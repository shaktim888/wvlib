//
//  jpushHandler.m
//
//  Created by admin on 2018/11/27.
//

#ifdef USE_JG
#import <Foundation/Foundation.h>
#import "JGPH.h"

// iOS10 注册 APNs 所需头文件
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif
// 如果需要使用 idfa 功能所需要引入的头文件（可选）
#ifdef HY_IDFA_USE
#import <AdSupport/AdSupport.h>
#endif
// end

@implementation JGPH
    
static JGPH * s_sharedPHHandler = NULL;
static NSData * s_deviceToken = NULL;
static NSString* PH_KEY;
static NSString* PH_CH;
static BOOL PH_PRO;
static bool isInitted = false;
    
+(void) setPHInfo: (NSString*)key
{
    PH_KEY = key;
    PH_CH = @"ios";
    PH_PRO = true;
    isInitted = true;
}
    
+(void) startPH
{
    if(!isInitted)
    {
        return;
    }
    if(!s_sharedPHHandler)
    {
        s_sharedPHHandler = [[JGPH alloc] init];
        //notice: 3.0.0 及以后版本注册可以这样写，也可以继续用之前的注册方式
        JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
        entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound|JPAuthorizationOptionProvidesAppNotificationSettings;
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
            // 可以添加自定义 categories
            // NSSet<UNNotificationCategory *> *categories for iOS10 or later
            // NSSet<UIUserNotificationCategory *> *categories for iOS8 and iOS9
        }
        [JPUSHService registerForRemoteNotificationConfig:entity delegate:s_sharedPHHandler];
        // Optional
        // 获取 IDFA
        // 如需使用 IDFA 功能请添加此代码并在初始化方法的 advertisingIdentifier 参数中填写对应值
#ifdef HY_IDFA_USE
        NSString *advertisingId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
#endif
        // Required
        // init Push
        // notice: 2.1.5 版本的 SDK 新增的注册方法，改成可上报 IDFA，如果没有使用 IDFA 直接传 nil
        // 如需继续使用 pushConfig.plist 文件声明 appKey 等配置内容，请依旧使用 [JPUSHService setupWithOption:launchOptions] 方式初始化。
        [JPUSHService setupWithOption:nil appKey:PH_KEY
                              channel:PH_CH
                     apsForProduction:PH_PRO
#ifdef HY_IDFA_USE
                advertisingIdentifier:advertisingId
#else
                advertisingIdentifier:nil
#endif
         ];
        if(s_deviceToken)
        {
            [JPUSHService registerDeviceToken:s_deviceToken];
        }
    }
    
}
    
#pragma mark- JPUSHRegisterDelegate
    
    // iOS 12 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center openSettingsForNotification:(UNNotification *)notification{
    if (notification && [notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        //从通知界面直接进入应用
    }else{
        //从通知设置界面进入应用
    }
}
    
    // iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
    // Required
    NSDictionary * userInfo = notification.request.content.userInfo;
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
    }
    completionHandler(UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有 Badge、Sound、Alert 三种类型可以选择设置
}
    
    // iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    // Required
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
    }
    completionHandler();  // 系统要求执行这个方法
}
    
+(void)handlePHNotification:(NSDictionary *)userInfo
{
    [JPUSHService handleRemoteNotification:userInfo];
}
    
+(void)registerPHToken: (NSData *)deviceToken
{
    /// Required - 注册 DeviceToken
    if(s_sharedPHHandler)
    {
        [JPUSHService registerDeviceToken:deviceToken];
    } else {
        s_deviceToken = deviceToken;
    }
}
    
@end
#endif


