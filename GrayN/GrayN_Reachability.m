/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Basic demonstration of how to use the SystemConfiguration Reachablity APIs.
 */

#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>
#import <sys/socket.h>
#import <netinet/in.h>

#import <CoreFoundation/CoreFoundation.h>
#import <UIKit/UIKit.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

#import "GrayN_Reachability.h"

#pragma mark IPv6 Support
//Reachability fully support IPv6.  For full details, see ReadMe.md.


NSString *e_GrayN_ReachabilityChangedNotification = @"kNetworkReachabilityChangedNotification";


#pragma mark - Supporting functions

//#define kShouldPrintReachabilityFlags 1

static void GrayN_PrintReachabilityFlags(SCNetworkReachabilityFlags GrayNflags, const char* GrayNcomment)
{
#if kShouldPrintReachabilityFlags
    
    NSLog(@"OPGameSDK LOG:\nReachability Flag Status: %c%c %c%c%c%c%c%c%c %s\n ",
          (flags & kSCNetworkReachabilityFlagsIsWWAN)               ? 'W' : '-',
          (flags & kSCNetworkReachabilityFlagsReachable)            ? 'R' : '-',
          
          (flags & kSCNetworkReachabilityFlagsTransientConnection)  ? 't' : '-',
          (flags & kSCNetworkReachabilityFlagsConnectionRequired)   ? 'c' : '-',
          (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic)  ? 'C' : '-',
          (flags & kSCNetworkReachabilityFlagsInterventionRequired) ? 'i' : '-',
          (flags & kSCNetworkReachabilityFlagsConnectionOnDemand)   ? 'D' : '-',
          (flags & kSCNetworkReachabilityFlagsIsLocalAddress)       ? 'l' : '-',
          (flags & kSCNetworkReachabilityFlagsIsDirect)             ? 'd' : '-',
          comment
          );
#endif
}


static void GrayN_ReachabilityCallback(SCNetworkReachabilityRef GrayNtarget, SCNetworkReachabilityFlags GrayNflags, void* GrayNinfo)
{
#pragma unused (GrayNtarget, GrayNflags)
    NSCAssert(GrayNinfo != NULL, @"info was NULL in ReachabilityCallback");
    NSCAssert([(__bridge NSObject*) GrayNinfo isKindOfClass: [GrayN_Reachability class]], @"info was wrong class in ReachabilityCallback");
    
    GrayN_Reachability* noteObject = (__bridge GrayN_Reachability *)GrayNinfo;
    // Post a notification to notify the client that the network reachability changed.
    [[NSNotificationCenter defaultCenter] postNotificationName: e_GrayN_ReachabilityChangedNotification object: noteObject];
}


#pragma mark - Reachability implementation

@implementation GrayN_Reachability
{
    SCNetworkReachabilityRef _reachabilityRef;
}

+ (instancetype)GrayNreachabilityWithHostName:(NSString *)GrayNhostName
{
    GrayN_Reachability* returnValue = NULL;
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, [GrayNhostName UTF8String]);
    if (reachability != NULL)
    {
        returnValue= [[self alloc] init];
        if (returnValue != NULL)
        {
            returnValue->_reachabilityRef = reachability;
        }
        else {
            CFRelease(reachability);
        }
    }
    return returnValue;
}


+ (instancetype)GrayNreachabilityWithAddress:(const struct sockaddr *)GrayNhostAddress
{
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, GrayNhostAddress);
    
    GrayN_Reachability* returnValue = NULL;
    
    if (reachability != NULL)
    {
        returnValue = [[self alloc] init];
        if (returnValue != NULL) {
            returnValue->_reachabilityRef = reachability;
        } else {
            CFRelease(reachability);
        }
    }
    return returnValue;
}


+ (instancetype)GrayNreachabilityForInternetConnection
{
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    return [self GrayNreachabilityWithAddress: (const struct sockaddr *) &zeroAddress];
}

#pragma mark reachabilityForLocalWiFi
//reachabilityForLocalWiFi has been removed from the sample.  See ReadMe.md for more information.
//+ (instancetype)reachabilityForLocalWiFi



#pragma mark - Start and stop notifier

- (BOOL)GrayNstartNotifier
{
    BOOL returnValue = NO;
    SCNetworkReachabilityContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
    
    if (SCNetworkReachabilitySetCallback(_reachabilityRef, GrayN_ReachabilityCallback, &context))
    {
        if (SCNetworkReachabilityScheduleWithRunLoop(_reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode))
        {
            returnValue = YES;
        }
    }
    
    return returnValue;
}


- (void)GrayNstopNotifier
{
    if (_reachabilityRef != NULL)
    {
        SCNetworkReachabilityUnscheduleFromRunLoop(_reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    }
}


- (void)dealloc
{
    [self GrayNstopNotifier];
    if (_reachabilityRef != NULL)
    {
        CFRelease(_reachabilityRef);
    }
}


#pragma mark - Network Flag Handling

- (GrayN_ReachabilityNetworkStatus)networkStatusForFlags:(SCNetworkReachabilityFlags)GrayNflags
{
    GrayN_PrintReachabilityFlags(GrayNflags, "networkStatusForFlags");
    if ((GrayNflags & kSCNetworkReachabilityFlagsReachable) == 0)
    {
        // The target host is not reachable.
        return k_GrayN_NotReachable;
    }
    
    GrayN_ReachabilityNetworkStatus returnValue = k_GrayN_NotReachable;
    
    if ((GrayNflags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
    {
        /*
         If the target host is reachable and no connection is required then we'll assume (for now) that you're on Wi-Fi...
         */
        returnValue = k_GrayN_ReachableViaWiFi;
    }
    
    if ((((GrayNflags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
         (GrayNflags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
    {
        /*
         ... and the connection is on-demand (or on-traffic) if the calling application is using the CFSocketStream or higher APIs...
         */
        
        if ((GrayNflags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
        {
            /*
             ... and no [user] intervention is needed...
             */
            returnValue = k_GrayN_ReachableViaWiFi;
        }
    }
    
    if ((GrayNflags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
    {
        /*
         ... but WWAN connections are OK if the calling application is using the CFNetwork APIs.
         */
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
        {
            
            CTTelephonyNetworkInfo * info = [[CTTelephonyNetworkInfo alloc] init];
            NSString *currentRadioAccessTechnology = info.currentRadioAccessTechnology;
            if (currentRadioAccessTechnology)
            {
                if ([currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyLTE])
                {
                    returnValue =  k_GrayN_ReachableVia4G;
                }
                else if ([currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyEdge] || [currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyGPRS])
                {
                    returnValue =  k_GrayN_ReachableVia2G;
                }
                else
                {
                    returnValue =  k_GrayN_ReachableVia3G;
                }
                return returnValue;
                
            }
        }
        
        if ((GrayNflags & kSCNetworkReachabilityFlagsTransientConnection) == kSCNetworkReachabilityFlagsTransientConnection)
        {
            if((GrayNflags & kSCNetworkReachabilityFlagsConnectionRequired) == kSCNetworkReachabilityFlagsConnectionRequired)
            {
                returnValue =  k_GrayN_ReachableVia2G;
                return returnValue;
            }
            returnValue =  k_GrayN_ReachableVia3G;
            return returnValue;
        }
        
    }
    
    return returnValue;
}


- (BOOL)GrayNconnectionRequired
{
    NSAssert(_reachabilityRef != NULL, @"connectionRequired called with NULL reachabilityRef");
    SCNetworkReachabilityFlags flags;
    
    if (SCNetworkReachabilityGetFlags(_reachabilityRef, &flags))
    {
        return (flags & kSCNetworkReachabilityFlagsConnectionRequired);
    }
    
    return NO;
}


- (GrayN_ReachabilityNetworkStatus)GrayNcurrentReachabilityStatus
{
    NSAssert(_reachabilityRef != NULL, @"currentNetworkStatus called with NULL SCNetworkReachabilityRef");
    GrayN_ReachabilityNetworkStatus returnValue = k_GrayN_NotReachable;
    SCNetworkReachabilityFlags flags;
    
    if (SCNetworkReachabilityGetFlags(_reachabilityRef, &flags))
    {
        returnValue = [self networkStatusForFlags:flags];
    }
    
    return returnValue;
}


@end
