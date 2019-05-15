//
//  OPLogDataBase.h
//
//  Created by 韩征 on 14-5-16.
//  Copyright (c) 2014年 op-mac1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface GrayN_LogDatabase_GrayN : NSObject

- (id)GrayN_LogDatabase_Init;
- (void)GrayN_LogDatabase_CreateTable;
- (void)GrayN_LogDatabase_InsertLogByUserId:(string)uid Data:(string)data LogID:(string)logId BornTime:(string)born;
- (void)GrayN_LogDatabase_CheckLogs;
- (void)GrayN_LogDatabase_DeleteLogByBornTime:(string)born LogID:(string)logId;

@end
