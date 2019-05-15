//
//  GrayN_ErrorLog_GrayN.cpp
//  GrayNSDK
//
//  Created by op-mac1 on 14-6-10.
//  Copyright (c) 2014年 op-mac1. All rights reserved.
//

#import "GrayN_ErrorLog_GrayN.h"
#import "GrayNcommon.h"
#import "GrayNconfig.h"
#import "GrayNjson_cpp.h"
#import <sstream>
#import "GrayN_UrlEncode_GrayN.h"
#import "GrayNSDK.h"
//#define ERRORDEBUG

GrayNusing_NameSpace;

GrayN_ErrorLog_GrayN::GrayN_ErrorLog_GrayN()
{
    p_GrayN_ErrorLog_Http = NULL;
    p_GrayN_ErrorLogObject = NULL;
}

GrayN_ErrorLog_GrayN::~GrayN_ErrorLog_GrayN()
{
    if (p_GrayN_ErrorLog_Http != NULL) {
        delete p_GrayN_ErrorLog_Http;
        p_GrayN_ErrorLog_Http = NULL;
    }
}

void GrayN_ErrorLog_GrayN::GrayN_ErrorLog_SendLog(const char *logType,const char *requestTime,
                               const char *errorType,const char* socketError,
                               int httpStatusCode,const char* responseData)
{
    p_GrayN_ErrorLog_LogId = logType;       //初始化、登录、。。。
    
    //request时间|request|订单号|用户id|角色id|SDK版本号|系统版本号|是否越狱|mac|idfa|wp8|道具id|request时间
    //request时间|response|订单号|用户id|角色id|SDK版本号|系统版本号|是否越狱|mac|idfa|wp8|道具id|response时间|错误类型
    //request时间|用户id|角色id|SDK版本号|系统版本号|mac|idfa|wp8|response时间|http错误类型|socketerror|httpStatusCode|responseData
    string tmp;
    tmp.append(requestTime);
    tmp.append("|");
    tmp.append(GrayNcommon::m_GrayN_Game_UserId);
    tmp.append("|");
    tmp.append(GrayNcommon::m_GrayN_Game_RoleId);
    tmp.append("|");
    tmp.append(GrayNcommon::m_GrayN_SDKVersion);
    tmp.append("|");
    tmp.append(GrayNcommon::m_GrayN_Device_OS_Version);
    tmp.append("|");
    tmp.append(GrayNcommon::m_GrayN_MAC_Address);
    tmp.append("|");
    tmp.append(GrayNcommon::m_GrayN_IDFA);
    tmp.append("|");
    tmp.append(GrayNcommon::m_GrayN_Device_UniqueId);
    tmp.append("|");
    tmp.append(GrayNcommon::GrayNgetCurrent_DateAndTime());
    tmp.append("|");        //error
    tmp.append(errorType);
    tmp.append("|");        //socketError
    tmp.append(socketError);
    tmp.append("|");        //httpStatusCode
    string statusCodeStr;
    std::stringstream ssss;
    ssss<<httpStatusCode;
    ssss>>statusCodeStr;
    tmp.append(statusCodeStr);
    tmp.append("|");        //httpdata
    string resData;
    GrayN_UrlEncode_GrayN::GrayN_Url_Encode(responseData, resData);
    tmp.append(resData);
    
    //******计算crc32进行校验*****
    string crc32;
    crc32.append(tmp);
    crc32.append("IT is a good day to play.");
    unsigned int idkey = GrayN_ErrorLog_GetCrc32((char*)crc32.c_str(), (int)crc32.length());
    std::stringstream ss;
    std::string str;
    ss<<idkey;
    ss>>p_GrayN_ErrorLog_IdKeyStr;
    //****************************
    
    GrayN_UrlEncode_GrayN::GrayN_Url_Encode(tmp.c_str(), p_GrayN_ErrorLog);
    
    p_GrayN_ErrorLogObject = this;
    if (p_GrayN_ErrorLog_Http == NULL) {
        //开启线程
        p_GrayN_ErrorLog_Http = new GrayN_Http_GrayN();
        p_GrayN_ErrorLog_Http->GrayN_Http_Set_Listener(this);
    }
    p_GrayN_ErrorLog_SendStatus = false;
    p_GrayN_ErrorLog_RequestCount = 1;
    this->GrayNstart();
}

void GrayN_ErrorLog_GrayN::GrayNrun(void *p)
{
    if (p_GrayN_ErrorLog_SendStatus) {
        // 销毁对象
        GrayN_Sleep(2);
        if (p_GrayN_ErrorLogObject != NULL) {
            delete p_GrayN_ErrorLogObject;
            p_GrayN_ErrorLogObject = NULL;
        }
        return;
    }
    // 发送日志
    string verUrl(GrayNSDK::m_GrayN_SDK_AppErrorUrl);
    
    string data;
    data.append("depart=misc&logid=");
    data.append(p_GrayN_ErrorLog_LogId);
    data.append("&serviceId=");
    data.append(GrayNcommon::m_GrayN_ServiceId);
    data.append("&id=");
    data.append(p_GrayN_ErrorLog_IdKeyStr);
    data.append("&logStr=");
    data.append(p_GrayN_ErrorLog);
    
    if (verUrl == "") {
        // 初始化的时候还没有设置地址，所以只能在这里特殊处理

        verUrl = GrayNcommon::GrayNgetLocal_StatisticalUrl();
        verUrl.append(GrayNappstoreLogRoute);
    }
    
#ifdef ERRORDEBUG
    cout<<"*******************"<<endl;
    cout<<verUrl<<endl;
    cout<<data<<endl;
    cout<<"*******************"<<endl;
#endif
    
    p_GrayN_ErrorLog_Http->GrayN_Http_Set_ContentType("application/x-www-form-urlencoded");
    p_GrayN_ErrorLog_Http->GrayN_Http_Post_ByUrl(verUrl.c_str(), data.c_str(), (int)data.length());
}

void GrayN_ErrorLog_GrayN::GrayN_On_HttpError(GrayN_Http_GrayN* client, GrayN_HttpErrorCode code)
{
    if (p_GrayN_ErrorLog_RequestCount >= 3) {
#ifdef ERRORDEBUG
        cout<<"错误日志发送失败！"<<endl;
#endif
        p_GrayN_ErrorLog_SendStatus = true;
        GrayNstart();        //不要忘记销毁对象
    }else{
        p_GrayN_ErrorLog_RequestCount++;
        GrayNstart();
    }
}

void GrayN_ErrorLog_GrayN::GrayN_On_HttpEvent(GrayN_Http_GrayN* client, GrayN_HttpEventCode code)
{
    if(code == k_GrayN_SEND_HEAD){
        p_GrayN_ErrorLog_HttpBuffer.clear();
    }else if(code == k_GrayN_COMPLETE)
    {
        GrayN_ErrorLog_ParseLog();
        //不要忘记销毁对象
        p_GrayN_ErrorLog_SendStatus = true;
        GrayNstart();
    }
}

void GrayN_ErrorLog_GrayN::GrayN_On_HttpResponse(GrayN_Http_GrayN* client,int code,int context_length,int startPos,int endPos,int totalContext,const char* data)
{
    
}

void GrayN_ErrorLog_GrayN::GrayN_On_Http_Data(GrayN_Http_GrayN* client,const char* data,int count)
{
    p_GrayN_ErrorLog_HttpBuffer.append(data,count);
}

void GrayN_ErrorLog_GrayN::GrayN_ErrorLog_ParseLog()
{
    GrayN_JSON::Reader    json_reader;
    GrayN_JSON::Value     json_object;
    
    if (!json_reader.parse(p_GrayN_ErrorLog_HttpBuffer, json_object)){
        return;// json格式解析错
    }
    int code = json_object["code"].asInt();
    if (code == 200) {
#ifdef ERRORDEBUG
        cout<<"错误日志发送成功！"<<endl;
        //cout<<p_GrayN_ErrorLog_HttpBuffer<<endl;
#endif
    }
}

unsigned int GrayN_ErrorLog_GrayN::GrayN_ErrorLog_GetCrc32(char* InStr,unsigned int len)
{
    //生成Crc32的查询表
    unsigned int Crc32Table[256];
    int i,j;
    unsigned int Crc;
    for (i = 0; i < 256; i++)
    {
        Crc = i;
        for (j = 0; j < 8; j++)
        {
            if (Crc & 1)
                Crc = (Crc >> 1) ^ 0xEDB88320;
            else
                Crc >>= 1;
        }
        Crc32Table[i] = Crc;
    }
    //开始计算CRC32校验值
    Crc=0xffffffff;
    for(int i=0; i<len; i++){
        Crc = (Crc >> 8)^ Crc32Table[(Crc & 0xFF) ^ InStr[i]];
    }
    
    Crc ^= 0xFFFFFFFF;
    return Crc;
}
