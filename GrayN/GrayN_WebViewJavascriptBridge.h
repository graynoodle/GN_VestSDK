//
//  GrayN_WebViewJavascriptBridge.h
//  ExampleApp-iOS
//
//  Created by Marcus Westin on 6/14/13.
//  Copyright (c) 2013 Marcus Westin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GrayN_WebViewJavascriptBridgeBase.h"

#if defined __MAC_OS_X_VERSION_MAX_ALLOWED
    #import <WebKit/WebKit.h>
    #define WVJB_PLATFORM_OSX
    #define WVJB_WEBVIEW_TYPE WebView
    #define WVJB_WEBVIEW_DELEGATE_TYPE NSObject<OPWebViewJavascriptBridgeBaseDelegate>
    #define WVJB_WEBVIEW_DELEGATE_INTERFACE NSObject<OPWebViewJavascriptBridgeBaseDelegate, WebPolicyDelegate>
#elif defined __IPHONE_OS_VERSION_MAX_ALLOWED
    #import <UIKit/UIWebView.h>
    #define WVJB_PLATFORM_IOS
    #define WVJB_WEBVIEW_TYPE UIWebView
    #define WVJB_WEBVIEW_DELEGATE_TYPE NSObject<UIWebViewDelegate>
    #define WVJB_WEBVIEW_DELEGATE_INTERFACE NSObject<UIWebViewDelegate, OPWebViewJavascriptBridgeBaseDelegate>
#endif

@interface GrayN_WebViewJavascriptBridge : WVJB_WEBVIEW_DELEGATE_INTERFACE

+ (instancetype)GrayNbridgeForWebView:(WVJB_WEBVIEW_TYPE*)webView;
+ (void)GrayNenableLogging;
+ (void)GrayNsetLogMaxLength:(int)length;

- (void)registerHandler:(NSString*)handlerName handler:(WVJBHandler)handler;
- (void)callHandler:(NSString*)handlerName;
- (void)callHandler:(NSString*)handlerName data:(id)data;
- (void)callHandler:(NSString*)handlerName data:(id)data responseCallback:(WVJBResponseCallback)responseCallback;
- (void)GrayNsetWebViewDelegate:(WVJB_WEBVIEW_DELEGATE_TYPE*)webViewDelegate;

    
@property (nonatomic, retain) NSURLRequest *jsBridgeRequest;
- (void)GrayNreshapeWebview;
- (void)GrayNsetShowNavbar:(BOOL)status;
- (void)GrayNsetsetTopbarUp:(BOOL)status;
@end
