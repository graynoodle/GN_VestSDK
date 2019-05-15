
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface GrayNbaseSDK : NSObject
//+ (id)shareInstance;

+ (void)GrayNsetUserPlatformID:(NSString *)GrayNplatformID;
+ (void)GrayNsetSDKVersion:(NSString *)SDKVersion;

+ (void)GrayNcallBackInit:(BOOL)GrayNstatus;

+ (void)GrayNregisterLogin;
+ (void)GrayNenterPlatform;
+ (void)GrayNuserFeedback;
+ (void)GrayNswitchAccount;
+ (void)GrayNcallBackSwitchAccount:(BOOL)result;
+ (void)GrayNlogout;
#pragma mark- 渠道登录
+ (BOOL)GrayNisLogin;

+ (void)GrayNcallBackLogin:(NSDictionary*)GrayNresultDic;
+ (void)GrayNcallBackLogout:(BOOL)GrayNresult;
+ (void)GrayNcallBackPayResult:(BOOL)GrayNresult data:(NSDictionary *)GrayNpayResultDic;

#pragma mark- Tools
+ (NSString*)GrayNencode_Base64_UrlEncode:(NSString*)GrayNinputData;
+ (NSString*)GrayNencodeBase64:(NSString*)GrayNinputData;
+ (NSString*)GrayNdecodeBase64:(NSString*)GrayNinputData;

+ (NSString*)GrayNencodeDES:(NSString*)GrayNinputData;
+ (NSString*)GrayNencodeDES:(const char*)GrayNinputData andKey:(const char*)GrayNkey;
+ (NSString*)GrayNdecodeDES:(NSString*)GrayNinputData;
+ (NSString*)GrayNdecodeDES:(const char*)GrayNinputData andKey:(const char*)GrayNkey;

+ (NSString*)GrayNurl_Encode:(const char*)GrayNinputData;
+ (NSString*)GrayNurl_Decode:(const char*)GrayNinputData;

#pragma mark- UIOrientation
+ (BOOL)GrayNwindow_IsLandScape;
+ (BOOL)GrayNwindow_IsAutoOrientation;
+ (UIInterfaceOrientation)GrayNwindow_InitOrientation;
+ (UIInterfaceOrientationMask)GrayNsupportedInterfaceOrientations;

+ (CGRect)GrayNwindow_Rect;

#pragma mark- OurpalmSDK
+ (const char*)GrayNgetGame_RoleId;
+ (const char*)GrayNgetGame_RoleName;

+ (const char*)GrayNgetSdkVersion;
+ (const char*)GrayNgetApplogUrl;
+ (const char*)GrayNget_ServiceId;
+ (const char*)GrayNgetAppstoreVerifyUrl;
//+ (BOOL)GetStoreAdSwitch;
+ (const char*)GrayNgetGame_ServerId;
/*5.2.4*/
+ (const char*)GrayNgetGame_ServerName;
+ (UIViewController*)GrayNgetRootViewController;
+ (const char*)GrayNgetSecretKey;
+ (BOOL)GrayNgetChargeLogSwitch;
#pragma mark- Common
+ (NSString*)GrayNgetCurrentMil_TimeString;
+ (NSString*)GrayNgetCurrentDate_Time;
+ (const char*)GrayNgetDeviceOsVersion;
+ (BOOL)GrayNgetDeviceIsJailBreak;
+ (const char*)GrayNgetDeviceMacAddress;
+ (const char*)GrayNgetDeviceIDFA;
+ (const char*)GrayNgetDeviceUniqueID;
+ (const char*)GrayNgetLocalLang:(const char*)GrayNinputData;
+ (void)GrayN_Debug_Log:(id)logs, ...;
+ (void)GrayN_Console_Log:(id)logs, ...;

+ (BOOL)GrayN_Debug_Mode;
+ (const char*)GrayNgetGame_RoleLevel;
+ (const char*)GrayNgetGame_RoleVipLevel;

/*5.1.4*/
+ (BOOL)GrayNhomeIndicator_AutoHidden;
+ (int)GrayNdeferring_SystemGestures;

+ (const char*)GrayNgetPayCallback_Url;
#pragma mark- GrayN_UserCenter
+ (const char*)GrayNgetGame_UserId;


#pragma mark- Appstore
+ (void)GrayNsetAppstoreUrl;

#pragma mark- OPPurchase
+ (const char*)GrayNget_SSID;
+ (const char*)GrayNget_ProductId;
+ (const char*)GrayNget_ProductNum;
+ (const char*)GrayNget_ProductName;
+ (const char*)GrayNget_ProductPrice;
+ (const char*)GrayNget_ProductRealName;
+ (const char*)GrayNget_ProductDescription;
+ (const char*)GrayNget_ExtendParams;
+ (const char*)GrayNget_CurrencyType;
+ (const char*)GrayNget_DeliveryUrl;

#pragma mark- GrayN_LoadingUI
+ (void)GrayNshow_Wait;
+ (void)GrayNclose_Wait;

#pragma mark- BaseControl
+ (UIWindow *)GrayNgetGame_Window;
+ (UIWindow *)GrayNgetSDK_Window;
@end
