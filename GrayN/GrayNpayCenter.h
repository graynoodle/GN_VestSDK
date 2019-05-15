//
//  GrayNpayCenter.h
//
//  Created by op-mac1 on 14-1-7.
//  Copyright (c) 2014年 op-mac1. All rights reserved.
//
#import "OPGameSDK.h"
#import <iostream>
#import "GrayNasyn_CallBack.h"
#ifdef WIN32
#import <hash_map>
#else
#import <ext/hash_map>
using namespace   __gnu_cxx;
#endif

#import "GrayNconfig.h"
#import "GrayNjson_cpp.h"
/*5.1.2*/
#import "GrayN_Https_GrayN.h"
/*5.1.2*/


GrayN_NameSpace_Start

class GrayNpayCenter : public GrayN_Http_GrayN::GrayN_HttpListener
{
private:
    enum GrayN_Pay_HttpType
    {
        GrayN_Pay_Get_ProductList,          // 获取道具列表
        GrayN_Pay_Go_Purchase,           // 购买
        GrayN_Pay_Exchange_Gamecode,     // 礼包码兑换
        GrayN_Pay_Get_H5_Deeplink,       // 获取微信deeplink
        GrayN_Pay_Get_PayResult,         // 支付结果
    };
    
public:
    GrayNpayCenter();
    ~GrayNpayCenter();
    
public:
    inline static GrayNpayCenter& GetInstance(){
        static GrayNpayCenter GrayN_payCenter;
        return GrayN_payCenter;
    }
    
public:
    virtual void GrayN_On_HttpError(GrayN_Http_GrayN* client, GrayN_HttpErrorCode code);
    virtual void GrayN_On_HttpEvent(GrayN_Http_GrayN* client, GrayN_HttpEventCode code);
    virtual void GrayN_On_HttpResponse(GrayN_Http_GrayN* client,int code,int context_length,int startPos,int endPos,int totalContext,const char* data);
    virtual void GrayN_On_Http_Data(GrayN_Http_GrayN* client,const char* data,int count);
    
private:
    static void GrayN_Pay_ProcessParseHttpData(void* args);
    static void GrayN_Pay_ProcessHttpError(void* args);
    
public:
    void GrayN_Pay_ParseHttpError(void* args);
    void GrayN_Pay_ParseHttpData(GrayN_Http_GrayN* client);
    
public:
    // 网络连接
    void GrayN_Pay_ConnectNetwork(int httpType, const char* url, string data);
    //购买
    void GrayN_Pay_GotoPurchase(OPPurchaseParam param);
    //礼包码
    void GrayN_Pay_ExchangeGameCode(const char* gamecode,const char *deleverUrl,const char *extendParams);
    void GrayN_Pay_GetH5Deeplink(string orderId, string param);
    
    void GrayN_Pay_GetPayResult();

private:
    //接卸common数据
    bool GrayN_Pay_ParseCommonData(GrayN_JSON::Value commonJson);
    //bool ParsePropsData(const char* propsData);
    //解析计费数据，获取计费类型
    void GrayN_Pay_ParseChargeType();
    
    //解析礼包码兑换
    void GrayN_Pay_ParseExchangeGamecode();
    
    void GrayN_Pay_ParseGetH5Deeplink();
    void GrayN_Pay_ParseGetPayResult();
    //Des解密，并检查JSON数据是否异常
    bool GrayN_Pay_ParseDesData(GrayN_JSON::Value &json_object);
    bool GrayN_Pay_ParseDesDataByNewDes(GrayN_JSON::Value &json_object);
    //重置临时变量
    void GrayN_Pay_ResetData();
    //数据加密
    void GrayN_Pay_BodyEncrypt(const char* requestData);
    
private:
    GrayN_Https_GrayN* GrayN_Pay_Https;
    string GrayN_Pay_LogType;
    string GrayN_Pay_DecodeData;
    
    string GrayN_Pay_HttpBuffer;  // 接收的数据缓存
    int GrayN_Pay_HttpType;
    string GrayN_Pay_PostBody;        // 加密后的body
    GrayN_HttpErrorCode GrayN_Pay_ErrorCode;
    GrayNasyn_CallBack* GrayN_Pay_Asyn_CallBack;
    string GrayN_Pay_ErrorLogType;   //错误日志类型
    
public:
    //购买参数信息
    string m_GrayN_Pay_SSID;            //订单号
    string m_GrayN_Pay_ProductId;          // 道具id
    string m_GrayN_Pay_Price;           // 商品价格
    string m_GrayN_Pay_CurrencyType;    // 货币类型
    string m_GrayN_Pay_DeliveryUrl;      // 发货地址
    string m_GrayN_Pay_ExtendParams;      // 游戏自定义信息
    string m_GrayN_Pay_ProductName;        // 商品名称
    string m_GrayN_Pay_ProductDesc;    // 商品描述
    string m_GrayN_Pay_ProductNum;         // 商品数量
    string m_GrayN_Pay_RealProductName;   //商品数量+名称
    bool m_GrayN_Pay_IsPurchasing;   // 是否正在第三方进行购买

private:
    long long p_GrayN_Pay_StartTime;
    long long p_GrayN_Pay_EndTime;
    string p_GrayN_Pay_RequestTime;
    string p_GrayN_Pay_DecryptData;
};

GrayN_NameSpace_End


