//
//  GrayN_ChannelSDK.m
//  OurpalmSDK
//
//  Created by op-mac1 on 15-5-21.
//  Copyright (c) 2015年 op-mac1. All rights reserved.
//

#import "GrayNchannelSDK.h"
#import "GrayNbaseSDK.h"
#import "GrayNconfig.h"
#import "GrayNchannelConfig.h"

#ifdef SDK_OP
#import "OPAlipay.h"
#import "OPJDPay.h"
#import "OPSDK.h"
#elif SDK_APPSTORE
#import "appstoreSDK_GrayN.h"
#elif SDK_PP
#import "OPPP.h"
#elif SDK_iTools
#import "OPiTools.h"
#elif SDK_TB
#import "OPTB.h"
#elif SDK_KY
#import "OPKY.h"
#elif SDK_XX
#import "OPXX.h"
#elif SDK_NewHM
#import "OPNewHM.h"
#elif SDK_iApple
#import "OPiApple.h"
#elif SDK_i4
#import "OPi4.h"
#elif SDK_XY
#import "OPXY.h"
#elif SDK_L8
#import "OPL8.h"
#elif SDK_Rekoo
#import "OPRekoo.h"
#elif SDK_91
#import "OP91.h"
#elif SDK_UC
#import "OPUC.h"
#elif SDK_Uwan
#import "OPUwan.h"
#elif SDK_YXZX
#import "OPYXZX.h"
#elif SDK_9377
#import "OP9377.h"
#elif SDK_YXF
#import "OPYXF.h"
#elif SDK_JQ
#import "OPJQ.h"
#elif SDK_ZongSi
#import "OPZongSi.h"
#elif SDK_HW2
#import "OPHW2.h"
#elif SDK_BuFan
#import "OPBuFan.h"
#else

#endif


static GrayN_ChannelSDK * _sharedInstance;

@implementation GrayN_ChannelSDK

+ (id)GrayN_Share
{
    @synchronized ([GrayN_ChannelSDK class]) {
        if (_sharedInstance == nil) {
#ifdef SDK_OP
            _sharedInstance = [[OPSDK alloc] init];
#elif SDK_APPSTORE
            _sharedInstance = [[appstoreSDK_GrayN alloc] init];
#elif SDK_PP
            _sharedInstance = [[OPPP alloc] init];
#elif SDK_iTools
            _sharedInstance = [[OPiTools alloc] init];
#elif SDK_TB
            _sharedInstance = [[OPTB alloc] init];
#elif SDK_KY
            _sharedInstance = [[OPKY alloc] init];
#elif SDK_XX
            _sharedInstance = [[OPXX alloc] init];
#elif SDK_NewHM
            _sharedInstance = [[OPNewHM alloc] init];
#elif SDK_iApple
            _sharedInstance = [[OPiApple alloc] init];
#elif SDK_i4
            _sharedInstance = [[OPi4 alloc] init];
#elif SDK_XY
            _sharedInstance = [[OPXY alloc] init];
#elif SDK_L8
            _sharedInstance = [[OPL8 alloc] init];
#elif SDK_Rekoo
            _sharedInstance = [[OPRekoo alloc] init];
#elif SDK_91
            _sharedInstance = [[OP91 alloc] init];
#elif SDK_UC
            _sharedInstance = [[OPUC alloc] init];
#elif SDK_Uwan
            _sharedInstance = [[OPUwan alloc] init];
#elif SDK_YXZX
            _sharedInstance = [[OPYXZX alloc] init];
#elif SDK_9377
            _sharedInstance = [[OP9377 alloc] init];
#elif SDK_YXF
            _sharedInstance = [[OPYXF alloc] init];
#elif SDK_JQ
            _sharedInstance = [[OPJQ alloc] init];
#elif SDK_ZongSi
            _sharedInstance = [[OPZongSi alloc] init];
#elif SDK_HW2
            _sharedInstance = [[OPHW2 alloc] init];
#elif SDK_BuFan
            _sharedInstance = [[OPBuFan alloc] init];
#else
            
#endif
            [GrayNbaseSDK GrayNsetSDKVersion:GrayN_SDK_ChannelVersion];
            [GrayNbaseSDK GrayNsetUserPlatformID:GrayN_User_PlatformId];
        }
        return _sharedInstance;
    }
}
- (NSDictionary*)getInterfaceInfo_GrayN
{
    return nil;
}
- (BOOL)application_GrayN:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    return YES;
}

- (void)initSDK_GrayN
{
    NSLog(@"GrayN_ChannelSDK initSDK");
}
- (void)preInitSDK_GrayN:(NSDictionary *)initParam;
{

}


- (void)registerLogin_GrayN
{
    
}

- (void)logout_GrayN
{
    
}

- (void)switchAccount_GrayN
{
    
}

- (void)enterPlatform_GrayN
{

}
- (void)userFeedback_GrayN
{
    
}

- (void)EnterAppBBS_GrayN
{
    
}
- (void)showPausePage_GrayN
{
    
}

#pragma 登录验证
- (void)loginVerifyResult_GrayN:(BOOL)result resultInfo:(NSString*) info
{
    if (result) {
        NSLog(@"GrayN_ChannelSDK loginVerifyResult success,resultInfo=%@",info);
    }else{
        NSLog(@"GrayN_ChannelSDK loginVerifyResult failed,resultInfo=%@",info);
    }
}

- (void)setGameLoginInfo_GrayN:(NSDictionary*)gameInfoDic
{
//    self.gameRoleId = [gameInfoDic objectForKey:@"roleId"];
//    self.gameRoleName = [gameInfoDic objectForKey:@"roleName"];
//    self.gameServerId = [gameInfoDic objectForKey:@"serverId"];
//    self.webHeaderDic = [gameInfoDic objectForKey:@"webHeader"];
}

- (void)iapPayWithPropInfo_GrayN:(NSDictionary*)propInfoDic
{
//    self.ssId = [propInfoDic objectForKey:@"ssId"];
//    self.propNum = [propInfoDic objectForKey:@"propNum"];
//    self.propName = [propInfoDic objectForKey:@"propName"];
//    self.propPrice = [propInfoDic objectForKey:@"propPrice"];
//    self.realPropName = [propInfoDic objectForKey:@"realPropName"];
}

- (void)iapPayWithPayInfo_GrayN:(const char*)payData
{
    
}

- (BOOL)application_GrayN:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return YES;
}

- (BOOL)application_GrayN:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{

    return YES;
}
- (void)applicationWillEnterForeground_GrayN:(UIApplication *)application
{
    
}
- (BOOL)applicationSupportedInterfaceOrientationsForWindow_GrayN
{
    return NO;
}

- (UIInterfaceOrientationMask)application_GrayN:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return UIInterfaceOrientationMaskAll;
}
- (BOOL)shouldAutoRotate_GrayN
{
    return YES;
}

#
- (void)notifyRegisterLogin_GrayN
{
    [GrayNbaseSDK GrayNregisterLogin];
}
- (void)notifyEnterPlatform_GrayN
{
    [GrayNbaseSDK GrayNenterPlatform];
}
- (void)notifySwitchAccount_GrayN
{
    [GrayNbaseSDK GrayNswitchAccount];
}
- (void)notifyLogout_GrayN
{
    [GrayNbaseSDK GrayNlogout];
}
- (void)notifyUserFeedback_GrayN
{
    [GrayNbaseSDK GrayNuserFeedback];
}
- (void)notifyInitResult_GrayN:(bool)result
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [GrayNbaseSDK GrayNcallBackInit:result];
    });
}

- (void)notifyLoginResult_GrayN:(NSDictionary*)resultDic
{
    [GrayNbaseSDK GrayNcallBackLogin:resultDic];
}

- (void)notifyPayResult_GrayN:(BOOL)result errorCode:(int)errorCode
{
    NSString *desc = @"";
    switch (errorCode) {
        case GrayN_Charge_SUCCESS_ERROR:
            desc = BeNSString(GrayN_Charge_SUCCESS_ERRORDESC);
            break;
        case GrayN_Charge_ORDERSUCCESS_ERROR:
            desc = BeNSString(GrayN_Charge_ORDERSUCCESS_ERRORDESC);
            break;
        case GrayN_Charge_FAILED_ERROR:
            desc = BeNSString(GrayN_Charge_FAILED_ERRORDESC);
            break;
        case GrayN_Charge_USERCANCEL_ERROR:
            desc = BeNSString(GrayN_Charge_USERCANCEL_ERRORDESC);
            break;
        case GrayN_Charge_LOGIN_STATUS_ERROR:
            desc = BeNSString(GrayN_Charge_LOGIN_STATUS_ERRORDESC);
            break;
        case GrayN_Charge_BILL_ILLEGAL_ERROR:
            desc = BeNSString(GrayN_Charge_BILL_ILLEGAL_ERRORDESC);
            break;
        default:
            break;
    }
    NSString *reset = [NSString stringWithFormat:@"%d", errorCode];
    NSDictionary *resultDic = [NSDictionary dictionaryWithObjectsAndKeys:
                               desc,@"desc",
                               reset,@"reset",nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [GrayNbaseSDK GrayNcallBackPayResult:result data:resultDic];
    });
}

- (void)notifyLogoutResult_GrayN:(bool)result
{
    [GrayNbaseSDK GrayNcallBackLogout:result];
}

- (void)notifySwitchAccountResult_GrayN:(bool)result
{
    [GrayNbaseSDK GrayNcallBackSwitchAccount:result];
}

#pragma 官网支付宝SDK支付
#ifdef SDK_OP
- (void)iapWithAliPay_GrayN:(NSString*)payInfo
{
    [OPAlipay aliPay:payInfo];
}
- (void)iapWithChannel_GrayN:(NSString *)channelName andInfos:(NSDictionary *)dic
{
    if ([channelName isEqualToString:@"JDPay"]) {
        [OPJDPay jdPay:dic];
    }
}
#pragma 官网京东SDK支付

//- (BOOL)iapWithAliPayApplication_GrayN:(UIApplication *)application
//                         openURL:(NSURL *)url
//               sourceApplication:(NSString *)sourceApplication
//                      annotation:(id)annotation
//{
//    return [OPAlipay application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
//}
#endif

@end
