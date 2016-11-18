//
//  ArchiveModel.m
//  11-9 buttonsLayout
//
//  Created by FQ on 16/11/10.
//  Copyright © 2016年 FQ. All rights reserved.
//

#import "ArchiveModel.h"

@implementation ArchiveModel
+ (instancetype)modelWith:(NSString *)name  no:(NSInteger)ID_No {
    ArchiveModel *model = [[ArchiveModel alloc] init];
    model.name = name;
    model.ID_No = ID_No;
    return model;
}
@end
