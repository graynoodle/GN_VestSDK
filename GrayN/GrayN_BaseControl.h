//
//  OPControl.h
//
//  Created by op-mac1 on 14-3-14.
//  Copyright (c) 2014年 op-mac1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^m_GrayN_Hud_Callback)();
@interface GrayN_BaseControl : UIViewController<UIWebViewDelegate>

+ (id)GrayN_Share;
- (void)GrayN_SetGameWindow;
- (void)GrayN_InitSDK_Window;
- (void)GrayN_ShowSDK_Window;
- (void)GrayN_CloseSDK_Window;
- (UIWindow*)GrayN_GetSDK_Window;
- (UIWindow*)GrayN_GetGame_Window;
- (void)GrayN_AutoDownload:(NSString*)downloadUrl;
- (NSString *)GrayNgetLanString:(const char*)string;
- (float)GrayNreturnDisplayRatio;


- (void)GrayNshowToast:(NSString *)msg withCenter:(CGPoint)point ifCloseWindow:(BOOL)ifClose;
- (void)GrayNshowJSBridgeView:(NSString *)url;
- (void)GrayNshowLocalJSBridgeView:(NSString *)url;
- (void)GrayNcloseJSBridgeView;

- (void)GrayNshowHudWithTag:(int)tag withUserName:(NSString *)userName handler:(m_GrayN_Hud_Callback)handler;
- (void)GrayNcloseHud;
- (void)GrayNswitch_Account;

- (void)GrayNshowWelcome:(NSString *)string;

#pragma mark- UIOrientation
+ (BOOL)GrayN_Base_WindowIsLandScape;
+ (BOOL)GrayN_Base_WindowIsAutoOrientation;
+ (UIInterfaceOrientation)GrayN_Base_WindowInitOrientation;
+ (UIInterfaceOrientationMask)GrayN_Base_SupportedInterfaceOrientations;
// 适配不同iOS版本的界面坐标系
+ (CGRect)GrayN_Base_WindowRect;

/*5.1.4新添navbar*/
- (void)GrayNshowJSBridgeViewInNewWebview:(NSString *)url;
- (void)GrayNcloseNewWebview;

/*5.2.1*/
- (void)GrayNshowQRCodeView;
- (void)GrayNcloseQRCodeView;
@property (nonatomic, assign) BOOL m_GrayN_Base_IsSaveUrl;

@end
