//
//  OPLogHandler.h
//  OPLogHandler
//
//  Created by 韩征 on 15-3-25.
//  Copyright (c) 2015年 韩征. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OP2_LogHandler : NSObject

+ (id)SharedInstance;

//- (void)OPUncaughtException:(NSDictionary*)exception;
//- (void)OPSignalHandler:(NSDictionary*)exception;
- (void)OPCreateLogByBridge:(NSDictionary *)log;
@end
