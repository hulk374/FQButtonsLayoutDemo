//
//  FQFmdbTool.h
//  6.15FMDB
//
//  Created by FQ on 16/11/10.
//  Copyright © 2016年 blueFocus. All rights reserved.
//

@class ArchiveModel;
#import <Foundation/Foundation.h>
#import "FMDB.h"
@interface FQFmdbTool : NSObject
/**
 *  返回数据库的路径
 *
 *  @return 返回数据库的路径
 */
+ (NSString *)getDataBasePath;

/**
 *  关闭数据库
 */
+ (void)close;

/**
 *  删除所有历史搜索记录
 *
 *  @return
 */
+ (BOOL)deleteAllHistory;

/**
 *  查询数据库中是否包含当前搜索记录
 *
 *  @param seachText text
 *
 *  @return          value
 */
+ (BOOL)isExistSearchText:(NSString *)searchText;

/**
 *  插入数据
 *
 *  @param model 插入模型数据
 *
 *  @return      value
 */
+ (BOOL)insertModel:(ArchiveModel *)model;

/**
 *  查询数据,如果 传空 默认会查询表中所有数据
 *
 *  @param querySql sql语句
 *
 *  @return         value
 */
+ (NSArray *)queryData:(NSString *)querySql;

/**
 *  删除数据,根据名称ID_No,如果 传空 默认会删除表中所有数据
 *
 *  @param model 删除模型数据，从中取出ID_No
 *
 *  @return      value 
 */
+ (BOOL)deleteData:(ArchiveModel *)model;

/**
 *  删除数据,根据名称name
 *
 *  @param name  名称
 *
 *  @return      value
 */
+ (BOOL)deleteByNameString:(NSString *)name;


@end
