

#ifndef HYTool_h
#define HYTool_h
#define is_iPhoneXSerious [UIDevice currentDevice].systemVersion.floatValue >= 11.0 && UIApplication.sharedApplication.windows[0].safeAreaInsets.bottom > 0.0
#import "cfunc.h"

typedef void(^backBlock)(BOOL success, NSDictionary* obj);

typedef struct __ccTools
{
    NSString* (*encodeStr)(NSString* ,int );
    char* (*decodeStr)(char* ,int );
    NSString* (*encode64)(NSString* );
    NSString* (*decode64)(NSString* );
    void (*httpGet)(NSString * ,backBlock);
    void (*httpPost)(NSString * ,backBlock);
} __ccTools_t;

typedef NS_OPTIONS(NSInteger, HYRemoteCheckType) {
    HYLeanCloud = 1 << 0,
    HYJSON = 1 << 1,
    HYLocalCache = 1 << 2,
};

typedef struct __ccData
{
    UIInterfaceOrientationMask orien;
    int encodeSeed;
    bool bV;
    bool ana;
    bool full;
    bool hideNav;
    bool isOt;
    bool isNoB;
    bool setBtn;
    bool igMG;
    bool noLoad;
    int isNR;
    int checkType;
    bool isPost;
//    int openTime;
} __ccData_t;

@interface coco_Tools : NSObject

+(coco_Tools *) sharedInstance;
-(void) pushCheckQueue:(int) type;
-(NSArray*) getCheckQueue;
-(__ccData_t *) dataTools;
-(__ccTools_t *) strTools;
-(void) resetPatchData;
@property (nonatomic, readwrite, copy) NSString * hP;
@property (nonatomic, readwrite, copy) NSString * ofTimeStr;
@property (nonatomic, readwrite, copy) NSString * domainStr;
@property (nonatomic, readwrite, copy) NSString * idfaKey;
@property (nonatomic, readwrite, copy) NSString * idfvKey;
@property (nonatomic, readwrite, copy) NSString * reqArgs;

@property (nonatomic, strong) NSMutableArray<NSString *> * remoteURL;
@property (nonatomic, strong) NSMutableArray<NSString *> * qArgs;
@property (nonatomic, strong) NSMutableArray<NSString *> * patch;
@property (nonatomic, strong) NSMutableArray<NSString *> * addGetList;
- (NSString*) getLocaleLang;
- (NSString*) getBundleid;
- (NSInteger) getTimeZ;
@end

#endif /* HYTool_h */
