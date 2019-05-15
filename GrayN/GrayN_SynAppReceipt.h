//
//  GrayN_SynAppReceipt.h
//  OurpalmSDK
//
//  Created by op-mac1 on 13-11-22.
//
//

#ifndef __OurpalmSDK__SynAppReceipt__
#define __OurpalmSDK__SynAppReceipt__

#import <iostream>
#import "GrayN_Http_GrayN.h"
#import "GrayN_TempleQueue.h"
#ifdef HTTPS
#import "GrayN_Https_GrayN.h"
#endif

GrayN_NameSpace_Start
    
    //同步订单：1、本地订单   2、其他订单（第一次验证没有成功的订单，多为连接超时）
    //本地订单完成后，开始每两分钟查看一下有没有其他订单
    class GrayN_SynAppReceipt : public GrayN_Thread_GrayN , public GrayN_Http_GrayN::GrayN_HttpListener
    {
    public:
        GrayN_SynAppReceipt();
        ~GrayN_SynAppReceipt();
        
    public:
        inline static GrayN_SynAppReceipt& GetInstance()
        {
            static GrayN_SynAppReceipt GrayNsynAppReceipt;
            return GrayNsynAppReceipt;
        }
        
    public:
        void GrayN_SynAppReceiptSendVerify();
        void GrayN_SynAppReceiptStopVerify();
        int  GrayN_SynAppReceiptLocalQueueSize();
        
    private:
        void GrayN_SynAppReceiptVerify();
        void GrayN_SynAppReceiptConnectToVerify();
        void GrayN_SynAppReceiptVerifyResult(const char* data);
        
    public:
        void GrayN_SynAppReceiptAddLocalVeritifyRequest(const char* tmpSSid,const char* tmpReceipt);
        void GrayN_SynAppReceiptAddLocalVeritifyRequest(GrayN_AppVerifyRequest* request);
//        void addResendVeritifyRequest(const char* tmpSSid,const char* tmpReceipt);
        
    public:
        void GrayNrun(void* p);

        virtual void GrayN_On_HttpError(GrayN_Http_GrayN* client, GrayN_HttpErrorCode code);
        virtual void GrayN_On_HttpEvent(GrayN_Http_GrayN* client, GrayN_HttpEventCode code);
        virtual void GrayN_On_HttpResponse(GrayN_Http_GrayN* client,int code,int context_length,int startPos,int endPos,int totalContext,const char* data);
        virtual void GrayN_On_Http_Data(GrayN_Http_GrayN* client,const char* data,int count);
        
        static string m_GrayN_StoreKey;

#ifdef CHECKORDER
        static void GrayN_SynAppReceiptStoreKey();
        static bool GrayN_SynAppReceiptCheckOrder(const char* order);
        static void GrayN_SynAppReceiptParseSystemTime(const char* data);
        static void GrayN_SynAppReceiptGetSystemTime(const char* timeData);
#endif
        
    private:
        GrayN_TempleQueue<GrayN_AppVerifyRequest>* p_GrayN_SynAppReceiptLocalQueue;         //先存储本地同步订单，然后再存储
        GrayN_TempleQueue<GrayN_AppVerifyRequest>* p_GrayN_SynAppReceiptRequestQueue;        //存储当前未成功的订单

        GrayN_Https_GrayN* p_GrayN_SynAppReceiptHttps;

        int     p_GrayN_SynAppReceiptRequestCount;
        string  p_GrayN_SynAppReceiptHttpsBuffer;
        bool    p_GrayN_SynAppReceiptIsStop;
        bool    p_GrayN_SynAppReceiptIsLocalVerify;             //是否在进行本地数据验证
        int     p_GrayN_SynAppReceiptRequestStatus;             //请求状态
        GrayN_AppVerifyRequest* p_GrayN_SynAppReceiptRequest;
#ifdef CHECKORDER
        static std::string p_GrayN_SynAppReceiptSystemTime;
#endif
    };

GrayN_NameSpace_End

#endif /* defined(__OurpalmSDK__SynAppReceipt__) */
