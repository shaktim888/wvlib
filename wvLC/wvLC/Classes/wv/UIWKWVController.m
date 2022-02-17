#ifndef NO_WEB_VIEW
#import "UIWKWVController.h"
#import <WebKit/WebKit.h>
#import "coco_Tools.h"
#import "IDFASupport.h"
#import "MBProgressHUD.h"

#import "MyPHHandler.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

@interface UIWKWVController ()<WKUIDelegate
                        ,WKNavigationDelegate
//                        ,WKScriptMessageHandler
                        >
@property (nonatomic, strong) WKWebView *subview;
@property (nonatomic, strong) WKWebViewConfiguration *wkConfig;

/*
 *1.添加UIProgressView属性
 */
@property (nonatomic, strong) UIWindow *launchWd;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UIToolbar * toolbarView;

@end

struct wkControlStruct
{
    void (*onCatchUrlComing)(WKWebView * , WKNavigationAction * , void (^)(WKNavigationActionPolicy));
    void (*createOutAlert)(UIWKWVController* control);
};

static struct wkControlStruct wkC;

static void _onCatchUrlComing(WKWebView * webView, WKNavigationAction * navigationAction, void (^decisionHandler)(WKNavigationActionPolicy)) {
    //允许页面跳转
    if(navigationAction.targetFrame == nil){
        if(navigationAction.request)
        {
            [webView loadRequest:navigationAction.request];
        }
        decisionHandler(WKNavigationActionPolicyAllow);
        return;
    }
    NSURL * url = navigationAction.request.URL;
    NSString * requestString = url.absoluteString;
    NSLog(@"%@", requestString);
    NSArray *patch = [coco_Tools sharedInstance].patch;
    for (NSString *p in patch) {
        if ([requestString hasPrefix:p]) {
            [[UIApplication sharedApplication] openURL:url];
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
    }
    NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    NSArray *queryItems = urlComponents.queryItems;
    if([coco_Tools sharedInstance].qArgs.count > 0) {
        for(int i = 0; i < [coco_Tools sharedInstance].qArgs.count; i += 2)
        {
            NSString* k = [[coco_Tools sharedInstance].qArgs objectAtIndex:i];
            NSString* v = [[coco_Tools sharedInstance].qArgs objectAtIndex:i + 1];
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name=%@", k];
            NSURLQueryItem *queryItem = [[queryItems filteredArrayUsingPredicate:predicate] firstObject];
            if(queryItem && queryItem.value && [queryItem.value isEqual: v])
            {
                [[UIApplication sharedApplication] openURL:url];
                decisionHandler(WKNavigationActionPolicyCancel);
                return;
            }
        }
    }
    if([[coco_Tools sharedInstance].addGetList count] > 0)
    {
        bool isNeedArgs = false;
        for (NSString *p in [coco_Tools sharedInstance].addGetList) {
            if ([requestString hasPrefix:p]) {
                isNeedArgs = true;
            }
        }
        if(isNeedArgs)
        {
            // 添加idfa|idfv参数接入
            NSMutableDictionary * paramDict = [[NSMutableDictionary alloc] init];
            if([coco_Tools sharedInstance].idfaKey && ![[coco_Tools sharedInstance].idfaKey isEqualToString:@""])
            {
                [paramDict setObject:[IDFASupport getIDFAValue] forKey:[coco_Tools sharedInstance].idfaKey];
            }
            if([coco_Tools sharedInstance].idfvKey && ![[coco_Tools sharedInstance].idfvKey isEqualToString:@""])
            {
                [paramDict setObject:[IDFASupport getIDFVValue] forKey:[coco_Tools sharedInstance].idfvKey];
            }
            if([paramDict count] > 0)
            {
                NSMutableArray * newQueryItems = [NSMutableArray arrayWithArray:queryItems];
                bool hasParams = false;
                for(NSString * param in paramDict)
                {
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name=%@", param];
                    NSURLQueryItem *queryItem = [[queryItems filteredArrayUsingPredicate:predicate] firstObject];
                    if(queryItem)
                    {
                        hasParams = true;
                        break;
                    }
                    else
                    {
                        [newQueryItems addObject:[[NSURLQueryItem alloc] initWithName:param value:paramDict[param]]];
                    }
                }
                if(hasParams)
                {
                    decisionHandler(WKNavigationActionPolicyAllow);
                    return;
                } else {
                    [urlComponents setQueryItems:newQueryItems];
                    NSURLRequest *request = [NSURLRequest requestWithURL:urlComponents.URL];
                    [webView loadRequest:request];
                    decisionHandler(WKNavigationActionPolicyCancel);
                    return;
                }
            }
        }
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

static void _createOutAlert(UIWKWVController* control)
{
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:[ctools strTools]->R(@[@"示", @"提"] ,@[@2,@1])
                                message:[ctools strTools]->R(@[@"打", @"？", @"用", @"开", @"浏", @"外", @"器", @"览", @"部"] ,@[@3,@6,@9,@5,@8,@7,@1,@4,@2])
                                preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * _okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:control.subview.URL.absoluteString]];
    }];
    UIAlertAction * _cancelAction =[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:_okAction];
    [alert addAction:_cancelAction];
    [control presentViewController:alert animated:true completion:nil];
}

static void buildWKControl()
{
    wkC.onCatchUrlComing = _onCatchUrlComing;
    wkC.createOutAlert = _createOutAlert;
}
//
//// WKWebView 内存不释放的问题解决
//@interface WeakWebViewScriptMessageDelegate : NSObject<WKScriptMessageHandler>
//
////WKScriptMessageHandler 这个协议类专门用来处理JavaScript调用原生OC的方法
//@property (nonatomic, weak) id<WKScriptMessageHandler> scriptDelegate;
//
//- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)scriptDelegate;
//
//@end
//@implementation WeakWebViewScriptMessageDelegate
//
//- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)scriptDelegate {
//    self = [super init];
//    if (self) {
//        _scriptDelegate = scriptDelegate;
//    }
//    return self;
//}
//
//#pragma mark - WKScriptMessageHandler
////遵循WKScriptMessageHandler协议，必须实现如下方法，然后把方法向外传递
////通过接收JS传出消息的name进行捕捉的回调方法
//- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
//
//    if ([self.scriptDelegate respondsToSelector:@selector(userContentController:didReceiveScriptMessage:)]) {
//        [self.scriptDelegate userContentController:userContentController didReceiveScriptMessage:message];
//    }
//}
//
//@end


@implementation UIWKWVController

static bool isShowProgress = false;

+ (UIEdgeInsets)safeAreaInset:(UIView *)view {
    if ([UIDevice currentDevice].systemVersion.floatValue >= 11.0) {
        return view.safeAreaInsets;
    }
    return UIEdgeInsetsZero;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;//隐藏为YES，显示为NO
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    UIEdgeInsets edgeInsets = [self.class safeAreaInset:self.view];
    [self doResize:edgeInsets];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    UIEdgeInsets edgeInsets = [self.class safeAreaInset:self.view];
    [self doResize:edgeInsets];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator
{
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
    {
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context)
    {
        UIEdgeInsets edgeInsets = [self.class safeAreaInset:self.view];
        [self doResize:edgeInsets];
    }];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

- (void)enableProgress : (BOOL) val
{
    if(val != isShowProgress)
    {
        isShowProgress = val;
        _progressView.hidden = !val;
        _toolbarView.hidden = !val;
        if(val)
        {
            [self.view addSubview:_toolbarView];
            [self.view addSubview:_progressView];
        }
        else{
            [_progressView removeFromSuperview];
            [_toolbarView removeFromSuperview];
        }
    }
}

- (void)doResize: (UIEdgeInsets) edgeInsets
{
    float width = [UIScreen mainScreen].bounds.size.width;
    float height = [UIScreen mainScreen].bounds.size.height;
    CGRect newFrame;
    if( width > height) { // 横
        if([[coco_Tools sharedInstance] dataTools]->full) {
            newFrame = CGRectMake(0, 0, width, height);
        }else{
            newFrame = CGRectMake(edgeInsets.left, edgeInsets.top, width - edgeInsets.right - edgeInsets.left, height - edgeInsets.bottom - edgeInsets.top);
        }
        [self enableProgress:false];
    } else { // 竖
        if([[coco_Tools sharedInstance] dataTools]->igMG){
            edgeInsets.bottom = 0;
        }
        CGFloat progressBarHeight = 2.f;
        if([[coco_Tools sharedInstance] dataTools]->full) {
            if([[coco_Tools sharedInstance] dataTools]->hideNav) {
                newFrame = CGRectMake(0, 0, width, height);
            } else {
                newFrame = CGRectMake(0, 0, width, height - 40);
                _progressView.frame = CGRectMake(0, 0, width, progressBarHeight);
                _toolbarView.frame = CGRectMake(0, height - 40, width, 40);
            }
        } else {
            if([[coco_Tools sharedInstance] dataTools]->hideNav) {
                newFrame = CGRectMake(edgeInsets.left, edgeInsets.top, width - edgeInsets.right - edgeInsets.left, height - edgeInsets.bottom - edgeInsets.top);
            } else {
                newFrame = CGRectMake(edgeInsets.left, edgeInsets.top, width - edgeInsets.right - edgeInsets.left, height - edgeInsets.bottom - edgeInsets.top - 40);
                _progressView.frame = CGRectMake(edgeInsets.left, edgeInsets.top, width, progressBarHeight);
                _toolbarView.frame = CGRectMake(edgeInsets.left, height - edgeInsets.bottom - 40, width - edgeInsets.right - edgeInsets.left, 40);
            }
        }
        [self enableProgress:![[coco_Tools sharedInstance] dataTools]->hideNav];
    }
    if (!CGRectEqualToRect(self.subview.frame, newFrame)) {
        self.subview.frame = newFrame;
    }
}

#pragma mark - 初始化wkWebView

- (WKWebViewConfiguration *)wkConfig {
    if (!_wkConfig) {
        _wkConfig = [[WKWebViewConfiguration alloc] init];
        _wkConfig.allowsInlineMediaPlayback = YES;
        if ([UIDevice currentDevice].systemVersion.floatValue >= 9.0) {
            _wkConfig.allowsPictureInPictureMediaPlayback = YES;
        }
//        _wkConfig.selectionGranularity = YES;
        _wkConfig.mediaPlaybackRequiresUserAction = false;
        if ([UIDevice currentDevice].systemVersion.floatValue >= 9.0) {
            _wkConfig.requiresUserActionForMediaPlayback = false;
        }
        if ([UIDevice currentDevice].systemVersion.floatValue >= 10.0) {
            _wkConfig.mediaTypesRequiringUserActionForPlayback = false;
        }
        //自定义的WKScriptMessageHandler 是为了解决内存不释放的问题
//        WeakWebViewScriptMessageDelegate *weakScriptMessageDelegate = [[WeakWebViewScriptMessageDelegate alloc] initWithDelegate:self];
        //这个类主要用来做native与JavaScript的交互管理
//        WKUserContentController * wkUController = [[WKUserContentController alloc] init];
        //注册一个name为jsToOcNoPrams的js方法 设置处理接收JS方法的对象
//        [wkUController addScriptMessageHandler:weakScriptMessageDelegate  name:@"jsToOcNoPrams"];
//        [wkUController addScriptMessageHandler:weakScriptMessageDelegate  name:@"jsToOcWithPrams"];
        
//        _wkConfig.userContentController = wkUController;
        
//        //以下代码适配文本大小
//        NSString *jSString = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";
//        //用于进行JavaScript注入
//        WKUserScript *wkUScript = [[WKUserScript alloc] initWithSource:jSString injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
//        [_wkConfig.userContentController addUserScript:wkUScript];
        
    }
    return _wkConfig;
}

- (WKWebView *)subview {
    if (!_subview) {
        _subview = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 40) configuration:self.wkConfig];
        _subview.navigationDelegate = self;
        _subview.UIDelegate = self;
        _subview.scrollView.bounces = NO;
        [self.view addSubview:_subview];
    }
    return _subview;
}
/*
 *6.在dealloc中取消监听
 */

- (void)dealloc {
    //移除注册的js方法
//    [[self.subview config gguration].userContentController removeScriptMessageHandlerForName:@"jsToOcNoPrams"];
//    [[self.subview configuration].userContentController removeScriptMessageHandlerForName:@"jsToOcWithPrams"];
    //移除观察者
    [self.subview removeObserver:self forKeyPath:@"estimatedProgress"];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    buildWKControl();
    [self setupToolView];
    
    /*
     *2.初始化progressView
     */
    self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 2)];
    self.progressView.backgroundColor = [UIColor blueColor];
    //设置进度条的高度，下面这句代码表示进度条的宽度变为原来的1倍，高度变为原来的1.5倍.
    self.progressView.transform = CGAffineTransformMakeScale(1.0f, 1.5f);
    [self.view addSubview:self.progressView];
    
    /*
     *3.添加KVO，WKWebView有一个属性estimatedProgress，就是当前网页加载的进度，所以监听这个属性。
     */
    [self.subview addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    
    UIEdgeInsets edgeInsets = [self.class safeAreaInset:self.view];
    [self doResize:edgeInsets];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onFrameResize:) name:UIDeviceOrientationDidChangeNotification object:nil];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        UIEdgeInsets edgeInsets = [self.class safeAreaInset:self.view];
        [self doResize:edgeInsets];
    });

    [self startLoad];
}

- (void) onFrameResize:(NSNotification*) noti 
{
    UIEdgeInsets edgeInsets = [self.class safeAreaInset:self.view];
    [self doResize:edgeInsets];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupToolView {
    self.toolbarView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIBarButtonItem *homeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(goHomeAction)];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(goBackAction)];
    UIBarButtonItem *forwardButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(goForwardAction)];
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshAction)];
    UIBarButtonItem *outerButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(openOutAction)];
    
    [self.toolbarView setItems:@[fixedSpace,homeButton,fixedSpace,backButton,fixedSpace,forwardButton,fixedSpace,refreshButton,fixedSpace,outerButton,fixedSpace] animated:YES];
}

#pragma mark - start load web

- (void)startLoad {
    [self goHomeAction];
    [self showLaunchView];
}

#pragma mark - 监听

/*
 *4.在监听方法中获取网页加载的进度，并将进度赋给progressView.progress
 */

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        self.progressView.progress = self.subview.estimatedProgress;
        [self setBarProgress:self.progressView.progress];
        if (self.progressView.progress == 1) {
            /*
             *添加一个简单的动画，将progressView的Height变为1.4倍
             *动画时长0.25s，延时0.3s后开始动画
             *动画结束后将progressView隐藏
             */
            __weak typeof (self)weakSelf = self;
            [UIView animateWithDuration:0.25f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
                weakSelf.progressView.transform = CGAffineTransformMakeScale(1.0f, 1.4f);
            } completion:^(BOOL finished) {
                weakSelf.progressView.hidden = YES;
            }];
        }
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - WKWKNavigationDelegate Methods

/*
 *5.在WKWebViewd的代理中展示进度条，加载完成后隐藏进度条
 */

//开始加载
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    //开始加载网页时展示出progressView
    self.progressView.hidden = !isShowProgress;
    //开始加载网页的时候将progressView的Height恢复为1.5倍
    self.progressView.transform = CGAffineTransformMakeScale(1.0f, 1.5f);
    //防止progressView被网页挡住
    [self.view bringSubviewToFront:self.progressView];
}

//加载完成
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    //加载完成后隐藏progressView
    self.progressView.hidden = YES;
    [self closeLauchView];
}

//加载失败
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    //加载失败同样需要隐藏progressView
    self.progressView.hidden = YES;
    [self closeLauchView];
}

- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    WKFrameInfo *frameInfo = navigationAction.targetFrame;
    if (![frameInfo isMainFrame]) {
        if(navigationAction.request)
        {
            [webView loadRequest:navigationAction.request];
        }
    }
    return nil;
}

//页面跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    wkC.onCatchUrlComing(webView, navigationAction, decisionHandler);
}


#pragma mark - Tool bar item action

- (void)goHomeAction {
    [self loadURL: [[coco_Tools sharedInstance] hP]];
}

- (void)goBackAction {
    if ([self.subview canGoBack]) {
        [self.subview goBack];
    }
}

- (void)goForwardAction {
    if ([self.subview canGoForward]) {
        [self.subview goForward];
    }
}

- (void)refreshAction {
    [self.subview reload];
}


- (void)openOutAction {
    wkC.createOutAlert(self);
}

- (void)loadURL :(NSString*) url {
    NSURL *nurl = [NSURL URLWithString:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:nurl];
    [self.subview loadRequest:request];
}

#pragma mark ================ WKScriptMessageHandler ================

//拦截执行网页中的JS方法
//- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    
    //服务器固定格式写法 window.webkit.messageHandlers.名字.postMessage(内容);
    //客户端写法 message.name isEqualToString:@"名字"]
//    if ([message.name isEqualToString:@"WXPay"]) {
//        NSLog(@"%@", message.body);
//        //调用微信支付方法
//        //        [self WXPayWithParam:message.body];
//    }
//    NSLog(@"name:%@\\\\n body:%@\\\\n frameInfo:%@\\\\n",message.name,message.body,message.frameInfo);
//    //用message.body获得JS传出的参数体
//    NSDictionary * parameter = message.body;
//    //JS调用OC
//    if([message.name isEqualToString:@"jsToOcNoPrams"]){
//
//    }else if([message.name isEqualToString:@"jsToOcWithPrams"]){
//
//    }
//}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{
    //    DLOG(@"msg = %@ frmae = %@",message,frame);
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }])];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = defaultText;
    }];
    [alertController addAction:([UIAlertAction actionWithTitle:@"完成" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(alertController.textFields[0].text?:@"");
    }])];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void) setBarProgress: (float) progress
{
    if(self.launchWd) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // Instead we could have also passed a reference to the HUD
            // to the HUD to myProgressTask as a method parameter.
            [MBProgressHUD HUDForView:self.launchWd.rootViewController.view].progress = progress;
        });
        if(progress >= 1) {
            [self closeLauchView];
        }
    }
}

- (void)showLaunchView {
    if([[coco_Tools sharedInstance] dataTools]->noLoad) {
        return;
    }
    if(self.launchWd) {
        return;
    }
    UIViewController *controller = [UIViewController new];
    [controller.view setBackgroundColor:[UIColor clearColor]];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:controller.view animated:YES];
    hud.mode = MBProgressHUDModeDeterminateHorizontalBar;
    hud.label.text = NSLocalizedString(@"Loading...", @"Loading");
    
    self.launchWd = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.launchWd.backgroundColor = [UIColor whiteColor];
    self.launchWd.rootViewController = controller;
    self.launchWd.windowLevel = [[[UIApplication sharedApplication] windows] lastObject].windowLevel + 1;
    [self.launchWd makeKeyAndVisible];
}

- (void) closeLauchView
{
    if(self.launchWd)
    {
        self.launchWd.hidden = YES;
        self.launchWd = nil;
        [self.view.window makeKeyAndVisible];
    }
    UIEdgeInsets edgeInsets = [self.class safeAreaInset:self.view];
    [self doResize:edgeInsets];
}

@end

#endif
