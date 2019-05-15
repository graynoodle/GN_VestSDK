//
//  GrayNlogCenter.cpp
//
//  Created by 韩征 on 14-1-14.
//  Copyright (c) 2014年 op-mac1. All rights reserved.
//

#import "GrayNlogCenter.h"
#import "GrayN_LogDatabase_GrayN.h"
#import "GrayN_LogHttp.h"
#import "GrayNconfig.h"
#import "GrayN_Base64_GrayN.h"

//#define LOGDEBUG
GrayNusing_NameSpace;

// 数据库操作对象
static GrayN_LogDatabase_GrayN* p_GrayN_LogDatabase;
// 创建日志队列
static dispatch_queue_t p_GrayN_LogCreateLogQueue = dispatch_queue_create("p_GrayN_LogCreateLogQueue", NULL);
// 解析队列
static dispatch_queue_t p_GrayN_LogParseQueue     = dispatch_queue_create("p_GrayN_LogParseQueue", NULL);
// 分页发送日志队列
static dispatch_queue_t p_GrayN_LogSentQueue      = dispatch_queue_create("p_GrayN_LogSentQueue", NULL);


GrayNlogCenter::GrayNlogCenter()
{
    p_GrayN_LogDatabase = [[GrayN_LogDatabase_GrayN alloc] GrayN_LogDatabase_Init];
    m_GrayN_Log_StatisticalUrl = "";
    p_GrayN_LogIsInit = false;
    m_GrayN_LogIsQuitGame = false;
    m_GrayN_LogValidLogs.clear();
    p_GrayN_LogConfigs.clear();
    p_GrayN_LogVersion = "0.0";
//    mLastNoResponseTrace.clear();
//    _opCrashMonitor = [NSClassFromString(Class_OPCrashMonitor) shareInstance];
}

GrayNlogCenter::~GrayNlogCenter()
{
//    GrayNreleaseSafe(p_GrayN_LogDatabase);
}

/* 设置账户信息 */
void GrayNlogCenter::GrayN_Log_SetAccountInfo(GrayN_Log_Account account)
{
    p_GrayN_LogAccount = account;
}

/* 清除账户信息 */
void GrayNlogCenter::GrayN_Log_ClearAccountInfo()
{
    p_GrayN_LogAccount.m_GrayN_Log_UserId = "";
    p_GrayN_LogAccount.m_GrayN_Log_UserName = "";
    p_GrayN_LogAccount.m_GrayN_Log_UserCenterServer.m_GrayN_Log_UserCenterUrl = "";
}

/* 设置角色信息 */
void GrayNlogCenter::GrayN_Log_SetRoleInfo(GrayN_Log_Role role)
{
    p_GrayN_LogRole = role;
}

/* 清除角色信息 */
void GrayNlogCenter::GrayN_Log_ClearRoleInfo()
{
    p_GrayN_LogRole.m_GrayN_Log_RoleId = "";
    p_GrayN_LogRole.m_GrayN_Log_RoleName = "";
}

/* CP设置特殊属性->用于描述请求报文 */
void GrayNlogCenter::GrayN_Log_SetSpecialKey(const char* specKeyJson)
{
    GrayN_JSON::Reader    json_reader;
    GrayN_JSON::Value     specValue;
    
    string buf = specKeyJson;
    if (!json_reader.parse(buf, specValue)) {
        GrayNcommon::GrayN_ConsoleLog("SpecKeyJson格式错误");
        GrayNcommon::GrayN_ConsoleLog(buf.c_str());
        return;// json格式解析错
    }

    GrayN_JSON::Value::Members mem = specValue.getMemberNames();
    
    for (auto iter = mem.begin(); iter != mem.end(); iter++) {
//        cout<<*iter<<"\t: ";
//        cout<<.asCString()<<endl;
        if (specValue[*iter].type() == GrayN_JSON::stringValue) {
            p_GrayN_LogSpecAttr.m_GrayN_Log_SpecialKeyJson[*iter] = GrayN_JSON::Value(specValue[*iter]);
        }
    }
}

/* 统计SDK初始化 */
void GrayNlogCenter::GrayN_LogInit(GrayN_Log_Device device)
{
    if (p_GrayN_LogIsInit) {
        return;
    }
    // 初始化数据库
    [p_GrayN_LogDatabase GrayN_LogDatabase_CreateTable];
    //初始化device信息
    p_GrayN_LogDevice = device;
    GrayN_JSON::Value _sdkinfo;
    _sdkinfo["platform"] = GrayN_JSON::Value(p_GrayN_LogDevice.m_GrayN_Log_SDKinfo.m_GrayN_Log_DeviceGroupId);
    _sdkinfo["locale"] = GrayN_JSON::Value(p_GrayN_LogDevice.m_GrayN_Log_SDKinfo.m_GrayN_Log_LocaleId);
    
    GrayN_JSON::Value _lauchServer;
    _lauchServer["url"] = GrayN_JSON::Value(p_GrayN_LogDevice.m_GrayN_Log_LauchServer.m_GrayN_Log_InitUrl);
    
    p_GrayN_LogDeviceJson["sdkInfo"] = _sdkinfo;
    p_GrayN_LogDeviceJson["lauchServer"] = _lauchServer;
    p_GrayN_LogDeviceJson["deviceUniqueId"] = GrayN_JSON::Value(GrayNcommon::m_GrayN_Device_UniqueId);
    p_GrayN_LogDeviceJson["openuuid"] = GrayN_JSON::Value(GrayNcommon::m_GrayN_Open_UUID);
    p_GrayN_LogDeviceJson["mac"] = GrayN_JSON::Value(GrayNcommon::m_GrayN_MAC_Address);
    p_GrayN_LogDeviceJson["idfa"] = GrayN_JSON::Value(GrayNcommon::m_GrayN_IDFA);
    p_GrayN_LogDeviceJson["imei"] = GrayN_JSON::Value(GrayNcommon::m_GrayN_IMEI);
    
    // 设置初始化有效日志
    GrayN_LogSetValidLogs();
    // 激活联网
    GrayN_LogActivateSDK();
}

/* 激活SDK */
void GrayNlogCenter::GrayN_LogActivateSDK()
{
    // 创建联网日志
    GrayN_Log_Data lauchLog;
    lauchLog.m_GrayN_Log_LogId = "0";
    dispatch_async(p_GrayN_LogCreateLogQueue, ^{
        GrayN_Log_CreateLogPrivate(lauchLog);
        usleep(1000);
    });
}
/* 设置初始化有效日志 */
void GrayNlogCenter::GrayN_LogSetValidLogs()
{
    // 设置默认有效日志 0-13
    for (int i=0; i<=16; i++) {
        string validLog = [[NSString stringWithFormat:@"%i",i] UTF8String];
        m_GrayN_LogValidLogs.push_back(validLog.c_str());
    }
    m_GrayN_LogValidLogs.push_back("91");
    m_GrayN_LogValidLogs.push_back("92");
    m_GrayN_LogValidLogs.push_back("110");
    m_GrayN_LogValidLogs.push_back("11001");
    m_GrayN_LogValidLogs.push_back("114");
    m_GrayN_LogValidLogs.push_back("115");
    m_GrayN_LogValidLogs.push_back("116");
    m_GrayN_LogValidLogs.push_back("11002");
    m_GrayN_LogValidLogs.push_back("11003");
    m_GrayN_LogValidLogs.push_back("11004");

    m_GrayN_LogValidLogs.push_back("1001");
    m_GrayN_LogValidLogs.push_back("1002");
    m_GrayN_LogValidLogs.push_back("1003");
    m_GrayN_LogValidLogs.push_back("2001");
    m_GrayN_LogValidLogs.push_back("70001");
    m_GrayN_LogValidLogs.push_back("70002");
    m_GrayN_LogValidLogs.push_back("21000");

}

#pragma mark -
/* 周期结束创建心跳日志 */
void GrayNlogCenter::GrayN_TimeUp()
{
    GrayNcommon::GrayN_DebugLog("opSendingHeartBeatLog...");
    GrayN_Log_Data opLog;
    opLog.m_GrayN_Log_LogId = "1";
    dispatch_async(p_GrayN_LogCreateLogQueue, ^{
        GrayN_Log_CreateLogPrivate(opLog);
        usleep(1000);
    });
}

/* 分页发送 */
void GrayNlogCenter::GrayN_Log_PageSendRequest()
{
    dispatch_async(p_GrayN_LogSentQueue, ^{
        
        list<GrayN_Log_Data> sentLogs;
        
        long listNum = m_GrayN_LogQueue.m_GrayN_Log_Queue_LogList.size();
        long count = listNum/m_GrayN_LogQueue.m_GrayN_Log_Queue_PageSize;
//        cout<<"listNum="<<listNum<<endl;
        for (int i=0; i < count; i++) {
            sentLogs.clear();
            for (int j=0; j < m_GrayN_LogQueue.m_GrayN_Log_Queue_PageSize; j++) {
                sentLogs.push_back(m_GrayN_LogQueue.m_GrayN_Log_Queue_LogList.front());
                m_GrayN_LogQueue.m_GrayN_Log_Queue_LogList.pop_front();
            }
            GrayN_LogSendRequest(sentLogs);
        }
        
        count = listNum-count*m_GrayN_LogQueue.m_GrayN_Log_Queue_PageSize;
        sentLogs.clear();
        for (int i=0; i < count; i++) {
            sentLogs.push_back(m_GrayN_LogQueue.m_GrayN_Log_Queue_LogList.front());
            m_GrayN_LogQueue.m_GrayN_Log_Queue_LogList.pop_front();
        }
        if (sentLogs.size() > 0) {
            GrayN_LogSendRequest(sentLogs);
        }
    });
}

/* 心跳发送 */
void GrayNlogCenter::GrayN_Log_HeartBeatSendRequest(unsigned int waitTime)
{
    if (p_GrayN_LogTimer) {
        if (waitTime == p_GrayN_LogTimer->m_GrayN_WaitTime) {
            return;
        }
        p_GrayN_LogTimer->GrayN_StopTimer();
    }
    p_GrayN_LogTimer = new GrayN_Timer_GrayN();
    p_GrayN_LogTimer->GrayN_StartTimer(waitTime, this);
}

/* 发送策略 */
void GrayNlogCenter::GrayN_LogSendStrategy(GrayN_Log_Data opLog)
{
    int type = atoi(m_GrayN_LogQueue.m_GrayN_Log_Queue_Type.c_str());
    
    /* 30 - 优先级 */
    // 如果日志有特殊配置，采用特殊配置发送
    if (!p_GrayN_LogConfigs.empty()) {
        for (int i=0; i < p_GrayN_LogConfigs.size(); ++i) {
            if (opLog.m_GrayN_Log_LogId == p_GrayN_LogConfigs.at(i).m_GrayN_Log_LogId) {
                switch (atoi(p_GrayN_LogConfigs.at(i).m_GrayN_Log_Periodicity.c_str())) {
                    case -1: {
                        // 不发送
                        GrayNcommon::GrayN_DebugLog("**********该日志不发送**********");
                        // 将日志存入数据库，下次发送时插入队列
                        return;
                    }
                        
                        break;
                    case 0: {
                        // 实时发送
                        // 如果当前发送状态为实时就实时发送，为周期，就触发一次发送
                        if (type == GrayN_PERIODIC_SEND) {
                            m_GrayN_LogQueue.m_GrayN_Log_Queue_LogList.push_back(opLog);
                            GrayN_Log_PageSendRequest();
                            return;
                        }
                    }
                        
                        break;
                    case 1: {
                        // 周期发送
                        // 如果当前发送状态为实时就让其周期发送，为周期，就入队列
                        if (type == GrayN_SYNC_SEND) {
                            m_GrayN_LogQueue.m_GrayN_Log_Queue_LogList.push_back(opLog);
                            GrayN_Log_HeartBeatSendRequest(m_GrayN_LogQueue.m_GrayN_Log_Queue_Period);
                            return;
                        }
                    }
                        break;
                        
                    default:
                        GrayNcommon::GrayN_DebugLog("**********periodicity参数异常**********");
                        break;
                }
            }
        }
    }
    
    /* 0 - 优先级 */
    /* 按日志type设置发送 */
    
    if (type == GrayN_SYNC_SEND) {
        // 实时发送
        m_GrayN_LogQueue.m_GrayN_Log_Queue_LogList.push_back(opLog);
        GrayN_Log_PageSendRequest();
    } else if (type == GrayN_PERIODIC_SEND) {
        // 心跳发送
        m_GrayN_LogQueue.m_GrayN_Log_Queue_LogList.push_back(opLog);
        GrayN_Log_HeartBeatSendRequest(m_GrayN_LogQueue.m_GrayN_Log_Queue_Period);
    } else {
        // 激活失败
        GrayNcommon::GrayN_ConsoleLog("type设置有误");
    }
}

/* 发送日志限制策略 */
bool GrayNlogCenter::GrayN_Log_SendRestrict(string logID)
{
    int _logID = atoi(logID.c_str());
    int _type = atoi(m_GrayN_LogQueue.m_GrayN_Log_Queue_Type.c_str());
    /* 100 - 优先级 */
    // 如果发送策略为不发送，不插入数据库
    if (_type == GrayN_FORBID_SEND && _logID != GrayN_LAUCH) {
        GrayNcommon::GrayN_DebugLog("**********禁止发送**********");
        // 当前状态为禁止发送 所有日志都不发送 也不存数据库
        return false;
    }
    
    /* 90 - 优先级 */
    // 如果是心跳日志或者联网日志，产生一次日志发送
    if (_logID == GrayN_LAUCH || _logID == GrayN_HEARTBEAT) {
        return true;
    }

    /* 50 - 优先级 */
    // 如果有效日志数组为空，任何日志均可发送
    if (m_GrayN_LogValidLogs.size()) {
        /* 40 - 优先级 */
        // 无效的日志不发送
        for (int i=0; i < m_GrayN_LogValidLogs.size(); ) {
            if (logID == m_GrayN_LogValidLogs.at(i)) {
                break;
            } else {
                if (++i == m_GrayN_LogValidLogs.size()) {
                    GrayNcommon::GrayN_DebugLog("当前日志无效，不发送，LogID如下");
                    GrayNcommon::GrayN_DebugLog(logID.c_str());
                    return false;
                }
            }
        }
    }
    return true;
}

/* 游戏调用创建日志的接口 */
void GrayNlogCenter::GrayN_Log_CreateLog(const char* logID, const char* logKey ,const char* logVal)
{
    if (!GrayN_Log_SendRestrict(logID)) {
        GrayNcommon::GrayN_DebugLog("当前日志不符合创建要求");
        return;
    }
    
    GrayN_Log_Data opLog;
    opLog.m_GrayN_Log_LogId = logID;
    opLog.m_GrayN_Log_Logkey = logKey;
    opLog.m_GrayN_Log_Data = logVal;
    
        dispatch_async(p_GrayN_LogCreateLogQueue, ^{
            GrayN_Log_CreateLogPrivate(opLog);
            usleep(1000);
        });
}

void GrayNlogCenter::GrayN_Log_CreateLog(GrayN_Log_Data opLog)
{
    if (!GrayN_Log_SendRestrict(opLog.m_GrayN_Log_LogId)) {
        GrayNcommon::GrayN_DebugLog("当前日志不符合创建要求");
        return;
    }
    dispatch_async(p_GrayN_LogCreateLogQueue, ^{
        GrayN_Log_CreateLogPrivate(opLog);
        usleep(1000);
    });
}
/* 创建日志 */
void GrayNlogCenter::GrayN_Log_CreateLogPrivate(GrayN_Log_Data opLog)
{
    if (m_GrayN_LogIsQuitGame) {
        GrayNcommon::GrayN_ConsoleLog(@"主动退出游戏不上报崩溃、卡顿！");
        abort();
        return;
    }
    GrayN_JSON::Value     json_object;
    GrayN_JSON::FastWriter fast_writer;
    
    // 创建日志通用信息
    json_object["id"] = GrayN_JSON::Value(opLog.m_GrayN_Log_LogId.c_str());
    
    GrayN_JSON::Value     value;
    value["time"] = GrayN_JSON::Value(GrayNcommon::GrayNgetCurrent_DateAndTime());
    value["uid"] = GrayN_JSON::Value(GrayNcommon::m_GrayN_Game_UserId);
    
    int logID = atoi(opLog.m_GrayN_Log_LogId.c_str());
    opLog.m_GrayN_Log_BornTime = GrayNcommon::GrayNgetCurrent_TimeString();

    switch (logID) {
        case GrayN_LAUCH: {
            json_object["key"] = GrayN_JSON::Value("lauch");
            json_object["val"] = value;
            opLog.m_GrayN_Log_LogVal = json_object;
            
            string saveData = fast_writer.write(opLog.m_GrayN_Log_LogVal);
            [p_GrayN_LogDatabase GrayN_LogDatabase_InsertLogByUserId:opLog.m_GrayN_Log_Data_UserId Data:saveData LogID:opLog.m_GrayN_Log_LogId BornTime:opLog.m_GrayN_Log_BornTime];
            
            m_GrayN_LogQueue.m_GrayN_Log_Queue_LogList.push_front(opLog);
            
            GrayN_Log_PageSendRequest();
        }
            return;
            
        case GrayN_HEARTBEAT: {
            json_object["key"] = GrayN_JSON::Value("heartbeat");
            json_object["val"] = value;
            opLog.m_GrayN_Log_LogVal = json_object;
            
            m_GrayN_LogQueue.m_GrayN_Log_Queue_LogList.push_front(opLog);
            GrayN_Log_PageSendRequest();
        }
            return;
            
        case GrayN_ACCOUNT_REGISTER: {
            json_object["key"] = GrayN_JSON::Value("account-register");
            value["loginType"] = GrayN_JSON::Value(opLog.m_GrayN_Log_LoginType);
        }
            break;
            
        case GrayN_ACCOUNT_LOGIN: {
            json_object["key"] = GrayN_JSON::Value("account-login");
            value["loginType"] = GrayN_JSON::Value(opLog.m_GrayN_Log_LoginType);
        }
            break;
        case GrayN_ACCOUNT_LOGOUT: {
            json_object["key"] = GrayN_JSON::Value("account-logout");
        }
            break;
            // 分别由用户中心、计费中心发送 故不处理
            //        case GrayN_ACCOUNT_PROP_UPDATE:
        case GrayN_ROLE_CREDIT:
        case GrayN_ROLE_REGISTER:
        case GrayN_ROLE_LOGIN:
        case GrayN_ROLE_DEBIT:
        case GrayN_ROLE_PROP_UPDATE:
        case GrayN_DEVICE_EXCEPTION:
        //case GrayN_SDK_LOGINFAILED:
        case GrayN_ROLE_CUSTOM: {
        CreateLable:
            json_object["key"] = GrayN_JSON::Value(opLog.m_GrayN_Log_Logkey);
            // 角色ID 角色名称 逻辑服
            GrayN_JSON::Reader    json_reader;
            
            string buf = opLog.m_GrayN_Log_Data;
            if (!json_reader.parse(buf, value)) {
                GrayNcommon::GrayN_ConsoleLog("日志格式错误");
                GrayNcommon::GrayN_ConsoleLog(buf.c_str());
                return;// json格式解析错
            }
            value["time"] = GrayN_JSON::Value(GrayNcommon::GrayNgetCurrent_DateAndTime());
            value["logicDeployNodeCode"] = GrayN_JSON::Value(GrayNcommon::m_GrayN_Game_ServerId);
            value["roleId"] = GrayN_JSON::Value(GrayNcommon::m_GrayN_Game_RoleId);
            value["roleName"] = GrayN_JSON::Value(GrayNcommon::m_GrayN_Game_RoleName);
            value["uid"] = GrayN_JSON::Value(GrayNcommon::m_GrayN_Game_UserId);
            
        }
            break;
            
        default:
            // 自定义日志ID有无穷多个
            if (atoi(opLog.m_GrayN_Log_LogId.c_str()) >= 0) {
                goto CreateLable;
            } else {
#ifdef DEBUG  
                GrayNcommon::GrayN_DebugLog("日志创建失败，日志ID有误");
#endif
                return;
            }
    }
    
    json_object["val"] = value;
    opLog.m_GrayN_Log_LogVal = json_object;
    
    // 创建的日志 只要非心跳即存入数据库
    string saveData = fast_writer.write(opLog.m_GrayN_Log_LogVal);
    [p_GrayN_LogDatabase GrayN_LogDatabase_InsertLogByUserId:opLog.m_GrayN_Log_Data_UserId Data:saveData LogID:opLog.m_GrayN_Log_LogId BornTime:opLog.m_GrayN_Log_BornTime];
    
    // 如果SDK没有初始化成功就不发送日志
    if (m_GrayN_Log_StatisticalUrl == "") {
        return;
    }
    // 进入发送策略
    GrayN_LogSendStrategy(opLog);
}

/* 发送日志请求 */
void GrayNlogCenter::GrayN_LogSendRequest(list<GrayN_Log_Data> sLs)
{
    // 增加控制，错开并发
    static int i=0;
    static bool isSleep = false;
//    cout<<"连接数----------"<<i<<endl;
    if (++i%50 == 0) {
        isSleep = !isSleep;
        i=0;
    }
    if (isSleep) {
        usleep(10000*(i%50));
    }
//    cout<<"isSleep "<<isSleep<<endl;
    // GrayN_Log_Account
    GrayN_JSON::Value _ucenter;
    _ucenter["url"] = GrayN_JSON::Value(p_GrayN_LogAccount.m_GrayN_Log_UserCenterServer.m_GrayN_Log_UserCenterUrl);
    
    GrayN_JSON::Value _account;
    _account["uid"] = GrayN_JSON::Value(p_GrayN_LogAccount.m_GrayN_Log_UserId);
    _account["accountName"] = GrayN_JSON::Value(p_GrayN_LogAccount.m_GrayN_Log_UserName);
    _account["ucenter"] = _ucenter;
    
    // GrayN_Log_Role
    GrayN_JSON::Value _role;
    _role["roleId"] = GrayN_JSON::Value(p_GrayN_LogRole.m_GrayN_Log_RoleId);
    _role["roleName"] = GrayN_JSON::Value(p_GrayN_LogRole.m_GrayN_Log_RoleName);
    
    // JsonMsg
    GrayN_JSON::Value root;
    root["device"] = p_GrayN_LogDeviceJson;
    root["account"] = _account;
    
    // SpecialAttr
    root["specAttr"] = p_GrayN_LogSpecAttr.m_GrayN_Log_SpecialKeyJson;
    root["role"] = _role;
    root["time"] = GrayN_JSON::Value(GrayNcommon::GrayNgetCurrent_DateAndTime());;
    root["version"] = GrayN_JSON::Value(m_GrayN_LogQueue.m_GrayN_Log_Queue_Version);
    root["period"] = GrayN_JSON::Value(m_GrayN_LogQueue.m_GrayN_Log_Queue_Period);
    root["type"] = GrayN_JSON::Value(m_GrayN_LogQueue.m_GrayN_Log_Queue_Type);
    root["pagesize"] = GrayN_JSON::Value(m_GrayN_LogQueue.m_GrayN_Log_Queue_PageSize);
    
    // 将日志队列中的日志拼成最终发送串
    list<GrayN_Log_Data>::iterator logListIterator;
    vector<string> sentLogsBorn;
    for (logListIterator = sLs.begin(); logListIterator != sLs.end(); logListIterator++) {
        root["logs"].append(logListIterator->m_GrayN_Log_LogVal);
        int flag = atoi(logListIterator->m_GrayN_Log_LogId.c_str());
        if (flag >=0 && flag != 1) {
            sentLogsBorn.push_back(logListIterator->m_GrayN_Log_BornTime);
        }
    }
    
    GrayN_JSON::FastWriter fast_writer;
    string tmp = fast_writer.write(root);

    GrayNcommon::GrayN_DebugLog("opLogUrl:%s\nopLogQue:", m_GrayN_Log_StatisticalUrl.c_str());
    GrayNcommon::GrayN_DebugLog(tmp.c_str());
    /*5.2.1*/
    string baseEncode;
    GrayN_Base64_GrayN::GrayN_Base64Encode((unsigned const char*)tmp.c_str(), strlen(tmp.c_str()), baseEncode);
    GrayNcommon::GrayN_DebugLog(baseEncode.c_str());

    GrayN_LogHttp *http = new GrayN_LogHttp();

    http->m_GrayN_LogHttp_SentLogsBornTime = sentLogsBorn;
    sentLogsBorn.clear();

//    http->GrayN_LogHttp_ConnectNetwork(GrayN_LogHttpSEND_REQUEST, "http://10.2.45.18:8080/logReceive/sdk/stat", baseEncode.c_str());
//    http->GrayN_LogHttp_ConnectNetwork(GrayN_LogHttpSEND_REQUEST, "http://10.2.45.18:8080/logReceive/sdk/stat", tmp.c_str());
    http->GrayN_LogHttp_ConnectNetwork(GrayN_LogHttpSEND_REQUEST, m_GrayN_Log_StatisticalUrl.c_str(), baseEncode.c_str());
}

/* OP接口公共解析函数 */
void GrayNlogCenter::GrayN_Log_ParseDataFunction(const char* data, const char* memo, const char* errorLog, const char* methodName, GrayN_Http_GrayN* client)
{
    string buf = data;
    GrayN_JSON::Reader    json_reader;
    GrayN_JSON::Value     json_object;
    
    if (!json_reader.parse(data, json_object)) {
        GrayNcommon::GrayN_ConsoleLog(errorLog);
        GrayNcommon::GrayN_ConsoleLog(buf.c_str());
        return;// json格式解析错
    }

    if (buf != "") {
#ifdef LOGDEBUG
        cout<<buf.c_str()<<endl;
#endif

        GrayNcommon::GrayN_DebugLog("opLogParseData:");
        GrayNcommon::GrayN_DebugLog(buf.c_str());
        
//        if (json_object["version"].empty() || !json_object["version"].isString()) {
//            cout<<"OPGameSDK ERRORLOG:日志策略版本有误！"<<buf<<endl;
//            return;
//        }
        // 日志策略版本
        m_GrayN_LogQueue.m_GrayN_Log_Queue_Version = json_object["version"].asString();

        // 获取后台配置信息
        if (p_GrayN_LogVersion != m_GrayN_LogQueue.m_GrayN_Log_Queue_Version ) {
            // 5.2.3 如果日志返回url不为空 更新之
            string returnUrl = json_object["url"].asString();
            if (returnUrl != "") {
                GrayNcommon::GrayN_ConsoleLog("opStatisticUrl update:");
                GrayNcommon::GrayN_ConsoleLog(returnUrl.c_str());
                m_GrayN_Log_StatisticalUrl = returnUrl;
            }
            // 获取上次请求的日志配置
            vector<string> tmpValidLogs = m_GrayN_LogValidLogs;
                        m_GrayN_LogQueue.m_GrayN_Log_Queue_Period = atoi(json_object["period"].toStyledString().c_str());
            m_GrayN_LogQueue.m_GrayN_Log_Queue_Type = json_object["type"].asCString();
            int type = atoi(m_GrayN_LogQueue.m_GrayN_Log_Queue_Type.c_str());
            if (type != GrayN_FORBID_SEND) {
                //激活后，根据type类型判断是否开始心跳
                GrayN_Log_HeartBeatSendRequest(m_GrayN_LogQueue.m_GrayN_Log_Queue_Period);
                //                    GrayN_Log_HeartBeatSendRequest(30);
            }
            m_GrayN_LogQueue.m_GrayN_Log_Queue_PageSize = atoi(json_object["pagesize"].toStyledString().c_str());
            p_GrayN_ValidLogsJson = json_object["validLogs"];
            p_GrayN_LogConfigsJson = json_object["logConfigs"];
            // 保存版本号,便于重新配置后台数据
            p_GrayN_LogVersion = m_GrayN_LogQueue.m_GrayN_Log_Queue_Version;
            
            // 将返回的有效日志数组保存至本地
            m_GrayN_LogValidLogs.clear();
            string validLogStr = "opValidLogs:\n";
            for (int i=0; i < p_GrayN_ValidLogsJson.size(); ++i) {
                validLogStr.append(p_GrayN_ValidLogsJson[i].asString());
                m_GrayN_LogValidLogs.push_back(p_GrayN_ValidLogsJson[i].asString());
                if (i==p_GrayN_ValidLogsJson.size()-1) {
                    // 输出有效日志数组
                    GrayNcommon::GrayN_DebugLog(validLogStr.c_str());
                    break;
                }
                validLogStr.append(", ");
            }
            
            // 删除数据库中无效日志
            for (vector<string>::iterator i=tmpValidLogs.begin();i!=tmpValidLogs.end(); i++) {
                for (int j=0; j < m_GrayN_LogValidLogs.size();) {
                    if ((*i) == m_GrayN_LogValidLogs.at(j++)) {
                        break;
                    } else if (j == m_GrayN_LogValidLogs.size()) {
#ifdef LOGDEBUG
                        cout<<"删除当前无效日志-> logID = "<<(*i).c_str()<<endl;
#endif
                        [p_GrayN_LogDatabase GrayN_LogDatabase_DeleteLogByBornTime:"" LogID:(*i).c_str()];
                    }
                }
            }
            
            // 从服务器获取日志配置信息
            p_GrayN_LogConfigs.clear();
            int logConfigsSize = p_GrayN_LogConfigsJson.size();
            for (int i=0; i < logConfigsSize; ++i) {
                if (!p_GrayN_LogConfigsJson[i].isMember("logId") || !p_GrayN_LogConfigsJson[i].isMember("logKey") || !p_GrayN_LogConfigsJson[i].isMember("periodicity")) {
                    GrayNcommon::GrayN_DebugLog("**********日志配置信息异常**********");
                    continue;
                }
                
                GrayN_Log_Config _configs;
                if (p_GrayN_LogConfigsJson[i].isMember("logId")) {
                    _configs.m_GrayN_Log_LogId = p_GrayN_LogConfigsJson[i]["logId"].asString();
                }
                if (p_GrayN_LogConfigsJson[i].isMember("logKey")) {
                    _configs.m_GrayN_Log_Logkey = p_GrayN_LogConfigsJson[i]["logKey"].asString();
                }
                if (p_GrayN_LogConfigsJson[i].isMember("periodicity")) {
                    _configs.m_GrayN_Log_Periodicity = p_GrayN_LogConfigsJson[i]["periodicity"].asString();
                }
                p_GrayN_LogConfigs.push_back(_configs);
            }
            // 将数据库中日志加入日志队列中
            [p_GrayN_LogDatabase GrayN_LogDatabase_CheckLogs];
            p_GrayN_LogIsInit = true;
        }
    }
}

void GrayNlogCenter::GrayN_Log_ParseInit(const char* data, GrayN_Http_GrayN* client)
{
    string parseData = data;
    dispatch_async(p_GrayN_LogParseQueue, ^{
        GrayN_Log_ParseDataFunction(parseData.c_str(), "统计SDK初始化失败", "初始化，数据解析失败！", "GrayN_Log_ParseInit", client);
    });
}

void GrayNlogCenter::GrayN_Log_ParseSendRequest(const char* data, GrayN_Http_GrayN* client)
{
    string parseData = data;
    dispatch_async(p_GrayN_LogParseQueue, ^{
        GrayN_Log_ParseDataFunction(parseData.c_str(), "统计SDK发送日志请求失败", "发送日志请求，数据解析失败！", "GrayN_Log_ParseSendRequest", client);
    });
}

void GrayNlogCenter::GrayN_Log_ParseHttpError(void* args, int httpType)
{
    switch (httpType)
    {
        case GrayN_LogHttpINIT:
            break;
        case GrayN_LogHttpSEND_REQUEST:

            break;
        default:
            break;
    }
}

void GrayNlogCenter::GrayN_Log_ParseHttpData(GrayN_Http_GrayN* client, int httpType, string data, vector<string> sentLogsBorn)
{
    // 删除已发送日志
    if (client->GrayN_Http_Get_HttpCode() == 200 && sentLogsBorn.size() > 0) {
        // 删除已发日志
        vector<string>::iterator sentBornIterator;
        for (sentBornIterator = sentLogsBorn.begin(); sentBornIterator != sentLogsBorn.end(); sentBornIterator++) {
//            cout<<sentBornIterator->c_str()<<endl;
            [p_GrayN_LogDatabase GrayN_LogDatabase_DeleteLogByBornTime:sentBornIterator->c_str() LogID:""];
        }
    }

    switch (httpType)
    {
        case GrayN_LogHttpINIT:
            GrayN_Log_ParseInit(data.c_str(), client);
            break;
        case GrayN_LogHttpSEND_REQUEST:
            GrayN_Log_ParseSendRequest(data.c_str(), client);
            break;
        default:
            break;
    }
}

void GrayNlogCenter::GrayNlogByBridge(void* bridgeLog)
{
    if (bridgeLog == nil) {
        return;
    }
    NSDictionary *dic = (NSDictionary *)bridgeLog;
    //    NSLog(@"OPCreateLogByBridge=%@", bridgeLog);
    NSString *logId = [dic objectForKey:@"logId"];
    NSString *logKey = [dic objectForKey:@"logKey"];
    NSString *logJson = [dic objectForKey:@"logJson"];
    GrayNlogCenter::GetInstance().GrayN_Log_CreateLog([logId UTF8String], [logKey UTF8String], [logJson UTF8String]);
}
