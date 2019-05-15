//
//
//  Created by 韩征 on 14-1-14.
//  Copyright (c) 2014年 op-mac1. All rights reserved.
//

#define GrayN_Log_Default_Version "1.0"
#define GrayN_Log_Default_Period 300
#define GrayN_Log_Default_Type "0"            //实时发送
#define GrayN_Log_Default_PageSize 10

#import <list>
#import "GrayNjson_cpp.h"
#import <iostream>
using namespace std;

class GrayN_Log_UCServer {
public:
    GrayN_Log_UCServer() {
        m_GrayN_Log_UserCenterUrl = "";
    }
    
    ~GrayN_Log_UCServer() {
        
    }

    string m_GrayN_Log_UserCenterUrl;
};

class GrayN_Log_Account {
public:
    GrayN_Log_Account() {
        m_GrayN_Log_UserId = "";
        m_GrayN_Log_UserName = "";
    }
    
    ~GrayN_Log_Account() {
        
    }
    
    string m_GrayN_Log_UserId;
    string m_GrayN_Log_UserName;
    GrayN_Log_UCServer m_GrayN_Log_UserCenterServer;
};


struct GrayN_Log_SDKinfo {
public:
    GrayN_Log_SDKinfo() {
        m_GrayN_Log_DeviceGroupId = "";
        m_GrayN_Log_LocaleId = "";
    }
    
    ~GrayN_Log_SDKinfo() {
        
    }
    
    string m_GrayN_Log_DeviceGroupId;           //机型组
    string m_GrayN_Log_LocaleId;             //地区
};

struct GrayN_Log_NetServer {
public:
    GrayN_Log_NetServer() {
        m_GrayN_Log_InitUrl = "";
    }
    
    ~GrayN_Log_NetServer() {
        
    }
    
    string m_GrayN_Log_InitUrl;    //初始化服务器地址
};

class GrayN_Log_Device {
public:
    GrayN_Log_Device() {
        
    }
    
    ~GrayN_Log_Device() {
        
    }
    
    GrayN_Log_SDKinfo m_GrayN_Log_SDKinfo;
    GrayN_Log_NetServer m_GrayN_Log_LauchServer;
    //下面几个属性，在内部发送日志时体现了
    //    std::string mDeviceUniqueId;
    //    std::string mOpenuuid;
    //    std::string mMac;
    //    std::string mIDFA;
    //    std::string mImei;
};


class GrayN_Log_Data {
public:
    GrayN_Log_Data() {
        m_GrayN_Log_Logkey = "";
        m_GrayN_Log_LogVal = "";
        m_GrayN_Log_Data_UserId = "";
//        mJSONstr = "";
        m_GrayN_Log_LoginType = "";
        m_GrayN_Log_BornTime = "";
        m_GrayN_Log_Data = "";
    }
    
    ~GrayN_Log_Data() {
        
    }
    
    /* 预留JSON串 如果游戏有需要填写但未定义的参数 直接保存至此*/
//    string mJSONstr;             // JSON
    
    /* 日志通用部分 */
    string m_GrayN_Log_BornTime;                // 日志入数据库唯一标示
    string m_GrayN_Log_Logkey;              // 日志key
    string m_GrayN_Log_Data;        // 游戏调用填写的value
    GrayN_JSON::Value m_GrayN_Log_LogVal;         // SDK拼接后日志的value
    
    //    0    联网日志
    //    1    心跳日志
    //    2    账户注册日志
    //    3    账户登录日志
    //    4    账户注销日志
    //    5    账户属性变更日志
    //    6    角色注册日志
    //    7    角色登录日志
    //    8    角色充值日志
    //    9    角色消费日志
    //    10    角色属性变更日志
    //    11    客户端异常日志
    string m_GrayN_Log_LogId;               // 日志ID
    //    string mTime;                // 日志发生时间
    string m_GrayN_Log_Data_UserId;                 // 用户中心登录ID
    string m_GrayN_Log_LoginType;           // 账户注册登录需要设置
    
};

class GrayN_Log_Config {
public:
    GrayN_Log_Config() {
        
    }
    
    ~GrayN_Log_Config() {
        
    }
    
    string m_GrayN_Log_LogId;       // 日志ID
    string m_GrayN_Log_Logkey;      // 日志Key
    string m_GrayN_Log_Periodicity; // 日志发送周期设置
    // -1:不发送
    //  0:实时
    //  1:周期发送
};

class GrayN_Log_Queue {
public:
    GrayN_Log_Queue() {
        m_GrayN_Log_Queue_Version = GrayN_Log_Default_Version;
        m_GrayN_Log_Queue_Period = GrayN_Log_Default_Period;
        m_GrayN_Log_Queue_Type = GrayN_Log_Default_Type;
        m_GrayN_Log_Queue_PageSize = GrayN_Log_Default_PageSize;
//        mUrl = "";
//        m_GrayN_Log_Queue_String = "";
    }
    
    ~GrayN_Log_Queue() {
        
    }
    
    string m_GrayN_Log_Queue_Version;     // 版本号
    int m_GrayN_Log_Queue_PageSize;       // 分页大小
    int m_GrayN_Log_Queue_Period;         // 周期
    string m_GrayN_Log_Queue_Type;        // 发送方式
//    string mUrl;         // 日志发送地址
    list<GrayN_Log_Data> m_GrayN_Log_Queue_LogList;                // 日志队列
//    string m_GrayN_Log_Queue_String;              // 日志队列转化字符串
};


class GrayN_Log_Role {
public:
    GrayN_Log_Role() {
        m_GrayN_Log_RoleId = "";
        m_GrayN_Log_RoleName = "";
    }
    
    ~GrayN_Log_Role() {
        
    }
    
    string m_GrayN_Log_RoleId;      // 角色ID
    string m_GrayN_Log_RoleName;    // 角色名
};


class GrayN_Log_SpecAttribute {
public:
    GrayN_Log_SpecAttribute() {
        m_GrayN_Log_SpecialKeyJson.clear();
    }
    
    ~GrayN_Log_SpecAttribute(){}
    
    GrayN_JSON::Value m_GrayN_Log_SpecialKeyJson;
};


