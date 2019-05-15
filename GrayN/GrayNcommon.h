/*
 宏定义 方法名 添加
 */


#import <stdio.h>
#import <stdlib.h>
#import <assert.h>
#import <memory.h>
#import <string.h>
#import <math.h>
#import <vector>
#import <unistd.h>
#import <iostream>
#import <sstream>
#import <fcntl.h>
#import  <objc/objc.h>
#import "GrayNjson_cpp.h"

#import "GrayNconfig.h"

using namespace std;

GrayN_NameSpace_Start
class GrayNcommon
{
public:
     GrayNcommon(){}
    ~GrayNcommon(){}

    // ****************游戏属性
    //角色ID
    static string m_GrayN_Game_RoleId;
    //角色名称
    static string m_GrayN_Game_RoleName;
    //分区ID
    static string m_GrayN_Game_ServerId;
    //分区名称
    static string m_GrayN_Game_ServerName;
    //游戏角色等级
    static string m_GrayN_Game_RoleLevel;
    //游戏角色vip等级
    static string m_GrayN_Game_RoleVipLevel;
    //动作ID 用户激活，注册，登陆
    static string m_GrayN_ActionId;
    //0:单机、1:网游
    static string m_GrayN_GameType;
    // 当前账号登录类型
    static string m_GrayN_CurrentUserType;
    static string m_GrayN_LoginType;     //标识，注册，登录

    static string m_GrayN_Oua;
    static string m_GrayN_AllVersion;
    //****************业务属性
    //业务id
    static string m_GrayN_ServiceId;
    //推广渠道id
    static string m_GrayN_ChannelId;
    //地区
    static string m_GrayN_LocaleId;
    //机型组ID
    static string m_GrayN_DeviceGroupId;
    
    // 设置rootViewController
    static void* m_GrayN_RootViewController;
    static string m_GrayN_DeviceInfo;           //设备信息
    static GrayN_JSON::Value m_GrayN_DeviceJson;      //设备唯一标识集合（{mac:“”，idfa:“”，deviceUniqueID:“”，phoneNum：“”}）
    static string m_GrayN_SessionId;               // 会话ID

    static string m_GrayN_SecretKey;   //私钥
    static string m_GrayN_DesKey;      //客户端SDK在开始进行计费时生成字符串SecretKey,把SecretKey用“ourpalm^-^%2012%”进行DES加密得到dk参数值。


    /*5.1.2*/
    static string m_GrayN_BundleId;
    /*5.1.2*/
    
    // 第三方用户系统ID
    static string m_GrayN_UserPlatformId;
    // 用户ID
    static string m_GrayN_Game_UserId;
    // 掌趣用户名
    static string m_GrayN_Game_UserName;
    // 掌趣号
    static string m_GrayN_Game_PalmId;
    // 掌趣昵称
    static string m_GrayN_Game_NickName;
    // 用户登录手机号
    static string m_GrayN_Game_PhoneNum;
    // 用户登录邮箱
    static string m_GrayN_Game_Email;
    /*5.1.5*/
    static string m_GrayN_Game_PayCallback_Url;

    /*5.2.1 二维码token*/
    static string m_GrayN_QRCodeTokenId;
    
#pragma mark- 静态参数
    static bool m_GrayNdebug_Mode;
    /*5.2.0*/
    static bool m_GrayNforceDebug_Mode;
    /*5.2.0*/

    static bool m_GrayN_ScreenIsAutoRotation;
    static bool m_GrayN_ShowLoading;
    static bool m_GrayN_IsJail_Break;
    static int m_GrayN_InitOrientation;
    static int m_GrayN_SDKOrientation;
/*5.1.5*/
    static int m_GrayN_Deferring_System_Gestures;
    static bool m_GrayN_Home_Indicator_Auto_Hidden;
    static string m_GrayN_SDKVersion;
    static string m_GrayN_PushServerUrl;
    static string m_GrayN_GameVersion;
    static string m_GrayN_GameResVersion;
    static string m_GrayN_HttpStaticHeader;         // http静态头信息

    static string m_GrayN_OS_Version;
    static string m_GrayN_Device_Model;
    static string m_GrayNcurLanguage;
    static string m_GrayN_IMEI;
    static string m_GrayN_MAC_Address;
    static string m_GrayN_IDFA;
    static string m_GrayN_Device_UniqueId;      //WP8设备唯一标识
    static string m_GrayN_IDFV;
//    static string mPushIdentity;       //推送使用的唯一标识 pcode+IDFA base64
    static string m_GrayN_RAM;
    static string m_GrayN_CpuCores;
    static string m_GrayN_CpuClockSpeed;
    static string m_GrayN_CpuType;
    static string m_GrayN_CpuInfo;
    
    static string m_GrayN_Screen_Resolution;    //屏幕分辨率
    static string m_GrayN_Screen_Orientation;
    static string m_GrayN_Open_UUID;
    
    static float m_GrayN_Float_OS_Version;
    static string m_GrayN_Device_OS_Version;
    
    static string m_GrayN_SDK_Init_Url;
    static string m_GrayN_StatisticalUrl;     //统计信息接口地址

    static string m_GrayN_Channel_Name;
    static string m_GrayN_P_Code;
    static string m_GrayN_NetSource_Info;
    static string m_GrayN_OPID;
    
    static string m_GrayNmobileCode;
    
    static string m_GrayNnetworkType;
    static string m_GrayNnetworkTypeNum;
    
    static string m_GrayNnetworkSubType;
    static string m_GrayNchannel_Info;
    

#pragma mark- 控制台日志输出
    /*ObjC*/
    static void GrayN_DebugLog(id GrayNlogs, ...);
    static void GrayN_ConsoleLog(id GrayNlogs, ...);
    /*c 不支持中文输出*/
    static void GrayN_DebugLog(const char* GrayNlogs, ...);
    static void GrayN_ConsoleLog(const char* GrayNlogs, ...);
    static id   GrayNgetDebugView();

#pragma mark- 公共方法
    static bool GrayNcommonInit();
    static bool GrayNcommonInitConfig();
    
    static string GrayNgetNetSourceInfo();
    static string GrayNcommonIntegerToString(int GrayNdata);
    static string GrayNcommonLongToString(long long GrayNdata);

    static string GrayNgetCurrentDeviceLang();

    static const char* GrayNcommonGetLocalLang(const char* GrayNkey);
    static const char* GrayNget_ChannelInfo();
    
    static int GrayNsplitString(string& GrayNprefix, string& GrayNstrSrc, string& GrayNstrDelims, vector<string>& GrayNstrDest);
    static void GrayNstringReplace(string& original, const string& replaceStr,const string& replacedStr);
    
    static void GrayNclearUserLocalData();
    static string GrayN_Encode_Base64_UrlEncode(const char* GrayNdata);

#pragma mark- 统计
    static string GrayNgetLocal_StatisticalUrl();
    static void   GrayNsetLocal_StatisticalUrl(string GrayNurl);
#pragma mark- 时间
    static long long GrayNgetCurrent_TimeStamp();
    static string GrayNgetCurrent_DateAndTime();
    static string GrayNgetCurrent_TimeString();
    static string GrayNgetCurrent_MilTimeString();
    
#pragma mark- 检测网络
    static void GrayNcheckNetworkType();
    static void GrayNcheckNetworkSubType();
    static string GrayN_DNSParse(const char* hostName);
    static void GrayNgetHttpStaticHeader();     // http 请求静态头信息
    static void GrayNgetHttpDynamicHeader(string & GrayNheader);//http 请求动态头信息
    static id   GrayNgetHttpsHeader();
    
#pragma mark- 内部方法
private:
    //加密私钥
    static void GrayNdesEncryptKey(const char* GrayNcontent, const char* GrayNkey, string& GrayNresult);
    //创建私钥
    static void GrayNcreateSecretKey();
    static bool GrayNisJail_Break();
    static string GrayNgetOsVersion();
    static string GrayNgetAppVersion();
    static string GrayNgetDeviceModel();
    static string GrayNgetTrueDeviceModel();
    static string GrayNgetImei();
    static string GrayNgetMacAddress();
    static string GrayNgetDevice_UniqueID();
    static string GrayNgetScreenResolution();
    static string GrayNgetMobileNetworkCode(); //获得SIM卡网络运营商名称
    static float GrayNgetfloatOsVersion();
    static bool GrayNgetKeychainIDFA();
    static void GrayNgetEncryptedIDFA();
    static void GrayNgetOPIDFA();
//    static void GrayNgetPushIdentity();
    static void GrayNgetCpuInfo();
    static void GrayNgetDeviceInfo();
    
#pragma mark- 私有变量
    static bool m_GrayNcommonIsInit;
    static bool m_GrayNcommonIsInitConfig;
    static const char* m_GrayNkeyItem; //秘钥生成来源字符串
/*5.1.0*/
    static void GrayNstroreOPUDID();
    static void GrayNstroreOPIDFV();
    static void GrayNstroreOPData(const char* GrayNfileName,const char* GrayNdata);
    
/*5.1.1*/
    static string GrayNgetOPUDID();
    static string GrayNgetOPIDFV();
    static string GrayNgetOPData(const char* GrayNfileName);
    
    static string m_GrayNrealTimeIDFA;
    static std::string m_GrayNrealTimeIDFV;
    
};

GrayN_NameSpace_End

