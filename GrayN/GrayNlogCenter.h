//
//  GrayNlogCenter.h
//
//  Created by 韩征 on 14-1-14.
//  Copyright (c) 2014年 op-mac1. All rights reserved.
//

#import <iostream>
#import "GrayNjson_cpp.h"
#import <vector>

#import "GrayNlogHeader.h"
#import "GrayNcommon.h"
#import "GrayN_Timer_GrayN.h"
#import "GrayN_Http_GrayN.h"

using namespace std;

GrayN_NameSpace_Start
    enum GrayN_LogID
    {
        GrayN_LAUCH,                  // 联网日志
        GrayN_HEARTBEAT,              // 心跳日志
        GrayN_ACCOUNT_REGISTER,       // 账户注册费日志
        GrayN_ACCOUNT_LOGIN,          // 账户登录日志
        GrayN_ACCOUNT_LOGOUT,         // 账户注销日志
        GrayN_ACCOUNT_PROP_UPDATE,    // 账户属性变更日志
        GrayN_ROLE_REGISTER,          // 角色注册日志
        GrayN_ROLE_LOGIN,             // 角色登录日志
        GrayN_ROLE_CREDIT,            // 角色充值日志
        GrayN_ROLE_DEBIT,             // 角色消费日志
        GrayN_ROLE_PROP_UPDATE,       // 角色属性变更日志
        GrayN_DEVICE_EXCEPTION,       // 客户端异常日志
        GrayN_ROLE_CUSTOM,            // 角色自定义日志
        GrayN_SDK_LOGINFAILED = 15,        // 登录失败日志
 
    };
    
    class GrayNlogCenter :  public GrayN_TimerObserver
    {
    public:
        GrayNlogCenter();
        ~GrayNlogCenter();
    public:
        inline static GrayNlogCenter& GetInstance() {
            static GrayNlogCenter GrayN_logCenter;
            return GrayN_logCenter;
        }
    public:
        enum GrayN_ActivateType
        {
            GrayN_SYNC_SEND,          // 实时发送
            GrayN_PERIODIC_SEND,      // 周期发送
            GrayN_FORBID_SEND = 9     // 终止发送
        };
        
    public:

        string m_GrayN_Log_StatisticalUrl;       // 统计接口地址
        GrayN_Log_Queue m_GrayN_LogQueue;         // 日志队列
        vector<string> m_GrayN_LogValidLogs;  // 合法日志数组
        bool m_GrayN_LogIsQuitGame;           // 手动退出游戏不进行崩溃收集
        
    private:
        GrayN_Log_Device p_GrayN_LogDevice;         // 设备对象
        GrayN_JSON::Value p_GrayN_LogDeviceJson;
        
        GrayN_Log_Account p_GrayN_LogAccount;       // 账户对象
        GrayN_Log_SpecAttribute p_GrayN_LogSpecAttr;     // 特殊属性对象
        GrayN_Log_Role p_GrayN_LogRole;             // 角色对象
        
        GrayN_Timer_GrayN* p_GrayN_LogTimer;      // 心跳定时器
        string p_GrayN_LogVersion;        // 当前统计版本号 - 据此清里本地数据
        GrayN_JSON::Value p_GrayN_ValidLogsJson;       // 有效日志Json
        GrayN_JSON::Value p_GrayN_LogConfigsJson;      // 日志配置Json
        
        
        vector<GrayN_Log_Config> p_GrayN_LogConfigs;   // 日志配置数组
        
        bool p_GrayN_LogIsInit;           // 是否初始化成功
        
    public:
        /**
         * @brief 初始化日志中心
         */
        void GrayN_LogInit(GrayN_Log_Device dvice);
        /* 游戏调用创建日志的接口 */
        void GrayN_Log_CreateLog(const char* logID, const char* logKey ,const char* logVal);
        void GrayN_Log_SetAccountInfo(GrayN_Log_Account account);   // 设置账户信息
        void GrayN_Log_SetRoleInfo(GrayN_Log_Role role);            // 设置角色信息
        void GrayN_Log_CreateLog(GrayN_Log_Data opLog);
        /* 游戏调用添加特殊属性的接口 */
        void GrayN_Log_SetSpecialKey(const char* specKeyJson);
        void GrayN_Log_ParseHttpError(void* args, int httpType);
        void GrayN_Log_ParseHttpData(GrayN_Http_GrayN* client, int httpType, string data, vector<string> sentLogsBorn);
        // 分页发送策略
        void GrayN_Log_PageSendRequest();
        
        void GrayNlogByBridge(void* bridgeLog);
        
    private:
        void GrayN_LogActivateSDK();                     // 激活SDK
        void GrayN_LogSetValidLogs();                    // 设置初始化有效日志
        void GrayN_LogSendStrategy(GrayN_Log_Data opLog);         // 发送策略
        void GrayN_LogSendRequest(list<GrayN_Log_Data> sLs);      // 发送日志请求
        void GrayN_TimeUp();                          // 定时器停止回调
        
        

        void GrayN_Log_ClearAccountInfo();                // 清除账户信息
        void GrayN_Log_ClearRoleInfo();                   // 清除角色信息
        

        bool GrayN_Log_SendRestrict(string logID);

        
        void GrayN_Log_ParseDataFunction(const char* data, const char* memo, const char* errorLog, const char* methodName, GrayN_Http_GrayN* client);
        void GrayN_Log_ParseInit(const char* data, GrayN_Http_GrayN* client);
        void GrayN_Log_ParseSendRequest(const char* data, GrayN_Http_GrayN* client);


    private:
        // 创建日志
        void GrayN_Log_CreateLogPrivate(GrayN_Log_Data opLog);
        // 心跳发送
        void GrayN_Log_HeartBeatSendRequest(unsigned int waitTime);
        
    };
GrayN_NameSpace_End

