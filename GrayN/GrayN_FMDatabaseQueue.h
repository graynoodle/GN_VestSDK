//
//  GrayN_FMDatabaseQueue.h
//  fmdb
//
//  Created by August Mueller on 6/22/11.
//  Copyright 2011 Flying Meat Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"

@class GrayN_FMDatabase;

/** To perform queries and updates on multiple threads, you'll want to use `GrayN_FMDatabaseQueue`.

 Using a single instance of `<GrayN_FMDatabase>` from multiple threads at once is a bad idea.  It has always been OK to make a `<GrayN_FMDatabase>` object *per thread*.  Just don't share a single instance across threads, and definitely not across multiple threads at the same time.

 Instead, use `GrayN_FMDatabaseQueue`. Here's how to use it:

 First, make your queue.

    GrayN_FMDatabaseQueue *queue = [GrayN_FMDatabaseQueue databaseQueueWithPath:aPath];

 Then use it like so:

    [queue inDatabase:^(GrayN_FMDatabase *db) {
        [db executeUpdate:@"INSERT INTO myTable VALUES (?)", [NSNumber numberWithInt:1]];
        [db executeUpdate:@"INSERT INTO myTable VALUES (?)", [NSNumber numberWithInt:2]];
        [db executeUpdate:@"INSERT INTO myTable VALUES (?)", [NSNumber numberWithInt:3]];

        GrayN_FMResultSet *rs = [db executeQuery:@"select * from foo"];
        while ([rs next]) {
            //…
        }
    }];

 An easy way to wrap things up in a transaction can be done like this:

    [queue inTransaction:^(GrayN_FMDatabase *db, BOOL *rollback) {
        [db executeUpdate:@"INSERT INTO myTable VALUES (?)", [NSNumber numberWithInt:1]];
        [db executeUpdate:@"INSERT INTO myTable VALUES (?)", [NSNumber numberWithInt:2]];
        [db executeUpdate:@"INSERT INTO myTable VALUES (?)", [NSNumber numberWithInt:3]];

        if (whoopsSomethingWrongHappened) {
            *rollback = YES;
            return;
        }
        // etc…
        [db executeUpdate:@"INSERT INTO myTable VALUES (?)", [NSNumber numberWithInt:4]];
    }];

 `GrayN_FMDatabaseQueue` will run the blocks on a serialized queue (hence the name of the class).  So if you call `GrayN_FMDatabaseQueue`'s methods from multiple threads at the same time, they will be executed in the order they are received.  This way queries and updates won't step on each other's toes, and every one is happy.

 ### See also

 - `<GrayN_FMDatabase>`

 @warning Do not instantiate a single `<GrayN_FMDatabase>` object and use it across multiple threads. Use `GrayN_FMDatabaseQueue` instead.
 
 @warning The calls to `GrayN_FMDatabaseQueue`'s methods are blocking.  So even though you are passing along blocks, they will **not** be run on another thread.

 */

@interface GrayN_FMDatabaseQueue : NSObject {
    NSString            *_path;
    dispatch_queue_t    _queue;
    GrayN_FMDatabase          *_db;
    int                 _openFlags;
}

@property (atomic, retain) NSString *path;
@property (atomic) int openFlags;

///----------------------------------------------------
/// @name Initialization, opening, and closing of queue
///----------------------------------------------------

/** Create queue using path.
 
 @param aPath The file path of the database.
 
 @return The `GrayN_FMDatabaseQueue` object. `nil` on error.
 */

+ (instancetype)databaseQueueWithPath:(NSString*)aPath;

/** Create queue using path and specified flags.
 
 @param aPath The file path of the database.
 @param openFlags Flags passed to the openWithFlags method of the database
 
 @return The `GrayN_FMDatabaseQueue` object. `nil` on error.
 */
+ (instancetype)databaseQueueWithPath:(NSString*)aPath flags:(int)openFlags;

/** Create queue using path.

 @param aPath The file path of the database.

 @return The `GrayN_FMDatabaseQueue` object. `nil` on error.
 */

- (instancetype)initWithPath:(NSString*)aPath;

/** Create queue using path and specified flags.
 
 @param aPath The file path of the database.
 @param openFlags Flags passed to the openWithFlags method of the database
 
 @return The `GrayN_FMDatabaseQueue` object. `nil` on error.
 */

- (instancetype)initWithPath:(NSString*)aPath flags:(int)openFlags;

/** Close database used by queue. */

- (void)close;

///-----------------------------------------------
/// @name Dispatching database operations to queue
///-----------------------------------------------

/** Synchronously perform database operations on queue.
 
 @param block The code to be run on the queue of `GrayN_FMDatabaseQueue`
 */

- (void)inDatabase:(void (^)(GrayN_FMDatabase *db))block;

/** Synchronously perform database operations on queue, using transactions.

 @param block The code to be run on the queue of `GrayN_FMDatabaseQueue`
 */

- (void)inTransaction:(void (^)(GrayN_FMDatabase *db, BOOL *rollback))block;

/** Synchronously perform database operations on queue, using deferred transactions.

 @param block The code to be run on the queue of `GrayN_FMDatabaseQueue`
 */

- (void)inDeferredTransaction:(void (^)(GrayN_FMDatabase *db, BOOL *rollback))block;

///-----------------------------------------------
/// @name Dispatching database operations to queue
///-----------------------------------------------

/** Synchronously perform database operations using save point.

 @param block The code to be run on the queue of `GrayN_FMDatabaseQueue`
 */

#if SQLITE_VERSION_NUMBER >= 3007000
// NOTE: you can not nest these, since calling it will pull another database out of the pool and you'll get a deadlock.
// If you need to nest, use GrayN_FMDatabase's startSavePointWithName:error: instead.
- (NSError*)inSavePoint:(void (^)(GrayN_FMDatabase *db, BOOL *rollback))block;
#endif

@end

