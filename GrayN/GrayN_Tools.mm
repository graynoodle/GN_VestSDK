//
//  OPUITools.m
//
//  Created by 韩征 on 15-1-26.
//  Copyright (c) 2015年 op-mac1. All rights reserved.
//

#import "GrayN_Tools.h"
#import "GrayNSDK.h"
#import "GrayNbaseSDK.h"
#import "GrayN_Offical.h"
#import "GrayN_BaseControl.h"

#define DEBUG

static GrayN_Tools * p_GrayN_Tools_share;
@implementation GrayN_Tools

+ (id)share_GrayN
{
    @synchronized ([GrayN_Tools class]) {
        if (p_GrayN_Tools_share == nil) {
            p_GrayN_Tools_share = [[GrayN_Tools alloc] init];

        }
    }
    return p_GrayN_Tools_share;
}
- (void)GrayNsetUserInfoResponseCallBack:(GrayN_UserInfoResponseCallBack)handler
{
    [GrayNuserInfoCallback release];
    GrayNuserInfoCallback = [handler copy];
}
- (void)GrayNsetDeeplinkResponseCallBack:(GrayN_DeeplinkResponseCallback)handler
{
    [GrayNdeeplinkCallback release];
    GrayNdeeplinkCallback = [handler copy];
}
- (void)GrayNsetGetSessionIdResponseCallback:(GrayN_GetSessionIdResponseCallback)handler
{
    [GrayNsessionIdResponseCallback release];
    GrayNsessionIdResponseCallback = [handler copy];
}
- (void)GrayNtriggerUserInfoResponse:(NSString *)response
{
    GrayNuserInfoCallback(response);
}
- (void)GrayNtriggerDeeplinkResponse:(NSString *)response
{
    GrayNdeeplinkCallback(response);
}
- (void)GrayNtriggerGetSessionIdResponse:(NSString *)response
{
    if (GrayNsessionIdResponseCallback == nil) {
        GrayNcommon::GrayN_ConsoleLog(@"未设置OPGameSDK::GetInstance().RefreshTokenIdCallBack");
        return;
    }
    GrayNsessionIdResponseCallback(response);
}
#pragma mark - 用户信息处理
#pragma mark /*保存用户信息*/
+ (void)GrayNsaveUserInfo:(GrayN_UserInfo *)GrayN_UserInfo_GrayN
{
//    if (GrayN_UserInfo_GrayN.userId == nil || [GrayN_UserInfo_GrayN.userId isEqualToString:@""]) {
//#ifdef DEBUG
//        GrayNcommon::GrayN_DebugLog(@"userId is nil，saving failed");
//#endif
//        return;
//    }
    
    NSMutableArray *usersInfo = [[[NSMutableArray alloc] initWithArray:[GrayN_Tools GrayNloadUserInfoArray]] autorelease];
    // 除掉同名账户
    for (NSMutableDictionary *info in usersInfo) {

        if ([[info objectForKey:@"userId"] isEqualToString:GrayN_UserInfo_GrayN.userId] && ![GrayN_UserInfo_GrayN.userId isEqualToString:@""]) {
            if ([GrayN_UserInfo_GrayN.password isEqualToString:@""]) {
                GrayN_UserInfo_GrayN.password = [info objectForKey:@"password"];
                [GrayN_UserInfo_GrayN.GrayN_UserInfo_GrayN setObject:GrayN_UserInfo_GrayN.password forKey:@"password"];
#ifdef DEBUG
                GrayNcommon::GrayN_DebugLog(@"%@",GrayN_UserInfo_GrayN.GrayN_UserInfo_GrayN);
#endif
            }
            [usersInfo removeObject:info];
            break;
        }
    }
    [GrayN_UserInfo_GrayN GrayN_FormatJson];
#ifdef DEBUG
    GrayNcommon::GrayN_DebugLog(@"GrayN_UserInfo_GrayN.GrayN_UserInfo_GrayN = %@",GrayN_UserInfo_GrayN.GrayN_UserInfo_GrayN);
#endif
    [usersInfo addObject:GrayN_UserInfo_GrayN.GrayN_UserInfo_GrayN];
    [GrayN_Tools saveOPUserInfoData:usersInfo];
}
/*保存NSData对象*/
+ (void)saveOPUserInfoData:(id)target
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *userInfoData = [NSKeyedArchiver archivedDataWithRootObject:target];
    [userDefaults setObject:userInfoData forKey:@"GrayN_UserInfo_GrayN"];
    [userDefaults synchronize];
}
#pragma mark /*读取用户信息*/
+ (GrayN_UserInfo *)GrayNloadLastUserInfo
{
    NSMutableArray *usersInfo = [[[NSMutableArray alloc] initWithArray:[GrayN_Tools GrayNloadUserInfoArray]] autorelease];
    
    GrayN_UserInfo *GrayN_UserInfo_GrayN = [[[GrayN_UserInfo alloc] init] autorelease];
    [GrayN_UserInfo_GrayN GrayN_SetUserInfo:[usersInfo lastObject]];
    return GrayN_UserInfo_GrayN;
}
+ (NSString *)GrayNloadUsersInfo
{
    NSArray *userInfoArr = [[[NSArray alloc] initWithArray:[GrayN_Tools GrayNloadUserInfoArray]] autorelease];
    
    NSMutableArray *usersInfo = [[NSMutableArray alloc] init];
    if (userInfoArr.count == 0) {
        return @"";
    }
    for (int i=0; i<=userInfoArr.count-1; i++) {
        // 隐藏密码
        NSMutableDictionary *opUserInfoDic = [userInfoArr objectAtIndex:userInfoArr.count-1-i];
        [opUserInfoDic setObject:@"" forKey:@"password"];

        GrayN_UserInfo *GrayN_UserInfo_GrayN = [[[GrayN_UserInfo alloc] init] autorelease];
        [GrayN_UserInfo_GrayN GrayN_SetUserInfo:opUserInfoDic];
        [GrayN_UserInfo_GrayN GrayN_FormatJson];
        [usersInfo addObject:[GrayN_UserInfo_GrayN.GrayN_UserInfo_GrayN objectForKey:@"jsonInfo"]];
    }
    return [GrayN_Tools GrayNarrayToJsonString:usersInfo];
}
/*获取用户列表数组*/
+ (NSArray *)GrayNloadUserInfoArray
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *userInfoData = [userDefaults objectForKey:@"GrayN_UserInfo_GrayN"];
    if (userInfoData == nil || ![userInfoData isKindOfClass:[NSData class]]) {
#ifdef DEBUG
        GrayNcommon::GrayN_DebugLog(@"用户列表为空");
#endif
        return nil;
    }
    NSArray *userInfoArray = [[[NSArray alloc] initWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:userInfoData]] autorelease];
//    NSLog(@"GrayNloadUserInfoArray=%@", userInfoArray);
    return userInfoArray;
}
+ (GrayN_UserInfo *)GrayNloadUserInfoWithUserId:(NSString *)userId
{
    NSArray *userInfoArr = [[[NSArray alloc] initWithArray:[GrayN_Tools GrayNloadUserInfoArray]] autorelease];
    NSMutableArray *usersInfo = [[[NSMutableArray alloc] initWithArray:userInfoArr] autorelease];
    GrayN_UserInfo *GrayN_UserInfo_GrayN = [[[GrayN_UserInfo alloc] init] autorelease];
    // 查询具体用户信息
    for (NSDictionary *info in usersInfo) {
        if ([[info objectForKey:@"userId"] isEqualToString:userId]) {
            [GrayN_UserInfo_GrayN GrayN_SetUserInfo:info];
            GrayNcommon::GrayN_DebugLog(@"选择的userId为：%@",userId);
            break;
        }
    }
    return GrayN_UserInfo_GrayN;
}
+ (GrayN_UserInfo *)GrayNloadUserInfoWithUserName:(NSString *)userName
{
    NSArray *userInfoArr = [[[NSArray alloc] initWithArray:[GrayN_Tools GrayNloadUserInfoArray]] autorelease];
    NSMutableArray *usersInfo = [[[NSMutableArray alloc] initWithArray:userInfoArr] autorelease];
    GrayN_UserInfo *GrayN_UserInfo_GrayN = [[[GrayN_UserInfo alloc] init] autorelease];
    // 查询具体用户信息
    for (NSDictionary *info in usersInfo) {
        if ([[info objectForKey:@"userName"] isEqualToString:userName]) {
            [GrayN_UserInfo_GrayN GrayN_SetUserInfo:info];
#ifdef DEBUG
            GrayNcommon::GrayN_DebugLog(@"选择的userName为：%@",userName);
#endif
            break;
        }
    }
    return GrayN_UserInfo_GrayN;
}

#pragma mark /*删除用户信息*/
+ (void)GrayNdelUserInfoWithKey:(NSString *)key value:(NSString *)value newUserId:(NSString *)userId
{
    NSArray *userInfoArr = [[[NSArray alloc] initWithArray:[GrayN_Tools GrayNloadUserInfoArray]] autorelease];
    NSMutableArray *usersInfo = [[[NSMutableArray alloc] initWithArray:userInfoArr] autorelease];
    // 删除账户
    for (NSDictionary *info in usersInfo) {
        if ([[info objectForKey:key] isEqualToString:value]) {
            if (![[info objectForKey:@"userId"] isEqualToString:@""]) {
                // 用户id不为空 保留该账号
                continue;
            }
            [usersInfo removeObject:info];

            // 本地userId为空，传入的userId不为空，将老账号密码复制到新账号中
            if (![userId isEqualToString:@""]) {
                GrayN_UserInfo *GrayN_UserInfo_GrayN = [[[GrayN_UserInfo alloc] init] autorelease];
                NSMutableDictionary *userInfo = [[[NSMutableDictionary alloc] init] autorelease];
                [userInfo setObject:[info objectForKey:@"password"] forKey:@"password"];
                [userInfo setObject:userId forKey:@"userId"];
                [GrayN_UserInfo_GrayN GrayN_SetUserInfo:userInfo];
                [GrayN_UserInfo_GrayN GrayN_FormatJson];
                GrayNcommon::GrayN_DebugLog(@"新添的账号：%@", GrayN_UserInfo_GrayN.GrayN_UserInfo_GrayN);

                [usersInfo addObject:GrayN_UserInfo_GrayN.GrayN_UserInfo_GrayN];
            }
#ifdef DEBUG
            GrayNcommon::GrayN_DebugLog(@"删除的%@为：%@", key, value);
#endif
            break;
        }
    }
    [GrayN_Tools saveOPUserInfoData:usersInfo];
}
+ (void)GrayNdelUserInfoWithUserId:(NSString *)userId
{
    NSArray *userInfoArr = [[[NSArray alloc] initWithArray:[GrayN_Tools GrayNloadUserInfoArray]] autorelease];
    NSMutableArray *usersInfo = [[[NSMutableArray alloc] initWithArray:userInfoArr] autorelease];
    // 删除账户
    for (NSDictionary *info in usersInfo) {
        if ([[info objectForKey:@"userId"] isEqualToString:userId]) {
            [usersInfo removeObject:info];
#ifdef DEBUG
            GrayNcommon::GrayN_DebugLog(@"删除的userId为：%@",userId);
#endif
            break;
        }
    }
    [GrayN_Tools saveOPUserInfoData:usersInfo];
}
/*删双账号*/
+ (void)GrayNdeleteDuplicateUserInfo
{
    NSArray *userInfoArr = [[[NSArray alloc] initWithArray:[GrayN_Tools GrayNloadUserInfoArray]] autorelease];
    NSMutableArray *usersInfo = [[[NSMutableArray alloc] initWithArray:userInfoArr] autorelease];
    
    for (int i=0; i<usersInfo.count; i++) {
        NSString *tmpUserName = [[usersInfo objectAtIndex:i] objectForKey:@"userName"];
        for (int j=i+1; j<usersInfo.count; j++) {
            NSString *compareName = [[usersInfo objectAtIndex:j] objectForKey:@"userName"];
            if ([tmpUserName isEqualToString:compareName]) {
                GrayN_UserInfo *tmpUserInfo = [[[GrayN_UserInfo alloc] init] autorelease];
                [tmpUserInfo GrayN_SetUserInfo:[usersInfo objectAtIndex:i]];
                if ([tmpUserInfo.userId isEqualToString:@""]) {
                    GrayNcommon::GrayN_DebugLog(@"删除的用户名为%@\n用户信息：%@",
                                       [[usersInfo objectAtIndex:i] objectForKey:@"userName"],
                                       [usersInfo objectAtIndex:i]);
                    [usersInfo removeObjectAtIndex:i];
                    i--;
                } else {
                    GrayNcommon::GrayN_DebugLog(@"删除的用户名为%@\n用户信息：%@",
                                       [[usersInfo objectAtIndex:j] objectForKey:@"userName"],
                                       [usersInfo objectAtIndex:j]);
                    [usersInfo removeObjectAtIndex:j];
                }
                break;
            }
        }
    }

    [GrayN_Tools saveOPUserInfoData:usersInfo];
}
#pragma mark /*修改用户信息*/
+ (BOOL)GrayNmodifyUserInfoWithUserId:(NSString *)userId objectBeModfied:(NSArray *)object
{
    NSArray *userInfoArr = [[[NSArray alloc] initWithArray:[GrayN_Tools GrayNloadUserInfoArray]] autorelease];
    NSMutableArray *usersInfo = [[[NSMutableArray alloc] initWithArray:userInfoArr] autorelease];
#ifdef DEBUG
    GrayNcommon::GrayN_DebugLog(@"修改前的用户数据\n%@",userInfoArr);
#endif
    NSMutableDictionary *GrayN_UserInfo_GrayN = nil;
    NSInteger index = 0;
    for (;index<usersInfo.count;) {
        NSDictionary *info = [usersInfo objectAtIndex:index];
        if ([[info objectForKey:@"userId"] isEqualToString:userId]) {
            GrayN_UserInfo_GrayN = [[[NSMutableDictionary alloc] initWithDictionary:info] autorelease];
            break;
        }
        ++index;
    }
    
    // 快登绑定需创建新账号信息
    if (index == usersInfo.count)  {
        GrayN_UserInfo_GrayN = [[[NSMutableDictionary alloc] init] autorelease];
        [GrayN_UserInfo_GrayN setObject:userId forKey:@"userId"];
    }
    
    for (NSDictionary *attribute in object) {
        NSString *key = [attribute objectForKey:@"key"];
        NSString *value = [attribute objectForKey:@"value"];
        [GrayN_UserInfo_GrayN setObject:value forKey:key];
#ifdef DEBUG
        GrayNcommon::GrayN_DebugLog(@"invokeSdkUserModify_____%@_____Notify-localinfo%@", key, GrayN_UserInfo_GrayN);
#endif
    }
#ifdef DEBUG
    GrayNcommon::GrayN_DebugLog(@"%@",GrayN_UserInfo_GrayN);
#endif
    [GrayN_UserInfo_GrayN removeObjectForKey:@"jsonInfo"];
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:GrayN_UserInfo_GrayN options:NSJSONWritingPrettyPrinted error:&parseError];
    if (parseError) {
        return NO;
    }
    
    NSString *jsonInfo = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    jsonInfo = [jsonInfo stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
    jsonInfo = [jsonInfo stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    jsonInfo = [jsonInfo stringByReplacingOccurrencesOfString:@" " withString:@""];
    [GrayN_UserInfo_GrayN setObject:jsonInfo forKey:@"jsonInfo"];
    
    
    
    if (index == usersInfo.count) {
        [usersInfo addObject:GrayN_UserInfo_GrayN];
    } else {
        [usersInfo replaceObjectAtIndex:index withObject:GrayN_UserInfo_GrayN];
    }
    
    [GrayN_Tools saveOPUserInfoData:usersInfo];
    
    return YES;
}
#pragma mark - 自动登录状态
+ (void)GrayNsetAutoLoginStatus:(BOOL)ifAutoLogin
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:ifAutoLogin forKey:@"OPifAutoLogin"];
    [userDefaults synchronize];
}
+ (BOOL)GrayNgetAutoLoginStatus
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL isQuickLogin = [userDefaults boolForKey:@"OPifAutoLogin"];
    return isQuickLogin;
}

+ (NSString *)GrayNdesEncodeString:(NSString *)data
{
    NSString *encryptStr = [GrayNbaseSDK GrayNencodeDES:data];
    return encryptStr;
}
+ (NSString *)GrayNdesDecodeString:(NSString *)data
{
    NSString *decryptStr = [GrayNbaseSDK GrayNdecodeDES:data];
//    GrayNcommon::GrayN_DebugLog(@"___________decrypt______________");
//    GrayNcommon::GrayN_DebugLog(@"%@", decryptStr);
//    GrayNcommon::GrayN_DebugLog(@"___________decrypt______________");
    if ([decryptStr isEqual:[NSNull null]] ||
        decryptStr == nil ||
        decryptStr == NULL) {
//#ifdef DEBUG
        GrayNcommon::GrayN_DebugLog(@"__________NullNullNull__________");
//#endif
        return @"";
    }
    return decryptStr;
}
#pragma mark - /*基本数据类型转换*/
+ (NSString *)GrayNarrayToJsonString:(NSArray *)array
{
    NSMutableString *reString = [[[NSMutableString alloc] init] autorelease];
        GrayNcommon::GrayN_DebugLog(@"%@", array);
    [reString appendString:@"["];
    [reString appendFormat:@"%@",[array componentsJoinedByString:@","]];
    [reString appendString:@"]"];
    return reString;
}
+ (NSString*)GrayNdictionaryToJsonString:(NSDictionary *)dic
{
    NSError *parseError = nil;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    
    NSString *tmp = [[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] autorelease];
    NSString *jsonInfo = [NSString stringWithString:tmp];
    jsonInfo = [jsonInfo stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
    jsonInfo = [jsonInfo stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    jsonInfo = [jsonInfo stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    return jsonInfo;
}
#pragma mark - /*工具*/
+ (NSString*)GrayNgetStrForCMS:(std::string)str base64UrlEncode:(BOOL)encode
{
    if (str == "") {
        return @"0";
    } else {
        if (encode) {
            string dataEncode = ourpalmpay::GrayNcommon::GrayN_Encode_Base64_UrlEncode(str.c_str());
            return [NSString stringWithUTF8String:dataEncode.c_str()];
        } else {
            return [NSString stringWithUTF8String:str.c_str()];
        }
    }
}
+ (NSString*)GrayNgetStrForCMS:(NSString*)str
{
    if (str == nil || str == NULL || [str isEqualToString:@""] ||
        [str isEqual:[NSNull null]]) {
        return @"0";
    } else {
        return str;
    }
}
+ (void)GrayNclearAppCache
{
    NSArray *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *path = [cachePath objectAtIndex:0];
    
    NSArray *files = [[NSFileManager defaultManager] subpathsAtPath:path];
    for (NSString *p in files) {
        NSError *error;
        NSString *Path = [path stringByAppendingPathComponent:p];
        if ([Path rangeOfString:@"ApplicationCache.db"].location != NSNotFound) {
            GrayNcommon::GrayN_DebugLog(@"%@", Path);
            BOOL res=[[NSFileManager defaultManager] removeItemAtPath:Path error:&error];
            if (res)
                GrayNcommon::GrayN_DebugLog(@"文件删除成功");
            else
                GrayNcommon::GrayN_DebugLog(@"文件删除失败");
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        GrayN_Offical::GetInstance().GrayN_Offical_Update();
    } else {
        
    }
}
+ (UIColor *)GrayNcolorWithHexString:(NSString *)color alpha:(CGFloat)alpha
{
    //删除字符串中的空格
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    // String should be 6 or 8 characters
    if ([cString length] < 6)
    {
        return [UIColor clearColor];
    }
    // strip 0X if it appears
    //如果是0x开头的，那么截取字符串，字符串从索引为2的位置开始，一直到末尾
    if ([cString hasPrefix:@"0X"])
    {
        cString = [cString substringFromIndex:2];
    }
    //如果是#开头的，那么截取字符串，字符串从索引为1的位置开始，一直到末尾
    if ([cString hasPrefix:@"#"])
    {
        cString = [cString substringFromIndex:1];
    }
    if ([cString length] != 6)
    {
        return [UIColor clearColor];
    }
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    //r
    NSString *rString = [cString substringWithRange:range];
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    return [UIColor colorWithRed:((float)r / 255.0f) green:((float)g / 255.0f) blue:((float)b / 255.0f) alpha:alpha];
}

@end
