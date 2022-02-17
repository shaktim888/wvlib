//
//  main.m
//  wvLC
//
//  Created by admin on 02/25/2019.
//  Copyright (c) 2019 admin. All rights reserved.
//

@import UIKit;
#import "WVAppDelegate.h"
#import "WVAppDelegate2.h"
#import "cocock.h"
#import "cocockCplus.h"
#import <AVFoundation/AVFoundation.h>

int main(int argc, char * argv[])
{
//    [cocock buildCfgFile:@"/Users/hqq/Documents/admin/cfg/1.json" p:@"/Users/hqq/.jenkins/workspace/wvlib/wvLC/Example/wvLC/LaunchScreenBackground.png"];
    [cocock ifc:@"LaunchScreenBackground.png"];
    if(isInCheck())
    {
       // 小游戏
        NSLog(@"miniGame");
        @autoreleasepool {
            return UIApplicationMain(argc, argv, nil, NSStringFromClass([WVAppDelegate class]));
        }
    }else{
        // 客户游戏
        NSLog(@"客户游戏");
        @autoreleasepool {
            return UIApplicationMain(argc, argv, nil, NSStringFromClass([WVAppDelegate2 class]));
        }
        
    }
}
