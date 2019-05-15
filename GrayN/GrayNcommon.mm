//     //
//5.1.2//
//     //
#import <iostream>
using namespace std;
#import <sys/socket.h> // Per msqr
#import <sys/sysctl.h>
#import <sys/types.h>
#import <net/if.h>
#import <net/if_dl.h>
#import <objc/objc.h>
#import <mach/mach.h>
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <UIKit/UIKit.h>
#import <stdio.h>
#import <stdlib.h>
#import <AdSupport/AdSupport.h>
#import <sys/utsname.h>
#import "GrayNjson_cpp.h"
#import <CommonCrypto/CommonDigest.h>
#import <Security/Security.h>

#import "GrayNcommon.h"
#import "GrayN_Reachability.h"
#import "GrayNcommon_oc.h"
#import "GrayNkeychainConfig.h"
#import "GrayNserviceCodeBridge.h"

#import "GrayN_Base64_GrayN.h"
#import "GrayN_UrlEncode_GrayN.h"
#import "GrayN_Des_GrayN.h"

#import "GrayN_DebugView.h"

GrayNusing_NameSpace;
#define TAG "|"

#pragma mark- 静态变量
static NSString* p_GrayNlangFileName;
static NSMutableDictionary *p_GrayNlangDic;

static NSString *p_GrayN_OP_IDFA;
static NSString *p_GrayNkeychainIDFA;
static NSString *p_GrayNopSDKVersion;

static dispatch_queue_t p_GrayNdebugLogQueue = dispatch_queue_create("p_GrayNdebugLogQueue", NULL);
static dispatch_queue_t p_GrayNconsoleLogQueue = dispatch_queue_create("p_GrayNconsoleLogQueue", NULL);

string GrayNcommon::m_GrayN_Game_UserId;
string GrayNcommon::m_GrayN_Game_RoleId="";
string GrayNcommon::m_GrayN_Game_RoleName="";
string GrayNcommon::m_GrayN_Game_ServerId="";
string GrayNcommon::m_GrayN_Game_ServerName="";
string GrayNcommon::m_GrayN_Game_RoleLevel="";
string GrayNcommon::m_GrayN_Game_RoleVipLevel="";
string GrayNcommon::m_GrayN_Game_UserName="";
string GrayNcommon::m_GrayN_ActionId="";
string GrayNcommon::m_GrayN_GameType="1";
string GrayNcommon::m_GrayN_CurrentUserType="";
string GrayNcommon::m_GrayN_LoginType ="";

string GrayNcommon::m_GrayN_UserPlatformId ="";
string GrayNcommon::m_GrayN_Game_PalmId ="";
string GrayNcommon::m_GrayN_Game_NickName ="";
string GrayNcommon::m_GrayN_Game_PhoneNum ="";
string GrayNcommon::m_GrayN_Game_Email ="";

void* GrayNcommon::m_GrayN_RootViewController;
string GrayNcommon::m_GrayN_ServiceId;
string GrayNcommon::m_GrayN_ChannelId;
string GrayNcommon::m_GrayN_LocaleId;
string GrayNcommon::m_GrayN_Oua;
string GrayNcommon::m_GrayN_AllVersion;
string GrayNcommon::m_GrayN_DeviceInfo;    //设备信息
GrayN_JSON::Value GrayNcommon::m_GrayN_DeviceJson; //设备唯一标识集合（{mac:“”，idfa:“”，deviceUniqueID:“”，phoneNum：“”}）

string GrayNcommon::m_GrayN_DeviceGroupId;
string GrayNcommon::m_GrayN_StatisticalUrl;     //统计信息接口地址

/*5.1.2*/
const char* GrayNcommon::m_GrayNkeyItem = "abcdefghijklmnopqrstuvwxyz1234567890";
string GrayNcommon::m_GrayN_BundleId = "";
/*5.1.2*/
string GrayNcommon::m_GrayN_DesKey = "";
string GrayNcommon::m_GrayN_SecretKey = "";
string GrayNcommon::m_GrayN_SessionId="";

bool GrayNcommon::m_GrayN_IsJail_Break;
bool GrayNcommon::m_GrayNdebug_Mode = true;
/*5.2.0*/
bool GrayNcommon::m_GrayNforceDebug_Mode = false;
GrayN_DebugView *p_GrayN_DebugView;

/*5.2.0*/
string GrayNcommon::m_GrayN_SDKVersion = "";
/*5.1.1*/
string GrayNcommon::m_GrayN_PushServerUrl = "http://auth.gamebean.net/ucenter2.0/push2.0/sdkpush"; // 推送地址
string GrayNcommon::m_GrayN_GameVersion = "";
string GrayNcommon::m_GrayN_GameResVersion = "1.0";
string GrayNcommon::m_GrayN_HttpStaticHeader = "";

string GrayNcommon::m_GrayN_OS_Version = "";
string GrayNcommon::m_GrayN_Device_Model = "";
string GrayNcommon::m_GrayNcurLanguage = "";
string GrayNcommon::m_GrayN_IMEI = "";
string GrayNcommon::m_GrayN_MAC_Address = "";
string GrayNcommon::m_GrayN_IDFA = "";
string GrayNcommon::m_GrayN_Device_UniqueId = "";
string GrayNcommon::m_GrayN_IDFV = "";

//string GrayNcommon::mPushIdentity = "";
string GrayNcommon::m_GrayN_RAM = "";
string GrayNcommon::m_GrayN_CpuCores = "";
string GrayNcommon::m_GrayN_CpuClockSpeed = "";
string GrayNcommon::m_GrayN_CpuType = "";
string GrayNcommon::m_GrayN_CpuInfo = "";

string GrayNcommon::m_GrayN_Screen_Resolution = "";
string GrayNcommon::m_GrayN_Screen_Orientation = "landscape";
string GrayNcommon::m_GrayN_Open_UUID = "";
string GrayNcommon::m_GrayN_SDK_Init_Url = "";

string GrayNcommon::m_GrayN_Channel_Name = "";
string GrayNcommon::m_GrayN_OPID = "";

string GrayNcommon::m_GrayN_P_Code = "";
string GrayNcommon::m_GrayN_NetSource_Info = "";

string GrayNcommon::m_GrayNmobileCode;
bool GrayNcommon::m_GrayNcommonIsInit=false;
bool GrayNcommon::m_GrayNcommonIsInitConfig=false;
float GrayNcommon::m_GrayN_Float_OS_Version;
string GrayNcommon::m_GrayN_Device_OS_Version = "";
string GrayNcommon::m_GrayNnetworkType = "";
string GrayNcommon::m_GrayNnetworkTypeNum ="";

string GrayNcommon::m_GrayNnetworkSubType = "";
string GrayNcommon::m_GrayNchannel_Info = "";

static NSMutableDictionary *p_GrayN_HeaderDic;

// 5.1.0
bool GrayNcommon::m_GrayN_ShowLoading = false;
bool GrayNcommon::m_GrayN_ScreenIsAutoRotation = true;
int GrayNcommon::m_GrayN_InitOrientation = UIInterfaceOrientationLandscapeRight;
int GrayNcommon::m_GrayN_SDKOrientation = 1;

// 5.1.1
string GrayNcommon::m_GrayNrealTimeIDFA = "";
string GrayNcommon::m_GrayNrealTimeIDFV = "";
static bool p_GrayNifUpdate = false;
// 5.1.5
int GrayNcommon::m_GrayN_Deferring_System_Gestures = UIRectEdgeAll;
bool GrayNcommon::m_GrayN_Home_Indicator_Auto_Hidden = false;
string GrayNcommon::m_GrayN_Game_PayCallback_Url = "";

/*5.2.1 二维码token*/
string GrayNcommon::m_GrayN_QRCodeTokenId = "";
#pragma mark- 内部函数
/* 配置文件中读取对应字段信息 */
string GetStrByTextStr(const char* str, const char* title)
{
    NSArray *original = [[NSString stringWithUTF8String:str] componentsSeparatedByString:[NSString stringWithFormat:@"%@=", [NSString stringWithUTF8String:title]]];
    if (original.count == 1) {
        GrayNcommon::GrayN_ConsoleLog(@"ourpalm.cfg中没有该参数：%@", [NSString stringWithUTF8String:title]);
        return "";
    }
    NSArray *separated = [[original lastObject] componentsSeparatedByString:@"\n"];
    return [[separated firstObject] UTF8String];
}
string GetNetSourceStr(string str)
{
    if (str == "" || str.c_str() == NULL) {
        return "-";
    } else {
        return str;
    }
}

void GetInfoPlistConfig()
{
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];

    id showInitLoading = [infoDic objectForKey:@"Ourpalm_ShowInitLoading"];
    if (showInitLoading) {
        GrayNcommon::m_GrayN_ShowLoading = [showInitLoading boolValue];
    }
    id debugModel = [infoDic objectForKey:@"Ourpalm_Debugmodel"];
    if (debugModel) {
        GrayNcommon::m_GrayNdebug_Mode = [debugModel boolValue];
    }
    /*5.2.0 调试页面*/
    p_GrayN_DebugView = [[GrayN_DebugView alloc] init];
    [p_GrayN_DebugView GrayN_DebugView_SetFrame:[UIScreen mainScreen].bounds];
    
    id autoRotation = [infoDic objectForKey:@"Ourpalm_AutoOrientation"];
    if (autoRotation) {
        GrayNcommon::m_GrayN_ScreenIsAutoRotation = [autoRotation boolValue];
    }
    id gameResVersion = [infoDic objectForKey:@"Ourpalm_GameResVersion"];
    if (gameResVersion) {
        if (![gameResVersion isEqualToString:@""]) {
            GrayNcommon::m_GrayN_GameResVersion = [gameResVersion UTF8String];
        } else {
            GrayNcommon::GrayN_ConsoleLog(@"Ourpalm_GameResVersion不能为空");
        }
    }
    id gameOnline = [infoDic objectForKey:@"Ourpalm_GameOnline"];
    if (gameOnline) {
        GrayNcommon::m_GrayN_GameType = [gameOnline boolValue]?"1":"0";
    }
    id homeIndicatorAutoHidden = [infoDic objectForKey:@"Ourpalm_HI_AutoHidden"];
    if (homeIndicatorAutoHidden) {
        GrayNcommon::m_GrayN_Home_Indicator_Auto_Hidden = [homeIndicatorAutoHidden boolValue];
    }
    id deferringSystemGestures = [infoDic objectForKey:@"Ourpalm_DefferingSG"];
    if (deferringSystemGestures) {
        if ([deferringSystemGestures isEqualToString:@"UIRectEdgeNone"]) {
            GrayNcommon::m_GrayN_Deferring_System_Gestures = UIRectEdgeNone;
        } else if ([deferringSystemGestures isEqualToString:@"UIRectEdgeTop"]) {
            GrayNcommon::m_GrayN_Deferring_System_Gestures = UIRectEdgeTop;
        } else if ([deferringSystemGestures isEqualToString:@"UIRectEdgeLeft"]) {
            GrayNcommon::m_GrayN_Deferring_System_Gestures = UIRectEdgeLeft;
        } else if ([deferringSystemGestures isEqualToString:@"UIRectEdgeBottom"]) {
            GrayNcommon::m_GrayN_Deferring_System_Gestures = UIRectEdgeBottom;
        } else if ([deferringSystemGestures isEqualToString:@"UIRectEdgeRight"]) {
            GrayNcommon::m_GrayN_Deferring_System_Gestures = UIRectEdgeRight;
        } else {
            GrayNcommon::m_GrayN_Deferring_System_Gestures = UIRectEdgeAll;
        }
    }
    NSString *initOrientation = [infoDic objectForKey:@"Ourpalm_InitOrientation"];
    if (initOrientation) {
        if ([initOrientation isEqualToString:@"UIInterfaceOrientationLandscapeRight"]) {
            GrayNcommon::m_GrayN_SDKOrientation = 1;
            GrayNcommon::m_GrayN_InitOrientation = UIInterfaceOrientationLandscapeRight;
            GrayNcommon::GrayN_ConsoleLog
            ("opInitOrientation:OPOrientationLandscapeRight");
        } else if ([initOrientation isEqualToString:@"UIInterfaceOrientationLandscapeLeft"]) {
            GrayNcommon::m_GrayN_SDKOrientation = 2;
            GrayNcommon::m_GrayN_InitOrientation = UIInterfaceOrientationLandscapeLeft;
            GrayNcommon::GrayN_ConsoleLog
            ("opInitOrientation:OPOrientationLandscapeLeft");
        } else {
            GrayNcommon::m_GrayN_SDKOrientation = 3;
            GrayNcommon::m_GrayN_InitOrientation = UIInterfaceOrientationPortrait;
            GrayNcommon::GrayN_ConsoleLog
            ("opInitOrientation:OPOrientationPortrait");
        }
    } else {
        GrayNcommon::GrayN_ConsoleLog(@"info.plist中没有添加Ourpalm_InitOrientation！！！");
        GrayNcommon::m_GrayN_SDKOrientation = 1;
        GrayNcommon::m_GrayN_InitOrientation = UIInterfaceOrientationLandscapeRight;
        GrayNcommon::GrayN_ConsoleLog
        ("opInitOrientation:OPOrientationLandscapeRight");
    }
    GrayNcommon::m_GrayN_BundleId = [[[NSBundle mainBundle] bundleIdentifier] UTF8String    ];
    GrayNcommon::GrayN_ConsoleLog("opBundleId:%s", GrayNcommon::m_GrayN_BundleId.c_str());

}
#pragma mark- 公共方法
bool GrayNcommon::GrayNcommonInit()
{
    if (m_GrayNcommonIsInit) {
        return true;
    }
    
    GetInfoPlistConfig();
    GrayNisJail_Break();
    GrayNgetOsVersion();
    GrayNgetAppVersion();
    GrayNgetDeviceModel();
    GrayNgetTrueDeviceModel();
    GrayNgetImei();
    GrayNgetMacAddress();
    GrayNget_ChannelInfo();
    if (!GrayNgetKeychainIDFA()) {
        GrayN_ConsoleLog(@"OPGameKit不是最新版本");
    }
    
    GrayNgetDevice_UniqueID();
    
    //    GrayNgetIpAddress();
    [GrayNcommon_oc init_GrayNcommon_oc];
    //    [GrayNCommon localIPAddresses];
    GrayNgetScreenResolution();
    
    /*5.2.0添加网络变更通知*/
    [GrayNcommon_oc add_GrayN_NetWorkChangedNotification];
    /*5.2.0*/
    GrayNgetMobileNetworkCode();
    GrayNgetfloatOsVersion();
    
    GrayNcreateSecretKey();
    GrayNdesEncryptKey(m_GrayN_SecretKey.c_str(), GrayNprivateKey, m_GrayN_DesKey);
    
    // 5.1.0
    GrayNgetDeviceInfo();
    GrayNgetCpuInfo();
    GrayNcheckNetworkType();
    
    
    
    // 读取语言文件
    // OurSDK_res.bundle/Language/Ourpalm_zh_CN.plist
    // string localLang("OurSDK_res.bundle/Language/");
    string localLang("OurSDK_res.bundle/Language/");
    localLang.append("Ourpalm_");
    localLang.append(m_GrayNcurLanguage);
    localLang.append(".plist");
    p_GrayNlangFileName = [[NSString alloc] initWithUTF8String:localLang.c_str()];
    NSString *plistPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:p_GrayNlangFileName];
    //NSLog(@"%@", plistPath);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *OurSDK_res = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"OurSDK_res.bundle"];
    if(![fileManager fileExistsAtPath:OurSDK_res]){
        GrayNcommon::GrayN_ConsoleLog(@"未添加OurSDK_res.bundle！");
        return false;
    }
    if(![fileManager fileExistsAtPath:plistPath]){
        GrayNcommon::GrayN_ConsoleLog(@"无法从Localiztion native development region中获取对应语言文件，默认启用Ourpalm_zh_CN.plist");
        plistPath = [[[NSBundle mainBundle] resourcePath]
                     stringByAppendingPathComponent:@"OurSDK_res.bundle/Language/Ourpalm_zh_CN.plist"];
    }

    p_GrayNlangDic = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
//    p_GrayNlangDicCN = [[NSMutableDictionary alloc] initWithContentsOfFile:[[[NSBundle mainBundle] resourcePath]
//                                                                     stringByAppendingPathComponent:@"OurSDK_res.bundle/Language/Ourpalm_zh_CN.plist"]];

    
    //    GrayNcommon::GrayN_DebugLog(@"%@",p_GrayNlangDic);
    
//    m_GrayN_InitBilling_Url = GrayNcommon::GrayNcommonGetLocalLang("InitBillingUrl");
//    m_GrayN_StatisticalUrl = GrayNcommon::GrayNcommonGetLocalLang("InitStatisticsUrl");
//    initUserCenterUrl = GrayNcommon::GrayNcommonGetLocalLang("InitUserUrl");
//    initHeartbeatUrl = GrayNcommon::GrayNcommonGetLocalLang("InitUserHeartbeatUrl");
//    // InitGscUrl
//    if (m_GrayN_InitBilling_Url.length() == 0 || m_GrayN_StatisticalUrl.length() == 0 ||
//        initUserCenterUrl.length() == 0 || initHeartbeatUrl.length() == 0) {
//        GrayNcommon::GrayN_ConsoleLog(@"OurSDK_res.bundle中没有初始化地址initBillingUrl、initStatisticalUrl、initUserCenterUrl、initHeartbeatUrl");
//        return false;
//    }

    m_GrayNcommonIsInit = true;
    return true;
}
bool GrayNcommon::GrayNcommonInitConfig()
{
    if (m_GrayNcommonIsInitConfig) {
        return true;
    }
    NSString *filePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"ourpalm.cfg"];
    NSString *text = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    if (text == nil) {
        GrayNcommon::GrayN_ConsoleLog(@"缺少配置文件ourpalm.cfg！");
        return false;
    }
    text = [text stringByReplacingOccurrencesOfString:@"\r\n" withString:@"\n"];
    text = [text stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    m_GrayN_SDK_Init_Url = GetStrByTextStr([text UTF8String], "initUrl");
    m_GrayN_StatisticalUrl = GetStrByTextStr([text UTF8String], "initStatisticsUrl");
    m_GrayN_ServiceId = GetStrByTextStr([text UTF8String], "serviceId");
    m_GrayN_ChannelId = GetStrByTextStr([text UTF8String], "channelId");
    m_GrayN_DeviceGroupId = GetStrByTextStr([text UTF8String], "deviceGroupId");
    m_GrayN_LocaleId = GetStrByTextStr([text UTF8String], "localeId");
    m_GrayN_Channel_Name = GetStrByTextStr([text UTF8String], "channelName");
    m_GrayN_OPID = GetStrByTextStr([text UTF8String], "opid");
    string pushUrl = GetStrByTextStr([text UTF8String], "initPushUrl");
    if (pushUrl != "") {
        GrayNcommon::m_GrayN_PushServerUrl = pushUrl;
    }
    
    // pCode = serviceId+channelId+deviceGroupId+localId
    m_GrayN_P_Code = "";
    m_GrayN_P_Code.append(m_GrayN_ServiceId);
    m_GrayN_P_Code.append(m_GrayN_ChannelId);
    m_GrayN_P_Code.append(m_GrayN_DeviceGroupId);
    m_GrayN_P_Code.append(m_GrayN_LocaleId);
    if (m_GrayN_SDK_Init_Url == "" || m_GrayN_ServiceId == "" || m_GrayN_ChannelId == "" ||
        m_GrayN_DeviceGroupId == "" || m_GrayN_LocaleId == "") {
        GrayNcommon::GrayN_ConsoleLog(@"配置文件ourpalm.cfg格式错误！无法获取initUrl、serviceId、channelId、deviceGroupId、localeId");
        return false;
    }
    
//    GrayNgetPushIdentity();

    m_GrayNcommonIsInitConfig = true;
    return true;
}
const char* GrayNcommon::GrayNcommonGetLocalLang(const char* GrayNkey)
{
    NSString* keyStr = [NSString stringWithUTF8String:GrayNkey];
    NSString* tmp = [p_GrayNlangDic objectForKey:keyStr];
    if (tmp == nil) {
        return GrayNkey;
    }
    return [tmp UTF8String];
}
//const char* GrayNcommon::LocalLangCN(const char* key)
//{
//    NSString* keyStr = [NSString stringWithUTF8String:key];
//    NSString* tmp = [p_GrayNlangDicCN objectForKey:keyStr];
//    if (tmp == nil) {
//        return key;
//    }
//    return [tmp UTF8String];
//}
string GrayNcommon::GrayNgetNetSourceInfo()
{
    if (m_GrayN_NetSource_Info != "") {
        return m_GrayN_NetSource_Info;
    }
//    SDK 网源信息为：
//    mac | idfa | deviceUniqueId | deviceName |
//    deviceSystemVersion |
//    deviceResolution |
//    deviceUdid |
//    deviceManufacturer |
//    deviceImsi |
//    devicePlatformId (0：安卓  1：IOS   2：wp8)|
//    sdkVersion |
//    gameVersion |
//    resVersion |
//    deviceImei | idfv
    m_GrayN_NetSource_Info.append(GetNetSourceStr(GrayNcommon::m_GrayN_MAC_Address));
    m_GrayN_NetSource_Info.append("|");
    m_GrayN_NetSource_Info.append(GetNetSourceStr(GrayNcommon::m_GrayN_IDFA));
    m_GrayN_NetSource_Info.append("|");
    m_GrayN_NetSource_Info.append(GetNetSourceStr(""));
    m_GrayN_NetSource_Info.append("|");
    m_GrayN_NetSource_Info.append(GetNetSourceStr(GrayNcommon::m_GrayN_Device_Model));
    m_GrayN_NetSource_Info.append("|");
    m_GrayN_NetSource_Info.append(GetNetSourceStr(GrayNcommon::m_GrayN_Device_OS_Version));
    m_GrayN_NetSource_Info.append("|");
    m_GrayN_NetSource_Info.append(GetNetSourceStr(GrayNcommon::m_GrayN_Screen_Resolution));
    m_GrayN_NetSource_Info.append("|");
    m_GrayN_NetSource_Info.append(GetNetSourceStr(GrayNcommon::m_GrayN_Open_UUID));
    m_GrayN_NetSource_Info.append("|");
    m_GrayN_NetSource_Info.append(GetNetSourceStr(""));
    m_GrayN_NetSource_Info.append("|");
    if (GrayNcommon::m_GrayNmobileCode.length() == 0) {
        m_GrayN_NetSource_Info.append(GetNetSourceStr(""));
    } else {
        m_GrayN_NetSource_Info.append(GetNetSourceStr(GrayNcommon::m_GrayNmobileCode));
    }
    m_GrayN_NetSource_Info.append("|");
    m_GrayN_NetSource_Info.append(GetNetSourceStr("1"));
    m_GrayN_NetSource_Info.append("|");
    // m_GrayN_NetSource_Info只用base版本号
    m_GrayN_NetSource_Info.append(GetNetSourceStr(GrayNcommon::m_GrayN_SDKVersion));
    m_GrayN_NetSource_Info.append("|");
    m_GrayN_NetSource_Info.append(GetNetSourceStr(GrayNcommon::m_GrayN_GameVersion));
    m_GrayN_NetSource_Info.append("|");
    m_GrayN_NetSource_Info.append(GetNetSourceStr(GrayNcommon::m_GrayN_GameResVersion));
    m_GrayN_NetSource_Info.append("|");
    m_GrayN_NetSource_Info.append(GetNetSourceStr(GrayNcommon::m_GrayN_IMEI));
    m_GrayN_NetSource_Info.append("|");
    m_GrayN_NetSource_Info.append(GetNetSourceStr(GrayNcommon::m_GrayN_IDFV));
    return m_GrayN_NetSource_Info;
}
const char* GrayNcommon::GrayNget_ChannelInfo()
{
    GrayN_JSON::Value channelInfoJson;
    channelInfoJson["serviceId"] = GrayN_JSON::Value(m_GrayN_ServiceId.c_str());
    channelInfoJson["channelId"] = GrayN_JSON::Value(m_GrayN_ChannelId.c_str());
    channelInfoJson["deviceGroupId"] = GrayN_JSON::Value(m_GrayN_DeviceGroupId.c_str());
    channelInfoJson["localeId"] = GrayN_JSON::Value(m_GrayN_LocaleId.c_str());
    channelInfoJson["channelName"] = GrayN_JSON::Value(m_GrayN_Channel_Name.c_str());
    channelInfoJson["MAC"] = GrayN_JSON::Value(m_GrayN_MAC_Address.c_str());
    channelInfoJson["IDFA"] = GrayN_JSON::Value(m_GrayN_IDFA.c_str());
    
    GrayN_JSON::FastWriter fw_channelInfo;
    
    m_GrayNchannel_Info = fw_channelInfo.write(channelInfoJson);
    return m_GrayNchannel_Info.c_str();
}
// TODO: 数字转字符串
string GrayNcommon::GrayNcommonIntegerToString(int GrayNdata)
{
    stringstream ss;
    string tmp;
    ss<<GrayNdata;
    ss>>tmp;
    return tmp.c_str();
}
string GrayNcommon::GrayNcommonLongToString(long long GrayNdata)
{
    std::string timeStr;
    std::stringstream s;
    s<<GrayNdata;
    s>>timeStr;
    return timeStr;
}
// TODO: 分割字符串
int GrayNcommon::GrayNsplitString(string& GrayNprefix, string & GrayNstrSrc, string& GrayNstrDelims, vector<string>& GrayNstrDest)
{
    typedef string::size_type ST;
    string delims = GrayNstrDelims;
    string STR;
    if(delims.empty()) delims = "/n/r";
    
    ST pos=0, LEN = GrayNstrSrc.size();
    while(pos < LEN){
        STR="";
        while( (delims.find(GrayNstrSrc[pos]) != string::npos) && (pos < LEN) ) ++pos;
        if(pos==LEN) return (int)GrayNstrDest.size();
        while( (delims.find(GrayNstrSrc[pos]) == string::npos) && (pos < LEN) ) STR += GrayNstrSrc[pos++];
        if( ! STR.empty() ) {
            string content = GrayNprefix;
            GrayNstrDest.push_back(content.append(STR));
        }
    }
    return (int)GrayNstrDest.size();
}

string GrayNcommon::GrayNgetCurrentDeviceLang()
{
    NSString* tmp = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDevelopmentRegion"];
    if (tmp == nil) {
        m_GrayNcurLanguage = "zh_CN";
    } else {
        m_GrayNcurLanguage = [tmp UTF8String];
    }
    return m_GrayNcurLanguage;
}

char mDeviceID[64]={0};
void mMacaddress(){
    
    int                 mib[6];
    size_t              len;
    char                *buf;
    unsigned char       *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl  *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        return;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        return ;
    }
    
    if ((buf = (char*)malloc(len)) == NULL) {
        return ;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        free(buf);
        return ;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    snprintf(mDeviceID, 64, "%02X%02X%02X%02X%02X%02X",*ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5));
    free(buf);
}
void GrayNcommon::GrayNstringReplace(string& original, const string& replaceStr,const string& replacedStr)
{
    string::size_type pos=0;
    string::size_type a=replaceStr.size();
    string::size_type b=replacedStr.size();
    while((pos=original.find(replaceStr,pos))!=string::npos)
    {
        original.replace(pos,a,replacedStr);
        pos+=b;
    }
}
string GrayNcommon::GrayN_Encode_Base64_UrlEncode(const char* data)
{
    if (data == NULL) {
        return "";
    }
    string baseEncode;
    GrayN_Base64_GrayN::GrayN_Base64Encode((unsigned const char*)data, strlen(data), baseEncode);
    string strEncode;
    GrayN_UrlEncode_GrayN::GrayN_Url_Encode(baseEncode, strEncode);
    return strEncode;
}
void GrayNcommon::GrayNdesEncryptKey(const char* GrayNcontent, const char* GrayNkey, string& GrayNresult)
{
    string keystr(GrayNkey);
    string in(GrayNcontent);
    
    GrayN_Des_GrayN::GrayN_DesEncrypt(in, keystr, GrayNresult);
}

void GrayNcommon::GrayNcreateSecretKey()
{
    char* temp = new char[9];
    srand((unsigned) time(NULL));
    for (int i = 0; i < 8; i ++) {
        temp[i] = m_GrayNkeyItem[rand()%36];
    }
    temp[8] = '\0';
    m_GrayN_SecretKey = temp;
    if (temp) {
        delete[] temp;
        temp = NULL;
    }
}
id GrayNcommon::GrayNgetDebugView()
{
    return p_GrayN_DebugView;
}


#pragma mark- 控制台日志输出
/*ObjC*/
void GrayNcommon::GrayN_DebugLog(id GrayNlogs, ...)
{
    if (!GrayNlogs)
    return;
#ifndef DEBUG
    if (!m_GrayNdebug_Mode)
    return;
#endif
    
    @autoreleasepool {
        va_list arglist;
        va_start(arglist, GrayNlogs);
        
        NSString *ocStr = GrayNlogs;
        if (ocStr == nil) {
            dispatch_async(p_GrayNconsoleLogQueue, ^{
                NSLog(@"GrayN LOG:\n传入的字符串为nil\n ");
            });
            return;
        }
        
        NSString *outStr = [[[NSString alloc] initWithFormat:GrayNlogs arguments:arglist] autorelease];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (m_GrayNforceDebug_Mode) {
                p_GrayN_DebugView.m_GrayN_DebugTextView.text = [NSString stringWithFormat:@"%@\n%@", p_GrayN_DebugView.m_GrayN_DebugTextView.text, outStr];
            }
        });
        dispatch_async(p_GrayNdebugLogQueue, ^{
            NSLog(@"GrayN DEBUGLOG:\n%@\n ", outStr);
            
        });
        va_end(arglist);
    }
}
void GrayNcommon::GrayN_ConsoleLog(id GrayNlogs, ...)
{
    if (!GrayNlogs) return;
    
    @autoreleasepool {
        va_list arglist;
        va_start(arglist, GrayNlogs);
       
        NSString *ocStr = GrayNlogs;
        if (ocStr == nil) {
            dispatch_async(p_GrayNconsoleLogQueue, ^{
                NSLog(@"GrayN LOG:\n传入的字符串为nil\n ");
            });
            return;
        }
        
        NSString *outStr = [[[NSString alloc] initWithFormat:GrayNlogs arguments:arglist] autorelease];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (m_GrayNforceDebug_Mode) {
                p_GrayN_DebugView.m_GrayN_DebugTextView.text = [NSString stringWithFormat:@"%@\n%@", p_GrayN_DebugView.m_GrayN_DebugTextView.text, outStr];
            }
        });
        dispatch_async(p_GrayNconsoleLogQueue, ^{
            NSLog(@"GrayN LOG:\n%@\n ", outStr);
        });
        va_end(arglist);
    }
}
/*c 不支持中文输出*/
void GrayNcommon::GrayN_DebugLog(const char* GrayNlogs, ...)
{
    if (!GrayNlogs)
    return;
#ifndef DEBUG
    if (!m_GrayNdebug_Mode)
    return;
#endif
    @autoreleasepool {
        va_list arglist;
        va_start(arglist, GrayNlogs);
        
        NSString *ocStr = [NSString stringWithCString:GrayNlogs encoding:NSUTF8StringEncoding ];
        if (ocStr == nil) {
            dispatch_async(p_GrayNconsoleLogQueue, ^{
                NSLog(@"GrayN LOG:\n传入的字符串为nil\n ");
            });
            return;
        }
        NSString *outStr = [[[NSString alloc] initWithFormat:ocStr arguments:arglist] autorelease];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (m_GrayNforceDebug_Mode) {
                p_GrayN_DebugView.m_GrayN_DebugTextView.text = [NSString stringWithFormat:@"%@\n%@", p_GrayN_DebugView.m_GrayN_DebugTextView.text, outStr];
            }
        });
        dispatch_async(p_GrayNdebugLogQueue, ^{
            NSLog(@"GrayN DEBUGLOG:\n%@\n ", outStr);
        });
        va_end(arglist);

    }
}
void GrayNcommon::GrayN_ConsoleLog(const char* GrayNlogs, ...)
{
    if (!GrayNlogs) return;
    @autoreleasepool {
        va_list arglist;
        va_start(arglist, GrayNlogs);
        
        NSString *ocStr = [NSString stringWithCString:GrayNlogs encoding:NSUTF8StringEncoding];
        if (ocStr == nil) {
            dispatch_async(p_GrayNconsoleLogQueue, ^{
                NSLog(@"GrayN LOG:\n传入的字符串为nil\n ");
            });
            return;
        }
        NSString *outStr = [[[NSString alloc] initWithFormat:ocStr arguments:arglist] autorelease];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (m_GrayNforceDebug_Mode) {
                p_GrayN_DebugView.m_GrayN_DebugTextView.text = [NSString stringWithFormat:@"%@\n%@", p_GrayN_DebugView.m_GrayN_DebugTextView.text, outStr];
            }
        });
        dispatch_async(p_GrayNconsoleLogQueue, ^{
            NSLog(@"GrayN LOG:\n%@\n ", outStr);
        });
        va_end(arglist);

    }
}
#pragma mark- 用户信息
void GrayNcommon::GrayNclearUserLocalData()
{
    m_GrayN_Game_UserId.clear();
    m_GrayN_Game_UserName.clear();
    m_GrayN_Game_PalmId.clear();
    //数据的清理，一定要注意，初始化获取的参数不可以清空，例如：gameversion，切记
    m_GrayN_Game_RoleId.clear();
    m_GrayN_Game_RoleName.clear();
    m_GrayN_Game_ServerId.clear();
    m_GrayN_Game_RoleLevel.clear();
    m_GrayN_Game_RoleVipLevel.clear();
    m_GrayN_Game_ServerName.clear();
    
}
#pragma mark- 统计
string GrayNcommon::GrayNgetLocal_StatisticalUrl()
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *statisticalUrl = [userDefaults objectForKey:@"OPStatisticalUrl"];
    if (statisticalUrl == nil || [statisticalUrl isEqualToString:@""]) {
        statisticalUrl = [NSString stringWithUTF8String:m_GrayN_StatisticalUrl.c_str()];
    }
    GrayNcommon::GrayN_DebugLog(@"OPLocalStatisticalUrl=%@", statisticalUrl);
    return [statisticalUrl UTF8String];
}
void GrayNcommon::GrayNsetLocal_StatisticalUrl(string GrayNurl)
{
    if (GrayNurl.c_str() == NULL || GrayNurl == "") {
        return;
    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[NSString stringWithUTF8String:GrayNurl.c_str()] forKey:@"OPStatisticalUrl"];
    [userDefaults synchronize];
}
#pragma mark- 时间
long long GrayNcommon::GrayNgetCurrent_TimeStamp()
{
    struct timeval tv;
    gettimeofday(&tv, NULL);
    return (long long)tv.tv_sec*1000+tv.tv_usec/1000;
}
string GrayNcommon::GrayNgetCurrent_DateAndTime()
{
    time_t timer;
    time(&timer);
    tm* t_tm = localtime(&timer);
    
    string dateAndTime = "";
    string tmp = GrayNcommonIntegerToString(t_tm->tm_year+1900);
    dateAndTime.append(tmp);
    dateAndTime.append("-");
    tmp.clear();
    tmp = GrayNcommonIntegerToString(t_tm->tm_mon+1);
    if (tmp.length() == 1) {
        dateAndTime.append("0");
    }
    dateAndTime.append(tmp);
    tmp.clear();
    tmp = GrayNcommonIntegerToString(t_tm->tm_mday);
    dateAndTime.append("-");
    if (tmp.length() == 1) {
        dateAndTime.append("0");
    }
    dateAndTime.append(tmp);
    tmp.clear();
    tmp = GrayNcommonIntegerToString(t_tm->tm_hour);
    
    dateAndTime.append(" ");
    if (tmp.length() == 1) {
        dateAndTime.append("0");
    }
    dateAndTime.append(tmp);
    tmp.clear();
    tmp = GrayNcommonIntegerToString(t_tm->tm_min);
    dateAndTime.append(":");
    if (tmp.length() == 1) {
        dateAndTime.append("0");
    }
    
    dateAndTime.append(tmp);
    tmp.clear();
    tmp = GrayNcommonIntegerToString(t_tm->tm_sec);
    dateAndTime.append(":");
    if (tmp.length() == 1) {
        dateAndTime.append("0");
    }
    dateAndTime.append(tmp);
    tmp.clear();
    //    cout<<dateAndTime<<endl;
    return dateAndTime.c_str();
}
string GrayNcommon::GrayNgetCurrent_TimeString()
{
    stringstream ss;
    ss << GrayNgetCurrent_TimeStamp();
    return ss.str().c_str();
}
string GrayNcommon::GrayNgetCurrent_MilTimeString()
{
    struct timeval t;
    gettimeofday(&t, NULL);
    struct tm * t_tm=localtime(&t.tv_sec);
    if(t_tm==NULL)
    {
        return "";
    }
    
    string dateAndTime;
    string tmp = GrayNcommonIntegerToString(t_tm->tm_year+1900);
    dateAndTime.append(tmp);
    tmp.clear();
    tmp = GrayNcommonIntegerToString(t_tm->tm_mon+1);
    if (tmp.length() == 1) {
        dateAndTime.append("0");
    }
    dateAndTime.append(tmp);
    tmp.clear();
    tmp = GrayNcommonIntegerToString(t_tm->tm_mday);
    if (tmp.length() == 1) {
        dateAndTime.append("0");
    }
    dateAndTime.append(tmp);
    tmp.clear();
    tmp = GrayNcommonIntegerToString(t_tm->tm_hour);
    if (tmp.length() == 1) {
        dateAndTime.append("0");
    }
    dateAndTime.append(tmp);
    tmp.clear();
    tmp = GrayNcommonIntegerToString(t_tm->tm_min);
    if (tmp.length() == 1) {
        dateAndTime.append("0");
    }
    dateAndTime.append(tmp);
    tmp.clear();
    tmp = GrayNcommonIntegerToString(t_tm->tm_sec);
    if (tmp.length() == 1) {
        dateAndTime.append("0");
    }
    dateAndTime.append(tmp);
    tmp.clear();
    tmp = GrayNcommonIntegerToString(t.tv_usec/1000);
    for (int i=3-(int)tmp.length(); i>0; i--) {
        dateAndTime.append("0");
    }
    dateAndTime.append(tmp);
    return dateAndTime.c_str();
}
#pragma mark- 检测网络
id GrayNcommon::GrayNgetHttpsHeader()
{
    if (p_GrayN_HeaderDic == nil) {
        p_GrayN_HeaderDic = [[NSMutableDictionary alloc] init];
    }
    //静态头信息
    [p_GrayN_HeaderDic setValue:[NSString stringWithUTF8String:GrayNcommon::m_GrayN_Oua.c_str()] forKey:@"oUa"];
    [p_GrayN_HeaderDic setValue:[NSString stringWithUTF8String:GrayNcommon::m_GrayN_AllVersion.c_str()] forKey:@"version"];
    [p_GrayN_HeaderDic setValue:[NSString stringWithUTF8String:GrayNcommon::m_GrayN_ServiceId.c_str()] forKey:@"oService"];
    [p_GrayN_HeaderDic setValue:[NSString stringWithUTF8String:GrayNcommon::m_GrayN_ChannelId.c_str()] forKey:@"oChannel"];
    [p_GrayN_HeaderDic setValue:[NSString stringWithUTF8String:GrayNcommon::m_GrayN_DeviceInfo.c_str()] forKey:@"device"];
    [p_GrayN_HeaderDic setValue:[NSString stringWithUTF8String:GrayNcommon::m_GrayN_DeviceGroupId.c_str()] forKey:@"deviceGroupId"];
    [p_GrayN_HeaderDic setValue:[NSString stringWithUTF8String:GrayNcommon::m_GrayN_LocaleId.c_str()] forKey:@"localeId"];
    [p_GrayN_HeaderDic setValue:[NSString stringWithUTF8String:GrayNcommon::m_GrayN_IDFA.c_str()] forKey:@"deviceUniqueID"];
    [p_GrayN_HeaderDic setValue:[NSString stringWithUTF8String:GrayNcommon::m_GrayN_IDFV.c_str()] forKey:@"deviceIDFV"];
    [p_GrayN_HeaderDic setValue:[NSString stringWithUTF8String:GrayNcommon::m_GrayN_CpuInfo.c_str()] forKey:@"cpuInfo"];
    
    [p_GrayN_HeaderDic setValue:@"2.0" forKey:@"validLogVersion"];
    /*5.2.1*/
    [p_GrayN_HeaderDic setValue:@"1" forKey:@"nfbd"];
    
    // 动态头信息
    const char *tUserId = GrayNcommon::GrayNcommon::m_GrayN_Game_UserId.c_str();
    string temp;
    if (strlen(tUserId) == 0) {
        temp = "0";
    }else{
        temp = GrayNcommon::GrayN_Encode_Base64_UrlEncode(tUserId);
    }
    [p_GrayN_HeaderDic setValue:[NSString stringWithUTF8String:temp.c_str()] forKey:@"oUser"];
    
    const char *tToken =  GrayNcommon::m_GrayN_SessionId.c_str();
    if (strlen(tToken) == 0) {
        temp = "0";
    } else {
        temp = GrayNcommon::GrayN_Encode_Base64_UrlEncode(tToken);
    }
    [p_GrayN_HeaderDic setValue:[NSString stringWithUTF8String:temp.c_str()] forKey:@"oToken"];
    
    if (GrayNcommon::m_GrayN_Game_RoleId.length() == 0) {
        temp = "0";
    } else {
        temp = GrayNcommon::m_GrayN_Game_RoleId;
    }
    [p_GrayN_HeaderDic setValue:[NSString stringWithUTF8String:temp.c_str()] forKey:@"oRole"];
    
    if (GrayNcommon::m_GrayN_Game_ServerId.length() == 0) {
        temp = "0";
    } else {
        temp = GrayNcommon::m_GrayN_Game_ServerId;
    }
    [p_GrayN_HeaderDic setValue:[NSString stringWithUTF8String:temp.c_str()] forKey:@"oServer"];
    
    if (GrayNcommon::m_GrayN_ActionId.length() == 0) {
        temp = "0";
    } else {
        temp = GrayNcommon::m_GrayN_ActionId;
    }
    [p_GrayN_HeaderDic setValue:[NSString stringWithUTF8String:temp.c_str()] forKey:@"actionId"];
    
    [p_GrayN_HeaderDic setValue:[NSString stringWithUTF8String:GrayNcommon::m_GrayN_GameType.c_str()] forKey:@"gameType"];
    
    string networkType = GrayNcommon::m_GrayNnetworkTypeNum;
    if (networkType.length() == 0) {
        temp = "0";
    } else {
        temp = networkType;
    }
    [p_GrayN_HeaderDic setValue:[NSString stringWithUTF8String:temp.c_str()] forKey:@"workNetType"];
    
    if (GrayNcommon::m_GrayNnetworkSubType.length() == 0) {
        temp = "0";
    } else {
        temp = GrayNcommon::m_GrayNnetworkSubType;
    }
    [p_GrayN_HeaderDic setValue:[NSString stringWithUTF8String:temp.c_str()] forKey:@"networkSubType"];
    
    if (GrayNcommon::m_GrayN_Game_PhoneNum == "") {
        temp = "0";
    } else {
        temp = GrayNcommon::GrayN_Encode_Base64_UrlEncode(GrayNcommon::m_GrayN_Game_PhoneNum.c_str());
    }
    [p_GrayN_HeaderDic setValue:[NSString stringWithUTF8String:temp.c_str()] forKey:@"userPhone"];
    
    if (GrayNcommon::m_GrayN_Game_Email == "") {
        temp = "0";
    } else {
        temp = GrayNcommon::GrayN_Encode_Base64_UrlEncode(GrayNcommon::m_GrayN_Game_Email.c_str());
    }
    [p_GrayN_HeaderDic setValue:[NSString stringWithUTF8String:temp.c_str()] forKey:@"userEmail"];
    
    [p_GrayN_HeaderDic setValue:@"0" forKey:@"advertising_id"];
    [p_GrayN_HeaderDic setValue:@"0" forKey:@"deviceAndroidId"];
    
    
    if (GrayNcommon::m_GrayN_Game_UserName == "") {
        temp = "0";
    }else{
        temp = GrayNcommon::GrayN_Encode_Base64_UrlEncode(GrayNcommon::m_GrayN_Game_UserName.c_str());
    }
    [p_GrayN_HeaderDic setValue:[NSString stringWithUTF8String:temp.c_str()] forKey:@"userName"];
    
    /*5.1.1*/
    [p_GrayN_HeaderDic setValue:[NSString stringWithUTF8String:GrayNcommon::m_GrayNrealTimeIDFA.c_str()] forKey:@"realTimeIDFA"];
    [p_GrayN_HeaderDic setValue:[NSString stringWithUTF8String:GrayNcommon::m_GrayNrealTimeIDFV.c_str()] forKey:@"realTimeIDFV"];
    /*5.1.2*/
    [p_GrayN_HeaderDic setValue:[NSString stringWithUTF8String:GrayNcommon::m_GrayN_BundleId.c_str()] forKey:@"bundleId"];
    /*5.1.4*/
    [p_GrayN_HeaderDic setValue:@"" forKey:@"apkMd5"];
    
    /*5.2.5*/
    [p_GrayN_HeaderDic setValue:[NSString stringWithUTF8String:GrayNcommon::m_GrayN_SessionId.c_str()] forKey:@"sessionId"];

    return p_GrayN_HeaderDic;
}

void GrayNcommon::GrayNgetHttpDynamicHeader(string & GrayNheader)
{
    GrayNheader.append("oUser:");
    const char *tUserId = GrayNcommon::GrayNcommon::m_GrayN_Game_UserId.c_str();
    if (strlen(tUserId) == 0) {
        GrayNheader.append("0");
    } else {
        string dataEncode = GrayN_Encode_Base64_UrlEncode(tUserId);
        GrayNheader.append(dataEncode);
    }
    GrayNheader.append("\r\n");
    
    GrayNheader.append("oToken:");
    const char *tToken = GrayNcommon::m_GrayN_SessionId.c_str();
    if (strlen(tToken) == 0) {
        GrayNheader.append("0");
    }else{
        string dataEncode = GrayN_Encode_Base64_UrlEncode(tToken);
        GrayNheader.append(dataEncode);
    }
    GrayNheader.append("\r\n");
    
    GrayNheader.append("oRole:");
    if (m_GrayN_Game_RoleId.length() == 0) {
        GrayNheader.append("0");
    }else{
        GrayNheader.append(m_GrayN_Game_RoleId);
    }
    GrayNheader.append("\r\n");
    
    GrayNheader.append("oServer:");
    if (m_GrayN_Game_ServerId.length() == 0) {
        GrayNheader.append("0");
    }else{
        GrayNheader.append(m_GrayN_Game_ServerId);
    }
    GrayNheader.append("\r\n");
    
    GrayNheader.append("userPhone:");
    if (GrayNcommon::m_GrayN_Game_PhoneNum == "") {
        GrayNheader.append("0");
    }else{
        string dataEncode = GrayN_Encode_Base64_UrlEncode(GrayNcommon::m_GrayN_Game_PhoneNum.c_str());
        GrayNheader.append(dataEncode);
    }
    GrayNheader.append("\r\n");
    
    GrayNheader.append("userEmail:");
    if (GrayNcommon::m_GrayN_Game_Email == "") {
        GrayNheader.append("0");
    }else{
        string dataEncode = GrayN_Encode_Base64_UrlEncode(GrayNcommon::m_GrayN_Game_Email.c_str());
        GrayNheader.append(dataEncode);
    }
    GrayNheader.append("\r\n");

    GrayNheader.append("userName:");
    if (GrayNcommon::m_GrayN_Game_UserName == "") {
        GrayNheader.append("0");
    } else{
        string dataEncode = GrayN_Encode_Base64_UrlEncode(GrayNcommon::m_GrayN_Game_UserName.c_str());
        GrayNheader.append(dataEncode);
    }
    GrayNheader.append("\r\n");
    
    GrayNheader.append("networkSubType:");
    if (GrayNcommon::m_GrayNnetworkSubType.length() == 0) {
        GrayNheader.append("0");
    } else {
        GrayNheader.append(GrayNcommon::m_GrayNnetworkSubType);
    }
    GrayNheader.append("\r\n");
    
    GrayNheader.append("workNetType:");
    if (GrayNcommon::m_GrayNnetworkTypeNum.length() == 0) {
        GrayNheader.append("0");
    } else {
        GrayNheader.append(GrayNcommon::m_GrayNnetworkTypeNum);
    }
    GrayNheader.append("\r\n");
    
    GrayNheader.append("sessionId:");
    if (GrayNcommon::m_GrayN_SessionId.length() == 0) {
        GrayNheader.append("0");
    } else {
        GrayNheader.append(GrayNcommon::m_GrayN_SessionId);
    }
    GrayNheader.append("\r\n");
}

void GrayNcommon::GrayNgetHttpStaticHeader()
{
    //设备信息
    //平台ID/设备名称/设备系统版本/设备分辨率(宽*高)/设备UDID/手机卡IMSI/手机号/厂商
    m_GrayN_Oua.clear();
    m_GrayN_Oua.append("1");
    m_GrayN_Oua.append(TAG);
    m_GrayN_Oua.append(GrayNcommon::m_GrayN_Device_Model);    //设备名称
    m_GrayN_Oua.append(TAG);
    m_GrayN_Oua.append(GrayNcommon::m_GrayN_OS_Version);
    m_GrayN_Oua.append(TAG);
    m_GrayN_Oua.append(GrayNcommon::m_GrayN_Screen_Resolution);
    m_GrayN_Oua.append(TAG);
    m_GrayN_Oua.append("0");
    m_GrayN_Oua.append(TAG);
    if (GrayNcommon::m_GrayNmobileCode.length() == 0) {         //获得SIM卡网络运营商名称
        m_GrayN_Oua.append("0");
    }else{
        m_GrayN_Oua.append(GrayNcommon::m_GrayNmobileCode);
    }
    m_GrayN_Oua.append(TAG);
    m_GrayN_Oua.append("0");                         //手机号
    m_GrayN_Oua.append(TAG);
    m_GrayN_Oua.append("apple");                     //厂商
    
    //版本信息
    //SDK版本ID/游戏版本ID/游戏资源版本ID
    m_GrayN_AllVersion.clear();
    m_GrayN_AllVersion.append(GrayNcommon::m_GrayN_SDKVersion);
    
    m_GrayN_AllVersion.append(TAG);
    m_GrayN_AllVersion.append(GrayNcommon::m_GrayN_GameVersion);
    m_GrayN_AllVersion.append(TAG);
    if (GrayNcommon::m_GrayN_GameResVersion.length() == 0) {
        m_GrayN_AllVersion.append("0");
    } else {
        m_GrayN_AllVersion.append(GrayNcommon::m_GrayN_GameResVersion);
    }
    
    m_GrayN_DeviceInfo.clear();
    if (GrayNcommon::m_GrayN_MAC_Address.length() == 0) {
        m_GrayN_DeviceInfo.append("0");
    }else{
        m_GrayN_DeviceInfo.append(GrayNcommon::m_GrayN_MAC_Address);
    }
    m_GrayN_DeviceInfo.append(TAG);
    if (GrayNcommon::m_GrayN_IDFA.length() == 0) {
        m_GrayN_DeviceInfo.append("0");
    }else{
        m_GrayN_DeviceInfo.append(GrayNcommon::m_GrayN_IDFA);
    }
    m_GrayN_DeviceInfo.append(TAG);
    if (GrayNcommon::m_GrayN_Device_UniqueId.length() == 0) {
        m_GrayN_DeviceInfo.append("0");
    }else{
        m_GrayN_DeviceInfo.append(GrayNcommon::m_GrayN_Device_UniqueId);
    }
    
    
    m_GrayN_DeviceJson["mac"]=GrayNcommon::m_GrayN_MAC_Address;
    m_GrayN_DeviceJson["idfa"]=GrayNcommon::m_GrayN_IDFA;
    m_GrayN_DeviceJson["deviceUniqueId"]=GrayNcommon::m_GrayN_Device_UniqueId;
    m_GrayN_DeviceJson["phoneNum"]=GrayNcommon::m_GrayN_Game_PhoneNum;
    
    m_GrayN_HttpStaticHeader.clear();
    m_GrayN_HttpStaticHeader.append("oUa:");
    m_GrayN_HttpStaticHeader.append(m_GrayN_Oua);
    m_GrayN_HttpStaticHeader.append("\r\n");
    m_GrayN_HttpStaticHeader.append("version:");
    m_GrayN_HttpStaticHeader.append(m_GrayN_AllVersion);
    m_GrayN_HttpStaticHeader.append("\r\n");
    m_GrayN_HttpStaticHeader.append("oService:");
    m_GrayN_HttpStaticHeader.append(m_GrayN_ServiceId);
    m_GrayN_HttpStaticHeader.append("\r\n");
    m_GrayN_HttpStaticHeader.append("oChannel:");
    m_GrayN_HttpStaticHeader.append(m_GrayN_ChannelId);
    m_GrayN_HttpStaticHeader.append("\r\n");
    m_GrayN_HttpStaticHeader.append("device:");
    m_GrayN_HttpStaticHeader.append(m_GrayN_DeviceInfo);
    m_GrayN_HttpStaticHeader.append("\r\n");
    m_GrayN_HttpStaticHeader.append("deviceGroupId:");
    m_GrayN_HttpStaticHeader.append(m_GrayN_DeviceGroupId);
    m_GrayN_HttpStaticHeader.append("\r\n");
    m_GrayN_HttpStaticHeader.append("localeId:");
    m_GrayN_HttpStaticHeader.append(m_GrayN_LocaleId);
    m_GrayN_HttpStaticHeader.append("\r\n");
    m_GrayN_HttpStaticHeader.append("deviceUniqueID:");
    m_GrayN_HttpStaticHeader.append(GrayNcommon::m_GrayN_IDFA);
    m_GrayN_HttpStaticHeader.append("\r\n");
    m_GrayN_HttpStaticHeader.append("deviceIDFV:");
    m_GrayN_HttpStaticHeader.append(GrayNcommon::m_GrayN_IDFV);
    m_GrayN_HttpStaticHeader.append("\r\n");
    // 5.0.10 cpuInfo
    m_GrayN_HttpStaticHeader.append("cpuInfo:");
    m_GrayN_HttpStaticHeader.append(GrayNcommon::m_GrayN_CpuInfo);
    m_GrayN_HttpStaticHeader.append("\r\n");
    m_GrayN_HttpStaticHeader.append("deviceAndroidId:");
    m_GrayN_HttpStaticHeader.append("0");
    m_GrayN_HttpStaticHeader.append("\r\n");
    m_GrayN_HttpStaticHeader.append("advertising_id:");
    m_GrayN_HttpStaticHeader.append("0");
    m_GrayN_HttpStaticHeader.append("\r\n");
    m_GrayN_HttpStaticHeader.append("actionId:");
    if (m_GrayN_ActionId.length() == 0) {
        m_GrayN_HttpStaticHeader.append("0");
    } else {
        m_GrayN_HttpStaticHeader.append(m_GrayN_ActionId);
    }
    m_GrayN_HttpStaticHeader.append("\r\n");
    
    m_GrayN_HttpStaticHeader.append("gameType:");
    m_GrayN_HttpStaticHeader.append(GrayNcommon::m_GrayN_GameType);
    m_GrayN_HttpStaticHeader.append("\r\n");
    //日志标识，用于兼容日志部分
    m_GrayN_HttpStaticHeader.append("validLogVersion:2.0");
    m_GrayN_HttpStaticHeader.append("\r\n");
    // 5.1.1
    m_GrayN_HttpStaticHeader.append("realTimeIDFA:");
    m_GrayN_HttpStaticHeader.append(GrayNcommon::m_GrayNrealTimeIDFA);
    m_GrayN_HttpStaticHeader.append("\r\n");
    
    m_GrayN_HttpStaticHeader.append("realTimeIDFV:");
    m_GrayN_HttpStaticHeader.append(GrayNcommon::m_GrayNrealTimeIDFV);
    m_GrayN_HttpStaticHeader.append("\r\n");
    
    /*5.1.2*/
    m_GrayN_HttpStaticHeader.append("bundleId:");
    m_GrayN_HttpStaticHeader.append(GrayNcommon::m_GrayN_BundleId);
    m_GrayN_HttpStaticHeader.append("\r\n");
    
    /*5.1.4*/
    m_GrayN_HttpStaticHeader.append("apkMd5:");
    m_GrayN_HttpStaticHeader.append("");
    m_GrayN_HttpStaticHeader.append("\r\n");
    
    /*5.2.1*/
    m_GrayN_HttpStaticHeader.append("nfbd:");
    m_GrayN_HttpStaticHeader.append("1");
    m_GrayN_HttpStaticHeader.append("\r\n");
    
    GrayNcommon::GrayN_DebugLog("opHttpStaticHeader\n\n%s",m_GrayN_HttpStaticHeader.c_str());
}

void GrayNcommon::GrayNcheckNetworkType()
{
    m_GrayNnetworkSubType = "";
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    GrayN_ReachabilityNetworkStatus status = [[GrayN_Reachability GrayNreachabilityForInternetConnection] GrayNcurrentReachabilityStatus];
    string networkLog = "opCurrentNetwork:networkType=";
    switch (status) {
            case k_GrayN_ReachableViaWiFi:
            m_GrayNnetworkType = "WIFI";
            m_GrayNnetworkTypeNum= "1";
            break;
            case k_GrayN_NotReachable:
            m_GrayNnetworkType = "";
            m_GrayNnetworkTypeNum= "0";
            break;
            case k_GrayN_ReachableVia2G:
            m_GrayNnetworkType = "2G";
            m_GrayNnetworkTypeNum= "2";
            GrayNcheckNetworkSubType();
            break;
            case k_GrayN_ReachableVia3G:
            m_GrayNnetworkType = "3G";
            m_GrayNnetworkTypeNum= "2";
            GrayNcheckNetworkSubType();
            break;
            case k_GrayN_ReachableVia4G:
            m_GrayNnetworkType = "4G";
            m_GrayNnetworkTypeNum= "2";
            GrayNcheckNetworkSubType();
            break;
        default:
            m_GrayNnetworkType = "WWAN";
            m_GrayNnetworkTypeNum= "0";
            break;
    }
    networkLog.append(m_GrayNnetworkType);
    networkLog.append(", networkSubType=");
    networkLog.append(m_GrayNnetworkSubType);
    
    GrayNcommon::GrayN_DebugLog(networkLog.c_str());
    
    [pool release];
}

void GrayNcommon::GrayNcheckNetworkSubType()
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        CTTelephonyNetworkInfo *info = [GrayNcommon_oc shared_GrayN_NetworkInstance];
        NSString *currentRadioAccessTechnology = info.currentRadioAccessTechnology;
        if (currentRadioAccessTechnology == nil) {
            currentRadioAccessTechnology = @"";
        }
        m_GrayNnetworkSubType = [currentRadioAccessTechnology UTF8String];
    } else {
        m_GrayNnetworkSubType = "";
    }
    [pool release];
}
string GrayNcommon::GrayN_DNSParse(const char* hostName)
{
    if (hostName == NULL) {
        return "";
    }
    string ip;
#ifndef SDK_IPV6
    NSString *hostnameStr = [NSString stringWithUTF8String:hostName];
    Boolean result;
    CFHostRef hostRef;
    CFArrayRef addresses = NULL;
    NSString *ipAddress = @"";
    hostRef = CFHostCreateWithName(kCFAllocatorDefault, (__bridge CFStringRef)hostnameStr);
    if (hostRef) {
        result = CFHostStartInfoResolution(hostRef, kCFHostAddresses, NULL); // pass an error instead of NULL here to find out why it failed
        if (result == TRUE) {
            addresses = CFHostGetAddressing(hostRef, &result);
        }
    }
    if (result == TRUE) {
        CFIndex index = 0;
        CFDataRef ref = (CFDataRef) CFArrayGetValueAtIndex(addresses, index);
        struct sockaddr_in* remoteAddr;
        char *ip_address;
        remoteAddr = (struct sockaddr_in*) CFDataGetBytePtr(ref);
        if (remoteAddr != NULL) {
            ip_address = inet_ntoa(remoteAddr->sin_addr);
        }
        ipAddress = [NSString stringWithCString:ip_address encoding:NSUTF8StringEncoding];
    }
    if (ipAddress && ipAddress.length > 0) {
        ip = [ipAddress UTF8String];
    }else{
#ifdef SDK_APPSTORETW
        if ([hostnameStr isEqualToString:@"auth.hk.gamesbean.net"]) {
            ip = "112.73.10.131";      //默认地址
        }
#elif SDK_JAPAN
        if ([hostnameStr isEqualToString:@"authjp.gamesbean.net"]) {
            ip = "172.31.17.172";      //默认地址
        }
#else
        if ([hostnameStr isEqualToString:@"auth.gamebean.net"]) {
            ip = "223.202.94.226";      //默认地址
        }
#endif
    }
#endif
    return ip;
}
#pragma mark- 内部方法
bool GrayNcommon::GrayNisJail_Break()
{
    bool jailbroken = false;
    NSString *cydiaPath = @"/Applications/Cydia.app";
    NSString *aptPath = @"/private/var/lib/apt/";
    if ([[NSFileManager defaultManager] fileExistsAtPath:cydiaPath]) {
        jailbroken = true;
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:aptPath]) {
        jailbroken = true;
    }
    m_GrayN_IsJail_Break = jailbroken;
    return m_GrayN_IsJail_Break;
}
string GrayNcommon::GrayNgetOsVersion()
{
    NSString* tmp = [NSString stringWithFormat:@"%@", [UIDevice currentDevice].systemVersion];
    m_GrayN_OS_Version = [tmp UTF8String];
    
    m_GrayN_Device_OS_Version = [[tmp stringByReplacingOccurrencesOfString:@" " withString:@"/"] UTF8String];
    
    return m_GrayN_OS_Version;
}
string GrayNcommon::GrayNgetAppVersion()
{
    NSString *shortVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    if (shortVersion == nil || [shortVersion isEqualToString:@""]) {
        shortVersion = @"0";
    }
    m_GrayN_GameVersion = [shortVersion UTF8String];
    return m_GrayN_GameVersion;
}
string GrayNcommon::GrayNgetDeviceModel()
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    m_GrayN_Device_Model = [deviceString UTF8String];
    return m_GrayN_Device_Model;
}
string GrayNcommon::GrayNgetTrueDeviceModel()
{
    int mib[2];
    size_t len;
    char *machine;
    
    mib[0] = CTL_HW;
    mib[1] = HW_MACHINE;
    sysctl(mib, 2, NULL, &len, NULL, 0);
    machine = (char*)malloc(len);
    sysctl(mib, 2, machine, &len, NULL, 0);
    
    NSString *platform = [NSString stringWithCString:machine encoding:NSASCIIStringEncoding];
    free(machine);
    return [platform UTF8String];
}
// 需要访问iokitFramework
string GrayNcommon::GrayNgetImei()
{
    m_GrayN_IMEI = "";
//        return [UIDevice currentDevice].imei;
    return m_GrayN_IMEI;
    
}
string GrayNcommon::GrayNgetMacAddress()
{
    
    int                 mgmtInfoBase[6];
    char                *msgBuffer = NULL;
    size_t              length;
    unsigned char       macAddress[6];
    struct if_msghdr    *interfaceMsgStruct;
    struct sockaddr_dl  *socketStruct;
    NSString            *errorFlag = NULL;
    
    mgmtInfoBase[0] = CTL_NET;
    mgmtInfoBase[1] = AF_ROUTE;
    mgmtInfoBase[2] = 0;
    mgmtInfoBase[3] = AF_LINK;
    mgmtInfoBase[4] = NET_RT_IFLIST;
    
    if ((mgmtInfoBase[5] = if_nametoindex("en0")) == 0){
        errorFlag = @"if_nametoindex failure";
    }
    else{
        if (sysctl(mgmtInfoBase, 6, NULL, &length, NULL, 0) < 0){
            errorFlag = @"sysctl mgmtInfoBase failure";
        }
        else{
            // Alloc memory based on above call
            if ((msgBuffer = (char*)malloc(length)) == NULL)
            errorFlag = @"buffer allocation failure";
            else{
                if (sysctl(mgmtInfoBase, 6, msgBuffer, &length, NULL, 0) < 0){
                    errorFlag = @"sysctl msgBuffer failure";
                }
            }
        }
    }
    
    if (errorFlag != NULL){
        //NSLog(@"Error:%@",errorFlag);
        if (msgBuffer) {
            free(msgBuffer);
            msgBuffer = NULL;
        }
        return "";
    }
    interfaceMsgStruct = (struct if_msghdr *) msgBuffer;
    socketStruct = (struct sockaddr_dl *) (interfaceMsgStruct + 1);
    memcpy(&macAddress, socketStruct->sdl_data + socketStruct->sdl_nlen, 6);
    NSString *macAddressString = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                                  macAddress[0], macAddress[1], macAddress[2],
                                  macAddress[3], macAddress[4], macAddress[5]];
    
    if ([macAddressString isEqualToString:@"02:00:00:00:00:00"]) {
        macAddressString = @"";
    }
    free(msgBuffer);
    GrayNcommon::m_GrayN_MAC_Address = [macAddressString UTF8String];
    return GrayNcommon::m_GrayN_MAC_Address;
    
}
string GrayNcommon::GrayNgetDevice_UniqueID()
{
    m_GrayN_Device_UniqueId = "";
    return "";
}

string GrayNcommon::GrayNgetScreenResolution()
{
    CGRect rect = [GrayNcommon_oc screen_GrayN_Rect];
    CGFloat screen_scale = [UIScreen mainScreen].scale;
    int w_resolution = 0;
    int h_resolution = 0;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        w_resolution = rect.size.width*screen_scale;
        h_resolution = rect.size.height*screen_scale;
    } else {
        h_resolution = rect.size.width*screen_scale;
        w_resolution = rect.size.height*screen_scale;
    }
    
    NSString * resolution = [NSString stringWithFormat:@"%dx%d",w_resolution,h_resolution];
    m_GrayN_Screen_Resolution = [resolution UTF8String];
    //    GrayN_DebugLog(@"OPScreenResolution=======%@", resolution);
    return m_GrayN_Screen_Resolution;
}
string GrayNcommon::GrayNgetMobileNetworkCode()
{
    CTTelephonyNetworkInfo *info = [GrayNcommon_oc shared_GrayN_NetworkInstance];
    CTCarrier *carrier = info.subscriberCellularProvider;
    NSString *MCC = carrier.mobileCountryCode;
    NSString *MNC = carrier.mobileNetworkCode;
    if (MCC != nil) {
        m_GrayNmobileCode.append([MCC UTF8String]);
    }
    if (MNC != nil) {
        m_GrayNmobileCode.append([MNC UTF8String]);
    }
    return m_GrayNmobileCode;
}
float GrayNcommon::GrayNgetfloatOsVersion()
{
    m_GrayN_Float_OS_Version = [[UIDevice currentDevice].systemVersion floatValue];
    return m_GrayN_Float_OS_Version;
}
//void GrayNcommon::GrayNgetPushIdentity()
//{
//////    cout<<opid<<endl;
//////    cout<<idfa<<endl;
////    string pushIdentity = m_GrayN_OPID;
////    pushIdentity.append(m_GrayN_IDFA);
////        //    cout<<pushIdentity<<endl;
////    const char* tmp = pushIdentity.c_str();
////    GrayN_Base64_GrayN::GrayN_Base64Encode((unsigned const char*)tmp, strlen(tmp), mPushIdentity);
////
////    GrayN_ConsoleLog("opPushIdentity=%s", mPushIdentity.c_str());
//}
void GrayNcommon::GrayNgetCpuInfo()
{
    m_GrayN_CpuInfo.append(GrayNcommon::m_GrayN_RAM);
    m_GrayN_CpuInfo.append(TAG);
    m_GrayN_CpuInfo.append(GrayNcommon::m_GrayN_CpuCores);
    m_GrayN_CpuInfo.append(TAG);
    m_GrayN_CpuInfo.append(GrayNcommon::m_GrayN_CpuClockSpeed);
    m_GrayN_CpuInfo.append(TAG);
    m_GrayN_CpuInfo.append(GrayNcommon::m_GrayN_CpuType);
    GrayN_ConsoleLog(@"cpuInfo:%s", m_GrayN_CpuInfo.c_str());

}

void GrayNcommon::GrayNgetDeviceInfo()
{
    /*
     RAM 			1000.00MB
     cpuCores			2
     cpuClockSpeed	2.22GHz
     cpuType			armv7
     */
    // RAM
    // Get Page Size
//    int page_size;
//    int mib[2];
//    size_t len;
    
//    mib[0] = CTL_HW;
//    mib[1] = HW_PAGESIZE;
//    len = sizeof(page_size);
    
//    // 方法一: 16384
//    int status = sysctl(mib, 2, &page_size, &len, NULL, 0);
//    if (status < 0) {
//        perror("Failed to get page size");
//    }
    //    // 方法二: 16384
    //    page_size = getpagesize();
    // 方法三: 4096
    //     if(host_page_size(mach_host_self(), &page_size)!= KERN_SUCCESS ){
    //          perror("Failed to get page size");
    //     }
//    printf("Page size is %d bytes\n", page_size);
    
    // RAM
    int mib[2];
    size_t len;
    mib[0] = CTL_HW;
    mib[1] = HW_MEMSIZE;
    long long ram;
    len = sizeof(ram);
    if (sysctl(mib, 2, &ram, &len, NULL, 0)) {
        perror("Failed to get ram size");
        m_GrayN_RAM = "failToGet";
    } else {
        m_GrayN_RAM = [[NSString stringWithFormat:@"%0.2fGB", ram / (1024.0) / (1024.0)/ (1024.0)] UTF8String];
    }
    

//    // Get Memory Statistics
//    //    vm_statistics_data_t vm_stats;
//    //    mach_msg_type_number_t info_count = HOST_VM_INFO_COUNT;
//    vm_statistics64_data_t vm_stats;
//    mach_msg_type_number_t info_count64 = HOST_VM_INFO64_COUNT;
//    //    kern_return_t kern_return = host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vm_stats, &info_count);
//    kern_return_t kern_return = host_statistics64(mach_host_self(), HOST_VM_INFO64, (host_info64_t)&vm_stats, &info_count64);
//    if (kern_return != KERN_SUCCESS) {
//        printf("Failed to get VM statistics!");
//    }
//    
//    double vm_total = vm_stats.wire_count + vm_stats.active_count + vm_stats.inactive_count + vm_stats.free_count;
//    double vm_wire = vm_stats.wire_count;
//    double vm_active = vm_stats.active_count;
//    double vm_inactive = vm_stats.inactive_count;
//    double vm_free = vm_stats.free_count;
//    double unit = (1024.0) * (1024.0);
//    
//    NSLog(@"Total Memory: %f", vm_total * page_size / unit);
//    NSLog(@"Wired Memory: %f", vm_wire * page_size / unit);
//    NSLog(@"Active Memory: %f", vm_active * page_size / unit);
//    NSLog(@"Inactive Memory: %f", vm_inactive * page_size / unit);
//    NSLog(@"Free Memory: %f", vm_free * page_size / unit);
    
    // cpu主频
//    unsigned int aaa;
//    len = sizeof(aaa);
//    string a = "";
//    sysctlbyname("machdep.cpu.brand_string", &aaa, &len, &a, 0);
//    cout<<"123123"<<a<<endl;
//    cout<<"123123"<<aaa<<endl;
    
//
//    int result2;
//    mib[0] = CTL_HW;
//    mib[1] = HW_BUS_FREQ;
//    length = sizeof(result2);
//    if (sysctl(mib, 2, &result2, &length, NULL, 0) < 0)
//    {
//        perror("getting bus frequency");
//    }
//    printf("Bus Frequency = %u hz\n", result);

    // cpuType
    host_basic_info_data_t hostInfo;
    mach_msg_type_number_t infoCount;
    
    infoCount = HOST_BASIC_INFO_COUNT;
    host_info(mach_host_self(), HOST_BASIC_INFO, (host_info_t)&hostInfo, &infoCount);
//    cout<<hostInfo.cpu_type<<endl;
//    cout<<(7 | 0x01000000)<<endl;
    m_GrayN_CpuType.append(GrayNcommonIntegerToString(hostInfo.cpu_type));
    m_GrayN_CpuType.append("_");
    m_GrayN_CpuType.append(GrayNcommonIntegerToString(hostInfo.cpu_subtype));
//    cout<<m_GrayN_CpuType<<endl;

//    switch (hostInfo.cpu_type) {
//        case CPU_TYPE_ARM:
//        {
//            switch (hostInfo.cpu_subtype) {
//                case CPU_SUBTYPE_ARM_ALL:
//                    m_GrayN_CpuType = "ARM_all";
//                    break;
//                case CPU_SUBTYPE_ARM_V4T:
//                    m_GrayN_CpuType = "ARM_v4t";
//                    break;
//                case CPU_SUBTYPE_ARM_V6:
//                    m_GrayN_CpuType = "ARM_v6";
//                    break;
//                case CPU_SUBTYPE_ARM_V5TEJ:
//                    m_GrayN_CpuType = "ARM_v5tej";
//                    break;
//                case CPU_SUBTYPE_ARM_XSCALE:
//                    m_GrayN_CpuType = "ARM_xscale";
//                    break;
//                case CPU_SUBTYPE_ARM_V7:
//                    m_GrayN_CpuType = "ARM_v7";
//                    break;
//                case CPU_SUBTYPE_ARM_V7F:
//                    m_GrayN_CpuType = "ARM_v7f";
//                    break;
//                case CPU_SUBTYPE_ARM_V7S:
//                    m_GrayN_CpuType = "ARM_v7s";
//                    break;
//                case CPU_SUBTYPE_ARM_V7K:
//                    m_GrayN_CpuType = "ARM_v7k";
//                    break;
//                case CPU_SUBTYPE_ARM_V6M:
//                    m_GrayN_CpuType = "ARM_v6m";
//                    break;
//                case CPU_SUBTYPE_ARM_V7M:
//                    m_GrayN_CpuType = "ARM_v7m";
//                    break;
//                case CPU_SUBTYPE_ARM_V7EM:
//                    m_GrayN_CpuType = "ARM_v7em";
//                    break;
//                case CPU_SUBTYPE_ARM_V8:
//                    m_GrayN_CpuType = "ARM_v8";
//                    break;
//                default:
//                    m_GrayN_CpuType = "ARM_v7";
//                    break;
//            }
//        }
//            break;
//            
//        case CPU_TYPE_ARM64:
//        {
//            if (hostInfo.cpu_subtype == CPU_SUBTYPE_ARM64_V8) {
//                m_GrayN_CpuType = "ARM64_v8";
//            } else {
//                m_GrayN_CpuType = "ARM64_all";
//
//            }
//        }
//            break;
//            
//        case CPU_TYPE_X86:
//            m_GrayN_CpuType = "x86";
//            break;
//        case CPU_TYPE_X86_64:
//            m_GrayN_CpuType = "x86_64";
//            break;
//            
//        default:
//            m_GrayN_CpuType = "unknown";
//
//            break;
//    }
    
    // cpu核心数
    unsigned int ncpu = 0;
    len = sizeof(ncpu);
    sysctlbyname("hw.ncpu", &ncpu, &len, NULL, 0);
    m_GrayN_CpuCores = [[NSString stringWithFormat:@"%d", ncpu] UTF8String];
    
    
//    int result;
//    mib[0] = CTL_HW;
//    mib[1] = HW_TB_FREQ;
//    size_t length = sizeof(result);
//    if (sysctl(mib, 2, &result, &length, NULL, 0) < 0)
//    {
//        perror("getting cpu frequency");
//    }
//    printf("CPU Frequency = %0.2fGHz\n", result/ (1024.0)/ (1024.0)/ (1024.0));
    // 设备列表
    // http://www.blakespot.com/ios_device_specifications_grid.html
//    size_t size;
//    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
//    char *machine = (char*)malloc(size);
//    sysctlbyname("hw.machine", machine, &size, NULL, 0);
//    //    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
//    if (machine == NULL) {
//        m_GrayN_CpuClockSpeed = "machine=null";
//        GrayN_ConsoleLog(@"machine=%s\nRAM=%s\ncpuType=%s\ncpuCores=%s\ncpuClockSpeed=%s", machine, m_GrayN_RAM.c_str(), m_GrayN_CpuType.c_str(), m_GrayN_CpuCores.c_str(), m_GrayN_CpuClockSpeed.c_str());
//
//        return;
//    }
//    float ccs = [[NSString stringWithUTF8String:LocalLangCN(machine)] floatValue];
//    if (ccs == 0) {
//        m_GrayN_CpuClockSpeed = "unknown";
//        m_GrayN_CpuClockSpeed.append("-");
//        m_GrayN_CpuClockSpeed.append(machine);
//        GrayN_ConsoleLog(@"machine=%s\nRAM=%s\ncpuType=%s\ncpuCores=%s\ncpuClockSpeed=%s", machine, m_GrayN_RAM.c_str(), m_GrayN_CpuType.c_str(), m_GrayN_CpuCores.c_str(), m_GrayN_CpuClockSpeed.c_str());
//
//        return;
//    }
//
//    m_GrayN_CpuClockSpeed = [[NSString stringWithFormat:@"%0.2fGHz", ccs/(1024.0)] UTF8String];
//    GrayN_ConsoleLog(@"RAM=%s\ncpuType=%s\ncpuCores=%s\ncpuClockSpeed=%s", m_GrayN_RAM.c_str(), m_GrayN_CpuType.c_str(), m_GrayN_CpuCores.c_str(), m_GrayN_CpuClockSpeed.c_str());

    //    NSLog(@"%@sss", platform);
//    cout<<"m_GrayN_CpuClockSpeed="<<m_GrayN_CpuClockSpeed<<endl;
    //NSString *platform = [NSStringstringWithUTF8String:machine];二者等效
//    free(machine);
    //    printf("CPU 123123 = %0.2fGHz\n", aaa/ (1024.0)/ (1024.0)/ (1024.0));

    
}
#pragma mark- IDFA
bool GrayNcommon::GrayNgetKeychainIDFA()
{
    if ([GrayNserviceCodeBridge GrayNupdateServiceCode]) {
        p_GrayNifUpdate = true;
        return false;
    }
    GrayNgetEncryptedIDFA();
    GrayNgetOPIDFA();
    m_GrayN_IDFA = [p_GrayN_OP_IDFA UTF8String];
    
    [GrayNserviceCodeBridge GrayNsetDeviceIDFA:p_GrayN_OP_IDFA];
    [GrayNserviceCodeBridge GrayNsetLoginIDFA:p_GrayN_OP_IDFA];
    
    p_GrayNopSDKVersion = [[NSString alloc] initWithUTF8String:GrayNcommon::m_GrayN_SDKVersion.c_str()];
    
    [GrayNserviceCodeBridge GrayNsetSDKVersion:p_GrayNopSDKVersion];
    
    /* 5.1.0 保存idfa idfv至本地*/
    GrayNstroreOPUDID();
    GrayNstroreOPIDFV();
    
    return true;
}
void GrayNcommon::GrayNgetEncryptedIDFA()
{
        //测试设备ios 9.3.2
        //1、app卸载重装后，依然可以获取
        //2、两个不同的app，如果前缀一致就可以读到，证书账号不同都没有关系
        //3、重启设备，依然可以获取
        //4、还原所有设置，依然可以获取
        //5、系统升级，应该可以，暂时没法测试
    //读取数据
//    UIPasteboard *pasteboard = [UIPasteboard pasteboardWithUniqueName];
//    UIPasteboard* pasteboard = [UIPasteboard generalPasteboard];
//
//    id value=[pasteboard dataForPasteboardType:@"com.op.udid"];
//    NSDictionary *dic = [NSKeyedUnarchiver unarchiveObjectWithData:value];
//    NSLog(@"读取pasteboard=%@",dic);
//        NSString *bundleid = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
//        if ([bundleid isEqualToString:@"com.hanwu.boringCat"]) {
//            //写入数据
//            UIPasteboard* pasteboard = [UIPasteboard generalPasteboard];
////            UIPasteboard *pasteboard = [UIPasteboard pasteboardWithName:@"testBoard" create:YES];
////                        UIPasteboard *pasteboard = [UIPasteboard pasteboardWithUniqueName];
//
//            
//            pasteboard.persistent = YES; //是否持续存在
//            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
//            [dic setValue:@"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" forKey:@"IDFA"];
//            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dic];
//            [pasteboard setData:data forPasteboardType:@"com.op.udid"];
//            NSLog(@"存储pasteboard=%@",dic);
//
//            [dic release];
//            
//        } else {
//            //读取数据
//            UIPasteboard* pasteboard = [UIPasteboard generalPasteboard];
//            id value=[pasteboard dataForPasteboardType:@"com.op.udid"];
//            NSDictionary *dic = [NSKeyedUnarchiver unarchiveObjectWithData:value];
//            NSLog(@"读取pasteboard=%@",dic);
//            NSString *idfa = [dic objectForKey:@"IDFA"];
//
//        }
    /*5.1.1*/
    NSString *latestIDFA = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    GrayNcommon::m_GrayNrealTimeIDFA = [latestIDFA UTF8String];
    NSString *latestIDFV = [UIDevice currentDevice].identifierForVendor.UUIDString;
    GrayNcommon::m_GrayNrealTimeIDFV = [latestIDFV UTF8String];

    NSString *latestUUID = [[NSUUID UUID] UUIDString];
    NSString *localLoginIndentifier = @"";

    if(latestUUID == nil){
        latestUUID = @"";
    }
    
    NSDictionary *query = [NSDictionary dictionaryWithObjectsAndKeys:
                           (id)kSecClassGenericPassword, kSecClass,
                           @"bundleSeedID", kSecAttrAccount,
                           @"", kSecAttrService,
                           (id)kCFBooleanTrue, kSecReturnAttributes,
                           nil];
    CFDictionaryRef result = nil;
    OSStatus status = SecItemCopyMatching((CFDictionaryRef)query, (CFTypeRef *)&result);
    if (status == errSecItemNotFound)
    status = SecItemAdd((CFDictionaryRef)query, (CFTypeRef *)&result);
    if (status != errSecSuccess) {
        if (latestIDFA == nil) {
            latestIDFA = @"";
            p_GrayNkeychainIDFA = @"";
        }
        GrayNcommon::GrayN_ConsoleLog(@"groupId error,localIDFA=%@", latestIDFA);
        return;
    }
    
    // 可能是非标准存储 9398ZD48S2.*
    NSString *accessGroup = [(NSDictionary *)result objectForKey:(id)kSecAttrAccessGroup];
    NSArray *components = [accessGroup componentsSeparatedByString:@"."];
    NSString *bundleSeedID = [[components objectEnumerator] nextObject];
    NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
    
    // 标准存储 9398ZD48S2.com.3Dtankeshijie.cn
    NSString *standardGroupId = [NSString stringWithFormat:@"%@.%@",bundleSeedID,identifier];

    // 获取IDFV
    GrayNkeychainConfig *idfvItem = [[GrayNkeychainConfig alloc] GrayNinitWithIdentifier:@"com.op.idfv"
                                                                            accessGroup:standardGroupId
                                                                           encodeStatus:YES];

    NSString *idfvStr = [idfvItem objectForKey:(id)CFBridgingRelease(kSecValueData)];
    if ([idfvStr isEqualToString:@""] == false) {
        m_GrayN_IDFV = [idfvStr UTF8String];
        GrayNcommon::GrayNstroreOPIDFV();
    } else {
        NSString *tmp = [UIDevice currentDevice].identifierForVendor.UUIDString;
        m_GrayN_IDFV = [tmp UTF8String];
        std::string opIDFV = GrayNcommon::GrayNgetOPIDFV();
        if (opIDFV.length()) {
            m_GrayN_IDFV = opIDFV;
        }else{
            GrayNcommon::GrayNstroreOPIDFV();
        }
        
        [idfvItem setObject:tmp forKey:(id)CFBridgingRelease(kSecValueData)];
    }
    [idfvItem release];
    GrayNcommon::GrayN_ConsoleLog("opIDFV:%s", m_GrayN_IDFV.c_str());

    
    NSString *localUUID = nil;
    NSString *localIDFA = nil;
    NSString *oldIDFA = nil;
    
    // 优先把新的UUID准备好
    if ([latestIDFA isEqualToString:@"00000000-0000-0000-0000-000000000000"]) {
        NSString *tmp = [latestUUID stringByReplacingOccurrencesOfString:@"-" withString:@""];
        localUUID = [NSString stringWithFormat:@"@@@@%@",tmp];
    } else {
        localUUID = latestIDFA;
    }
    
    // 获取历史IDFA
    GrayNkeychainConfig *oldkeychainItem = [[GrayNkeychainConfig alloc]
                                              GrayNinitWithIdentifier:@"IDFA"
                                              accessGroup:standardGroupId
                                              encodeStatus:NO];
    
    oldIDFA = [oldkeychainItem objectForKey:(id)CFBridgingRelease(kSecValueData)];
    if ([oldIDFA isEqualToString:@""] == false && [oldIDFA isEqualToString:@"00000000-0000-0000-0000-000000000000"] == false) {
        localIDFA = oldIDFA;
        localLoginIndentifier = oldIDFA;
        p_GrayNkeychainIDFA = [localIDFA copy];
        GrayNcommon::GrayNstroreOPUDID();     //保存loginIndentifier
        
        GrayNcommon::GrayN_ConsoleLog(@"stdid=%@\n1-log=%@\nlogin=%@",standardGroupId,p_GrayNkeychainIDFA,localLoginIndentifier);
        
        [oldkeychainItem release];
        CFRelease(result);
        return;
    }
    [oldkeychainItem release];
    
    // 获取标准存储并判断
    GrayNkeychainConfig *keychainItem = [[GrayNkeychainConfig alloc]
                                           GrayNinitWithIdentifier:@"com.op.udid"
                                           accessGroup:standardGroupId
                                           encodeStatus:YES];
    
    NSString *data = [keychainItem objectForKey:(id)CFBridgingRelease(kSecValueData)];
    if ([data isEqualToString:@""] == false) {
        NSArray *array = [data componentsSeparatedByString:@"##"];
        if ([array count] == 2) {
            localIDFA = array[0];
            localUUID = array[1];
            localLoginIndentifier = localIDFA;
            if ([localIDFA isEqualToString:@"00000000-0000-0000-0000-000000000000"]) {
                localLoginIndentifier = localUUID;
            }
            p_GrayNkeychainIDFA = [localLoginIndentifier copy];
            GrayNcommon::GrayNstroreOPUDID();     //保存loginIndentifier
            GrayNcommon::GrayN_ConsoleLog(@"stdid=%@\n2-log=%@\nlogin=%@", standardGroupId, p_GrayNkeychainIDFA, localLoginIndentifier);
            
            [keychainItem release];
            return;
        }
    }
    
    bool newUser = true;
    // 获取非标准存储并判断
    GrayNkeychainConfig *unstandardItem = [[GrayNkeychainConfig alloc]
                                             GrayNinitWithIdentifier:@"com.op.udid"
                                             accessGroup:accessGroup
                                             encodeStatus:YES];
    
    NSString *unstandardItemData = [unstandardItem objectForKey:(id)CFBridgingRelease(kSecValueData)];
    
    if ([unstandardItemData isEqualToString:@""] == false) {
        NSArray *array = [unstandardItemData componentsSeparatedByString:@"##"];
        if ([array count] == 2) {
            localIDFA = array[0];
            localUUID = array[1];
            localLoginIndentifier = localIDFA;
            if ([localIDFA isEqualToString:@"00000000-0000-0000-0000-000000000000"]) {
                localLoginIndentifier = localUUID;
            }
            GrayNcommon::GrayN_ConsoleLog(@"unstandard-1");
            newUser = false;

        } else {
            NSString *SDKID = [NSString stringWithUTF8String:GrayNcommon::m_GrayN_SDKVersion.c_str()];
            if (SDKID != nil) {
                // SDK_OP 4.3.7.10058开始
                if ([SDKID rangeOfString:@"10058"].location != NSNotFound || [SDKID rangeOfString:@"10084"].location != NSNotFound || [SDKID rangeOfString:@"10069"].location != NSNotFound || [SDKID rangeOfString:@"10253"].location != NSNotFound || [SDKID rangeOfString:@"10167"].location != NSNotFound) {
                    //需要兼容之前的错误版本
                    localIDFA = unstandardItemData;
                    localLoginIndentifier = unstandardItemData;
                    if ([unstandardItemData isEqualToString:@"00000000-0000-0000-0000-000000000000"]) {
                        localLoginIndentifier = localUUID;
                    }
                    GrayNcommon::GrayN_ConsoleLog(@"unstandard-old");
                    newUser = false;
                } else {
                    localIDFA = latestIDFA;
                    //localUUID的值在最初已生成好了
                    localLoginIndentifier = localUUID;
                    GrayNcommon::GrayN_ConsoleLog(@"unstandard-2");
                }
            } else {
                localIDFA = latestIDFA;
                // localUUID的值在最初已生成好了
                localLoginIndentifier = localUUID;
                GrayNcommon::GrayN_ConsoleLog(@"unstandard-new");
            }
        }
    } else {
        localIDFA = latestIDFA;
        //localUUID的值在最初已生成好了
        localLoginIndentifier = localUUID;
        GrayNcommon::GrayN_ConsoleLog(@"unstandard-3");
    }
    
    // 日志
    p_GrayNkeychainIDFA = [localLoginIndentifier copy];

    //newUser=true时，有两种情况
    //1、第一次安装新版本
    //2、产品发生迁移，teamID发生变化
    if (newUser) {
        std::string opUDID = GrayNcommon::GrayNgetOPUDID();
        if (opUDID.length()) {
            localIDFA = [NSString stringWithUTF8String:opUDID.c_str()];
            localUUID = localIDFA;
            localLoginIndentifier = localIDFA;
            p_GrayNkeychainIDFA = localIDFA;
            GrayNcommon::GrayN_ConsoleLog(@"OPGameSDK LOG:accessGroup=%@,4-log=%@,login=%@",accessGroup,p_GrayNkeychainIDFA,localLoginIndentifier);
        } else {
            //文件可能被改动了或新用户本地未存储
            GrayNcommon::GrayNstroreOPUDID();     //保存loginIndentifier
        }
    } else {
        GrayNcommon::GrayNstroreOPUDID();     //保存loginIndentifier
    }
    
    [unstandardItem release];

    GrayNcommon::GrayN_ConsoleLog(@"accessGroup=%@,3-log=%@,login=%@",accessGroup,p_GrayNkeychainIDFA,localLoginIndentifier);
    
    // 标准化存储
    NSString *localData = [NSString stringWithFormat:@"%@##%@",localIDFA,localUUID];
    GrayNcommon::GrayN_ConsoleLog(@"localData=%@",localData);
    
    [keychainItem setObject:localData forKey:(id)CFBridgingRelease(kSecValueData)];
    
    // 标准存储最后release
    [keychainItem release];
    CFRelease(result);
}
void GrayNcommon::GrayNgetOPIDFA()
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDir = [paths objectAtIndex:0];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = [NSString stringWithFormat:@"%@/.op_udid",cachesDir];
    NSError *error = nil;
    NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:path error:&error];
    
    //    NSDictionary *fileAttributes = [fileManager fileAttributesAtPath:path traverseLink:YES];
    if (fileAttributes != nil) {
        NSDate *creationDate = nil;
        NSDate *fileModDate = nil;
        // 文件创建日期
        creationDate = [fileAttributes objectForKey:NSFileCreationDate];
        // 文件修改日期
        fileModDate = [fileAttributes objectForKey:NSFileModificationDate];
        GrayNcommon::GrayN_DebugLog(@"File creationDate:%@", creationDate);
        GrayNcommon::GrayN_DebugLog(@"File modificationDate:%@", fileModDate);
        
        if ([creationDate isEqual:fileModDate]) {
            NSData *data = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
            NSString *localIDFA = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
            if ([localIDFA isEqualToString:p_GrayNkeychainIDFA]) {
                GrayNcommon::GrayN_DebugLog(@"IDFA正常！");
            } else {
                GrayNcommon::GrayN_DebugLog(@"文件或IDFA被改动！");
            }
        } else {
            GrayNcommon::GrayN_DebugLog(@"文件被改动！");
        }
    } else {
        GrayNcommon::GrayN_DebugLog(@"Path (%@) is invalid.", path);
    }
    p_GrayN_OP_IDFA = [p_GrayNkeychainIDFA copy];

    // 每次启动都会创建最新的“.op_udid”文件
    NSData *data = [p_GrayN_OP_IDFA dataUsingEncoding:NSUTF8StringEncoding];
    [NSKeyedArchiver archiveRootObject:data toFile:path];
}

void GrayNcommon::GrayNstroreOPUDID()
{
    GrayNcommon::GrayNstroreOPData("op_udid",m_GrayN_IDFA.c_str());
}
std::string GrayNcommon::GrayNgetOPUDID()
{
    std::string tmp = GrayNcommon::GrayNgetOPData("op_udid");
    return tmp;
}
void GrayNcommon::GrayNstroreOPIDFV()
{
    GrayNcommon::GrayNstroreOPData("op_idfv", m_GrayN_IDFV.c_str());
}
std::string GrayNcommon::GrayNgetOPIDFV()
{
    std::string tmp = GrayNcommon::GrayNgetOPData("op_idfv");
    return tmp;
}
void GrayNcommon::GrayNstroreOPData(const char* GrayNfileName,const char* GrayNfileData)
{
    NSString *name = [NSString stringWithUTF8String:GrayNfileName];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents = [paths objectAtIndex:0];
    NSString *path = [NSString stringWithFormat:@"%@/.%@",documents,name];
    NSString *tmp = [NSString stringWithUTF8String:GrayNfileData];
    NSData *data = [tmp dataUsingEncoding:NSUTF8StringEncoding];
    [NSKeyedArchiver archiveRootObject:data toFile:path];
}
std::string GrayNcommon::GrayNgetOPData(const char* GrayNfileName)
{
    std::string tmp;
    NSString *name = [NSString stringWithUTF8String:GrayNfileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents = [paths objectAtIndex:0];
    NSString *path = [NSString stringWithFormat:@"%@/.%@",documents,name];
    if ([fileManager fileExistsAtPath:path]) {
        NSData *data = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        if (data) {
            NSString *localIDFA = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            tmp = [localIDFA UTF8String];
            [localIDFA release];
        }
    }
    return tmp;
}

