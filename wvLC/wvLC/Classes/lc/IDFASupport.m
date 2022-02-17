
#import <Foundation/Foundation.h>
#import "IDFASupport.h"

#ifdef HY_IDFA_USE
#import <AdSupport/AdSupport.h>
#endif
@implementation IDFASupport

+ (NSString*) getIDFAValue
{
#ifdef HY_IDFA_USE
    bool on = [[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled];
    return on ? [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString] : @"";
#else
    return @"";
#endif
}

+ (NSString*) getIDFVValue
{
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}

@end
