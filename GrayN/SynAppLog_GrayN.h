//
//  SynAppLog_GrayN.h
//  OurpalmSDK
//
//  Created by op-mac1 on 14-4-23.
//
//

#ifndef __OurpalmSDK__SynAppLog__
#define __OurpalmSDK__SynAppLog__

#import <iostream>
#import <objc/objc.h>
#import "GrayN_Http_GrayN.h"
#import "GrayN_TempleQueue.h"

GrayN_NameSpace_Start
    
    //发送错误日志
    class SynAppLog_GrayN : public GrayN_Thread_GrayN , public GrayN_Http_GrayN::GrayN_HttpListener
    {
    public:
        SynAppLog_GrayN();
        ~SynAppLog_GrayN();
    
    public:
        inline static SynAppLog_GrayN& GetInstance()
        {
            static SynAppLog_GrayN GrayNappLog;
            return GrayNappLog;
        }
        
    public:
        //启动线程，并将验证请求添加到队列中
        void AddLocalAppLogRequest_GrayN(const char* tmpIndex,const char* tmpLog);
        
    private:
        void ParseSynAppLogResponse_GrayN();
        unsigned int SynAppLogGetCrc32_GrayN(char* InStr,unsigned int len);
        
    public:
        void GrayNrun(void *p);
        
        virtual void GrayN_On_HttpError(GrayN_Http_GrayN* client, GrayN_HttpErrorCode code);
        virtual void GrayN_On_HttpEvent(GrayN_Http_GrayN* client, GrayN_HttpEventCode code);
        virtual void GrayN_On_HttpResponse(GrayN_Http_GrayN* client,int code,int context_length,int startPos,int endPos,int totalContext,const char* data);
        virtual void GrayN_On_Http_Data(GrayN_Http_GrayN* client,const char* data,int count);
        
    public:
        bool p_GrayN_SynAppIsStop;
        
    private:
        GrayN_Http_GrayN* p_GrayN_SynAppHttp;
        string p_GrayN_SynAppHttpBuffer;
        
        //验证信息
        string p_GrayN_SynAppLogTime;
        string p_GrayN_SynAppLog;
        bool p_GrayN_SynAppLogSendStatus;
        int p_GrayN_SynAppLogRequestCount;
        

        GrayN_TempleQueue<GrayN_AppLogRequest>* p_GrayN_SynAppLogLoacalQueue;
        GrayN_AppLogRequest* p_GrayN_SynAppLogRequest;
    };

GrayN_NameSpace_End

#endif /* defined(__OurpalmSDK__SynAppLog__) */
