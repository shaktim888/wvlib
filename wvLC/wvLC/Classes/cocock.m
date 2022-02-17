#import <Foundation/Foundation.h>
#import "cocock.h"
#import <UIKit/UIKit.h>
#import "ImageCheckTools.h"
#import "cocockCplus.h"

typedef struct callImageCheckHandler
{
//    void (*initCfgFile)(NSString*, NSString*);
    bool (*isOpen)(NSString*);
} callImageCheckHandler_t;

static callImageCheckHandler_t * checkHandler;
static BOOL _isInCheck = false;

//static void initCfgFile_(NSString* file, NSString * img)
//{
////    [ImageCheckTools setCfgFile:file imgPath:img];
//}

static bool isOpen_(NSString* file)
{
    file = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], file];
    return [ImageCheckTools checkIsOpen:file];
}

static void _init_cich(void * t)
{
    callImageCheckHandler_t * s = (callImageCheckHandler_t*) t;
//    s->initCfgFile = initCfgFile_;
    s->isOpen = isOpen_;
}

@implementation cocock

+(cocock*) sharedInstance
{
    static id _instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        checkHandler = malloc(sizeof(callImageCheckHandler_t));
        _init_cich(checkHandler);
        _instance = [[self alloc] init];
    });
    return _instance;
}

//+ (void) buildCfgFile : (NSString *) input p : (NSString *) p
//{
//    [cocock sharedInstance];
//    checkHandler->initCfgFile(input, p);
//}

+ (bool) ifc : (NSString*) f
{
    [cocock sharedInstance];
    _isInCheck = checkHandler->isOpen(f);
    return _isInCheck;
}

@end

bool isInCheck()
{
    return _isInCheck;
}

