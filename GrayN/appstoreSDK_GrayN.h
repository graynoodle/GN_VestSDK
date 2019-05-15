//
//  OPSDK.h
//  OurpalmSDK
//
//  Created by op-mac1 on 15-6-17.
//  Copyright (c) 2015年 op-mac1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GrayNchannelSDK.h"
#import "GrayN_Store_IAP.h"

@interface appstoreSDK_GrayN : GrayN_ChannelSDK

- (NSDictionary*)getInterfaceInfo_GrayN;

- (void)initSDK_GrayN;

- (void)registerLogin_GrayN;
- (void)logout_GrayN;
- (void)enterPlatform_GrayN;
- (void)switchAccount_GrayN;
- (void)userFeedback_GrayN;


- (void)iapPayWithPayInfo_GrayN:(const char*)payData;


@end
