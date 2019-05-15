//
//  JQPluginSDK.m
//  SDKDemo
//
//  Created by zhangwen on 2019/1/30.
//  Copyright © 2019 zhangwen. All rights reserved.
//

#import "JQPluginSDK.h"

#import <KingSDK/KingSDK.h>

@interface JQPluginSDK () <KingSDKDelegate>


@end

@implementation JQPluginSDK

+ (instancetype)sharedInstance
{
    static JQPluginSDK *instance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (void)initPluginSDK
{
    [KingSDKManager king_setResultDelegate:self];
    [KingSDKManager king_initSDK];
}

- (void)pluginSDKLogin
{
    [KingSDKManager king_login];
}

- (void)pluginSDKLogout
{
    [KingSDKManager king_logout];
}

- (void)pluginSDKSwitchAccount
{
    [KingSDKManager king_switchAccount];
}

- (void)pluginSDKSetResultDelegate:(id<JQPluginSDKDelegate>)delegate
{
    self.delegate = delegate;
}

- (void)setDebug:(BOOL)isDebug
{
    [KingSDKManager setDebug:isDebug];
}

- (void)pluginSDKGoodsBuyWithOrderId:(NSString *)orderId productCode:(NSString *)productCode amount:(NSString *)amount productName:(NSString *)productName serverId:(NSString *)serverId roleName:(NSString *)roleName roleLevel:(NSString *)roleLevel extraInfo:(NSString *)extraInfo
{
    KingSDKOrderInfo *orderInfo = [KingSDKOrderInfo initWithOrderId:orderId productCode:productCode amount:amount productName:productName serverId:serverId roleName:roleName roleLevel:roleLevel extraInfo:extraInfo];
    [KingSDKManager king_goodsBuyWithOrderInfo:orderInfo];
}

- (void)pluginSDKDataStatisticsWithRoleName:(NSString *)roleName roleLevel:(NSString *)roleLevel roleServerid:(NSString *)roleServerid
{
    KingSDKRoleInfo *roleInfo = [KingSDKRoleInfo initWithRoleName:roleName roleLevel:roleLevel roleServerid:roleServerid];
    [KingSDKManager king_dataStatisticsWithRoleInfo:roleInfo];
}

- (NSString *)pluginSDKGameAuditState
{
    return [KingSDKManager king_gameAuditState];
}

- (NSString *)pluginSDKWebGameUrlString
{
    return [KingSDKManager king_webGameUrlString];
}

- (void)pluginSDKOpenGameWorld
{
    [KingSDKManager king_openGameWorld];
}

#pragma mark - KingSDKDelegate
- (void)king_SDKInitSuccess
{
    NSLog(@"初始化成功");
    if (self.delegate && [self.delegate respondsToSelector:@selector(SDKInitSuccess)])
    {
        [self.delegate SDKInitSuccess];
    }
}

- (void)king_LoginDidSuccessWithUserInfo:(NSDictionary *)userInfo
{
    NSLog(@"登录成功");
    if (self.delegate && [self.delegate respondsToSelector:@selector(loginDidSuccessWithUserInfo:)])
    {
        [self.delegate loginDidSuccessWithUserInfo:userInfo];
    }
}

- (void)king_LogoutDidSuccess
{
    NSLog(@"登出成功");
    if (self.delegate && [self.delegate respondsToSelector:@selector(logoutDidSuccess)])
    {
        [self.delegate logoutDidSuccess];
    }
}

- (void)king_ResultIAPDidSuccess
{
    NSLog(@"内购支付成功");
    if (self.delegate && [self.delegate respondsToSelector:@selector(resultIAPDidSuccess)])
    {
        [self.delegate resultIAPDidSuccess];
    }
}

- (void)king_ResultIAPDidFailWithReason:(KingIAPFailReason)reason
{
    NSLog(@"内购支付失败，原因=%ld", (long)reason);
    if (self.delegate && [self.delegate respondsToSelector:@selector(resultIAPDidFail)])
    {
        [self.delegate resultIAPDidFail];
    }
}

@end
