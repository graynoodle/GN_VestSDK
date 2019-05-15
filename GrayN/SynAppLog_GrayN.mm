//
//  SynAppLog_GrayN.cpp
//  OurpalmSDK
//
//  Created by op-mac1 on 14-4-23.
//
//

#import "SynAppLog_GrayN.h"
#import "GrayN_Store_IAP.h"
#import "GrayNjson_cpp.h"
#import "GrayNbaseSDK.h"
#import <sstream>

//#import "OurpalmSDK.h"
//#import "GrayN_UrlEncode_GrayN.h"

//#define SYNAPPLOGDEBUG

GrayNusing_NameSpace;
    
SynAppLog_GrayN::SynAppLog_GrayN()
{
    p_GrayN_SynAppHttp = new GrayN_Http_GrayN();
    p_GrayN_SynAppHttp->GrayN_Http_Set_Listener(this);
    p_GrayN_SynAppLogLoacalQueue = new GrayN_TempleQueue<GrayN_AppLogRequest>();
    p_GrayN_SynAppLogRequestCount = 1;
    p_GrayN_SynAppIsStop = false;
}

SynAppLog_GrayN::~SynAppLog_GrayN()
{
    if (p_GrayN_SynAppHttp != NULL) {
        delete p_GrayN_SynAppHttp;
        p_GrayN_SynAppHttp = NULL;
    }
    if (p_GrayN_SynAppLogLoacalQueue != NULL) {
        delete p_GrayN_SynAppLogLoacalQueue;
        p_GrayN_SynAppLogLoacalQueue = NULL;
    }
}

void SynAppLog_GrayN::AddLocalAppLogRequest_GrayN(const char* tmpIndex,const char* tmpLog)
{
    GrayN_AppLogRequest* tmp = new GrayN_AppLogRequest();
    tmp->m_GrayNappLogTime = tmpIndex;
    tmp->m_GrayNappLog = tmpLog;
    p_GrayN_SynAppLogLoacalQueue->push(tmp);
}

void SynAppLog_GrayN::GrayNrun(void *p)
{
    if (p_GrayN_SynAppLogLoacalQueue->empty()) {
        if (p_GrayN_SynAppIsStop) {
#ifdef SYNAPPLOGDEBUG
            cout<<"错误日志发送完成！"<<endl;
#endif
            return;
        }
        //获取log日志
        GrayN_Store_IAP::GetInstance().GrayN_Store_IAP_CheckLocalAppLog();
        if (p_GrayN_SynAppLogLoacalQueue->empty()) {
#ifdef SYNAPPLOGDEBUG
            cout<<"错误日志发送完成！"<<endl;
#endif
            return;
        }else if (p_GrayN_SynAppLogLoacalQueue->size()<10){
            p_GrayN_SynAppIsStop = true;
        }
#ifdef SYNAPPLOGDEBUG
        cout<<"发送新的本地日志！"<<endl;
#endif
    }
    
    p_GrayN_SynAppLogRequest = p_GrayN_SynAppLogLoacalQueue->front_element();
    if (p_GrayN_SynAppLogRequest == NULL) {
        return;
    }
    p_GrayN_SynAppLog = p_GrayN_SynAppLogRequest->m_GrayNappLog;
    p_GrayN_SynAppLogTime = p_GrayN_SynAppLogRequest->m_GrayNappLogTime;
    
    //发送日志
    string verUrl([GrayNbaseSDK GrayNgetApplogUrl]);
    if (verUrl == "") {
        verUrl = "http://prism.gamebean.net/logmonitor/sdk/stat/ac?";
    }
    //非常重要，请参看AppLog.cpp
    string tmp = "";
    tmp = [[GrayNbaseSDK GrayNurl_Decode:p_GrayN_SynAppLog.c_str()] UTF8String];
    
    //******计算crc32进行校验*****
    string idKeyStr;
    string crc32;
    crc32.append(tmp);
    crc32.append("IT is a good day to play.");
    unsigned int idkey = SynAppLogGetCrc32_GrayN((char*)crc32.c_str(), (int)crc32.length());
    std::stringstream ss;
    std::string str;
    ss<<idkey;
    ss>>idKeyStr;
    //****************************
    
    string data;
    data.append("depart=misc&logid=appstore&serviceId=");
    data.append([GrayNbaseSDK GrayNget_ServiceId]);
    data.append("&id=");
    data.append(idKeyStr);
    data.append("&logStr=");
    data.append(p_GrayN_SynAppLog);
    
#ifdef SYNAPPLOGDEBUG
    cout<<data<<endl;
    cout<<p_GrayN_SynAppLog<<endl;
#endif
    
    p_GrayN_SynAppHttp->GrayN_Http_Set_ContentType("application/x-www-form-urlencoded");
    p_GrayN_SynAppHttp->GrayN_Http_Post_ByUrl(verUrl.c_str(), data.c_str(), data.length());
}

void SynAppLog_GrayN::GrayN_On_HttpError(GrayN_Http_GrayN* client, GrayN_HttpErrorCode code)
{
    if (p_GrayN_SynAppLogRequestCount > 3) {
#ifdef SYNAPPLOGDEBUG
        cout<<"appstore计费日志发送失败！"<<endl;
#endif
        p_GrayN_SynAppLogSendStatus = true;
        p_GrayN_SynAppLogLoacalQueue->pop();
        p_GrayN_SynAppLogRequestCount = 1;
        GrayNstart();
    }else{
        p_GrayN_SynAppLogRequestCount++;
        GrayNstart();
    }
}

void SynAppLog_GrayN::GrayN_On_HttpEvent(GrayN_Http_GrayN* client, GrayN_HttpEventCode code)
{
    if(code == k_GrayN_SEND_HEAD){
        p_GrayN_SynAppHttpBuffer.clear();
    }else if(code == k_GrayN_COMPLETE)
    {
        p_GrayN_SynAppLogSendStatus = true;
        p_GrayN_SynAppLogLoacalQueue->pop();
        ParseSynAppLogResponse_GrayN();
        GrayNstart();
    }
}

void SynAppLog_GrayN::GrayN_On_HttpResponse(GrayN_Http_GrayN* client,int code,int context_length,int startPos,int endPos,int totalContext,const char* data)
{
    
}

void SynAppLog_GrayN::GrayN_On_Http_Data(GrayN_Http_GrayN* client,const char* data,int count)
{
    p_GrayN_SynAppHttpBuffer.append(data,count);
}

void SynAppLog_GrayN::ParseSynAppLogResponse_GrayN()
{
    GrayN_JSON::Reader    json_reader;
    GrayN_JSON::Value     json_object;
    
    if (!json_reader.parse(p_GrayN_SynAppHttpBuffer, json_object)){
        return;// json格式解析错
    }
    int code = json_object["code"].asInt();
    if (code == 200) {
#ifdef SYNAPPLOGDEBUG
        cout<<"错误日志发送成功！"<<endl;
#endif
        GrayN_Store_IAP::GetInstance().GrayN_Store_IAP_DeleteAppLog(p_GrayN_SynAppLogTime);
    }
}
    
unsigned int SynAppLog_GrayN::SynAppLogGetCrc32_GrayN(char* InStr,unsigned int len)
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
