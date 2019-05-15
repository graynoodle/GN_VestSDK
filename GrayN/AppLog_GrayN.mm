//
//  AppLog_GrayN.cpp
//  OurpalmSDK
//
//  Created by op-mac1 on 14-4-23.
//
//

#import "AppLog_GrayN.h"
#import "GrayNbaseSDK.h"
#import "GrayNconfig.h"
//#import "OPPurchase.h"
//#import "GrayN_UserCenter.h"
#import "GrayN_Store_IAP.h"
#import "GrayNjson_cpp.h"
#import <sstream>
//#import "GrayN_UrlEncode_GrayN.h"
//#define APPLOGDEBUG

GrayNusing_NameSpace;
    
AppLog_GrayN::AppLog_GrayN()
{
    p_GrayN_AppLogHttp = NULL;
    p_GrayN_AppLogObject = NULL;
}

AppLog_GrayN::~AppLog_GrayN()
{
    if (p_GrayN_AppLogHttp != NULL) {
        delete p_GrayN_AppLogHttp;
        p_GrayN_AppLogHttp = NULL;
    }
}

void AppLog_GrayN::CreateRequestAppLog_GrayN(const char* ssid,const char *propId,const char* error)
{
    CreateAppLog_GrayN("request",ssid,propId,error);
}
    
void AppLog_GrayN::CreateResponseAppLog_GrayN(const char* ssid,const char *propId,const char* error)
{
    CreateAppLog_GrayN("response",ssid,propId,error);
}

void AppLog_GrayN::CreateRestoreAppLog_GrayN(const char* ssid,const char *propId,const char* error)
{
    CreateAppLog_GrayN("restore",ssid,propId,error);
}

void AppLog_GrayN::CreateAppLog_GrayN(const char* logType,const char* ssid,const char *propId,const char* error)
{
    //request时间|request|订单号|用户id|角色id|SDK版本号|系统版本号|是否越狱|mac|idfa|wp8|道具id
    //request时间|response|订单号|用户id|角色id|SDK版本号|系统版本号|是否越狱|mac|idfa|wp8|道具id|错误类型
    p_GrayN_AppLog.clear();
    p_GrayN_AppLogTime.clear();
    p_GrayN_AppLogTime = [[GrayNbaseSDK GrayNgetCurrentMil_TimeString] UTF8String];
    string mOpSSID;     //掌趣订单号
    if(ssid == NULL){
        mOpSSID = p_GrayN_AppLogTime;
        mOpSSID.append("8888");
    } else {
        mOpSSID = ssid;
    }
    string errorTmpLog = "";
    
    errorTmpLog.append([[GrayNbaseSDK GrayNgetCurrentDate_Time] UTF8String]);
    errorTmpLog.append("|");
    errorTmpLog.append(logType);
    errorTmpLog.append("|");
    errorTmpLog.append(mOpSSID);
    errorTmpLog.append("|");
    errorTmpLog.append([GrayNbaseSDK GrayNgetGame_UserId]);
    errorTmpLog.append("|");
    errorTmpLog.append([GrayNbaseSDK GrayNgetGame_RoleId]);
    errorTmpLog.append("|");
    errorTmpLog.append([GrayNbaseSDK GrayNgetSdkVersion]);
    errorTmpLog.append("|");
    errorTmpLog.append([GrayNbaseSDK GrayNgetDeviceOsVersion]);
    errorTmpLog.append("|");
    if([GrayNbaseSDK GrayNgetDeviceIsJailBreak]){
        errorTmpLog.append("jailbreak");
    }
    errorTmpLog.append("|");
    errorTmpLog.append([GrayNbaseSDK GrayNgetDeviceMacAddress]);
    errorTmpLog.append("|");
    errorTmpLog.append([GrayNbaseSDK GrayNgetDeviceIDFA]);
    errorTmpLog.append("|");
    errorTmpLog.append([GrayNbaseSDK GrayNgetDeviceUniqueID]);
    errorTmpLog.append("|");
    errorTmpLog.append(propId);
    errorTmpLog.append("|");
    if(error)
        errorTmpLog.append(error);
//    cout<<errorTmpLog<<endl;

//    p_GrayN_AppLog = "2014-06-11 16:53:05|request|00522014061017535999000|0100010000000000000000000000000000009080|10004226|4.0.0.10013|7.0.4||com.fingerfun.kawaihunter.0992|";
    [GrayNbaseSDK GrayN_Debug_Log:@"%s ", errorTmpLog.c_str()];

    
    //******计算crc32进行校验*****
    p_GrayN_IdKeyStr.clear();
    string crc32;
    crc32.append(errorTmpLog);
    crc32.append("IT is a good day to play.");
    unsigned int idkey = AppLogGetCrc32_GrayN((char*)crc32.c_str(), (unsigned int)crc32.length());
    std::stringstream ss;
    std::string str;
    ss<<idkey;
    ss>>p_GrayN_IdKeyStr;
    //****************************
    
    //必须在这里urlencode否则校验值有问题
    p_GrayN_AppLog = [[GrayNbaseSDK GrayNurl_Encode:errorTmpLog.c_str()] UTF8String];
//    GrayN_UrlEncode_GrayN::GrayN_Url_Encode(tmp, p_GrayN_AppLog);
    
    //保存日志
    GrayN_Store_IAP::GetInstance().GrayN_Store_IAP_InsertAppLog(p_GrayN_AppLogTime, p_GrayN_AppLog);
    //发送日志
    SendAppLog_GrayN();
}

void AppLog_GrayN::SendAppLog_GrayN()
{
    p_GrayN_AppLogObject = this;
    if (p_GrayN_AppLogHttp == NULL) {
        //开启线程
        p_GrayN_AppLogHttp = new GrayN_Http_GrayN();
        p_GrayN_AppLogHttp->GrayN_Http_Set_Listener(this);
    }
    p_GrayN_SendStatus = false;
    p_GrayN_RequestCount = 1;
    this->GrayNstart();
}

void AppLog_GrayN::GrayNrun(void *p)
{
    if (p_GrayN_SendStatus) {
        //销毁对象
        GrayN_Sleep(2);
        if (p_GrayN_AppLogObject != NULL) {
            delete p_GrayN_AppLogObject;
            p_GrayN_AppLogObject = NULL;
        }
        return;
    }
    //发送日志
    string verUrl([GrayNbaseSDK GrayNgetApplogUrl]);
    if (verUrl == "") {
        verUrl = "http://prism.gamebean.net/logmonitor/sdk/stat/ac?";
    }
    string data;
    data.append("depart=misc&logid=appstore&serviceId=");
    data.append([GrayNbaseSDK GrayNget_ServiceId]);
    data.append("&id=");
    data.append(p_GrayN_IdKeyStr);
    data.append("&logStr=");
    data.append(p_GrayN_AppLog);
    
#ifdef APPLOGDEBUG
    cout<<"data="<<data<<endl;
    cout<<"p_GrayN_AppLog="<<p_GrayN_AppLog<<endl;
#endif
    
    p_GrayN_AppLogHttp->GrayN_Http_Set_ContentType("application/x-www-form-urlencoded");
    p_GrayN_AppLogHttp->GrayN_Http_Post_ByUrl(verUrl.c_str(), data.c_str(), (int)data.length());
}

void AppLog_GrayN::GrayN_On_HttpError(GrayN_Http_GrayN* client, GrayN_HttpErrorCode code)
{
    if (p_GrayN_RequestCount > 3) {
        [GrayNbaseSDK GrayN_Debug_Log:@"opApplog发送失败..."];

        p_GrayN_SendStatus = true;
        GrayNstart();        //不要忘记销毁对象
    }else{
        p_GrayN_RequestCount++;
        GrayNstart();
    }
}
    
void AppLog_GrayN::GrayN_On_HttpEvent(GrayN_Http_GrayN* client, GrayN_HttpEventCode code)
{
    if(code == k_GrayN_SEND_HEAD){
        p_GrayN_AppLogHttpBuffer.clear();
    } else if(code == k_GrayN_COMPLETE) {
        ParseAppLogResponse_GrayN();
        //不要忘记销毁对象
        p_GrayN_SendStatus = true;
        GrayNstart();
    }
}
    
void AppLog_GrayN::GrayN_On_HttpResponse(GrayN_Http_GrayN* client,int code,int context_length,int startPos,int endPos,int totalContext,const char* data)
{
    
}
    
void AppLog_GrayN::GrayN_On_Http_Data(GrayN_Http_GrayN* client,const char* data,int count)
{
    p_GrayN_AppLogHttpBuffer.append(data,count);
}
    
void AppLog_GrayN::ParseAppLogResponse_GrayN()
{
    GrayN_JSON::Reader    json_reader;
    GrayN_JSON::Value     json_object;
    
    if (!json_reader.parse(p_GrayN_AppLogHttpBuffer, json_object)){
        return;// json格式解析错
    }
    int code = json_object["code"].asInt();
    if (code == 200) {

        [GrayNbaseSDK GrayN_Debug_Log:@"opApplog发送成功..."];

        GrayN_Store_IAP::GetInstance().GrayN_Store_IAP_DeleteAppLog(p_GrayN_AppLogTime);
    }
}
    
unsigned int AppLog_GrayN::AppLogGetCrc32_GrayN(char* InStr,unsigned int len)
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
    
