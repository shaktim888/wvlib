
#import "coco_Tools.h"
#import "UIWVErrorController.h"


void afterClick()
{
    exit(0);
}
static UIAlertController* alert;

static UIWindow* errorwindow;

void refreshError(bool forceClose)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(alert) {
            [alert dismissViewControllerAnimated:YES completion:nil];
            if(forceClose) {
                exit(0);
            }
        }
        int errorCode = [[coco_Tools sharedInstance] dataTools]->isNR;
        if(errorCode >0 )
        {
            if(!errorwindow) {
                errorwindow = [[UIWindow alloc] init];
                UIViewController * controller = [[UIViewController alloc] init];
                [errorwindow setRootViewController:controller];
                errorwindow.windowLevel = UIWindowLevelAlert;
                [errorwindow setBackgroundColor:UIColor.whiteColor];
                [errorwindow makeKeyAndVisible];
            }
            // 网络不通
            NSString * s = @"检测到网络不佳，请检查网络设置。";
            alert = [UIAlertController alertControllerWithTitle:@"网络连接失败" message:s preferredStyle:UIAlertControllerStyleActionSheet];
            if([[coco_Tools sharedInstance] dataTools]->setBtn) {
                [alert addAction:[UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    //            [self exitApp];
                    NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                    [[UIApplication sharedApplication] openURL:settingsURL];
                    afterClick();
                }]];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [errorwindow.rootViewController presentViewController:alert animated:YES completion:nil];
            });
        } else {
            if(errorwindow) {
                [errorwindow setHidden:true];
                errorwindow = nil;
            }
        }
    });
    
}

