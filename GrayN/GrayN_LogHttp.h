//
//  GrayN_LogHttp.h
//
//  Created by 韩征 on 14-5-13.
//  Copyright (c) 2014年 op-mac1. All rights reserved.
//

#import <iostream>
#import  <objc/objc.h>
#import "GrayN_Http_GrayN.h"
#import <vector>

enum GrayN_LogHttpType
{
    GrayN_LogHttpINIT,               // 初始化
    GrayN_LogHttpSEND_REQUEST,       // 发送请求
};

GrayN_NameSpace_Start
    class GrayN_LogHttp : public GrayN_Thread_GrayN , public GrayN_Http_GrayN::GrayN_HttpListener
    {
    public:
        GrayN_LogHttp();
        ~GrayN_LogHttp();
        
        void GrayN_LogHttp_ConnectNetwork(int httpType, const char* url, string data);  // 网络连接
        void GrayN_LogHttp_SendLog();
        void GrayNrun(void* p);
        virtual void GrayN_On_HttpError(GrayN_Http_GrayN* client, GrayN_HttpErrorCode code);
        virtual void GrayN_On_HttpEvent(GrayN_Http_GrayN* client, GrayN_HttpEventCode code);
        virtual void GrayN_On_HttpResponse(GrayN_Http_GrayN* client,int code,int context_length,int startPos,int endPos,int totalContext,const char* data);
        virtual void GrayN_On_Http_Data(GrayN_Http_GrayN* client,const char* data,int count);
        
    public:
        vector<string> m_GrayN_LogHttp_SentLogsBornTime;     // 已发送日志的唯一标识
        
    private:
        GrayN_Http_GrayN* p_GrayN_LogHttp;
        int p_GrayN_LogHttpType;
        string p_GrayN_LogHttpBuffer;
        string p_GrayN_LogHttpUrl;
        string p_GrayN_LogHttpData;
        bool p_GrayN_LogHttpSendStatus;
        int p_GrayN_LogHttpRequestCount;
        GrayN_LogHttp* p_GrayN_LogHttpObject;
    };
GrayN_NameSpace_End

