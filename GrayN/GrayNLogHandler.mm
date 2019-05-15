//
//  OPLogHandler.m
//  OPLogHandler
//
//  Created by 韩征 on 15-3-25.
//  Copyright (c) 2015年 韩征. All rights reserved.
//

#import "GrayNLogHandler.h"
#import "GrayNlogCenter.h"
GrayNusing_NameSpace;
static OP2_LogHandler * _sharedInstance;

@interface OP2_LogHandler ()

@end

@implementation OP2_LogHandler

+ (id)SharedInstance
{
    @synchronized ([OP2_LogHandler class]) {
        if (_sharedInstance == nil) {
            _sharedInstance = [[OP2_LogHandler alloc] init];
        }
    }
    return _sharedInstance;
}
//- (void)OPUncaughtException:(NSDictionary *)exception
//{
//    OPLogCenter::GetInstance().OPUncaughtException(exception);
//}
//- (void)OPSignalHandler:(NSDictionary*)exception
//{
//    OPLogCenter::GetInstance().OPSignalHandler(exception);
//}
- (void)OPCreateLogByBridge:(NSDictionary *)log
{
    GrayNlogCenter::GetInstance().GrayNlogByBridge(log);
}

@end
