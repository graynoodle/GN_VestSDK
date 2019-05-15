//
//  GrayNCommon.h
//
//  Created by op-mac1 on 14-11-12.
//  Copyright (c) 2014年 op-mac1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

@interface GrayNcommon_oc : NSObject

+ (void)init_GrayNcommon_oc;
+ (CGRect)screen_GrayN_Rect;
+ (void)add_GrayN_NetWorkChangedNotification;
+ (CTTelephonyNetworkInfo *)shared_GrayN_NetworkInstance;

@end
