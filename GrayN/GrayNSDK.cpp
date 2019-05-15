//
//  GrayNSDK.cpp
//  GrayNSDK
//
//  Created by op-mac1 on 14-1-7.
//  Copyright (c) 2014年 op-mac1. All rights reserved.
//

#import "GrayNSDK.h"
#import "GrayNpayCenter.h"
#import "GrayN_UserCenter.h"
#import "GrayNlogCenter.h"

#import "GrayN_LoadingUI.h"
#import "GrayNconfig.h"
#import "GrayN_Offical.h"


GrayNusing_NameSpace;

std::string GrayNSDK::m_GrayN_SDK_InitJson;          // 初始化返回Json
std::string GrayNSDK::m_GrayN_SDK_UserCenterEntryUrl;   //用户中心地址
std::string GrayNSDK::m_GrayN_SDK_UserCenterCoreUrl;    //用户中心地址
std::string GrayNSDK::m_GrayN_SDK_BillingUrl;        //计费接口地址
bool GrayNSDK::m_GrayN_SDK_LogSwitch;             //SDK日志开关
bool GrayNSDK::m_GrayN_SDK_ChargeLogSwitch = true;
bool GrayNSDK::m_GrayN_SDK_ProtocolSwitch;           //协议开关
bool GrayNSDK::m_GrayN_SDK_StoreAdSwitch;            //appstore广告开关
bool GrayNSDK::m_GrayN_SDK_ForceTouristBindSwitch;   // 计费强制绑定账号开关
bool GrayNSDK::m_GrayN_SDK_SandBoxSwitch;
/*5.1.9 绑定官网账号开关*/
bool GrayNSDK::m_GrayN_SDK_BindOfficialUserSwitch;
std::string GrayNSDK::m_GrayN_SDK_GscFrontUrl;       //GSC前端地址
std::string GrayNSDK::m_GrayN_SDK_NoticeSwitch;      // 公告开关
std::string GrayNSDK::m_GrayN_SDK_NoticeContent;     // 公告内容
std::string GrayNSDK::m_GrayN_SDK_UpdateType;
std::string GrayNSDK::m_GrayN_SDK_UpdateVersion;      //
std::string GrayNSDK::m_GrayN_SDK_UpdateDesc;         //
std::string GrayNSDK::m_GrayN_SDK_UpdateFileSize;     //
std::string GrayNSDK::m_GrayN_SDK_UpdateUrl;          //
std::string GrayNSDK::m_GrayN_SDK_LimitDesc;
std::string GrayNSDK::m_GrayN_SDK_IsLimit;            //
std::string GrayNSDK::m_GrayN_SDK_IdentityAuth;       // 身份认证
std::string GrayNSDK::m_GrayN_SDK_IdentityStatus;

std::string GrayNSDK::m_GrayN_SDK_LoginUrl;           // 首登页面UI
std::string GrayNSDK::m_GrayN_SDK_ChangeLoginUrl;     // 切换账户UI页
std::string GrayNSDK::m_GrayN_SDK_TourAutoLoginUpgradeUrl; // 游客自动登录后进入游客升级账户提示UI页
std::string GrayNSDK::m_GrayN_SDK_OfficalAutoLoginBindMobileUrl; // 正式账号自动登录后需要强绑手机UI页
std::string GrayNSDK::m_GrayN_SDK_NoticeUrl;          // 登录前置提示UI页
std::string GrayNSDK::m_GrayN_SDK_PayUrl;             // 发起支付后的页面UI
std::string GrayNSDK::m_GrayN_SDK_PersonalCenterUrl;  // 悬浮框页面UI
std::string GrayNSDK::m_GrayN_SDK_CustomerUrl;        // 独立客服问题页面UI
std::string GrayNSDK::m_GrayN_SDK_IdentityAuthUrl;    // 身份认证UI
std::string GrayNSDK::m_GrayN_SDK_PayIdentityAuth;    // 支付实名认证
std::string GrayNSDK::m_GrayN_SDK_PayUrlUpgradeUrl;      // 支付时 游客 绑定官网账号
std::string GrayNSDK::m_GrayN_SDK_PageUrl;      // 页面首地址

std::string GrayNSDK::m_GrayN_SDK_BillingDomainName;
std::string GrayNSDK::m_GrayN_SDK_AppstoreVerifyUrl;
std::string GrayNSDK::m_GrayN_SDK_AppLogUrl;
std::string GrayNSDK::m_GrayN_SDK_AppErrorUrl;
std::string GrayNSDK::m_GrayN_SDK_ActivateCodeSwitch;        //激活码开关
std::string GrayNSDK::m_GrayN_SDK_OpenActivateWin;           //是否展示激活框
std::string GrayNSDK::m_GrayN_SDK_ActivateTokenId;
std::string GrayNSDK::m_GrayN_SDK_ActivateCode;

//bool GrayNSDK::mSDKInitStatus = false;
int GrayNSDK::m_GrayN_SDK_InitStatus;
//bool GrayNSDK::mIfLoginClick;
bool GrayNSDK::m_GrayN_SDK_IsShowUpdate=false;

void (* GrayNSDK::p_GrayN_SDKfuncInit)(bool result,const char * jsonStr);
void (* GrayNSDK::p_GrayN_SDKfuncLogin)(bool result,const char* jsonStr);
void (* GrayNSDK::p_GrayN_SDKfuncLogout)(bool result,const char * jsonStr);

PurchaseListener* GrayNSDK::p_GrayN_SDK_PayObserver=NULL;

void GrayNSDK::GrayN_SDK_Init()
{
    //游戏版本号
    GrayNcommon::GrayN_ConsoleLog("opGame_Version=%s", GrayNcommon::m_GrayN_GameVersion.c_str());
            
    //使用默认的统计地址，为了跟踪初始化的问题
    m_GrayN_SDK_AppErrorUrl = GrayNcommon::m_GrayN_StatisticalUrl;
    m_GrayN_SDK_AppErrorUrl.append(GrayNappstoreLogRoute);

    //广告默认是打开的
    m_GrayN_SDK_StoreAdSwitch = 1;
    
    //头信息
    GrayNcommon::GrayNgetHttpStaticHeader();
    
    // 渠道初始化
    GrayNchannel::GetInstance().GrayN_ChannelInit();
}

void GrayNSDK::GrayN_SDK_CallBackInit(bool result,const char* jsonStr)
{
    GrayN_LoadingUI::GetInstance().GrayN_CloseWaitMainThread();
        
    if(p_GrayN_SDKfuncInit){
        (* p_GrayN_SDKfuncInit)(result,jsonStr);
    }else{
        GrayNcommon::GrayN_ConsoleLog("未设置InitCallBack()！");
    }
//    mSDKInitStatus = result;
    GrayNcommon::GrayN_ConsoleLog(jsonStr);
}





void GrayNSDK::GrayN_SDK_SetPayListener(PurchaseListener* listener)
{
    p_GrayN_SDK_PayObserver = listener;
}

void GrayNSDK::GrayN_SDK_CallBackLogin(bool result,const char* jsonStr)
{
    GrayN_LoadingUI::GetInstance().GrayN_CloseWaitMainThread();
    GrayNchannel::GetInstance().m_GrayN_IsLogining = false;
    if (result) {
        GrayNcommon::GrayN_ConsoleLog("掌趣登录成功");
        GrayNchannel::GetInstance().GrayN_SetLoginStatus(true);
        // 启动用户中心心跳，先关闭之前的心跳，然后再启动新的心跳
        GrayN_UserCenter::GetInstance().GrayN_UserCenter_StopHeartBeat();
        GrayN_UserCenter::GetInstance().GrayN_UserCenter_StartHeartBeat();
    } else {
        GrayNcommon::GrayN_ConsoleLog("掌趣登录失败");
    }
//    GrayNchannel::GetInstance().CloseAdmob();

    if (p_GrayN_SDKfuncLogin) {
        (* p_GrayN_SDKfuncLogin)(result,jsonStr);
    }else{
        GrayNcommon::GrayN_ConsoleLog("未设置RegisteLoginCallBack()！");
    }
}

void GrayNSDK::GrayN_SDK_SendUserRegisterLoginLog()
{
    //设置日志的账号属性
    GrayN_Log_Account account;
    account.m_GrayN_Log_UserId = GrayNcommon::m_GrayN_Game_UserId;
    account.m_GrayN_Log_UserName = GrayNcommon::m_GrayN_Game_UserName;
    account.m_GrayN_Log_UserCenterServer.m_GrayN_Log_UserCenterUrl = GrayNSDK::m_GrayN_SDK_UserCenterEntryUrl;
    GrayNlogCenter::GetInstance().GrayN_Log_SetAccountInfo(account);
    
    // 日志
    GrayN_Log_Data log;
    log.m_GrayN_Log_Data_UserId = GrayNcommon::m_GrayN_Game_UserId;              // 用户中心登录ID
    log.m_GrayN_Log_LoginType = GrayNcommon::m_GrayN_LoginType;         // 注册登录类型
    //    cout<<log.m_GrayN_Log_LoginType<<endl;
    string::size_type idx = log.m_GrayN_Log_LoginType.find("Register");
    if (idx !=string::npos) {
        log.m_GrayN_Log_LogId = "2";
        GrayNcommon::GrayN_DebugLog("发送注册日志loginType=%s!!!",log.m_GrayN_Log_LoginType.c_str());
    } else {
        log.m_GrayN_Log_LogId = "3";
        GrayNcommon::GrayN_DebugLog("发送登录日志loginType=%s!!!",log.m_GrayN_Log_LoginType.c_str());
    }
    GrayNlogCenter::GetInstance().GrayN_Log_CreateLog(log);
}

void GrayNSDK::GrayN_SDK_SetGameLoginInfo(OPGameInfo opParam,OPGameType opGameType)
{
    GrayNcommon::m_GrayN_Game_RoleId = opParam.mGame_RoleId;
    GrayNcommon::m_GrayN_Game_ServerId = opParam.mGame_ServerId;
    GrayNcommon::m_GrayN_Game_RoleName = opParam.mGame_RoleName;
    GrayNcommon::m_GrayN_Game_ServerName = opParam.mGame_ServerName;
    
    //设置日志的账号属性
    GrayN_Log_Account account;
    account.m_GrayN_Log_UserId = GrayNcommon::m_GrayN_Game_UserId;
    account.m_GrayN_Log_UserName = GrayNcommon::m_GrayN_Game_UserName;
    account.m_GrayN_Log_UserCenterServer.m_GrayN_Log_UserCenterUrl = GrayNSDK::m_GrayN_SDK_UserCenterEntryUrl;
    GrayNlogCenter::GetInstance().GrayN_Log_SetAccountInfo(account);
    //设置日志的角色属性
    GrayN_Log_Role role;
    role.m_GrayN_Log_RoleId = opParam.mGame_RoleId;
    role.m_GrayN_Log_RoleName = opParam.mGame_RoleName;
    GrayNlogCenter::GetInstance().GrayN_Log_SetRoleInfo(role);
    //生成日志
    GrayN_Log_Data log;
    log.m_GrayN_Log_Data_UserId = GrayNcommon::m_GrayN_Game_UserId;                 //用户中心登录ID
    //    6	角色注册日志
    //    7	角色登录日志
    if (opGameType == kGameRegister) {
        log.m_GrayN_Log_LogId = "6";
        log.m_GrayN_Log_Logkey = "role-register";
    } else if (opGameType == kGameLogin) {
        log.m_GrayN_Log_LogId = "7";
        log.m_GrayN_Log_Logkey = "role-login";
    } else{
        return;
    }
    GrayN_JSON::Value logJson;
    logJson["uid"] = GrayNcommon::m_GrayN_Game_UserId;
    logJson["logicDeployNodeCode"] = opParam.mGame_ServerId;
    logJson["roleId"] = opParam.mGame_RoleId;
    logJson["roleName"] = opParam.mGame_RoleName;
    logJson["roleLevel"] = opParam.mGame_RoleLevel;
    logJson["roleVipLevel"] = opParam.mGame_RoleVipLevel;
    GrayN_JSON::FastWriter fast_writer;
    log.m_GrayN_Log_Data = fast_writer.write(logJson).c_str();
    
    GrayNlogCenter::GetInstance().GrayN_Log_CreateLog(log);
    
    //发送用户与角色关联信息
    if (opGameType == kGameLogin) {
        GrayN_UserCenter *opUserCenter = new GrayN_UserCenter();
        opUserCenter->GrayN_UserCenter_RoleInfoCorrespondUserInfo(opUserCenter);        //将对象传递进去是为了释放
    }
}
void GrayN_SDK_ClearData()
{
    //清理数据
    GrayNcommon::GrayNclearUserLocalData();
    
    //最好放在这里，例如平台内的注销
    GrayN_UserCenter::GetInstance().GrayN_UserCenter_StopHeartBeat();         //停止心跳
    // 调用日志SDK接口清理日志数据
    //重新设置日志的属性
    GrayN_Log_Account account;
    account.m_GrayN_Log_UserId = GrayNcommon::m_GrayN_Game_UserId;
    account.m_GrayN_Log_UserName = GrayNcommon::m_GrayN_Game_UserName;
    account.m_GrayN_Log_UserCenterServer.m_GrayN_Log_UserCenterUrl = GrayNSDK::m_GrayN_SDK_UserCenterEntryUrl;
    GrayNlogCenter::GetInstance().GrayN_Log_SetAccountInfo(account);
    GrayN_Log_Role role;
    role.m_GrayN_Log_RoleId.clear();
    role.m_GrayN_Log_RoleName.clear();
    GrayNlogCenter::GetInstance().GrayN_Log_SetRoleInfo(role);       //将日志中的数据清理一下
    
}
void GrayNSDK::GrayN_SDK_CallBackLogout(bool result,const char* jsonStr)
{
    GrayNchannel::GetInstance().GrayN_SetLoginStatus(false);
    GrayNchannel::GetInstance().m_GrayN_IsLogining = false;
    
    GrayN_SDK_ClearData();
    
    if (p_GrayN_SDKfuncLogout){
        (* p_GrayN_SDKfuncLogout)(result,jsonStr);
    }else{
        GrayNcommon::GrayN_ConsoleLog("未设置RegisterLogoutCallBack()！");
    }
}



void GrayNSDK::GrayN_SDK_GotoPurchase(OPPurchaseParam param)
{
    if (p_GrayN_SDK_PayObserver == NULL) {
        GrayNcommon::GrayN_ConsoleLog("未设置SetListener()");
        return;
    }

    GrayNpayCenter::GetInstance().GrayN_Pay_GotoPurchase(param);
}

void GrayNSDK::GrayN_SDK_ExchangeGameCode(const char* gamecode,const char *deleverUrl,const char *extendParams)
{
    if (p_GrayN_SDK_PayObserver==NULL) {
        GrayNcommon::GrayN_ConsoleLog("未设置SetListener()");
        return;
    }
    GrayNpayCenter::GetInstance().GrayN_Pay_ExchangeGameCode(gamecode,deleverUrl,extendParams);
}

void GrayNSDK::GrayN_SDK_OnPurchaseResult(bool result, const char* jsonStr)
{
    if (p_GrayN_SDK_PayObserver==NULL) {
        GrayNcommon::GrayN_ConsoleLog("未设置SetListener()");
        return;
    }
    p_GrayN_SDK_PayObserver->OnPurchaseResult(result, jsonStr);
}

void GrayNSDK::GrayN_SDK_OnExchangeGamecodeResult(bool result, const char* jsonStr)
{
    if (p_GrayN_SDK_PayObserver==NULL) {
        GrayNcommon::GrayN_ConsoleLog("未设置SetListener()");
        return;
    }
    p_GrayN_SDK_PayObserver->OnGamecodeResult(result, jsonStr);
}
