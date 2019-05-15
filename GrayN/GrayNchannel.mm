//
//  GrayNchannel.cpp
//  GrayNbaseSDK
//
//  Created by op-mac1 on 15-5-6.
//  Copyright (c) 2015年 op-mac1. All rights reserved.
//
#import <UIKit/UIKit.h>

#import "GrayNchannel.h"
#import "GrayNbaseSDK.h"
#import "GrayN_BaseControl.h"
#import "GrayNpayCenter.h"
#import "GrayNSDK.h"
#import "GrayN_Offical.h"
#import "GrayNchannelSDK.h"
#import "GrayNinit.h"


GrayNusing_NameSpace;
using namespace std;

GrayNchannel::GrayNchannel()
{
    p_GrayN_IsOfficialCharge = false;
    m_GrayN_IsLogining = false;
}

GrayNchannel::~GrayNchannel()
{
    
}
void GrayNchannel::GrayN_PreInit()
{
    [GrayN_ChannelSDK GrayN_Share];
    static BOOL isInit = false;
    if (!isInit) {
        isInit = true;
        GrayNcommon::m_GrayN_SDKVersion.insert(0, ".");
        GrayNcommon::m_GrayN_SDKVersion.insert(0, GrayNbaseVersion);
    };
    
    
    GrayNcommon::GrayN_ConsoleLog("opSDK_Version=%s", GrayNcommon::m_GrayN_SDKVersion.c_str());
}
const char* GrayNchannel::GrayN_GetEnable_Interface()
{
    if (p_GrayN_FuctionDes.length()) {
        return p_GrayN_FuctionDes.c_str();
    }
    
    NSDictionary *dic = [[GrayN_ChannelSDK GrayN_Share] getInterfaceInfo_GrayN];
    
    if (dic==nil) {
        return p_GrayN_FuctionDes.c_str();
    }
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    NSString *jsonString = [[[NSString alloc] initWithData:jsonData
                                                 encoding:NSUTF8StringEncoding] autorelease];
    p_GrayN_FuctionDes = [jsonString UTF8String];
    return p_GrayN_FuctionDes.c_str();
}

void GrayNchannel::GrayN_ChannelCustomService()
{
    [[GrayN_ChannelSDK GrayN_Share] userFeedback_GrayN];
}
void GrayNchannel::GrayN_ChannelInit()
{
    [[GrayN_BaseControl GrayN_Share] GrayN_SetGameWindow];

    // 用户中心初始化
    GrayN_SDK_Init::GetInstance().GrayN_GetInitInfo();
    
    NSMutableDictionary *initParam = [[[NSMutableDictionary alloc] init] autorelease];
    NSNumber *debugModel = [NSNumber numberWithBool:GrayNcommon::m_GrayNdebug_Mode];
    [initParam setObject:debugModel forKey:@"debugModel"];
    NSNumber *autoOrientation = [NSNumber numberWithBool:GrayNcommon::m_GrayN_ScreenIsAutoRotation];
    [initParam setObject:autoOrientation forKey:@"autoOrientation"];
    NSNumber *gameOnline = [NSNumber numberWithBool:atoi(GrayNcommon::m_GrayN_GameType.c_str())];
    [initParam setObject:gameOnline forKey:@"gameOnline"];
    NSNumber *screenOrientation = [NSNumber numberWithInt:GrayNcommon::m_GrayN_SDKOrientation];
    [initParam setObject:screenOrientation forKey:@"screenOrientation"];

    [[GrayN_ChannelSDK GrayN_Share] preInitSDK_GrayN:initParam];
    
}

void GrayNchannel::GrayN_ChannelInitOver()
{
    // 初始化完成开始用户中心心跳
    GrayN_UserCenter::GetInstance().GrayN_UserCenter_StopHeartBeat();
    GrayN_UserCenter::GetInstance().GrayN_UserCenter_StartHeartBeat();
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // 渠道初始化
        [[GrayN_ChannelSDK GrayN_Share] initSDK_GrayN];
    });
}

void GrayNchannel::GrayN_ChannelLogin()
{
    GrayNcommon::GrayN_ConsoleLog(@"RegisterLogin()");
    m_GrayN_IsLogining = true;
    [[GrayN_ChannelSDK GrayN_Share] registerLogin_GrayN];
}

void GrayNchannel::GrayN_SetLoginStatus(bool status)
{
#ifdef DEBUG
    cout<<"GrayNchannel::GrayN_SetLoginStatus()"<<endl;
#endif
    p_GrayN_ChannelLoginStatus = status;
}

bool GrayNchannel::GrayN_ChannelIsLogin()
{
#ifdef DEBUG
    cout<<"GrayNchannel::GrayN_ChannelIsLogin()"<<endl;
#endif
    return p_GrayN_ChannelLoginStatus;
}

void GrayNchannel::GrayN_ChannelLogout()
{
    GrayNcommon::GrayN_ConsoleLog(@"Logout()");

    [[GrayN_ChannelSDK GrayN_Share] logout_GrayN];
}

void GrayNchannel::GrayN_ChannelSetGameLoginInfo(OPGameInfo opParam,OPGameType opGameType)
{
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    [data setObject:[NSString stringWithUTF8String:opParam.mGame_RoleId.c_str()] forKey:@"roleId"];
    [data setObject:[NSString stringWithUTF8String:opParam.mGame_ServerId.c_str()] forKey:@"serverId"];
    [data setObject:[NSString stringWithUTF8String:opParam.mGame_RoleName.c_str()] forKey:@"roleName"];
    [data setObject:[NSString stringWithUTF8String:opParam.mGame_ServerName.c_str()] forKey:@"serverName"];
    [data setObject:[NSString stringWithUTF8String:opParam.mGame_RoleLevel.c_str()] forKey:@"roleLevel"];
    [data setObject:[NSString stringWithUTF8String:opParam.mGame_RoleVipLevel.c_str()] forKey:@"roleVipLevel"];
    [data setObject:[NSString stringWithUTF8String:opParam.mGame_OriginalRoleName.c_str()] forKey:@"originName"];
    [data setObject:[NSString stringWithUTF8String:opParam.mGame_OriginalRoleLevel.c_str()] forKey:@"originLevel"];
    [data setObject:[NSString stringWithUTF8String:opParam.mGame_OriginalRoleVipLevel.c_str()] forKey:@"originVipLevel"];
    [data setObject:[NSString stringWithFormat:@"%d", opGameType] forKey:@"gameType"];
    
    [[GrayN_ChannelSDK GrayN_Share] setGameLoginInfo_GrayN:data];
}
// 解析渠道具体验证
void GrayNchannel::GrayN_ChannelParseChargeInfo(GrayN_JSON::Value chargeInfoJson)
{
    GrayN_JSON::FastWriter fast_writer;
    string chargeInfo = fast_writer.write(chargeInfoJson);
//    GrayNcommon::GrayN_DebugLog("GrayN_ChannelParseChargeInfo=%s", chargeInfo.c_str());
    [[GrayN_ChannelSDK GrayN_Share] iapPayWithPayInfo_GrayN:chargeInfo.c_str()];
}

void GrayNchannel::GrayN_ChannelParseChargeInfo(int chargeType,GrayN_JSON::Value chargeInfoJson)
{
//    cout<<"m_GrayN_SDK_IdentityStatus"<<GrayNSDK::m_GrayN_SDK_IdentityStatus<<endl;
//    cout<<"m_GrayN_SDK_PayIdentityAuth"<<GrayNSDK::m_GrayN_SDK_PayIdentityAuth<<endl;

    if (chargeType == 0) {
        // 官网
        if (GrayNSDK::m_GrayN_SDK_ForceTouristBindSwitch) {
            string::size_type idx = GrayNcommon::m_GrayN_CurrentUserType.find("speedy");
            if ( idx !=string::npos)
                GrayN_Offical::GetInstance().GrayN_Offical_ShowPayUpgradeView();
            else {
                /*5.1.4*/
                if (atoi(GrayNSDK::m_GrayN_SDK_PayIdentityAuth.c_str()) &&
                    (GrayNSDK::m_GrayN_SDK_IdentityStatus == "-1" || GrayNSDK::m_GrayN_SDK_IdentityStatus == "0")) {
                    GrayN_Offical::GetInstance().GrayN_Offical_ShowPayUpgradeView();
                } else {
                    GrayN_Offical::GetInstance().GrayN_Offical_ShowChargeView();
                }
            }
        } else {
            /*5.1.9*/
            if (atoi(GrayNSDK::m_GrayN_SDK_PayIdentityAuth.c_str()) &&
                (GrayNSDK::m_GrayN_SDK_IdentityStatus == "-1" || GrayNSDK::m_GrayN_SDK_IdentityStatus == "0")) {
                GrayN_Offical::GetInstance().GrayN_Offical_ShowPayUpgradeView();
            } else {
                GrayN_Offical::GetInstance().GrayN_Offical_ShowChargeView();
            }
        }
    } else if (chargeType == 1) {
//        cout<<GrayNSDK::m_GrayN_SDK_SandBoxSwitch<<endl;
//        cout<<GrayNSDK::m_GrayN_SDK_ForceTouristBindSwitch<<endl;

        if (GrayNSDK::m_GrayN_SDK_SandBoxSwitch == 0 && GrayNSDK::m_GrayN_SDK_ForceTouristBindSwitch == 1) {
            string::size_type idx = GrayNcommon::m_GrayN_CurrentUserType.find("speedy");
            if (idx !=string::npos)
                GrayN_Offical::GetInstance().GrayN_Offical_ShowPayUpgradeView();
            else {
                /*5.1.4*/
                if (atoi(GrayNSDK::m_GrayN_SDK_PayIdentityAuth.c_str()) &&
                    (GrayNSDK::m_GrayN_SDK_IdentityStatus == "-1" || GrayNSDK::m_GrayN_SDK_IdentityStatus == "0")) {
                    GrayN_Offical::GetInstance().GrayN_Offical_ShowPayUpgradeView();
                } else {
                    GrayN_ChannelParseChargeInfo(chargeInfoJson);
                }
            }
        } else {
            /*5.1.4*/

            if (GrayNSDK::m_GrayN_SDK_SandBoxSwitch) {
                GrayN_ChannelParseChargeInfo(chargeInfoJson);
            } else {
                string::size_type idx = GrayNcommon::m_GrayN_CurrentUserType.find("speedy");

                if (atoi(GrayNSDK::m_GrayN_SDK_PayIdentityAuth.c_str()) &&
                    (GrayNSDK::m_GrayN_SDK_IdentityStatus == "-1" || GrayNSDK::m_GrayN_SDK_IdentityStatus == "0") && idx ==string::npos) {
                    GrayN_Offical::GetInstance().GrayN_Offical_ShowPayUpgradeView();
                } else {
                    GrayN_ChannelParseChargeInfo(chargeInfoJson);
                }
            }
        }
    }
}

//#pragma mark - 掌趣官网模块
void GrayNchannel::GrayN_ChannelEnterPlatform()
{
    GrayNcommon::GrayN_ConsoleLog(@"EnterPlatform()");

    [[GrayN_ChannelSDK GrayN_Share] enterPlatform_GrayN];
}

//在游戏暂停或者从后台恢复的时候显示暂停页
void GrayNchannel::GrayN_ChannelShowPausePage()
{
    GrayNcommon::GrayN_ConsoleLog(@"ShowPausePage()");

    [[GrayN_ChannelSDK GrayN_Share] showPausePage_GrayN];
}

//切换账号
void GrayNchannel::GrayN_ChannelSwitchAccount()
{
    GrayNcommon::GrayN_ConsoleLog(@"SwitchAccount()");

    [[GrayN_ChannelSDK GrayN_Share] switchAccount_GrayN];
}
/*5.2.0 debug开关*/
void GrayNchannel::GrayN_ChannelCheckHandleOpenURL(void* url)
{
    NSURL *u = (NSURL *)url;
    if ([u.absoluteString rangeOfString:@"opDebugSwitch"].location != NSNotFound) {
        GrayNcommon::m_GrayNforceDebug_Mode = true;
        GrayNcommon::m_GrayNdebug_Mode = YES;
    
        [[GrayNbaseSDK GrayNgetGame_Window] addSubview:GrayNcommon::GrayNgetDebugView()];
    }
}
/*5.2.0*/

bool GrayNchannel::GrayN_ChannelHandleOpenUrl(void* url)
{
    return [[GrayN_ChannelSDK GrayN_Share] application_GrayN:nil handleOpenURL:(NSURL *)url];
}

void GrayNchannel::GrayN_ChannelHandleOpenUrl(void* url, void* application)
{
    [[GrayN_ChannelSDK GrayN_Share] application_GrayN:(UIApplication *)application handleOpenURL:(NSURL *)url];
}

bool GrayNchannel::GrayN_ChannelHandleOpenUrl(void* application,void* url,void* sourceApplication,void* annotation)
{
    if (p_GrayN_IsOfficialCharge)
        p_GrayN_IsOfficialCharge = false;
    return [[GrayN_ChannelSDK GrayN_Share] application_GrayN:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation];
}

bool GrayNchannel::GrayN_ChannelApplicationDidFinishLaunchingWithOptions(void *application,void *launchOptions)
{
    return [[GrayN_ChannelSDK GrayN_Share] application_GrayN:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions];
}

bool GrayNchannel::GrayN_ChannelApplicationSupportedInterfaceOrientationsForWindow()
{
    return [[GrayN_ChannelSDK GrayN_Share] applicationSupportedInterfaceOrientationsForWindow_GrayN];
}

unsigned int GrayNchannel::GrayN_ChannelApplicationSupportedInterfaceOrientationsForWindow(void *application,void *window)
{
    return (unsigned int)[[GrayN_ChannelSDK GrayN_Share] application_GrayN:(UIApplication *)application  supportedInterfaceOrientationsForWindow:(UIWindow *)window];
}
bool GrayNchannel::GrayN_ChannelShouldAutoRotate()
{
    SEL sel = NSSelectorFromString(@"shouldAutoRotate_GrayN");
    if([[GrayN_ChannelSDK GrayN_Share] respondsToSelector:sel]) {
//        GrayNcommon::GrayN_DebugLog(@"第三方SDK已实现shouldAutoRotate");
        return [[GrayN_ChannelSDK GrayN_Share] shouldAutoRotate_GrayN];
    } else {
//        GrayNcommon::GrayN_DebugLog(@"第三方SDK未实现shouldAutoRotate");
        return GrayNcommon::m_GrayN_ScreenIsAutoRotation;
//        return YES;
    }
}
void GrayNchannel::GrayN_ChannelApplicationWillEnterForeground(id application)
{
    SEL sel = NSSelectorFromString(@"applicationWillEnterForeground_GrayN:");
    if([[GrayN_ChannelSDK GrayN_Share] respondsToSelector:sel]) {
//        GrayNcommon::GrayN_DebugLog(@"第三方SDK已实现applicationWillEnterForeground");
        [[GrayN_ChannelSDK GrayN_Share] applicationWillEnterForeground_GrayN:(UIApplication *)application];
    } else {
//        GrayNcommon::GrayN_DebugLog(@"第三方SDK未实现applicationWillEnterForeground");
    }
}
