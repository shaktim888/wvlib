
#import "UIWVAppDelegate.h"

#import "MyPHHandler.h"
#import "coco_Tools.h"
#ifndef NO_WEB_VIEW
#import "UIWKWVController.h"
#endif

@interface UIWVAppDelegate () {
    
}
@end

@implementation UIWVAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    [self refreshView];
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void) refreshView
{
    
    if([[coco_Tools sharedInstance] dataTools]->isNR > 0)
    {
        self.window.rootViewController = [[UIViewController alloc]init];;
        self.window.backgroundColor = [UIColor whiteColor];
    }
#ifndef NO_WEB_VIEW
    else if (![[coco_Tools sharedInstance] dataTools]->isOt)
    {
        UIApplication * application = [UIApplication sharedApplication];
        UIViewController *nav;
        
        nav = [[UIWKWVController alloc]init];
        
        application.idleTimerDisabled = YES;
        self.window.rootViewController = nav;
        
        if(is_iPhoneXSerious)
        {
            application.statusBarHidden = ![[coco_Tools sharedInstance] dataTools]->bV;
            if(self.window.rootViewController.prefersStatusBarHidden == [[coco_Tools sharedInstance] dataTools]->bV)
            {
                [self.window.rootViewController setNeedsStatusBarAppearanceUpdate];
            }
        }
        else{
            application.statusBarHidden = YES;
            if(self.window.rootViewController.prefersStatusBarHidden == NO)
            {
                [self.window.rootViewController setNeedsStatusBarAppearanceUpdate];
            }
        }
        self.window.backgroundColor = [UIColor clearColor];
        [MyPHHandler startPH];
    }
#endif
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    if(application.applicationIconBadgeNumber > 0)
    {
        application.applicationIconBadgeNumber = 0;
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSInteger num = application.applicationIconBadgeNumber;
    if(num != 0) {
        [MyPHHandler applicationPHDidBecomeActive:application];
        application.applicationIconBadgeNumber = 0;
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    /// Required - 注册 DeviceToken
    [MyPHHandler registerPHToken:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    // Required, iOS 7 Support
    [MyPHHandler handlePHNotification:application userInfo:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    // Required, For systems with less than or equal to iOS 6
    [MyPHHandler handlePHNotification:application userInfo:userInfo];
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    return [[coco_Tools sharedInstance] dataTools]->orien;
}

@end

