//
//  GrayNserviceCodeBridge.h
//
//  Created by JackYin on 3/11/16.
//  Copyright © 2016年 op-mac1. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GrayNserviceCodeBridge : NSObject

+ (void)GrayNsetSDKVersion:(NSString*)GrayNsdkVersion;
+ (NSString*)GrayNgetSDKVerison;

+ (void)GrayNsetDeviceIDFA:(NSString*)GrayNidfa;
+ (NSString*)GrayNgetDeviceIDFA;

+ (void)GrayNsetLoginIDFA:(NSString*)GrayNidfa;
+ (NSString*)GrayNgetLoginIDFA;

+ (bool)GrayNupdateServiceCode;

@end
