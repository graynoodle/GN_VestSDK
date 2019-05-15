//
//  GrayN_UserCenter.h
//
//  Created by op-mac1 on 14-1-7.
//  Copyright (c) 2014年 op-mac1. All rights reserved.
//



#import <iostream>
#import "GrayNcommon.h"
#import "GrayNconfig.h"
#import "GrayN_LoadingUI.h"
#import "GrayNSDK.h"
#import "GrayNchannel.h"
#import "GrayNasyn_CallBack.h"
#import "GrayN_UserHeart.h"

/*5.1.2*/
#import "GrayN_Https_GrayN.h"
/*5.1.2*/

GrayNusing_NameSpace;
GrayN_NameSpace_Start

class GrayN_UserHeart;
class GrayN_UserCenter: public GrayN_Http_GrayN::GrayN_HttpListener, public p_GrayN_UserHeart_Observer
{
public:
     GrayN_UserCenter();
    ~GrayN_UserCenter();
public:
    inline static GrayN_UserCenter& GetInstance(){
        static GrayN_UserCenter GrayNuserCenter;
        return GrayNuserCenter;
    }
public:
    enum GrayN_UserCenter_HttpType
    {
        GrayN_UserCenter_Login,               // 欢畅登录
        GrayN_UserCenter_Role_Correspond_User,// 用户角色关联
        GrayN_UserCenter_LoginVerify,         // 欢畅登录二次验证
        GrayN_UserCenter_Get_SessionId,       // 获取当前session后，登录刷新用户信息
        GrayN_UserCenter_GC_LoginVerify,      // gamecenter验证绑定官网账号
        GrayN_UserCenter_QR_Scanner,          // 扫码通信
        GrayN_UserCenter_QR_ScannerConfirm    // 扫码确认
    };
    // 自动登录状态
    bool m_GrayN_UserCenter_IsAutoLogin;
    
public:
    // 快登
    void GrayN_UserCenter_SpeedyLogin(bool isAutoLogin, bool getSessionId);
    // 登陆注册
    void GrayN_UserCenter_CommonLogin(string userName, string userPwd, bool isAutoLogin, bool getSessionId);
    // 用户中心id与角色id相关联
    void GrayN_UserCenter_RoleInfoCorrespondUserInfo(GrayN_UserCenter *obj);
    // 登录验证
    void GrayN_UserCenter_LoginVerify_GrayN(GrayN_JSON::Value &verifyJson);
    
    // 5.2.0
    void GrayN_UserCenter_GCLoginVerify_GrayN(string playerID, string alias);
    // 5.2.1 手机扫二维码
    void GrayN_UserCenter_QRScanner_GrayN();
    void GrayN_UserCenter_QRScannerConfirm_GrayN();

private:
    // 网络连接
    void GrayN_UserCenter_ConnectNetwork(int httpType, const char* url, string data);
    // 解析错误
    void GrayN_UserCenter_ParseHttpError(void* args);
    // 解析数据
    void GrayN_UserCenter_ParseHttpData(GrayN_Http_GrayN* client);
    // 登录信息解析
    void GrayN_UserCenter_ParseLoginInfo();
    // 重新获取session验证
    void GrayN_UserCenter_ParseGetSessionIdLogin();
    // 登录验证解析
    void GrayN_UserCenter_ParseLoginVerify();
    // 5.2.0
    void GrayN_UserCenter_GCParseLoginVerify();
    
    // 用户角色关联解析
    void GrayN_UserCenter_ParseRoleInfoCorrespondUserInfo();
    // 5.2.1 手机扫二维码
    void GrayN_UserCenter_ParseQRScanner();
    void GrayN_UserCenter_ParseQRScannerConfirm();
public:
    virtual void GrayN_On_HttpError(GrayN_Http_GrayN* client, GrayN_HttpErrorCode code);
    virtual void GrayN_On_HttpEvent(GrayN_Http_GrayN* client, GrayN_HttpEventCode code);
    virtual void GrayN_On_HttpResponse(GrayN_Http_GrayN* client,int code,int context_length,int startPos,int endPos,int totalContext,const char* data);
    virtual void GrayN_On_Http_Data(GrayN_Http_GrayN* client,const char* data,int count);
    virtual void GrayN_On_Http_Over();
    
private:
    static void GrayN_UserCenter_ProcessHttpError(void* args);
    static void GrayN_UserCenter_ProcessParseHttpData(void* args);
    
    // Des解密，并检查JSON数据是否异常
    bool GrayN_UserCenter_ParseDesData(GrayN_JSON::Value &json_object);
    
public:
    void GrayN_UserCenter_StartHeartBeat();
    void GrayN_UserCenter_StopHeartBeat();
    
private:
    int p_GrayN_UserCenter_HttpType;
    GrayN_UserHeart* p_GrayN_UserCenter_UserHeart;
    long long p_GrayN_UserCenter_StartTime;
    long long p_GrayN_UserCenter_EndTime;
    string p_GrayN_UserCenter_RequestTime;
    string p_GrayN_UserCenter_LogType;
    string p_GrayN_UserCenter_DecryptData;
    string p_GrayN_UserCenter_DecodeData; // 请求的明文
    GrayN_UserCenter *p_GrayN_UserCenterObject;
    GrayN_Https_GrayN* p_GrayN_UserCenter_Https;
    string p_GrayN_UserCenter_HttpBuffer;     // 接收的数据缓存
    GrayN_HttpErrorCode p_GrayN_UserCenter_HttpErrorCode;            // 专门用于httpError的判断
    GrayNasyn_CallBack* p_GrayN_UserCenter_Asyn_CallBack;
};

GrayN_NameSpace_End

