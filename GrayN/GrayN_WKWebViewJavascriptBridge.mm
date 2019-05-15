//
//  WKWebViewJavascriptBridge.m
//
//  Created by @LokiMeyburg on 10/15/14.
//  Copyright (c) 2014 @LokiMeyburg. All rights reserved.
//


#import "GrayN_WKWebViewJavascriptBridge.h"
#import "GrayN_WebViewController.h"
#import "GrayNbaseSDK.h"
#import "GrayN_BaseControl.h"
#import "GrayNcommon.h"
#import "GrayN_Offical.h"
#import "GrayNchannel.h"

#define GrayNgetStatusBarOrientation [UIApplication sharedApplication].statusBarOrientation
#define kStatusBarHeight 35
#define kwkCloseBtnWidth 28
#define kwkCloseBtnHeight 25
#define kBtnInterval 70

GrayNusing_NameSpace;

#if defined(supportsWKWebKit)
UIButton *wkCloseBtn;
UIButton *wkForwardBtn;
UIButton *wkBackwardBtn;
UIButton *wkRefreshBtn;
BOOL wkTopBarUp;
BOOL wkShowNavbar;
UIView *wkTopBar;
CGRect wkWebviewBounds;

@implementation GrayN_WKWebViewJavascriptBridge {
    WKWebView* _webView;
    id<WKNavigationDelegate> _webViewDelegate;
    long _uniqueId;
    GrayN_WebViewJavascriptBridgeBase *_base;
}
    @synthesize jsBridgeRequest = _jsBridgeRequest;

/* API
 *****/

+ (void)GrayNenableLogging { [GrayN_WebViewJavascriptBridgeBase GrayNenableLogging]; }

+ (instancetype)GrayNbridgeForWebView:(WKWebView*)webView
{
    GrayN_WKWebViewJavascriptBridge* bridge = [[self alloc] init];
    [bridge _setupInstance:webView];
    [bridge reset];
    
    wkTopBar = [[UIView alloc] init] ;
    wkTopBar.backgroundColor = GrayNblackColor;
    [webView.superview addSubview:wkTopBar];
    [wkTopBar release];
    wkCloseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"OurSDK_res.bundle/images/closeBtn.png"];
    UIImage *backImage = [UIImage imageWithContentsOfFile:path];
    [wkCloseBtn setImage:backImage forState:UIControlStateNormal];
    
    wkTopBar.frame = CGRectMake(0, 0, webView.frame.size.width, kStatusBarHeight);
    wkCloseBtn.frame = CGRectMake(webView.frame.size.width-wkTopBar.frame.size.height+2, 2, kwkCloseBtnWidth, kwkCloseBtnHeight);
    
    wkBackwardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"OurSDK_res.bundle/images/backwardBtn.png"];
    backImage = [UIImage imageWithContentsOfFile:path];
    [wkBackwardBtn setImage:backImage forState:UIControlStateNormal];
    
    wkForwardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"OurSDK_res.bundle/images/forwardBtn.png"];
    backImage = [UIImage imageWithContentsOfFile:path];
    [wkForwardBtn setImage:backImage forState:UIControlStateNormal];
    
    
    wkRefreshBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"OurSDK_res.bundle/images/refreshBtn.png"];
    backImage = [UIImage imageWithContentsOfFile:path];
    [wkRefreshBtn setImage:backImage forState:UIControlStateNormal];
    wkRefreshBtn.frame = CGRectMake(10, 2, kwkCloseBtnWidth, kwkCloseBtnHeight);
    if (GrayNisStraightBangsDevice) {
        if ([GrayN_BaseControl GrayN_Base_WindowIsLandScape])
        wkCloseBtn.center = CGPointMake(wkCloseBtn.center.x-GrayNstraightBangsTopEdge*1.5, wkCloseBtn.center.y);
        else
        wkCloseBtn.center = CGPointMake(wkCloseBtn.center.x-GrayNstraightBangsTopEdge*0.8, wkCloseBtn.center.y*1.5);
        
        wkRefreshBtn.center = CGPointMake(wkRefreshBtn.center.x+GrayNstraightBangsTopEdge, wkRefreshBtn.center.y);
    } else {
        wkCloseBtn.center = CGPointMake(wkCloseBtn.center.x, kStatusBarHeight*0.5);
    }
    wkBackwardBtn.frame = CGRectMake(wkRefreshBtn.frame.origin.x+1.5*kBtnInterval, 2, kwkCloseBtnWidth, kwkCloseBtnHeight);
    wkForwardBtn.frame = CGRectMake(wkBackwardBtn.frame.origin.x+kBtnInterval, 2, kwkCloseBtnWidth, kwkCloseBtnHeight);
    
    wkRefreshBtn.center = CGPointMake(wkRefreshBtn.center.x, kStatusBarHeight*0.5);
    wkForwardBtn.center = CGPointMake(wkForwardBtn.center.x, kStatusBarHeight*0.5);
    wkBackwardBtn.center = CGPointMake(wkBackwardBtn.center.x, kStatusBarHeight*0.5);
    
    [wkCloseBtn addTarget:bridge action:@selector(closeBtn) forControlEvents:UIControlEventTouchUpInside];
    [wkRefreshBtn addTarget:bridge action:@selector(refreshBtn) forControlEvents:UIControlEventTouchUpInside];
    [wkForwardBtn addTarget:bridge action:@selector(forwardBtn) forControlEvents:UIControlEventTouchUpInside];
    [wkBackwardBtn addTarget:bridge action:@selector(backwardBtn) forControlEvents:UIControlEventTouchUpInside];
    
    [wkTopBar addSubview:wkCloseBtn];
    [wkTopBar addSubview:wkRefreshBtn];
    [wkTopBar addSubview:wkForwardBtn];
    [wkTopBar addSubview:wkBackwardBtn];
    
    [wkTopBar setHidden:YES];
    [wkCloseBtn setHidden:YES];
    [wkRefreshBtn setHidden:YES];
    [wkForwardBtn setHidden:YES];
    [wkBackwardBtn setHidden:YES];
    wkTopBarUp = YES;
    wkWebviewBounds = [GrayN_BaseControl GrayN_Base_WindowRect];
    return bridge;
}
- (void)GrayNsetShowNavbar:(BOOL)status
{
    wkShowNavbar = status;
}
- (void)GrayNreshapeWebview
{
    GrayNcommon::GrayN_DebugLog(@"opReshapeWebview wkShowNavbar:%d", wkShowNavbar);
    float width = MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    float height = MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    
    if (GrayNgetStatusBarOrientation == UIInterfaceOrientationLandscapeLeft ||
        GrayNgetStatusBarOrientation == UIInterfaceOrientationLandscapeRight) {
        _webView.frame = CGRectMake(0, 0, width, height-kStatusBarHeight);
        
    } else {
        _webView.frame = CGRectMake(0, 0, height, width-kStatusBarHeight);
    }
    
    if (!wkShowNavbar) {
        if (GrayNgetStatusBarOrientation == UIInterfaceOrientationLandscapeLeft ||
            GrayNgetStatusBarOrientation == UIInterfaceOrientationLandscapeRight) {
            _webView.frame = CGRectMake(0, 0, width, height);
        } else {
            _webView.frame = CGRectMake(0, 0, height, width);
            
        }
        [wkTopBar setHidden:YES];
        [wkRefreshBtn setHidden:YES];
        [wkForwardBtn setHidden:YES];
        [wkBackwardBtn setHidden:YES];
        [wkCloseBtn setHidden:YES];
        wkWebviewBounds = _webView.bounds;
        
        return;
    }
    [wkTopBar setHidden:NO];
    [wkRefreshBtn setHidden:NO];
    [wkForwardBtn setHidden:NO];
    [wkBackwardBtn setHidden:NO];
    [wkCloseBtn setHidden:NO];
    
    if (GrayNisStraightBangsDevice) {
        _webView.frame = CGRectMake(0, 0, _webView.frame.size.width, _webView.frame.size.height-GrayNstraightBangsTopEdge*0.6);
        wkTopBar.frame = CGRectMake(0, _webView.frame.size.height, _webView.frame.size.width, kStatusBarHeight+GrayNstraightBangsTopEdge*0.6);
    } else
        wkTopBar.frame = CGRectMake(0, _webView.frame.size.height, _webView.frame.size.width, kStatusBarHeight);
    
    wkCloseBtn.frame = CGRectMake(_webView.frame.size.width-wkTopBar.frame.size.height+2, 2, kwkCloseBtnWidth, kwkCloseBtnHeight);
    wkCloseBtn.center = CGPointMake(wkCloseBtn.center.x, kStatusBarHeight*0.5);
    
    wkWebviewBounds = _webView.bounds;
    
    if (GrayNisStraightBangsDevice)
        wkCloseBtn.center = CGPointMake(wkCloseBtn.center.x-GrayNstraightBangsTopEdge*0.5, wkCloseBtn.center.y);
}
- (void)GrayNsetsetTopbarUp:(BOOL)status
    {
        wkTopBarUp = status;
        [self GrayNreshapeWebview];
    }
- (void)closeBtn
    {
        if (![[GrayN_BaseControl GrayN_Share] m_GrayN_Base_IsSaveUrl]) {
            [GrayN_WebViewController GrayN_WVC_SetIsOpenAllOrientation:NO];
            
            [[GrayN_BaseControl GrayN_Share] setM_GrayN_Base_IsSaveUrl:YES];
            [[GrayN_BaseControl GrayN_Share] GrayNcloseNewWebview];
        } else {
            [[GrayN_WebViewController GrayN_Share] GrayN_WVC_CloseJSBridgeViewIsForceClose:NO];
        }
    }
- (void)forwardBtn
    {
        [_webView goForward];
    }
- (void)backwardBtn
    {
        [_webView goBack];
    }
- (void)refreshBtn
    {
        [_webView reload];
    }
- (void)send:(id)data {
    [self send:data responseCallback:nil];
}

- (void)send:(id)data responseCallback:(WVJBResponseCallback)responseCallback {
    [_base sendData:data responseCallback:responseCallback handlerName:nil];
}

- (void)callHandler:(NSString *)handlerName {
    [self callHandler:handlerName data:nil responseCallback:nil];
}

- (void)callHandler:(NSString *)handlerName data:(id)data {
    [self callHandler:handlerName data:data responseCallback:nil];
}

- (void)callHandler:(NSString *)handlerName data:(id)data responseCallback:(WVJBResponseCallback)responseCallback {
    [_base sendData:data responseCallback:responseCallback handlerName:handlerName];
}

- (void)registerHandler:(NSString *)handlerName handler:(WVJBHandler)handler {
    _base.messageHandlers[handlerName] = [handler copy];
}

- (void)reset {
    [_base reset];
}

- (void)GrayNsetWebViewDelegate:(id<WKNavigationDelegate>)webViewDelegate {
    _webViewDelegate = webViewDelegate;
}

/* Internals
 ***********/

- (void)dealloc {
    _base = nil;
    _webView = nil;
    _webViewDelegate = nil;
    _webView.navigationDelegate = nil;
    [super dealloc];
}


/* WKWebView Specific Internals
 ******************************/

- (void) _setupInstance:(WKWebView*)webView
{
    _webView = webView;
    _webView.navigationDelegate = self;
    _base = [[GrayN_WebViewJavascriptBridgeBase alloc] init];
    _base.delegate = self;
}
- (void)WKFlushMessageQueue
{
    [_webView evaluateJavaScript:[_base webViewJavascriptFetchQueyCommand] completionHandler:^(NSString* result, NSError* error) {
        if (error != nil) {
            NSLog(@"WebViewJavascriptBridge: WARNING: Error when trying to fetch data from WKWebView: %@", error);
        }
        [_base flushMessageQueue:result];
    }];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    if (webView != _webView) { return; }
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"WebKitCacheModelPreferenceKey"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"WebKitDiskImageCacheEnabled"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"WebKitOfflineWebApplicationCacheEnabled"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [GrayNbaseSDK GrayNclose_Wait];

    [webView evaluateJavaScript:@"document.location.href" completionHandler:^(id _Nullable HTMLSource, NSError * _Nullable error) {
        GrayNcommon::GrayN_DebugLog(@"current-URL:%@", HTMLSource);
    }];
    
    if (wkTopBarUp) {
        [wkRefreshBtn setHidden:YES];
        [wkForwardBtn setHidden:YES];
        [wkBackwardBtn setHidden:YES];
        // 判断是否是2.0页面，不是就让页面滚动、添加关闭按钮
        [webView evaluateJavaScript:@"document.querySelector('meta[name=\"oppage-usetype\"]').getAttribute('content')" completionHandler:^(id _Nullable HTMLSource, NSError * _Nullable error) {
            GrayNcommon::GrayN_DebugLog(@"oppage-usetype:%@", HTMLSource);
            if ([HTMLSource isEqualToString:@"sdk2.0"]) {
                webView.frame = wkWebviewBounds;
                [wkCloseBtn setHidden:YES];
                [wkTopBar setHidden:YES];
                _webView.backgroundColor = GrayNclearColor;
                for (UIView * sub in webView.subviews) {
                    if ([sub isKindOfClass:[UIScrollView class]]) {
                        [(UIScrollView *)sub setScrollEnabled:NO];
                    }
                }
            } else {
                _webView.backgroundColor = GrayNblackColor;
                [wkCloseBtn setHidden:NO];
                [wkTopBar setHidden:NO];
                webView.frame = CGRectMake(0, kStatusBarHeight, wkWebviewBounds.size.width, wkWebviewBounds.size.height-kStatusBarHeight);
                
                for (UIView * sub in webView.subviews) {
                    if ([sub isKindOfClass:[UIScrollView class]]) {
                        [(UIScrollView *)sub setScrollEnabled:YES];
                    }
                }
            }
        }];
    } else {
        // 黑条在下方显示 有返回 前进 刷新按钮
        webView.frame = CGRectMake(0, 0, wkWebviewBounds.size.width, wkWebviewBounds.size.height);
        _webView.backgroundColor = GrayNblackColor;
        [wkRefreshBtn setHidden:!wkShowNavbar];
        [wkForwardBtn setHidden:!wkShowNavbar];
        [wkBackwardBtn setHidden:!wkShowNavbar];
        [wkCloseBtn setHidden:!wkShowNavbar];
        [wkTopBar setHidden:!wkShowNavbar];
        for (UIView * sub in webView.subviews) {
            if ([sub isKindOfClass:[UIScrollView class]]) {
                [(UIScrollView *)sub setScrollEnabled:YES];
            }
        }
    }
    __strong typeof(_webViewDelegate) strongDelegate = _webViewDelegate;
    if (strongDelegate && [strongDelegate respondsToSelector:@selector(webView:didFinishNavigation:)]) {
        [strongDelegate webView:webView didFinishNavigation:navigation];
    }
}
- (void)webView:(WKWebView *)webView
decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
//    [GrayNbaseSDK GrayNclose_Wait];

    if (webView != _webView) { return; }
    
    NSURL *url = navigationAction.request.URL;
    
    GrayNcommon::GrayN_DebugLog(@"the URL is: %@", [url absoluteString]);
    NSString *urlStr = [url absoluteString];
    
    // 判断是否包含打开字符串
    NSRange range = [urlStr rangeOfString:@"event=close"];
    if (range.location != NSNotFound) {
        [[GrayN_WebViewController GrayN_Share] GrayN_WVC_CloseJSBridgeViewIsForceClose:YES];
        return;
    }
    
    
    __strong typeof(_webViewDelegate) strongDelegate = _webViewDelegate;

    if ([_base isCorrectProcotocolScheme:url]) {
        if ([_base isBridgeLoadedURL:url]) {
            [_base injectJavascriptFile];
        } else if ([_base isQueueMessageURL:url]) {
            [self WKFlushMessageQueue];
        } else {
            [_base logUnkownMessage:url];
        }
//        decisionHandler(WKNavigationActionPolicyCancel);
    }
    
    if (strongDelegate && [strongDelegate respondsToSelector:@selector(webView:decidePolicyForNavigationAction:decisionHandler:)]) {
        [_webViewDelegate webView:webView decidePolicyForNavigationAction:navigationAction decisionHandler:decisionHandler];
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    if (webView != _webView) { return; }
    
    __strong typeof(_webViewDelegate) strongDelegate = _webViewDelegate;
    if (strongDelegate && [strongDelegate respondsToSelector:@selector(webView:didStartProvisionalNavigation:)]) {
        [strongDelegate webView:webView didStartProvisionalNavigation:navigation];
    }
}


- (void)webView:(WKWebView *)webView
didFailNavigation:(WKNavigation *)navigation
      withError:(NSError *)error
{
    if (webView != _webView) { return; }
    [GrayNbaseSDK GrayNclose_Wait];
    
    GrayNcommon::GrayN_DebugLog(@"%@",error);
    GrayNcommon::GrayN_DebugLog(@"***didFailLoadWithError***");
    if([error code] == NSURLErrorCancelled)
    {
        return;
    }
    [self performSelector:@selector(showErrorView) withObject:nil afterDelay:0];
    
    __strong typeof(_webViewDelegate) strongDelegate = _webViewDelegate;
    if (strongDelegate && [strongDelegate respondsToSelector:@selector(webView:didFailNavigation:withError:)]) {
        [strongDelegate webView:webView didFailNavigation:navigation withError:error];
    }
}
- (void)showErrorView
{
    // 显示错误界面的结果必然是关闭界面
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"OurSDK_res.bundle/Html/error.html"];
    NSURL* url = [NSURL fileURLWithPath:path];
    NSURLRequest* request = [NSURLRequest requestWithURL:url] ;
    [_webView loadRequest:request];
    GrayNcommon::GrayN_ConsoleLog(@"加载错误页面结束页面监控");
//    GrayN_Offical::GetInstance().GrayN_StopTimer();
    GrayN_Offical::GetInstance().m_GrayN_Offical_IsLogining = false;
    GrayNchannel::GetInstance().m_GrayN_IsLogining = false;
}
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    if (webView != _webView) { return; }
    
    __strong typeof(_webViewDelegate) strongDelegate = _webViewDelegate;
    if (strongDelegate && [strongDelegate respondsToSelector:@selector(webView:didFailProvisionalNavigation:withError:)]) {
        [strongDelegate webView:webView didFailProvisionalNavigation:navigation withError:error];
    }
}
- (NSString*)_evaluateJavascript:(NSString*)javascriptCommand
{
    [_webView evaluateJavaScript:javascriptCommand completionHandler:nil];
    return NULL;
}
@end
#endif
