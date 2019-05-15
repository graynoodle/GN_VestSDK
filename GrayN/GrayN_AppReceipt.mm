//
//  GrayN_AppReceipt.cpp
//  OurpalmSDK
//
//  Created by op-mac1 on 13-12-12.
//
//

#import "GrayN_AppReceipt.h"

#import "GrayN_Store_IAP.h"
#import "GrayNjson_cpp.h"
#import "GrayN_SynAppReceipt.h"

#import "GrayN_Store_IAP.h"
#import "GrayNconfig.h"
#import "GrayNbaseSDK.h"
#import "GrayN_LoadingUI.h"
#import "GrayNchannelSDK.h"

#import "GrayN_Offical.h"

//#define APPRECEIPT
#define APPRECEIPT_MD5    //2015-11-2  加入sign加密功能

GrayNusing_NameSpace;
    
GrayN_AppReceipt::GrayN_AppReceipt()
{
    p_GrayN_AppReceiptIsStop = true;
    p_GrayN_AppReceiptHttps = NULL;
    p_GrayN_AppReceiptRequestStatus = 0;          //注意初始值
    p_GrayN_AppReceiptRequestCount = 1;
    p_GrayN_AppReceiptObject = NULL;
    p_GrayN_AppReceiptAsyn_CallBack = new GrayNasyn_CallBack();
    m_GrayN_AppReceiptIsShowAlert = true;
}

GrayN_AppReceipt::~GrayN_AppReceipt()
{
    if (p_GrayN_AppReceiptHttps != NULL) {
        delete p_GrayN_AppReceiptHttps;
        p_GrayN_AppReceiptHttps = NULL;
    }
    if (p_GrayN_AppReceiptAsyn_CallBack) {
        delete p_GrayN_AppReceiptAsyn_CallBack;
        p_GrayN_AppReceiptAsyn_CallBack = NULL;
    }
}

void GrayN_AppReceipt::GrayN_AppReceiptSendVerify(const char* tmpSSID,const char* tmpCountryCode,const char* receipt)
{
    this->GrayN_AppReceiptSendVerify(tmpSSID, tmpCountryCode, "",receipt);
}

void GrayN_AppReceipt::GrayN_AppReceiptSendVerify(const char* tmpSSID,const char* tmpCountryCode,const char* tmpCurrencyCode,const char* receipt)
{
    p_GrayN_AppReceiptSSID = tmpSSID;
    p_GrayN_AppReceiptCountryCode = tmpCountryCode;
    p_GrayN_AppReceiptCurrencyCode = tmpCurrencyCode;
    p_GrayN_AppReceipt = receipt;
    p_GrayN_AppReceiptObject = this;
    p_GrayN_AppReceiptVerifyStatus = false;
    if (p_GrayN_AppReceiptHttps == NULL) {
        //开启线程
        p_GrayN_AppReceiptHttps = new GrayN_Https_GrayN();

        p_GrayN_AppReceiptHttps->GrayN_Http_Set_Listener(this);
    }
    if (p_GrayN_AppReceiptIsStop) {
#ifdef APPRECEIPT
        XCLOG("开启线程AppReceipt::GrayN_AppReceiptSendVerify！");
#endif
        p_GrayN_AppReceiptIsStop = false;
        this->GrayNstart();
        // 注意这里，只能调用一次！否则每次发送都会起一个线程！！！！！！！
    }
}

void GrayN_AppReceipt::GrayN_AppReceiptStopVerify()
{
    p_GrayN_AppReceiptIsStop = true;
    if (p_GrayN_AppReceiptHttps != NULL) {
        p_GrayN_AppReceiptHttps->GrayNstop();       //关闭线程
        delete p_GrayN_AppReceiptHttps;
        p_GrayN_AppReceiptHttps = NULL;
    }
}

void GrayN_AppReceipt::GrayNrun(void* p)
{
    if (p_GrayN_AppReceiptVerifyStatus) {
        //销毁对象
        GrayN_Sleep(2);
        if (p_GrayN_AppReceiptObject != NULL) {
            delete p_GrayN_AppReceiptObject;
            p_GrayN_AppReceiptObject = NULL;
        }
        return;
    }
    //验证
    string verUrl([GrayNbaseSDK GrayNgetAppstoreVerifyUrl]);
    //verUrl = "http://192.168.92.23:8080/billingcenter2.0/palmBilling/appStorePay/query.do?";
    
    string data("orderId=");
    data.append(p_GrayN_AppReceiptSSID);
    data.append("&appFeeVersion=");     //验证接口版本号
#ifdef APPRECEIPT_MD5
    data.append("4");
#else
    data.append("3");
#endif
    data.append("&countryCode=");
    data.append(p_GrayN_AppReceiptCountryCode);
    data.append("&currencyCode=");
    data.append(p_GrayN_AppReceiptCurrencyCode);
    data.append("&resend=0");           //实时订单
    data.append("&appParam=");
    data.append(p_GrayN_AppReceipt);
    
    [GrayNbaseSDK GrayN_Debug_Log:@"APPRECEIPT data========,%@",BeNSString(data.c_str())];
    
    //
#ifdef APPRECEIPT_MD5
    string sign;
    sign.append("4");       //appFeeVersion
    sign.append(p_GrayN_AppReceipt);//appParam
    sign.append(p_GrayN_AppReceiptCountryCode);
    sign.append(p_GrayN_AppReceiptCurrencyCode);
    sign.append(p_GrayN_AppReceiptSSID);
    sign.append("0");       //resend
    sign.append("obctabsayo34rty56c");  //key
    string md5Encode = GrayN_Store_IAP::GetInstance().GrayN_Store_IAP_MD5Encode(sign.c_str());
    data.append("&sign=");
    data.append(md5Encode);
//    cout<<verUrl<<endl;
//    cout<<md5Encode<<endl;
    [GrayNbaseSDK GrayN_Debug_Log:@"APPRECEIPT md5Encode========%@",BeNSString(md5Encode.c_str())];
#endif
    
    GrayN_LoadingUI::GetInstance().GrayN_ChangeWait([GrayNbaseSDK GrayNgetLocalLang:GrayN_StoreVerify]);
    
    p_GrayN_AppReceiptHttps->GrayN_Https_Post(verUrl, data);

}

void GrayN_AppReceipt::GrayN_On_HttpError(GrayN_Http_GrayN* client, GrayN_HttpErrorCode code)
{
    if (p_GrayN_AppReceiptRequestCount > 3) {
#ifdef APPRECEIPT
        XCLOG("订单号%s验证失败！",p_GrayN_AppReceiptSSID.c_str());
#endif
        p_GrayN_AppReceiptRequestStatus++;
        if (p_GrayN_AppReceiptRequestStatus <= 3){
            sleep(2);
        }else{
            if (m_GrayN_AppReceiptIsShowAlert) {
                GrayN_AppReceiptMsg *msg = new GrayN_AppReceiptMsg();
                msg->m_GrayN_AppReceiptSSID = p_GrayN_AppReceiptSSID;
                msg->m_GrayN_AppReceiptResult = false;
                msg->m_GrayN_AppReceiptResultDesc = [GrayNbaseSDK GrayNgetLocalLang:GrayN_ChargeFail];
                p_GrayN_AppReceiptAsyn_CallBack->GrayNstartAsyn_CallBack(GrayN_AppReceipt::GrayN_AppReceiptNotifyResult, msg);
            }
            //不要忘记销毁对象
            p_GrayN_AppReceiptVerifyStatus = true;
            GrayNstart();
            return;
        }
        GrayNstart();
    }else{
        if (p_GrayN_AppReceiptRequestStatus != 0) {       //第一次请求，试3次，后续都为1次
            GrayNstart();
            return;
        }
        p_GrayN_AppReceiptRequestCount++;
        GrayNstart();
    }
}
void GrayN_AppReceipt::GrayN_On_HttpEvent(GrayN_Http_GrayN* client, GrayN_HttpEventCode code)
{
    if(code == k_GrayN_SEND_HEAD) {
        p_GrayN_AppReceiptHttpsBuffer.clear();
    } else if(code == k_GrayN_COMPLETE) {
        //client->GrayNstop();       //易犯的错误，请慎重使用
        GrayN_AppReceiptVerifyResult(p_GrayN_AppReceiptHttpsBuffer.c_str());
        
        //不要忘记销毁对象
        p_GrayN_AppReceiptVerifyStatus = true;
        GrayNstart();
    }
}
void GrayN_AppReceipt::GrayN_On_HttpResponse(GrayN_Http_GrayN* client,int code,int context_length,int startPos,int endPos,int totalContext,const char* data)
{
    
}
void GrayN_AppReceipt::GrayN_On_Http_Data(GrayN_Http_GrayN* client,const char* data,int count)
{
    p_GrayN_AppReceiptHttpsBuffer.append(data,count);
}

void GrayN_AppReceipt::GrayN_AppReceiptVerifyResult(const char* data)
{
#ifdef APPRECEIPT
    XCLOG("GrayN_AppReceipt Response：%s",data);
#endif
    GrayN_JSON::Value json_object;
    GrayN_JSON::Reader    json_reader;
    string info = "订单：";
    info.append(p_GrayN_AppReceiptSSID);
    if (!json_reader.parse(data, json_object)){
        info.append(",fail");
       
        [GrayNbaseSDK GrayN_Debug_Log:BeNSString(info.c_str())];
        if (m_GrayN_AppReceiptIsShowAlert) {
            GrayN_AppReceiptMsg *msg = new GrayN_AppReceiptMsg();
            msg->m_GrayN_AppReceiptSSID = p_GrayN_AppReceiptSSID;
            msg->m_GrayN_AppReceiptResult = false;
            msg->m_GrayN_AppReceiptResultDesc = [GrayNbaseSDK GrayNgetLocalLang:GrayN_ChargeFail];
            p_GrayN_AppReceiptAsyn_CallBack->GrayNstartAsyn_CallBack(GrayN_AppReceipt::GrayN_AppReceiptNotifyResult, msg);
        }
        //this->GrayN_AppReceiptNotifyResult(false,[GrayNbaseSDK GrayNgetLocalLang:](GrayN_ChargeFail));
        return;
    }
    
    string result = json_object["result"].asString();
    string resultDesc = json_object["resultDesc"].asString();
    [GrayNbaseSDK GrayN_Debug_Log:BeNSString(data)];
    if (strcmp(result.c_str(), "success") == 0) {
        // 删除订单
        GrayN_Store_IAP::GetInstance().GrayN_Store_IAP_RemoveData(p_GrayN_AppReceiptSSID);
        info.append(",success");
        [GrayNbaseSDK GrayN_Debug_Log:BeNSString(info.c_str())];
        if (m_GrayN_AppReceiptIsShowAlert) {
            GrayN_AppReceiptMsg *msg = new GrayN_AppReceiptMsg();
            msg->m_GrayN_AppReceiptSSID = p_GrayN_AppReceiptSSID;
            msg->m_GrayN_AppReceiptResult = true;
            msg->m_GrayN_AppReceiptResultDesc = resultDesc;
            p_GrayN_AppReceiptAsyn_CallBack->GrayNstartAsyn_CallBack(GrayN_AppReceipt::GrayN_AppReceiptNotifyResult, msg);
        }
        //this->GrayN_AppReceiptNotifyResult(true,resultDesc.c_str());
    }else{
        info.append(",fail");
        [GrayNbaseSDK GrayN_Debug_Log:BeNSString(info.c_str())];
        if (m_GrayN_AppReceiptIsShowAlert) {
            GrayN_AppReceiptMsg *msg = new GrayN_AppReceiptMsg();
            msg->m_GrayN_AppReceiptSSID = p_GrayN_AppReceiptSSID;
            msg->m_GrayN_AppReceiptResult = false;
            msg->m_GrayN_AppReceiptResultDesc = resultDesc;
            p_GrayN_AppReceiptAsyn_CallBack->GrayNstartAsyn_CallBack(GrayN_AppReceipt::GrayN_AppReceiptNotifyResult, msg);
        }
        //this->GrayN_AppReceiptNotifyResult(false,resultDesc.c_str());
    }
}

void GrayN_AppReceipt::GrayN_AppReceiptNotifyResult(void* args)
{
    GrayN_LoadingUI::GetInstance().GrayN_CloseGameWait();
    
    GrayN_AppReceiptMsg *msg = (GrayN_AppReceiptMsg*)args;
    if (msg == NULL) {
        GrayN_LoadingUI::GetInstance().GrayN_ShowMsgBox([GrayNbaseSDK GrayNgetLocalLang:GrayN_Title], "通知返回为空!", 0, 1);
        GrayN_Store_IAP::GetInstance().GrayN_Store_IAP_PayResult(false, GrayN_Charge_FAILED_ERROR);

        return;
    }
    bool result = msg->m_GrayN_AppReceiptResult;
    string resultDesc = msg->m_GrayN_AppReceiptResultDesc;
    string p_GrayN_AppReceiptSSID = msg->m_GrayN_AppReceiptSSID;
    if (msg) {
        delete msg;
        msg = NULL;
    }
    
    GrayN_Offical::GetInstance().GrayN_Offical_ShowToast(resultDesc, YES);
//    GrayN_LoadingUI::GetInstance().GrayN_ShowMsgBox([GrayNbaseSDK GrayNgetLocalLang:GrayN_Title], resultDesc.c_str(), 0, 1);
    
    int errorCode = GrayN_Charge_SUCCESS_ERROR;
    if (!result) {
        errorCode = GrayN_Charge_FAILED_ERROR;
    }
    GrayN_Store_IAP::GetInstance().GrayN_Store_IAP_PayResult(result, errorCode);
}
