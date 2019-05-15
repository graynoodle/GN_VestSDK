//
//  GrayN_AppPurchase.h
//  OurpalmSDK
//
//  Created by gamebean on 13-1-17.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#ifndef OurpalmSDK_AppPurchase_h
#define OurpalmSDK_AppPurchase_h
#import "GrayN_Store_IAP.h"
#import "GrayNjson_cpp.h"

using namespace std;

GrayN_NameSpace_Start
class GrayN_AppPurchase : public GrayN_Store_IAP::GrayN_Store_IAP_Listener
{
public:
    GrayN_AppPurchase();
    ~GrayN_AppPurchase();
public:
    inline static GrayN_AppPurchase& GetInstance()
    {
        static GrayN_AppPurchase GrayNapp;
        return GrayNapp;
    }
public:
    
    // 此接口有特殊用途
    void GrayN_AppPurchaseInit();
    void GrayN_AppPurchaseInitOver();
    void GrayN_AppPurchaseParseChargeInfo(GrayN_JSON::Value chargeInfoJson);
    
public:
    void GrayN_AppPurchaseOnIAP(bool state, GrayN_InputStream* is);
    void GrayN_AppPurchaseTimeOut();
    
public:
    //处理未验证的订单：规则为1、启动应用那时自动启动  2、定时发送（1min\2min\5min）
    void GrayN_AppPurchaseSynAppReceipt();
    void GrayN_AppPurchaseSynAppLog();
    
private:
    string p_GrayN_AppPurchaseAppReceipt;
};

GrayN_NameSpace_End
#endif
