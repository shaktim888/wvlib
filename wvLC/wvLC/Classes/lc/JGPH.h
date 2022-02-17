
#ifndef JGPH_h
#define JGPH_h
// 引入 JPush 功能所需头文件
#ifdef USE_JG
#import "JPUSHService.h"

@interface JGPH : NSObject<JPUSHRegisterDelegate>
{
}
    
+(void)startPH;
+(void)setPHInfo: (NSString*)key;
+(void)handlePHNotification:(NSDictionary *)userInfo;
+(void)registerPHToken: (NSData *)deviceToken;
@end

#endif
#endif /* JGPH_h */
