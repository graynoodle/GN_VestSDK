//
//  StoreIAP.cpp
//
//  Created by 建南 刘 on 12-4-24.
//  Copyright (c)2012年 Home. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import "GrayN_Store_IAP.h"
#import "GrayNbaseSDK.h"

#import "AppStore_IAP_GrayN.h"
#import "GrayNjson_cpp.h"
#import "GrayNconfig.h"

#import "GrayN_FMDatabaseQueue.h"
#import "GrayN_FMDatabase.h"
#import "GrayN_SynAppReceipt.h"
#import "SynAppLog_GrayN.h"
#import "GrayN_GTMBase64.h"
#import "AppLog_GrayN.h"
using namespace ourpalmpay;
#import "GrayNchannelSDK.h"

#define GrayN_Store_IAP_DBNAME    @"info.sqlite"
#define GrayN_Store_IAP_TABLENAME @"INFO"                       //保存appstore返回的收据
#define GrayN_Store_IAP_SSID      @"SSID"
#define GrayN_Store_IAP_USERID    @"USERID"
#define GrayN_Store_IAP_INFO      @"INFO"
#define GrayN_Store_IAP_TEMPTIME  @"TIME"
#define GrayN_Store_IAP_APPLOG_TIME @"APPLOGTIME"
#define GrayN_Store_IAP_APPLOG    @"APPLOG"

#define GrayN_Store_IAP_TEMPTABLENAME @"TEMP"                    //保存每一次请求日志
#define GrayN_Store_IAP_TEMPLOG_TABLENAME @"TMPAPPLOG"            //保存每一次

#ifdef DEBUG
#define DEBUG_TMPREQ
#define DEBUG_TMP
#define DEBUG_TMPAPPLOG
#endif

@interface GrayN_Store_IAP_DB_PRIVATE : NSObject
{
    GrayN_FMDatabase* p_GrayN_Store_IAP_database;
    NSString*   p_GrayN_Store_IAP_databasePath;
}

- (void)GrayN_Store_IAP_Insert:(NSString*)ssid userId:(NSString*)unequeUserId receipt:(NSString*)appleReceipt;
- (void)GrayN_Store_IAP_RemoveDataOnMainThread:(NSString*)ssid;
- (void)GrayN_Store_IAP_CheckLocalData:(NSString*)userId;
- (void)GrayN_Store_IAP_SynAppReceipt_oc:(NSString*)userId;
- (void)GrayN_Store_IAP_SynAppReceiptOver_oc;

#ifdef TEMPIAP
// 补单，从临时表中查找订单号
- (void)GrayN_Store_IAP_DealLeakedData_oc:(NSString*)producId userId:(NSString*)unequeUserId receipt:(NSString*)appleReceipt;
// 临时表的操作
- (void)GrayN_Store_IAP_InsertTemp_oc:(NSString*)ssid userId:(NSString*)unequeUserId appleProducId:(NSString*)producId;
- (void)GrayN_Store_IAP_RemoveTempDataOnMainThread:(NSString *)ssid;
- (void)GrayN_Store_IAP_RemoveAllTempData_oc;
- (void)GrayN_Store_IAP_Remove2DaysTempData_oc;
#endif

// applog
- (void)GrayN_Store_IAP_InsertAppLog_oc:(NSString*)timeIndex appLog:(NSString*)tmpApplog;
- (void)GrayN_Store_IAP_DeleteAppLog_oc:(NSString*)timeIndex;
- (void)GrayN_Store_IAP_CheckLocalAppLog_oc;
@end

@implementation GrayN_Store_IAP_DB_PRIVATE

- (id)initWithPath:(NSString*)database_path
{
    if(self=[super init]) {
        p_GrayN_Store_IAP_databasePath = [[NSString alloc] initWithString:database_path];
        [NSThread detachNewThreadSelector:@selector(GrayN_Store_IAP_CreateTable)toTarget:self withObject:nil];
    }
    return self;
}

- (void)GrayN_Store_IAP_CreateTable
{
    p_GrayN_Store_IAP_database = [GrayN_FMDatabase databaseWithPath:p_GrayN_Store_IAP_databasePath];
    if ([p_GrayN_Store_IAP_database open]) {
        // 成功订单表
        [self GrayN_Store_IAP_CreateTable:GrayN_Store_IAP_TABLENAME];
        // 临时订单表
        [self GrayN_Store_IAP_CreateTempTable:GrayN_Store_IAP_TEMPTABLENAME];
        // APP失败日志表
        [self GrayN_Store_IAP_CreateLogTable:GrayN_Store_IAP_TEMPLOG_TABLENAME];
        [p_GrayN_Store_IAP_database close];
    }
    [GrayNbaseSDK GrayN_Console_Log:@"appstore数据库创建成功!!!"];
}

- (void)GrayN_Store_IAP_CreateLogTable:(NSString*)tableName
{
    NSString *sqlCreateTable = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (%@ TEXT PRIMARY KEY, %@ TEXT)",
                                 tableName,GrayN_Store_IAP_APPLOG_TIME,GrayN_Store_IAP_APPLOG];
    
    BOOL res = [p_GrayN_Store_IAP_database executeUpdate:sqlCreateTable];
    if (!res) {
        [GrayNbaseSDK GrayN_Debug_Log:@"GrayN_Store_IAP_CreateLogTable: error when creating p_GrayN_Store_IAP_database table"];
    } else {
//        [GrayNbaseSDK GrayN_Debug_Log:@"success to creating p_GrayN_Store_IAP_database table"];
    }
}

- (void)GrayN_Store_IAP_CreateTable:(NSString*)tableName
{
    NSString *sqlCreateTable =  [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (%@ TEXT PRIMARY KEY, %@ TEXT ,%@ TEXT)",
                                 tableName,GrayN_Store_IAP_SSID,GrayN_Store_IAP_USERID,GrayN_Store_IAP_INFO];
    
    BOOL res = [p_GrayN_Store_IAP_database executeUpdate:sqlCreateTable];
    if (!res) {
        [GrayNbaseSDK GrayN_Debug_Log:@"GrayN_Store_IAP_CreateTable: error when creating p_GrayN_Store_IAP_database table"];
    } else {
//        [GrayNbaseSDK GrayN_Debug_Log:@"success to creating p_GrayN_Store_IAP_database table"];
    }
}

- (void)GrayN_Store_IAP_CreateTempTable:(NSString*)tableName
{
    NSString *sqlCreateTable =  [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (%@ TEXT PRIMARY KEY, %@ TEXT ,%@ TEXT ,%@ TEXT)",
                                 tableName,GrayN_Store_IAP_SSID,GrayN_Store_IAP_USERID,GrayN_Store_IAP_INFO,GrayN_Store_IAP_TEMPTIME];
    
    BOOL res = [p_GrayN_Store_IAP_database executeUpdate:sqlCreateTable];
    if (!res) {
        [GrayNbaseSDK GrayN_Debug_Log:@"GrayN_Store_IAP_CreateTempTable: error when creating p_GrayN_Store_IAP_database table"];
    } else {
//        [GrayNbaseSDK GrayN_Debug_Log:@"success to creating p_GrayN_Store_IAP_database table"];
    }
}

- (void)GrayN_Store_IAP_CheckLocalData:(NSString*)userId
{
    GrayN_FMDatabaseQueue *queue = [GrayN_FMDatabaseQueue databaseQueueWithPath:p_GrayN_Store_IAP_databasePath];
    dispatch_queue_t q1 = dispatch_queue_create("queue1", NULL);
    dispatch_async(q1, ^{
        [queue inDatabase:^(GrayN_FMDatabase *db2){
            
            NSString *selectSql = nil;
            if ([userId length] == 0) {
                // 异步的时候，不考虑是否用户，因为发货都是由服务器提供
                selectSql= [NSString stringWithFormat:@"SELECT * FROM %@",GrayN_Store_IAP_TABLENAME];
            } else {
                // 同步，必须考虑多个用户，以防发错货
                selectSql= [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = '%@'",GrayN_Store_IAP_TABLENAME,GrayN_Store_IAP_USERID,userId];
            }
            
            GrayN_FMResultSet * rs = [db2 executeQuery:selectSql];
            
            while ([rs next]){
                NSString* ssidStr = [rs stringForColumn:GrayN_Store_IAP_SSID];
                //NSString * userId = [rs stringForColumn:GrayN_Store_IAP_USERID];
                NSString * buf = [rs stringForColumn:GrayN_Store_IAP_INFO];
                
                // 解密，容易忘记
                string tmpBuf([buf UTF8String]);
                string receipt;
                string storeKey = GrayN_SynAppReceipt::GetInstance().m_GrayN_StoreKey;
                receipt = [[GrayNbaseSDK GrayNdecodeDES:tmpBuf.c_str()andKey:storeKey.c_str()] UTF8String];

//                cout<<receipt<<endl;
                
                string ssid = [ssidStr UTF8String];
                string realReceipt;
                string countryCode;
                string currencyCode;
                string logid = ssid;
                string orderType;
                int pos = (int)ssid.find("|");
                if (pos == -1) {
                    //
                    int index = (int)receipt.find("##");
                    if (index < 0) {
                        // 历史订单
                        realReceipt = receipt;
                        orderType = "1";
                    } else if (index < 10 && index>=0) {
                        // 正常订单
                        // 需要替换地区编码
                        string specialCode = receipt.substr(0,index);
                        int pos = (int)specialCode.find("|");
                        if (pos == -1) {
                            orderType = "4";
                        } else {
                            countryCode = specialCode.substr(0,pos);
                            currencyCode = specialCode.substr(pos+1);
                            orderType = "3";
                        }
                        realReceipt = receipt.substr(index+2);
                    }
                } else {
                    // 订单号为：订单号|地区码
                    // 货币码为“”，因为是历史订单
                    realReceipt = receipt;
                    // 注意：此处没有将ssid拆开是因为在本地验证的时候，删除本地数据库会用到
                    int index = (int)ssid.find("|");
                    if (index > 0) {
                        countryCode = ssid.substr(index+1);
                        ssid = ssid.substr(0,index);
                    }
                    orderType = "2";
                }
                
                // 有三种本地订单
                // 1、订单号                收据
                // 2、订单号|国家码          收据
                // 3、订单号                国家码|货币码##收据
                // 最终处理为：订单号|国家码    货币码    收据
                GrayN_AppVerifyRequest* request = new GrayN_AppVerifyRequest();
                request->GrayN_AppVerifyRequest_LogId = logid;
                request->GrayN_AppVerifyRequest_SSID = ssid;
                request->GrayN_AppVerifyRequest_AppReceipt = realReceipt;
                request->GrayN_AppVerifyRequest_CountryCode = countryCode;
                request->GrayN_AppVerifyRequest_CurrencyCode = currencyCode;
                request->GrayN_AppVerifyRequest_OrderType = orderType;
                GrayN_SynAppReceipt::GetInstance().GrayN_SynAppReceiptAddLocalVeritifyRequest(request);
            }
            [rs close];
            
//            // 启动同步线程，先处理本地未完成的验证，然后再验证AppReceipt中请求超时的验证
            int count = GrayN_SynAppReceipt::GetInstance().GrayN_SynAppReceiptLocalQueueSize();
            if ( count == 0) {
                [GrayNbaseSDK GrayN_Console_Log:@"************无同步订单！！！！！*************"];
                return;
            }
            [GrayNbaseSDK GrayN_Console_Log:@"*********有%d个未完成的订单需要同步！！！！！*********", count];
            GrayN_SynAppReceipt::GetInstance().GrayN_SynAppReceiptSendVerify();
        }];
    });
    dispatch_release(q1);
}

- (void)GrayN_Store_IAP_SynAppReceipt_oc:(NSString*)userId
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self GrayN_Store_IAP_CheckLocalData:userId];
    });
}

- (void)GrayN_Store_IAP_SynAppReceiptOver_oc
{
    // 停止定时器
}

#pragma 本地保存appstore验证收据
- (void)GrayN_Store_IAP_Insert:(NSString*)ssid userId:(NSString*)unequeUserId receipt:(NSString*)appleReceipt
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    GrayN_FMDatabaseQueue *queue = [GrayN_FMDatabaseQueue databaseQueueWithPath:p_GrayN_Store_IAP_databasePath];
    dispatch_queue_t q1 = dispatch_queue_create("queue1", NULL);
    dispatch_async(q1, ^{
        [queue inDatabase:^(GrayN_FMDatabase *db2) {
            
            NSString *insertSql1= [NSString stringWithFormat:
                                   @"INSERT INTO '%@' ('%@','%@','%@')VALUES (?,?,?)",
                                   GrayN_Store_IAP_TABLENAME, GrayN_Store_IAP_SSID,GrayN_Store_IAP_USERID,GrayN_Store_IAP_INFO];
            BOOL res = [db2 executeUpdate:insertSql1, ssid,unequeUserId,appleReceipt];
            if (!res) {
                [GrayNbaseSDK GrayN_Debug_Log:@"error to insert data: %@", insertSql1];
                [GrayNbaseSDK GrayN_Debug_Log:@"error to insert data!"];
            } else {
                [GrayNbaseSDK GrayN_Debug_Log:@"success to insert data: %@,ssid=%@", insertSql1, ssid];
            }
        }];
    });
    dispatch_release(q1);
    [pool release];
}

- (void)GrayN_Store_IAP_RemoveDataOnMainThread:(NSString*)ssid
{
    [self performSelectorOnMainThread:@selector(GrayN_Store_IAP_RemoveData:)withObject:ssid waitUntilDone:NO];
}

- (void)GrayN_Store_IAP_RemoveData:(NSString*)ssid
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    GrayN_FMDatabaseQueue *queue = [GrayN_FMDatabaseQueue databaseQueueWithPath:p_GrayN_Store_IAP_databasePath];
    
    dispatch_queue_t q1 = dispatch_queue_create([ssid UTF8String], NULL);
    
    dispatch_async(q1, ^{
        [queue inDatabase:^(GrayN_FMDatabase *db2) {
            bool result = false;
            //删除收据表
            NSString *deleteSql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = '%@'",GrayN_Store_IAP_TABLENAME,GrayN_Store_IAP_SSID, ssid];
            BOOL res = [db2 executeUpdate:deleteSql];
            if (!res) {
                [GrayNbaseSDK GrayN_Debug_Log:@"error to delete data!"];
                [GrayNbaseSDK GrayN_Debug_Log:@"error to delete data: %@", deleteSql];
                result = true;
            } else {
                [GrayNbaseSDK GrayN_Debug_Log:@"success to delete data: %@", deleteSql];
            }
            
            if (result == false) {
                return;
            }
            
            // 必须在收据发送成功后再删除请求表，这样可以防止漏单
            deleteSql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = '%@'",GrayN_Store_IAP_TEMPTABLENAME,GrayN_Store_IAP_SSID, ssid];
            res = [db2 executeUpdate:deleteSql];
            if (!res) {
                [GrayNbaseSDK GrayN_Debug_Log:@"error to delete data!"];
#ifndef DEBUG_TMPAPPLOG
                [GrayNbaseSDK GrayN_Debug_Log:@"error to delete data: %@", deleteSql];
#endif
            } else {
#ifndef DEBUG_TMPAPPLOG
                [GrayNbaseSDK GrayN_Debug_Log:@"success to delete data: %@", deleteSql];
#endif
            }
        }];
    });
    dispatch_release(q1);
    [pool release];
}

#ifdef TEMPIAP
//*********************临时表操作
- (void)GrayN_Store_IAP_InsertTemp_oc:(NSString*)ssid userId:(NSString*)unequeUserId appleProducId:(NSString*)producId
{
    GrayN_FMDatabaseQueue *queue = [GrayN_FMDatabaseQueue databaseQueueWithPath:p_GrayN_Store_IAP_databasePath];
    dispatch_queue_t q1 = dispatch_queue_create("queue1", NULL);
    dispatch_async(q1, ^{
        [queue inDatabase:^(GrayN_FMDatabase *db2) {
            
            // 插入请求购买列表
            NSString *insertSql1= [NSString stringWithFormat:
                                   @"INSERT INTO '%@' ('%@','%@','%@','%@')VALUES (?,?,?,?)",
                                   GrayN_Store_IAP_TEMPTABLENAME, GrayN_Store_IAP_SSID,GrayN_Store_IAP_USERID,GrayN_Store_IAP_INFO,GrayN_Store_IAP_TEMPTIME];
            string time = [[GrayNbaseSDK GrayNgetCurrentMil_TimeString] UTF8String];
            NSString *curTime = [NSString stringWithUTF8String:time.c_str()];
            BOOL res = [db2 executeUpdate:insertSql1, ssid,unequeUserId,producId,curTime];
            if (!res) {
#ifndef DEBUG_TMPAPPLOG
                [GrayNbaseSDK GrayN_Debug_Log:@"error to insert data: %@，SSID = %@", insertSql1, ssid];
#endif
                [GrayNbaseSDK GrayN_Debug_Log:@"error to insert data!"];
            } else {
#ifndef DEBUG_TMPAPPLOG
                [GrayNbaseSDK GrayN_Debug_Log:@"success to insert data: %@", insertSql1];
#endif
            }
        }];
    });
    dispatch_release(q1);
}

- (void)GrayN_Store_IAP_DealLeakedData_oc:(NSString*)producId userId:(NSString*)unequeUserId receipt:(NSString*)appleReceipt;
{
    GrayN_FMDatabaseQueue *queue = [GrayN_FMDatabaseQueue databaseQueueWithPath:p_GrayN_Store_IAP_databasePath];
    dispatch_queue_t q1 = dispatch_queue_create("queue1", NULL);
    dispatch_async(q1, ^{
        [queue inDatabase:^(GrayN_FMDatabase *db2) {
            
            NSString *selectSql = nil;
            if ([unequeUserId length] == 0) {
                // 异步的时候，不考虑是否用户，全部删除
                // 从数据库中根据SSID降序排列，找第一个订单号
                selectSql= [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = '%@' ORDER BY %@ DESC",GrayN_Store_IAP_TEMPTABLENAME,GrayN_Store_IAP_INFO,producId,GrayN_Store_IAP_TEMPTIME];
            } else {
                // 同步，必须考虑多个用户，以防止
//                selectSql= [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = '%@'",GrayN_Store_IAP_TEMPTABLENAME,USERID,unequeUserId];
            }
            
            GrayN_FMResultSet * rs = [db2 executeQuery:selectSql];
            NSString *propId = [NSString stringWithFormat:@"%@",producId];
            NSString* ssid = nil;
            while ([rs next]) {
                ssid = [rs stringForColumn:GrayN_Store_IAP_SSID];

                [GrayNbaseSDK GrayN_Console_Log:@"本地查找到的订单号为：%@", ssid];

                break;          //只需要第一个数据
            }

            [rs close];
            if (ssid == nil){
                // 无对应的订单信息，这条数据没有办法了
                [GrayNbaseSDK GrayN_Console_Log:@"这个订单因为找不到订单号，所以没办法了！"];
                
                return;
            }
            
            // 将漏单插入成功的订单中!!!!!!!!!!!!!!!!!!注意这里的TABLENAME
            // 注意最新版开始格式变化，不再是：订单号|国家码   统一为：订单号   （4.1.10-2015.8.28）
            NSRange range = [ssid rangeOfString:@"|"];
            if (range.location != NSNotFound){
                // 防止别人恶意更改本地数据库，理论上本地存储的订单号没有|
                [GrayNbaseSDK GrayN_Console_Log:@"这个订单因为找不到订单号，所以没办法了！"];
                return;
            }
            
            // 如果没有重复订单就插入
            NSString *insertSql1= [NSString stringWithFormat:
                                   @"INSERT INTO '%@' ('%@','%@','%@')VALUES (?,?,?)",
                                   GrayN_Store_IAP_TABLENAME, GrayN_Store_IAP_SSID,GrayN_Store_IAP_USERID,GrayN_Store_IAP_INFO];
            BOOL res = [db2 executeUpdate:insertSql1, ssid,unequeUserId,appleReceipt];
            if (!res) {
                [GrayNbaseSDK GrayN_Debug_Log:@"error to insert data: %@，ssid = %@", insertSql1, ssid];
                [GrayNbaseSDK GrayN_Debug_Log:@"error to insert data!"];
            } else {
                [GrayNbaseSDK GrayN_Debug_Log:@"success to insert data: %@，ssid = %@", insertSql1, ssid];
            }
            
            // 将订单从购买订单中删除
            NSString *deleteSql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = '%@'",GrayN_Store_IAP_TEMPTABLENAME,GrayN_Store_IAP_SSID, ssid];
            res = [db2 executeUpdate:deleteSql];
            if (!res) {
                [GrayNbaseSDK GrayN_Debug_Log:@"error to delete data!"];
                [GrayNbaseSDK GrayN_Debug_Log:@"error to delete data: %@,ssid=%@", deleteSql, ssid];
            } else {
                [GrayNbaseSDK GrayN_Debug_Log:@"success to delete data: %@", deleteSql];
            }
            
            // 补单日志
            if (ssid && propId) {
                AppLog_GrayN* log = new AppLog_GrayN();
                log->CreateResponseAppLog_GrayN([ssid UTF8String], [propId UTF8String],GrayN_SKReuploadReceiptSuccess);
            }
        }];
    });
    dispatch_release(q1);
}

- (void)GrayN_Store_IAP_RemoveTempDataOnMainThread:(NSString *)ssid
{
    [self performSelectorOnMainThread:@selector(removeTempIapData:)withObject:ssid waitUntilDone:NO];
}

- (void)removeTempIapData:(NSString *)ssid
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    GrayN_FMDatabaseQueue *queue = [GrayN_FMDatabaseQueue databaseQueueWithPath:p_GrayN_Store_IAP_databasePath];
    
    dispatch_queue_t q1 = dispatch_queue_create("tmpDeleteQueue", NULL);
    
    dispatch_async(q1, ^{
        [queue inDatabase:^(GrayN_FMDatabase *db2) {
            
            NSString *deleteSql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = '%@'",GrayN_Store_IAP_TEMPTABLENAME,GrayN_Store_IAP_SSID, ssid];
            BOOL res = [db2 executeUpdate:deleteSql];
            if (!res) {
                [GrayNbaseSDK GrayN_Debug_Log:@"error to delete data!"];
#ifndef DEBUG_TMPAPPLOG
                [GrayNbaseSDK GrayN_Debug_Log:@"error to delete data: %@", deleteSql];
#endif
            } else {
#ifndef DEBUG_TMPAPPLOG
                [GrayNbaseSDK GrayN_Debug_Log:@"success to delete data: %@", deleteSql];
#endif
            }
        }];
    });
    dispatch_release(q1);
    [pool release];
}

- (void)removeAllTempIapDataOnMainThread
{
    [self performSelectorOnMainThread:@selector(GrayN_Store_IAP_RemoveAllTempData_oc)withObject:nil waitUntilDone:NO];
}

- (void)GrayN_Store_IAP_RemoveAllTempData_oc
{
    GrayN_FMDatabaseQueue *queue = [GrayN_FMDatabaseQueue databaseQueueWithPath:p_GrayN_Store_IAP_databasePath];
    
    dispatch_queue_t q1 = dispatch_queue_create("tmpqueue1", NULL);
    
    dispatch_async(q1, ^{
        [queue inDatabase:^(GrayN_FMDatabase *db2){
            
            NSString *deleteSql = [NSString stringWithFormat:@"DELETE FROM %@",GrayN_Store_IAP_TEMPTABLENAME];
            BOOL res = [db2 executeUpdate:deleteSql];
            if (!res){
                [GrayNbaseSDK GrayN_Debug_Log:@"error to delete data!"];
#ifdef DEBUG_TMP
                [GrayNbaseSDK GrayN_Debug_Log:@"error to delete data: %@", deleteSql];
#endif
            } else {
#ifdef DEBUG_TMP
                [GrayNbaseSDK GrayN_Debug_Log:@"success to delete data: %@", deleteSql];
#endif
            }
        }];
    });
    dispatch_release(q1);
}

#endif
- (void)GrayN_Store_IAP_Remove2DaysTempData_oc
{
    GrayN_FMDatabaseQueue *queue = [GrayN_FMDatabaseQueue databaseQueueWithPath:p_GrayN_Store_IAP_databasePath];
    dispatch_queue_t q1 = dispatch_queue_create("tmpqueue1", NULL);
    dispatch_async(q1, ^{
        [queue inDatabase:^(GrayN_FMDatabase *db2) {
            
            NSString *selectSql = [NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY %@ DESC", GrayN_Store_IAP_TEMPTABLENAME, GrayN_Store_IAP_TEMPTIME];
           
            GrayN_FMResultSet * rs = [db2 executeQuery:selectSql];
//            NSString *propId = [NSString stringWithFormat:@"%@",producId];
//            NSDate
            NSString *ssid = nil;
            NSString *tmpDate = nil;
            NSDate *tmpNSDate = nil;
            NSString *today = [GrayNbaseSDK GrayNgetCurrentMil_TimeString];
            today = [today substringToIndex:8];
            NSLog(@"today=%@",today);
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat =@"yyyyMMdd";
            NSDate *nowDate = [formatter dateFromString:today];
            
            NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            unsigned int unitFlag = NSDayCalendarUnit;
            
            NSMutableArray *delSsids = [[NSMutableArray alloc] init];
            while ([rs next]) {
                ssid = [rs stringForColumn:GrayN_Store_IAP_SSID];
                tmpDate = [rs stringForColumn:GrayN_Store_IAP_TEMPTIME];
                tmpDate = [tmpDate substringToIndex:8];
                tmpNSDate = [formatter dateFromString:tmpDate];
                
                NSDateComponents *components = [calendar components:unitFlag fromDate:tmpNSDate toDate:nowDate options:0];
                if ([components day] > 2) {
                    [GrayNbaseSDK GrayN_Console_Log:@"本地查找到超过两天的订单号为：%@ 时间：%@ 间隔：%ld", ssid, tmpDate, [components day]];
                    [delSsids addObject:ssid];
                }
            }
            
            [rs close];
            
            
            
            for (NSString *delSsid in delSsids) {
                NSString *deleteSql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = '%@'",GrayN_Store_IAP_TEMPTABLENAME,GrayN_Store_IAP_SSID, delSsid];
                BOOL res = [db2 executeUpdate:deleteSql];
                if (!res) {
                    [GrayNbaseSDK GrayN_Debug_Log:@"error to delete data!"];
#ifndef DEBUG_TMPAPPLOG
                    [GrayNbaseSDK GrayN_Debug_Log:@"error to delete data: %@", deleteSql];
#endif
                } else {
#ifndef DEBUG_TMPAPPLOG
                    [GrayNbaseSDK GrayN_Debug_Log:@"success to delete data: %@", deleteSql];
#endif
                }
            }
            
        }];
    });
    dispatch_release(q1);

}
//TimerDelegate
- (void)timerOut
{
    [GrayNbaseSDK GrayN_Console_Log:@"同步订单超时，结束任务！！！！！！"];
    GrayN_SynAppReceipt::GetInstance().GrayN_SynAppReceiptStopVerify();
}

//applog
- (void)GrayN_Store_IAP_InsertAppLog_oc:(NSString*)timeIndex appLog:(NSString*)tmpApplog
{
    GrayN_FMDatabaseQueue *queue = [GrayN_FMDatabaseQueue databaseQueueWithPath:p_GrayN_Store_IAP_databasePath];
    [queue inDatabase:^(GrayN_FMDatabase *tDb) {
        
        NSString *insertSql1= [NSString stringWithFormat:
                               @"INSERT INTO '%@' ('%@','%@')VALUES (?,?)",
                               GrayN_Store_IAP_TEMPLOG_TABLENAME, GrayN_Store_IAP_APPLOG_TIME,GrayN_Store_IAP_APPLOG];
        BOOL res = [tDb executeUpdate:insertSql1, timeIndex,tmpApplog];
        if (!res) {
#ifdef DEBUG_TMPAPPLOG
            [GrayNbaseSDK GrayN_Debug_Log:@"error to insert data: %@", insertSql1];
#endif
            [GrayNbaseSDK GrayN_Debug_Log:@"error to insert data!"];
        } else {
#ifdef DEBUG_TMPAPPLOG
            [GrayNbaseSDK GrayN_Debug_Log:@"success to insert data: %@", insertSql1];
#endif
        }
    }];
}

- (void)GrayN_Store_IAP_DeleteAppLog_oc:(NSString*)timeIndex
{
    GrayN_FMDatabaseQueue *queue = [GrayN_FMDatabaseQueue databaseQueueWithPath:p_GrayN_Store_IAP_databasePath];
    [queue inDatabase:^(GrayN_FMDatabase *tDb) {
        
        NSString *deleteSql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = '%@'",GrayN_Store_IAP_TEMPLOG_TABLENAME,GrayN_Store_IAP_APPLOG_TIME, timeIndex];
        BOOL res = [tDb executeUpdate:deleteSql];
        if (!res){
            [GrayNbaseSDK GrayN_Debug_Log:@"error to delete data!"];
#ifdef DEBUG_TMPAPPLOG
            [GrayNbaseSDK GrayN_Debug_Log:@"error to delete data: %@", deleteSql];
#endif
        } else {
#ifdef DEBUG_TMPAPPLOG
            [GrayNbaseSDK GrayN_Debug_Log:@"success to delete data: %@", deleteSql];
#endif
        }
    }];
}

- (void)GrayN_Store_IAP_CheckLocalAppLog_oc
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    GrayN_FMDatabaseQueue *queue = [GrayN_FMDatabaseQueue databaseQueueWithPath:p_GrayN_Store_IAP_databasePath];
    [queue inDatabase:^(GrayN_FMDatabase *tDb){
        
        NSString *selectSql= [NSString stringWithFormat:@"SELECT * FROM %@ limit 0,10",GrayN_Store_IAP_TEMPLOG_TABLENAME];
        
        GrayN_FMResultSet * rs = [tDb executeQuery:selectSql];
        
        while ([rs next]){
            NSString* appLogTime = [rs stringForColumn:GrayN_Store_IAP_APPLOG_TIME];
            NSString * appLog = [rs stringForColumn:GrayN_Store_IAP_APPLOG];
            SynAppLog_GrayN::GetInstance().AddLocalAppLogRequest_GrayN([appLogTime UTF8String], [appLog UTF8String]);
        }
        [rs close];
    }];
    [pool release];
}

- (void)dealloc
{
    [p_GrayN_Store_IAP_databasePath release];
    [super dealloc];
}

//计算时间差
- (int)intervalSinceNow:(NSString *)theDate
{
    NSMutableString *datestring = [NSMutableString stringWithFormat:@"%@",theDate];
    [datestring insertString:@"-" atIndex:4];
    [datestring insertString:@"-" atIndex:7];
    [datestring insertString:@" " atIndex:10];
    [datestring insertString:@":" atIndex:13];
    [datestring insertString:@":" atIndex:16];
    
    NSDateFormatter *date=[[NSDateFormatter alloc] init];
    [date setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *d=[date dateFromString:datestring];
    
    NSTimeInterval late=[d timeIntervalSince1970]*1;
    
    NSDate* dat = [NSDate date];
    NSTimeInterval now=[dat timeIntervalSince1970]*1;
    NSString *timeString=@"";
    
    NSTimeInterval cha=now-late;
    
    if (cha/86400>1)
    {
        timeString = [NSString stringWithFormat:@"%f", cha/86400];
        timeString = [timeString substringToIndex:timeString.length-7];
        return [timeString intValue];
    }
    return -1;
}

@end

GrayNusing_NameSpace;
    
AppStore_IAP_GrayN* appStroe=nil;
GrayN_Store_IAP::GrayN_Store_IAP()
{

}
GrayN_Store_IAP::~GrayN_Store_IAP()
{

    [p_GrayN_Store_IAP_fmdb release];
    [appStroe release];
}

void GrayN_Store_IAP::GrayN_Store_IAP_Init()
{
    appStroe=[[AppStore_IAP_GrayN alloc] init];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents = [paths objectAtIndex:0];
    NSString *database_path = [documents stringByAppendingPathComponent:GrayN_Store_IAP_DBNAME];
    p_GrayN_Store_IAP_fmdb = [[GrayN_Store_IAP_DB_PRIVATE alloc] initWithPath:database_path];
}

bool GrayN_Store_IAP::GrayN_Store_IAP_CanMakePayments()
{
    return [appStroe GrayN_IAP_CanMakePayments];
}


void GrayN_Store_IAP::GrayN_Store_IAP_Buy(const char* itemID,const char* fee_permission,const char* fee_permission_currencycode,const char* fee_permission_note)
{
    [appStroe GrayN_IAP_RequestProductInfo:itemID withCountryCode:fee_permission withCurrencyCode:fee_permission_currencycode withNote:fee_permission_note];
}

void GrayN_Store_IAP::GrayN_Store_IAP_InsertData(std::string ssid,std::string userId,std::string receipt)
{
    NSString* ssidStr = [NSString stringWithUTF8String:ssid.c_str()];
    NSString* userIdStr = [NSString stringWithUTF8String:userId.c_str()];
    NSString* receiptStr = [NSString stringWithUTF8String:receipt.c_str()];
    [p_GrayN_Store_IAP_fmdb GrayN_Store_IAP_Insert:ssidStr userId:userIdStr receipt:receiptStr];
}

void GrayN_Store_IAP::GrayN_Store_IAP_RemoveData(std::string ssid)
{
    NSString* ssidStr = [NSString stringWithUTF8String:ssid.c_str()];
    [p_GrayN_Store_IAP_fmdb GrayN_Store_IAP_RemoveDataOnMainThread:ssidStr];
}
#ifdef TEMPIAP
void GrayN_Store_IAP::GrayN_Store_IAP_InsertTempData(std::string ssid,std::string userId,std::string productId)
{
    NSString* ssidStr = [NSString stringWithUTF8String:ssid.c_str()];
    NSString* userIdStr = [NSString stringWithUTF8String:userId.c_str()];
    NSString* productIdStr = [NSString stringWithUTF8String:productId.c_str()];
    [p_GrayN_Store_IAP_fmdb GrayN_Store_IAP_InsertTemp_oc:ssidStr userId:userIdStr appleProducId:productIdStr];
}

void GrayN_Store_IAP::GrayN_Store_IAP_DealLeakedData(std::string productId,std::string userId,std::string receipt)
{
    NSString* productIdStr = [NSString stringWithUTF8String:productId.c_str()];
//    NSString* userIdStr = [NSString stringWithUTF8String:userId.c_str()];
    NSString* receiptStr = [NSString stringWithUTF8String:receipt.c_str()];
    // 暂时不考虑单机
    [p_GrayN_Store_IAP_fmdb GrayN_Store_IAP_DealLeakedData_oc:productIdStr userId:@"" receipt:receiptStr];
}

void GrayN_Store_IAP::GrayN_Store_IAP_RemoveTempData(std::string ssid)
{
    NSString* ssidStr = [NSString stringWithUTF8String:ssid.c_str()];
    [p_GrayN_Store_IAP_fmdb GrayN_Store_IAP_RemoveTempDataOnMainThread:ssidStr];
}

void GrayN_Store_IAP::GrayN_Store_IAP_RemoveAllTempData()
{
    [p_GrayN_Store_IAP_fmdb removeAllTempIapDataOnMainThread];
}
void GrayN_Store_IAP::GrayN_Store_IAP_Remove2DaysTempData()
{
    [p_GrayN_Store_IAP_fmdb GrayN_Store_IAP_Remove2DaysTempData_oc];
}
#endif

void GrayN_Store_IAP::GrayN_Store_IAP_SynAppReceipt(std::string userId)
{
    [GrayNbaseSDK GrayN_Console_Log:@"************检测是否有同步订单，并同步！！！！！************"];
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSString* userIdStr = [NSString stringWithUTF8String:userId.c_str()];
    [p_GrayN_Store_IAP_fmdb GrayN_Store_IAP_SynAppReceipt_oc:userIdStr];
    [pool release];
}

void GrayN_Store_IAP::GrayN_Store_IAP_SynAppReceiptOver()
{
    [p_GrayN_Store_IAP_fmdb GrayN_Store_IAP_SynAppReceiptOver_oc];
}

void GrayN_Store_IAP::GrayN_Store_IAP_InsertAppLog(std::string tmpApplogTime ,std::string tmpApplog)
{
    //子线程操作需要加pool否则会内存泄露
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSString* appLogTime = [NSString stringWithUTF8String:tmpApplogTime.c_str()];
    NSString* appLog = [NSString stringWithUTF8String:tmpApplog.c_str()];
    [p_GrayN_Store_IAP_fmdb GrayN_Store_IAP_InsertAppLog_oc:appLogTime appLog:appLog];
    [pool release];
}

void GrayN_Store_IAP::GrayN_Store_IAP_DeleteAppLog(std::string tmpApplogTime)
{
    //子线程操作需要加pool否则会内存泄露
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSString* appLogTime = [NSString stringWithUTF8String:tmpApplogTime.c_str()];
    [p_GrayN_Store_IAP_fmdb GrayN_Store_IAP_DeleteAppLog_oc:appLogTime];
    [pool release];
}

void GrayN_Store_IAP::GrayN_Store_IAP_CheckLocalAppLog()
{
    [p_GrayN_Store_IAP_fmdb GrayN_Store_IAP_CheckLocalAppLog_oc];
}

void GrayN_Store_IAP::GrayN_Store_IAP_PayResult(bool result, int errorCode)
{
    [[GrayN_ChannelSDK GrayN_Share] notifyPayResult_GrayN:result errorCode:errorCode];
}

string GrayN_Store_IAP::GrayN_Store_IAP_Base64Encode(const char* inData)
{
    //更换base64编码方式
    NSString *receipt = [NSString stringWithUTF8String:inData];
    NSData *data = [receipt dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString* encoded = [[NSString alloc] initWithData:[GrayN_GTMBase64_GrayN encodeData:data] encoding:NSUTF8StringEncoding];
    string baseEncode = [encoded UTF8String];
    [encoded release];
    return baseEncode;
}

string GrayN_Store_IAP::GrayN_Store_IAP_MD5Encode(const char* source)
{
    if (source == NULL) {
        return "";
    }
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(source, (uint32_t)strlen(source), result);
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < 16; i++)
        [hash appendFormat:@"%02X", result[i]];
    std::string md5 = [hash UTF8String];
    return md5;
}
