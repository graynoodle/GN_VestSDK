//
//  GrayN_ErrorLog_GrayN.h
//
//  Created by op-mac1 on 14-6-10.
//  Copyright (c) 2014年 op-mac1. All rights reserved.
//

#import <iostream>
#import  <objc/objc.h>
#import "GrayN_Http_GrayN.h"

GrayN_NameSpace_Start

//发送错误日志
class GrayN_ErrorLog_GrayN : public GrayN_Thread_GrayN , public GrayN_Http_GrayN::GrayN_HttpListener
{
public:
    GrayN_ErrorLog_GrayN();
    ~GrayN_ErrorLog_GrayN();
    
public:
    //logType   init oplogin thirdlogin update charge
    //requestTime  http发起请求的时间
    //errorType  错误类型
    //httpStatusCode  http状态码
    //responseData  http数据
    void GrayN_ErrorLog_SendLog(const char *logType,const char *requestTime,
                        const char *errorType,const char* socketError,
                        int httpStatusCode,const char* responseData);
    
private:
    void GrayN_ErrorLog_ParseLog();
    unsigned int GrayN_ErrorLog_GetCrc32(char* InStr,unsigned int len);
    
public:
    void GrayNrun(void *p);
    
    virtual void GrayN_On_HttpError(GrayN_Http_GrayN* client, GrayN_HttpErrorCode code);
    virtual void GrayN_On_HttpEvent(GrayN_Http_GrayN* client, GrayN_HttpEventCode code);
    virtual void GrayN_On_HttpResponse(GrayN_Http_GrayN* client,int code,int context_length,int startPos,int endPos,int totalContext,const char* data);
    virtual void GrayN_On_Http_Data(GrayN_Http_GrayN* client,const char* data,int count);
    

private:
    GrayN_Http_GrayN* p_GrayN_ErrorLog_Http;
    string p_GrayN_ErrorLog_HttpBuffer;
    
    //日志信息
    string p_GrayN_ErrorLog;
    bool p_GrayN_ErrorLog_SendStatus;
    int p_GrayN_ErrorLog_RequestCount;
    string p_GrayN_ErrorLog_LogId;
    
    string p_GrayN_ErrorLog_IdKeyStr;
    
    GrayN_ErrorLog_GrayN* p_GrayN_ErrorLogObject;
};

GrayN_NameSpace_End


