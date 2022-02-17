//
//  WVStateControl.m
//  Pods
//
//  Created by admin on 2019/11/11.
//

#import <Foundation/Foundation.h>
#import "WVStateControl.h"

#define STATUS_LEN 10

@interface WVStatusControl()
{
    int curStatus;
    int totalStatus;
    void* arr[STATUS_LEN];
}
@end


@implementation WVStatusControl

+ (instancetype)sharedInstance
{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nextStatus) name:@"nextStatus" object:nil];
        curStatus = 0;
        totalStatus = 0;
        memset(arr, 0, sizeof(void*) * STATUS_LEN);
    }
    return self;
}


- (void) addStep : (void *) p
{
    arr[totalStatus++] = p;
}

- (void) nextStatus
{
    if(curStatus < totalStatus) {
        curStatus++;
        ((void(*)(void))arr[curStatus - 1])();
    }
}

@end
