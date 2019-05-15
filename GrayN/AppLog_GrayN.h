//
//  AppLog_GrayN.h
//  OurpalmSDK
//
//  Created by op-mac1 on 14-4-23.
//
//

#ifndef __OurpalmSDK__AppLog__
#define __OurpalmSDK__AppLog__

#import <iostream>
#import  <objc/objc.h>

#import "GrayN_Http_GrayN.h"
#import "GrayN_TempleQueue.h"

GrayN_NameSpace_Start
    //发送错误日志
    class AppLog_GrayN : public GrayN_Thread_GrayN , public GrayN_Http_GrayN::GrayN_HttpListener
    {
    public:
        AppLog_GrayN();
        ~AppLog_GrayN();
        
    public:
        void CreateRequestAppLog_GrayN(const char* ssid,const char *propId,const char* error);
        void CreateResponseAppLog_GrayN(const char* ssid,const char *propId,const char* error);
        void CreateRestoreAppLog_GrayN(const char* ssid,const char *propId,const char* error);
        
    private:
        void CreateAppLog_GrayN(const char* logType,const char* ssid,const char *propId,const char* error);
        
        //启动线程，并将验证请求添加到队列中
        void SendAppLog_GrayN();
        
    private:
        void ParseAppLogResponse_GrayN();
        unsigned int AppLogGetCrc32_GrayN(char* InStr,unsigned int len);
        
    public:
        void GrayNrun(void *p);
        
        virtual void GrayN_On_HttpError(GrayN_Http_GrayN* client, GrayN_HttpErrorCode code);
        virtual void GrayN_On_HttpEvent(GrayN_Http_GrayN* client, GrayN_HttpEventCode code);
        virtual void GrayN_On_HttpResponse(GrayN_Http_GrayN* client,int code,int context_length,int startPos,int endPos,int totalContext,const char* data);
        virtual void GrayN_On_Http_Data(GrayN_Http_GrayN* client,const char* data,int count);
        
    private:
        GrayN_Http_GrayN* p_GrayN_AppLogHttp;
        string p_GrayN_AppLogHttpBuffer;
        
        //验证信息
        string p_GrayN_AppLogTime;
        string p_GrayN_AppLog;
        bool p_GrayN_SendStatus;
        int p_GrayN_RequestCount;
        
        string p_GrayN_IdKeyStr;
        
        AppLog_GrayN* p_GrayN_AppLogObject;
    };

GrayN_NameSpace_End

#endif /* defined(__OurpalmSDK__AppLog__) */
