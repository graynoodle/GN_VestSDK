//
//  GrayNcommon_oc.m
//
//  Created by op-mac1 on 14-11-12.
//  Copyright (c) 2014年 op-mac1. All rights reserved.
//

#import <sys/types.h>
#import <sys/socket.h>
#import <ifaddrs.h>
#import <net/if.h>
#import <netdb.h>
#import <arpa/inet.h>

#import "GrayNcommon.h"
#import "GrayNcommon_oc.h"
#import "GrayN_Reachability.h"

GrayNusing_NameSpace;

static CGRect p_GrayNscreenRect;
static CTTelephonyNetworkInfo *p_GrayNinfo = nil;

@implementation GrayNcommon_oc

+ (void)init_GrayNcommon_oc
{
    CGSize tSize = [UIScreen mainScreen].bounds.size;
    GrayNcommon::GrayN_DebugLog(@"[UIScreen mainScreen].bounds=%@",NSStringFromCGRect([UIScreen mainScreen].bounds));
    tSize = CGSizeMake(MIN(tSize.width, tSize.height), MAX(tSize.width, tSize.height));
    p_GrayNscreenRect = CGRectMake(0, 0, tSize.width, tSize.height);
}

+ (CGRect)screen_GrayN_Rect
{
    return p_GrayNscreenRect;
}

//添加网络变更通知
+ (void)add_GrayN_NetWorkChangedNotification
{
    GrayN_Reachability* reach = [GrayN_Reachability GrayNreachabilityForInternetConnection];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(netWork_GrayN_Info)
                                                 name:e_GrayN_ReachabilityChangedNotification object:nil];
    
    [reach GrayNstartNotifier];
}

+ (void)netWork_GrayN_Info
{
    GrayNcommon::GrayNcheckNetworkType();
}

+ (CTTelephonyNetworkInfo *)shared_GrayN_NetworkInstance
{
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        p_GrayNinfo = [[CTTelephonyNetworkInfo alloc] init];
    });
    return p_GrayNinfo;
}



@end
