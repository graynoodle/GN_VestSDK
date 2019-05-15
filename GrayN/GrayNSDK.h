//
//  GrayNSDK.h
//  GrayNSDK
//
//  Created by op-mac1 on 14-1-7.
//  Copyright (c) 2014年 op-mac1. All rights reserved.
//

#ifndef __GrayNSDK__GrayNSDK__
#define __GrayNSDK__GrayNSDK__

#import <iostream>
#import "GrayNjson_cpp.h"

#import "GrayNcommon.h"
#import "GrayNconfig.h"
#import "GrayN_UserCenter.h"
#import "OPGameSDK.h"

GrayN_NameSpace_Start

class GrayNSDK
{
public:
    //初始化
    static void GrayN_SDK_Init();
    
    //初始化回调
    static void GrayN_SDK_InitCallBack(void (* pf)(bool result,const char* jsonStr)) { p_GrayN_SDKfuncInit = pf; }
    static void GrayN_SDK_CallBackInit(bool result,const char* jsonStr);
    static void GrayN_SDK_SetGameLoginInfo(OPGameInfo opParam,OPGameType opGameType);
    
    //登录回调
    static void GrayN_SDK_RegisterLoginCallBack(void (* pf)(bool result,const char* jsonStr)) { p_GrayN_SDKfuncLogin = pf; }//注册登录回调
    static void GrayN_SDK_CallBackLogin(bool result,const char* jsonStr);
    
    //登出回调
    static void GrayN_SDK_RegisterLogoutCallBack(void (* pf)(bool result,const char* jsonStr)){p_GrayN_SDKfuncLogout = pf;};
    static void GrayN_SDK_CallBackLogout(bool result,const char* jsonStr);
    
private:
    static void (* p_GrayN_SDKfuncInit)(bool result,const char * jsonStr);
    static void (* p_GrayN_SDKfuncLogin)(bool result,const char* jsonStr);
    static void (* p_GrayN_SDKfuncLogout)(bool result,const char * jsonStr);
    
public:
    //购买接口
    static void GrayN_SDK_SetPayListener(PurchaseListener* listener);
    static void GrayN_SDK_GotoPurchase(OPPurchaseParam param);
    static void GrayN_SDK_ExchangeGameCode(const char* gamecode,const char *deleverUrl,const char *extendParams);
    
    static void GrayN_SDK_OnPurchaseResult(bool result, const char* jsonStr);
    static void GrayN_SDK_OnExchangeGamecodeResult(bool result, const char* jsonStr);
    static void GrayN_SDK_SendUserRegisterLoginLog();

private:
    static PurchaseListener* p_GrayN_SDK_PayObserver;
    
    
public:
    /* 2.0 初始化接口参数 */
    static std::string m_GrayN_SDK_InitJson; // 初始化返回Json
    static std::string m_GrayN_SDK_UserCenterEntryUrl;     // 用户中心入口地址
    static std::string m_GrayN_SDK_UserCenterCoreUrl;      // 用户中心核心地址
    static std::string m_GrayN_SDK_BillingUrl;          // 计费中心地址
    static bool m_GrayN_SDK_LogSwitch;              // SDK日志开关
    static bool m_GrayN_SDK_ChargeLogSwitch;           // SDK计费日志开关

    static bool m_GrayN_SDK_ProtocolSwitch;            // 协议开关
    static bool m_GrayN_SDK_StoreAdSwitch;             // appstore广告开关
    static bool m_GrayN_SDK_ForceTouristBindSwitch;    // 计费强制绑定账号开关
    static bool m_GrayN_SDK_SandBoxSwitch;             // 沙盒开关
    /*5.1.9 绑定官网账号开关*/
    static bool m_GrayN_SDK_BindOfficialUserSwitch;             

    static std::string m_GrayN_SDK_GscFrontUrl;        // GSC前端地址(客服)

    static std::string m_GrayN_SDK_NoticeSwitch;       // 公告开关
    static std::string m_GrayN_SDK_NoticeContent;      // 公告内容
    
    static std::string m_GrayN_SDK_UpdateType;         //
    static std::string m_GrayN_SDK_UpdateVersion;      //
    static std::string m_GrayN_SDK_UpdateDesc;         //
    static std::string m_GrayN_SDK_UpdateFileSize;     //
    static std::string m_GrayN_SDK_UpdateUrl;          //
    static std::string m_GrayN_SDK_LimitDesc;          //
    static std::string m_GrayN_SDK_IsLimit;            //
    static std::string m_GrayN_SDK_IdentityAuth;       // 身份认证
    static std::string m_GrayN_SDK_PayIdentityAuth;    // 支付实名认证
    /*5.1.4*/
    static std::string m_GrayN_SDK_IdentityStatus;     // 当前账号实名类型
    /*登录注册模块*/
    static std::string m_GrayN_SDK_LoginUrl;           // 首登页面UI
    static std::string m_GrayN_SDK_ChangeLoginUrl;     // 切换账户UI页
    static std::string m_GrayN_SDK_TourAutoLoginUpgradeUrl; // 游客自动登录后进入游客升级账户提示UI页
    static std::string m_GrayN_SDK_OfficalAutoLoginBindMobileUrl;  // 正式账号自动登录后需要强绑手机UI页
    static std::string m_GrayN_SDK_NoticeUrl;          // 登录前置提示UI页
    /*5.1.9*/
    static std::string m_GrayN_SDK_PageUrl; // 页面首地址

    /*支付模块*/
    static std::string m_GrayN_SDK_PayUrl;             // 发起支付后的页面UI
    static std::string m_GrayN_SDK_PayUrlUpgradeUrl;      // 支付时 游客 绑定官网账号
    
    /*用户中心模块*/
    static std::string m_GrayN_SDK_PersonalCenterUrl;  // 悬浮框页面UI
    static std::string m_GrayN_SDK_CustomerUrl;        // 独立客服问题页面UI
    static std::string m_GrayN_SDK_IdentityAuthUrl;    // 身份认证UI

    /********************************************************/

    
    static std::string m_GrayN_SDK_BillingDomainName;  // 计费中心域名地址
    static std::string m_GrayN_SDK_AppstoreVerifyUrl;  // appstore计费验证地址
    static std::string m_GrayN_SDK_AppLogUrl;          // appstore日志发送地址
    static std::string m_GrayN_SDK_AppErrorUrl;        // 错误日志收集地址
    static std::string m_GrayN_SDK_ActivateCodeSwitch; // 激活码开关
    static std::string m_GrayN_SDK_OpenActivateWin;    // 是否展示激活框
    static std::string m_GrayN_SDK_ActivateCode;       // 激活码
    static std::string m_GrayN_SDK_ActivateTokenId;    // 激活的tokenId

public:
//    static bool mSDKInitStatus;             //第三方SDK初始化状态，注意：必须先初始化第三方SDK，再调用掌趣初始化
    //掌趣初始化状态，当初始化未成功，游戏调用登录接口时需要此状态值判断该执行什么操作
    //0:初始值
    //1:初始化完成，并且不更新
    //2:初始化完成，但更新失败
    //3:初始化失败，但读取默认配置文件成功
    //4:初始化完成，并且要更新
    //5:初始化完成，并且正在显示更新界面，这时候调用登录接口会return
    //-1:初始化失败，且读取默认配置文件也失败
    //-2:重新初始化
    static int m_GrayN_SDK_InitStatus;
//    static bool mIfLoginClick;      //在更新界面，用于判断是否调用登录接口
    // 是否使用手机注册
    static bool m_GrayN_SDK_IsShowUpdate;     // 更新流程完毕才可登录
};

GrayN_NameSpace_End

#endif /* defined(__GrayNSDK__GrayNSDK__) */
