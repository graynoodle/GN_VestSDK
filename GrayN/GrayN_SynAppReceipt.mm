//
//  GrayN_SynAppReceipt.cpp
//  OurpalmSDK
//
//  Created by op-mac1 on 13-11-22.
//


#import "GrayNjson_cpp.h"

#import "GrayN_SynAppReceipt.h"
#import "GrayN_Store_IAP.h"
#import "GrayNbaseSDK.h"
#import "GrayN_GTMBase64.h"
#import "GrayNchannelSDK.h"

//#define SynAppReceiptDEBUG
#define APPRECEIPT_MD5

GrayNusing_NameSpace;
string GrayN_SynAppReceipt::m_GrayN_StoreKey;
#ifdef CHECKORDER
static NSDate *p_GrayN_SystemDate;
#endif
GrayN_SynAppReceipt::GrayN_SynAppReceipt()
{
    GrayN_SynAppReceiptStoreKey();
    p_GrayN_SynAppReceiptHttps = new GrayN_Https_GrayN();

    p_GrayN_SynAppReceiptHttps->GrayN_Http_Set_Listener(this);
    p_GrayN_SynAppReceiptIsStop = false;
    p_GrayN_SynAppReceiptRequestStatus = 1;
    p_GrayN_SynAppReceiptLocalQueue = new GrayN_TempleQueue<GrayN_AppVerifyRequest>();;
    p_GrayN_SynAppReceiptRequestQueue = new GrayN_TempleQueue<GrayN_AppVerifyRequest>();;
}

GrayN_SynAppReceipt::~GrayN_SynAppReceipt()
{
    if (p_GrayN_SynAppReceiptHttps != NULL) {
        delete p_GrayN_SynAppReceiptHttps;
        p_GrayN_SynAppReceiptHttps = NULL;
    }
    if (p_GrayN_SynAppReceiptLocalQueue != NULL) {
        delete p_GrayN_SynAppReceiptLocalQueue;
        p_GrayN_SynAppReceiptLocalQueue = NULL;
    }
    if (p_GrayN_SynAppReceiptRequestQueue != NULL) {
        delete p_GrayN_SynAppReceiptRequestQueue;
        p_GrayN_SynAppReceiptRequestQueue = NULL;
    }
}

void GrayN_SynAppReceipt::GrayN_SynAppReceiptSendVerify()
{
    
    p_GrayN_SynAppReceiptIsStop = false;
    p_GrayN_SynAppReceiptIsLocalVerify = true;
    this->GrayNstart();
}

void GrayN_SynAppReceipt::GrayN_SynAppReceiptStopVerify()
{
    //终止验证
    p_GrayN_SynAppReceiptIsStop = true;
    p_GrayN_SynAppReceiptHttps->GrayNstop();       //关闭线程
}

void GrayN_SynAppReceipt::GrayN_SynAppReceiptVerifyResult(const char* data)
{
//    cout<<data<<endl;
    string logId = p_GrayN_SynAppReceiptRequest->GrayN_AppVerifyRequest_LogId;
    string info = "同步订单：";
    info.append(logId);
    GrayN_JSON::Value json_object;
    GrayN_JSON::Reader    json_reader;
    if (!json_reader.parse(data, json_object)){
        info.append("fail error");
        [GrayNbaseSDK GrayN_Debug_Log:BeNSString(info.c_str())];
        return;
    }
    
    string result = json_object["result"].asString();
    [GrayNbaseSDK GrayN_Debug_Log:BeNSString(data)];
    if (strcmp(result.c_str(), "success") == 0) {
        info.append(",success");
        [GrayNbaseSDK GrayN_Debug_Log:BeNSString(info.c_str())];
        //删除订单
        GrayN_Store_IAP::GetInstance().GrayN_Store_IAP_RemoveData(logId);
    }else{
        info.append(",fail");
        [GrayNbaseSDK GrayN_Debug_Log:BeNSString(info.c_str())];
    }
}

void GrayN_SynAppReceipt::GrayNrun(void* p)
{
    [GrayNbaseSDK GrayN_Debug_Log:@"GrayN_SynAppReceipt is ready!"];
    while (!p_GrayN_SynAppReceiptIsStop) {
        if (p_GrayN_SynAppReceiptIsLocalVerify) {
            p_GrayN_SynAppReceiptRequest = p_GrayN_SynAppReceiptLocalQueue->front_element();
            if (p_GrayN_SynAppReceiptRequest == NULL) {           //本地同步完成时，不要删除loacalQueue，否则会奔溃！！！！
                //new  直接停止
                [GrayNbaseSDK GrayN_Debug_Log:@"==========GrayN_SynAppReceipt::loacalQueue同步订单完成！=============="];
                return;
                
                p_GrayN_SynAppReceiptIsLocalVerify = false;

                GrayN_Store_IAP::GetInstance().GrayN_Store_IAP_SynAppReceiptOver();
                
                //注意下面的处理
                if (p_GrayN_SynAppReceiptRequestQueue->empty()) {
                    sleep(120);     //2min
                }else{
                    sleep(5);
                }
                continue;
            }
            GrayN_SynAppReceiptVerify();
        }else{
            p_GrayN_SynAppReceiptRequest = p_GrayN_SynAppReceiptRequestQueue->front_element();
            if (p_GrayN_SynAppReceiptRequest == NULL) {
#ifdef SynAppReceiptDEBUG
                [GrayNbaseSDK GrayN_Debug_Log:@"p_GrayN_SynAppReceiptRequest is null!"];
#endif
                p_GrayN_SynAppReceiptIsLocalVerify = true;           //注意这里，当curRequest == NULL，使用isLocalVerify = true的定时器处理，等待2分钟还是5秒
                continue;
            }
            
#ifdef SynAppReceiptDEBUG
            [GrayNbaseSDK GrayN_Debug_Log:@"==========GrayN_SynAppReceipt::GrayNrun()==========正在验证订单号%s",p_GrayN_SynAppReceiptRequest->m_GrayN_AppRequest_SSID.c_str()];
#endif
            GrayN_SynAppReceiptVerify();
        }
    }
}

void GrayN_SynAppReceipt::GrayN_SynAppReceiptVerify()
{
    //appReceipt数据未进行解密，服务器那边进行了处理
    if (p_GrayN_SynAppReceiptRequestStatus == 1) {
        //触发新的请求
        
#ifdef SynAppReceiptDEBUG
        [GrayNbaseSDK GrayN_Debug_Log:@"==========GrayN_SynAppReceipt::GrayNrun()==========正在验证订单号%s",p_GrayN_SynAppReceiptRequest->m_GrayN_AppRequest_SSID.c_str()];
#endif
        p_GrayN_SynAppReceiptRequestStatus = 0;
        p_GrayN_SynAppReceiptRequestCount = 0;           //注意这里
        this->GrayN_SynAppReceiptConnectToVerify();
    }else if (p_GrayN_SynAppReceiptRequestStatus == -1){
        //请求失败，重新发起请求
        p_GrayN_SynAppReceiptRequestStatus = 0;
        this->GrayN_SynAppReceiptConnectToVerify();
    }else if (p_GrayN_SynAppReceiptRequestStatus == 0){
        sleep(5);
    }
}
void GrayN_SynAppReceipt::GrayN_SynAppReceiptConnectToVerify()
{
    string verUrl([GrayNbaseSDK GrayNgetAppstoreVerifyUrl]);
//    cout<<verUrl<<endl;
    string data("orderId=");
    string ssid = p_GrayN_SynAppReceiptRequest->GrayN_AppVerifyRequest_SSID;
    string countryCode = p_GrayN_SynAppReceiptRequest->GrayN_AppVerifyRequest_CountryCode;
    string currencyCode = p_GrayN_SynAppReceiptRequest->GrayN_AppVerifyRequest_CurrencyCode;
    string orderType = p_GrayN_SynAppReceiptRequest->GrayN_AppVerifyRequest_OrderType;
    int pos = (int)ssid.find("|");
#ifdef CHECKORDER
    string orderId;
#endif
    if (pos >0 ) {
        //历史订单，订单号|国家码
#ifdef CHECKORDER
        orderId = ssid.substr(0,pos);
#endif
        data.append(ssid.substr(0,pos));
        countryCode = ssid.substr(pos+1);
        currencyCode="";
    }else{
#ifdef CHECKORDER
        orderId = ssid;
#endif
        data.append(ssid);
    }
    
#ifdef CHECKORDER
    bool result = GrayN_SynAppReceiptCheckOrder(orderId.c_str());
    if (!result) {
        //无效订单
        string logId = p_GrayN_SynAppReceiptRequest->GrayN_AppVerifyRequest_LogId;
        GrayN_Store_IAP::GetInstance().GrayN_Store_IAP_RemoveData(logId);
        if (p_GrayN_SynAppReceiptIsLocalVerify) {
            p_GrayN_SynAppReceiptLocalQueue->pop();
        }else{
            p_GrayN_SynAppReceiptRequestQueue->pop();
        }
        sleep(3);
        p_GrayN_SynAppReceiptRequestStatus = 1;
        return;
    }
#endif
    
    data.append("&appFeeVersion=");     //验证接口版本号
#ifdef APPRECEIPT_MD5
    data.append("4");
#else
    data.append("3");
#endif
    data.append("&countryCode=");
    data.append(countryCode);
    data.append("&currencyCode=");
    data.append(currencyCode);
    data.append("&resend=1");         //用于标识是否为本地同步过来的
    data.append("&orderType=");     //订单类型，历史订单、漏单、未实时同步订单
    data.append(orderType);
    data.append("&appParam=");
    data.append(p_GrayN_SynAppReceiptRequest->GrayN_AppVerifyRequest_AppReceipt);

    [GrayNbaseSDK GrayN_Debug_Log:@"GrayN_SynAppReceipt=%@", BeNSString(data.c_str())];
    
#ifdef APPRECEIPT_MD5
    string sign;
    sign.append("4");       //appFeeVersion
    sign.append(p_GrayN_SynAppReceiptRequest->GrayN_AppVerifyRequest_AppReceipt);//appParam
    sign.append(countryCode);
    sign.append(currencyCode);
    sign.append(ssid);
    sign.append("1");       //resend
    sign.append("obctabsayo34rty56c");  //key
    string md5Encode = GrayN_Store_IAP::GetInstance().GrayN_Store_IAP_MD5Encode(sign.c_str());
    data.append("&sign=");
    data.append(md5Encode);
#endif
    
#ifdef HTTPS
    p_GrayN_SynAppReceiptHttps->GrayN_Https_Post(verUrl, data);
#else
    p_GrayN_SynAppReceiptHttps->GrayN_Http_Set_ContentType("application/x-www-form-urlencoded");
    p_GrayN_SynAppReceiptHttps->GrayN_Http_Post_ByUrl(verUrl.c_str(), data.c_str(), (int)data.length());
#endif

}

void GrayN_SynAppReceipt::GrayN_On_HttpError(GrayN_Http_GrayN* client, GrayN_HttpErrorCode code)
{
    if (p_GrayN_SynAppReceiptRequestCount > 3) {
        if (p_GrayN_SynAppReceiptIsLocalVerify) {
            p_GrayN_SynAppReceiptLocalQueue->pop();         //本地验证失败的，不管了，下次再说
        }else{
            p_GrayN_SynAppReceiptRequestQueue->pop();        //暂时先不管。。。。。。
        }
        sleep(3);
        p_GrayN_SynAppReceiptRequestStatus = 1;
    }else{
        p_GrayN_SynAppReceiptRequestCount++;
        sleep(3);
        p_GrayN_SynAppReceiptRequestStatus = -1;
    }
}

void GrayN_SynAppReceipt::GrayN_On_HttpEvent(GrayN_Http_GrayN* client, GrayN_HttpEventCode code)
{
#ifdef SynAppReceiptDEBUG
    [GrayNbaseSDK GrayN_Debug_Log:@"on http event code = %d", code];
#endif
    if(code == k_GrayN_SEND_HEAD){
        p_GrayN_SynAppReceiptHttpsBuffer.clear();
    } else if(code == k_GrayN_COMPLETE) {
        GrayN_SynAppReceiptVerifyResult(p_GrayN_SynAppReceiptHttpsBuffer.c_str());
        //这里肯定会返回结果，所以无论验证结果是否正确，直接pop
        if (p_GrayN_SynAppReceiptIsLocalVerify) {
            p_GrayN_SynAppReceiptLocalQueue->pop();
        }else{
            p_GrayN_SynAppReceiptRequestQueue->pop();
        }
        sleep(3);
        p_GrayN_SynAppReceiptRequestStatus = 1;
    }
}
void GrayN_SynAppReceipt::GrayN_On_HttpResponse(GrayN_Http_GrayN* client,int code,int context_length,int startPos,int endPos,int totalContext,const char* data)
{
    
}
void GrayN_SynAppReceipt::GrayN_On_Http_Data(GrayN_Http_GrayN* client,const char* data,int count)
{
    p_GrayN_SynAppReceiptHttpsBuffer.append(data,count);
}

void GrayN_SynAppReceipt::GrayN_SynAppReceiptAddLocalVeritifyRequest(const char* tmpSSid,const char* tmpReceipt)
{
    GrayN_AppVerifyRequest* request = new GrayN_AppVerifyRequest();
//    request->GrayN_AppVerifyRequest_LogId = tmpLogId;
    request->GrayN_AppVerifyRequest_SSID = tmpSSid;
    request->GrayN_AppVerifyRequest_AppReceipt = tmpReceipt;
//    request->GrayN_AppVerifyRequest_CountryCode = tmpCountryCode;
//    request->GrayN_AppVerifyRequest_CurrencyCode = tmpCurrencyCode;
    p_GrayN_SynAppReceiptLocalQueue->push(request);
}

void GrayN_SynAppReceipt::GrayN_SynAppReceiptAddLocalVeritifyRequest(GrayN_AppVerifyRequest* request)
{
    p_GrayN_SynAppReceiptLocalQueue->push(request);
}

//void GrayN_SynAppReceipt::addResendVeritifyRequest(const char* tmpSSid,const char* tmpReceipt)
//{
//    //限制请求的数量，避免占用太多内存，这种情况下优先处理之前的订单
//    int size = p_GrayN_SynAppReceiptLocalQueue->size() + p_GrayN_SynAppReceiptRequestQueue->size();
//    if (size > 10) {
//        [GrayNbaseSDK GrayN_Debug_Log:@"busy now!"];
//        return;
//    }
//    GrayN_AppVerifyRequest* request = new GrayN_AppVerifyRequest();
//    request->m_GrayN_AppRequest_SSID = tmpSSid;
//    request->GrayN_AppVerifyRequest_AppReceipt = tmpReceipt;
//    p_GrayN_SynAppReceiptRequestQueue->push(request);
//}

int GrayN_SynAppReceipt::GrayN_SynAppReceiptLocalQueueSize()
{
    return p_GrayN_SynAppReceiptLocalQueue->size();
}

#ifdef CHECKORDER
void GrayN_SynAppReceipt::GrayN_SynAppReceiptStoreKey()
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *value = [userDefaults valueForKey:@"DK"];
    if (value) {
        if (value.length < 3) {
            GrayN_SynAppReceipt::m_GrayN_StoreKey = [GrayNbaseSDK GrayNgetSecretKey];
            return;
        }
        int index = (int)value.length-3;
        NSString *head = [value substringFromIndex:index];
        NSString *end = [value substringToIndex:index];
        NSString *encode = [NSString stringWithFormat:@"%@%@",head,end];
        NSData *data = [encode dataUsingEncoding:NSUTF8StringEncoding];
        NSString* decode = [[NSString alloc] initWithData:[GrayN_GTMBase64_GrayN decodeData:data] encoding:NSUTF8StringEncoding];
        if (value.length == 0) {
            GrayN_SynAppReceipt::m_GrayN_StoreKey = [GrayNbaseSDK GrayNgetSecretKey];
            return;
        }
        string tmp([decode UTF8String]);
        string reverse(tmp);
        int count = (int)tmp.length();
        for(int i=0;i<count;i++){
            reverse[i] = tmp[count-i-1];
        }
        GrayN_SynAppReceipt::m_GrayN_StoreKey = reverse;

        [GrayNbaseSDK GrayN_Debug_Log:@"DK=%@,GrayN_SynAppReceipt::m_GrayN_StoreKey=%@,[GrayNbaseSDK GrayNgetSecretKey]=%@", encode, BeNSString(GrayN_SynAppReceipt::m_GrayN_StoreKey.c_str()), BeNSString([GrayNbaseSDK GrayNgetSecretKey])];

        [decode release];
    } else {
        GrayN_SynAppReceipt::m_GrayN_StoreKey = [GrayNbaseSDK GrayNgetSecretKey];
        string tmp([GrayNbaseSDK GrayNgetSecretKey]);
        string reverse(tmp);
        int count = (int)tmp.length();
        for(int i=0;i<count;i++){
            reverse[i] = tmp[count-i-1];
        }
        NSString* reverseStr = [NSString stringWithUTF8String:reverse.c_str()];
        NSData *data = [reverseStr dataUsingEncoding:NSUTF8StringEncoding];
        NSString* encoded = [[NSString alloc] initWithData:[GrayN_GTMBase64_GrayN encodeData:data] encoding:NSUTF8StringEncoding];
        [GrayNbaseSDK GrayN_Debug_Log:@"DK=%@,GrayN_SynAppReceipt::m_GrayN_StoreKey=%@,[GrayNbaseSDK GrayNgetSecretKey]=%@", encoded, BeNSString(GrayN_SynAppReceipt::m_GrayN_StoreKey.c_str()), BeNSString([GrayNbaseSDK GrayNgetSecretKey])];

        NSString *head = [encoded substringToIndex:3];
        NSString *end = [encoded substringFromIndex:3];
        NSString *storeData = [NSString stringWithFormat:@"%@%@",end,head];
        [userDefaults setValue:storeData forKey:@"DK"];
        [userDefaults synchronize];
        [encoded release];
    }
}

void GrayN_SynAppReceipt::GrayN_SynAppReceiptParseSystemTime(const char* data)
{
    if(data == NULL)
        return;
    string tmp(data);
    int pos = (int)tmp.find("Date: ");
    if(pos >= 0)
    {
        tmp = tmp.substr(pos+6);
        pos = (int)tmp.find("\r\n");
        if(pos >= 0)
        {
            tmp = tmp.substr(0,pos);
            GrayN_SynAppReceiptGetSystemTime(tmp.c_str());
        }
    }
}

void GrayN_SynAppReceipt::GrayN_SynAppReceiptGetSystemTime(const char* timeData)
{
    if (timeData == NULL) {
        return;
    }
    [GrayNbaseSDK GrayN_Debug_Log:@"OPGameSDK OPLOG：服务器时间=%@",BeNSString(timeData)];

    NSString *string = [NSString stringWithUTF8String:timeData];
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"EEE, dd MMM yyyy HH:mm:ss ZZZZ";
    fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en-US"];
    NSDate *date = [fmt dateFromString:string];
    if(date)
    {
        NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *targetTime = [dateFormatter stringFromDate:date];
        if(targetTime)
        {
            NSDate *tmpDate = [dateFormatter dateFromString:targetTime];
            NSTimeInterval now=[tmpDate timeIntervalSince1970]*1;
            p_GrayN_SystemDate = [[NSDate alloc] initWithTimeIntervalSince1970:now];
            //p_GrayN_SynAppReceiptSystemTime = [targetTime UTF8String];
        }
        [dateFormatter release];
    }
    [fmt release];
}

bool GrayN_SynAppReceipt::GrayN_SynAppReceiptCheckOrder(const char* order)
{
    //以初始化的服务器时间为准，订单超过7天就删除
    if (p_GrayN_SystemDate == nil) {
        return true;
    }
    NSString *orderStr = [NSString stringWithUTF8String:order];
    NSString *timeStr = [orderStr substringWithRange:NSMakeRange(3,14)];
    NSMutableString *datestring = [NSMutableString stringWithFormat:@"%@",timeStr];
    [datestring insertString:@"-" atIndex:4];
    [datestring insertString:@"-" atIndex:7];
    [datestring insertString:@" " atIndex:10];
    [datestring insertString:@":" atIndex:13];
    [datestring insertString:@":" atIndex:16];
    
    NSDateFormatter *date=[[NSDateFormatter alloc] init];
    [date setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *d=[date dateFromString:datestring];
    
    NSTimeInterval late=[d timeIntervalSince1970]*1;
    
    //NSDate* dat = [NSDate date];
    NSTimeInterval now=[p_GrayN_SystemDate timeIntervalSince1970]*1;
    NSString *timeString=@"";
    
    NSTimeInterval cha=now-late;
    
    [date release];
    
    if (cha/86400>1)
    {
        timeString = [NSString stringWithFormat:@"%f", cha/86400];
        timeString = [timeString substringToIndex:timeString.length-7];
        int day = [timeString intValue];
        if (day > 7) {
            return false;   //无效订单
        }
        return true;    //有效订单
    }
    return true;    //有效订单
}
#endif

