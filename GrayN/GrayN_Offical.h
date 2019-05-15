//
//  GrayN_Offical.h
//
//  Created by op-mac1 on 14-3-11.
//  Copyright (c) 2014年 op-mac1. All rights reserved.
//

#import "GrayNjson_cpp.h"
#import  <objc/objc.h>

#import "GrayNconfig.h"
#import "GrayN_Timer_GrayN.h"

GrayN_NameSpace_Start

class GrayN_Offical : public GrayN_TimerObserver
{
public:
    GrayN_Offical();
    ~GrayN_Offical();
public:
    inline static GrayN_Offical &GetInstance()
    {
        static GrayN_Offical GrayNoffical;
        return GrayNoffical;
    }
public:
    void GrayN_Offical_ShowToast(string content, bool ifClose);
    void GrayN_Offical_ShowWelcome(string name);
    void GrayN_Offical_ShowChargeView();
    
    void GrayN_Offical_UserInfoResponse(string info);
    void GrayN_Offical_DeeplinkResponse(string info);
    
    void GrayN_Offical_GetSessionId();
    void GrayN_Offical_GetSessionIdResponse(string info);
    void GrayN_Offical_LoginGetSessionIdResponse();
    
    void GrayN_Offical_ShowUpgradeTipView();
    void GrayN_Offical_ShowBindPhoneView();
    void GrayN_Offical_ShowPayUpgradeView();
    void GrayN_Offical_CustomService();
    void GrayN_Offical_ShowID_Authentication();
    
    void GrayN_Offical_Update();
    
    void GrayN_Offical_RegisterLogin();
    void GrayN_Offical_GetCurrentThirdHiddenNickName(string userId, string&nickName);
    void GrayN_Offical_Logout();
    void GrayN_Offical_SwitchAccount();
    void GrayN_Offical_ShowSwitchAccountView();
    void GrayN_Offical_EnterPlatform();
    void GrayN_Offical_UpdateUserInfo(GrayN_JSON::Value json);
    
//    void CloseOPWindow();
    
//    void ControlRedPoint(GrayN_JSON::Value json);
    
    /*5.1.4*/
    void GrayN_Offical_OpenWebviewWithNavbar(string url);
    /*5.1.9*/
    void GrayN_Offical_DelAllUserInfoAndUpdateLastone(GrayN_JSON::Value json);
    void GrayN_Offical_ShowBindOfficialView();
    /*5.2.0*/
    void GrayN_Offical_GC_Callback(string userName, string currentUserType, bool status);
    
    /*5.2.1*/
    void GrayN_Offical_CodeScanner();
    void GrayN_Offical_ShowQRConfirmView();
    void GrayN_Offical_CloseQRConfirmView();
    /*5.2.3*/
    GrayN_JSON::Value m_GrayN_Offical_LoginData;
public:
    bool m_GrayN_Offical_IsLogining;

//    void startLogTimer(int length);
//    void GrayN_TimeUp();
//    void GrayN_StopTimer();
    
//    GrayN_Timer_GrayN* logTimer;
    bool m_GrayN_Offical_IsHttp;
    id m_GrayN_Offical_TestUrl;
    
    bool m_GrayN_Offical_IsLocalRequest;
};
GrayN_NameSpace_End

