//
//  OPSDK.m
//  OurpalmSDK
//
//  Created by op-mac1 on 15-6-17.
//  Copyright (c) 2015年 op-mac1. All rights reserved.
//

#import "appstoreSDK_GrayN.h"
//#import "OPAdmob.h"
#import "GrayNbaseSDK.h"
#import "GrayN_AppPurchase.h"
#import "GrayNjson_cpp.h"
#import "GrayN_Https_GrayN.h"
#import "GrayN_SynAppReceipt.h"

GrayNusing_NameSpace;
@implementation appstoreSDK_GrayN

- (NSDictionary*)getInterfaceInfo_GrayN
{
    NSNumber *on = [NSNumber numberWithInt:1];
    NSNumber *off = [NSNumber numberWithInt:0];
    NSMutableDictionary *dic = [[[NSMutableDictionary alloc] init] autorelease];
    [dic setValue:on forKey:@"IsLogin"];
    [dic setValue:on forKey:@"RegisterLogin"];
    [dic setValue:on forKey:@"Logout"];
    [dic setValue:on forKey:@"SwitchAccount"];
    [dic setValue:on forKey:@"EnterPlatform"];
    [dic setValue:off forKey:@"ShowPausePage"];
    [dic setValue:on forKey:@"UserFeedback"];
    [dic setValue:off forKey:@"EnterAppCenter"];
    [dic setValue:off forKey:@"EnterUserSetting"];
    [dic setValue:off forKey:@"EnterAppBBS"];
    [dic setValue:on forKey:@"ShowToolBar"];
    [dic setValue:on forKey:@"HideToolBar"];
    
    return dic;
}

- (void)preInitSDK_GrayN:(NSDictionary *)initParam;
{
    [super preInitSDK_GrayN:initParam];
    GrayN_AppPurchase::GetInstance().GrayN_AppPurchaseInit();
}

- (void)initSDK_GrayN
{
#ifdef CHECKORDER
    const char* httpHeader =  GrayN_Https_GrayN::m_GrayN_HeadDate.c_str();
#ifdef HTTPS
    GrayN_SynAppReceipt::GrayN_SynAppReceiptGetSystemTime(httpHeader);
#else
    GrayN_SynAppReceipt::GrayN_SynAppReceiptParseSystemTime(httpHeader);
#endif
#endif
    
    GrayN_AppPurchase::GetInstance().GrayN_AppPurchaseInitOver();
    /*10061.014*/
    /*10061.014*/

//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    [self notifyInitResult_GrayN:true];
//    });
}
- (void)registerLogin_GrayN
{
    [[GrayN_ChannelSDK GrayN_Share] notifyRegisterLogin_GrayN];
}
- (void)enterPlatform_GrayN
{
    [[GrayN_ChannelSDK GrayN_Share] notifyEnterPlatform_GrayN];
}
- (void)switchAccount_GrayN
{
    [[GrayN_ChannelSDK GrayN_Share] notifySwitchAccount_GrayN];
}
- (void)logout_GrayN
{
    [[GrayN_ChannelSDK GrayN_Share] notifyLogout_GrayN];
}

- (void)userFeedback_GrayN
{
    [[GrayN_ChannelSDK GrayN_Share] notifyUserFeedback_GrayN];
}
- (void)iapPayWithPayInfo_GrayN:(const char*)payData
{
    GrayN_JSON::Reader    json_reader;
    GrayN_JSON::Value     json_object;
    if (!json_reader.parse(payData, json_object)){
        NSLog(@"计费数据异常，无法解析！");

        return;//json格式解析错误
    }

    GrayN_AppPurchase::GetInstance().GrayN_AppPurchaseParseChargeInfo(json_object);
}



@end
