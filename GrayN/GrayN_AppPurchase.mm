//
//  GrayN_AppPurchase.cpp
//  OPSDKSDK
//
//  Created by gamebean on 13-1-17.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <iostream>
#import "GrayN_AppPurchase.h"
#import "GrayN_Store_IAP.h"
#import "GrayNjson_cpp.h"
#import "GrayN_LoadingUI.h"
#import "GrayNasyn_CallBack.h"
#import "GrayN_AppReceipt.h"

#import "GrayNbaseSDK.h"

#import "GrayN_SynAppReceipt.h"
#import "SynAppLog_GrayN.h"

GrayNusing_NameSpace;
    
GrayN_AppPurchase::GrayN_AppPurchase()
{
    GrayN_Store_IAP::GetInstance().GrayN_Store_IAP_SetListener(this);
}

GrayN_AppPurchase::~GrayN_AppPurchase()
{
    
}

void GrayN_AppPurchase::GrayN_AppPurchaseInit()
{
    // Appstore计费非常重要
    GrayN_Store_IAP::GetInstance().GrayN_Store_IAP_Init();
}

void GrayN_AppPurchase::GrayN_AppPurchaseInitOver()
{
    [GrayNbaseSDK GrayNsetAppstoreUrl];
    // 同步本地收据
    GrayN_AppPurchase::GetInstance().GrayN_AppPurchaseSynAppReceipt();
    // 同步applog日志
    GrayN_AppPurchase::GetInstance().GrayN_AppPurchaseSynAppLog();
    /*16删除2天本地临时日志*/
    GrayN_Store_IAP::GetInstance().GrayN_Store_IAP_Remove2DaysTempData();
}

void GrayN_AppPurchase::GrayN_AppPurchaseSynAppReceipt()
{
    // 查看本地数据库
    GrayN_Store_IAP::GetInstance().GrayN_Store_IAP_SynAppReceipt();
}

void GrayN_AppPurchase::GrayN_AppPurchaseSynAppLog()
{
    // 开始同步本地applog日志
    GrayN_Store_IAP::GetInstance().GrayN_Store_IAP_CheckLocalAppLog();
    SynAppLog_GrayN::GetInstance().GrayNstart();
}

void GrayN_AppPurchase::GrayN_AppPurchaseParseChargeInfo(GrayN_JSON::Value chargeInfoJson)
{
    GrayN_JSON::Value dataJson = chargeInfoJson["data"];
    string productId = dataJson["app_product_id"].asString();
    // 当前支持的区域，比较特殊
    string fee_permission = dataJson["fee_permission"].asString();
    string fee_permission_note = dataJson["fee_permission_note"].asString();
    string fee_permission_currencycode = dataJson["fee_permission_currencycode"].asString();
    

    if (productId == "") {
        [GrayNbaseSDK GrayN_Console_Log:@"没有获得道具id！"];

        string body;
        body.append([GrayNbaseSDK GrayNgetLocalLang:GrayN_ChargeDataError]);
        body.append(GrayN_BILL_INFO_ERROR_RESET);
        GrayN_LoadingUI::GetInstance().GrayN_ShowMsgBox([GrayNbaseSDK GrayNgetLocalLang:GrayN_Title] , body.c_str(), -1, 1);
        return;
    }

    if (GrayN_Store_IAP::GetInstance().GrayN_Store_IAP_CanMakePayments()) {
        GrayN_LoadingUI::GetInstance().GrayN_ShowGameWait([GrayNbaseSDK GrayNgetLocalLang:GrayN_StoreGetProductInfo]);
        GrayN_Store_IAP::GetInstance().GrayN_Store_IAP_Buy(productId.c_str(),fee_permission.c_str(),fee_permission_currencycode.c_str(),fee_permission_note.c_str());
    } else {
        [GrayNbaseSDK GrayN_Debug_Log:@"用户不允许应用内购买！"];
        GrayN_LoadingUI::GetInstance().GrayN_ShowMsgBox([GrayNbaseSDK GrayNgetLocalLang:GrayN_Title], [GrayNbaseSDK GrayNgetLocalLang:GrayN_UserRefuseCharge], -1, 1);
    }
}

void GrayN_AppPurchase::GrayN_AppPurchaseOnIAP(bool state,GrayN_InputStream* is)
{
    [GrayNbaseSDK GrayN_Debug_Log:@"===========GrayN_AppPurchase::GrayN_AppPurchaseOnIAP========"];
    int num = is->ReadInt();
    [GrayNbaseSDK GrayN_Debug_Log:[NSString stringWithFormat:
                           @"===========GrayN_AppPurchase::The number of receipt is %d========",num]];

    bool flag = false;
    string json = "";
    for ( int i = 0; i < num; i++ ) {
        // 苹果订单号
        GrayN_CONSTANT_Utf8 appleOrderId;
        GrayN_CONSTANT_Utf8 product;
        GrayN_CONSTANT_Utf8 receipt;
        int res = is->ReadInt();
        appleOrderId.Read(*is);
        product.Read(*is);
        if ( res == 0 ) {
            flag = true;
            receipt.Read(*is);
            json.append("{\"receipt\":\"");
            string baseEncode = GrayN_Store_IAP::GetInstance().GrayN_Store_IAP_Base64Encode(receipt.Data());
            json.append(baseEncode.c_str());
            json.append("\",");
            json.append("\"appleOid\":\"");
            json.append(appleOrderId.Data());
            json.append("\"},");
        } else {
            // 越狱版
            if (res != 1) {
                [GrayNbaseSDK GrayN_Debug_Log:@"此设备为越狱设备或者没有注销设备中的Appstore账号，导致无法使用Appstore计费"];
            } else {
                [GrayNbaseSDK GrayN_Debug_Log:@"用户取消购买！"];
            }
        }
    }
    int idx = (int)json.find_last_of(",");
    if (idx >= 0) {
        json.replace(idx, 1, "");
    }
    // 只有失败的提示，成功由游戏提示
    if(flag){
        p_GrayN_AppPurchaseAppReceipt = json.c_str();
        GrayN_AppRequest_GrayN* request = GrayN_TempleQueue<GrayN_AppRequest_GrayN>::GetInstance().front_element();
        if (request) {
            // 请求完成后，自动释放对象
            GrayN_AppReceipt* object = new GrayN_AppReceipt();
            // 后台发送验证
            object->GrayN_AppReceiptSendVerify(request->m_GrayN_AppRequest_SSID.c_str(),request->m_GrayN_AppRequest_CountryCode.c_str(),request->m_GrayN_AppRequest_CurrencyCode.c_str(),p_GrayN_AppPurchaseAppReceipt.c_str());
        } else {
            GrayN_LoadingUI::GetInstance().GrayN_CloseGameWait();
        }
        GrayN_TempleQueue<GrayN_AppRequest_GrayN>::GetInstance().pop();
    } else {
        [GrayNbaseSDK GrayN_Debug_Log:@"购买失败！"];
        GrayN_LoadingUI::GetInstance().GrayN_CloseGameWait();
        GrayN_LoadingUI::GetInstance().GrayN_ShowMsgBox([GrayNbaseSDK GrayNgetLocalLang:GrayN_Title], [GrayNbaseSDK GrayNgetLocalLang:GrayN_ChargeFail], -1, 1);
    }
}

void GrayN_AppPurchase::GrayN_AppPurchaseTimeOut()
{
    [GrayNbaseSDK GrayN_Debug_Log:@"超时！！！！！！！"];
    GrayN_LoadingUI::GetInstance().GrayN_CloseGameWait();
}
