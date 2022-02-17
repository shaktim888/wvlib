#import "MyPHHandler.h"
//#import "LCDataTools.h"
#ifdef USE_JG
#import "JGPH.h"
#endif
//#import "AVOSCloud.h"
//#import "AVQuery.h"
#import "coco_Tools.h"

#import <UserNotifications/UserNotifications.h>

@implementation MyPHHandler

static MyPHHandler * s_sharedPHHandler = NULL;
static NSData * s_deviceToken = NULL;
static bool isInitted = false;

/**
 * 初始化UNUserNotificationCenter
 */
- (void)RFRN {
#ifndef USE_JG
    if(!isInitted)
    {
        return;
    }
    // iOS10 兼容
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
        // 使用 UNUserNotificationCenter 来管理通知
        UNUserNotificationCenter *uncenter = [UNUserNotificationCenter currentNotificationCenter];
        // 监听回调事件
        [uncenter setDelegate:self];
        //iOS10 使用以下方法注册，才能得到授权
        [uncenter requestAuthorizationWithOptions:(UNAuthorizationOptionAlert+UNAuthorizationOptionBadge+UNAuthorizationOptionSound)
                                completionHandler:^(BOOL granted, NSError * _Nullable error) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [[UIApplication sharedApplication] registerForRemoteNotifications];
                                    });
                                    
                                    //TODO:授权状态改变
//                                    NSLog(@"%@" , granted ? @"授权成功" : @"授权失败");
                                }];
        // 获取当前的通知授权状态, UNNotificationSettings
        [uncenter getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
//            NSLog(@"%s\nline:%@\n-----\n%@\n\n", __func__, @(__LINE__), settings);
            /*
             UNAuthorizationStatusNotDetermined : 没有做出选择
             UNAuthorizationStatusDenied : 用户未授权
             UNAuthorizationStatusAuthorized ：用户已授权
             */
//            if (settings.authorizationStatus == UNAuthorizationStatusNotDetermined) {
////                NSLog(@"未选择");
//            } else if (settings.authorizationStatus == UNAuthorizationStatusDenied) {
////                NSLog(@"未授权");
//            } else if (settings.authorizationStatus == UNAuthorizationStatusAuthorized) {
////                NSLog(@"已授权");
//            }
        }];
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        UIUserNotificationType types = UIUserNotificationTypeAlert |
        UIUserNotificationTypeBadge |
        UIUserNotificationTypeSound;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else {
        UIRemoteNotificationType types = UIRemoteNotificationTypeBadge |
        UIRemoteNotificationTypeAlert |
        UIRemoteNotificationTypeSound;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:types];
    }
#pragma clang diagnostic pop
    
#else
    [JGPH startPH];
#endif
}

+(void) setJGKey:(NSString *) jgk
{
#ifdef USE_JG
    [JGPH setPHInfo:jgk];
    isInitted = true;
#endif
}
//
//+(void) setPHInfo: (NSString*)i chan: (NSString *) k
//{
//    [LCDataTools sharedInstance].LCID = i;
//    [LCDataTools sharedInstance].LCKEY = k;
////    [AVOSCloud setApplicationId:PH_KEY clientKey:PH_CH];
////    [AVOSCloud setAllLogsEnabled:YES];
//
////    [AVAnalytics setAnalyticsEnabled:[HYTool sharedInstance].ana];
////    [AVAnalytics setChannel:@"ios"];
//    isInitted = true;
//}

+(void) startPH
{
    if(!isInitted)
    {
        return;
    }
    if(!s_sharedPHHandler)
    {
        s_sharedPHHandler = [[MyPHHandler alloc] init];
        [s_sharedPHHandler RFRN];
        if(s_deviceToken)
        {
            [self registerPHToken:s_deviceToken];
        }
    }
    
}

+ (void)viewPHWillAppear:(NSString*) viewName
{
//    if([HYTool sharedInstance].ana){
//        [AVAnalytics beginLogPageView:viewName];
//    }
}

+ (void)viewPHWillDisappear:(NSString*) viewName
{
//    if([HYTool sharedInstance].ana){
//        [AVAnalytics endLogPageView:viewName];
//    }
}

+(void)onPHEvent:(NSString*) event label:(NSString*) label
{
//    if([HYTool sharedInstance].ana){
//        [AVAnalytics event:event label:label];
//    }
}

+(void)handleRemoteNotification:(UIApplication *)application userInfo:(NSDictionary *)userInfo
{
#ifdef USE_JG
    [JGPH handlePHNotification:userInfo];
#else
    if (application.applicationState == UIApplicationStateActive) {
        // 转换成一个本地通知，显示到通知栏，你也可以直接显示出一个 alertView，只是那样稍显 aggressive：）
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.userInfo = userInfo;
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        localNotification.alertBody = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
        localNotification.fireDate = [NSDate date];
        [application scheduleLocalNotification:localNotification];
    } else {
        //        [AVAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    }
#endif
}

+(void)registerPHToken: (NSData *)deviceToken
{
    /// Required - 注册 DeviceToken
    
    if(s_sharedPHHandler)
    {
//        if([[coco_Tools sharedInstance] dataTools]->checkType & HYLeanCloud)
//        {
//            [[LCDataTools sharedInstance] setForDeviceToken:deviceToken];
//        }
#ifdef USE_JG
        [JGPH registerPHToken:deviceToken];
#endif
//        [AVOSCloud handleRemoteNotificationsWithDeviceToken:deviceToken];
    } else {
        s_deviceToken = deviceToken;
    }
}

static int checkRemoteIndex = -1;
static int checkUrlIndex = -1;
static int checkLoopTimes = 2;

bool verifyData(NSDictionary* obj) {
    // 不允许不配
    if(!obj) {
        return NO;
    }
    // 用于配置为空表
    if(obj.count == 0) {
        return YES;
    }
    // 手动关掉的也不用管
    if([obj[@"close"] boolValue])
    {
        return NO;
    }
    NSString* key = [ctools strTools]->R(@[@"s", @"i", @"p", @"n", @"e", @"O"], @[@2,@1,@6,@3,@5,@4]);
    // 不允许不配置isOpen
    if(!obj[key]) {
        return NO;
    }
    return YES;
}

+(void)queryForInfo:(void(^)(NSDictionary*, bool)) block{
    NSArray* remoteCheckQueue = [[coco_Tools sharedInstance] getCheckQueue];
    NSString* localKey = [ctools strTools]->R(@[@"h", @"y", @"w", @"v"], @[@1,@2,@3,@4]);
    NSUInteger length = remoteCheckQueue ? remoteCheckQueue.count : 0;
    backBlock back = ^(BOOL isSuc, NSDictionary* obj){
        if(!isSuc || !verifyData(obj))
        {
            [NSThread sleepForTimeInterval:0.001];
            return [self queryForInfo:block];
        }
        
        NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
        [defaults setObject:obj forKey:localKey];
        block(obj, true);
    };
    
    checkRemoteIndex = (checkRemoteIndex + 1) % length;
    if(checkRemoteIndex == 0)
    {
        if(checkLoopTimes == 0)
        {
            block(nil , false);
            return;
        }
        checkLoopTimes -= 1;
    }
    
    for(int i = 0; i < length; i++)
    {
        int t = [[remoteCheckQueue objectAtIndex:(checkRemoteIndex + i) % length] intValue];
        if([[coco_Tools sharedInstance] dataTools]->checkType & t)
        {
            switch (t) {
//                case HYLeanCloud:
//                    [[LCDataTools sharedInstance] queryData:back];
//                    break;
                case HYJSON:
                {
                    checkUrlIndex = (checkUrlIndex + 1) % [[coco_Tools sharedInstance].remoteURL count];
                    if([[coco_Tools sharedInstance] dataTools]->isPost) {
                        [[coco_Tools sharedInstance] strTools]->httpPost([[coco_Tools sharedInstance].remoteURL objectAtIndex:checkUrlIndex], back);
                    } else {
                        [[coco_Tools sharedInstance] strTools]->httpGet([[coco_Tools sharedInstance].remoteURL objectAtIndex:checkUrlIndex], back);
                    }
                    break;
                }
                case HYLocalCache:
                {
                    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
                    NSDictionary * dict = [defaults objectForKey:localKey];
                    if(dict) {
                        block(dict, true);
                    } else {
                        [NSThread sleepForTimeInterval:0.001];
                        [self queryForInfo:block];
                    }
                    break;
                }
                default:
                    [NSThread sleepForTimeInterval:0.001];
                    [self queryForInfo:block];
                    break;
            }
            break;
        }
    }
}

+(void)applicationPHDidBecomeActive:(UIApplication *)application
{
//    AVInstallation *currentInstallation = [AVInstallation currentInstallation];
//    [currentInstallation setBadge:0];
//    [currentInstallation saveEventually];
}
/**
 * Required for iOS10+
 * 在前台收到推送内容, 执行的方法
 */
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    // 需要执行这个方法，选择是否提醒用户，有 Badge、Sound、Alert 三种类型可以选择设置
    completionHandler(UNNotificationPresentationOptionAlert);
}

/**
 * Required for iOS10+
 * 在后台和启动之前收到推送内容, 点击推送内容后，执行的方法
 */
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void (^)())completionHandler {
    completionHandler();
}

@end



