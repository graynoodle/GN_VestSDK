//
//  GrayN_WebViewJavascriptBridge.m
//  ExampleApp-iOS
//
//  Created by Marcus Westin on 6/14/13.
//  Copyright (c) 2013 Marcus Westin. All rights reserved.
//

#import "GrayN_WebViewJavascriptBridge.h"
#import <UIKit/UIKit.h>
#import "GrayN_WebViewController.h"
#import "GrayNbaseSDK.h"
#import "GrayN_BaseControl.h"
#import "GrayNcommon.h"
#import "GrayN_Offical.h"
#import "GrayNchannel.h"

#define GrayNgetStatusBarOrientation [UIApplication sharedApplication].statusBarOrientation
#define kStatusBarHeight 35
#define kCloseBtnWidth 28
#define kCloseBtnHeight 25
#define kBtnInterval 70

GrayNusing_NameSpace;

#if __has_feature(objc_arc_weak)
#define WVJB_WEAK __weak
#else
#define WVJB_WEAK __unsafe_unretained
#endif
UIButton *closeBtn;
UIButton *forwardBtn;
UIButton *backwardBtn;
UIButton *refreshBtn;
BOOL topBarUp;
BOOL showNavbar;
UIView *topBar;
CGRect webviewBounds;

@interface GrayN_WebViewJavascriptBridge ()<NSURLConnectionDelegate,NSURLConnectionDataDelegate>

{
    NSURLConnection *_urlConnection;
    BOOL _authenticated;
}
@end
@implementation GrayN_WebViewJavascriptBridge {
    WVJB_WEAK WVJB_WEBVIEW_TYPE* _webView;
    WVJB_WEAK id _webViewDelegate;
    long _uniqueId;
    GrayN_WebViewJavascriptBridgeBase *_base;
}
;
@synthesize jsBridgeRequest = _jsBridgeRequest;
/* API
 *****/

+ (void)GrayNenableLogging { [GrayN_WebViewJavascriptBridgeBase GrayNenableLogging]; }
+ (void)GrayNsetLogMaxLength:(int)length { [GrayN_WebViewJavascriptBridgeBase GrayNsetLogMaxLength:length]; }

+ (instancetype)GrayNbridgeForWebView:(WVJB_WEBVIEW_TYPE*)webView {
    GrayN_WebViewJavascriptBridge* bridge = [[self alloc] init];
    [bridge _platformSpecificSetup:webView];
    topBar = [[UIView alloc] init] ;
    
    topBar.backgroundColor = GrayNblackColor;
    [webView.superview addSubview:topBar];
//    [topBar release];
    closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"OurSDK_res.bundle/images/closeBtn.png"];
    UIImage *backImage = [UIImage imageWithContentsOfFile:path];
    [closeBtn setImage:backImage forState:UIControlStateNormal];

    topBar.frame = CGRectMake(0, 0, webView.frame.size.width, kStatusBarHeight);
    closeBtn.frame = CGRectMake(webView.frame.size.width-topBar.frame.size.height+2, 2, kCloseBtnWidth, kCloseBtnHeight);

    backwardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"OurSDK_res.bundle/images/backwardBtn.png"];
    backImage = [UIImage imageWithContentsOfFile:path];
    [backwardBtn setImage:backImage forState:UIControlStateNormal];

    forwardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"OurSDK_res.bundle/images/forwardBtn.png"];
    backImage = [UIImage imageWithContentsOfFile:path];
    [forwardBtn setImage:backImage forState:UIControlStateNormal];

    
    refreshBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"OurSDK_res.bundle/images/refreshBtn.png"];
    backImage = [UIImage imageWithContentsOfFile:path];
    [refreshBtn setImage:backImage forState:UIControlStateNormal];
    refreshBtn.frame = CGRectMake(10, 2, kCloseBtnWidth, kCloseBtnHeight);
    if (GrayNisStraightBangsDevice) {
        if ([GrayN_BaseControl GrayN_Base_WindowIsLandScape])
            closeBtn.center = CGPointMake(closeBtn.center.x-GrayNstraightBangsTopEdge*1.5, closeBtn.center.y);
        else
            closeBtn.center = CGPointMake(closeBtn.center.x-GrayNstraightBangsTopEdge*0.8, closeBtn.center.y*1.5);

        refreshBtn.center = CGPointMake(refreshBtn.center.x+GrayNstraightBangsTopEdge, refreshBtn.center.y);
    } else {
        closeBtn.center = CGPointMake(closeBtn.center.x, kStatusBarHeight*0.5);
    }
    backwardBtn.frame = CGRectMake(refreshBtn.frame.origin.x+1.5*kBtnInterval, 2, kCloseBtnWidth, kCloseBtnHeight);
    forwardBtn.frame = CGRectMake(backwardBtn.frame.origin.x+kBtnInterval, 2, kCloseBtnWidth, kCloseBtnHeight);

    refreshBtn.center = CGPointMake(refreshBtn.center.x, kStatusBarHeight*0.5);
    forwardBtn.center = CGPointMake(forwardBtn.center.x, kStatusBarHeight*0.5);
    backwardBtn.center = CGPointMake(backwardBtn.center.x, kStatusBarHeight*0.5);

    [closeBtn addTarget:bridge action:@selector(closeBtn) forControlEvents:UIControlEventTouchUpInside];
    [refreshBtn addTarget:bridge action:@selector(refreshBtn) forControlEvents:UIControlEventTouchUpInside];
    [forwardBtn addTarget:bridge action:@selector(forwardBtn) forControlEvents:UIControlEventTouchUpInside];
    [backwardBtn addTarget:bridge action:@selector(backwardBtn) forControlEvents:UIControlEventTouchUpInside];

    [topBar addSubview:closeBtn];
    [topBar addSubview:refreshBtn];
    [topBar addSubview:forwardBtn];
    [topBar addSubview:backwardBtn];

//    for (UIView * sub in webView.subviews) {
//        sub.backgroundColor = [UIColor clearColor];
//        if ([sub isKindOfClass:[UIScrollView class]]) {
//            [sub addSubview:closeBtn];
//        }
//    }
    [topBar setHidden:YES];
    [closeBtn setHidden:YES];
    [refreshBtn setHidden:YES];
    [forwardBtn setHidden:YES];
    [backwardBtn setHidden:YES];
    topBarUp = YES;
    webviewBounds = [GrayN_BaseControl GrayN_Base_WindowRect];
    
    return bridge;
}
- (void)GrayNsetShowNavbar:(BOOL)status
{
    showNavbar = status;
}
- (void)GrayNreshapeWebview
{
    GrayNcommon::GrayN_DebugLog(@"opReshapeWebview showNavbar:%d", showNavbar);
    float width = MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    float height = MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    
    if (GrayNgetStatusBarOrientation == UIInterfaceOrientationLandscapeLeft ||
        GrayNgetStatusBarOrientation == UIInterfaceOrientationLandscapeRight) {
        _webView.frame = CGRectMake(0, 0, width, height-kStatusBarHeight);
        
    } else {
        _webView.frame = CGRectMake(0, 0, height, width-kStatusBarHeight);
    }

    if (!showNavbar) {
        if (GrayNgetStatusBarOrientation == UIInterfaceOrientationLandscapeLeft ||
            GrayNgetStatusBarOrientation == UIInterfaceOrientationLandscapeRight) {
            _webView.frame = CGRectMake(0, 0, width, height);
        } else {
            _webView.frame = CGRectMake(0, 0, height, width);
            
        }
        [topBar setHidden:YES];
        [refreshBtn setHidden:YES];
        [forwardBtn setHidden:YES];
        [backwardBtn setHidden:YES];
        [closeBtn setHidden:YES];
        webviewBounds = _webView.bounds;

        return;
    }
    [topBar setHidden:NO];
    [refreshBtn setHidden:NO];
    [forwardBtn setHidden:NO];
    [backwardBtn setHidden:NO];
    [closeBtn setHidden:NO];
    
    if (GrayNisStraightBangsDevice) {
        _webView.frame = CGRectMake(0, 0, _webView.frame.size.width, _webView.frame.size.height-GrayNstraightBangsTopEdge*0.6);
        topBar.frame = CGRectMake(0, _webView.frame.size.height, _webView.frame.size.width, kStatusBarHeight+GrayNstraightBangsTopEdge*0.6);
    } else
        topBar.frame = CGRectMake(0, _webView.frame.size.height, _webView.frame.size.width, kStatusBarHeight);

    closeBtn.frame = CGRectMake(_webView.frame.size.width-topBar.frame.size.height+2, 2, kCloseBtnWidth, kCloseBtnHeight);
    closeBtn.center = CGPointMake(closeBtn.center.x, kStatusBarHeight*0.5);
    
    webviewBounds = _webView.bounds;
    
    if (GrayNisStraightBangsDevice) 
        closeBtn.center = CGPointMake(closeBtn.center.x-GrayNstraightBangsTopEdge*0.5, closeBtn.center.y);
}
- (void)GrayNsetsetTopbarUp:(BOOL)status
{
    topBarUp = status;
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
- (void)GrayNsetWebViewDelegate:(WVJB_WEBVIEW_DELEGATE_TYPE*)webViewDelegate {
    _webViewDelegate = webViewDelegate;
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

/* Platform agnostic internals
 *****************************/

- (void)dealloc
{
    [self _platformSpecificDealloc];
    [_base release];
    _base = nil;
    [_webView release];
    [_webView stopLoading];
    _webView = nil;
    [_webViewDelegate release];
    _webViewDelegate = nil;
    [_jsBridgeRequest release];
    _jsBridgeRequest = nil;
    [super dealloc];
}

- (NSString*) _evaluateJavascript:(NSString*)javascriptCommand
{
    return [_webView stringByEvaluatingJavaScriptFromString:javascriptCommand];
}

/* Platform specific internals: OSX
 **********************************/
#if defined WVJB_PLATFORM_OSX

- (void) _platformSpecificSetup:(WVJB_WEBVIEW_TYPE*)webView {
    _webView = webView;
    
    _webView.policyDelegate = self;
    
    _base = [[GrayN_WebViewJavascriptBridgeBase alloc] init];
    _base.delegate = self;
}

- (void)_platformSpecificDealloc {
    _webView.policyDelegate = nil;
}

- (void)webView:(WebView *)webView decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id<WebPolicyDecisionListener>)listener
{
    if (webView != _webView) { return; }
    
    
    NSURL *url = [request URL];
    if ([_base isCorrectProcotocolScheme:url]) {
        if ([_base isBridgeLoadedURL:url]) {
            [_base injectJavascriptFile];
        } else if ([_base isQueueMessageURL:url]) {
            NSString *messageQueueString = [self _evaluateJavascript:[_base webViewJavascriptFetchQueyCommand]];
            [_base flushMessageQueue:messageQueueString];
        } else {
            [_base logUnkownMessage:url];
        }
        [listener ignore];
    } else if (_webViewDelegate && [_webViewDelegate respondsToSelector:@selector(webView:decidePolicyForNavigationAction:request:frame:decisionListener:)]) {
        [_webViewDelegate webView:webView decidePolicyForNavigationAction:actionInformation request:request frame:frame decisionListener:listener];
    } else {
        [listener use];
    }
}



/* Platform specific internals: iOS
 **********************************/
#elif defined WVJB_PLATFORM_IOS

- (void) _platformSpecificSetup:(WVJB_WEBVIEW_TYPE*)webView {
    _webView = webView;
    _webView.delegate = self;
    _base = [[GrayN_WebViewJavascriptBridgeBase alloc] init];
    _base.delegate = self;

}

- (void) _platformSpecificDealloc {
    _webView.delegate = nil;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"WebKitCacheModelPreferenceKey"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"WebKitDiskImageCacheEnabled"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"WebKitOfflineWebApplicationCacheEnabled"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (webView != _webView) { return; }
    [GrayNbaseSDK GrayNclose_Wait];
//        GrayNcommon::GrayN_DebugLog(@"%@", [webView stringByEvaluatingJavaScriptFromString:@"document.querySelector('meta[name=\"oppage-usetype\"]').getAttribute('content')"]);
//    NSLog(@"加载完毕%@  \n当前webView=%@", webView, [[GrayN_WebViewController GrayN_Share] GrayN_WVC_GetCurrentWebview]);

    NSString *currentURL = [webView stringByEvaluatingJavaScriptFromString:@"document.location.href"];
    GrayNcommon::GrayN_DebugLog(@"current-URL:%@", currentURL);
    
    
    if (topBarUp) {
        [refreshBtn setHidden:YES];
        [forwardBtn setHidden:YES];
        [backwardBtn setHidden:YES];
        // 判断是否是2.0页面，不是就让页面滚动、添加关闭按钮
        NSString *oppage_usetype = [webView stringByEvaluatingJavaScriptFromString:@"document.querySelector('meta[name=\"oppage-usetype\"]').getAttribute('content')"];
        //    if (bounds.size.height > bounds.size.width) {
        //        float tmp;
        //        tmp = bounds.size.width;
        //        bounds.size.width = bounds.size.height;
        //        bounds.size.height = tmp;
        //    }
        GrayNcommon::GrayN_DebugLog(@"oppage-usetype:%@", oppage_usetype);
        if ([oppage_usetype isEqualToString:@"sdk2.0"]) {
            webView.frame = webviewBounds;
            [closeBtn setHidden:YES];
            [topBar setHidden:YES];
            _webView.backgroundColor = GrayNclearColor;
            for (UIView * sub in webView.subviews) {
                if ([sub isKindOfClass:[UIScrollView class]]) {
                    [(UIScrollView *)sub setScrollEnabled:NO];
                }
            }
        } else {
            _webView.backgroundColor = GrayNblackColor;
            [closeBtn setHidden:NO];
            [topBar setHidden:NO];
            webView.frame = CGRectMake(0, kStatusBarHeight, webviewBounds.size.width, webviewBounds.size.height-kStatusBarHeight);

            for (UIView * sub in webView.subviews) {
                if ([sub isKindOfClass:[UIScrollView class]]) {
                    [(UIScrollView *)sub setScrollEnabled:YES];
                }
            }
        }
    } else {
        // 黑条在下方显示 有返回 前进 刷新按钮
        webView.frame = CGRectMake(0, 0, webviewBounds.size.width, webviewBounds.size.height);
        _webView.backgroundColor = GrayNblackColor;
        [refreshBtn setHidden:!showNavbar];
        [forwardBtn setHidden:!showNavbar];
        [backwardBtn setHidden:!showNavbar];
        [closeBtn setHidden:!showNavbar];
        [topBar setHidden:!showNavbar];
        for (UIView * sub in webView.subviews) {
            if ([sub isKindOfClass:[UIScrollView class]]) {
                [(UIScrollView *)sub setScrollEnabled:YES];
            }
        }
//        NSString *jsMeta = [NSString stringWithFormat:@"var meta = document.createElement('meta');meta.content='width=device-width,initial-scale=1.0,minimum-scale=.5,maximum-scale=3';meta.name='viewport';document.getElementsByTagName('head')[0].appendChild(meta);"];
//        [_webView stringByEvaluatingJavaScriptFromString:jsMeta];
        
    }
    
    __strong WVJB_WEBVIEW_DELEGATE_TYPE* strongDelegate = _webViewDelegate;
    if (strongDelegate && [strongDelegate respondsToSelector:@selector(webViewDidFinishLoad:)]) {
        [strongDelegate webViewDidFinishLoad:webView];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if (webView != _webView) { return; }
    [GrayNbaseSDK GrayNclose_Wait];

    GrayNcommon::GrayN_DebugLog(@"%@",error);
    GrayNcommon::GrayN_DebugLog(@"***didFailLoadWithError***");
    if([error code] == NSURLErrorCancelled)
    {
        return;
    }
    [self performSelector:@selector(showErrorView) withObject:nil afterDelay:0];
    
    __strong WVJB_WEBVIEW_DELEGATE_TYPE* strongDelegate = _webViewDelegate;
    if (strongDelegate && [strongDelegate respondsToSelector:@selector(webView:didFailLoadWithError:)]) {
        [strongDelegate webView:webView didFailLoadWithError:error];
    }
    
}
- (void)showErrorView
{
    //显示错误界面的结果必然是关闭界面
    
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"OurSDK_res.bundle/Html/error.html"];
    NSURL* url = [NSURL fileURLWithPath:path];
    NSURLRequest* request = [NSURLRequest requestWithURL:url] ;
    [_webView loadRequest:request];
    GrayNcommon::GrayN_ConsoleLog(@"加载错误页面结束页面监控");
//    GrayN_Offical::GetInstance().GrayN_StopTimer();
    GrayN_Offical::GetInstance().m_GrayN_Offical_IsLogining = false;
    GrayNchannel::GetInstance().m_GrayN_IsLogining = false;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    [GrayNbaseSDK GrayNclose_Wait];

    if (webView != _webView) { return YES; }
    GrayNcommon::GrayN_DebugLog(@"the URL is: %@", [[request URL]absoluteString]);
    //    if (!_authenticated) {
//        _authenticated = NO;
//        _urlConnection = [[NSURLConnection alloc] initWithRequest:_jsBridgeRequest delegate:self];
//        [_urlConnection start];
//        return NO;
//    }
    
    NSURL *url = [request URL];
//    GrayNcommon::GrayN_DebugLog(@"url-----%@", url);
    NSString *urlStr = request.URL.absoluteString;
    
    // 判断是否包含打开字符串
    NSRange range = [urlStr rangeOfString:@"event=close"];
    if (range.location != NSNotFound) {
        [[GrayN_WebViewController GrayN_Share] GrayN_WVC_CloseJSBridgeViewIsForceClose:YES];
        return NO;
    }

    __strong WVJB_WEBVIEW_DELEGATE_TYPE* strongDelegate = _webViewDelegate;
    if ([_base isCorrectProcotocolScheme:url]) {
        if ([_base isBridgeLoadedURL:url]) {
            [_base injectJavascriptFile];
        } else if ([_base isQueueMessageURL:url]) {
            NSString *messageQueueString = [self _evaluateJavascript:[_base webViewJavascriptFetchQueyCommand]];
            [_base flushMessageQueue:messageQueueString];
        } else {
            [_base logUnkownMessage:url];
        }
        return NO;
    } else if (strongDelegate && [strongDelegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)]) {
        return [strongDelegate webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    } else {
        return YES;
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    if (webView != _webView) { return; }
    
    __strong WVJB_WEBVIEW_DELEGATE_TYPE* strongDelegate = _webViewDelegate;
    if (strongDelegate && [strongDelegate respondsToSelector:@selector(webViewDidStartLoad:)]) {
        [strongDelegate webViewDidStartLoad:webView];
    }
}
#pragma mark - URLConnectionDelegate
- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
        //if ([trustedHosts containsObject:challenge.protectionSpace.host])
        [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]
             forAuthenticationChallenge:challenge];
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}
//- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
//{
//    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
//}
//
//- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
//{
//    GrayNcommon::GrayN_DebugLog(@"验证签名证书");
//    
//    if ([challenge previousFailureCount] == 0)
//    {
//        _authenticated = YES;
//        
//        NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
//        
//        [challenge.sender useCredential:credential forAuthenticationChallenge:challenge];
//        
//    } else
//    {
//        [[challenge sender] cancelAuthenticationChallenge:challenge];
//    }
//}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [GrayNbaseSDK GrayNclose_Wait];

    GrayNcommon::GrayN_DebugLog(@"WebController received response via NSURLConnection");
    // remake a webview call now that authentication has passed ok.
    
    _authenticated = YES;
    [_webView loadRequest:_jsBridgeRequest];
    
    // Cancel the URL connection otherwise we double up (webview + url connection, same url = no good!)
    [_urlConnection cancel];
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [GrayNbaseSDK GrayNclose_Wait];
    [[GrayN_WebViewController GrayN_Share] GrayN_WVC_CloseJSBridgeViewIsForceClose:YES];
    GrayNcommon::GrayN_DebugLog(@"%@",error);
    GrayNcommon::GrayN_DebugLog(@"didFailWithError");
}
#endif

@end
//@interface NSURLRequest (IgnoreSSL)
//+(BOOL)allowsAnyHTTPSCertificateForHost:(NSString*)host;
//@end
//@implementation NSURLRequest (IgnoreSSL)
//+(BOOL)allowsAnyHTTPSCertificateForHost:(NSString*)host {return YES;}
//@end
