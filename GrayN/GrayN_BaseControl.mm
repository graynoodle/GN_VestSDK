//
//  OPControl.m
//
//  Created by op-mac1 on 14-3-14.
//  Copyright (c) 2014年 op-mac1. All rights reserved.
//

#import "GrayN_BaseControl.h"
#import "GrayNchannelSDK.h"
#import "GrayNbaseSDK.h"
#import "GrayN_UserCenter.h"
#import "GrayN_Base64_GrayN.h"
#import "GrayN_Offical.h"
#import "GrayN_Toast.h"
#import "GrayN_Hud.h"
#import "GrayNconfig.h"

#import "GrayN_WebViewController.h"
#import "GrayNcustomService_Control.h"
#import "GrayNcommon.h"
#import "GrayNinit.h"
#import "GrayN_DebugView.h"
//#import <AssetsLibrary/AssetsLibrary.h>
/*5.2.1*/
#import "GrayN_QRCodeConfirm.h"

GrayNusing_NameSpace;

static GrayN_BaseControl * p_GrayN_Base_share;
static UIWebView *p_GrayN_Base_AutoDownloadView;
static UIInterfaceOrientation p_GrayN_Base_InitOrientation;
static BOOL p_GrayN_Base_IsShowSDK_Window;
static UIWindow *p_GrayN_Base_GameWindow;
static BOOL p_GrayN_Base_IsLandScape;
static CGRect p_GrayN_Base_WindowRect;

@interface GrayN_BaseControl ()
{
    UIWindow            *p_GrayN_Base_SDKWindow;
    GrayN_Toast          *p_GrayN_Base_Toast;
    GrayN_Hud           *p_GrayN_Base_Hud;
    UIViewController     *p_GrayN_Base_Rvc;

    float                p_GrayN_Base_Screen_Ratio;
    GrayN_WebViewController *p_GrayN_Base_NewJSBV;
    
    /*5.2.1*/
    GrayN_QRCodeConfirm *p_GrayN_Base_QR_View;
}
@end

@implementation GrayN_BaseControl
- (void)dealloc
{
    GrayNreleaseSafe(p_GrayN_Base_Hud);
    [super dealloc];
}
+ (BOOL)GrayN_Base_WindowIsLandScape
{
    return p_GrayN_Base_IsLandScape;
}
+ (BOOL)GrayN_Base_WindowIsAutoOrientation
{
    return GrayNcommon::m_GrayN_ScreenIsAutoRotation;
}
+ (UIInterfaceOrientation)GrayN_Base_WindowInitOrientation
{
    return p_GrayN_Base_InitOrientation;
}
+ (CGRect)GrayN_Base_WindowRect
{
    return p_GrayN_Base_WindowRect;
}

+ (id)GrayN_Share
{
    @synchronized ([GrayN_BaseControl class]) {
        if (p_GrayN_Base_share == nil) {
            p_GrayN_Base_InitOrientation = (UIInterfaceOrientation)GrayNcommon::m_GrayN_InitOrientation;
            if (p_GrayN_Base_InitOrientation == UIInterfaceOrientationLandscapeRight ||
                p_GrayN_Base_InitOrientation == UIInterfaceOrientationLandscapeLeft ) {
                p_GrayN_Base_IsLandScape = true;
                GrayNcommon::m_GrayN_Screen_Orientation = "landscape";
                
            } else {
                p_GrayN_Base_IsLandScape = false;
                GrayNcommon::m_GrayN_Screen_Orientation = "portrait";
            }
            
            if (GrayNcommon::m_GrayN_ScreenIsAutoRotation) {
                GrayNcommon::GrayN_ConsoleLog(@"opAutoRotation Yes");
            } else {
                GrayNcommon::GrayN_ConsoleLog(@"opAutoRotation No");
            }
            
            p_GrayN_Base_share = [[GrayN_BaseControl alloc] init];
            [p_GrayN_Base_share GrayN_InitSDK_Window];
            p_GrayN_Base_IsShowSDK_Window = NO;        //注意该变量
            [GrayNcustomService_Control GrayNshare];
    

//            if (p_GrayN_Base_GameWindow == nil) {
//                p_GrayN_Base_GameWindow = [[UIApplication sharedApplication] keyWindow];
//                NSLog(@"initGameWindow=%@",p_GrayN_Base_GameWindow);
//            }
            if (p_GrayN_Base_AutoDownloadView == nil) {
                p_GrayN_Base_AutoDownloadView = [[UIWebView alloc] init];
            }
            p_GrayN_Base_share.m_GrayN_Base_IsSaveUrl = YES;
        }
    }
    return p_GrayN_Base_share;
}
- (void)GrayN_SetGameWindow
{
    if (p_GrayN_Base_GameWindow == nil) {
        p_GrayN_Base_GameWindow = [[UIApplication sharedApplication] keyWindow];
    }
}
- (void)GrayN_InitSDK_Window;
{
    if (p_GrayN_Base_SDKWindow == nil) {
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            p_GrayN_Base_Screen_Ratio = 1.00f;
        } else {
            p_GrayN_Base_Screen_Ratio = 0.58f;
        }
        p_GrayN_Base_WindowRect = [UIScreen mainScreen].bounds;
        p_GrayN_Base_SDKWindow = [[UIWindow alloc] initWithFrame:p_GrayN_Base_WindowRect];
        
        if (p_GrayN_Base_IsLandScape) {
            // landscape
            p_GrayN_Base_WindowRect = CGRectMake(0, 0, MAX(p_GrayN_Base_WindowRect.size.width, p_GrayN_Base_WindowRect.size.height), MIN(p_GrayN_Base_WindowRect.size.width, p_GrayN_Base_WindowRect.size.height));
        } else {
            p_GrayN_Base_WindowRect = CGRectMake(0, 0, MIN(p_GrayN_Base_WindowRect.size.width, p_GrayN_Base_WindowRect.size.height), MAX(p_GrayN_Base_WindowRect.size.width, p_GrayN_Base_WindowRect.size.height));
        }
        
        p_GrayN_Base_SDKWindow.rootViewController = self;
        p_GrayN_Base_SDKWindow.rootViewController.view.frame = p_GrayN_Base_WindowRect;
        // 非常重要
        [p_GrayN_Base_SDKWindow setBackgroundColor:GrayNclearColor];
    }
}
- (void)GrayN_ShowSDK_Window
{
    GrayNcommon::GrayN_DebugLog(@"p_GrayN_Base_SDKWindow: Open.");
    if (p_GrayN_Base_SDKWindow == nil) {
        [self GrayN_InitSDK_Window];
    }
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
        p_GrayN_Base_SDKWindow.windowLevel = UIWindowLevelNormal;
    } else {
        p_GrayN_Base_SDKWindow.windowLevel = UIWindowLevelAlert;
    }
    if (p_GrayN_Base_IsShowSDK_Window == NO) {
        p_GrayN_Base_IsShowSDK_Window = YES;
        [p_GrayN_Base_SDKWindow makeKeyAndVisible];
    }
}
- (void)GrayN_CloseSDK_Window
{
    if (p_GrayN_Base_Toast.m_GrayN_Toast_IsClose && p_GrayN_Base_Toast.m_GrayN_Toast_IsProcessing) {
        GrayNcommon::GrayN_ConsoleLog(@"opToast: Still show.");
        return;
    }
    GrayNcommon::GrayN_DebugLog(@"p_GrayN_Base_SDKWindow: Close.");
    if (p_GrayN_Base_IsShowSDK_Window == YES) {
        p_GrayN_Base_IsShowSDK_Window = NO;
        [p_GrayN_Base_SDKWindow setHidden:YES];
        // 由于与海马的机制有冲突，去掉这句，这个对其他SDK应该没有影响
//        p_GrayN_Base_SDKWindow.windowLevel = UIWindowLevelNormal;
    }
    if (p_GrayN_Base_GameWindow) {
        [p_GrayN_Base_GameWindow makeKeyAndVisible];
    }
//    NSLog(@"p_GrayN_Base_GameWindow=%@", p_GrayN_Base_GameWindow);

    /*5.2.0 调试页面*/
    GrayN_DebugView *optv = GrayNcommon::GrayNgetDebugView();
    if (optv != nil && p_GrayN_Base_GameWindow != nil && GrayNcommon::m_GrayNforceDebug_Mode) {
        [optv GrayN_DebugView_SetFrame:CGRectMake(0, 0, p_GrayN_Base_Rvc.view.frame.size.width, p_GrayN_Base_Rvc.view.frame.size.height)];
        [[GrayNbaseSDK GrayNgetGame_Window] addSubview:optv];
    }
    /*5.2.0*/
}
- (UIWindow*)GrayN_GetSDK_Window
{
    return p_GrayN_Base_SDKWindow;
}

- (UIWindow*)GrayN_GetGame_Window
{
    return p_GrayN_Base_GameWindow;
}
- (float)GrayNreturnDisplayRatio
{
    return p_GrayN_Base_Screen_Ratio;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if(GrayNcommon::m_GrayN_ScreenIsAutoRotation){
        if (UIInterfaceOrientationIsLandscape(p_GrayN_Base_InitOrientation)) {
            return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
        }else{
            return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
        }
    } else {
        if (p_GrayN_Base_InitOrientation == toInterfaceOrientation) {
            return YES;
        } else {
            return NO;
        }
    }
}

- (BOOL)shouldAutorotate
{
    return GrayNcommon::m_GrayN_ScreenIsAutoRotation;
}
+ (UIInterfaceOrientationMask)GrayN_Base_SupportedInterfaceOrientations
{
    if(GrayNcommon::m_GrayN_ScreenIsAutoRotation) {
        if (UIInterfaceOrientationIsLandscape(p_GrayN_Base_InitOrientation)) {
            return UIInterfaceOrientationMaskLandscape;
        } else {
            return UIInterfaceOrientationMaskPortrait;
        }
    } else {
        if (p_GrayN_Base_InitOrientation == UIInterfaceOrientationPortrait) {
            return UIInterfaceOrientationMaskPortrait;
        } else if (p_GrayN_Base_InitOrientation == UIInterfaceOrientationPortraitUpsideDown) {
            return UIInterfaceOrientationMaskPortraitUpsideDown;
        } else if (p_GrayN_Base_InitOrientation == UIInterfaceOrientationLandscapeLeft) {
            return UIInterfaceOrientationMaskLandscapeLeft;
        } else {
            return UIInterfaceOrientationMaskLandscapeRight;
        }
    }
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return [GrayN_BaseControl GrayN_Base_SupportedInterfaceOrientations];
}

- (void)GrayN_AutoDownload:(NSString*)downloadUrl
{
    NSURLCache * cache = [NSURLCache sharedURLCache];
    [cache removeAllCachedResponses];
    [cache setDiskCapacity:0];
    [cache setMemoryCapacity:0];
    
    NSString *encodedString=[downloadUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];       //必须的
    NSURL* AD_URL = [NSURL URLWithString:encodedString];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:AD_URL];
    
    // 设置header信息
    NSMutableDictionary *dicHeader = [[[NSMutableDictionary alloc] init] autorelease];
    [dicHeader setValue:[NSString stringWithUTF8String:GrayNcommon::m_GrayN_Oua.c_str()] forKey:@"oUa"];
    [dicHeader setValue:[NSString stringWithUTF8String:GrayNcommon::m_GrayN_AllVersion.c_str()] forKey:@"version"];
    [dicHeader setValue:[NSString stringWithUTF8String:GrayNcommon::m_GrayN_ServiceId.c_str()] forKey:@"oService"];
    [dicHeader setValue:[NSString stringWithUTF8String:GrayNcommon::m_GrayN_ChannelId.c_str()] forKey:@"oChannel"];
    [dicHeader setValue:[NSString stringWithUTF8String:GrayNcommon::m_GrayN_DeviceInfo.c_str()] forKey:@"device"];
    [dicHeader setValue:[NSString stringWithUTF8String:GrayNcommon::m_GrayN_DeviceGroupId.c_str()] forKey:@"deviceGroupId"];
    [dicHeader setValue:[NSString stringWithUTF8String:GrayNcommon::m_GrayN_LocaleId.c_str()] forKey:@"localeId"];
    
    [request setHTTPMethod:@"GET"];
    // 非常重要
    [request setAllHTTPHeaderFields:dicHeader];
    
    [p_GrayN_Base_AutoDownloadView setDelegate:[GrayN_BaseControl GrayN_Share]];
    [p_GrayN_Base_AutoDownloadView loadRequest:request];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    GrayN_LoadingUI::GetInstance().GrayN_ShowWait(GrayNcommon::GrayNcommonGetLocalLang(GrayN_UpdateString));
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    GrayN_LoadingUI::GetInstance().GrayN_CloseWaitMainThread();
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    GrayN_LoadingUI::GetInstance().GrayN_CloseWaitMainThread();
    
    if([error code] == NSURLErrorCancelled) {
        return;
    }
    if (error.code == 102 && [error.domain isEqual:@"WebKitErrorDomain"]) {
        return;
    }
    NSLog(@"%@",error);
    NSString *message = [NSString stringWithUTF8String:GrayNcommon::GrayNcommonGetLocalLang(GrayN_UpdateFailed)];
    NSString *sure = [NSString stringWithUTF8String:GrayNcommon::GrayNcommonGetLocalLang(GrayN_Sure)];
    UIAlertView*alert = [[UIAlertView alloc]initWithTitle:nil
                                                  message:message
                                                 delegate:nil
                                        cancelButtonTitle:nil
                                        otherButtonTitles:sure,nil];
    [alert show];
    [alert release];
    
}
#pragma mark - 获取对应语言字符串
- (NSString *)GrayNgetLanString:(const char *)string
{
    return [NSString stringWithUTF8String:GrayNcommon::GrayNcommonGetLocalLang(string)];
}



#pragma mark 提示框
/* 顯示提示框 */
- (void)GrayNshowToast:(NSString *)msg withCenter:(CGPoint)point ifCloseWindow:(BOOL)ifClose
{
    dispatch_async(dispatch_get_main_queue(), ^{
//        NSLog(@"%f %f", point.x,point.y );
        if (ifClose) {
            [self GrayN_ShowSDK_Window];
        }
        [self.view setHidden:NO];
        static BOOL isInit = NO;
        if (!isInit) {
            p_GrayN_Base_Toast = [[GrayN_Toast alloc] init];
            isInit = YES;
        }
        p_GrayN_Base_Toast.center = point;
        
        p_GrayN_Base_Toast.m_GrayN_Toast_IsClose = ifClose;
        [p_GrayN_Base_Toast GrayN_Toast_ShowWithMsg:msg];
        [p_GrayN_Base_SDKWindow.rootViewController.view addSubview:p_GrayN_Base_Toast];
    });
}

- (void)GrayNshowJSBridgeView:(NSString *)url
{
    [self GrayN_ShowSDK_Window];
//    GrayNchannel::GetInstance().IsAllowShowToolBar(NO);
    p_GrayN_Base_Rvc = p_GrayN_Base_SDKWindow.rootViewController;

    GrayN_WebViewController *UIWebViewExampleController = [GrayN_WebViewController  GrayN_Share];

    p_GrayN_Base_SDKWindow.rootViewController = UIWebViewExampleController;
    // 不设置iOS8会适配出错
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        p_GrayN_Base_SDKWindow.rootViewController.view.frame = p_GrayN_Base_WindowRect;
    }
    [[GrayN_WebViewController GrayN_Share] GrayN_WVC_ShowJSBridgeView:url];
    
    
    GrayN_DebugView *optv = GrayNcommon::GrayNgetDebugView();
    if (optv != nil && p_GrayN_Base_SDKWindow != nil && GrayNcommon::m_GrayNforceDebug_Mode) {
        [optv GrayN_DebugView_SetFrame:CGRectMake(0, 0, p_GrayN_Base_Rvc.view.frame.size.width, p_GrayN_Base_Rvc.view.frame.size.height)];
        [p_GrayN_Base_SDKWindow addSubview:optv];
    }

}
- (void)GrayNshowJSBridgeViewInNewWebview:(NSString *)url
{

    p_GrayN_Base_NewJSBV = [[GrayN_WebViewController alloc] init];
    p_GrayN_Base_SDKWindow.rootViewController = p_GrayN_Base_NewJSBV;
    // 不设置iOS8会适配出错
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        p_GrayN_Base_SDKWindow.rootViewController.view.frame = p_GrayN_Base_WindowRect;
    }
    [p_GrayN_Base_NewJSBV GrayN_WVC_ShowJSBridgeView:url];
    WKWebView *w = [p_GrayN_Base_NewJSBV GrayN_WVC_GetCurrentWebview];
    w.backgroundColor = GrayNblackColor;
}
- (void)GrayNcloseNewWebview
{
    if (p_GrayN_Base_NewJSBV) {
        WKWebView *w = [p_GrayN_Base_NewJSBV GrayN_WVC_GetCurrentWebview];
        [w stopLoading];
        // 很重要必须将代理制空，否则还会加载释放前页面的代理
//        w.delegate = nil;
        [w release];
        w = nil;
        GrayNreleaseSafe(p_GrayN_Base_NewJSBV);
    }
    GrayN_WebViewController *UIWebViewExampleController = [GrayN_WebViewController  GrayN_Share];
    p_GrayN_Base_SDKWindow.rootViewController = UIWebViewExampleController;
    // 不设置iOS8会适配出错
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        p_GrayN_Base_SDKWindow.rootViewController.view.frame = p_GrayN_Base_WindowRect;
    }
}

- (void)GrayNshowLocalJSBridgeView:(NSString *)url
{
    [self GrayN_ShowSDK_Window];
//    GrayNchannel::GetInstance().IsAllowShowToolBar(NO);
    p_GrayN_Base_Rvc = p_GrayN_Base_SDKWindow.rootViewController;

    GrayN_WebViewController *UIWebViewExampleController = [GrayN_WebViewController  GrayN_Share];
    p_GrayN_Base_SDKWindow.rootViewController = UIWebViewExampleController;
    // 不设置iOS8会适配出错
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        p_GrayN_Base_SDKWindow.rootViewController.view.frame = p_GrayN_Base_WindowRect;
    }
    [[GrayN_WebViewController GrayN_Share] GrayN_WVC_ShowLocalBridgeView:url];
    GrayN_DebugView *optv = GrayNcommon::GrayNgetDebugView();
    if (optv != nil && p_GrayN_Base_SDKWindow != nil && GrayNcommon::m_GrayNforceDebug_Mode) {
        [optv GrayN_DebugView_SetFrame:CGRectMake(0, 0, p_GrayN_Base_Rvc.view.frame.size.width, p_GrayN_Base_Rvc.view.frame.size.height)];
        [p_GrayN_Base_SDKWindow addSubview:optv];
    }
}
- (void)GrayNcloseJSBridgeView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [GrayN_WebViewController GrayN_WVC_SetJSBridgeNil];
        [self GrayN_CloseSDK_Window];
        if (GrayNchannel::GetInstance().GrayN_ChannelIsLogin()) {
//            GrayNchannel::GetInstance().IsAllowShowToolBar(YES);
        }
        p_GrayN_Base_SDKWindow.rootViewController = p_GrayN_Base_Rvc;

        if (p_GrayN_Base_Toast.m_GrayN_Toast_IsClose && p_GrayN_Base_Toast.m_GrayN_Toast_IsProcessing) {
            [p_GrayN_Base_Toast removeFromSuperview];
            [p_GrayN_Base_SDKWindow.rootViewController.view addSubview:p_GrayN_Base_Toast];
        }
    });
}
/* 顯示進度欄 */
- (void)GrayNshowHudWithTag:(int)tag withUserName:(NSString *)userName handler:(m_GrayN_Hud_Callback)handler
{
    [self GrayN_ShowSDK_Window];
    [self.view setHidden:NO];
    
    static BOOL isInit = NO;
    if (!isInit) {
        p_GrayN_Base_Hud = [[GrayN_Hud alloc] initWithFrame:CGRectMake(0, 0, 492*p_GrayN_Base_Screen_Ratio, 156*p_GrayN_Base_Screen_Ratio)];
        isInit = YES;
        if ([[[UIDevice currentDevice] systemVersion] floatValue]<8.0f && p_GrayN_Base_IsLandScape) {
            p_GrayN_Base_Hud.center = CGPointMake(self.view.center.y, self.view.center.x);
        } else {
            p_GrayN_Base_Hud.center = self.view.center;
        }
    }
    p_GrayN_Base_Hud.m_GrayN_Hud_UserName = userName;
    [self.view addSubview:p_GrayN_Base_Hud];
    
    [p_GrayN_Base_Hud.m_GrayN_Hud_Callback release];
    p_GrayN_Base_Hud.m_GrayN_Hud_Callback = [handler copy];
    [p_GrayN_Base_Hud GrayN_Hud_ShowWithTag:tag];
}
/* 關閉進度欄 */
- (void)GrayNcloseHud
{
    [p_GrayN_Base_Hud GrayN_Hud_Close];
    [p_GrayN_Base_Hud removeFromSuperview];
    p_GrayN_Base_Hud.m_GrayN_Hud_UserName = @"";
    
    [self GrayN_CloseSDK_Window];
}
- (void)GrayNswitch_Account
{
    dispatch_async(dispatch_get_main_queue(), ^{
        GrayN_Offical::GetInstance().GrayN_Offical_ShowSwitchAccountView();
    });
}
/* 欢迎栏 */
- (void)GrayNshowWelcome:(NSString *)string
{
    CGPoint GrayNwelcomeCenter = CGPointZero;
    
        if ([[[UIDevice currentDevice] systemVersion] floatValue]<8.0f && p_GrayN_Base_IsLandScape) {
            GrayNwelcomeCenter = CGPointMake(p_GrayN_Base_SDKWindow.center.y, GrayNstraightBangsTopEdge*0.5);
        } else {
            GrayNwelcomeCenter = CGPointMake(p_GrayN_Base_SDKWindow.center.x, GrayNstraightBangsTopEdge*0.5);

            /*5.1.1 判断iPhoneX*/
            if (GrayNisStraightBangsDevice) {
                if (!p_GrayN_Base_IsLandScape) {
                    GrayNwelcomeCenter = CGPointMake(p_GrayN_Base_SDKWindow.center.x, GrayNstraightBangsTopEdge*0.5 + 44);
                } 
            }
        }
    
    if ([string isEqualToString:@"!@w#$"]) {
        string = GrayNgetResBundleStr(GrayN_GUEST_NAME);
    }
    
    NSString *msg = [NSString stringWithFormat:@"%@%@",string,GrayNgetResBundleStr(GrayN_WELCOME_ENTER_GAME)];
    // 限制显示用户名长度，控制为30位以内
    if (string.length >= GrayNrestrict_Length) {
        string = [NSString stringWithFormat:@"%@...",[string substringToIndex:GrayNrestrict_Length-3]];
        msg = [NSString stringWithFormat:@"%@%@",string,GrayNgetResBundleStr(GrayN_WELCOME_ENTER_GAME)];
        
    }
    [[GrayN_BaseControl GrayN_Share] GrayNshowToast:msg withCenter:GrayNwelcomeCenter ifCloseWindow:YES];
}

- (BOOL)prefersHomeIndicatorAutoHidden
{
    return [GrayNbaseSDK GrayNhomeIndicator_AutoHidden];
}
- (UIRectEdge)preferredScreenEdgesDeferringSystemGestures
{
    return [GrayNbaseSDK GrayNdeferring_SystemGestures];
}
/*5.2.1*/
- (void)GrayNshowQRCodeView
{

    [self GrayN_ShowSDK_Window];
    if (p_GrayN_Base_QR_View == nil) {
        p_GrayN_Base_QR_View = [[GrayN_QRCodeConfirm alloc] initWithFrame:CGRectMake(0, 0, 488*GrayNscreen_Ratio, 518*GrayNscreen_Ratio)];
        p_GrayN_Base_QR_View.center = p_GrayN_Base_SDKWindow.center;
    }
    [p_GrayN_Base_SDKWindow.rootViewController.view addSubview:p_GrayN_Base_QR_View];
    [p_GrayN_Base_QR_View GrayNshowQRCodeCofirm];

}
- (void)GrayNcloseQRCodeView
{
    [self GrayN_CloseSDK_Window];

    [p_GrayN_Base_QR_View removeFromSuperview];
}
@end
