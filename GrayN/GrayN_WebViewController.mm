
#import <WebKit/WebKit.h>

#import "GrayN_WebViewController.h"
#import "GrayNSDK.h"
#import "GrayN_BaseControl.h"
#import "GrayNbaseSDK.h"
#import "GrayNcommon.h"
#import "GrayNpayCenter.h"
#import "GrayN_LoadingUI.h"
#import "GrayNcustomService_Control.h"
#import "GrayN_Tools.h"
#import "GrayN_Offical.h"
#import "GrayNchannelSDK.h"
#import "GrayNinit.h"
#import "GrayNlogCenter.h"


/*5.2.0*/
#import "GrayN_GameCenter.h"

GrayNusing_NameSpace;

@interface GrayN_WebViewController ()
{
    id p_GrayN_WVC_WebView;
}
@end

static GrayN_WebViewController *p_GrayN_WVC_share;
static string p_GrayN_WVC_JSBridgeUrl = "";
static BOOL   p_GrayN_WVC_IsOpenAllOrientation = NO;

@implementation GrayN_WebViewController
@synthesize bridge = _bridge;

- (WKWebView *)GrayN_WVC_GetCurrentWebview
{
    return p_GrayN_WVC_WebView;
}
+ (id)GrayN_Share
{
    if (p_GrayN_WVC_share == nil) {
        p_GrayN_WVC_share = [[GrayN_WebViewController alloc] init];
    }
    return p_GrayN_WVC_share;
}
+ (void)GrayN_WVC_SetJSBridgeNil
{
    [p_GrayN_WVC_share GrayNstopWebView];
    [p_GrayN_WVC_share release];
    p_GrayN_WVC_share = nil;
    
//    [p_GrayN_WVC_share.bridge dealloc];
//    NSLog(@"Dealloc~~~~~~~~");

}
- (void)GrayNstopWebView
{
    GrayNreleaseSafe(p_GrayN_WVC_WebView);

//    [p_GrayN_WVC_WebView stopLoading];
//    // 很重要必须将代理制空，否则还会加载释放前页面的代理
//    p_GrayN_WVC_WebView.delegate = nil;
}
- (void)viewWillAppear:(BOOL)animated
{
    [p_GrayN_WVC_WebView stopLoading];
    if (_bridge) {
//        NSLog(@"OPUIWebView:viewWillAppearreturn");
        return;
    }
    self.view.frame = [GrayN_BaseControl GrayN_Base_WindowRect];

    if ([[UIDevice currentDevice].systemVersion floatValue] < 8.0f) {
        UIWebView *webView = [[UIWebView alloc] initWithFrame:[GrayN_BaseControl GrayN_Base_WindowRect]];
        webView.opaque = NO;
        /*解决键盘崩溃*/
        webView.keyboardDisplayRequiresUserAction = NO;
        // 禁止页面捏合
        webView.scalesPageToFit = NO;

        [p_GrayN_WVC_share setNavigationBarHidden:YES];
        webView.backgroundColor = GrayNclearColor;
        p_GrayN_WVC_WebView = webView;
        [self.view addSubview:webView];

        _bridge = [GrayN_WebViewJavascriptBridge GrayNbridgeForWebView:p_GrayN_WVC_WebView];

    } else {
        WKWebView *webView = [[WKWebView alloc] initWithFrame:[GrayN_BaseControl GrayN_Base_WindowRect]];
        webView.opaque = NO;
        [p_GrayN_WVC_share setNavigationBarHidden:YES];
        webView.backgroundColor = GrayNclearColor;
        p_GrayN_WVC_WebView = webView;

        [self.view addSubview:webView];
        
        if (GrayNcommon::m_GrayNdebug_Mode) {
            [GrayN_WKWebViewJavascriptBridge GrayNenableLogging];
        }
        
        _bridge = [GrayN_WKWebViewJavascriptBridge GrayNbridgeForWebView:p_GrayN_WVC_WebView];
    }
    

    // 4.1	通用功能
    [self invokeSdkEncryptData];
    [self invokeSdkDecodeData];
    [self invokeSdkCloseWebiew];
    [self invokeSdkCloseWebview];
    [self invokeSdkNativeToast];
    [self invokeSdkClipboardCopy];
    [self invokeSdkOpenBrowser];
    [self invokeSdkOpenKeyboard];
    [self invokeSdkCloseKeyboard];
    [self invokeSdkClearAppcache];
    [self invokeSdkWebviewBack];
    [self invokeSdkPrintConsole];
    [self invokeSdkPageLoadNotify];
    [self invokeSdkGetStaticSource];
    [self invokeSdkOpenWebview];
    
    // 4.2	登录前置功能
    [self invokeSdkGetPromptInfo];
    [self invokeSdkSetUpdatePrompt];
    [self invokeSdkActivateNotify];
    [self invokeSdkGetActivateInfo];
    [self invokeSdkDownloadGame];
    
    // 4.3	登录注册初始化
    [self invokeSdkQuitApp];
    [self invokeSdkGetLoginedUsers];
    [self invokeSdkGetCurrentUser];
    [self invokeSdkDelUser];
    [self invokeSdkGetFastLoginDeviceId];
    [self invokeSdkLoginFinished];
    [self invokeSdkUserLogin];
    [self invokeSdkReloadSessionId];
    [self invokeSdkRegisterNotify];
    [self invokeSdkDelUserByUserName];
    [self invokeSdkThirdLogin];
    
    // 4.4	支付相关接口
    [self invokeSdkOpenNativePay];
    [self invokeSdkGetOrderInfo];
    [self invokeSdkPayResult];
    
    // 4.5	用户中心相关接口
    [self invokeSdkUserUpgradeNotify];
    [self invokeSdkUserBindNotify];
    [self invokeSdkUserModifyPasswordNotify];
    [self invokeSdkUserModifyNickNameNotify];
    [self invokeSdkUserUnBindNotify];
    [self invokeSdkIdentityAuthBindNotify];
    [self invokeSdkLogOut];
    [self invokeSdkSwitchAccount];
    [self invokeSdkUnreadMessageStatus];
    // 4.6	客服相关接口
    [self invokeSdkUploadImg];
}
#pragma mark - 4.1 通用功能
/*4.1.1	数据加密接口*/
- (void)invokeSdkEncryptData
{
    [_bridge registerHandler:@"invokeSdkEncryptData" handler:^(id data, WVJBResponseCallback responseCallback) {
#ifdef DES_ENCRYPT
        GrayNcommon::GrayN_DebugLog(@"encryptData called: %@", data);
#endif
        NSString *strData = [NSString stringWithFormat:@"%@", data];
        strData = [GrayN_Tools GrayNdesEncodeString:strData];
        
        responseCallback(strData);
    }];
}
/*4.1.2	数据解密接口*/
- (void)invokeSdkDecodeData
{
    [_bridge registerHandler:@"invokeSdkDecodeData" handler:^(id data, WVJBResponseCallback responseCallback) {
#ifdef DES_ENCRYPT
        GrayNcommon::GrayN_DebugLog(@"decryptData called: %@", data);
#endif
        NSString *strData = [NSString stringWithFormat:@"%@", data];
        strData = [GrayN_Tools GrayNdesDecodeString:strData];
        
        responseCallback(strData);
    }];
}
/*4.1.3	关闭当前页面窗口*/
- (void)invokeSdkCloseWebiew
{
    [_bridge registerHandler:@"invokeSdkCloseWebiew" handler:^(id data, WVJBResponseCallback responseCallback) {
        GrayNcommon::GrayN_DebugLog(@"invokeSdkCloseWebiew: %@", data);
        responseCallback(@"true");
        [self GrayN_WVC_CloseJSBridgeViewIsForceClose:NO];
    }];
}
- (void)invokeSdkCloseWebview
{
    [_bridge registerHandler:@"invokeSdkCloseWebview" handler:^(id data, WVJBResponseCallback responseCallback) {
        GrayNcommon::GrayN_DebugLog(@"invokeSdkCloseWebview: %@", data);
        responseCallback(@"true");
        [self GrayN_WVC_CloseJSBridgeViewIsForceClose:NO];
    }];
}
/*4.1.4	本地toast提示信息接口*/
- (void)invokeSdkNativeToast
{
    [_bridge registerHandler:@"invokeSdkNativeToast" handler:^(id data, WVJBResponseCallback responseCallback) {
        GrayNcommon::GrayN_DebugLog(@"invokeSdkNativeToast: %@", data);
        NSString *msg = (NSString*)data;
        if ([msg isEqualToString:@""] || msg == nil) {
            msg = @"invokeSdkNativeToast异常错误,msg返回为空";
        }
        GrayN_Offical::GetInstance().GrayN_Offical_ShowToast([msg UTF8String], YES);
        
        responseCallback(@"true");
    }];
}
/*4.1.5 复制到剪贴板*/
- (void)invokeSdkClipboardCopy
{
    [_bridge registerHandler:@"invokeSdkClipboardCopy" handler:^(id data, WVJBResponseCallback responseCallback) {
        GrayNcommon::GrayN_DebugLog(@"invokeSdkClipboardCopy: %@", data);
        
        NSString *pasteStr = (NSString*)data;
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = pasteStr;
        responseCallback(pasteStr);
    }];
}
/*4.1.6 打开本地浏览器*/
- (void)invokeSdkOpenBrowser
{
    [_bridge registerHandler:@"invokeSdkOpenBrowser" handler:^(id data, WVJBResponseCallback responseCallback) {
        GrayNcommon::GrayN_DebugLog(@"invokeSdkOpenBrowser: %@", data);
        
        NSString *url = (NSString*)data;
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        responseCallback(url);
    }];
}
/*4.1.7 打开键盘*/
- (void)invokeSdkOpenKeyboard
{
    [_bridge registerHandler:@"invokeSdkOpenKeyboard" handler:^(id data, WVJBResponseCallback responseCallback) {
        GrayNcommon::GrayN_DebugLog(@"invokeSdkOpenKeyboard: %@", data);
//        [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
        responseCallback(@"true");
    }];
}
/*4.1.8 关闭键盘*/
- (void)invokeSdkCloseKeyboard
{
    [_bridge registerHandler:@"invokeSdkCloseKeyboard" handler:^(id data, WVJBResponseCallback responseCallback) {
        GrayNcommon::GrayN_DebugLog(@"invokeSdkCloseKeyboard: %@", data);
        [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
        responseCallback(@"true");
    }];
}
/*4.1.9	主动清除appcache缓存*/
- (void)invokeSdkClearAppcache
{
    [_bridge registerHandler:@"invokeSdkClearAppcache" handler:^(id data, WVJBResponseCallback responseCallback) {
        GrayNcommon::GrayN_DebugLog(@"invokeSdkClearAppcache: %@", data);
        
        [GrayN_Tools GrayNclearAppCache];
        responseCallback(@"true");
    }];
}
/*4.1.10 返回上一页*/
- (void)invokeSdkWebviewBack
{
    [_bridge registerHandler:@"invokeSdkWebviewBack" handler:^(id data, WVJBResponseCallback responseCallback) {
        GrayNcommon::GrayN_DebugLog(@"invokeSdkWebviewBack: %@", data);
        [p_GrayN_WVC_WebView goBack];
        responseCallback(@"true");
    }];
}
/*4.1.11 输出日志接口*/
- (void)invokeSdkPrintConsole
{
    [_bridge registerHandler:@"invokeSdkPrintConsole" handler:^(id data, WVJBResponseCallback responseCallback) {
        GrayNcommon::GrayN_ConsoleLog(@"invokeSdkPrintConsole: \n%@", data);
        responseCallback(@"true");
    }];
}
/*4.1.12 页面加载回报通知接口*/
- (void)invokeSdkPageLoadNotify
{
    [_bridge registerHandler:@"invokeSdkPageLoadNotify" handler:^(id data, WVJBResponseCallback responseCallback) {
        GrayNcommon::GrayN_DebugLog(@"invokeSdkPageLoadNotify: \n%@", data);
        NSDictionary *callbackDic = (NSDictionary*)data;
        NSString *status = [callbackDic objectForKey:@"status"];
        NSString *errorType = [callbackDic objectForKey:@"errorType"];
        NSString *errorInfo = [callbackDic objectForKey:@"errorInfo"];
//        cout<<"p_GrayN_WVC_JSBridgeUrl="<<p_GrayN_WVC_JSBridgeUrl<<endl;
        if ([status isEqualToString:@"false"]) {
            // 发送页面错误日志
            GrayN_JSON::Value logValJson;
            logValJson["pageUrl"] = GrayN_JSON::Value(p_GrayN_WVC_JSBridgeUrl);
            logValJson["waitTime"] = GrayN_JSON::Value("");
            logValJson["errorType"] = GrayN_JSON::Value([errorType UTF8String]);
            logValJson["errorInfo"] = GrayN_JSON::Value([errorInfo UTF8String]);
            GrayN_JSON::FastWriter fast_writer;
            string resultStr = fast_writer.write(logValJson);
            OPGameSDK::GetInstance().SendLog("11003", "sdk-crash-page", resultStr.c_str());
        } else {
            GrayNcommon::GrayN_ConsoleLog(@"页面加载成功结束页面监控");
//            GrayN_Offical::GetInstance().GrayN_StopTimer();
        }
        responseCallback(@"true");
    }];
}
/*4.1.13 获取本地静态资源接口*/
- (void)invokeSdkGetStaticSource
{
    [_bridge registerHandler:@"invokeSdkGetStaticSource" handler:^(id data, WVJBResponseCallback responseCallback) {
        GrayNcommon::GrayN_DebugLog(@"invokeSdkGetStaticSource: \n%@", data);
        NSDictionary *callbackDic = (NSDictionary*)data;
        
        NSString *name = [callbackDic objectForKey:@"name"];
        NSString *type = [callbackDic objectForKey:@"type"];
        
        NSString *returnFile = nil;
        NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"OurSDK_res.bundle/jsBridge/%@", name]];
        NSData *fileData = [NSData dataWithContentsOfFile:path];

        if ([type isEqualToString:@"file"]) {
            returnFile = [fileData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        } else if ([type isEqualToString:@"content"]) {
            returnFile = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
        } else {
            responseCallback(@"");
            return;
        }
        
        returnFile = [GrayNbaseSDK GrayNencodeBase64:returnFile];
        
        GrayNcommon::GrayN_DebugLog(@"invokeSdkGetStaticSourceReturn:\n%@", returnFile);

        responseCallback(returnFile);
    }];
}
/*4.1.14 打开webview加载指定页面*/
- (void)invokeSdkOpenWebview
{
    [_bridge registerHandler:@"invokeSdkOpenWebview" handler:^(id data, WVJBResponseCallback responseCallback) {
        GrayNcommon::GrayN_DebugLog(@"invokeSdkOpenWebview: \n%@", data);
        NSDictionary *callbackDic = (NSDictionary*)data;
        
        NSString *type = [callbackDic objectForKey:@"type"];
        NSString *url = [callbackDic objectForKey:@"url"];
        url = [GrayNbaseSDK GrayNurl_Decode:[url UTF8String]];

        BOOL closeCurrentWebview = [[callbackDic objectForKey:@"closeCurrentWebview"] boolValue];
        BOOL showNavbar = [[callbackDic objectForKey:@"navbarView"] boolValue];
        GrayNcommon::GrayN_DebugLog(@"type=%@\nurl=%@\ncloseCurrentWebview=%d\nshowNavbar=%d", type, url, closeCurrentWebview, showNavbar);

        
        if (closeCurrentWebview) {
            [self GrayN_WVC_CloseJSBridgeViewIsForceClose:YES];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[GrayN_BaseControl GrayN_Share] GrayNshowJSBridgeView:url];
            });
        } else {
            [[GrayN_BaseControl GrayN_Share] setM_GrayN_Base_IsSaveUrl:NO];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[GrayN_BaseControl GrayN_Share] GrayNshowJSBridgeViewInNewWebview:url];
            });
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            p_GrayN_WVC_IsOpenAllOrientation = YES;
            [_bridge GrayNsetShowNavbar:showNavbar];
            [_bridge GrayNsetsetTopbarUp:NO];
        });
        
        
        responseCallback(@"true");
    }];
}
#pragma mark - 4.2 登录前置功能
/*4.2.1	获取登录前置提示信息*/
- (void)invokeSdkGetPromptInfo
{
    [_bridge registerHandler:@"invokeSdkGetPromptInfo" handler:^(id data, WVJBResponseCallback responseCallback) {
        
        GrayN_JSON::Value noticeInfo;
        noticeInfo["switch"] = GrayNSDK::m_GrayN_SDK_NoticeSwitch;//GrayN_JSON::Value(GrayNSDK::m_GrayN_SDK_NoticeSwitch); //公告开关，是否显示公告
        noticeInfo["content"] = GrayNSDK::m_GrayN_SDK_NoticeContent;
        GrayN_JSON::Value gameUpdateInfo;
        //更新：1 强制更新 2 非强制更新 3 不更新
        int updateType = atoi(GrayNSDK::m_GrayN_SDK_UpdateType.c_str());
        if (updateType == 2) {
            //非强制更新
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSDictionary *dic = [userDefaults objectForKey:@"ShowUpdate"];
//            NSLog(@"ShowUpdateDic=%@", dic);
            
            if (dic == nil) {
                gameUpdateInfo["updateType"] = GrayN_JSON::Value(GrayNSDK::m_GrayN_SDK_UpdateType);
            } else {
//                NSString *newVersion = [dic objectForKey:@"version"];
//                NSString *curVersion = [NSString stringWithUTF8String:GrayNcommon::m_GrayN_GameVersion.c_str()];
//                if ([newVersion compare:curVersion options:NSNumericSearch] == NSOrderedDescending) {
                    bool prompt = [[dic objectForKey:@"prompt"] boolValue];
                    if (prompt) {
                        gameUpdateInfo["updateType"] =GrayN_JSON::Value(GrayNSDK::m_GrayN_SDK_UpdateType);
                    } else {
                        GrayNcommon::GrayN_DebugLog(@"用户选择无需更新！");
                        gameUpdateInfo["updateType"] = GrayN_JSON::Value("3");
                    }
//                }
            }
        } else {
            gameUpdateInfo["updateType"] = GrayN_JSON::Value(GrayNSDK::m_GrayN_SDK_UpdateType);
        }
        
        gameUpdateInfo["version"] = GrayN_JSON::Value(GrayNSDK::m_GrayN_SDK_UpdateVersion);
        gameUpdateInfo["description"] = GrayN_JSON::Value(GrayNSDK::m_GrayN_SDK_UpdateDesc);
        gameUpdateInfo["fileSize"] = GrayN_JSON::Value(GrayNSDK::m_GrayN_SDK_UpdateFileSize);
        gameUpdateInfo["updateUrl"] = GrayN_JSON::Value(GrayNSDK::m_GrayN_SDK_UpdateUrl);

        GrayN_JSON::Value promptInfo;
        promptInfo["message"] = GrayN_JSON::Value(GrayNSDK::m_GrayN_SDK_LimitDesc);
        promptInfo["type"] = GrayN_JSON::Value("0");        //白名单开关，是否可关闭
        promptInfo["hasPromp"] = GrayN_JSON::Value(GrayNSDK::m_GrayN_SDK_IsLimit);    //是否有提示信息；0：没有；1：有；
        
        GrayN_JSON::Value activateCode;
        activateCode["openActivateWin"] = GrayN_JSON::Value(GrayNSDK::m_GrayN_SDK_OpenActivateWin);
        activateCode["switch"] = GrayN_JSON::Value(GrayNSDK::m_GrayN_SDK_ActivateCodeSwitch);
        
        GrayN_JSON::Value root;
        root["noticeInfo"] = GrayN_JSON::Value(noticeInfo);
        root["gameUpdateInfo"] = GrayN_JSON::Value(gameUpdateInfo);
        root["promptInfo"] = GrayN_JSON::Value(promptInfo);
        root["activateCode"] = GrayN_JSON::Value(activateCode);
        
        GrayN_JSON::FastWriter fast_writer;
        string tmp = fast_writer.write(root);
        NSString *jsonStr = [NSString stringWithUTF8String:tmp.c_str()];
        GrayNcommon::GrayN_DebugLog(@"invokeSdkGetPromptInfoCallBack:%@",jsonStr);
        responseCallback(jsonStr);
    }];
}

/*4.2.2	设置目的更新版本不再进行提示*/
- (void)invokeSdkSetUpdatePrompt
{
    [_bridge registerHandler:@"invokeSdkSetUpdatePrompt" handler:^(id data, WVJBResponseCallback responseCallback) {
        GrayNcommon::GrayN_DebugLog(@"invokeSdkSetUpdatePrompt: %@", data);
        
        NSDictionary *dic = (NSDictionary*)data;
        if (dic) {
            //            NSString *newVersion = [dic objectForKey:@"version"];
            //            bool prompt = [[dic objectForKey:@"prompt"] boolValue]; //下次启动是否需要提示，true需要，false不需要
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:dic forKey:@"ShowUpdate"];
            [userDefaults synchronize];
        }
        responseCallback(@"true");
    }];
}
/*4.2.3	激活码激活成功通知接口*/
- (void)invokeSdkActivateNotify
{
    [_bridge registerHandler:@"invokeSdkActivateNotify" handler:^(id data, WVJBResponseCallback responseCallback) {
        GrayNcommon::GrayN_DebugLog(@"invokeSdkActivateNotify: %@", data);
        
        NSDictionary *dic = (NSDictionary*)data;
        if (dic) {
            NSString *activateCode = [dic objectForKey:@"activateCode"];
            GrayNSDK::m_GrayN_SDK_ActivateCode = [activateCode UTF8String];
            NSString *activateTokenId = [dic objectForKey:@"activateTokenId"];
            GrayNSDK::m_GrayN_SDK_ActivateTokenId = [activateTokenId UTF8String];
        }
        
        responseCallback(@"true");
    }];
}
/*4.2.4	获取激活码激活成功token接口*/
- (void)invokeSdkGetActivateInfo
{
    [_bridge registerHandler:@"invokeSdkGetActivateInfo" handler:^(id data, WVJBResponseCallback responseCallback) {
        GrayNcommon::GrayN_DebugLog(@"invokeSdkGetActivateInfo: %@", data);
        
        GrayN_JSON::Value activateInfo;
        activateInfo["activateCode"]=GrayN_JSON::Value(GrayNSDK::m_GrayN_SDK_ActivateCode);
        activateInfo["activateTokenId"]=GrayN_JSON::Value(GrayNSDK::m_GrayN_SDK_ActivateTokenId);
        GrayN_JSON::FastWriter fast_writer;
        string tmp = fast_writer.write(activateInfo);
        NSString *jsonStr = [NSString stringWithUTF8String:tmp.c_str()];
        
        responseCallback(jsonStr);
    }];
}
//4.2.5	更新下载接口
- (void)invokeSdkDownloadGame
{
    [_bridge registerHandler:@"invokeSdkDownloadGame" handler:^(id data, WVJBResponseCallback responseCallback) {
        GrayNcommon::GrayN_DebugLog(@"invokeSdkDownloadGame: %@", data);
        
        NSDictionary *dic = (NSDictionary*)data;
        if (dic) {
            NSString *url = [dic objectForKey:@"url"];
            //            NSString *fileSize = [dic objectForKey:@"fileSize"];
            //            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
            
            //使用官网的登录及更新，直接使用游戏内部更新
            [[GrayN_BaseControl GrayN_Share] GrayN_AutoDownload:url];
            
            responseCallback(@"true");
        }
    }];
}
#pragma mark - 4.3 登录注册初始化
/*4.3.1 退出当前应用*/
- (void)invokeSdkQuitApp
{
    [_bridge registerHandler:@"invokeSdkQuitApp" handler:^(id data, WVJBResponseCallback responseCallback) {
        GrayNcommon::GrayN_DebugLog(@"invokeSdkQuitApp: %@", data);
        responseCallback(@"true");
        /* 不要使用exit函数，调用exit会让用户感觉程序崩溃了，
           不会有按Home键返回时的平滑过渡和动画效果；
           另外，使用exit可能会丢失数据，因为调用exit并不会调用
           -applicationWillTerminate:方法和UIApplicationDelegate方法
         */
        GrayNlogCenter::GetInstance().m_GrayN_LogIsQuitGame = true;
            abort();
//        exit(0);
    }];
}
/*4.3.2	获取本地记录的登录过的用户信息列表*/
- (void)invokeSdkGetLoginedUsers
{
    [_bridge registerHandler:@"invokeSdkGetLoginedUsers" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSString *users = [GrayN_Tools GrayNloadUsersInfo];
        GrayNcommon::GrayN_DebugLog(@"invokeSdkGetLoginedUsers: %@", users);
        
        responseCallback(users);
    }];
}
/*4.3.3	获取当前已经登录的用户信息*/
- (void)invokeSdkGetCurrentUser
{
    [_bridge registerHandler:@"invokeSdkGetCurrentUser" handler:^(id data, WVJBResponseCallback responseCallback) {
        
        GrayN_UserInfo *GrayN_UserInfo_GrayN = [GrayN_Tools GrayNloadLastUserInfo];
        NSMutableDictionary *opUserInfoDic = GrayN_UserInfo_GrayN.GrayN_UserInfo_GrayN;
        [opUserInfoDic setObject:@"" forKey:@"password"];
    
        GrayN_UserInfo *opUserInfoNoPswd = [[[GrayN_UserInfo alloc] init] autorelease];
        [opUserInfoNoPswd GrayN_SetUserInfo:opUserInfoDic];
        [opUserInfoNoPswd GrayN_FormatJson];

        NSString *dataStr = [opUserInfoNoPswd.GrayN_UserInfo_GrayN objectForKey:@"jsonInfo"];

        GrayNcommon::GrayN_DebugLog(@"invokeSdkGetCurrentUser: %@", dataStr);
        responseCallback(dataStr);
    }];
}
/*4.3.4	删除账户登录记录*/
- (void)invokeSdkDelUser
{
    [_bridge registerHandler:@"invokeSdkDelUser" handler:^(id data, WVJBResponseCallback responseCallback) {
        GrayNcommon::GrayN_DebugLog(@"invokeSdkDelUser: %@", data);
        NSDictionary *userInfo = (NSDictionary*)data;
        [GrayN_Tools GrayNdelUserInfoWithUserId:[userInfo objectForKey:@"userId"]];
        responseCallback(data);
    }];
}
/*4.3.5	获取快登的设备信息*/
- (void)invokeSdkGetFastLoginDeviceId
{
    [_bridge registerHandler:@"invokeSdkGetFastLoginDeviceId" handler:^(id data, WVJBResponseCallback responseCallback) {
        GrayNcommon::GrayN_DebugLog(@"invokeSdkGetFastLoginDeviceId: %@", data);
        
        NSString *idfa = [NSString stringWithUTF8String:GrayNcommon::m_GrayN_IDFA.c_str()];
        NSMutableDictionary *deviceId = [[[NSMutableDictionary alloc] init] autorelease];
        [deviceId setObject:idfa forKey:@"deviceId"];
        NSString *dataStr = [GrayN_Tools GrayNdictionaryToJsonString:deviceId];
        
        GrayNcommon::GrayN_DebugLog(@"sendIDFA: %@", dataStr);
        responseCallback(dataStr);
    }];
}
/*4.3.6	用户登入成功回调*/
- (void)invokeSdkLoginFinished
{
    [_bridge registerHandler:@"invokeSdkLoginFinished" handler:^(id data, WVJBResponseCallback responseCallback) {
        GrayNcommon::GrayN_DebugLog(@"invokeSdkLoginFinished: %@", data);
        
        NSDictionary *userInfo = (NSDictionary*)data;
        GrayN_UserInfo *GrayN_UserInfo_GrayN = [[[GrayN_UserInfo alloc] init] autorelease];
        [GrayN_UserInfo_GrayN GrayN_SetUserInfo:userInfo];
        GrayNcommon::GrayN_DebugLog(@"333333333333%@", GrayN_UserInfo_GrayN.returnJson);
        
        if ([GrayN_UserInfo_GrayN.returnJson isEqual:[NSNull null]] ||
            GrayN_UserInfo_GrayN.returnJson == nil || [GrayN_UserInfo_GrayN.returnJson isEqual:@""]) {
            GrayN_UserInfo *opTmpUserInfo = [[[GrayN_UserInfo alloc] init] autorelease];
            opTmpUserInfo = [GrayN_Tools GrayNloadUserInfoWithUserId:GrayN_UserInfo_GrayN.userId];
            if (![opTmpUserInfo.userId isEqualToString:@""]) {
                if (opTmpUserInfo.returnJson != nil) {
                    GrayN_UserInfo_GrayN.returnJson = opTmpUserInfo.returnJson;
                    [GrayN_UserInfo_GrayN.GrayN_UserInfo_GrayN setObject:GrayN_UserInfo_GrayN.returnJson forKey:@"returnJson"];
                }
                if (GrayN_UserInfo_GrayN.GrayN_UserInfo_GrayN == nil) {
                    GrayN_UserInfo_GrayN.GrayN_UserInfo_GrayN = opTmpUserInfo.GrayN_UserInfo_GrayN;
                }
            }
        }
        GrayNcommon::GrayN_DebugLog(@"44444444444%@", GrayN_UserInfo_GrayN.returnJson);
        GrayNcommon::m_GrayN_Game_UserId = [GrayN_UserInfo_GrayN.userId UTF8String];
        GrayNcommon::m_GrayN_Game_UserName = [GrayN_UserInfo_GrayN.userName UTF8String];
        GrayNcommon::m_GrayN_Game_PhoneNum = [GrayN_UserInfo_GrayN.bindPhone UTF8String];
        GrayNcommon::m_GrayN_Game_Email = [GrayN_UserInfo_GrayN.bindEmail UTF8String];
        GrayNcommon::m_GrayN_Game_PalmId = [GrayN_UserInfo_GrayN.palmId UTF8String];
        GrayNcommon::m_GrayN_LoginType = [GrayN_UserInfo_GrayN.loginType UTF8String];
        GrayNcommon::m_GrayN_Game_NickName = [GrayN_UserInfo_GrayN.nickName UTF8String];

        [GrayN_Tools GrayNsaveUserInfo:GrayN_UserInfo_GrayN];
        responseCallback(@"true");
        
        /*5.1.4 保存实名认证状态*/
        GrayNSDK::m_GrayN_SDK_IdentityStatus = [GrayN_UserInfo_GrayN.identityAuthStatus UTF8String];
        
        if ([GrayN_UserInfo_GrayN.currentUserType rangeOfString:@"speedy"].location!=NSNotFound) {
            GrayN_Offical::GetInstance().GrayN_Offical_ShowWelcome("!@w#$");
        } else if ([GrayN_UserInfo_GrayN.currentUserType rangeOfString:@"thirdHidden"].location!=NSNotFound) {
            string nickName;
            GrayN_Offical::GetInstance().GrayN_Offical_GetCurrentThirdHiddenNickName([GrayN_UserInfo_GrayN.userId UTF8String], nickName);
            GrayN_Offical::GetInstance().GrayN_Offical_ShowWelcome(nickName);
        } else if ([GrayN_UserInfo_GrayN.currentUserType rangeOfString:@"phone"].location!=NSNotFound) {
            string nickName;
            GrayN_Offical::GetInstance().GrayN_Offical_ShowWelcome([GrayN_UserInfo_GrayN.bindPhone UTF8String]);
        } else {
            GrayN_Offical::GetInstance().GrayN_Offical_ShowWelcome([GrayN_UserInfo_GrayN.userName UTF8String]);
            //            GrayN_Offical::GetInstance().SetIsNeedBindPhone([GrayN_UserInfo_GrayN.needBindPhone boolValue]);
        }
        
        GrayNcommon::m_GrayN_CurrentUserType = [GrayN_UserInfo_GrayN.currentUserType UTF8String];
        
        GrayN_JSON::Value userInfo_json;
        userInfo_json["palmId"] = [GrayN_UserInfo_GrayN.palmId UTF8String];
        userInfo_json["nickName"] = [GrayN_UserInfo_GrayN.nickName UTF8String];
        
        GrayN_JSON::Value tmp_json;
        tmp_json["returnJson"] = userInfo_json;
        
        tmp_json["userId"] = [GrayN_UserInfo_GrayN.userId UTF8String];
        string::size_type idx = GrayNcommon::m_GrayN_CurrentUserType.find("phone");
        if ( idx !=string::npos) {
            tmp_json["userName"] = [GrayN_UserInfo_GrayN.bindPhone UTF8String];
        } else {
            tmp_json["userName"] = [GrayN_UserInfo_GrayN.userName UTF8String];
        }
        
        tmp_json["tokenId"] = GrayNcommon::m_GrayN_SessionId;
        tmp_json["currentUserType"] = GrayNcommon::m_GrayN_CurrentUserType;
        
        /*拼接5.2.3 dataJson*/
        GrayN_JSON::Value dataJson;

        if (GrayN_Offical::GetInstance().m_GrayN_Offical_LoginData["userId"].asString() != "") {
            dataJson = GrayN_Offical::GetInstance().m_GrayN_Offical_LoginData;
        } else {
            GrayN_JSON::Value bindPhone;
            bindPhone["bindTokenId"] = [[userInfo objectForKey:@"bindTokenId"] UTF8String];
            bindPhone["isNeed"] = [[userInfo objectForKey:@"needBindPhone"] UTF8String];
            
            dataJson["bindPhone"] = bindPhone;
            
            dataJson["currentUserType"] = [[userInfo objectForKey:@"currentUserType"] UTF8String];
            
            dataJson["bindEmail"] = [[userInfo objectForKey:@"bindEmail"] UTF8String];
            
            GrayN_JSON::Value identityAuth;
            identityAuth["idNum"] = [[userInfo objectForKey:@"identityAuthIdNum"] UTF8String];
            identityAuth["realName"] = [[userInfo objectForKey:@"identityAuthRealName"] UTF8String];
            identityAuth["status"] = [[userInfo objectForKey:@"identityAuthStatus"] UTF8String];
            
            dataJson["identityAuth"] = identityAuth;
            
            GrayN_JSON::Value limit;
            limit["isLimit"] = [[userInfo objectForKey:@"isLimit"] UTF8String];
            limit["limitDesc"] = [[userInfo objectForKey:@"limitDesc"] UTF8String];
            
            dataJson["limit"] = limit;
            
            dataJson["loginType"] = [[userInfo objectForKey:@"loginType"] UTF8String];
            
            dataJson["nickName"] = [[userInfo objectForKey:@"nickName"] UTF8String];
            
            dataJson["originalUserType"] = [[userInfo objectForKey:@"originalUserType"] UTF8String];
            
            dataJson["palmId"] = [[userInfo objectForKey:@"palmId"] UTF8String];
            
            dataJson["phone"] = [[userInfo objectForKey:@"bindPhone"] UTF8String];
            
            dataJson["loginType"] = [[userInfo objectForKey:@"loginType"] UTF8String];
            
            dataJson["returnJson"] = "";
            
            dataJson["userId"] = [[userInfo objectForKey:@"userId"] UTF8String];
            
            dataJson["userName"] = [[userInfo objectForKey:@"userName"] UTF8String];
            
            dataJson["userNameType"] = "";

            dataJson["userPlatformId"] = [[userInfo objectForKey:@"userPlatformId"] UTF8String];
        }
        GrayN_Offical::GetInstance().m_GrayN_Offical_LoginData["userId"] = "";
        tmp_json["data"] = dataJson;

        GrayN_JSON::FastWriter fast_writer;
        string tmp = fast_writer.write(tmp_json);
        
        [GrayN_Tools GrayNsetAutoLoginStatus:YES];
        
        GrayNchannel::GetInstance().GrayN_SetLoginStatus(true);
        [self GrayN_WVC_CloseJSBridgeViewIsForceClose:NO];
        
        GrayNSDK::GrayN_SDK_CallBackLogin(true, tmp.c_str());
    }];
}
/*4.3.7	切换账户页面登录接口*/
- (void)invokeSdkUserLogin
{
    [_bridge registerHandler:@"invokeSdkUserLogin" handler:^(id data, WVJBResponseCallback responseCallback) {
        GrayNcommon::GrayN_DebugLog(@"invokeSdkUserLogin: %@", data);
        
        NSDictionary *userInfo = (NSDictionary*)data;
        NSString *opUserId = [userInfo objectForKey:@"userId"];
        NSString *opUserName = [userInfo objectForKey:@"userName"];

        [[GrayN_Tools share_GrayN] GrayNsetUserInfoResponseCallBack:^(id responseData) {
            GrayNcommon::GrayN_DebugLog(@"invokeSdkUserLoginCallBack:\n%@", responseData);
            responseCallback(responseData);
        }];
        
        GrayN_UserInfo *GrayN_UserInfo_GrayN = [[[GrayN_UserInfo alloc] init] autorelease];
        /* 兼容1.0账号登录
         * 1.有用户ID 优先使用用户ID获取账户信息
         * 2.没有用户ID 使用UserName查找账号信息
         */
        if (![opUserId isEqualToString:@""]) {
            GrayN_UserInfo_GrayN = [GrayN_Tools GrayNloadUserInfoWithUserId:opUserId];
            GrayNcommon::GrayN_DebugLog(@"当前使用用户ID登录:%@", opUserId);
        } else if (![opUserName isEqualToString:@""]) {
            GrayNcommon::GrayN_DebugLog(@"当前使用用户名登录:%@", opUserName);
            GrayN_UserInfo_GrayN = [GrayN_Tools GrayNloadUserInfoWithUserName:opUserName];
        } 

        if ([GrayN_UserInfo_GrayN.loginType rangeOfString:@"speedy"].location != NSNotFound) {
            GrayN_UserCenter::GetInstance().GrayN_UserCenter_SpeedyLogin(false, false);
        } else {
            string userName = [GrayN_UserInfo_GrayN.userName UTF8String];
            string userPwd = [GrayN_UserInfo_GrayN.password UTF8String];
            if ([GrayN_UserInfo_GrayN.currentUserType rangeOfString:@"phone"].
                location != NSNotFound) {
                userName  = [GrayN_UserInfo_GrayN.bindPhone UTF8String];
            }
//            GrayNcommon::GrayN_DebugLog(@"%@",GrayN_UserInfo_GrayN.password);
            GrayN_UserCenter::GetInstance().GrayN_UserCenter_CommonLogin(userName, userPwd, false, false);
        }
    }];
}
/*4.3.8	sessionId的重新初始化接口*/
- (void)invokeSdkReloadSessionId
{
    [_bridge registerHandler:@"invokeSdkReloadSessionId" handler:^(id data, WVJBResponseCallback responseCallback) {
        GrayNcommon::GrayN_DebugLog(@"invokeSdkReloadSessionId: %@", data);
        
        [[GrayN_Tools share_GrayN] GrayNsetGetSessionIdResponseCallback:^(id responseData) {
            GrayNcommon::GrayN_DebugLog(@"invokeSdkReloadSessionId=========\n%@", responseData);
            responseCallback(responseData);
        }];
        GrayN_Offical::GetInstance().GrayN_Offical_GetSessionId();
    }];
}
/*4.3.9 注册成功通知接口*/
- (void)invokeSdkRegisterNotify
{
    [_bridge registerHandler:@"invokeSdkRegisterNotify" handler:^(id data, WVJBResponseCallback responseCallback) {
        GrayNcommon::GrayN_DebugLog(@"invokeSdkRegisterNotify: %@", data);
        NSDictionary *userInfo = (NSDictionary*)data;
        GrayN_UserInfo *GrayN_UserInfo_GrayN = [[[GrayN_UserInfo alloc] init] autorelease];
        [GrayN_UserInfo_GrayN GrayN_SetUserInfo:userInfo];
        /*QQ微博登录需要从returnJson中获取nickName*/
        if ([GrayN_UserInfo_GrayN.returnJson isEqual:[NSNull null]] ||
            GrayN_UserInfo_GrayN.returnJson == nil || [GrayN_UserInfo_GrayN.returnJson isEqual:@""]) {
            GrayN_UserInfo *opTmpUserInfo = [[[GrayN_UserInfo alloc] init] autorelease];
            opTmpUserInfo = [GrayN_Tools GrayNloadUserInfoWithUserId:GrayN_UserInfo_GrayN.userId];
            if (![opTmpUserInfo.userId isEqualToString:@""]) {
                if (opTmpUserInfo.returnJson != nil) {
                    GrayN_UserInfo_GrayN.returnJson = opTmpUserInfo.returnJson;
                    [GrayN_UserInfo_GrayN.GrayN_UserInfo_GrayN setObject:GrayN_UserInfo_GrayN.returnJson forKey:@"returnJson"];
                }
                if (GrayN_UserInfo_GrayN.GrayN_UserInfo_GrayN == nil) {
                    GrayN_UserInfo_GrayN.GrayN_UserInfo_GrayN = opTmpUserInfo.GrayN_UserInfo_GrayN;
                }
            }
        }
        
        GrayNcommon::m_GrayN_Game_UserId = [GrayN_UserInfo_GrayN.userId UTF8String];
        GrayNcommon::m_GrayN_Game_UserName = [GrayN_UserInfo_GrayN.userName UTF8String];
        GrayNcommon::m_GrayN_Game_PhoneNum = [GrayN_UserInfo_GrayN.bindPhone UTF8String];
        GrayNcommon::m_GrayN_Game_Email = [GrayN_UserInfo_GrayN.bindEmail UTF8String];
        GrayNcommon::m_GrayN_Game_PalmId = [GrayN_UserInfo_GrayN.palmId UTF8String];
        GrayNcommon::m_GrayN_LoginType = [GrayN_UserInfo_GrayN.loginType UTF8String];
        GrayNcommon::m_GrayN_CurrentUserType = [GrayN_UserInfo_GrayN.currentUserType UTF8String];
        GrayNcommon::m_GrayN_Game_NickName = [GrayN_UserInfo_GrayN.nickName UTF8String];


        [GrayN_Tools GrayNsaveUserInfo:GrayN_UserInfo_GrayN];
        
        // 发送注册日志
        GrayNSDK::GrayN_SDK_SendUserRegisterLoginLog();
        responseCallback(@"true");
    }];
}
/*4.3.10 通过userName删除用户信息*/
- (void)invokeSdkDelUserByUserName
{
    [_bridge registerHandler:@"invokeSdkDelUserByUserName" handler:^(id data, WVJBResponseCallback responseCallback) {
        GrayNcommon::GrayN_DebugLog(@"invokeSdkDelUserByUserName: %@", data);
        NSDictionary *userInfo = (NSDictionary*)data;
        NSString *userId = [userInfo objectForKey:@"userId"];
        NSString *userName = [userInfo objectForKey:@"userName"];

        [GrayN_Tools GrayNdelUserInfoWithKey:@"userName" value:userName newUserId:userId];
        responseCallback(@"true");
    }];
}
/*4.3.11 第三方SDK登录接口*/
- (void)invokeSdkThirdLogin
{
    [_bridge registerHandler:@"invokeSdkThirdLogin" handler:^(id data, WVJBResponseCallback responseCallback) {
        GrayNcommon::GrayN_DebugLog(@"invokeSdkThirdLogin: %@", data);
        NSDictionary *userInfo = (NSDictionary*)data;
        NSString *userPlatformId = [userInfo objectForKey:@"userPlatformId"];
        
        if ([userPlatformId isEqualToString:@"0329"]) {
                    [[GrayN_GameCenter GrayN_share] GrayN_GC_LoginWithHandler:^(GrayN_GCLoginState bindState, NSDictionary *dic) {
                        GrayNcommon::GrayN_DebugLog(@"GameCenter Login%@", dic);
                        responseCallback(dic);
            
                        switch (bindState) {
                            case GrayN_GCLogin_Success:
            
                                break;
                            case GrayN_GCLogin_Fail:
            
                                break;
                            default:
                                // GrayN_GCLogin_Cancel
                                break;
                        }
                    }];
                    return;
        } else {
            responseCallback(@"false");
        }
        
    }];
}

#pragma mark - 4.4 支付相关接口
/*4.4.1	本地支付请求接口*/
- (void)invokeSdkOpenNativePay
{
    [_bridge registerHandler:@"invokeSdkOpenNativePay" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSString *strData = [NSString stringWithFormat:@"%@", data];
        strData = [GrayN_Tools GrayNdesDecodeString:strData];
        GrayNcommon::GrayN_DebugLog(@"invokeSdkOpenNativePay: %@", strData);

        GrayN_JSON::Value json_object;
        GrayN_JSON::Reader    json_reader;
        if (!json_reader.parse([strData UTF8String], json_object)) {
            GrayNcommon::GrayN_ConsoleLog(@"invokeSdkOpenNativePay支付JSON解析错误");
            return ;
        }
        GrayN_JSON::Value payData = json_object["data"];
        
        NSString *driverid = [NSString stringWithUTF8String: json_object["driverid"].asString().c_str()];
        
        if ([driverid isEqualToString:@"2105440001120000"]) {
            NSString *mweb_url = [NSString stringWithUTF8String:payData["mweb_url"].asString().c_str()];
            NSString *Referer = [NSString stringWithUTF8String: payData["Referer"].asString().c_str()];
            //mweb_url = @"https://wx.tenpay.com/cgi-bin/mmpayweb-bin/checkmweb?prepay_id=wx1618191733399539b671f6d81524050424&package=1655766282";
            //Referer= @"http://auth.gamebean.com";
            
            NSOperationQueue * queue = [[[NSOperationQueue alloc] init] autorelease];
            
            NSMutableURLRequest *request = [NSMutableURLRequest
                                            requestWithURL:[NSURL URLWithString:[mweb_url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]
                                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                                            timeoutInterval:30.0f];
            [request setValue:Referer forHTTPHeaderField:@"Referer"];
            request.HTTPMethod = @"POST";
            
            [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                
                NSString *dataStr = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    GrayNpayCenter::GetInstance().GrayN_Pay_GetH5Deeplink(GrayNpayCenter::GetInstance().m_GrayN_Pay_SSID.c_str(), [dataStr UTF8String]);
                    [[GrayN_Tools share_GrayN] GrayNsetDeeplinkResponseCallBack:^(id responseData) {
                        NSString *deepLink = (NSString *)responseData;
                        GrayNcommon::GrayN_DebugLog(@"opWXDeeplink:%@", deepLink);
                        NSURL *deepLinkUrl = [NSURL URLWithString:deepLink];
                        if ([[UIApplication sharedApplication] canOpenURL:deepLinkUrl]) {
                            [[UIApplication sharedApplication] openURL:deepLinkUrl];
                            [self GrayN_WVC_CloseJSBridgeViewIsForceClose:NO];
                            GrayNpayCenter::GetInstance().m_GrayN_Pay_IsPurchasing = true;
                            responseCallback(@"true");
                        } else {
                            // 需要关掉界面 因为页面其他计费方式无法再点击
                            [self GrayN_WVC_CloseJSBridgeViewIsForceClose:NO];
                            GrayN_Offical::GetInstance().GrayN_Offical_ShowToast("您未安装微信客户端，请安装后重试", YES);
                            responseCallback(@"false");
                        }
                    }];
                });
            }];
            //            [self weixinGetDeepLinkWithReferer:Referer url:mweb_url];
        } else if ([driverid isEqualToString:@"2103910000140134"]) {
//            NSString *alipayData = [NSString stringWithUTF8String:payData["alipayData"].asString().c_str()];
//            BOOL canOpenAlipay = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"alipay://"]];
            //            [OPAlipay aliPay:alipayData];
            
            /*支付宝支付*/
//            [[GrayN_ChannelSDK GrayN_Share] iapWithAliPay:alipayData];
            
//            if (canOpenAlipay) {
//                GrayNpayCenter::GetInstance().m_GrayN_Pay_IsPurchasing = true;
//            } else {
//                GrayNpayCenter::GetInstance().m_GrayN_Pay_IsPurchasing = false;
//            }
            //            GrayNcommon::GrayN_DebugLog(@"=========%d",canOpenAlipay);
            [[GrayN_BaseControl GrayN_Share] GrayNcloseJSBridgeView];
            
            responseCallback(@"true");
        } else if ([driverid isEqualToString:@"2105440003120000"]) {
//            NSString *deepLink = [NSString stringWithUTF8String:payData["protocolUrl"].asString().c_str()];
//            GrayNcommon::GrayN_DebugLog(@"%@", deepLink);
//            NSURL *deepLinkUrl = [NSURL URLWithString:deepLink];
//            if ([[UIApplication sharedApplication] canOpenURL:deepLinkUrl]) {
//                [[UIApplication sharedApplication] openURL:deepLinkUrl];
                [self GrayN_WVC_CloseJSBridgeViewIsForceClose:NO];
                GrayNpayCenter::GetInstance().m_GrayN_Pay_IsPurchasing = true;
                responseCallback(@"true");
//            } else {
//                [self GrayN_WVC_CloseJSBridgeViewIsForceClose:NO];
//                GrayN_Offical::GetInstance().GrayN_Offical_ShowToast("您未安装QQ客户端，请安装后重试", YES);
//                responseCallback(@"false");
//            }
        } else if ([driverid isEqualToString:@"2110980000120000"]) {
//            NSString *jd_orderId = [NSString stringWithUTF8String:payData["jd_orderId"].asString().c_str()];
//            NSString *appId = [NSString stringWithUTF8String:payData["appId"].asString().c_str()];
//            NSString *merchant = [NSString stringWithUTF8String:payData["merchant"].asString().c_str()];
//            NSString *signData = [NSString stringWithUTF8String:payData["signData"].asString().c_str()];
//            NSMutableDictionary *dic = [[[NSMutableDictionary alloc] init] autorelease];
//            [dic setObject:jd_orderId forKey:@"jd_orderId"];
//            [dic setObject:appId forKey:@"appId"];
//            [dic setObject:merchant forKey:@"merchant"];
//            [dic setObject:signData forKey:@"signData"];

//            BOOL canOpenAlipay = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"alipay://"]];
            //            [OPAlipay aliPay:alipayData];
            
            /*京东支付*/
//            [[GrayN_ChannelSDK GrayN_Share] iapWithChannel:@"JDPay" andInfos:dic];
            
//            if (canOpenAlipay) {
//                GrayNpayCenter::GetInstance().m_GrayN_Pay_IsPurchasing = true;
//            } else {
                GrayNpayCenter::GetInstance().m_GrayN_Pay_IsPurchasing = false;
//            }
            //            GrayNcommon::GrayN_DebugLog(@"=========%d",canOpenAlipay);
            [[GrayN_BaseControl GrayN_Share] GrayNcloseJSBridgeView];
            
            responseCallback(@"true");

        }
    }];
}
/*4.4.2	获取当前下单的订单信息*/
- (void)invokeSdkGetOrderInfo
{
    [_bridge registerHandler:@"invokeSdkGetOrderInfo" handler:^(id data, WVJBResponseCallback responseCallback) {
        GrayNcommon::GrayN_DebugLog(@"invokeSdkGetOrderInfo: %@", data);
        
        string orderId = GrayNpayCenter::GetInstance().m_GrayN_Pay_SSID;
        string propName = GrayNpayCenter::GetInstance().m_GrayN_Pay_ProductName;
        NSString *orderIdStr = [NSString stringWithUTF8String:orderId.c_str()];
        NSString *propNameStr = [NSString stringWithUTF8String:propName.c_str()];
        NSString *price = [NSString stringWithUTF8String:GrayNpayCenter::GetInstance().m_GrayN_Pay_Price.c_str()];
        NSString *propCount= [NSString stringWithUTF8String:GrayNpayCenter::GetInstance().m_GrayN_Pay_ProductNum.c_str()];
        NSMutableDictionary *orderInfo = [[[NSMutableDictionary alloc] init] autorelease];
        [orderInfo setObject:orderIdStr forKey:@"orderId"];
        [orderInfo setObject:propNameStr forKey:@"goodsName"];
        [orderInfo setObject:price forKey:@"cost"];
        [orderInfo setObject:@"1" forKey:@"currency"];
        [orderInfo setObject:propCount forKey:@"propCount"];


        GrayNcommon::GrayN_DebugLog(@"orderInfo: %@", orderInfo);

        NSString *dataStr = [GrayN_Tools GrayNdictionaryToJsonString:orderInfo];
        
        responseCallback(dataStr);
    }];
}
/*4.4.3	支付结果通知接口*/
- (void)invokeSdkPayResult
{
    [_bridge registerHandler:@"invokeSdkPayResult" handler:^(id data, WVJBResponseCallback responseCallback) {
        GrayNcommon::GrayN_DebugLog(@"invokeSdkPayResult: %@", data);
        NSDictionary *result = (NSDictionary *)data;
        BOOL payResult = ![[result objectForKey:@"payResult"] boolValue];
        NSString *desc = [GrayN_Tools GrayNgetStrForCMS:[result objectForKey:@"desc"]];
        NSString *reset = [GrayN_Tools GrayNgetStrForCMS:[result objectForKey:@"reset"]];

        GrayN_JSON::Value errJson;
        errJson["propId"] = GrayN_JSON::Value(GrayNpayCenter::GetInstance().m_GrayN_Pay_ProductId);
        errJson["reset"] = GrayN_JSON::Value([reset UTF8String]);
        errJson["desc"] = GrayN_JSON::Value([desc UTF8String]);
        errJson["ssId"] = GrayN_JSON::Value(GrayNpayCenter::GetInstance().m_GrayN_Pay_SSID);
        GrayN_JSON::FastWriter fast_writer;
        string resultStr = fast_writer.write(errJson);
        
        GrayNSDK::GrayN_SDK_OnPurchaseResult(payResult, resultStr.c_str());
        responseCallback(@"ture");
    }];
}
#pragma mark - 4.5 用户中心相关接口
/*4.5.1 用户中心-升级账户通知接口*/
- (void)invokeSdkUserUpgradeNotify
{
    [_bridge registerHandler:@"invokeSdkUserUpgradeNotify" handler:^(id data, WVJBResponseCallback responseCallback) {
        GrayNcommon::GrayN_DebugLog(@"invokeSdkUserUpgradeNotify: %@", data);
        
        NSDictionary *newUserInfo = (NSDictionary*)data;
        NSString *userId = [newUserInfo objectForKey:@"userId"];
        NSString *key1 = @"userName";
        NSString *value1 = [newUserInfo objectForKey:key1];
        NSString *key2 = @"password";
        NSString *value2 = [newUserInfo objectForKey:key2];
        // 特殊处理保留原始用户密码
        if ([value2 isEqualToString:@""]) {
            GrayN_UserInfo *tmpUserInfo = [GrayN_Tools GrayNloadUserInfoWithUserId:userId];
            GrayNcommon::GrayN_DebugLog(@"当前新密码: %@", tmpUserInfo.password);
            value2 = tmpUserInfo.password;
        }
        NSString *key3 = @"loginType";
        NSString *value3 = [newUserInfo objectForKey:key3];
        NSString *key4 = @"originalUserType";
        NSString *value4 = [newUserInfo objectForKey:key4];
        NSString *key5 = @"currentUserType";
        NSString *value5 = [newUserInfo objectForKey:key5];
        
        NSMutableArray *object = [[[NSMutableArray alloc] init] autorelease];
        [object addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                           key1, @"key",value1, @"value",nil]];
        [object addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                           key2, @"key",value2, @"value",nil]];
        [object addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                           key3, @"key",value3, @"value",nil]];
        [object addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                           key4, @"key",value4, @"value",nil]];
        [object addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                           key5, @"key",value5, @"value",nil]];
        //        GrayNcommon::GrayN_DebugLog(@"%@", object);
        if ([GrayN_Tools GrayNmodifyUserInfoWithUserId:userId
                             objectBeModfied:object]) {
            GrayNcommon::m_GrayN_CurrentUserType = [value5 UTF8String];
            responseCallback(@"true");
        } else {
            responseCallback(@"false");
        }
    }];
}
/*4.5.2	用户中心-绑定手机邮箱通知接口*/
- (void)invokeSdkUserBindNotify
{
    [_bridge registerHandler:@"invokeSdkUserBindNotify" handler:^(id data, WVJBResponseCallback responseCallback) {
        GrayNcommon::GrayN_DebugLog(@"invokeSdkUserBindNotify: %@", data);
        
        NSDictionary *newUserInfo = (NSDictionary*)data;
        NSString *userId = [newUserInfo objectForKey:@"userId"];
        NSString *key1 = @"bindPhone";
        NSString *value1 = [newUserInfo objectForKey:key1];
        NSString *key2 = @"bindEmail";
        NSString *value2 = [newUserInfo objectForKey:key2];
        
        NSMutableArray *object = [[[NSMutableArray alloc] init] autorelease];
        [object addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                           key1, @"key",value1, @"value",nil]];
        [object addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                           key2, @"key",value2, @"value",nil]];
        
        if ([GrayN_Tools GrayNmodifyUserInfoWithUserId:userId
                             objectBeModfied:object]) {
            responseCallback(@"true");
        } else {
            responseCallback(@"false");
        }
    }];
}
/*4.5.3	用户中心-修改密码通知接口*/
- (void)invokeSdkUserModifyPasswordNotify
{
    [_bridge registerHandler:@"invokeSdkUserModifyPasswordNotify" handler:^(id data, WVJBResponseCallback responseCallback) {
        GrayNcommon::GrayN_DebugLog(@"invokeSdkUserModifyPasswordNotify: %@", data);
        
        NSDictionary *newUserInfo = (NSDictionary*)data;
        NSString *userId = [newUserInfo objectForKey:@"userId"];
        NSString *key = @"password";
        NSString *value = [newUserInfo objectForKey:key];
        
        NSMutableArray *object = [[[NSMutableArray alloc] init] autorelease];
        [object addObject:[NSDictionary dictionaryWithObjectsAndKeys:key, @"key",
                           value, @"value",nil]];
        
        if ([GrayN_Tools GrayNmodifyUserInfoWithUserId:userId
                             objectBeModfied:object]) {
            responseCallback(@"true");
        } else {
            responseCallback(@"false");
        }
    }];
}
/*4.5.4 用户中心-修改昵称回调接口*/
- (void)invokeSdkUserModifyNickNameNotify
{
    [_bridge registerHandler:@"invokeSdkUserModifyNickNameNotify" handler:^(id data, WVJBResponseCallback responseCallback) {
        GrayNcommon::GrayN_DebugLog(@"invokeSdkUserModifyNickNameNotify: %@", data);
        
        NSDictionary *newUserInfo = (NSDictionary*)data;
        NSString *userId = [newUserInfo objectForKey:@"userId"];
        NSString *key = @"nickName";
        NSString *value = [newUserInfo objectForKey:key];
        
        NSMutableArray *object = [[[NSMutableArray alloc] init] autorelease];
        [object addObject:[NSDictionary dictionaryWithObjectsAndKeys:key, @"key",
                           value, @"value",nil]];
        
        if ([GrayN_Tools GrayNmodifyUserInfoWithUserId:userId
                             objectBeModfied:object]) {
            responseCallback(@"true");
        } else {
            responseCallback(@"false");
        }
    }];
}
/*4.5.5 用户中心-解绑手机邮箱通知接口*/
- (void)invokeSdkUserUnBindNotify
{
    [_bridge registerHandler:@"invokeSdkUserUnBindNotify" handler:^(id data, WVJBResponseCallback responseCallback) {
        GrayNcommon::GrayN_DebugLog(@"invokeSdkUserUnBindNotify: %@", data);
        
        NSDictionary *newUserInfo = (NSDictionary*)data;
        NSString *userId = [newUserInfo objectForKey:@"userId"];
        NSString *key = @"unBindType";
        NSString *value = [newUserInfo objectForKey:key];
        if ([value isEqualToString:@"phone"]) {
            key = @"bindPhone";
            value = @"";
        } else if ([value isEqualToString:@"email"]) {
            key = @"bindEmail";
            value = @"";
        } else {
            GrayNcommon::GrayN_DebugLog(@"解绑失败，key值=%@", key);
            responseCallback(@"false");
            return;
        }
        NSMutableArray *object = [[[NSMutableArray alloc] init] autorelease];
        [object addObject:[NSDictionary dictionaryWithObjectsAndKeys:key, @"key",
                           value, @"value",nil]];
        
        if ([GrayN_Tools GrayNmodifyUserInfoWithUserId:userId
                             objectBeModfied:object]) {
            responseCallback(@"true");
        } else {
            responseCallback(@"false");
        }
    }];
}
/*4.5.6 实名认证成功后通知sdk的接口*/
- (void)invokeSdkIdentityAuthBindNotify
{
    [_bridge registerHandler:@"invokeSdkIdentityAuthBindNotify" handler:^(id data, WVJBResponseCallback responseCallback) {
        GrayNcommon::GrayN_DebugLog(@"invokeSdkIdentityAuthBindNotify: %@", data);
        
        NSDictionary *newUserInfo = (NSDictionary*)data;
        NSString *userId = [newUserInfo objectForKey:@"userId"];
        // 0：未验证；1：验证中；2：验证成功；-1：验证失败；
        NSString *key1 = @"identityAuthStatus";
        NSString *value1 = [newUserInfo objectForKey:key1];
        /*5.1.4*/
        GrayNSDK::m_GrayN_SDK_IdentityStatus = [value1 UTF8String];

        NSString *key2 = @"identityAuthIdNum";
        NSString *value2 = [newUserInfo objectForKey:key2];
        NSString *key3 = @"identityAuthRealName";
        NSString *value3 = [newUserInfo objectForKey:key3];
        NSMutableArray *object = [[[NSMutableArray alloc] init] autorelease];
        [object addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                           key1, @"key", value1, @"value",nil]];
        [object addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                           key2, @"key", value2, @"value",nil]];
        [object addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                           key3, @"key", value3, @"value",nil]];
        
        if ([GrayN_Tools GrayNmodifyUserInfoWithUserId:userId
                             objectBeModfied:object]) {
            responseCallback(@"true");
        } else {
            responseCallback(@"false");
        }
    }];
}
/*4.5.7	用户中心-注销接口*/
- (void)invokeSdkLogOut
{
    [_bridge registerHandler:@"invokeSdkLogOut" handler:^(id data, WVJBResponseCallback responseCallback) {
        GrayNcommon::GrayN_DebugLog(@"invokeSdkLogOut: %@", data);
        
        GrayN_Offical::GetInstance().GrayN_Offical_Logout();
        responseCallback(@"true");
    }];
}
/*4.5.8	用户中心-切换账号接口*/
- (void)invokeSdkSwitchAccount
{
    [_bridge registerHandler:@"invokeSdkSwitchAccount" handler:^(id data, WVJBResponseCallback responseCallback) {
        GrayNcommon::GrayN_DebugLog(@"invokeSdkSwitchAccount: %@", data);
        
        GrayN_Offical::GetInstance().GrayN_Offical_SwitchAccount();

        responseCallback(@"true");
    }];
}
/*4.5.8	用户中心-用户未读消息通知接口*/
- (void)invokeSdkUnreadMessageStatus
{
    [_bridge registerHandler:@"invokeSdkUnreadMessageStatus" handler:^(id data, WVJBResponseCallback responseCallback) {
        GrayNcommon::GrayN_DebugLog(@"invokeSdkUnreadMessageStatus: %@", data);
//        NSString *messageType = [data objectForKey:@"messageType"];
//        NSString *status = [data objectForKey:@"status"];
        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            NSMutableDictionary *dic = [[[NSMutableDictionary alloc] init] autorelease];
//            [dic setObject:status forKey:messageType];
//            GrayNcommon::GrayN_DebugLog(@"小红点：\n%@", dic);
//            [GrayN_Tools controlRedPoint:dic];
//        });
        
        responseCallback(@"true");
    }];
}

#pragma mark - 4.6 客服相关接口
/*4.6.1	图片压缩上传接口*/
- (void)invokeSdkUploadImg
{
    [_bridge registerHandler:@"invokeSdkUploadImg" handler:^(id data, WVJBResponseCallback responseCallback) {
        
        GrayNcommon::GrayN_DebugLog(@"invokeSdkUploadImg: %@", data);
        
        NSDictionary *result = (NSDictionary *)data;
        
        [[GrayNcustomService_Control GrayNshare] GrayNcustomServiceSdkUploadImg:[result objectForKey:@"uploadurl"]
                                           withLimitSize:[result objectForKey:@"filesize"] handler:^(id responseData) {
                                               NSString *dataStr = [GrayN_Tools GrayNdictionaryToJsonString:responseData];
                                               responseCallback(dataStr);
                                               GrayNcommon::GrayN_DebugLog(@"responseData: %@", dataStr);
                                           }];
    }];
}
#pragma mark - JSBridge初始化
- (void)GrayN_WVC_InitJSBridge
{
    NSMutableDictionary *userInfo = [[[NSMutableDictionary alloc] init] autorelease];
    // initData
    [userInfo setObject:[NSString stringWithUTF8String:GrayNSDK::m_GrayN_SDK_InitJson.c_str()] forKey:@"initData"];
    
    // functionData
    NSMutableArray *funcNames = [[[NSMutableArray alloc] init] autorelease];
    [funcNames addObject:@"invokeSdkEncryptData"];
    [funcNames addObject:@"invokeSdkDecodeData"];
    [funcNames addObject:@"invokeSdkCloseWebiew"];
    [funcNames addObject:@"invokeSdkCloseWebview"];
    [funcNames addObject:@"invokeSdkNativeToast"];
    [funcNames addObject:@"invokeSdkClipboardCopy"];
    [funcNames addObject:@"invokeSdkOpenBrowser"];
    [funcNames addObject:@"invokeSdkOpenKeyboard"];
    [funcNames addObject:@"invokeSdkCloseKeyboard"];
    [funcNames addObject:@"invokeSdkClearAppcache"];
    [funcNames addObject:@"invokeSdkWebviewBack"];
    [funcNames addObject:@"invokeSdkPrintConsole"];
    [funcNames addObject:@"invokeSdkPageLoadNotify"];
    [funcNames addObject:@"invokeSdkGetStaticSource"];
    [funcNames addObject:@"invokeSdkOpenWebview"];
    [funcNames addObject:@"invokeSdkGetPromptInfo"];
    [funcNames addObject:@"invokeSdkSetUpdatePrompt"];
    [funcNames addObject:@"invokeSdkActivateNotify"];
    [funcNames addObject:@"invokeSdkGetActivateInfo"];
    [funcNames addObject:@"invokeSdkDownloadGame"];
    [funcNames addObject:@"invokeSdkQuitApp"];
    [funcNames addObject:@"invokeSdkGetLoginedUsers"];
    [funcNames addObject:@"invokeSdkGetCurrentUser"];
    [funcNames addObject:@"invokeSdkDelUser"];
    [funcNames addObject:@"invokeSdkGetFastLoginDeviceId"];
    [funcNames addObject:@"invokeSdkLoginFinished"];
    [funcNames addObject:@"invokeSdkUserLogin"];
    [funcNames addObject:@"invokeSdkReloadSessionId"];
    [funcNames addObject:@"invokeSdkRegisterNotify"];
    [funcNames addObject:@"invokeSdkDelUserByUserName"];
    [funcNames addObject:@"invokeSdkOpenNativePay"];
    [funcNames addObject:@"invokeSdkGetOrderInfo"];
    [funcNames addObject:@"invokeSdkPayResult"];
    [funcNames addObject:@"invokeSdkUserUpgradeNotify"];
    [funcNames addObject:@"invokeSdkUserBindNotify"];
    [funcNames addObject:@"invokeSdkUserModifyPasswordNotify"];
    [funcNames addObject:@"invokeSdkUserModifyNickNameNotify"];
    [funcNames addObject:@"invokeSdkUserUnBindNotify"];
    [funcNames addObject:@"invokeSdkIdentityAuthBindNotify"];
    [funcNames addObject:@"invokeSdkLogOut"];
    [funcNames addObject:@"invokeSdkSwitchAccount"];
    [funcNames addObject:@"invokeSdkUnreadMessageStatus"];

    [funcNames addObject:@"invokeSdkUploadImg"];
    [funcNames addObject:@"invokeSdkThirdLogin"];

    
    [userInfo setObject:funcNames forKey:@"functionData"];
    
    NSMutableDictionary *sdkData = [[[NSMutableDictionary alloc] init] autorelease];
    [sdkData setObject:@"1" forKey:@"devicePlatformId"];
    
    [sdkData setObject:[NSString stringWithUTF8String:GrayNcommon::m_GrayN_OPID.c_str()] forKey:@"opid"];
    [sdkData setObject:@"" forKey:@"advertising_id"];
    
    [sdkData setObject:[NSString stringWithUTF8String:GrayNcommon::m_GrayN_ServiceId.c_str()] forKey:@"oService"];
    [sdkData setObject:[NSString stringWithUTF8String:GrayNcommon::m_GrayN_DeviceGroupId.c_str()] forKey:@"deviceGroupId"];
    [sdkData setObject:[NSString stringWithUTF8String:GrayNcommon::m_GrayN_LocaleId.c_str()] forKey:@"localeId"];
    [sdkData setObject:[NSString stringWithUTF8String:GrayNcommon::m_GrayN_ChannelId.c_str()] forKey:@"oChannel"];

    string version = GrayNcommon::m_GrayN_SDKVersion;
    version.append("|");
    version.append(GrayNcommon::m_GrayN_GameVersion);
    version.append("|");
    version.append(GrayNcommon::m_GrayN_GameResVersion);
    [sdkData setObject:[NSString stringWithUTF8String:version.c_str()] forKey:@"version"];
    
    [sdkData setObject:@"1" forKey:@"gameType"];
    
    string m_GrayN_SDK_UserCenterEntryUrl = GrayNSDK::m_GrayN_SDK_UserCenterEntryUrl;
    string m_GrayN_SDK_UserCenterCoreUrl = GrayNSDK::m_GrayN_SDK_UserCenterCoreUrl;
    string m_GrayN_SDK_BillingDomainName = GrayNSDK::m_GrayN_SDK_BillingDomainName;
    
    if (!GrayN_Offical::GetInstance().m_GrayN_Offical_IsHttp) {
        GrayNcommon::GrayNstringReplace(m_GrayN_SDK_UserCenterEntryUrl, "http://", "https://");
        GrayNcommon::GrayNstringReplace(m_GrayN_SDK_UserCenterCoreUrl, "http://", "https://");
        GrayNcommon::GrayNstringReplace(m_GrayN_SDK_BillingDomainName, "http://", "https://");
    }

    [sdkData setObject:[NSString stringWithUTF8String:m_GrayN_SDK_UserCenterEntryUrl.c_str()] forKey:@"ucenterEntryUrl"];
    [sdkData setObject:[NSString stringWithUTF8String:m_GrayN_SDK_UserCenterCoreUrl.c_str()] forKey:@"ucenterCoreUrl"];
    [sdkData setObject:[NSString stringWithUTF8String:m_GrayN_SDK_BillingDomainName.c_str()] forKey:@"bcenterUrl"];
    [sdkData setObject:[NSString stringWithUTF8String:GrayNcommon::m_GrayN_StatisticalUrl.c_str()] forKey:@"statisUrl"];
    [sdkData setObject:[NSString stringWithFormat:@"%d",GrayNSDK::m_GrayN_SDK_LogSwitch] forKey:@"sdkLogSwitch"];
    [sdkData setObject:[NSString stringWithFormat:@"%d",GrayNSDK::m_GrayN_SDK_ProtocolSwitch] forKey:@"protocolSwitch"];
    [sdkData setObject:[NSString stringWithUTF8String:GrayNSDK::m_GrayN_SDK_GscFrontUrl.c_str()] forKey:@"gscFrontUrl"];
    [sdkData setObject:[NSString stringWithUTF8String:GrayNcommon::m_GrayN_PushServerUrl.c_str()] forKey:@"pushServerUrl"];
    [sdkData setObject:[NSString stringWithUTF8String:GrayNSDK::m_GrayN_SDK_IdentityAuth.c_str()] forKey:@"identityAuth"];
    [sdkData setObject:@"0" forKey:@"actionId"];
    [sdkData setObject:[NSString stringWithUTF8String:GrayNcommon::GrayNgetCurrentDeviceLang().c_str()] forKey:@"nativeLanguage"];
    [sdkData setObject:[NSString stringWithUTF8String:GrayNcommon::m_GrayN_Screen_Orientation.c_str()] forKey:@"screenOrientation"];
    [sdkData setObject:[NSString stringWithFormat:@"%d", 0] forKey:@"forceBindUIShowSwitch"];
    [sdkData setObject:[NSString stringWithFormat:@"%d",GrayNSDK::m_GrayN_SDK_SandBoxSwitch] forKey:@"sandBoxSwitch"];
    [sdkData setObject:[NSString stringWithFormat:@"%d",GrayNSDK::m_GrayN_SDK_ForceTouristBindSwitch] forKey:@"forceTouristBindSwitch"];
    /*5.1.4*/
    [sdkData setObject:[NSString stringWithUTF8String:GrayNSDK::m_GrayN_SDK_PayIdentityAuth.c_str()] forKey:@"forceIdentityAuthBindSwitch"];

    if (GrayN_Offical::GetInstance().m_GrayN_Offical_IsLocalRequest) {
        [sdkData setObject:@"local" forKey:@"pageFrom"];
    } else {
        [sdkData setObject:@"server" forKey:@"pageFrom"];
    }

    if (GrayNcommon::m_GrayNdebug_Mode) {
        [sdkData setObject:@"true" forKey:@"debug"];
    } else {
        [sdkData setObject:@"false" forKey:@"debug"];
    }
    
    [userInfo setObject:sdkData forKey:@"sdkData"];
    
    NSMutableDictionary *userData = [[[NSMutableDictionary alloc] init] autorelease];
    NSString *sessionId = [GrayN_Tools GrayNgetStrForCMS:GrayNcommon::m_GrayN_SessionId base64UrlEncode:NO];
    [userData setObject:sessionId forKey:@"sessionId"];
    NSString *oUser = [GrayN_Tools GrayNgetStrForCMS:GrayNcommon::m_GrayN_Game_UserId base64UrlEncode:YES];
    [userData setObject:oUser forKey:@"oUser"];
    NSString *userName = [GrayN_Tools GrayNgetStrForCMS:GrayNcommon::m_GrayN_Game_UserName base64UrlEncode:YES];
    [userData setObject:userName forKey:@"userName"];
    NSString *palmId = [GrayN_Tools GrayNgetStrForCMS:GrayNcommon::m_GrayN_Game_PalmId base64UrlEncode:YES];
    [userData setObject:palmId forKey:@"palmId"];
    NSString *userPhone = [GrayN_Tools GrayNgetStrForCMS:GrayNcommon::m_GrayN_Game_PhoneNum base64UrlEncode:YES];
    [userData setObject:userPhone forKey:@"userPhone"];
    NSString *userEmail = [GrayN_Tools GrayNgetStrForCMS:GrayNcommon::m_GrayN_Game_Email base64UrlEncode:YES];
    [userData setObject:userEmail forKey:@"userEmail"];
    [userInfo setObject:userData forKey:@"userData"];
    
    NSMutableDictionary *gameData = [[[NSMutableDictionary alloc] init] autorelease];
    
    NSString* gameName = [GrayN_Tools GrayNgetStrForCMS:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"]];
    [gameData setObject:gameName forKey:@"gameName"];
    NSString *oServer = [GrayN_Tools GrayNgetStrForCMS:GrayNcommon::m_GrayN_Game_ServerId base64UrlEncode:NO];
    [gameData setObject:oServer forKey:@"oServer"];
    NSString *oRole = [GrayN_Tools GrayNgetStrForCMS:GrayNcommon::m_GrayN_Game_RoleId base64UrlEncode:NO];
    [gameData setObject:oRole forKey:@"oRole"];
    [gameData setObject:[NSString stringWithUTF8String:GrayNcommon::m_GrayN_Game_RoleName.c_str()] forKey:@"oRoleName"];
    [userInfo setObject:gameData forKey:@"gameData"];
    
    NSMutableDictionary *deviceData = [[[NSMutableDictionary alloc] init] autorelease];
    NSString *macStr = [NSString stringWithUTF8String:GrayNcommon::m_GrayN_MAC_Address.c_str()];
    NSString *idfaStr = [NSString stringWithUTF8String:GrayNcommon::m_GrayN_IDFA.c_str()];
    NSString *deviceUniqueIDStr = [NSString stringWithUTF8String:GrayNcommon::m_GrayN_Device_UniqueId.c_str()];
    NSString *device_IDFV = [NSString stringWithUTF8String:GrayNcommon::m_GrayN_IDFV.c_str()];
    
    NSString *deviceObj = [NSString stringWithFormat:@"%@|%@|%@",
                           [macStr isEqualToString:@""]?@"0":macStr,
                           [idfaStr isEqualToString:@""]?@"0":idfaStr,
                           [deviceUniqueIDStr isEqualToString:@""]?@"0":deviceUniqueIDStr];
    [deviceData setObject:deviceObj forKey:@"device"];
    [deviceData setObject:[NSString stringWithUTF8String:GrayNcommon::m_GrayN_IMEI.c_str()] forKey:@"deviceIM"];
    [deviceData setObject:[NSString stringWithUTF8String:GrayNcommon::m_GrayNnetworkTypeNum.c_str()] forKey:@"workNetType"];
    [deviceData setObject:[NSString stringWithUTF8String:GrayNcommon::m_GrayNnetworkSubType.c_str()] forKey:@"networkSubType"];
    [deviceData setObject:[NSString stringWithUTF8String:GrayNcommon::m_GrayN_Oua.c_str()] forKey:@"oUa"];
    [deviceData setObject:macStr forKey:@"mac"];
    [deviceData setObject:idfaStr forKey:@"idfa"];
    [deviceData setObject:deviceUniqueIDStr forKey:@"deviceUniqueId"];
    [deviceData setObject:device_IDFV forKey:@"device_IDFV"];

    [userInfo setObject:deviceData forKey:@"deviceData"];
    
    NSString *dataStr = [GrayN_Tools GrayNdictionaryToJsonString:userInfo];
    
    
    GrayNcommon::GrayN_DebugLog(@"initJSBridge\n%@", dataStr);
    
    [_bridge callHandler:@"pageInit" data:dataStr responseCallback:^(id response) {
        
        GrayNcommon::GrayN_DebugLog(@"testJavascriptHandler responded: %@", response);
    }];
}
- (void)GrayN_WVC_ShowJSBridgeView:(NSString *)url
{

    
    [_bridge GrayNsetShowNavbar:NO];

    GrayNcommon::GrayN_DebugLog(@"GrayNshowJSBridgeView====%@",url);
    
    url = [url stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSURL *baseURL = [NSURL URLWithString:url];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:baseURL];
    [request setHTTPMethod:@"GET"];
    // ssl不验证
//    [NSURLConnection connectionWithRequest:request delegate:_bridge];
//    NSString* htmlPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"OurSDK_res.bundle/images/113.txt"];
//    NSData *img = [NSData dataWithContentsOfFile:htmlPath];
//    NSString *tmp = [img base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
//    
//    NSLog(@"+++++++++%@",tmp);
//    NSString *stri = [[NSString alloc] initWithData:img encoding:NSUTF8StringEncoding];
//    NSLog(@"txtxtxtxt=%@",stri);
//    
//
//    NSString *base64Tmp = [GrayNbaseSDK EncodeBase64:stri];
////    NSLog(@"~~~~~~~~~%@",base64Tmp);
//  
//    NSLog(@"~~~~~~~~~%@",base64Tmp);

    if (_bridge == nil) {
        [self viewWillAppear:YES];
    }
    p_GrayN_WVC_JSBridgeUrl = [url UTF8String];
    [_bridge setJsBridgeRequest:request];
    [p_GrayN_WVC_WebView loadRequest:request];
    
    GrayN_LoadingUI::GetInstance().GrayN_ShowWaitMainThread(GrayNcommon::GrayNcommonGetLocalLang(GrayN_WaitingString));
    [_bridge GrayNreshapeWebview];

}
- (void)GrayN_WVC_ShowJSBridgeViewWithNavBar:(NSString *)url
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[GrayN_BaseControl GrayN_Share] GrayNshowJSBridgeView:url];

        p_GrayN_WVC_IsOpenAllOrientation = YES;
        [_bridge GrayNsetShowNavbar:YES];
        [_bridge GrayNsetsetTopbarUp:NO];
    });
}
- (void)GrayN_WVC_ShowLocalBridgeView:(NSString *)url
{
    
    [_bridge GrayNsetShowNavbar:NO];

    if (_bridge == nil) {
        [self viewWillAppear:YES];
    }
    
//    NSString* htmlPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"OurSDK_res.bundle/jsBridge/index.html"];
//    NSString* appHtml = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];

//    htmlPath = [NSString stringWithFormat:@"file://%@%@", htmlPath, url];
//    NSURL *baseURL = [NSURL URLWithString:htmlPath];
    
//    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:baseURL];
//    NSString * from = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"OurSDK_res.bundle/jsBridge"];
//    NSString * to = [[NSURL fileURLWithPath:NSTemporaryDirectory()] URLByAppendingPathComponent:@"jsBridge"].absoluteString;
    
//    [self copyFileFromPath:from  toPath:to];
//    [p_GrayN_WVC_WebView loadRequest:request];
//    [p_GrayN_WVC_WebView loadHTMLString:appHtml baseURL:baseURL];
//     3.加载文件
//    [p_GrayN_WVC_WebView loadFileURL:baseURL allowingReadAccessToURL:baseURL];
    
    
//    NSURL *fileURL = [GrayN_WebViewController fileURLForBuggyWKWebView8:baseURL];
//    [request setHTTPMethod:@"GET"];
    
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
    NSString *path =  [self GrayNcreateFileUrlHelper:[self GrayNcopyBundle:[self GrayNtmpFolderPath]]];
//    NSLog(@"htmlPath=%@", path);

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"file://%@%@", path, url]]];

//    [_bridge setJsBridgeRequest:request];
    [p_GrayN_WVC_WebView loadRequest:request];

    GrayN_LoadingUI::GetInstance().GrayN_ShowWaitMainThread(GrayNcommon::GrayNcommonGetLocalLang(GrayN_WaitingString));
    [_bridge GrayNreshapeWebview];
}

- (void)GrayN_WVC_CloseJSBridgeViewIsForceClose:(BOOL)status
{
    // 5.1.4 重置下方导航栏
    [_bridge GrayNsetsetTopbarUp:YES];
    p_GrayN_WVC_IsOpenAllOrientation = NO;
    
    GrayNcommon::GrayN_ConsoleLog(@"opCloseJsbv %d %d %d",GrayN_SDK_Init::GetInstance().p_GrayN_IsClickLogin,  GrayNSDK::m_GrayN_SDK_IsShowUpdate, GrayN_Offical::GetInstance().m_GrayN_Offical_IsLogining);
    [[GrayN_BaseControl GrayN_Share] GrayNcloseJSBridgeView];
    GrayNcommon::m_GrayN_ShowLoading = true;

    if (GrayNchannel::GetInstance().GrayN_ChannelIsLogin()) {
    }
    
    // 如果在初始化中游戏调用过登录，在初始化结束时调起登录
    if (GrayN_SDK_Init::GetInstance().p_GrayN_IsClickLogin && !GrayNSDK::m_GrayN_SDK_IsShowUpdate) {
        GrayNSDK::m_GrayN_SDK_IsShowUpdate = true;
        // 必须主线程调用，否则没有HUD
        dispatch_async(dispatch_get_main_queue(), ^{
            OPGameSDK::GetInstance().RegisterLogin();
            return;
        });
    } else {
        GrayNSDK::m_GrayN_SDK_IsShowUpdate = true;
    }

    if (status) {
        GrayN_Offical::GetInstance().m_GrayN_Offical_IsLogining = false;
        return;
    }
    // 第三方登录时，关闭弹登录界面
    if (GrayN_Offical::GetInstance().m_GrayN_Offical_IsLogining) {
        dispatch_async(dispatch_get_main_queue(), ^{
            GrayN_Offical::GetInstance().GrayN_Offical_ShowSwitchAccountView();
        });
    }
}

////遍历文件夹获得文件夹大小，返回多少M
//- (float ) folderSizeAtPath:(NSString*) folderPath{
//    NSFileManager* manager = [NSFileManager defaultManager];
//    if (![manager fileExistsAtPath:folderPath]) return 0;
//    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
//    NSString* fileName;
//    long long folderSize = 0;
//    while ((fileName = [childFilesEnumerator nextObject]) != nil){
//        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
//        folderSize += [self fileSizeAtPath:fileAbsolutePath];
//    }
//    return folderSize/(1024.0*1024.0);
//}
//- (long long) fileSizeAtPath:(NSString*) filePath{
//    NSFileManager* manager = [NSFileManager defaultManager];
//    if ([manager fileExistsAtPath:filePath]){
//        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
//    }
//    return 0;
//}
#pragma mark - 页面旋转
+ (void)GrayN_WVC_SetIsOpenAllOrientation:(BOOL)status
{
    p_GrayN_WVC_IsOpenAllOrientation = status;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if([GrayN_BaseControl GrayN_Base_WindowIsAutoOrientation]){
        if (UIInterfaceOrientationIsLandscape([GrayN_BaseControl GrayN_Base_WindowInitOrientation])) {
            return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
        } else {
            return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
        }
    } else {
        if ([GrayN_BaseControl GrayN_Base_WindowInitOrientation] == toInterfaceOrientation) {
            return YES;
        } else {
            return NO;
        }
    }
}
- (BOOL)shouldAutorotate
{

    return [GrayN_BaseControl GrayN_Base_WindowIsAutoOrientation];
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (p_GrayN_WVC_IsOpenAllOrientation) {
        [_bridge GrayNreshapeWebview];
        return UIInterfaceOrientationMaskAll;
    } else
        return [GrayN_BaseControl GrayN_Base_SupportedInterfaceOrientations];
}


- (BOOL)prefersHomeIndicatorAutoHidden
{
    return [GrayNbaseSDK GrayNhomeIndicator_AutoHidden];
}
- (UIRectEdge)preferredScreenEdgesDeferringSystemGestures
{
    return [GrayNbaseSDK GrayNdeferring_SystemGestures];
}
/*5.1.6 本地加载 拷贝资源*/
- (NSString*)GrayNcreateFileUrlHelper:(NSString*)folderPath
{
    NSString* path = [folderPath stringByAppendingPathComponent:[self GrayNindexFileName]];
//    NSLog(@"111111111%@",[self GrayNindexFileName]);
    NSURL* url = [NSURL fileURLWithPath:path];
    return url.absoluteString;
}

- (BOOL)GrayNcopyFrom:(NSString*)src to:(NSString*)dest error:(NSError* __autoreleasing*)error
{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:src]) {
        NSString* errorString = [NSString stringWithFormat:@"%@ file does not exist.", src];
        if (error != NULL) {
            (*error) = [NSError errorWithDomain:@"TestDomainTODO"
                                           code:1
                                       userInfo:[NSDictionary dictionaryWithObject:errorString
                                                                            forKey:NSLocalizedDescriptionKey]];
        }
        return NO;
    }
    
    // generate unique filepath in temp directory
    CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef uuidString = CFUUIDCreateString(kCFAllocatorDefault, uuidRef);
    NSString* tempBackup = [[NSTemporaryDirectory() stringByAppendingPathComponent:(__bridge NSString*)uuidString] stringByAppendingPathExtension:@"bak"];
    CFRelease(uuidString);
    CFRelease(uuidRef);
    
    BOOL destExists = [fileManager fileExistsAtPath:dest];
    
    // backup the dest
    if (destExists && ![fileManager copyItemAtPath:dest toPath:tempBackup error:error]) {
        return NO;
    }
    
    // remove the dest
    if (destExists && ![fileManager removeItemAtPath:dest error:error]) {
        return NO;
    }
    
    // create path to dest
    if (!destExists && ![fileManager createDirectoryAtPath:[dest stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:error]) {
        return NO;
    }
    
    // copy src to dest
    if ([fileManager copyItemAtPath:src toPath:dest error:error]) {
        // success - cleanup - delete the backup to the dest
        if ([fileManager fileExistsAtPath:tempBackup]) {
            [fileManager removeItemAtPath:tempBackup error:error];
        }
        return YES;
    } else {
        // failure - we restore the temp backup file to dest
        [fileManager copyItemAtPath:tempBackup toPath:dest error:error];
        // cleanup - delete the backup to the dest
        if ([fileManager fileExistsAtPath:tempBackup]) {
            [fileManager removeItemAtPath:tempBackup error:error];
        }
        return NO;
    }
}
- (NSString*)GrayNindexFileName
{
    return @"index.html";
}
- (NSString*)GrayNbundleFolderPath
{
    NSBundle* mainBundle = [NSBundle mainBundle];
    NSString* wwwFileBundlePath = [mainBundle pathForResource:[self GrayNindexFileName] ofType:@"" inDirectory:@"OurSDK_res.bundle/jsBridge"];
    return [wwwFileBundlePath stringByDeletingLastPathComponent];
}
- (NSString*)GrayNtmpFolderPath
{
    return NSTemporaryDirectory();
}
- (NSString*)GrayNcopyBundle:(NSString*)folderPath
{
    NSString* location = nil;
    BOOL copyOK = NO;
    
    // is the bundle www index.html there
//    NSLog(@"x%@      %@",[self GrayNbundleFolderPath], [self GrayNindexFileName]);
    NSString* indexFileWWWBundlePath = [[self GrayNbundleFolderPath] stringByAppendingPathComponent:[self GrayNindexFileName]];
    BOOL readable = [[NSFileManager defaultManager] isReadableFileAtPath:indexFileWWWBundlePath];
//    NSLog(@"File %@ is readable: %@", indexFileWWWBundlePath, readable? @"YES" : @"NO");
    
    if (readable) {
        NSString* newFolderPath = [folderPath stringByAppendingPathComponent:@"ourpalm"];
        
        // create the folder, if needed
        [[NSFileManager defaultManager] createDirectoryAtPath:newFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
        
        // copy
        NSError* error = nil;
        if ((copyOK = [self GrayNcopyFrom:[self GrayNbundleFolderPath]  to:newFolderPath error:&error])) {
            location = newFolderPath;
        }
//        NSLog(@"Copy from %@ to %@ is ok: %@", folderPath, newFolderPath, copyOK? @"YES" : @"NO");
        if (error != nil) {
//            NSLog(@"%@", [error localizedDescription]);
            location = nil;
        }
    }
    
    return location;
}

@end
