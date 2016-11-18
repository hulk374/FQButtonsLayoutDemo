//
//  ArchiveModel.h
//  11-9 buttonsLayout
//
//  Created by FQ on 16/11/10.
//  Copyright © 2016年 FQ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ArchiveModel : NSObject

/** 名称 */
@property (nonatomic, copy) NSString *name;
/** 编号 */
@property (nonatomic, assign) NSInteger ID_No;

/**
 *  模型数据写入
 *
 *  @param name  名称
 *  @param ID_No 编号
 *
 *  @return 模型
 */
+ (instancetype)modelWith:(NSString *)name  no:(NSInteger)ID_No;
@end
