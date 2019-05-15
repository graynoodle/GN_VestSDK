//
//  GrayN_LogHttp.c
//
//  Created by 韩征 on 14-5-13.
//  Copyright (c) 2014年 op-mac1. All rights reserved.
//

#import "GrayN_LogHttp.h"
#import "GrayNcommon.h"
#import "GrayNconfig.h"
#import "GrayNlogCenter.h"

#ifdef DEBUG
//#define HTTPDEBUG
#endif
GrayN_NameSpace_Start

GrayN_LogHttp::GrayN_LogHttp()
{
    m_GrayN_LogHttp_SentLogsBornTime.clear();
    p_GrayN_LogHttpBuffer.clear();
    p_GrayN_LogHttpData = "";
    p_GrayN_LogHttpUrl = "";
    p_GrayN_LogHttp = NULL;
    p_GrayN_LogHttpObject = NULL;
}

GrayN_LogHttp::~GrayN_LogHttp()
{
    if (p_GrayN_LogHttp != NULL) {
        delete p_GrayN_LogHttp;
        p_GrayN_LogHttp = NULL;
    }
}

void GrayN_LogHttp::GrayN_LogHttp_ConnectNetwork(int httpType, const char* url, string data)
{
    p_GrayN_LogHttpType = httpType;
    p_GrayN_LogHttpUrl = url;
    p_GrayN_LogHttpData = data;
    GrayN_LogHttp_SendLog();
}

void GrayN_LogHttp::GrayN_LogHttp_SendLog()
{
    p_GrayN_LogHttpObject = this;
    if (p_GrayN_LogHttp == NULL) {
        //开启线程
        p_GrayN_LogHttp = new GrayN_Http_GrayN();
        p_GrayN_LogHttp->GrayN_Http_Set_Listener(this);
    }
    p_GrayN_LogHttpSendStatus = false;
    p_GrayN_LogHttpRequestCount = 0;
    this->GrayNstart();
}

void GrayN_LogHttp::GrayNrun(void* p)
{
    if (p_GrayN_LogHttpSendStatus) {
        //销毁对象
        GrayN_Sleep(2);
        if (p_GrayN_LogHttpObject != NULL) {
            delete p_GrayN_LogHttpObject;
            p_GrayN_LogHttpObject = NULL;
        }
        return;
    }
    //发送日志
    p_GrayN_LogHttp->GrayN_Http_Post_ByUrl(p_GrayN_LogHttpUrl.c_str(), p_GrayN_LogHttpData.c_str(), p_GrayN_LogHttpData.length());
}

void GrayN_LogHttp::GrayN_On_HttpError(GrayN_Http_GrayN* client, GrayN_HttpErrorCode code)
{
    if (p_GrayN_LogHttpRequestCount > 3) {

#ifdef HTTPDEBUG
        GrayNcommon::GrayN_DebugLog("该日志队列发送失败：\n%s",p_GrayN_LogHttpData.c_str());
#endif
        GrayNcommon::GrayN_ConsoleLog(p_GrayN_LogHttpData.c_str());
        p_GrayN_LogHttpSendStatus = true;
        GrayNstart();        //不要忘记销毁对象
    }else{
        p_GrayN_LogHttpRequestCount++;
        GrayNstart();
    }
    
#ifdef HTTPDEBUG
    GrayNcommon::GrayN_DebugLog("on http error code=%d", code);
#endif
    client->GrayNstop();
    GrayNlogCenter::GetInstance().GrayN_Log_ParseHttpError(&code, p_GrayN_LogHttpType);
}

void GrayN_LogHttp::GrayN_On_HttpEvent(GrayN_Http_GrayN* client, GrayN_HttpEventCode code)
{
#ifdef HTTPDEBUG
    GrayNcommon::GrayN_DebugLog("on http event code = %d", code);
#endif
    
    if(code == k_GrayN_SEND_HEAD) {
        p_GrayN_LogHttpBuffer.clear();
    } else if(code == k_GrayN_COMPLETE) {
        client->GrayNstop();
        if (p_GrayN_LogHttpType == GrayN_LogHttpSEND_REQUEST && client->GrayN_Http_Get_HttpCode() == 200) {
#ifdef DEBUG
            GrayNcommon::GrayN_DebugLog("GrayN_LogHttp:日志发送成功！");
#endif
        }
        
        GrayNlogCenter::GetInstance().GrayN_Log_ParseHttpData(client, p_GrayN_LogHttpType, p_GrayN_LogHttpBuffer, m_GrayN_LogHttp_SentLogsBornTime);
        //不要忘记销毁对象
        p_GrayN_LogHttpSendStatus = true;
        GrayNstart();
    }
}

void GrayN_LogHttp::GrayN_On_HttpResponse(GrayN_Http_GrayN* client,int code,int context_length,int startPos,int endPos,int totalContext,const char* data)
{
    
}

void GrayN_LogHttp::GrayN_On_Http_Data(GrayN_Http_GrayN* client,const char* data,int count)
{
#ifdef HTTPDEBUG
    GrayNcommon::GrayN_DebugLog("on http length=%d data=%s",count,data);
#endif
    p_GrayN_LogHttpBuffer.append(data,count);
}

GrayN_NameSpace_End
