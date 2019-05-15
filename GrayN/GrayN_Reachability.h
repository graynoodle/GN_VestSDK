/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Basic demonstration of how to use the SystemConfiguration Reachablity APIs.
 */

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>


typedef enum : NSInteger
{
    k_GrayN_NotReachable = 0,
    k_GrayN_ReachableViaWiFi,
    k_GrayN_ReachableViaWWAN,
    k_GrayN_ReachableVia2G,
    k_GrayN_ReachableVia3G,
    k_GrayN_ReachableVia4G
} GrayN_ReachabilityNetworkStatus;

#pragma mark IPv6 Support
//Reachability fully support IPv6.  For full details, see ReadMe.md.

extern NSString *e_GrayN_ReachabilityChangedNotification;

@interface GrayN_Reachability : NSObject

/*!
 * Use to check the reachability of a given host name.
 */
+ (instancetype)GrayNreachabilityWithHostName:(NSString *)GrayNhostName;

/*!
 * Use to check the reachability of a given IP address.
 */
+ (instancetype)GrayNreachabilityWithAddress:(const struct sockaddr *)GrayNhostAddress;

/*!
 * Checks whether the default route is available. Should be used by applications that do not connect to a particular host.
 */
+ (instancetype)GrayNreachabilityForInternetConnection;


#pragma mark reachabilityForLocalWiFi
//reachabilityForLocalWiFi has been removed from the sample.  See ReadMe.md for more information.
//+ (instancetype)reachabilityForLocalWiFi;

/*!
 * Start listening for reachability notifications on the current run loop.
 */
- (BOOL)GrayNstartNotifier;
- (void)GrayNstopNotifier;

- (GrayN_ReachabilityNetworkStatus)GrayNcurrentReachabilityStatus;

/*!
 * WWAN may be available, but not active until a connection has been established. WiFi may require a connection for VPN on Demand.
 */
- (BOOL)GrayNconnectionRequired;

@end
