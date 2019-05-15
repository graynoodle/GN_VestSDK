//
//  OPGameSDK.cpp
//
//  Created by op-mac1 on 15-5-6.
//
//
#import "OPGameSDK.h"
#import "GrayNchannel.h"
#import "GrayNSDK.h"
#import "GrayNlogCenter.h"
#import "GrayNpayCenter.h"
#import "GrayNinit.h"
#import "GrayNinitCheck.h"

#import "GrayNlanguage.h"
#import "GrayN_Offical.h"

#import "GrayNAdsBridge.h"

using namespace ourpalmpay;
//using namespace ourpalmLog;
bool OPMonitorInterface()
{
    if (!GrayNcommon::GrayNcommonInit()) {
        return true;
    }

    if (GrayNSDK::m_GrayN_SDK_InitStatus <= 0) {
        GrayNinitCheck::GetInstance().GrayN_CheckInitStatus();
        return true;
    }

    if (GrayNchannel::GetInstance().m_GrayN_IsLogining) {
        GrayNcommon::GrayN_DebugLog("opLogining...");
        return true;
    }
    if (!GrayNSDK::m_GrayN_SDK_IsShowUpdate) {
        GrayNcommon::GrayN_ConsoleLog("opIsNotShowUpdate");
        return true;
    }

    return false;
}
OPGameSDK::OPGameSDK()
{

    pfuncInit = NULL;
    pfuncLogin = NULL;
    pfuncLogout = NULL;

}
OPGameSDK::~OPGameSDK()
{
    
}
const char* OPGameSDK::GetEnableInterface()
{
    return GrayNchannel::GetInstance().GrayN_GetEnable_Interface();
}
#pragma mark- Init
void OPGameSDK::Init(void* controller)
{
    GrayNcommon::GrayN_ConsoleLog("opStartInit...");
    if (controller == NULL) {
        GrayNcommon::GrayN_ConsoleLog("初始化参数controller不能为空！");
        string body(GrayNcommon::GrayNcommonGetLocalLang(GrayN_InitFailed));
        body.append(GrayN_Init_PARAM_ERROR);
        GrayN_LoadingUI::GetInstance().GrayN_ShowMsgBox(GrayNcommon::GrayNcommonGetLocalLang(GrayN_Title), GrayNcommon::GrayNcommonGetLocalLang(body.c_str()), 0, 1);
        GrayNSDK::GrayN_SDK_CallBackInit(false, GrayN_JSON_INITPARAM_ERROR);
        return;
    }
    
    if (!GrayNcommon::GrayNcommonInit()) {
        string body(GrayNcommon::GrayNcommonGetLocalLang(GrayN_InitFailed));
        body.append(GrayN_Init_PLIST_ERROR);
        GrayN_LoadingUI::GetInstance().GrayN_ShowMsgBox(GrayNcommon::GrayNcommonGetLocalLang(GrayN_Title), GrayNcommon::GrayNcommonGetLocalLang(body.c_str()), 0, 1);
        GrayNSDK::GrayN_SDK_CallBackInit(false, GrayN_JSON_INITPLIST_ERROR);
        return;
    }
    
    if (!GrayNcommon::GrayNcommonInitConfig()) {
        string body(GrayNcommon::GrayNcommonGetLocalLang(GrayN_InitFailed));
        body.append(GrayN_Init_CFG_ERROR);
        GrayN_LoadingUI::GetInstance().GrayN_ShowMsgBox(GrayNcommon::GrayNcommonGetLocalLang(GrayN_Title), GrayNcommon::GrayNcommonGetLocalLang(body.c_str()), 0, 1);
        GrayNSDK::GrayN_SDK_CallBackInit(false, GrayN_JSON_INITCFG_ERROR);
        return;
    }

    /*5.1.0 通过info.plist控制*/
    GrayNcommon::m_GrayN_RootViewController = controller;

    GrayNSDK::GrayN_SDK_Init();
    /*9.0.1 添加第三方统计*/
    OPAdsBridge::GetInstance().checkInit();

}
void OPGameSDK::InitCallBack(void (* pf)(bool result,const char* jsonStr))
{
    pfuncInit = pf;
    GrayNSDK::GrayN_SDK_InitCallBack(pfuncInit);
}
#pragma mark- Login
void OPGameSDK::RegisterLogin()
{
    GrayN_SDK_Init::GetInstance().p_GrayN_IsClickLogin = true;

    if (OPMonitorInterface()) {
        return;
    }
    
    GrayNchannel::GetInstance().GrayN_ChannelLogin();
}
void OPGameSDK::RegisterLoginCallBack(void (* pf)(bool result,const char* uid))
{
    GrayNSDK::GrayN_SDK_RegisterLoginCallBack(pf);
}

void OPGameSDK::RegisterLogoutCallBack(void (* pf)(bool result,const char* uid))
{
    GrayNSDK::GrayN_SDK_RegisterLogoutCallBack(pf);
}

void OPGameSDK::SendLog(const char* logID, const char* logKey ,const char* logValJson)
{
    GrayNlogCenter::GetInstance().GrayN_Log_CreateLog(logID, logKey, logValJson);
}

void OPGameSDK::SetListener(PurchaseListener* listener)
{
    GrayNSDK::GrayN_SDK_SetPayListener(listener);
}

void OPGameSDK::Purchase(OPPurchaseParam params)
{
    GrayNSDK::GrayN_SDK_GotoPurchase(params);
}

bool OPGameSDK::IsLogin()
{
    return GrayNchannel::GetInstance().GrayN_ChannelIsLogin();
}

string OPGameSDK::GetUserId()
{
    return GrayNcommon::m_GrayN_Game_UserId;
}

string OPGameSDK::GetTokenId()
{
    return GrayNcommon::m_GrayN_SessionId;
}
string OPGameSDK::GetSDKVersion()
{
    return GrayNcommon::m_GrayN_SDKVersion;
}

void OPGameSDK::SetGameLoginInfo(OPGameInfo opParam,OPGameType opGameType)
{
    GrayNSDK::GrayN_SDK_SetGameLoginInfo(opParam, opGameType);
    GrayNchannel::GetInstance().GrayN_ChannelSetGameLoginInfo(opParam, opGameType);
}

void OPGameSDK::EnterPlatform()
{
    GrayNchannel::GetInstance().GrayN_ChannelEnterPlatform();
}

void OPGameSDK::UserFeedback()
{
    GrayNchannel::GetInstance().GrayN_ChannelCustomService();
}

void OPGameSDK::SwitchAccount()
{
    GrayN_SDK_Init::GetInstance().p_GrayN_IsClickLogin = true;

    if (OPMonitorInterface()) {
        return;
    }
    
    GrayNchannel::GetInstance().GrayN_ChannelSwitchAccount();
}

void OPGameSDK::LogOut()
{
    GrayNchannel::GetInstance().GrayN_ChannelLogout();
}
/*5.1.2 初始化成功后才能调用此接口*/
bool OPGameSDK::HandleOpenURL(void* url)
{
    /*5.2.0*/
    GrayNchannel::GetInstance().GrayN_ChannelCheckHandleOpenURL(url);
    /*5.2.0*/
    if (GrayN_SDK_Init::GetInstance().GrayN_GetInitStatus()) {
        return GrayNchannel::GetInstance().GrayN_ChannelHandleOpenUrl(url);
    }
    return true;
}

void OPGameSDK::HandleOpenURL(void* url, void* application)
{
    /*5.2.0*/
    GrayNchannel::GetInstance().GrayN_ChannelCheckHandleOpenURL(url);
    /*5.2.0*/
    if (GrayN_SDK_Init::GetInstance().GrayN_GetInitStatus()) {
        GrayNchannel::GetInstance().GrayN_ChannelHandleOpenUrl(url, application);
    }
}
bool OPGameSDK::HandleOpenURL(void* application,void* url, void* sourceApplication,void* annotation)
{
    /*5.2.0*/
    GrayNchannel::GetInstance().GrayN_ChannelCheckHandleOpenURL(url);
    /*5.2.0*/
    if (GrayN_SDK_Init::GetInstance().GrayN_GetInitStatus()) {
        return GrayNchannel::GetInstance().GrayN_ChannelHandleOpenUrl(application, url, sourceApplication, annotation);
    }
    return true;
}

void OPGameSDK::SetSpecKey(const char* specKeyJson)
{
    GrayNlogCenter::GetInstance().GrayN_Log_SetSpecialKey(specKeyJson);
}

bool OPGameSDK::ApplicationDidFinishLaunchingWithOptions(void *application,void *launchOptions)
{
    GrayNchannel::GetInstance().GrayN_PreInit();
    if (!GrayNcommon::GrayNcommonInit()) {
        return false;
    }
    return GrayNchannel::GetInstance().GrayN_ChannelApplicationDidFinishLaunchingWithOptions(application, launchOptions);
}

bool OPGameSDK::ApplicationSupportedInterfaceOrientationsForWindow()
{
    return GrayNchannel::GetInstance().GrayN_ChannelApplicationSupportedInterfaceOrientationsForWindow();
}

unsigned int OPGameSDK::ApplicationSupportedInterfaceOrientationsForWindow(void *application,void *window)
{
    return GrayNchannel::GetInstance().GrayN_ChannelApplicationSupportedInterfaceOrientationsForWindow(application, window);
}
bool OPGameSDK::ShouldAutoRotate()
{
    return GrayNchannel::GetInstance().GrayN_ChannelShouldAutoRotate();
}
void OPGameSDK::ApplicationWillEnterForeground(id application)
{
    // 获取支付结果
    if (GrayNpayCenter::GetInstance().m_GrayN_Pay_IsPurchasing) {
        GrayNpayCenter::GetInstance().GrayN_Pay_GetPayResult();
    }
    GrayNchannel::GetInstance().GrayN_ChannelShowPausePage();
    GrayNchannel::GetInstance().GrayN_ChannelApplicationWillEnterForeground(application);
}

//礼包码接口
void OPGameSDK::ExchangeGameCode(const char* gameCode,const char *deliverUrl,const char *extendParams)
{
    GrayNSDK::GrayN_SDK_ExchangeGameCode(gameCode, deliverUrl, extendParams);
}
//SDK信息
const char* OPGameSDK::GetChannelInfo()
{
    GrayNcommon::GrayNcommonInit();
    return GrayNcommon::m_GrayNchannel_Info.c_str();
}
string OPGameSDK::GetServiceId()
{
    return GrayNcommon::m_GrayN_ServiceId;
}

string OPGameSDK::GetChannelId()
{
    return GrayNcommon::m_GrayN_ChannelId;
}
string OPGameSDK::GetChannelName()
{
    return GrayNcommon::m_GrayN_Channel_Name;
}
string OPGameSDK::GetDeviceGroupId()
{
    return GrayNcommon::m_GrayN_DeviceGroupId;
}
string OPGameSDK::GetLocaleId()
{
    return GrayNcommon::m_GrayN_LocaleId;
}
void OPGameSDK::OpenWebviewWithNavbar(string url)
{
    GrayN_Offical::GetInstance().GrayN_Offical_OpenWebviewWithNavbar(url);
}
void OPGameSDK::CodeScanner()
{
    GrayN_Offical::GetInstance().GrayN_Offical_CodeScanner();
}
/*9.0.1*/
void OPGameSDK::LogEvent(const char* ourpalm_event_key, const char* event_paras)
{
    if (event_paras == NULL) {
        event_paras = "";
    }
    OPAdsBridge::GetInstance().logEvent(ourpalm_event_key, event_paras);
}
