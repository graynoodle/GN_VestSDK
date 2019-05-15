//
//  OPJQ.h
//  OurpalmSDK
//
//  Created by op-mac1 on 15-6-17.
//  Copyright (c) 2015年 op-mac1. All rights reserved.
//
#ifdef SDK_JQ
#import <Foundation/Foundation.h>
#import "GrayNchannelSDK.h"
//#import "JQPluginSDK.h"

@interface OPJQ : GrayN_ChannelSDK <JQPluginSDKDelegate>

- (NSDictionary*)getInterfaceInfo;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
- (void)initSDK;
- (void)registerLogin;
- (void)logout;
- (void)enterPlatform;
- (void)switchAccount;
- (void)userFeedback;
    
#pragma mark- Pay
- (void)setGameLoginInfo:(NSDictionary*)gameInfoDic;

- (void)iapPayWithPayInfo:(const char*)payData;
    
//// 界面旋转
//- (BOOL)applicationSupportedInterfaceOrientationsForWindow;
//- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window;
- (void)applicationWillEnterForeground:(UIApplication *)application;

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;

@end
#endif
