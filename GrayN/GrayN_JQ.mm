//
//  OPJQ.m
//  OurpalmSDK
//
//  Created by op-mac1 on 15-6-17.
//  Copyright (c) 2015年 op-mac1. All rights reserved.
///Users/graynoodle/Desktop/01_SDKProject/OurpalmSDK_5.0/OurpalmSDK/OurpalmSDK/Channel/JQ/OPJQ.mm
#ifdef SDK_JQ
#import "GrayN_JQ.h"
#import "GrayNbaseSDK.h"
#import "OPConfig.h"
static BOOL mIsLogout;
@implementation OPJQ 

- (NSDictionary*)getInterfaceInfo
{
    NSNumber *on = [NSNumber numberWithInt:1];
    NSNumber *off = [NSNumber numberWithInt:0];
    NSMutableDictionary *dic = [[[NSMutableDictionary alloc] init] autorelease];
    [dic setValue:on forKey:@"IsLogin"];
    [dic setValue:on forKey:@"RegisterLogin"];
    [dic setValue:on forKey:@"Logout"];
    [dic setValue:on forKey:@"SwitchAccount"];
    [dic setValue:off forKey:@"EnterPlatform"];
    [dic setValue:off forKey:@"ShowPausePage"];
    [dic setValue:on forKey:@"UserFeedback"];
    [dic setValue:off forKey:@"EnterAppCenter"];
    [dic setValue:off forKey:@"EnterUserSetting"];
    [dic setValue:off forKey:@"EnterAppBBS"];
    [dic setValue:off forKey:@"ShowToolBar"];
    [dic setValue:off forKey:@"HideToolBar"];
    
    return dic;
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(userKillGame)
//                                                 name:UIApplicationWillTerminateNotification
//                                               object:nil];
    [[JQPluginSDK sharedInstance] pluginSDKSetResultDelegate:self];
//    [XQTApiManager setResultDelegate:self];
//    [XQTApiManager setDebug:[OPBaseSDK debugModel]];
    
    return YES;
}
- (void)userKillGame
{
    
}
- (void)initSDK
{
    [[JQPluginSDK sharedInstance] initPluginSDK];

//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//    });
}

- (void)registerLogin
{
    [[JQPluginSDK sharedInstance] pluginSDKLogin];
}
- (void)enterPlatform
{
    [[OPChannelSDK ShareInstance] notifyEnterPlatform];
}
- (void)switchAccount
{
    mIsLogout = NO;
    [[JQPluginSDK sharedInstance] pluginSDKSwitchAccount];
}
- (void)logout
{
    mIsLogout = YES;
    [[JQPluginSDK sharedInstance] pluginSDKLogout];
}

- (void)userFeedback
{
    [[OPChannelSDK ShareInstance] notifyUserFeedback];
}
- (void)applicationWillEnterForeground:(UIApplication *)application
{

}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{

    return YES;
}
#pragma mark- Pay
    - (void)setGameLoginInfo:(NSDictionary*)gameInfoDic
    {
        NSString *gameRoleId = [gameInfoDic objectForKey:@"roleId"];
        NSString *gameRoleName = [gameInfoDic objectForKey:@"roleName"];
        NSString *gameServerId = [gameInfoDic objectForKey:@"serverId"];
        NSString *serverName = [gameInfoDic objectForKey:@"serverName"];
        NSString *roleLevel = [gameInfoDic objectForKey:@"roleLevel"];
        NSString *roleVipLevel = [gameInfoDic objectForKey:@"roleVipLevel"];
        int gameType = [[gameInfoDic objectForKey:@"gameType"] intValue];
        NSLog(@"roleId=%@roleName=%@serverId=%@serverName=%@roleLevel=%@roleVipLevel=%@gameType=%d", gameRoleId,
              gameRoleName,
              gameServerId,
              serverName,
              roleLevel,
              roleVipLevel,
              gameType);
        
        [[JQPluginSDK sharedInstance] pluginSDKDataStatisticsWithRoleName:gameRoleName roleLevel:roleLevel roleServerid:gameServerId];
    }
- (void)iapPayWithPayInfo:(const char*)payData
{
        NSError *parseError = nil;
        NSString *payDataStr = [NSString stringWithUTF8String:payData];
        NSData *pay_Data = [payDataStr dataUsingEncoding:NSUTF8StringEncoding];
        
        NSDictionary *payInfoDic = [NSJSONSerialization JSONObjectWithData:pay_Data    options:NSJSONReadingMutableContainers error:&parseError];
        
        if (parseError) {
            NSLog(@"iapPayWithPayInfoParseError");
            return;
        }
        
        NSLog(@"%@", payInfoDic);
        NSString *priceStr = [payInfoDic objectForKey:@"combinePrice"];
        //    NSString *ssid
        int price = [priceStr intValue];
        if (price == -1) {
            price = [[NSString stringWithUTF8String:[OPBaseSDK GetPropPrice]] intValue];
        }
        price = price/100;
    
    NSString *ssId = [NSString stringWithUTF8String:[OPBaseSDK GetSSID]];
    NSString *realPropName = [NSString stringWithUTF8String:[OPBaseSDK GetRealPropName]];
    NSString *paymentId = [NSString stringWithUTF8String:[OPBaseSDK GetPropId]];
    NSString *serverId = [NSString stringWithUTF8String:[OPBaseSDK GetServerId]];
    NSString *roleLevel = [NSString stringWithUTF8String:[OPBaseSDK GetRoleLevel]];
    NSString *roleName = [NSString stringWithUTF8String:[OPBaseSDK GetGame_RoleName]];

//        NSLog(@"%@\n%@\n%@\n",ssId, realPropName, notifyUrl);
    
//    KingSDKOrderInfo *orderInfo = [KingSDKOrderInfo initWithOrderId:ssId productCode:paymentId amount:[NSString stringWithFormat:@"%d", price] productName:realPropName serverId:serverId roleName:roleName roleLevel:roleLevel extraInfo:ssId];
//    [XQTApiManager goodsBuyWithOrderInfo:orderInfo];
    [[JQPluginSDK sharedInstance] pluginSDKGoodsBuyWithOrderId:ssId productCode:paymentId amount:[NSString stringWithFormat:@"%d", price] productName:realPropName serverId:serverId roleName:roleName roleLevel:roleLevel extraInfo:ssId];
}
- (void)SDKInitSuccess
{
    NSLog(@"JQ初始化成功");
    [self notifyInitResult:true];

}
- (void)loginDidSuccessWithUserInfo:(NSDictionary *)userInfo
{
    NSLog(@"====================== Login Success =====================");
    NSLog(@"%@", userInfo);
    NSString* uid = [userInfo objectForKey:@"uid"];
    NSString* userName = [userInfo objectForKey:@"userName"];
    NSString* token = [userInfo objectForKey:@"token"];

    if (uid != nil) {
        // 处理登录成功的结果
        NSString *verifyJson = [NSString stringWithFormat:@"{\"uid\"=\"%@\",\"userName\"=\"%@\",\"token\"=\"%@\"}", uid, userName, token];
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1],@"result",verifyJson,@"verifyJson", nil];
        [self notifyLoginResult:dic];
    } else {
        // 处理登录失败的结果
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:0],@"result",@"",@"verifyJson", nil];
        [self notifyLoginResult:dic];
    }

}

-(void)loginFail
{
    NSLog(@"demo login fail....................");
    // 处理登录失败的结果
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:0],@"result",@"",@"verifyJson", nil];
    [self notifyLoginResult:dic];
}
- (void)logoutDidSuccess
{
    NSLog(@"demo logout success....................");
    if (mIsLogout) {
        [self notifyLogoutResult:true];
    } else {
        [self notifySwitchAccountResult:true];
    }
}
- (void)resultIAPDidSuccess
{
    NSLog(@"demo pay success....................");
    [self notifyPayResult:YES errorCode:OPCharge_ORDERSUCCESS_ERROR];

}
- (void)resultIAPDidFail
{
    NSLog(@"resultIAPDidFailWithReason Fail");
    [self notifyPayResult:NO errorCode:OPCharge_FAILED_ERROR];

}
@end
#endif
