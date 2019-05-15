//
//  GrayNbaseSDK.m
//  GrayNbaseSDK
//
//  Created by op-mac1 on 15-5-6.
//  Copyright (c) 2015年 op-mac1. All rights reserved.
//

#import "GrayNbaseSDK.h"
#import "GrayN_BaseControl.h"
#import "GrayN_LoadingUI.h"
#import "GrayN_Offical.h"
#import "GrayNSDK.h"
#import "GrayN_UserCenter.h"
#import "GrayNpayCenter.h"
#import "GrayN_Base64_GrayN.h"
#import "GrayN_UrlEncode_GrayN.h"
#import "GrayN_Des_GrayN.h"
#import "GrayNinitCheck.h"
#import "GrayNinit.h"
#import <stdlib.h>

//static GrayNbaseSDK * _sharedInstance;
@implementation GrayNbaseSDK
#pragma mark - Init
//+ (id)shareInstance
//{
//    @synchronized ([GrayNbaseSDK class]) {
//        if (_sharedInstance == nil) {
//            _sharedInstance = [[GrayNbaseSDK alloc] init];
//        }
//        return _sharedInstance;
//    }
//}
+ (void)GrayNsetUserPlatformID:(NSString *)GrayNplatformID
{
    GrayNcommon::m_GrayN_UserPlatformId = [GrayNplatformID UTF8String];
}
+ (void)GrayNsetSDKVersion:(NSString *)GrayNSDKVersion
{
    GrayNcommon::m_GrayN_SDKVersion = [GrayNSDKVersion UTF8String];
}

+ (void)GrayNcallBackInit:(BOOL)GrayNstatus
{
    GrayNcommon::GrayN_ConsoleLog(@"opRootViewController=%@", GrayNcommon::m_GrayN_RootViewController);
//    // 根据用户中心初始化状态弹出更新界面
//    if (GrayN_SDK_Init::GetInstance().GrayN_GetInitStatus()) {
//    }
    
    if (GrayNstatus && GrayN_SDK_Init::GetInstance().GrayN_GetInitStatus()) {
        // 渠道初始化完成后弹更新界面
        GrayN_Offical::GetInstance().GrayN_Offical_Update();
        GrayNSDK::GrayN_SDK_CallBackInit(true, "opChannelSDK_initSuccess");
    } else {
        // 渠道初始化失败重新初始化
        GrayN_SDK_Init::GetInstance().GrayN_SetInitStatus(false);
        GrayNSDK::GrayN_SDK_CallBackInit(false, "opChannelSDK_initFail");
    }
}
#pragma mark Login
+ (void)GrayNregisterLogin
{
    GrayN_Offical::GetInstance().GrayN_Offical_RegisterLogin();
}
+ (void)GrayNcallBackLogin:(NSDictionary*)GrayNresultDic
{
    GrayNcommon::GrayN_DebugLog(@"resultDic=%@",GrayNresultDic);
    NSString *result = [GrayNresultDic objectForKey:@"result"];
    NSString *verifyJson = [GrayNresultDic objectForKey:@"verifyJson"];
    string buf=[verifyJson UTF8String];
    
    if ([result boolValue]) {
        GrayN_JSON::Value json_object;
        GrayN_JSON::Reader json_reader;
        if (!json_reader.parse(buf, json_object)){
            GrayNcommon::GrayN_ConsoleLog(@"GrayNbaseSDK***********callBackLogin,resultDic parse error!");
            return;
        }
        GrayN_UserCenter::GetInstance().GrayN_UserCenter_LoginVerify_GrayN(json_object);
        [GrayNbaseSDK GrayNshow_Wait];
    } else {
        GrayNSDK::GrayN_SDK_CallBackLogin(false, buf.c_str());
    }
}
#pragma mark- 渠道登录
+ (BOOL)GrayNisLogin
{
    return GrayNchannel::GetInstance().GrayN_ChannelIsLogin();
}
#pragma mark Gaming
+ (void)GrayNenterPlatform
{
    GrayN_Offical::GetInstance().GrayN_Offical_EnterPlatform();
}
+ (void)GrayNuserFeedback
{
    GrayN_Offical::GetInstance().GrayN_Offical_CustomService();
}
+ (void)GrayNswitchAccount
{
    GrayN_Offical::GetInstance().GrayN_Offical_SwitchAccount();
}
+ (void)GrayNcallBackSwitchAccount:(BOOL)result
{
    if (result) {
        GrayNSDK::GrayN_SDK_CallBackLogout(true, GrayN_LogoutJson_SwitchAccount);
        GrayNcommon::GrayN_DebugLog(@"GrayNbaseSDK***********GrayNcallBackSwitchAccount，切换账号成功");
    }else{
        GrayNSDK::GrayN_SDK_CallBackLogout(false, GrayN_LogoutJson_SwitchAccount);
        GrayNcommon::GrayN_DebugLog(@"GrayNbaseSDK***********GrayNcallBackSwitchAccount，切换账号失败");
    }
}
+ (void)GrayNlogout
{
    GrayN_Offical::GetInstance().GrayN_Offical_Logout();
}
+ (void)GrayNcallBackLogout:(BOOL)GrayNresult
{
    if (GrayNresult) {
        GrayNSDK::GrayN_SDK_CallBackLogout(true, GrayN_LogoutJson_Logout);
        GrayNcommon::GrayN_DebugLog(@"GrayNbaseSDK***********callBackLogout，注销成功");
    } else {
        GrayNSDK::GrayN_SDK_CallBackLogout(false, GrayN_LogoutJson_Logout);
        GrayNcommon::GrayN_DebugLog(@"GrayNbaseSDK***********callBackLogout，注销失败");
    }
}



#pragma mark- Pay
+ (void)GrayNcallBackPayResult:(BOOL)GrayNresult data:(NSDictionary *)GrayNpayResultDic;
{    
    string reset = [[GrayNpayResultDic objectForKey:@"reset"] UTF8String];
    string desc = [[GrayNpayResultDic objectForKey:@"desc"] UTF8String];
    string propId = GrayNpayCenter::GetInstance().m_GrayN_Pay_ProductId;
    string ssid = GrayNpayCenter::GetInstance().m_GrayN_Pay_SSID;

    if (propId == "" && ssid == "") {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *lastSsid = [userDefaults objectForKey:@"lastSsid"];
        if (lastSsid == nil || [lastSsid isEqualToString:@""]) {
            ssid = "unknown";
        } else {
            ssid = [lastSsid UTF8String];
        }
        NSString *lastProductId = [userDefaults objectForKey:@"lastProductId"];
        if (lastProductId == nil || [lastProductId isEqualToString:@""]) {
            propId = "unknown";
        } else {
            propId = [lastProductId UTF8String];
        }
    }
//    NSNumber *errNumber = [payResultDic objectForKey:@"reset"];
//    int reset = [errNumber intValue];
    GrayN_JSON::Value errJson;
    errJson["propId"] = GrayN_JSON::Value(propId);
    errJson["reset"] = GrayN_JSON::Value(reset);
    errJson["desc"] = GrayN_JSON::Value(desc);
    errJson["ssId"] = GrayN_JSON::Value(ssid);
    GrayN_JSON::FastWriter fast_writer;
    string resultStr = fast_writer.write(errJson);
    
    GrayNSDK::GrayN_SDK_OnPurchaseResult(GrayNresult, resultStr.c_str());
}

+(NSString *)toJSONStr:(id)theData
{
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:theData
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    if ([jsonData length] > 0 && error == nil){
        jsonStr = [jsonStr stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
        jsonStr = [jsonStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        jsonStr = [jsonStr stringByReplacingOccurrencesOfString:@" " withString:@""];
        return jsonStr;
    }else{
        return nil;
    }
}

#pragma mark- Tools
+ (NSString*)GrayNencode_Base64_UrlEncode:(NSString*)GrayNinputData
{
    if ([GrayNinputData isEqualToString:@""] || GrayNinputData == nil) {
        return @"";
    }
    string baseEncode;
    const char* tmp = [GrayNinputData UTF8String];
    GrayN_Base64_GrayN::GrayN_Base64Encode((unsigned const char*)tmp, strlen(tmp), baseEncode);
    string strEncode;
    GrayN_UrlEncode_GrayN::GrayN_Url_Encode(baseEncode, strEncode);
    NSString *ocStr = [[[NSString alloc] initWithString:[NSString stringWithUTF8String:strEncode.c_str()]] autorelease];

    return ocStr;
}
+ (NSString*)GrayNdecodeBase64:(NSString*)GrayNinputData
{
    if ([GrayNinputData isEqualToString:@""] || GrayNinputData == nil) {
        return @"";
    }
    NSData *data = [[[NSData alloc]initWithBase64EncodedString:GrayNinputData options:0] autorelease];
    
    NSString *detailStr = [[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding] autorelease];
//    detailStr = [detailStr stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
//    detailStr = [detailStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    return detailStr;

}

+ (NSString*)GrayNencodeBase64:(NSString*)GrayNinputData
{
    if ([GrayNinputData isEqualToString:@""] || GrayNinputData == nil) {
        return @"";
    }
    const char* tmp = [GrayNinputData UTF8String];
    string baseEncode;
    GrayN_Base64_GrayN::GrayN_Base64Encode((unsigned const char*)tmp, strlen(tmp), baseEncode);
    NSString *detailStr = [NSString stringWithUTF8String:baseEncode.c_str()];
    detailStr = [detailStr stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
    detailStr = [detailStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    return detailStr;
}

+ (NSString*)GrayNencodeDES:(NSString*)GrayNinputData
{
    if ([GrayNinputData isEqualToString:@""] || GrayNinputData == nil) {
        return @"";
    }
    string result = "";
    GrayN_Des_GrayN::GrayN_DesEncrypt([GrayNinputData UTF8String], result);
    if (result == "") {
        GrayNcommon::GrayN_ConsoleLog(@"GrayNencodeDES异常");
        return @"";
    }
    NSString *ocStr = [[[NSString alloc] initWithString:[NSString stringWithUTF8String:result.c_str()]] autorelease];
    return ocStr;
}
+ (NSString*)GrayNencodeDES:(const char*)GrayNinputData andKey:(const char*)GrayNkey
{
    if (GrayNinputData == nil) {
        return @"";
    }
    string result = "";
    GrayN_Des_GrayN::GrayN_DesEncrypt(GrayNinputData, GrayNkey, result);
//    cout<<"GrayNencodeDES"<<result<<endl;
    if (result == "") {
        GrayNcommon::GrayN_ConsoleLog(@"GrayNencodeDES异常");
        return @"";
    }
    NSString *ocStr = [[[NSString alloc] initWithString:[NSString stringWithUTF8String:result.c_str()]] autorelease];
    return ocStr;
}
+ (NSString*)GrayNdecodeDES:(NSString*)GrayNinputData
{
    if ([GrayNinputData isEqualToString:@""] || GrayNinputData == nil) {
        return @"";
    }
    string Out = "";
    string In = [GrayNinputData UTF8String];
    GrayN_Des_GrayN::GrayN_DesDecrypt(In, Out);
    
    if (Out == "") {
        GrayNcommon::GrayN_ConsoleLog(@"GrayNdecodeDES异常");
        return @"";
    }
    NSString *ocStr = [[[NSString alloc] initWithString:[NSString stringWithUTF8String:Out.c_str()]] autorelease];
    return ocStr;
}
+ (NSString*)GrayNdecodeDES:(const char*)GrayNinputData andKey:(const char*)GrayNkey
{
    if (GrayNinputData == nil) {
        return @"";
    }
    string result = "";
    GrayN_Des_GrayN::GrayN_DesDecrypt(GrayNinputData, GrayNkey, result);
    //    cout<<"GrayNencodeDES"<<result<<endl;
    if (result == "") {
        GrayNcommon::GrayN_ConsoleLog(@"GrayNdecodeDES异常");
        return @"";
    }
    NSString *ocStr = [[[NSString alloc] initWithString:[NSString stringWithUTF8String:result.c_str()]] autorelease];
    return ocStr;
}
+ (NSString*)GrayNurl_Encode:(const char*)GrayNinputData
{
    string encodeStr = "";
    GrayN_UrlEncode_GrayN::GrayN_Url_Encode(GrayNinputData, encodeStr);
    NSString *ocStr = [[[NSString alloc] initWithString:[NSString stringWithUTF8String:encodeStr.c_str()]] autorelease];
    return ocStr;
}
+ (NSString*)GrayNurl_Decode:(const char*)GrayNinputData
{
    string decodeStr = "";
    GrayN_UrlEncode_GrayN::GrayN_Url_Decode(GrayNinputData, decodeStr);
    if (decodeStr == "") {
        GrayNcommon::GrayN_ConsoleLog(@"UrlDecode异常");
        return @"";
    }
    NSString *ocStr = [[[NSString alloc] initWithString:[NSString stringWithUTF8String:decodeStr.c_str()]] autorelease];
    
    return ocStr;
}
#pragma mark- UIOrientation
+ (BOOL)GrayNwindow_IsLandScape
{
    return [GrayN_BaseControl GrayN_Base_WindowIsLandScape];
}
+ (BOOL)GrayNwindow_IsAutoOrientation
{
    return [GrayN_BaseControl GrayN_Base_WindowIsAutoOrientation];
}
+ (UIInterfaceOrientation)GrayNwindow_InitOrientation
{
    return [GrayN_BaseControl GrayN_Base_WindowInitOrientation];
}
+ (UIInterfaceOrientationMask)GrayNsupportedInterfaceOrientations
{
    return [GrayN_BaseControl GrayN_Base_SupportedInterfaceOrientations];
}
+ (CGRect)GrayNwindow_Rect
{
    return [GrayN_BaseControl GrayN_Base_WindowRect];
}
#pragma mark- GrayNSDK
+ (const char*)GrayNgetGame_RoleId
{
    return GrayNcommon::m_GrayN_Game_RoleId.c_str();
}
+ (const char*)GrayNgetGame_RoleName
{
    return GrayNcommon::m_GrayN_Game_RoleName.c_str();
}
+ (const char*)GrayNgetSdkVersion
{
    return GrayNcommon::m_GrayN_SDKVersion.c_str();
}
+ (const char*)GrayNgetApplogUrl
{
    return GrayNSDK::m_GrayN_SDK_AppLogUrl.c_str();
}
+ (const char*)GrayNget_ServiceId
{
    return GrayNcommon::m_GrayN_ServiceId.c_str();
}

+ (const char*)GrayNgetAppstoreVerifyUrl
{
    return GrayNSDK::m_GrayN_SDK_AppstoreVerifyUrl.c_str();
}
+ (const char*)GrayNgetGame_ServerId
{
    return GrayNcommon::m_GrayN_Game_ServerId.c_str();
}
+ (const char*)GrayNgetGame_ServerName
{
    return GrayNcommon::m_GrayN_Game_ServerName.c_str();
}
+ (UIViewController*)GrayNgetRootViewController
{
    UIViewController *rvc = (UIViewController*)GrayNcommon::m_GrayN_RootViewController;
    if (rvc == nil) {
        rvc = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    }
    return rvc;
}
+ (const char*)GrayNgetSecretKey
{
    return GrayNcommon::m_GrayN_SecretKey.c_str();
}
+ (BOOL)GrayNgetChargeLogSwitch
{
     return GrayNSDK::m_GrayN_SDK_ChargeLogSwitch;
}
#pragma mark- Common
+ (NSString*)GrayNgetCurrentMil_TimeString
{
    NSString *ocStr = [[[NSString alloc] initWithString:[NSString stringWithUTF8String:GrayNcommon::GrayNgetCurrent_MilTimeString().c_str()]] autorelease];
    return ocStr;
}
+ (NSString*)GrayNgetCurrentDate_Time
{
    NSString *ocStr = [[[NSString alloc] initWithString:[NSString stringWithUTF8String:GrayNcommon::GrayNgetCurrent_DateAndTime().c_str()]] autorelease];
    return ocStr;
}
+ (const char*)GrayNgetDeviceOsVersion
{
    return GrayNcommon::m_GrayN_Device_OS_Version.c_str();
}
+ (BOOL)GrayNgetDeviceIsJailBreak
{
    return GrayNcommon::m_GrayN_IsJail_Break;
}
+ (const char*)GrayNgetDeviceMacAddress
{
    return GrayNcommon::m_GrayN_MAC_Address.c_str();
}
+ (const char*)GrayNgetDeviceIDFA
{
    return GrayNcommon::m_GrayN_IDFA.c_str();
}
+ (const char*)GrayNgetDeviceUniqueID
{
    return GrayNcommon::m_GrayN_Device_UniqueId.c_str();
}
+ (const char*)GrayNgetLocalLang:(const char*)GrayNinputData
{
    return GrayNcommon::GrayNcommonGetLocalLang(GrayNinputData);
}
+ (void)GrayN_Debug_Log:(id)logs, ...
{
    if (!logs)
        return;
#ifndef DEBUG
    if (!GrayNcommon::m_GrayNdebug_Mode)
        return;
#endif
    @autoreleasepool {
        va_list arglist;
        va_start(arglist, logs);
        NSString *outStr = [[[NSString alloc] initWithFormat:logs arguments:arglist] autorelease];
        va_end(arglist);
        GrayNcommon::GrayN_DebugLog(outStr);
    }
}
+ (void)GrayN_Console_Log:(id)logs, ...
{
    if (!logs) return;
    
    @autoreleasepool {
        va_list arglist;
        va_start(arglist, logs);
        NSString *outStr = [[[NSString alloc] initWithFormat:logs arguments:arglist] autorelease];
        va_end(arglist);
        GrayNcommon::GrayN_ConsoleLog(outStr);
    }
}
+ (BOOL)GrayN_Debug_Mode
{
    return GrayNcommon::m_GrayNdebug_Mode;
}
+ (const char*)GrayNgetGame_RoleLevel
    {
        return GrayNcommon::m_GrayN_Game_RoleLevel.c_str();
    }
+ (const char*)GrayNgetGame_RoleVipLevel
    {
        return GrayNcommon::m_GrayN_Game_RoleVipLevel.c_str();
    }
+ (BOOL)GrayNhomeIndicator_AutoHidden
{
    return GrayNcommon::m_GrayN_Home_Indicator_Auto_Hidden;
}
+ (int)GrayNdeferring_SystemGestures
{
    return GrayNcommon::m_GrayN_Deferring_System_Gestures;
}
    + (const char*)GrayNgetPayCallback_Url
    {
        return GrayNcommon::m_GrayN_Game_PayCallback_Url.c_str();
    }
#pragma mark GrayN_UserCenter
+ (const char*)GrayNgetGame_UserId
{
    return GrayNcommon::GrayNcommon::m_GrayN_Game_UserId.c_str();
}
#pragma mark Appstore
+ (void)GrayNsetAppstoreUrl
{
    /*异常崩溃 m_GrayN_SDK_AppstoreVerifyUrl 不能设置默认值*/
    // APPSTORE计费验证地址
    GrayNSDK::m_GrayN_SDK_AppstoreVerifyUrl = GrayNSDK::m_GrayN_SDK_BillingDomainName;
    GrayNSDK::m_GrayN_SDK_AppstoreVerifyUrl.append(GrayNappstoreVerifyRoute);

     /*上传收据地址*/
    GrayNcommon::GrayNstringReplace(GrayNSDK::m_GrayN_SDK_AppstoreVerifyUrl, "http://", "https://");

    //同步applog计费日志地址
    GrayNSDK::m_GrayN_SDK_AppLogUrl = GrayNcommon::m_GrayN_StatisticalUrl;
    GrayNSDK::m_GrayN_SDK_AppLogUrl.append(GrayNappstoreLogRoute);
}
#pragma mark- GrayNpayCenter
+ (const char*)GrayNget_SSID
{
    return GrayNpayCenter::GetInstance().m_GrayN_Pay_SSID.c_str();
}
+ (const char*)GrayNget_ProductId
{
    return GrayNpayCenter::GetInstance().m_GrayN_Pay_ProductId.c_str();
}
+ (const char*)GrayNget_ProductNum
{
    return GrayNpayCenter::GetInstance().m_GrayN_Pay_ProductNum.c_str();
}
+ (const char*)GrayNget_ProductName
{
    return GrayNpayCenter::GetInstance().m_GrayN_Pay_ProductName.c_str();
}
+ (const char*)GrayNget_ProductPrice
{
    return GrayNpayCenter::GetInstance().m_GrayN_Pay_Price.c_str();
}
+ (const char*)GrayNget_ProductRealName
{
    return GrayNpayCenter::GetInstance().m_GrayN_Pay_RealProductName.c_str();
}
+ (const char*)GrayNget_ProductDescription
{
    return GrayNpayCenter::GetInstance().m_GrayN_Pay_ProductDesc.c_str();
}
+ (const char*)GrayNget_ExtendParams
{
    return GrayNpayCenter::GetInstance().m_GrayN_Pay_ExtendParams.c_str();
}
+ (const char*)GrayNget_CurrencyType
{
    return GrayNpayCenter::GetInstance().m_GrayN_Pay_CurrencyType.c_str();
}
+ (const char*)GrayNget_DeliveryUrl
{
    return GrayNpayCenter::GetInstance().m_GrayN_Pay_DeliveryUrl.c_str();
}
//+ (void)RepayLastOder
//{
//    GrayNpayCenter::GetInstance().RepayLastOder();
//}

#pragma mark- GrayN_LoadingUI
+ (void)GrayNshow_Wait
{
    GrayN_LoadingUI::GetInstance().GrayN_ShowWaitMainThread(GrayNcommon::GrayNcommonGetLocalLang(GrayN_WaitingString));
}
+ (void)GrayNclose_Wait
{
    GrayN_LoadingUI::GetInstance().GrayN_CloseWaitMainThread();

}
#pragma mark- BaseControl
+ (UIWindow *)GrayNgetGame_Window
{
    return [[GrayN_BaseControl GrayN_Share] GrayN_GetGame_Window];
}
+ (UIWindow *)GrayNgetSDK_Window
{
    return [[GrayN_BaseControl GrayN_Share] GrayN_GetSDK_Window];
}

@end
