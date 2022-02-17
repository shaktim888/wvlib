//
//  WVStateControl.h
//  Pods
//
//  Created by admin on 2019/11/11.
//

#ifndef WVStateControl_h
#define WVStateControl_h

@interface WVStatusControl : NSObject

+ (instancetype)sharedInstance;
- (void) addStep : (void *) p;
- (void) nextStatus;
@end

#endif /* WVStateControl_h */
