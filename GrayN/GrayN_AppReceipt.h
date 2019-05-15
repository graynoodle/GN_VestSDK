//
//  GrayN_AppReceipt.h
//  OurpalmSDK
//
//  Created by op-mac1 on 13-12-12.
//
//

#ifndef __OurpalmSDK__AppReceipt__
#define __OurpalmSDK__AppReceipt__

#import <iostream>
#import <objc/objc.h>
#import "GrayN_Http_GrayN.h"
#import "GrayNasyn_CallBack.h"
#ifdef HTTPS
#import "GrayN_Https_GrayN.h"
#endif

GrayN_NameSpace_Start

class GrayN_AppReceiptMsg
{
public:
    bool   m_GrayN_AppReceiptResult;
    string m_GrayN_AppReceiptResultDesc;
    string m_GrayN_AppReceiptSSID;
};

//负责游戏中购买收据的验证
class GrayN_AppReceipt : public GrayN_Thread_GrayN , public GrayN_Http_GrayN::GrayN_HttpListener
{
public:
    GrayN_AppReceipt();
    ~GrayN_AppReceipt();
    
public:
    inline static GrayN_AppReceipt& GetInstance()
    {
        static GrayN_AppReceipt GrayNappReceipt;
        return GrayNappReceipt;
    }
    
public:
    //启动线程，并将验证请求添加到队列中
    void GrayN_AppReceiptSendVerify(const char* tmpSSID,const char* tmpCountryCode,const char* receipt);
    void GrayN_AppReceiptSendVerify(const char* tmpSSID,const char* tmpCountryCode,const char* tmpCurrencyCode,const char* receipt);
    void GrayN_AppReceiptStopVerify();
    
private:
    void GrayN_AppReceiptVerifyResult(const char* data);
    static void GrayN_AppReceiptNotifyResult(void* args);
    
public:
    void GrayNrun(void* p);
    
    virtual void GrayN_On_HttpError(GrayN_Http_GrayN* client, GrayN_HttpErrorCode code);
    virtual void GrayN_On_HttpEvent(GrayN_Http_GrayN* client, GrayN_HttpEventCode code);
    virtual void GrayN_On_HttpResponse(GrayN_Http_GrayN* client,int code,int context_length,int startPos,int endPos,int totalContext,const char* data);
    virtual void GrayN_On_Http_Data(GrayN_Http_GrayN* client,const char* data,int count);
    
public:
    //是否实时显示提示框
    bool m_GrayN_AppReceiptIsShowAlert;

private:
    GrayN_Https_GrayN* p_GrayN_AppReceiptHttps;

    int p_GrayN_AppReceiptRequestCount;
    string p_GrayN_AppReceiptHttpsBuffer;
    bool p_GrayN_AppReceiptIsStop;
    int p_GrayN_AppReceiptRequestStatus;          //请求状态
    bool p_GrayN_AppReceiptVerifyStatus;          //验证状态
    
    //验证信息
    string p_GrayN_AppReceiptCountryCode;
    string p_GrayN_AppReceiptCurrencyCode;
    string p_GrayN_AppReceiptSSID;
    string p_GrayN_AppReceipt;
    GrayN_AppReceipt* p_GrayN_AppReceiptObject;
    
private:
    GrayNasyn_CallBack* p_GrayN_AppReceiptAsyn_CallBack;

};

GrayN_NameSpace_End

#endif /* defined(__OurpalmSDK__AppReceipt__) */
