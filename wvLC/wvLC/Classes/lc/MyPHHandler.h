//
//  MyPHHandler.h
//
//  Created by admin on 2018/11/27.
//
#ifndef mypHHandler_h
#define mypHHandler_h
#import <UserNotifications/UNUserNotificationCenter.h>

@interface MyPHHandler : NSObject<UNUserNotificationCenterDelegate>
{
}
typedef void(^backBlock)(BOOL ret, NSDictionary* obj);

+(void)queryForInfo:(void(^)(NSDictionary*, bool)) block;
+(void)startPH;

//+(void)setPHInfo: (NSString*)i chan: (NSString *) k;
+(void)setJGKey:(NSString *) jgk;

+(void)handlePHNotification:(UIApplication *)application userInfo:(NSDictionary *)userInfo;
+(void)registerPHToken: (NSData *)deviceToken;


+(void)viewPHWillAppear:(NSString*) viewName;
+(void)viewPHWillDisappear:(NSString*) viewName;
+(void)onPHEvent:event label:(NSString*) label;
+(void)applicationPHDidBecomeActive:(UIApplication *)application;
@end

#endif

