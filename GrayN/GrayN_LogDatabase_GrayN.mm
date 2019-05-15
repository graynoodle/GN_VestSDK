//
//  GrayN_LogDatabase_GrayN.m
//
//  Created by 韩征 on 14-5-16.
//  Copyright (c) 2014年 op-mac1. All rights reserved.
//

#import "GrayNlogHeader.h"
#import "GrayNlogCenter.h"
#import "GrayNcommon.h"
#import "GrayN_LogDatabase_GrayN.h"

#import <sstream>
#import <dispatch/queue.h>

GrayNusing_NameSpace;
#ifdef DEBUG
//#define LOGDEBUG
#endif

#define GrayN_LogDatabase_DATABASE_PATH @"LogData.sqlite" // 保存日志的数据库

static dispatch_queue_t p_GrayN_LogDatabase_LogQueue = dispatch_queue_create("p_GrayN_LogDatabase_LogQueue",NULL);      //操作日志队列

@interface GrayN_LogDatabase_GrayN ()

{
    sqlite3* p_GrayN_LogDatabase;     // 保存日志数据库
    char* p_GrayN_LogDatabaseErrorMsg;        // 错误提示
}

@end

@implementation GrayN_LogDatabase_GrayN

- (void)dealloc
{
//    sqlite3_free(p_GrayN_LogDatabaseErrorMsg);
    sqlite3_close(p_GrayN_LogDatabase);
    [super dealloc];
}
/**
 *  @brief 初始化数据库
 */
- (id)GrayN_LogDatabase_Init
{
    self = [super init];
    if (self) {
        // 初始化数据库
        sqlite3_config(SQLITE_CONFIG_SERIALIZED);
    }
    return self;
}
/**
 *  @brief 创建表
 */
- (void)GrayN_LogDatabase_CreateTable
{
    if (p_GrayN_LogDatabase) {
        return;
    }
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];         //线程中需要加
    // 初始化数据库
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents = [paths objectAtIndex:0];
    NSString *database_path = [documents stringByAppendingPathComponent:GrayN_LogDatabase_DATABASE_PATH];
    
    if (sqlite3_open([database_path UTF8String], &p_GrayN_LogDatabase) != SQLITE_OK) {
#ifdef LOGDEBUG
        GrayNcommon::GrayN_ConsoleLog("数据库打开失败");
        GrayNcommon::GrayN_ConsoleLog(sqlite3_errmsg(p_GrayN_LogDatabase));
#endif
        [pool release];
        return;
    } else {
        string sql_create = "create table logs(uid text, data contentJson, logId text, born text)";
        // create Logs in database
        if (sqlite3_exec(p_GrayN_LogDatabase, sql_create.c_str(), NULL, NULL, &p_GrayN_LogDatabaseErrorMsg)
            != SQLITE_OK) {
#ifdef LOGDEBUG
            GrayNcommon::GrayN_ConsoleLog("表创建失败");
            GrayNcommon::GrayN_ConsoleLog(sqlite3_errmsg(p_GrayN_LogDatabase));
#endif
            if (p_GrayN_LogDatabaseErrorMsg) {
                sqlite3_free(p_GrayN_LogDatabaseErrorMsg);
            }
        }
    }
    [pool release];
}

/**
 *  @brief 插入日志
 */
- (void)GrayN_LogDatabase_InsertLogByUserId:(string)uid Data:(string)data LogID:(string)logId BornTime:(string)born
{
    if (born.length() != 13) {
        return;
    }
    dispatch_async(p_GrayN_LogDatabase_LogQueue, ^{
        stringstream ss;
        ss.clear();
        ss << "INSERT INTO 'logs' ('uid', 'data', 'logId', 'born') VALUES ('" << uid << "','" << data << "','" << logId << "','" << born << "')";
//        cout<<ss.str()<<endl;
        if (sqlite3_exec(p_GrayN_LogDatabase, ss.str().c_str(), NULL, NULL, &p_GrayN_LogDatabaseErrorMsg) != SQLITE_OK) {
#ifdef LOGDEBUG
            GrayNcommon::GrayN_ConsoleLog("数据库插入日志失败");
            GrayNcommon::GrayN_ConsoleLog(sqlite3_errmsg(p_GrayN_LogDatabase));
#endif
            if (p_GrayN_LogDatabaseErrorMsg) {
                sqlite3_free(p_GrayN_LogDatabaseErrorMsg);
            }
        }
        
#ifdef LOGDEBUG
        GrayNcommon::GrayN_DebugLog("当前插入日志标识为");
        GrayNcommon::GrayN_DebugLog(ss.str().c_str());
#endif

    });
}
/** 
 *  @brief 删除日志
 */
- (void)GrayN_LogDatabase_DeleteLogByBornTime:(string)born LogID:(string)logId
{
//    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    dispatch_async(p_GrayN_LogDatabase_LogQueue, ^{
        stringstream ss;
        ss.clear();
        
        // 按照日志生成序列号删除日志
        if (logId == "") {
            if (born.length() != 13) {
                return;
            }
            ss << "DELETE FROM logs WHERE born = '" << born <<"'";
//            cout<<ss.str()<<endl;

            if (sqlite3_exec(p_GrayN_LogDatabase, ss.str().c_str(), NULL, NULL, &p_GrayN_LogDatabaseErrorMsg) != SQLITE_OK) {
#ifdef LOGDEBUG
                GrayNcommon::GrayN_ConsoleLog("数据库删除日志失败");
                GrayNcommon::GrayN_ConsoleLog(sqlite3_errmsg(p_GrayN_LogDatabase));
#endif
                if (p_GrayN_LogDatabaseErrorMsg) {
                    sqlite3_free(p_GrayN_LogDatabaseErrorMsg);
                }
            }
        } else {
            // 按照日志ID删除日志
            if (logId.length()>2 || logId.length()==0) {
                return;
            }
            ss << "DELETE FROM logs WHERE logID = '" << logId <<"'";
//            cout<<ss.str()<<endl;

            if (sqlite3_exec(p_GrayN_LogDatabase, ss.str().c_str(), NULL, NULL, &p_GrayN_LogDatabaseErrorMsg) != SQLITE_OK) {
#ifdef LOGDEBUG
                GrayNcommon::GrayN_ConsoleLog("数据库删除日志失败");
                GrayNcommon::GrayN_ConsoleLog(sqlite3_errmsg(p_GrayN_LogDatabase));
#endif
                if (p_GrayN_LogDatabaseErrorMsg) {
                    sqlite3_free(p_GrayN_LogDatabaseErrorMsg);
                }
            }
        }
        
#ifdef LOGDEBUG
        GrayNcommon::GrayN_DebugLog("当前删除的日志标识为");
        GrayNcommon::GrayN_DebugLog(ss.str().c_str());
#endif

    });
//    [pool release];
}
/**
 *  @brief 读取日志
 */
- (void)GrayN_LogDatabase_CheckLogs
{
    dispatch_async(p_GrayN_LogDatabase_LogQueue, ^{
        string query = "SELECT * FROM logs";
        sqlite3_stmt *statement;
        
        if (sqlite3_prepare_v2(p_GrayN_LogDatabase, query.c_str(), -1, &statement, NULL) == SQLITE_OK) {

            GrayN_JSON::Reader tmp_reader;
            // 依次读取数据库表格logs中每行的内容
            while (sqlite3_step(statement) == SQLITE_ROW) {
                // 获得数据
                string uid = (char*)sqlite3_column_text(statement, 0);
                string data = (char*)sqlite3_column_text(statement, 1);
                string logId = (char*)sqlite3_column_text(statement, 2);
                string born = (char*)sqlite3_column_text(statement, 3);

                GrayN_Log_Data tmpLog;
                tmpLog.m_GrayN_Log_Data_UserId = uid;
//                cout<<"data->"<<data<<endl;
                tmp_reader.parse(data, tmpLog.m_GrayN_Log_LogVal);
                tmpLog.m_GrayN_Log_LogId = logId;
                tmpLog.m_GrayN_Log_BornTime = born;
                GrayNlogCenter::GetInstance().m_GrayN_LogQueue.m_GrayN_Log_Queue_LogList.push_back(tmpLog);
//                cout<<"数据库插入后日志队列当前长度->"<<GrayNlogCenter::GetInstance().m_GrayN_LogQueue.m_GrayN_Log_Queue_LogList.size()<<endl;
            }
            sqlite3_finalize(statement);
            // 将日志插入数据库后立刻触发一次日志发送
            if (!GrayNlogCenter::GetInstance().m_GrayN_LogQueue.m_GrayN_Log_Queue_LogList.empty()) {
                GrayNlogCenter::GetInstance().GrayN_Log_PageSendRequest();
            }
        }
    });
}

@end
