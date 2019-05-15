//
//  JQPluginSDK.h
//  SDKDemo
//
//  Created by zhangwen on 2019/1/30.
//  Copyright © 2019 zhangwen. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JQPluginSDKDelegate <NSObject>

@optional
- (void)SDKInitSuccess;

- (void)loginDidSuccessWithUserInfo:(NSDictionary *)userInfo;

- (void)logoutDidSuccess;

- (void)resultIAPDidSuccess;

- (void)resultIAPDidFail;

@end

NS_ASSUME_NONNULL_BEGIN

@interface JQPluginSDK : NSObject

@property (nonatomic, weak) id<JQPluginSDKDelegate> delegate;

+ (instancetype)sharedInstance;
/**
 SDK初始化方法
 注意事项：请最好将该方法放在[window makeKeyAndVisible]后调用
 
 Unity调用时机：确保是在startUnity:方法调用后，即UnityController.mm文件中applicationDidBecomeActive:方法里调用的startUnity方法
 cocos2dx调用时机：AppController.mm文件中application:didFinishLaunchingWithOptions:方法里的[window makeKeyAndVisible]方法调用后
 */
- (void)initPluginSDK;

/**
 SDK登录方法
 */
- (void)pluginSDKLogin;

/**
 SDK登出方法
 游戏内如有登出按钮，可调用此接口
 */
- (void)pluginSDKLogout;

/**
 SDK切换账号接口
 游戏内如有切换账号按钮，可调用此接口
 */
- (void)pluginSDKSwitchAccount;

/**
 设置登录、支付回调
 
 @param delegate 回调接收对象
 */
- (void)pluginSDKSetResultDelegate:(id<JQPluginSDKDelegate>)delegate;

- (void)pluginSDKGoodsBuyWithOrderId:(NSString *)orderId productCode:(NSString *)productCode amount:(NSString *)amount productName:(NSString *)productName serverId:(NSString *)serverId roleName:(NSString *)roleName roleLevel:(NSString *)roleLevel extraInfo:(NSString *)extraInfo;

/**
 是否显示调试日志
 
 @param isDebug debug
 */
- (void)setDebug:(BOOL)isDebug;

- (void)pluginSDKDataStatisticsWithRoleName:(NSString *)roleName roleLevel:(NSString *)roleLevel roleServerid:(NSString *)roleServerid;

/**
 当前游戏状态
 
 @return 游戏状态 1:审核 0:正式
 */
- (NSString *)pluginSDKGameAuditState;

/**
 web游戏所需的地址，其余游戏可不关注
 
 @return web游戏url
 */
- (NSString *)pluginSDKWebGameUrlString;

/**
 打开游戏世界
 */
- (void)pluginSDKOpenGameWorld;

@end

NS_ASSUME_NONNULL_END
