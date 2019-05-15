//
//  GrayN_UserInfo.h
//
//  Created by lolo on 16/6/17.
//  Copyright © 2016年 op-mac1. All rights reserved.
//

#ifndef OPUserInfo_h
#define OPUserInfo_h

#import <UIKit/UIKit.h>
@interface GrayN_UserInfo : NSObject

@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *userPlatformId;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *palmId;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString *loginType;
@property (nonatomic, copy) NSString *originalUserType;
@property (nonatomic, copy) NSString *currentUserType;
@property (nonatomic, copy) NSString *bindPhone;
@property (nonatomic, copy) NSString *bindEmail;
@property (nonatomic, copy) NSString *bindTokenId;
@property (nonatomic, copy) NSString *needBindPhone;
@property (nonatomic, copy) NSString *isLimit;
@property (nonatomic, copy) NSString *limitDesc;
@property (nonatomic, copy) NSString *deviceId;
@property (nonatomic, copy) NSString *loginTime;
@property (nonatomic, copy) NSDictionary *returnJson;
@property (nonatomic, copy) NSString *identityAuthStatus;
@property (nonatomic, copy) NSString *identityAuthIdNum;
@property (nonatomic, copy) NSString *identityAuthRealName;
@property (nonatomic, retain) NSMutableDictionary *GrayN_UserInfo_GrayN;
//@property (nonatomic, copy) NSString *jsonInfo;

- (void)GrayN_SetUserInfo:(NSDictionary *)GrayNuserInfo;
- (void)GrayN_FormatJson;

@end
#endif /* OPUserInfo_h */
