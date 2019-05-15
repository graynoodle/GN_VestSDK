//
//  GrayN_SDK_Init.h
//
//  Created by op-mac1 on 14-6-17.
//  Copyright (c) 2014年 op-mac1. All rights reserved.
//

#import "GrayNjson_cpp.h"

#import "GrayNconfig.h"
#import "GrayN_Https_GrayN.h"

GrayNusing_NameSpace;
GrayN_NameSpace_Start

class GrayN_SDK_Init: public GrayN_Thread_GrayN , public GrayN_Http_GrayN::GrayN_HttpListener
{
public:
    GrayN_SDK_Init();
    ~GrayN_SDK_Init();
  
public:
    inline static GrayN_SDK_Init &GetInstance()
    {
        static GrayN_SDK_Init GrayNInit;
        return GrayNInit;
    }
    
public:
    enum GrayN_Init_HttpType
    {
        k_GrayN_Init,         // 初始化（获取接口信息）0
        k_GrayN_Update,       // 更新
        k_GrayN_Get_SessionId // 获取最新sessionId
    };
    
public:
    void GrayNrun(void *p);
    void GrayN_StartUpdate();

private:
    int p_GrayN_Init_HttpType;
    GrayN_Https_GrayN* p_GrayN_Init_Https;

    string p_GrayN_Init_HttpsBuffer;     // 接收的数据缓存
    string p_GrayN_Init_DecodeData; // 请求的明文
public:
    // 获取接口信息
    void GrayN_GetInitInfo();
    bool GrayN_GetInitStatus();
    void GrayN_SetInitStatus(bool status);
    void GrayN_InitGetSessionId();
    
private:
    //网络连接
    void GrayN_InitConnectNetwork(int httpType, const char* url, string data);
    
    // 创建初始化参数
    string GrayN_CreateInitInfo();
    // 接口信息解析
    bool GrayN_ParseInitInfo();
    
    // 升级
    void GrayN_ParseGameUpdate();
    // 重新获取sessionId
    void GrayN_ParseInitGetSessionId();

public:
    virtual void GrayN_On_HttpError(GrayN_Http_GrayN* client, GrayN_HttpErrorCode code);
    virtual void GrayN_On_HttpEvent(GrayN_Http_GrayN* client, GrayN_HttpEventCode code);
    virtual void GrayN_On_HttpResponse(GrayN_Http_GrayN* client,int code,int context_length,int startPos,int endPos,int totalContext,const char* data);
    virtual void GrayN_On_Http_Data(GrayN_Http_GrayN* client,const char* data,int count);
    
private:
    //Des解密，并检查JSON数据是否异常
    bool GrayN_ParseInitDesData(GrayN_JSON::Value &json_object);

    //发送错误日志，用于分析
    void GrayN_SendErrorLog();
    void GrayN_SendInitLog();
    
private:
    int p_GrayN_InitRequestCount;             //请求次数
    string p_GrayN_InitRequestTime;
    string p_GrayN_InitLogType;
    string p_GrayN_InitDecryptData;
    string p_GrayN_InitErrorType;
    int p_GrayN_InitError;
    GrayN_HttpErrorCode p_GrayN_InitHttpErrorCode;
    
    bool p_GrayN_InitIsInUse;          // 防止初始化被调用多次
    bool p_GrayN_InitIsInit;           // 防止初始化和更新变量多次赋值
    bool p_GrayN_InitIsInitFinished;        
    string p_GrayN_InitBody;
    string p_GrayN_UpdateBody;
    
public:
    bool p_GrayN_IsClickLogin;

    int p_GrayN_UpdateType;
//    GrayN_JSON::Value mUpdataJson;
};

GrayN_NameSpace_End

