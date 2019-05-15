	//
//  GrayNpayCenter.cpp
//
//  Created by op-mac1 on 14-1-7.
//  Copyright (c) 2014年 op-mac1. All rights reserved.
//
#import "OPGameSDK.h"
#import "GrayNpayCenter.h"
#import "GrayN_Des_GrayN.h"
#import "GrayNSDK.h"
#import "GrayN_LoadingUI.h"
#import "GrayNasyn_CallBack.h"
#import "GrayN_UserCenter.h"
#import "GrayN_ErrorLog_GrayN.h"
#import "GrayN_Offical.h"
#import "GrayN_UrlEncode_GrayN.h"

GrayNusing_NameSpace;


GrayNpayCenter::GrayNpayCenter()
{
    GrayN_Pay_Https = new GrayN_Https_GrayN();

    GrayN_Pay_Https->GrayN_Http_Set_Listener(this);
    GrayN_Pay_Asyn_CallBack = new GrayNasyn_CallBack();
    m_GrayN_Pay_IsPurchasing = false;
}

GrayNpayCenter::~GrayNpayCenter()
{
    if (GrayN_Pay_Https) {
        delete GrayN_Pay_Https;
        GrayN_Pay_Https = NULL;
    }
    if (GrayN_Pay_Asyn_CallBack) {
        delete GrayN_Pay_Asyn_CallBack;
        GrayN_Pay_Asyn_CallBack = NULL;
    }
}
void GrayNpayCenter::GrayN_Pay_ConnectNetwork(int httpType, const char* url, string data)//网络连接
{
    // 请求时间
    p_GrayN_Pay_StartTime = GrayNcommon::GrayNgetCurrent_TimeStamp();
    p_GrayN_Pay_RequestTime.clear();
    p_GrayN_Pay_RequestTime = GrayNcommon::GrayNgetCurrent_DateAndTime();
    
    if (httpType == GrayN_Pay_Get_H5_Deeplink) {
        GrayN_Pay_LogType = "getH5Deeplink";
    } else if (httpType == GrayN_Pay_Get_PayResult) {
        GrayN_Pay_LogType = "getPayResult";
    } else if (httpType == GrayN_Pay_Exchange_Gamecode) {
        GrayN_Pay_LogType = "exchangeGamecode";
    } else if (httpType == GrayN_Pay_Go_Purchase) {
        GrayN_Pay_LogType = "goPurchase";
    }
    
    GrayN_Pay_HttpBuffer.clear();
    GrayN_Pay_HttpType = httpType;
    
    string httpsUrl = url;
//    GrayNcommon::GrayNstringReplace(httpsUrl, "http://", "https://");
    GrayN_Pay_Https->GrayN_Https_Post(httpsUrl, data);
    GrayNcommon::GrayN_DebugLog("GrayNpayCenterHttpType:%s\nGrayNpayCenterHttpUrls:%s\nGrayNpayCenterHttpData:", GrayN_Pay_LogType.c_str(), httpsUrl.c_str());
    GrayNcommon::GrayN_DebugLog(GrayN_Pay_DecodeData.c_str());

}
void GrayNpayCenter::GrayN_Pay_BodyEncrypt(const char* requestData)
{
    // 加密
    string desData;
    GrayN_Des_GrayN::GrayN_DesEncrypt(requestData, GrayNcommon::m_GrayN_SecretKey, desData);
    
    GrayN_Pay_PostBody.clear();
    GrayN_Pay_PostBody.append("jsonStr=");
    GrayN_Pay_PostBody.append(desData);
    GrayN_Pay_PostBody.append("&dk=");
    GrayN_Pay_PostBody.append(GrayNcommon::m_GrayN_DesKey.c_str());
}

bool GrayNpayCenter::GrayN_Pay_ParseCommonData(GrayN_JSON::Value commonJson)
{
    string status = commonJson["status"].asString();
    if (atoi(status.c_str()) == 0) {
        return true;
    } else {
        GrayN_JSON::FastWriter fast_writer;
        string tmp = fast_writer.write(commonJson);
//        GrayNcommon::GrayN_ConsoleLog(tmp.c_str());
        
        string desc = commonJson["desc"].asString();
        string reset = commonJson["reset"].asString();
        reset.append(":");
        reset.append(desc);
        GrayN_LoadingUI::GetInstance().GrayN_ShowMsgBox(GrayNcommon::GrayNcommonGetLocalLang(GrayN_Title), reset.c_str(), 0, 1);
        
        return false;
    }
}

#pragma mark- 功能
void GrayNpayCenter::GrayN_Pay_GotoPurchase(OPPurchaseParam param)
{
    GrayN_Pay_ResetData();
    //--从指针里读出参数，为了避免混淆，在这里先定义一些临时变量读出来------//
    m_GrayN_Pay_Price = param.mPrice;
    m_GrayN_Pay_CurrencyType = param.mCurrencyType;
    m_GrayN_Pay_ProductName = param.mPropName;
    m_GrayN_Pay_ProductId = param.mPropId;
    m_GrayN_Pay_DeliveryUrl = param.mDeleverUrl;
    m_GrayN_Pay_ExtendParams = param.mExtendParams;
    m_GrayN_Pay_ProductDesc = param.mPropDescribe;
    m_GrayN_Pay_ProductNum = param.mPropNum;
    if (param.mGameRoleLevel != "") {
        GrayNcommon::m_GrayN_Game_RoleLevel = param.mGameRoleLevel;
    }
    if (param.mGameRoleVipLevel != "") {
        GrayNcommon::m_GrayN_Game_RoleVipLevel = param.mGameRoleVipLevel;
    }
    
    //-----------------------------------------//
    if (GrayNcommon::m_GrayNdebug_Mode) {
        cout<<"商品价格："<<m_GrayN_Pay_Price<<endl;
        cout<<"商品ID："<<m_GrayN_Pay_ProductId<<endl;
        cout<<"商品数量："<<m_GrayN_Pay_ProductNum<<endl;
        cout<<"商品名称："<<m_GrayN_Pay_ProductName<<endl;
    }
    
    //错误日志类型
    GrayN_Pay_ErrorLogType = "charge";
    
    string url(GrayNSDK::m_GrayN_SDK_BillingUrl);
    //    string url("http://223.202.94.171:8081/billingcenter2.0");
    
    url.append("/gameClient/main.do");
    
    //common
    GrayN_JSON::Value common;
    common["interfaceId"] = GrayN_JSON::Value(GrayNsortPurchasePointInterface);
    common["tokenId"] = GrayN_JSON::Value(GrayNcommon::m_GrayN_SessionId);
    common["serviceId"] = GrayN_JSON::Value(GrayNcommon::m_GrayN_ServiceId);
    common["channelId"] = GrayN_JSON::Value(GrayNcommon::m_GrayN_ChannelId);
    common["deviceGroupId"] = GrayN_JSON::Value(GrayNcommon::m_GrayN_DeviceGroupId);
    common["localeId"] = GrayN_JSON::Value(GrayNcommon::m_GrayN_LocaleId);
    // device
    common["device"] = GrayNcommon::m_GrayN_DeviceJson;
    
    if (atoi(m_GrayN_Pay_ProductNum.c_str())!=1) {
        m_GrayN_Pay_RealProductName.append(m_GrayN_Pay_ProductNum);
    }
    m_GrayN_Pay_RealProductName.append(m_GrayN_Pay_ProductName);
    
    // options
    GrayN_JSON::Value Options;
    Options["virtualCoinUnit"] = "1";//newSDK中该参数已不需要，但是服务器要求不能传空，故直接传1
    Options["virtualCoin"] = "1";//newSDK中该参数已不需要，但是服务器要求不能传空，故直接传1
    Options["chargeCash"] = m_GrayN_Pay_Price;
    Options["currencyType"] = m_GrayN_Pay_CurrencyType;
    Options["propName"] = m_GrayN_Pay_RealProductName;
    Options["propId"] = m_GrayN_Pay_ProductId;
    Options["propCount"] = m_GrayN_Pay_ProductNum;
    Options["sdkVersion"] = GrayNcommon::m_GrayN_SDKVersion;
    Options["userId"] = GrayNcommon::m_GrayN_Game_UserId;
    Options["roleId"] = GrayNcommon::m_GrayN_Game_RoleId;
    Options["roleName"] = GrayNcommon::m_GrayN_Game_RoleName;
    Options["roleLevel"] =   GrayNcommon::m_GrayN_Game_RoleLevel;
    Options["roleVipLevel"] = GrayNcommon::m_GrayN_Game_RoleVipLevel;
    Options["gameType"] = GrayN_JSON::Value(GrayNcommon::m_GrayN_GameType);
    Options["gameServerId"] = GrayNcommon::m_GrayN_Game_ServerId;
    Options["gameClientVersion"] = GrayNcommon::m_GrayN_GameVersion;
    Options["deliverUrl"] = m_GrayN_Pay_DeliveryUrl;
    Options["extendParams"] = m_GrayN_Pay_ExtendParams;
    
    GrayN_JSON::Value root;
    root["common"] = common;
    root["options"] = Options;
    
    GrayN_JSON::FastWriter fast_writer;
    string tmp = fast_writer.write(root);
    GrayN_Pay_DecodeData = tmp;
    
    GrayN_Pay_BodyEncrypt(tmp.c_str());
    
    GrayN_LoadingUI::GetInstance().GrayN_ShowWait(GrayNcommon::GrayNcommonGetLocalLang(GrayN_WaitingString));
    GrayNpayCenter::GrayN_Pay_ConnectNetwork(GrayN_Pay_Go_Purchase, url.c_str(), GrayN_Pay_PostBody);
//    mLastParam = param;
}
//void GrayNpayCenter::RepayLastOder()
//{
//    GrayN_Pay_GotoPurchase(mLastParam);
//}

void GrayNpayCenter::GrayN_Pay_ExchangeGameCode(const char* gameCode,const char *deliverUrl,const char *extendParams)
{
    string url(GrayNSDK::m_GrayN_SDK_BillingUrl);
#ifdef DEBUG
    url = "http://113.31.91.163:8892/billingcenter2.0/gameClient/main.do";
    gameCode = "22E32K5PZ3BGUA";
#endif
    
    //common
    GrayN_JSON::Value common;
    common["interfaceId"] = GrayN_JSON::Value(GrayNexchangeGamecodeInterface);
    common["tokenId"] = GrayN_JSON::Value(GrayNcommon::m_GrayN_SessionId);
    common["serviceId"] = GrayN_JSON::Value(GrayNcommon::m_GrayN_ServiceId);
    common["channelId"] = GrayN_JSON::Value(GrayNcommon::m_GrayN_ChannelId);
    common["deviceGroupId"] = GrayN_JSON::Value(GrayNcommon::m_GrayN_DeviceGroupId);
    common["localeId"] = GrayN_JSON::Value(GrayNcommon::m_GrayN_LocaleId);
    // device
    common["device"] = GrayNcommon::m_GrayN_DeviceJson;
    
    // options
    GrayN_JSON::Value Options;
    Options["gamecode"] = gameCode;
    Options["userId"] = GrayNcommon::m_GrayN_Game_UserId;
    Options["roleId"] = GrayNcommon::m_GrayN_Game_RoleId;
    Options["roleName"] = GrayNcommon::m_GrayN_Game_RoleName;
    Options["gameServerId"] = GrayNcommon::m_GrayN_Game_ServerId;
#ifdef DEBUG
    Options["deliverUrl"] = "http://pay.gamebean.net/OurPalm_Pay_Accept/ResponseDeliver?ssid=2013030715493703719999";
#else
    Options["deliverUrl"] = deliverUrl;
#endif
    Options["extendParams"] = extendParams;
    
    //错误日志类型
    GrayN_Pay_ErrorLogType = "gamecode";
    
    GrayN_JSON::Value root;
    root["common"] = common;
    root["options"] = Options;
    
    GrayN_JSON::FastWriter fast_writer;
    string tmp = fast_writer.write(root);
    GrayN_Pay_DecodeData = tmp;

    
    GrayN_Pay_BodyEncrypt(tmp.c_str());
    
    GrayN_LoadingUI::GetInstance().GrayN_ShowWait(GrayNcommon::GrayNcommonGetLocalLang(GrayN_WaitingString));
    
    GrayNpayCenter::GrayN_Pay_ConnectNetwork(GrayN_Pay_Exchange_Gamecode, url.c_str(), GrayN_Pay_PostBody);

}

void GrayNpayCenter::GrayN_Pay_GetH5Deeplink(string orderId, string param)
{
    string url(GrayNSDK::m_GrayN_SDK_BillingDomainName);
    url.append("/palmBilling/weixinH5/getDeepLink.do");
    //common
    GrayN_JSON::Value root;
    root["orderId"] = GrayN_JSON::Value(orderId);
    string urlEncodeParam = "";
    GrayN_UrlEncode_GrayN::GrayN_Url_Encode(param, urlEncodeParam);
    root["param"] = GrayN_JSON::Value(urlEncodeParam);
//    cout<<param<<endl;
    GrayN_JSON::FastWriter fast_writer;
    string tmp = fast_writer.write(root);
    GrayN_Pay_DecodeData = tmp;
    GrayN_LoadingUI::GetInstance().GrayN_ShowWait(GrayNcommon::GrayNcommonGetLocalLang(GrayN_WaitingString));
    
    GrayNpayCenter::GrayN_Pay_ConnectNetwork(GrayN_Pay_Get_H5_Deeplink, url.c_str(), tmp);
}
void GrayNpayCenter::GrayN_Pay_GetPayResult()
{
    string url(GrayNSDK::m_GrayN_SDK_BillingDomainName);
    url.append("/webOffical/main.do");
    
    // common
    GrayN_JSON::Value common;
    common["interfaceId"] = GrayN_JSON::Value(GrayNsortPurchaseResultInterface);
    common["pCode"] = GrayN_JSON::Value(GrayNcommon::m_GrayN_P_Code);
    common["netSource"] = GrayN_JSON::Value("1");

    // options
    GrayN_JSON::Value Options;
    Options["orderId"] = m_GrayN_Pay_SSID;
    
    GrayN_JSON::Value root;
    root["common"] = common;
    root["options"] = Options;
    
    GrayN_JSON::FastWriter fast_writer;
    string tmp = fast_writer.write(root);
    GrayN_Pay_DecodeData = tmp;

//    cout<<url<<endl;
//    cout<<tmp<<endl;
    GrayN_Pay_BodyEncrypt(tmp.c_str());
    GrayN_LoadingUI::GetInstance().GrayN_ShowWait(GrayNcommon::GrayNcommonGetLocalLang(GrayN_WaitingString));

    GrayNpayCenter::GrayN_Pay_ConnectNetwork(GrayN_Pay_Get_PayResult, url.c_str(), GrayN_Pay_PostBody);
}
void GrayNpayCenter::GrayN_Pay_ParseChargeType()
{

    GrayN_LoadingUI::GetInstance().GrayN_CloseWait();

    GrayN_JSON::Value json_object;
    if (!GrayN_Pay_ParseDesData(json_object)) {
        return;
    }
    
    GrayN_JSON::Value commonJson = json_object["common"];
    if (!GrayN_Pay_ParseCommonData(commonJson)) {
        return;
    }
    
    GrayN_JSON::Value optionsJson = json_object["options"];
    if (optionsJson["orderId"].empty() || optionsJson["chargeType"].empty()) {
        GrayN_ErrorLog_GrayN *errorLog = new GrayN_ErrorLog_GrayN();
        errorLog->GrayN_ErrorLog_SendLog(GrayN_Pay_ErrorLogType.c_str(), p_GrayN_Pay_RequestTime.c_str(), GrayN_CHARGE_JSON_LOGERROR,
                                 GrayN_Pay_Https->GrayN_Http_Get_SocketError(),GrayN_Pay_Https->GrayN_Http_Get_HttpCode(), GrayN_Pay_HttpBuffer.c_str());
        

            GrayN_JSON::Value errJson;
            errJson["status"] = GrayN_JSON::Value("1");
            errJson["reset"] = GrayN_JSON::Value(GrayN_Charge_NETDATA_ERROR);
            errJson["desc"] = GrayN_JSON::Value(GrayN_Charge_NETDATA_ERRORDESC);
            errJson["ssId"] = GrayN_JSON::Value("");
            GrayN_JSON::FastWriter fast_writer;
            string resultStr = fast_writer.write(errJson);
            GrayNSDK::GrayN_SDK_OnPurchaseResult(false, resultStr.c_str());
        return;
    }
    
    m_GrayN_Pay_SSID = optionsJson["orderId"].asString();
    GrayNcommon::m_GrayN_Game_PayCallback_Url = optionsJson["data"]["callback_url"].asString();
    GrayNcommon::GrayN_ConsoleLog("opSSID=%s", m_GrayN_Pay_SSID.c_str());
    
    int chargeType = atoi(optionsJson["chargeType"].asString().c_str());
#ifdef OPCharge_Test
    chargeType = 0;
#endif
    //chargeType 0:官网，1：联运
    GrayNchannel::GetInstance().GrayN_ChannelParseChargeInfo(chargeType, optionsJson);
}

void GrayNpayCenter::GrayN_Pay_ParseExchangeGamecode()
{
    GrayN_LoadingUI::GetInstance().GrayN_CloseWait();
    
    GrayN_JSON::Value json_object;
    if (!GrayN_Pay_ParseDesData(json_object)) {
        return;
    }
    
    GrayN_JSON::Value commonJson = json_object["common"];
    if (!GrayN_Pay_ParseCommonData(commonJson)) {
        return;
    }
    
        GrayN_JSON::Value errJson;
        errJson["status"] = GrayN_JSON::Value("1");
        errJson["reset"] = GrayN_JSON::Value(GrayN_GameCode_SUCCESS_ERROR);
        errJson["desc"] = GrayN_JSON::Value(GrayN_GameCode_SUCCESS_ERRORDESC);
        GrayN_JSON::FastWriter fast_writer;
        string resultStr = fast_writer.write(errJson);
    
        GrayNSDK::GrayN_SDK_OnExchangeGamecodeResult(true, resultStr.c_str());
}
void GrayNpayCenter::GrayN_Pay_ParseGetH5Deeplink()
{
    GrayN_LoadingUI::GetInstance().GrayN_CloseWait();
    
    GrayN_JSON::Value json_object;
    if (!GrayN_Pay_ParseDesDataByNewDes(json_object)) {
        GrayN_Offical::GetInstance().GrayN_Offical_ShowToast("json解析错误", false);
        return;
    }
    
    string deepLink = json_object["deepLink"].asString();
    if (deepLink != "") {
        //
        GrayN_Offical::GetInstance().GrayN_Offical_DeeplinkResponse(deepLink);
    } else {
        GrayN_Offical::GetInstance().GrayN_Offical_ShowToast("deeplink为空", false);
    }
}
void GrayNpayCenter::GrayN_Pay_ParseGetPayResult()
{
    GrayN_LoadingUI::GetInstance().GrayN_CloseWait();
    
    GrayN_JSON::Value json_object;
    if (!GrayN_Pay_ParseDesData(json_object)) {
        GrayN_Offical::GetInstance().GrayN_Offical_ShowToast("json解析错误", false);
        return;
    }
    GrayN_JSON::Value commonJson = json_object["common"];
    if (!GrayN_Pay_ParseCommonData(commonJson)) {
        return;
    }
    GrayN_JSON::Value options = json_object["options"];
    string payCode = options["payCode"].asString();
    
    GrayN_JSON::Value errJson;
    errJson["ssId"] = GrayN_JSON::Value(m_GrayN_Pay_SSID);
    errJson["propId"] = GrayN_JSON::Value(m_GrayN_Pay_ProductId);

    GrayN_JSON::FastWriter fast_writer;
    string resultStr = "";
    
    if (atoi(payCode.c_str())) {
        errJson["reset"] = "200";
        errJson["desc"] = GrayN_Charge_SUCCESS_ERRORDESC;
        resultStr = fast_writer.write(errJson);
        GrayNSDK::GrayN_SDK_OnPurchaseResult(true, resultStr.c_str());
    } else {
        errJson["reset"] = "201";
        errJson["desc"] = GrayN_Charge_FAILED_ERRORDESC;
        resultStr = fast_writer.write(errJson);
        GrayNSDK::GrayN_SDK_OnPurchaseResult(false, resultStr.c_str());
    }
    m_GrayN_Pay_IsPurchasing = false;
}
bool GrayNpayCenter::GrayN_Pay_ParseDesData(GrayN_JSON::Value &json_object)
{
    //解密
    string tmpBuf(GrayN_Pay_HttpBuffer.c_str());
//    cout<<GrayN_Pay_HttpBuffer<<endl;
    string buf;
    GrayN_Des_GrayN::GrayN_DesDecrypt(tmpBuf, GrayNcommon::m_GrayN_SecretKey, buf);
    GrayNcommon::GrayN_DebugLog("GrayNpayCenter GrayN_Pay_ParseDesData");
    GrayNcommon::GrayN_DebugLog(buf.c_str());

    GrayN_JSON::Reader    json_reader;
    if (!json_reader.parse(buf, json_object)){
        GrayNcommon::GrayN_ConsoleLog("数据异常，无法解析！");
        GrayNcommon::GrayN_ConsoleLog(buf.c_str());
#ifdef DEBUG
        GrayNcommon::GrayN_ConsoleLog(GrayN_Pay_HttpBuffer.c_str());
#endif
        
        GrayN_ErrorLog_GrayN *errorLog = new GrayN_ErrorLog_GrayN();
        errorLog->GrayN_ErrorLog_SendLog(GrayN_Pay_ErrorLogType.c_str(), p_GrayN_Pay_RequestTime.c_str(), GrayN_CHARGE_DES_LOGERROR,
                                 GrayN_Pay_Https->GrayN_Http_Get_SocketError(), GrayN_Pay_Https->GrayN_Http_Get_HttpCode(), GrayN_Pay_HttpBuffer.c_str());
        

            int reset=0;
            string desc;
            GrayN_JSON::Value errJson;
            errJson["status"] = GrayN_JSON::Value("1");
            if (GrayN_Pay_HttpType == GrayN_Pay_Go_Purchase) {
                reset = GrayN_Charge_NETDATA_ERROR;              //数据异常，下单失败
                desc = GrayN_Charge_NETDATA_ERRORDESC;
                errJson["ssId"] = GrayN_JSON::Value("");
            }else if (GrayN_Pay_HttpType == GrayN_Pay_Exchange_Gamecode){
                reset = GrayN_GameCode_NETDATA_ERROR;    //数据异常，礼包码兑换失败
                desc = GrayN_GameCode_NETDATA_ERRORDESC;
            } else if (GrayN_Pay_HttpType == GrayN_Pay_Get_H5_Deeplink) {
                reset = GrayN_GameCode_NETDATA_ERROR;    //deeplink
                desc = GrayN_GameCode_NETDATA_ERRORDESC;
            }
            errJson["reset"] = GrayN_JSON::Value(reset);
            errJson["desc"] = GrayN_JSON::Value(desc);
            GrayN_JSON::FastWriter fast_writer;
            string resultStr = fast_writer.write(errJson);
            if (GrayN_Pay_HttpType == GrayN_Pay_Go_Purchase) {
                GrayNSDK::GrayN_SDK_OnPurchaseResult(false, resultStr.c_str());
            }else if (GrayN_Pay_HttpType == GrayN_Pay_Exchange_Gamecode){
                GrayNSDK::GrayN_SDK_OnExchangeGamecodeResult(false, resultStr.c_str());
            }
        return false;//json格式解析错误
    }
    
    p_GrayN_Pay_DecryptData.clear();
    p_GrayN_Pay_DecryptData = tmpBuf;
    
    return true;
}
bool GrayNpayCenter::GrayN_Pay_ParseDesDataByNewDes(GrayN_JSON::Value &json_object)
{
    //解密
    string decodeStr = "";
    GrayN_Des_GrayN::GrayN_DesDecrypt(GrayN_Pay_HttpBuffer, decodeStr);
    
    GrayN_JSON::Reader    json_reader;
    if (!json_reader.parse(decodeStr, json_object)){
        GrayNcommon::GrayN_ConsoleLog("数据异常，无法解析！");
        GrayNcommon::GrayN_ConsoleLog(decodeStr.c_str());
#ifdef DEBUG
        GrayNcommon::GrayN_ConsoleLog(GrayN_Pay_HttpBuffer.c_str());
#endif
        
        GrayN_ErrorLog_GrayN *errorLog = new GrayN_ErrorLog_GrayN();
        errorLog->GrayN_ErrorLog_SendLog(GrayN_Pay_ErrorLogType.c_str(), p_GrayN_Pay_RequestTime.c_str(), GrayN_CHARGE_DES_LOGERROR,
                                 GrayN_Pay_Https->GrayN_Http_Get_SocketError(), GrayN_Pay_Https->GrayN_Http_Get_HttpCode(), GrayN_Pay_HttpBuffer.c_str());
 
            int reset=0;
            string desc;
            GrayN_JSON::Value errJson;
            errJson["status"] = GrayN_JSON::Value("1");
            if (GrayN_Pay_HttpType == GrayN_Pay_Go_Purchase) {
                reset = GrayN_Charge_NETDATA_ERROR;              //数据异常，下单失败
                desc = GrayN_Charge_NETDATA_ERRORDESC;
                errJson["ssId"] = GrayN_JSON::Value("");
            }else if (GrayN_Pay_HttpType == GrayN_Pay_Exchange_Gamecode){
                reset = GrayN_GameCode_NETDATA_ERROR;    //数据异常，礼包码兑换失败
                desc = GrayN_GameCode_NETDATA_ERRORDESC;
            } else if (GrayN_Pay_HttpType == GrayN_Pay_Get_H5_Deeplink) {
                reset = GrayN_GameCode_NETDATA_ERROR;    //deeplink
                desc = GrayN_GameCode_NETDATA_ERRORDESC;
            }
            errJson["reset"] = GrayN_JSON::Value(reset);
            errJson["desc"] = GrayN_JSON::Value(desc);
            GrayN_JSON::FastWriter fast_writer;
            string resultStr = fast_writer.write(errJson);
            if (GrayN_Pay_HttpType == GrayN_Pay_Go_Purchase) {
                GrayNSDK::GrayN_SDK_OnPurchaseResult(false, resultStr.c_str());
            } else if (GrayN_Pay_HttpType == GrayN_Pay_Exchange_Gamecode){
                GrayNSDK::GrayN_SDK_OnExchangeGamecodeResult(false, resultStr.c_str());
            }
        return false;//json格式解析错误
    }
    
    p_GrayN_Pay_DecryptData.clear();
    p_GrayN_Pay_DecryptData = decodeStr;
    
    return true;
}

void GrayNpayCenter::GrayN_Pay_ProcessHttpError(void* args)
{
    GrayNpayCenter::GetInstance().GrayN_Pay_ParseHttpError(args);
}

void GrayNpayCenter::GrayN_Pay_ParseHttpError(void* args)
{
    bool ifTimeOut = false;
    p_GrayN_Pay_EndTime = GrayNcommon::GrayNgetCurrent_TimeStamp();
    if (p_GrayN_Pay_EndTime-p_GrayN_Pay_StartTime > 40000) {      //40s
        ifTimeOut = true;
    }
    
    GrayN_LoadingUI::GetInstance().GrayN_CloseWait();
    
    //加入错误发送日志
    string tmp;
    if (GrayN_Pay_ErrorCode == k_GrayN_OPEN_ERROR) {
        tmp = "OPEN_ERROR";
    }else if (GrayN_Pay_ErrorCode == k_GrayN_SEND_HEAD_ERROR){
        tmp = "SEND_HEAD_ERROR";
    }else if (GrayN_Pay_ErrorCode == k_GrayN_SEND_POST_ERROR){
        tmp = "SEND_POST_ERROR";
    }else if (GrayN_Pay_ErrorCode == k_GrayN_RECV_HEAD_ERROR){
        tmp = "RECV_HEAD_ERROR";
    }else if (GrayN_Pay_ErrorCode == k_GrayN_RECV_DATA_ERROR){
        tmp = "RECV_DATA_ERROR";
    }else if (GrayN_Pay_ErrorCode == k_GrayN_DISCONNECTED_ERROR){
        tmp = "DISCONNECTED_ERROR";
    }
    GrayN_ErrorLog_GrayN *errorLog = new GrayN_ErrorLog_GrayN();
    errorLog->GrayN_ErrorLog_SendLog(GrayN_Pay_ErrorLogType.c_str(), p_GrayN_Pay_RequestTime.c_str(), tmp.c_str(),
                             GrayN_Pay_Https->GrayN_Http_Get_SocketError(), GrayN_Pay_Https->GrayN_Http_Get_HttpCode(), GrayN_Pay_HttpBuffer.c_str());
    

        GrayN_JSON::Value errJson;
        errJson["status"] = GrayN_JSON::Value("1");
        int reset =0;
        string desc;
        if (GrayN_Pay_HttpType == GrayN_Pay_Go_Purchase) {
            if (ifTimeOut) {
                reset = GrayN_Charge_TIMEOUT_ERROR;
                desc = GrayN_Charge_TIMEOUT_ERRORDESC;
            }else{
                reset = GrayN_Charge_NETWORK_ERROR;
                desc = GrayN_Charge_NETWORK_ERRORDESC;
            }
            errJson["reset"] = GrayN_JSON::Value(reset);
            errJson["desc"] = GrayN_JSON::Value(desc);
            errJson["ssId"] = GrayN_JSON::Value("");
            GrayN_JSON::FastWriter fast_writer;
            string resultStr = fast_writer.write(errJson);
            GrayNSDK::GrayN_SDK_OnPurchaseResult(false, resultStr.c_str());
        }else if (GrayN_Pay_HttpType == GrayN_Pay_Exchange_Gamecode){
            if (ifTimeOut) {
                reset = GrayN_GameCode_TIMEOUT_ERROR;
                desc = GrayN_GameCode_TIMEOUT_ERRORDESC;
            }else{
                reset = GrayN_GameCode_NETWORK_ERROR;
                desc = GrayN_GameCode_NETWORK_ERRORDESC;
            }
            errJson["reset"] = GrayN_JSON::Value(reset);
            errJson["desc"] = GrayN_JSON::Value(desc);
            GrayN_JSON::FastWriter fast_writer;
            string resultStr = fast_writer.write(errJson);
            GrayNSDK::GrayN_SDK_OnExchangeGamecodeResult(false, resultStr.c_str());
        }
}

void GrayNpayCenter::GrayN_On_HttpError(GrayN_Http_GrayN* client, GrayN_HttpErrorCode code)
{
#ifdef HTTPDEBUG
    GrayNcommon::GrayN_DebugLog("on http error code=%d", code);
#endif
    GrayN_Pay_ErrorCode = code;
    GrayN_Pay_Asyn_CallBack->GrayNstartAsyn_CallBack(GrayNpayCenter::GrayN_Pay_ProcessHttpError, &code);

}

void GrayNpayCenter::GrayN_Pay_ProcessParseHttpData(void* args)
{
    GrayNpayCenter::GetInstance().GrayN_Pay_ParseHttpData((GrayN_Http_GrayN*)args);
}

void GrayNpayCenter::GrayN_Pay_ParseHttpData(GrayN_Http_GrayN* client)
{
    switch (GrayN_Pay_HttpType) {
        case GrayN_Pay_Get_ProductList:
            break;
            
        case GrayN_Pay_Go_Purchase:
            GrayN_Pay_ParseChargeType();
            break;
            
        case GrayN_Pay_Exchange_Gamecode:
            GrayN_Pay_ParseExchangeGamecode();
            break;
        case GrayN_Pay_Get_H5_Deeplink:
            GrayN_Pay_ParseGetH5Deeplink();
            break;
        case GrayN_Pay_Get_PayResult:
            GrayN_Pay_ParseGetPayResult();
            break;
        default:
            break;
    }
}


void GrayNpayCenter::GrayN_On_HttpEvent(GrayN_Http_GrayN* client, GrayN_HttpEventCode code)
{
#ifdef HTTPDEBUG
    GrayNcommon::GrayN_DebugLog("on http event code = %d", code);
#endif
    if(code == k_GrayN_SEND_HEAD){
        GrayN_Pay_HttpBuffer.clear();
    }else if(code == k_GrayN_COMPLETE)
    {
        GrayN_Pay_Asyn_CallBack->GrayNstartAsyn_CallBack(GrayNpayCenter::GrayN_Pay_ProcessParseHttpData, client);

    }
}

void GrayNpayCenter::GrayN_On_HttpResponse(GrayN_Http_GrayN* client,int code,int context_length,int startPos,int endPos,int totalContext,const char* data)
{
    
}

void GrayNpayCenter::GrayN_On_Http_Data(GrayN_Http_GrayN* client,const char* data,int count)
{
#ifdef HTTPDEBUG
    GrayNcommon::GrayN_DebugLog("on http length=%d data=%s",count,data);
#endif
    GrayN_Pay_HttpBuffer.append(data,count);
}

void GrayNpayCenter::GrayN_Pay_ResetData()
{
    m_GrayN_Pay_Price.clear();
    m_GrayN_Pay_CurrencyType.clear();
    m_GrayN_Pay_ProductId.clear();
    m_GrayN_Pay_DeliveryUrl.clear();
    m_GrayN_Pay_ExtendParams.clear();
    m_GrayN_Pay_ProductName.clear();
    m_GrayN_Pay_ProductDesc.clear();
    m_GrayN_Pay_SSID.clear();
    m_GrayN_Pay_ProductNum.clear();
    m_GrayN_Pay_RealProductName.clear();
}
