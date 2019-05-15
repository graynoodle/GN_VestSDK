//
//  GrayN_UserHeart.cpp
//
//  Created by op-mac1 on 14-3-4.
//  Copyright (c) 2014年 op-mac1. All rights reserved.
//

#import "GrayN_UserHeart.h"

#import "OPGameSDK.h"
#import "GrayNconfig.h"
#import "GrayN_UserCenter.h"
#import "GrayN_Offical.h"
#import "GrayN_Des_GrayN.h"

#define HEARTDEBUG
GrayNusing_NameSpace;

int GrayN_UserHeart::m_GrayN_UserHeart_BeatingTime;
std::string GrayN_UserHeart::m_GrayN_UserHeart_Url;
p_GrayN_UserHeart_Observer* GrayN_UserHeart::p_GrayN_UserHeartObserver;

GrayN_UserHeart::GrayN_UserHeart()
{
//    p_GrayN_UserHeart_Https = new GrayN_Http_GrayN();
    p_GrayN_UserHeart_Https = new GrayN_Https_GrayN();

    p_GrayN_UserHeart_Https->GrayN_Http_Set_Listener(this);
    p_GrayN_UserHeart_Timer = NULL;
}

GrayN_UserHeart::~GrayN_UserHeart()
{
    if (p_GrayN_UserHeart_Timer) {
        p_GrayN_UserHeart_Timer->GrayN_StopTimer();
    }
    if (p_GrayN_UserHeart_Https) {
        delete p_GrayN_UserHeart_Https;
        p_GrayN_UserHeart_Https = NULL;
    }
}

void GrayN_UserHeart::GrayN_UserHeart_SetListener(p_GrayN_UserHeart_Observer* observer)
{
    p_GrayN_UserHeartObserver = observer;
}

void GrayN_UserHeart::GrayN_UserHeart_HeartBeating()
{
    if (m_GrayN_UserHeart_BeatingTime == 0) {
        GrayN_UserHeart_StopHeartBeat();
        return;
    }
    p_GrayN_UserHeart_IsStop = false;
    p_GrayN_UserHeartObject = this;
    //开启心跳
    p_GrayN_UserHeart_Timer = new GrayN_Timer_GrayN();
    p_GrayN_UserHeart_Timer->GrayN_StartTimer(60*m_GrayN_UserHeart_BeatingTime, this);     //注意这里
//        p_GrayN_UserHeart_Timer->GrayN_StartTimer(15, this);     //注意这里
}

void GrayN_UserHeart::GrayN_UserHeart_StopHeartBeat()
{
    p_GrayN_UserHeart_IsStop = true;
    if (p_GrayN_UserHeart_Timer) {
        p_GrayN_UserHeart_Timer->GrayN_StopTimer();
        p_GrayN_UserHeart_Timer = NULL;      //由线程自己释放
    }
}

void GrayN_UserHeart::GrayN_UserHeart_RunHeartBeating(string type)
{
    //心跳无需加密
    GrayN_JSON::Value root;
    root["service"] = GrayN_JSON::Value(GrayNheartBeatInterface);
    root["sessionId"] = GrayN_JSON::Value(GrayNcommon::m_GrayN_SessionId);
    root["roleId"] = GrayN_JSON::Value(GrayNcommon::m_GrayN_Game_RoleId);
    root["roleName"] = GrayN_JSON::Value(GrayNcommon::m_GrayN_Game_RoleName);
    root["roleLevel"] = GrayN_JSON::Value(GrayNcommon::m_GrayN_Game_RoleLevel);
    root["roleVipLevel"] = GrayN_JSON::Value(GrayNcommon::m_GrayN_Game_RoleVipLevel);
    root["serverId"] = GrayN_JSON::Value(GrayNcommon::m_GrayN_Game_ServerId);
    root["userId"] = GrayN_JSON::Value(GrayNcommon::m_GrayN_Game_UserId);
    root["heartbeatType"] = GrayN_JSON::Value(type);

    GrayN_JSON::FastWriter fast_writer;
    string tmp = fast_writer.write(root);

    string data = "";
    string desData;
    
    GrayN_Des_GrayN::GrayN_DesEncrypt(tmp, GrayNcommon::m_GrayN_SecretKey.c_str(), desData);
    data.append(desData);
    data.append(GrayNcommon::m_GrayN_DesKey.c_str());

#ifdef HEARTDEBUG

#endif
    p_GrayN_UserHeart_HttpBuffer.clear();
    p_GrayN_UserHeart_HttpType = GrayN_UserHeart_Get_Heart_Info;
//    p_GrayN_UserHeart_Https->GrayN_Http_Set_ContentType("application/x-www-form-urlencoded");
//    p_GrayN_UserHeart_Https->GrayN_Http_Post_ByUrl(m_GrayN_UserHeart_Url.c_str(), data.c_str(), (int)data.length());
    
    string httpsUrl = m_GrayN_UserHeart_Url;
    GrayNcommon::GrayNstringReplace(httpsUrl, "http://", "https://");
    p_GrayN_UserHeart_Https->GrayN_Https_Post(httpsUrl, data);
    GrayNcommon::GrayN_DebugLog("opUserHeartHttpUrls:%s\nopUserHeartHttpData:",httpsUrl.c_str());
    GrayNcommon::GrayN_DebugLog(tmp.c_str());
}

void GrayN_UserHeart::GrayN_UserHeart_ParseHeartbeating()
{
    GrayN_JSON::Reader    json_reader;
    GrayN_JSON::Value     json_object;
    
    string decodeStr = "";
    GrayN_Des_GrayN::GrayN_DesDecrypt(p_GrayN_UserHeart_HttpBuffer, decodeStr);
//    cout<<decodeStr<<endl;

    if (!json_reader.parse(decodeStr, json_object)){
#ifdef HEARTDEBUG
        GrayNcommon::GrayN_DebugLog("opUserHeart=%s","心跳数据无法解析！");
#endif
        return;
    }
    if (json_object["status"].empty() ||
        json_object["errorCode"].empty() ||
        json_object["errorDesc"].empty()) {
#ifdef HEARTDEBUG
        GrayNcommon::GrayN_DebugLog("opUserHeart=%s","心跳返回的数据不完整！");
#endif
        return;
    }
    string status = json_object["status"].asString();
    if (status == "0") {
#ifdef HEARTDEBUG
        GrayNcommon::GrayN_DebugLog("opUserHeart: Abnormal.");
#endif
    } else {
        GrayNcommon::GrayN_DebugLog("opUserHeart: Normal.");
//        cout<<decodeStr<<endl;
        
        GrayN_JSON::Value messages = json_object["data"]["messages"];
//        GrayN_JSON::Value item;
//        item["type"] = "forum";
//        item["show"] = "1";
//        messages.append(item);
//        GrayN_Offical::GetInstance().ControlRedPoint(messages);
    }
    
}

void GrayN_UserHeart::GrayN_TimeUp()
{
    if (p_GrayN_UserHeart_IsStop) {
        if (p_GrayN_UserHeartObject) {
            delete p_GrayN_UserHeartObject;
            p_GrayN_UserHeartObject = NULL;
        }
        return;
    }
    GrayN_UserHeart_RunHeartBeating("1");
}

void GrayN_UserHeart::GrayN_On_HttpError(GrayN_Http_GrayN* client, GrayN_HttpErrorCode code)
{
#ifdef HTTPDEBUG
    GrayNcommon::GrayN_DebugLog("GrayN_UserHeart::GrayN_On_HttpError code=%d", code);
#endif
    //心跳异常，不用做任何处理，等待下次心跳
    //GrayN_UserHeart_HeartBeating();
}

void GrayN_UserHeart::GrayN_On_HttpEvent(GrayN_Http_GrayN* client, GrayN_HttpEventCode code)
{
#ifdef HTTPDEBUG
    GrayNcommon::GrayN_DebugLog("GrayN_UserHeart::GrayN_On_HttpEvent code = %d", code);
#endif
    if(code == k_GrayN_SEND_HEAD){
        p_GrayN_UserHeart_HttpBuffer.clear();
    }else if(code == k_GrayN_COMPLETE)
    {
        GrayN_UserHeart_ParseHeartbeating();
    }
}

void GrayN_UserHeart::GrayN_On_HttpResponse(GrayN_Http_GrayN* client,int code,int context_length,int startPos,int endPos,int totalContext,const char* data)
{
    
}

void GrayN_UserHeart::GrayN_On_Http_Data(GrayN_Http_GrayN* client,const char* data,int count)
{
#ifdef HTTPDEBUG
    GrayNcommon::GrayN_DebugLog("GrayN_UserHeart::GrayN_On_Http_Data length=%d data=%s", count, data);
#endif
    p_GrayN_UserHeart_HttpBuffer.append(data,count);
}
