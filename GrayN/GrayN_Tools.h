//
//  OPUITools.h
//
//  Created by 韩征 on 15-1-26.
//  Copyright (c) 2015年 op-mac1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GrayN_UserInfo.h"
#import <iostream>

typedef void (^GrayN_UserInfoResponseCallBack)(id responseData);
typedef void (^GrayN_DeeplinkResponseCallback)(id responseData);
typedef void (^GrayN_GetSessionIdResponseCallback)(id responseData);

@interface GrayN_Tools : NSObject <UIAlertViewDelegate>
{
    void (^GrayNuserInfoCallback)(id responseData);
    void (^GrayNdeeplinkCallback)(id responseData);
    void (^GrayNsessionIdResponseCallback)(id responseData);
}
+ (id)share_GrayN;
- (void)GrayNsetUserInfoResponseCallBack:(GrayN_UserInfoResponseCallBack)handler;
- (void)GrayNsetDeeplinkResponseCallBack:(GrayN_DeeplinkResponseCallback)handler;
- (void)GrayNsetGetSessionIdResponseCallback:(GrayN_GetSessionIdResponseCallback)handler;


- (void)GrayNtriggerUserInfoResponse:(NSString *)response;
- (void)GrayNtriggerDeeplinkResponse:(NSString *)response;
- (void)GrayNtriggerGetSessionIdResponse:(NSString *)response;

/*增*/
+ (void)GrayNsaveUserInfo:(GrayN_UserInfo *)GrayN_UserInfo_GrayN;
/*删*/
+ (void)GrayNdelUserInfoWithKey:(NSString *)key value:(NSString *)value newUserId:(NSString *)userId;
+ (void)GrayNdelUserInfoWithUserId:(NSString *)userId;
/*改*/
+ (BOOL)GrayNmodifyUserInfoWithUserId:(NSString *)userId objectBeModfied:(NSArray *)object;
/*查*/
+ (GrayN_UserInfo *)GrayNloadLastUserInfo;
+ (NSString *)GrayNloadUsersInfo;
+ (NSArray *)GrayNloadUserInfoArray;
+ (GrayN_UserInfo *)GrayNloadUserInfoWithUserId:(NSString *)userId;
+ (GrayN_UserInfo *)GrayNloadUserInfoWithUserName:(NSString *)userName;

+ (void)GrayNsetAutoLoginStatus:(BOOL)ifAutoLogin;
+ (BOOL)GrayNgetAutoLoginStatus;


/*DES加解密*/
+ (NSString *)GrayNdesEncodeString:(NSString *)data;
+ (NSString *)GrayNdesDecodeString:(NSString *)data;

/*基本数据类型转换*/
+ (NSString *)GrayNarrayToJsonString:(NSArray *)array;
+ (NSString*)GrayNdictionaryToJsonString:(NSDictionary *)dic;

+ (NSString*)GrayNgetStrForCMS:(std::string)str base64UrlEncode:(BOOL)encode;
+ (NSString*)GrayNgetStrForCMS:(NSString*)str;

/*清app缓存*/
+ (void)GrayNclearAppCache;
/*删双账号*/
+ (void)GrayNdeleteDuplicateUserInfo;

/*5.2.1通过hex获取颜色*/
+ (UIColor *)GrayNcolorWithHexString:(NSString *)color alpha:(CGFloat)alpha;
@end
