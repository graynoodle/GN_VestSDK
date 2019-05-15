//
//  GrayN_WKWebViewJavascriptBridge.h
//
//  Created by @LokiMeyburg on 10/15/14.
//  Copyright (c) 2014 @LokiMeyburg. All rights reserved.
//

#if (__MAC_OS_X_VERSION_MAX_ALLOWED > __MAC_10_9 || __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_1)
#define supportsWKWebKit
#endif

#if defined(supportsWKWebKit )

#import <Foundation/Foundation.h>
#import "GrayN_WebViewJavascriptBridgeBase.h"
#import <WebKit/WebKit.h>

@interface GrayN_WKWebViewJavascriptBridge : NSObject<WKNavigationDelegate, OPWebViewJavascriptBridgeBaseDelegate>

+ (instancetype)GrayNbridgeForWebView:(WKWebView*)webView;
+ (void)GrayNenableLogging;

- (void)registerHandler:(NSString*)handlerName handler:(WVJBHandler)handler;
- (void)callHandler:(NSString*)handlerName;
- (void)callHandler:(NSString*)handlerName data:(id)data;
- (void)callHandler:(NSString*)handlerName data:(id)data responseCallback:(WVJBResponseCallback)responseCallback;
- (void)reset;
- (void)GrayNsetWebViewDelegate:(id<WKNavigationDelegate>)webViewDelegate;

    
    @property (nonatomic, retain) NSURLRequest *jsBridgeRequest;
- (void)GrayNreshapeWebview;
- (void)GrayNsetShowNavbar:(BOOL)status;
- (void)GrayNsetsetTopbarUp:(BOOL)status;
@end

#endif
