#import "GrayN_Offical.h"
#import <dispatch/dispatch.h>

#import "GrayNSDK.h"
#import "GrayNjson_cpp.h"
#import "GrayN_UserCenter.h"
#import "GrayN_BaseControl.h"
#import "GrayNconfig.h"

#import "GrayN_WebViewController.h"
#import "GrayN_Tools.h"
#import "GrayNinit.h"
#import "OPGameSDK.h"

#import "GrayN_GameCenter.h"

#import "GrayN_CodeScanner.h"
GrayNusing_NameSpace;
//#define OPWaitTime "20"

static GrayN_CodeScanner *p_GrayN_Offical_Scanner;
#pragma mark- 初始化
GrayN_Offical::GrayN_Offical()
{
    m_GrayN_Offical_IsHttp = false;
    m_GrayN_Offical_IsLogining = false;
    m_GrayN_Offical_IsLocalRequest = false;
    m_GrayN_Offical_TestUrl = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"OP_UITest_URL"];
    GrayNcommon::GrayN_DebugLog(@"OP_UITest_URL=%@",m_GrayN_Offical_TestUrl);
    
    if ([m_GrayN_Offical_TestUrl isEqualToString:@""]) {
        m_GrayN_Offical_TestUrl = nil;
        return;
    }
    // 判断测试地址是否为http
    if ([m_GrayN_Offical_TestUrl rangeOfString:@"https"].location == NSNotFound ) {
        m_GrayN_Offical_IsHttp = true;
    }
}
GrayN_Offical::~GrayN_Offical()
{
    
}
//void GrayN_Offical::startLogTimer(int length)
//{
//    GrayNcommon::GrayN_ConsoleLog(@"opPageMonitorStart");
//    if (logTimer) {
//        if (length == logTimer->m_GrayN_WaitTime) {
//            return;
//        }
//        logTimer->GrayN_StopTimer();
//    }
//    logTimer = new GrayN_Timer_GrayN();
//    logTimer->GrayN_StartTimer(length, this);
//}
//void GrayN_Offical::GrayN_StopTimer()
//{
//    if (logTimer) {
//        logTimer->GrayN_StopTimer();
//    }
//}
//void GrayN_Offical::GrayN_TimeUp()
//{
//    GrayNcommon::m_GrayN_ShowLoading = true;
//
//    [[GrayN_BaseControl GrayN_Share] closeJSBridgeView];
//    m_GrayN_Offical_IsLocalRequest = true;
//    GrayNcommon::GrayN_ConsoleLog(@"opClearAppCache");
//    [GrayN_Tools GrayNclearAppCache];
//
//    GrayN_StopTimer();
//    GrayNcommon::GrayN_ConsoleLog(@"opPageErrorLogSending");
//
//    GrayN_Offical_Update();
//
//    // 发送监控日志
//    GrayN_JSON::Value logValJson;
//    logValJson["pageUrl"] = GrayN_JSON::Value(GrayNSDK::m_GrayN_SDK_NoticeUrl);
//    logValJson["waitTime"] = GrayN_JSON::Value(OPWaitTime);
//    logValJson["errorType"] = GrayN_JSON::Value("0");
//    logValJson["errorInfo"] = GrayN_JSON::Value("");
//    GrayN_JSON::FastWriter fast_writer;
//    string resultStr = fast_writer.write(logValJson);
//    OPGameSDK::GetInstance().SendLog("11003", "sdk-crash-page", resultStr.c_str());
//}
#pragma mark- JSBridgeViews
void GrayN_Offical::GrayN_Offical_Update()
{
    //    m_GrayN_Offical_IsLocalRequest = true;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (atoi(GrayNSDK::m_GrayN_SDK_IsLimit.c_str())) {
            [GrayN_Tools GrayNsetAutoLoginStatus:NO];
        }
        
        if (m_GrayN_Offical_IsLocalRequest) {
            [[GrayN_BaseControl GrayN_Share] GrayNshowLocalJSBridgeView:@"#/login/login_prompt"];
            return ;
        }
        
        // 监控页面
        //        startLogTimer(atoi(OPWaitTime));
        
        if (m_GrayN_Offical_TestUrl) {
            [[GrayN_BaseControl GrayN_Share] GrayNshowJSBridgeView:[NSString stringWithFormat:@"%@#/login/login_prompt", m_GrayN_Offical_TestUrl]];
        } else {
            [[GrayN_BaseControl GrayN_Share] GrayNshowJSBridgeView:[NSString stringWithUTF8String:GrayNSDK::m_GrayN_SDK_NoticeUrl.c_str()]];
        }
    });
}
void GrayN_Offical::GrayN_Offical_RegisterLogin()
{
    // 处理双账号删除逻辑
    GrayNcommon::GrayN_DebugLog(@"上次登录的列表\n%@",[GrayN_Tools GrayNloadUserInfoArray]);
    [GrayN_Tools GrayNdeleteDuplicateUserInfo];
    
//    GrayNchannel::GetInstance().IsAllowShowToolBar(YES);
    
    // 处理1.0老账号迁移问题
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:@"accounts"] != nil) {
        NSArray *account_arr = [userDefaults objectForKey:@"accounts"];
        [account_arr reverseObjectEnumerator];
        for (int i=0; i<account_arr.count; i++) {
            GrayN_UserInfo *GrayN_UserInfo_GrayN = [[[GrayN_UserInfo alloc] init] autorelease];
            NSMutableDictionary *userInfo = [[[NSMutableDictionary alloc] init] autorelease];
            [userInfo setObject:[[account_arr objectAtIndex:account_arr.count-i-1] objectForKey:@"name"] forKey:@"userName"];
            [userInfo setObject:[[account_arr objectAtIndex:account_arr.count-i-1] objectForKey:@"password"] forKey:@"password"];
            [userInfo setObject:@"common" forKey:@"currentUserType"];
            [GrayN_UserInfo_GrayN GrayN_SetUserInfo:userInfo];
            [GrayN_Tools GrayNsaveUserInfo:GrayN_UserInfo_GrayN];
        }
        
        GrayN_Offical_ShowSwitchAccountView();
        // 删除老账号
        [userDefaults removeObjectForKey:@"accounts"];
        return;
    }
    
    NSArray *userInfoArr = [[[NSArray alloc] initWithArray:[GrayN_Tools GrayNloadUserInfoArray]] autorelease];
    
    if (userInfoArr && [userInfoArr count]) {
        if ([GrayN_Tools GrayNgetAutoLoginStatus]) {
            GrayN_UserInfo *userInfo = [GrayN_Tools GrayNloadLastUserInfo];
            NSString *loginType = userInfo.loginType;
            if ([loginType rangeOfString:@"speedy"].location != NSNotFound) {
                // 快登
                
                    [[GrayN_BaseControl GrayN_Share] GrayNshowHudWithTag:GrayN_QUICK_LOGINNING withUserName:@"" handler:^() {
                        GrayN_UserCenter::GetInstance().GrayN_UserCenter_SpeedyLogin(true, false);
                    }];
                
            } else {
                // 普通自动登录
                NSString *loginUserName = userInfo.userName;
                NSString *displayUserName = userInfo.userName;
                
                if ([userInfo.currentUserType rangeOfString:@"thirdHidden"].location != NSNotFound) {
                    // 处理显示第三方昵称
                    string thirdName = "";
                    GrayN_Offical_GetCurrentThirdHiddenNickName([userInfo.userId UTF8String], thirdName);
                    displayUserName = [NSString stringWithUTF8String:thirdName.c_str()];
                } else if ([userInfo.currentUserType rangeOfString:@"phone"].
                           location != NSNotFound) {
                    // 处理手机号登录
                    loginUserName = userInfo.bindPhone;
                    displayUserName = userInfo.bindPhone;
                }
                
                    [[GrayN_BaseControl GrayN_Share] GrayNshowHudWithTag:GrayN_LOGINNING withUserName:displayUserName handler:^() {
                        string userName = [loginUserName UTF8String];
                        string userPwd = [userInfo.password UTF8String];
                        GrayN_UserCenter::GetInstance().GrayN_UserCenter_CommonLogin(userName, userPwd, true, false);
                    }];
            }
        } else {
            GrayN_Offical_ShowSwitchAccountView();
        }
    } else {
        m_GrayN_Offical_IsLogining = true;
        
        if (m_GrayN_Offical_IsLocalRequest) {
            [[GrayN_BaseControl GrayN_Share] GrayNshowLocalJSBridgeView:@"#/login/login_first"];
            return ;
        }
        
        if (m_GrayN_Offical_TestUrl) {
            [[GrayN_BaseControl GrayN_Share] GrayNshowJSBridgeView:[NSString stringWithFormat:@"%@#/login/login_first", m_GrayN_Offical_TestUrl]];
        } else {
            [[GrayN_BaseControl GrayN_Share] GrayNshowJSBridgeView:[NSString stringWithUTF8String:GrayNSDK::m_GrayN_SDK_LoginUrl.c_str()]];
        }
    }
}
void GrayN_Offical::GrayN_Offical_SwitchAccount()
{
    GrayNSDK::GrayN_SDK_CallBackLogout(true, GrayN_LogoutJson_SwitchAccount);
    GrayN_Offical_ShowSwitchAccountView();
}
void GrayN_Offical::GrayN_Offical_ShowSwitchAccountView()
{
    m_GrayN_Offical_IsLogining = true;
    // 显示切换账号页面不触发回调
    NSArray *userInfoArr = [[[NSArray alloc] initWithArray:[GrayN_Tools GrayNloadUserInfoArray]] autorelease];
    
    if (userInfoArr && [userInfoArr count]) {
        if (m_GrayN_Offical_IsLocalRequest) {
            [[GrayN_BaseControl GrayN_Share] GrayNshowLocalJSBridgeView:@"#/login/login_switch"];
            return ;
        }
        
        if (m_GrayN_Offical_TestUrl) {
            [[GrayN_BaseControl GrayN_Share] GrayNshowJSBridgeView:[NSString stringWithFormat:@"%@#/login/login_switch", m_GrayN_Offical_TestUrl]];
        } else {
            [[GrayN_BaseControl GrayN_Share] GrayNshowJSBridgeView:[NSString stringWithUTF8String:GrayNSDK::m_GrayN_SDK_ChangeLoginUrl.c_str()]];
        }
    } else {
        if (m_GrayN_Offical_IsLocalRequest) {
            [[GrayN_BaseControl GrayN_Share] GrayNshowLocalJSBridgeView:@"#/login/login_first"];
            return ;
        }
        
        if (m_GrayN_Offical_TestUrl) {
            [[GrayN_BaseControl GrayN_Share] GrayNshowJSBridgeView:[NSString stringWithFormat:@"%@#/login/login_first", m_GrayN_Offical_TestUrl]];
        } else {
            [[GrayN_BaseControl GrayN_Share] GrayNshowJSBridgeView:[NSString stringWithUTF8String:GrayNSDK::m_GrayN_SDK_LoginUrl.c_str()]];
        }
    }
}
void GrayN_Offical::GrayN_Offical_EnterPlatform()
{
    if (m_GrayN_Offical_IsLocalRequest) {
        [[GrayN_BaseControl GrayN_Share] GrayNshowLocalJSBridgeView:@"#/ucenter/menu"];
        return ;
    }
    
    if (m_GrayN_Offical_TestUrl) {
        [[GrayN_BaseControl GrayN_Share] GrayNshowJSBridgeView:[NSString stringWithFormat:@"%@#/ucenter/menu", m_GrayN_Offical_TestUrl]];
    } else {
        [[GrayN_BaseControl GrayN_Share] GrayNshowJSBridgeView:[NSString stringWithUTF8String:GrayNSDK::m_GrayN_SDK_PersonalCenterUrl.c_str()]];
    }
}
void GrayN_Offical::GrayN_Offical_ShowUpgradeTipView()
{
    if (m_GrayN_Offical_IsLocalRequest) {
        [[GrayN_BaseControl GrayN_Share] GrayNshowLocalJSBridgeView:@"#/login/upgrade_tip"];
        return ;
    }
    
    if (m_GrayN_Offical_TestUrl) {
        [[GrayN_BaseControl GrayN_Share] GrayNshowJSBridgeView:[NSString stringWithFormat:@"%@#/login/upgrade_tip", m_GrayN_Offical_TestUrl]];
    } else {
        [[GrayN_BaseControl GrayN_Share] GrayNshowJSBridgeView:[NSString stringWithUTF8String:GrayNSDK::m_GrayN_SDK_TourAutoLoginUpgradeUrl.c_str()]];
    }
}
void GrayN_Offical::GrayN_Offical_ShowChargeView()
{
    if (m_GrayN_Offical_IsLocalRequest) {
        [[GrayN_BaseControl GrayN_Share] GrayNshowLocalJSBridgeView:@"#/pcenter/index"];
        return ;
    }
    
    if (m_GrayN_Offical_TestUrl) {
        [[GrayN_BaseControl GrayN_Share] GrayNshowJSBridgeView:[NSString stringWithFormat:@"%@#/pcenter/index", m_GrayN_Offical_TestUrl]];
    } else {
        [[GrayN_BaseControl GrayN_Share] GrayNshowJSBridgeView:[NSString stringWithUTF8String:GrayNSDK::m_GrayN_SDK_PayUrl.c_str()]];
    }
}
void GrayN_Offical::GrayN_Offical_CustomService()
{
    if (m_GrayN_Offical_IsLocalRequest) {
        [[GrayN_BaseControl GrayN_Share] GrayNshowLocalJSBridgeView:@"#/question/question_index"];
        return ;
    }
    
    if (m_GrayN_Offical_TestUrl) {
        [[GrayN_BaseControl GrayN_Share] GrayNshowJSBridgeView:[NSString stringWithFormat:@"%@#/question/question_index", m_GrayN_Offical_TestUrl]];
    } else {
        [[GrayN_BaseControl GrayN_Share] GrayNshowJSBridgeView:[NSString stringWithUTF8String:GrayNSDK::m_GrayN_SDK_CustomerUrl.c_str()]];
        
    }
}
void GrayN_Offical::GrayN_Offical_ShowBindPhoneView()
{
    if (m_GrayN_Offical_IsLocalRequest) {
        [[GrayN_BaseControl GrayN_Share] GrayNshowLocalJSBridgeView:@"#/login/login_bindphone"];
        return ;
    }
    
    if (m_GrayN_Offical_TestUrl) {
        [[GrayN_BaseControl GrayN_Share] GrayNshowJSBridgeView:[NSString stringWithFormat:@"%@#/login/login_bindphone", m_GrayN_Offical_TestUrl]];
    } else {
        [[GrayN_BaseControl GrayN_Share] GrayNshowJSBridgeView:[NSString stringWithUTF8String:GrayNSDK::m_GrayN_SDK_OfficalAutoLoginBindMobileUrl.c_str()]];
    }
}
void GrayN_Offical::GrayN_Offical_ShowID_Authentication()
{
    if (m_GrayN_Offical_IsLocalRequest) {
        [[GrayN_BaseControl GrayN_Share] GrayNshowLocalJSBridgeView:@"#/login/identity_authentication"];
        return ;
    }
    
    if (m_GrayN_Offical_TestUrl) {
        [[GrayN_BaseControl GrayN_Share] GrayNshowJSBridgeView:[NSString stringWithFormat:@"%@#/login/identity_authentication", m_GrayN_Offical_TestUrl]];
    } else {
        [[GrayN_BaseControl GrayN_Share] GrayNshowJSBridgeView:[NSString stringWithUTF8String:GrayNSDK::m_GrayN_SDK_IdentityAuthUrl.c_str()]];
    }
}
void GrayN_Offical::GrayN_Offical_ShowPayUpgradeView()
{
    if (m_GrayN_Offical_IsLocalRequest) {
        [[GrayN_BaseControl GrayN_Share] GrayNshowLocalJSBridgeView:@"#/pcenter/upgrade"];
        return ;
    }
    
    if (m_GrayN_Offical_TestUrl) {
        [[GrayN_BaseControl GrayN_Share] GrayNshowJSBridgeView:[NSString stringWithFormat:@"%@#/pcenter/upgrade", m_GrayN_Offical_TestUrl]];
    } else {
        [[GrayN_BaseControl GrayN_Share] GrayNshowJSBridgeView:[NSString stringWithUTF8String:GrayNSDK::m_GrayN_SDK_PayUrlUpgradeUrl.c_str()]];
    }
}

void GrayN_Offical::GrayN_Offical_Logout()
{
    [[GrayN_BaseControl GrayN_Share] GrayN_CloseSDK_Window];
    
    GrayNSDK::GrayN_SDK_CallBackLogout(true, GrayN_LogoutJson_Logout);
    [GrayN_Tools GrayNsetAutoLoginStatus:NO];
}
void GrayN_Offical::GrayN_Offical_ShowToast(string content, bool ifClose)
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue]<8.0f && [GrayN_BaseControl GrayN_Base_WindowIsLandScape]) {
        [[GrayN_BaseControl GrayN_Share] GrayNshowToast:[NSString stringWithUTF8String:content.c_str()]
                                       withCenter:CGPointMake(
                                                              [[GrayN_BaseControl GrayN_Share] view].center.y,
                                                              [[GrayN_BaseControl GrayN_Share] view].frame.size.width*0.7)
                                    ifCloseWindow:ifClose];
    } else {
        [[GrayN_BaseControl GrayN_Share] GrayNshowToast:[NSString stringWithUTF8String:content.c_str()]
                                       withCenter:CGPointMake(
                                                              [[GrayN_BaseControl GrayN_Share] view].center.x,
                                                              [[GrayN_BaseControl GrayN_Share] view].frame.size.height*0.7)
                                    ifCloseWindow:ifClose];
    }
}
void GrayN_Offical::GrayN_Offical_ShowWelcome(string name)
{
    m_GrayN_Offical_IsLogining = false;
    [[GrayN_BaseControl GrayN_Share] GrayNshowWelcome:[NSString stringWithUTF8String:name.c_str()]];
}

void GrayN_Offical::GrayN_Offical_UserInfoResponse(string info)
{
    [[GrayN_Tools share_GrayN] GrayNtriggerUserInfoResponse:[NSString stringWithUTF8String:info.c_str()]];
}
void GrayN_Offical::GrayN_Offical_DeeplinkResponse(string info)
{
    [[GrayN_Tools share_GrayN] GrayNtriggerDeeplinkResponse:[NSString stringWithUTF8String:info.c_str()]];
    
}
void GrayN_Offical::GrayN_Offical_GetSessionId()
{
    GrayN_SDK_Init::GetInstance().GrayN_InitGetSessionId();
}
void GrayN_Offical::GrayN_Offical_GetSessionIdResponse(string info)
{
    [[GrayN_Tools share_GrayN] GrayNtriggerGetSessionIdResponse:[NSString stringWithUTF8String:info.c_str()]];
}
void GrayN_Offical::GrayN_Offical_LoginGetSessionIdResponse()
{
    NSArray *userInfoArr = [[[NSArray alloc] initWithArray:[GrayN_Tools GrayNloadUserInfoArray]] autorelease];
    if (userInfoArr && [userInfoArr count]) {
        if ([GrayN_Tools GrayNgetAutoLoginStatus]) {
            GrayN_UserInfo *userInfo = [GrayN_Tools GrayNloadLastUserInfo];
            NSString *loginType = userInfo.loginType;
            if ([loginType isEqualToString:@"speedyLogin"] ||
                [loginType isEqualToString:@"speedyRegister"] ) {
                // 快登
                GrayN_UserCenter::GetInstance().GrayN_UserCenter_SpeedyLogin(true, true);
            } else {
                // 普通自动登录
                string userName = [userInfo.userName UTF8String];
                string userPwd = [userInfo.password UTF8String];
                GrayN_UserCenter::GetInstance().GrayN_UserCenter_CommonLogin(userName, userPwd, true, true);
            }
        } else {
            [[GrayN_Tools share_GrayN] GrayNtriggerGetSessionIdResponse:@"false"];
        }
    } else {
        [[GrayN_Tools share_GrayN] GrayNtriggerGetSessionIdResponse:@"false"];
    }
}


void GrayN_Offical::GrayN_Offical_UpdateUserInfo(GrayN_JSON::Value json)
{
    NSString *userId = [NSString stringWithUTF8String:json["userId"].asString().c_str()];
    GrayN_UserInfo *GrayN_UserInfo_GrayN = [[[GrayN_UserInfo alloc] init] autorelease];
    GrayN_UserInfo_GrayN = [GrayN_Tools GrayNloadUserInfoWithUserId:userId];
    GrayNcommon::GrayN_DebugLog(@"GrayN_Offical_UpdateUserInfo begin%@", GrayN_UserInfo_GrayN.GrayN_UserInfo_GrayN);
    
    /*5.1.9*/
    GrayN_UserInfo_GrayN.userId = userId;
    [GrayN_UserInfo_GrayN.GrayN_UserInfo_GrayN setObject:GrayN_UserInfo_GrayN.userId forKey:@"userId"];
    
    GrayN_UserInfo_GrayN.userName = [NSString stringWithUTF8String:GrayNcommon::m_GrayN_Game_UserName.c_str()];
    [GrayN_UserInfo_GrayN.GrayN_UserInfo_GrayN setObject:GrayN_UserInfo_GrayN.userName forKey:@"userName"];
    
    GrayN_UserInfo_GrayN.password = [NSString stringWithUTF8String:json["password"].asString().c_str()];
    [GrayN_UserInfo_GrayN.GrayN_UserInfo_GrayN setObject:GrayN_UserInfo_GrayN.password forKey:@"password"];
    /*5.1.9*/

    GrayN_UserInfo_GrayN.isLimit = [NSString stringWithUTF8String:json["limit"]["isLimit"].asString().c_str()];
    [GrayN_UserInfo_GrayN.GrayN_UserInfo_GrayN setObject:GrayN_UserInfo_GrayN.isLimit forKey:@"isLimit"];
    
    GrayN_UserInfo_GrayN.limitDesc = [NSString stringWithUTF8String:json["limit"]["limitDesc"].asString().c_str()];
    [GrayN_UserInfo_GrayN.GrayN_UserInfo_GrayN setObject:GrayN_UserInfo_GrayN.limitDesc forKey:@"limitDesc"];
    
    GrayN_UserInfo_GrayN.palmId = [NSString stringWithUTF8String:json["palmId"].asString().c_str()];
    [GrayN_UserInfo_GrayN.GrayN_UserInfo_GrayN setObject:GrayN_UserInfo_GrayN.palmId forKey:@"palmId"];
    
    GrayN_UserInfo_GrayN.bindPhone = [NSString stringWithUTF8String:json["phone"].asString().c_str()];
    [GrayN_UserInfo_GrayN.GrayN_UserInfo_GrayN setObject:GrayN_UserInfo_GrayN.bindPhone forKey:@"bindPhone"];
    
    GrayN_UserInfo_GrayN.bindTokenId = [NSString stringWithUTF8String:json["bindPhone"]["bindTokenId"].asString().c_str()];
    [GrayN_UserInfo_GrayN.GrayN_UserInfo_GrayN setObject:GrayN_UserInfo_GrayN.bindTokenId forKey:@"bindTokenId"];
    
    GrayN_UserInfo_GrayN.needBindPhone = [NSString stringWithUTF8String:json["bindPhone"]["isNeed"].asString().c_str()];
    [GrayN_UserInfo_GrayN.GrayN_UserInfo_GrayN setObject:GrayN_UserInfo_GrayN.needBindPhone forKey:@"needBindPhone"];
    
    GrayN_UserInfo_GrayN.bindEmail = [NSString stringWithUTF8String:json["email"].asString().c_str()];
    [GrayN_UserInfo_GrayN.GrayN_UserInfo_GrayN setObject:GrayN_UserInfo_GrayN.bindEmail forKey:@"bindEmail"];
    
    GrayN_UserInfo_GrayN.nickName = [NSString stringWithUTF8String:json["nickName"].asString().c_str()];
    [GrayN_UserInfo_GrayN.GrayN_UserInfo_GrayN setObject:GrayN_UserInfo_GrayN.nickName forKey:@"nickName"];
    
    GrayN_UserInfo_GrayN.originalUserType = [NSString stringWithUTF8String:json["originalUserType"].asString().c_str()];
    [GrayN_UserInfo_GrayN.GrayN_UserInfo_GrayN setObject:GrayN_UserInfo_GrayN.originalUserType forKey:@"originalUserType"];
    
    GrayN_UserInfo_GrayN.loginType = [NSString stringWithUTF8String:json["loginType"].asString().c_str()];
    [GrayN_UserInfo_GrayN.GrayN_UserInfo_GrayN setObject:GrayN_UserInfo_GrayN.loginType forKey:@"loginType"];
    
    GrayN_UserInfo_GrayN.currentUserType = [NSString stringWithUTF8String:json["currentUserType"].asString().c_str()];
    [GrayN_UserInfo_GrayN.GrayN_UserInfo_GrayN setObject:GrayN_UserInfo_GrayN.currentUserType forKey:@"currentUserType"];
    
//        GrayN_UserInfo_GrayN.currentUserType = @"thirdHiddenLogin";
//        [GrayN_UserInfo_GrayN.GrayN_UserInfo_GrayN setObject:GrayN_UserInfo_GrayN.currentUserType forKey:@"currentUserType"];
    
    GrayN_UserInfo_GrayN.identityAuthStatus = [NSString stringWithUTF8String:json["identityAuth"]["status"].asString().c_str()];
    [GrayN_UserInfo_GrayN.GrayN_UserInfo_GrayN setObject:GrayN_UserInfo_GrayN.identityAuthStatus forKey:@"identityAuthStatus"];
    
    GrayN_UserInfo_GrayN.identityAuthIdNum = [NSString stringWithUTF8String:json["identityAuth"]["idNum"].asString().c_str()];
    [GrayN_UserInfo_GrayN.GrayN_UserInfo_GrayN setObject:GrayN_UserInfo_GrayN.identityAuthIdNum forKey:@"identityAuthIdNum"];
    
    GrayN_UserInfo_GrayN.identityAuthRealName = [NSString stringWithUTF8String:json["identityAuth"]["realName"].asString().c_str()];
    [GrayN_UserInfo_GrayN.GrayN_UserInfo_GrayN setObject:GrayN_UserInfo_GrayN.identityAuthRealName forKey:@"identityAuthRealName"];
    
    [GrayN_UserInfo_GrayN GrayN_FormatJson];
    GrayNcommon::GrayN_DebugLog(@"GrayN_Offical_UpdateUserInfo finish%@", GrayN_UserInfo_GrayN.GrayN_UserInfo_GrayN);
    [GrayN_Tools GrayNsaveUserInfo:GrayN_UserInfo_GrayN];
}
/*5.1.9*/
void GrayN_Offical::GrayN_Offical_DelAllUserInfoAndUpdateLastone(GrayN_JSON::Value json)
{
    // 删除本地存储第三方账号
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    [userDefaults setObject:nil forKey:@"GrayN_UserInfo_GrayN"];
//    [userDefaults synchronize];
    
    GrayN_Offical_UpdateUserInfo(json);
}
void GrayN_Offical::GrayN_Offical_ShowBindOfficialView()
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (m_GrayN_Offical_IsLocalRequest) {
            [[GrayN_BaseControl GrayN_Share] GrayNshowLocalJSBridgeView:@"#/login/channel_user_to_official_user"];
            return ;
        }
        
        if (m_GrayN_Offical_TestUrl) {
            [[GrayN_BaseControl GrayN_Share] GrayNshowJSBridgeView:[NSString stringWithFormat:@"%@#/login/channel_user_to_official_user", m_GrayN_Offical_TestUrl]];
        } else {
            [[GrayN_BaseControl GrayN_Share] GrayNshowJSBridgeView:[NSString stringWithFormat:@"%@/login/channel_user_to_official_user", [NSString stringWithUTF8String:GrayNSDK::m_GrayN_SDK_PageUrl.c_str()]]];
        }
    });
    
}
void GrayN_Offical::GrayN_Offical_GetCurrentThirdHiddenNickName(string userId, string& nickName)
{
    NSString *tUserId = [NSString stringWithUTF8String:userId.c_str()];
    GrayN_UserInfo *GrayN_UserInfo_GrayN = [[[GrayN_UserInfo alloc] init] autorelease];
    GrayN_UserInfo_GrayN = [GrayN_Tools GrayNloadUserInfoWithUserId:tUserId];
    NSDictionary *returnJson = [GrayN_UserInfo_GrayN.GrayN_UserInfo_GrayN objectForKey:@"returnJson"];
    if ([returnJson isEqual:[NSNull null]] ||
        returnJson == nil ||
        [returnJson isEqual:@""]) {
        nickName = [GrayN_UserInfo_GrayN.nickName UTF8String];
    } else {
        nickName = [[[GrayN_UserInfo_GrayN.GrayN_UserInfo_GrayN objectForKey:@"returnJson"] objectForKey:@"nickName"] UTF8String];
    }
}
//void GrayN_Offical::CloseOPWindow()
//{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [[GrayN_BaseControl GrayN_Share] GrayN_CloseSDK_Window];
//    });
//}
//void GrayN_Offical::ControlRedPoint(GrayN_JSON::Value json)
//{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        NSMutableDictionary *dic = [[[NSMutableDictionary alloc] init] autorelease];
//        //        cout<<"!!!!!!!!!!!"<<json.size()<<endl;
//        //        cout<<json.toStyledString()<<endl;
//        for(int i=0;i<json.size();i++){
//
//            string jsonType = json[i]["type"].asString();
//            string jsonShow = json[i]["show"].asString();
//
//            NSString *type = [NSString stringWithUTF8String:jsonType.c_str()];
//            NSString *show = [NSString stringWithUTF8String:jsonShow.c_str()];
//            [dic setObject:show forKey:type];
//        }
//        GrayNcommon::GrayN_DebugLog(@"小红点：\n%@", dic);
//        [GrayN_Tools controlRedPoint:dic];
//    });
//}

void GrayN_Offical::GrayN_Offical_OpenWebviewWithNavbar(string url)
{
    if (url == "" || url.c_str() == NULL) {
        GrayN_Offical::GetInstance().GrayN_Offical_ShowToast("当前打开的地址不能为空!", YES);
        return;
    }
    [[GrayN_WebViewController GrayN_Share] GrayN_WVC_ShowJSBridgeViewWithNavBar:[NSString stringWithUTF8String:url.c_str()]];
}
/*5.2.0*/
void GrayN_Offical::GrayN_Offical_GC_Callback(string userName, string currentUserType, bool status)
{
    NSString *uName = [NSString stringWithUTF8String:userName.c_str()];
    NSString *current = [NSString stringWithUTF8String:currentUserType.c_str()];

    [[GrayN_GameCenter GrayN_share] GrayN_GC_CallbackUserName:uName CUT:current status:status];
}
/*5.2.1*/
void GrayN_Offical::GrayN_Offical_CodeScanner()
{
    if (GrayNchannel::GetInstance().GrayN_ChannelIsLogin() == false) {
        string body(GrayNcommon::GrayNcommonGetLocalLang(GrayN_IsNotLogin));
        GrayN_LoadingUI::GetInstance().GrayN_ShowMsgBox(GrayNcommon::GrayNcommonGetLocalLang(GrayN_Title), GrayNcommon::GrayNcommonGetLocalLang(body.c_str()), 0, 1);
        return;
    }
    
 
    if (p_GrayN_Offical_Scanner == nil) {
        p_GrayN_Offical_Scanner = [[GrayN_CodeScanner alloc] init];
    }

    UIViewController *rvc = [[UIApplication sharedApplication] keyWindow].rootViewController;
    [rvc presentViewController:p_GrayN_Offical_Scanner animated:YES completion:nil];
    [p_GrayN_Offical_Scanner GrayN_AuthorityConfirm];
    p_GrayN_Offical_Scanner.m_GrayN_Scanner_ResultBlock = ^(NSString *value) {
        GrayNcommon::GrayN_ConsoleLog(@"二维码tokenId=%@", value);

        if (![value isEqualToString:@""]) {
            GrayNcommon::m_GrayN_QRCodeTokenId = [value UTF8String];
            GrayN_LoadingUI::GetInstance().GrayN_ShowWaitMainThread(GrayNcommon::GrayNcommonGetLocalLang(GrayN_WaitingString));
            GrayN_UserCenter::GetInstance().GrayN_UserCenter_QRScanner_GrayN();
        } else {
            
        }
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:value message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [alertView show];
    };
}
void GrayN_Offical::GrayN_Offical_ShowQRConfirmView()
{
    [[GrayN_BaseControl GrayN_Share] GrayNshowQRCodeView];
}
void GrayN_Offical::GrayN_Offical_CloseQRConfirmView()
{
    [[GrayN_BaseControl GrayN_Share] GrayNcloseQRCodeView];
}
