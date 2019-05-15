//
//  GrayN_WebViewController.h
//  ExampleApp-iOS
//
//  Created by Marcus Westin on 1/13/14.
//  Copyright (c) 2014 Marcus Westin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GrayN_WebViewJavascriptBridge.h"
#import "GrayN_WKWebViewJavascriptBridge.h"

@interface GrayN_WebViewController : UINavigationController <WKNavigationDelegate>
+ (id)GrayN_Share;
+ (void)GrayN_WVC_SetJSBridgeNil;
+ (void)GrayN_WVC_SetIsOpenAllOrientation:(BOOL)status;

- (WKWebView *)GrayN_WVC_GetCurrentWebview;
- (void)GrayN_WVC_InitJSBridge;
- (void)GrayN_WVC_ShowJSBridgeView:(NSString *)url;
/*5.1.4*/
- (void)GrayN_WVC_ShowJSBridgeViewWithNavBar:(NSString *)url;

- (void)GrayN_WVC_ShowLocalBridgeView:(NSString *)url;

- (void)GrayN_WVC_CloseJSBridgeViewIsForceClose:(BOOL)status;

/*5.1.6*/
@property (nonatomic, retain)id bridge;


@end
