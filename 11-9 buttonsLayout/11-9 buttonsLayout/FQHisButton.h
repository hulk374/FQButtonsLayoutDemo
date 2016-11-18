//
//  FQHisButton.h
//  11-9 buttonsLayout
//
//  Created by FQ on 16/11/9.
//  Copyright © 2016年 FQ. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^deleteBlock)(NSString* name,NSInteger tag);
@interface FQHisButton : UIButton
@property (nonatomic, strong) UIImageView  *imgView;

-(void)setImgViewHidden:(BOOL)hidden;

-(void)addDleTap;

@property (nonatomic, copy) deleteBlock deleteItemblock;

@end
