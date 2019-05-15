//
//  GrayN_UserInfo.m
//
//  Created by lolo on 16/6/17.
//  Copyright © 2016年 op-mac1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GrayN_UserInfo.h"
#import "GrayN_Tools.h"

@implementation GrayN_UserInfo
@synthesize userId          = _userId;
@synthesize userPlatformId  = _userPlatformId;
@synthesize userName        = _userName;
@synthesize password        = _password;
@synthesize palmId          = _palmId;
@synthesize nickName        = _nickName;
@synthesize loginType       = _loginType;
@synthesize originalUserType= _originalUserType;
@synthesize currentUserType = _currentUserType;
@synthesize bindPhone       = _bindPhone;
@synthesize bindEmail       = _bindEmail;
@synthesize bindTokenId     = _bindTokenId;
@synthesize needBindPhone   = _needBindPhone;
@synthesize isLimit         = _isLimit;
@synthesize limitDesc       = _limitDesc;
@synthesize deviceId        = _deviceId;
@synthesize loginTime       = _loginTime;
@synthesize returnJson      = _returnJson;
@synthesize identityAuthStatus  = _identityAuthStatus;
@synthesize identityAuthIdNum   = _identityAuthIdNum;
@synthesize identityAuthRealName= _identityAuthRealName;
@synthesize GrayN_UserInfo_GrayN      = _GrayN_UserInfo_GrayN;

- (void)GrayN_SetUserInfo:(NSDictionary *)GrayNuserInfo
{
//    NSLog(@"GrayN_SetUserInfo = %@",GrayN_UserInfo_GrayN);
    self.GrayN_UserInfo_GrayN = [NSMutableDictionary dictionaryWithDictionary:GrayNuserInfo];
    [self GrayN_LoadOPUserInfo];
}
- (id)init
{
    if((self = [super init])) {
        
        self.userId          = @"";
        self.userPlatformId  = @"";
        self.userName        = @"";
        self.password        = @"";
        self.palmId          = @"";
        self.nickName        = @"";
        self.loginType       = @"";
        self.originalUserType= @"";
        self.currentUserType = @"";
        self.bindPhone       = @"";
        self.bindEmail       = @"";
        self.bindTokenId     = @"";
        self.needBindPhone   = @"";
        self.isLimit         = @"";
        self.limitDesc       = @"";
        self.deviceId        = @"";
        self.loginTime       = @"";
        self.returnJson      = nil;
        self.identityAuthStatus     = @"";
        self.identityAuthIdNum      = @"";
        self.identityAuthRealName   = @"";
        self.GrayN_UserInfo_GrayN      = [[[NSMutableDictionary alloc] init] autorelease];
    }
    
    return self;
}
- (id)getValueByKey:(NSString *)key
{
//    NSLog(@"%@",[_GrayN_UserInfo_GrayN objectForKey:key]);
    if ([_GrayN_UserInfo_GrayN objectForKey:key] != nil &&
        [_GrayN_UserInfo_GrayN objectForKey:key] != NULL &&
        ![[_GrayN_UserInfo_GrayN objectForKey:key] isEqual:[NSNull null]]) {
        return [_GrayN_UserInfo_GrayN objectForKey:key];
    } else {
        [self.GrayN_UserInfo_GrayN setObject:@"" forKey:key];
        return @"";
    }
}
- (void)GrayN_LoadOPUserInfo
{
    self.userId          = [self getValueByKey:@"userId"];
    self.userPlatformId  = [self getValueByKey:@"userPlatformId"];
    self.userName        = [self getValueByKey:@"userName"];
    self.password        = [self getValueByKey:@"password"];
    self.palmId          = [self getValueByKey:@"palmId"];
    self.nickName        = [self getValueByKey:@"nickName"];
    self.loginType       = [self getValueByKey:@"loginType"];
    self.originalUserType= [self getValueByKey:@"originalUserType"];
    self.currentUserType = [self getValueByKey:@"currentUserType"];
    self.bindPhone       = [self getValueByKey:@"bindPhone"];
    self.bindEmail       = [self getValueByKey:@"bindEmail"];
    self.bindTokenId     = [self getValueByKey:@"bindTokenId"];
    self.needBindPhone   = [self getValueByKey:@"needBindPhone"];
    self.isLimit         = [self getValueByKey:@"isLimit"];
    self.limitDesc       = [self getValueByKey:@"limitDesc"];
    self.deviceId        = [self getValueByKey:@"deviceId"];
    self.loginTime       = [self getValueByKey:@"loginTime"];
    self.returnJson      = [_GrayN_UserInfo_GrayN objectForKey:@"returnJson"];
    self.identityAuthStatus     = [self getValueByKey:@"identityAuthStatus"];
    self.identityAuthIdNum      = [self getValueByKey:@"identityAuthIdNum"];
    self.identityAuthRealName   = [self getValueByKey:@"identityAuthRealName"];
}

- (void)GrayN_FormatJson
{
    NSError *parseError = nil;
    
    // 需要先把jsonInfo去掉，否则jsonInfo会无限增多
    [_GrayN_UserInfo_GrayN removeObjectForKey:@"jsonInfo"];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:_GrayN_UserInfo_GrayN options:NSJSONWritingPrettyPrinted error:&parseError];
    NSString *jsonInfo = [[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] autorelease];
    
    jsonInfo = [jsonInfo stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
    jsonInfo = [jsonInfo stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    jsonInfo = [jsonInfo stringByReplacingOccurrencesOfString:@" " withString:@""];

    [_GrayN_UserInfo_GrayN setObject:jsonInfo forKey:@"jsonInfo"];
}

- (void)dealloc
{
    [_GrayN_UserInfo_GrayN release];
    _GrayN_UserInfo_GrayN = nil;
    
    [super dealloc];
}
@end
