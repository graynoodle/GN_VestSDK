//
//  GrayN_ChannelSDK.h
//  OurpalmSDK
//
//  Created by op-mac1 on 15-5-21.
//  Copyright (c) 2015年 op-mac1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define BeNSString(_ptr_) [NSString stringWithUTF8String:_ptr_]

@interface GrayN_ChannelSDK : NSObject

+ (id)GrayN_Share;

/**
 *  SDK接口信息
 */
- (NSDictionary*)getInterfaceInfo_GrayN;
/**
 *  SDK启动接口
 */
- (BOOL)application_GrayN:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;

/**
 *  初始化第三方SDK
 */
- (void)preInitSDK_GrayN:(NSDictionary *)initParam;
- (void)initSDK_GrayN;

/**
 *  登录
 */
- (void)registerLogin_GrayN;

/**
 *  注销
 */
- (void)logout_GrayN;

/**
 * 切换账号
 */
- (void)switchAccount_GrayN;

/**
 * 用户中心
 */
- (void)enterPlatform_GrayN;

/**
 * 客服中心
 */
- (void)userFeedback_GrayN;
/**
 * 游戏BBS论坛
 */
- (void)EnterAppBBS_GrayN;
/**
 * 暂停页
 */
- (void)showPausePage_GrayN;

//***************************登录验证**************************

/**
 * 第三方登录验证成功后，将结果返回第三方SDK，例如渠道PP
 */
- (void)loginVerifyResult_GrayN:(BOOL)result resultInfo:(NSString*)info;


#pragma charge 计费
- (void)setGameLoginInfo_GrayN:(NSDictionary*)gameInfoDic;
- (void)iapPayWithPropInfo_GrayN:(NSDictionary*)propInfoDic;
- (void)iapPayWithPayInfo_GrayN:(const char*)payData;


#pragma mark- HandleOpenURL
- (BOOL)application_GrayN:(UIApplication *)application handleOpenURL:(NSURL *)url;
- (BOOL)application_GrayN:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;
- (void)applicationWillEnterForeground_GrayN:(UIApplication *)application;

#pragma mark- 屏幕方向
- (BOOL)applicationSupportedInterfaceOrientationsForWindow_GrayN;
- (UIInterfaceOrientationMask)application_GrayN:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window;
- (BOOL)shouldAutoRotate_GrayN;

/**
 * 通知
 */
- (void)notifyInitResult_GrayN:(bool)result;
- (void)notifyLoginResult_GrayN:(NSDictionary*)resultDic;
- (void)notifyPayResult_GrayN:(BOOL)result errorCode:(int)errorCode;
- (void)notifyLogoutResult_GrayN:(bool)result;
- (void)notifySwitchAccountResult_GrayN:(bool)result;

- (void)notifyRegisterLogin_GrayN;
- (void)notifyEnterPlatform_GrayN;
- (void)notifySwitchAccount_GrayN;
- (void)notifyLogout_GrayN;
- (void)notifyUserFeedback_GrayN;

#pragma 官网支付宝SDK支付
- (void)iapWithAliPay_GrayN:(NSString *)payInfo;
- (void)iapWithChannel_GrayN:(NSString *)channelName andInfos:(NSDictionary *)dic;
- (BOOL)iapWithAliPayApplication_GrayN:(UIApplication *)application
                         openURL:(NSURL *)url
               sourceApplication:(NSString *)sourceApplication
                      annotation:(id)annotation;
@end
