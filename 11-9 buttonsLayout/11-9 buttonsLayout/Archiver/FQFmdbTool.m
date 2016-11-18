//
//  FQFmdbTool.m
//  6.15FMDB
//
//  Created by FQ on 16/11/10.
//  Copyright © 2016年 blueFocus. All rights reserved.
//
#import "FMDB.h"
#import "FQFmdbTool.h"
#import "ArchiveModel.h"
#define FQSQLITE_NAME @"t_history.sqlite"
#define HISTORY_NAME  @"t_history"

static FMDatabase *_db;
@implementation FQFmdbTool

+ (void)initialize {
    // 执行打开数据库和创建表操作
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:FQSQLITE_NAME];
    _db = [FMDatabase databaseWithPath:filePath];
    
    [_db open];
   // 必须先打开数据库才能创建表。。。否则提示数据库没有打开
    if ([_db open]) {
        BOOL res = [_db executeUpdate:@"CREATE TABLE IF NOT EXISTS t_history (id integer PRIMARY KEY AUTOINCREMENT, name text NOT NULL, ID_No INTEGER NOT NULL);"];
        if (res) {
            NSLog(@"创建t_history表格成功");
        }else{
            NSLog(@"创建t_history表格失败");
        }
    }else{
        NSLog(@"数据库没有打开");
    }
}

+ (BOOL)insertModel:(ArchiveModel *)model {
    NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO t_history(name, ID_No) VALUES ('%@', '%zd');", model.name, model.ID_No];
    return [_db executeUpdate:insertSql];
}

+ (NSArray *)queryData:(NSString *)querySql {
    
    if (querySql == nil) {
        querySql = @"SELECT * FROM t_history;";
    }
    
    NSMutableArray *arrM = [NSMutableArray array];
    FMResultSet *set = [_db executeQuery:querySql];
    
    while ([set next]) {
        
        NSString *name  = [set stringForColumn:@"name"];
        NSString *ID_No = [set stringForColumn:@"ID_No"];
        
        ArchiveModel *model = [ArchiveModel modelWith:name  no:ID_No.intValue];
        [arrM addObject:model];
    }
    
    return arrM;
}

+ (BOOL)deleteData:(ArchiveModel *)model {
    
    return [_db executeUpdateWithFormat:@"DELETE FROM t_history WHERE ID_No = %ld",(long)model.ID_No];
    
}

+ (BOOL)deleteByNameString:(NSString *)name {

    return [_db executeUpdateWithFormat:@"DELETE FROM t_history WHERE name = %@",name];
}

+ (BOOL)modifyData:(NSString *)modifySql ArchiveModel:(ArchiveModel *)model {
    
    if (modifySql == nil) {
        modifySql = @"UPDATE t_history SET ID_No = '999999' WHERE name = 'Jack'";
    }
    return [_db executeUpdateWithFormat:@"UPDATE t_history SET ID_No = %ld WHERE name = %@",(long)model.ID_No,model.name];
}

+ (NSInteger)maxIDInTable {

    FMResultSet *set = [_db executeQuery:@"SELECT MAX(id) as id FROM t_history"];
    
    NSInteger num = 0;
    
    while (set.next) {
        
        num = [set intForColumn:@"id"];
        
        return num;
    
    }
        return num;
}


/**
 *  返回数据库的路径
 *
 *  @return 返回数据库的路径
 */
+ (NSString *)getDataBasePath
{
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    return [path stringByAppendingPathComponent:FQSQLITE_NAME];
}

/**
 *  关闭数据库
 */
+ (void)close
{
    [_db close];
}

/**
 *  删除所有历史搜索记录
 *
 *  @return
 */
+ (BOOL)deleteAllHistory
{
    NSString *sql = @"DELETE FROM t_history";
    BOOL isDeleteOK = [_db executeUpdate:sql];
    
    if (isDeleteOK) {
        return YES;
    }
    return NO;
}

/**
 *  查询数据库中是否包含当前搜索记录
 *
 *  @param seachText text
 *
 *  @return          value
 */
+ (BOOL)isExistSearchText:(NSString *)searchText
{
    NSString *sql = @"SELECT * FROM t_history";
    FMResultSet *results = [_db executeQuery:sql];
    
    while (results.next) {
        if ([searchText isEqualToString:[results stringForColumn:@"name"]]) {
            return YES;
        }
    }
    return NO;
}

@end
