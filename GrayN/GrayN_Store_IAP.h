//
//  StoreIAP.h
//
//  Created by 建南 刘 on 12-4-24.
//  Copyright (c) 2012年 Home. All rights reserved.
//

#ifndef OurpalmSDK_Store_IAP_h
#define OurpalmSDK_Store_IAP_h

#ifdef __cplusplus
#import <objc/objc.h>
#import "GrayN_Stream.h"
#import "GrayNconfig.h"
#import <string>

using namespace std;
#define TEMPIAP

GrayN_NameSpace_Start

    class GrayN_Store_IAP
    {
    public:
        class GrayN_Store_IAP_Listener
        {
        public:
            virtual void GrayN_AppPurchaseOnIAP(bool state,GrayN_InputStream* is){}
            virtual void GrayN_AppPurchaseTimeOut(){}
        };
    private:
        GrayN_Store_IAP();
        ~GrayN_Store_IAP();
    public:
        static GrayN_Store_IAP& GetInstance()
        {
            static GrayN_Store_IAP GrayNiap;
            return GrayNiap;
        }
    public:
        void GrayN_Store_IAP_Init();
        
        inline void GrayN_Store_IAP_SetListener(GrayN_Store_IAP_Listener* p_GrayN_Store_IAP_Listener){this->p_GrayN_Store_IAP_Listener=p_GrayN_Store_IAP_Listener;}
        inline GrayN_Store_IAP_Listener* GrayN_Store_IAP_GetListener(){return p_GrayN_Store_IAP_Listener;}
        bool GrayN_Store_IAP_CanMakePayments();
        void GrayN_Store_IAP_Buy(const char* itemID,const char* fee_permission,const char* fee_permission_currencycode,const char* fee_permission_note);
        
        //同步一次，无论是否完全发送完成
        void GrayN_Store_IAP_InsertData(std::string ssid,std::string userId,std::string receipt);
        void GrayN_Store_IAP_RemoveData(std::string ssid);
        
#ifdef TEMPIAP
        void GrayN_Store_IAP_InsertTempData(std::string ssid,std::string userId,std::string productId);
        void GrayN_Store_IAP_DealLeakedData(std::string productId,std::string userId,std::string receipt);
        void GrayN_Store_IAP_RemoveTempData(std::string ssid);
        void GrayN_Store_IAP_RemoveAllTempData();
        /*16*/
        void GrayN_Store_IAP_Remove2DaysTempData();
        /*16*/

#endif
        
        void GrayN_Store_IAP_SynAppReceipt(std::string userId="");
        void GrayN_Store_IAP_SynAppReceiptOver();                        //停止定时器
        
        //applog
        void GrayN_Store_IAP_InsertAppLog(std::string tmpApplogTime ,std::string tmpApplog);
        void GrayN_Store_IAP_DeleteAppLog(std::string tmpApplogTime);
        void GrayN_Store_IAP_CheckLocalAppLog();
        
        void GrayN_Store_IAP_PayResult(bool result, int errorCode);
        
        string GrayN_Store_IAP_Base64Encode(const char* inData);
        string GrayN_Store_IAP_MD5Encode(const char* source);

	private:
        id              p_GrayN_Store_IAP_fmdb;
        
        GrayN_Store_IAP_Listener*   p_GrayN_Store_IAP_Listener;
        
    };

GrayN_NameSpace_End
#endif

#endif
