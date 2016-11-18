//
//  FQDemoView.h
//  11-9 buttonsLayout
//
//  Created by FQ on 16/11/9.
//  Copyright © 2016年 FQ. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^seachWithContent)(NSString* string);
typedef void(^updataSourceData)(NSString* name,NSInteger tag);
typedef void(^clearSourceData) ();
typedef void(^removeFiveLine)  (NSMutableArray* array);
typedef void(^seachByRecomand) (NSString* string);

@interface FQDemoView : UIScrollView

/**
 *  布局搜索历史记录
 *
 *  @param dataArr
 */
- (void)layoutButtonsWithArr:(NSMutableArray*)dataArr;

@property (nonatomic, copy) seachByRecomand recomandBlock;
/**
 *  布局搜索推荐信息
 *
 *  @param dataArr
 */
- (void)layoutRecomandButtonsWithArr:(NSMutableArray*)dataArr;

@property (nonatomic, copy) seachWithContent searchBlock;
@property (nonatomic, copy) updataSourceData updataBlock;
@property (nonatomic, copy) clearSourceData  clearBlock;
/**
 *  demoView的点击事件
 *
 *  @param updataBlock 删除一条历史记录
 *  @param clearBlock  清除全部历史记录
 *  @param searchBlock 按钮的点击
 */
-(void)updataSourceData:(updataSourceData)updataBlock clearSourceData:(clearSourceData)clearBlock seachWithContent:(seachWithContent)searchBlock;

@property (nonatomic, copy) removeFiveLine  removeFiveLineBlock;

@end
