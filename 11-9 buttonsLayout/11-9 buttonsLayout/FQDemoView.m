//
//  FQDemoView.m
//  11-9 buttonsLayout
//
//  Created by FQ on 16/11/9.
//  Copyright © 2016年 FQ. All rights reserved.
//
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kScreenWidth  [UIScreen mainScreen].bounds.size.width
#define labelColor [UIColor lightGrayColor]
#define labelFont  [UIFont systemFontOfSize:12]
#import "FQDemoView.h"
#import "Masonry/Masonry/Masonry.h"
#import "FQHisButton.h"

@interface FQDemoView ()
@property (nonatomic, strong) UILabel  *historyLabel;
@property (nonatomic, strong) UIButton *trashButton;
@property (nonatomic, strong) UILabel  *recommendLabel;
@property (nonatomic, strong) NSMutableArray *hisBtnsArr;

@end
@implementation FQDemoView

- (NSMutableArray *)hisBtnsArr {
    if (!_hisBtnsArr) {
        _hisBtnsArr = [NSMutableArray array];
    }
    return _hisBtnsArr;
}
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]){
        
//        [self setupHistoryUI];
    }
    return self;
}

- (void)setupHistoryUI
{
    [self addSubview:self.historyLabel];
    [self addSubview:self.trashButton];

}

#define marginTop  10
#define marginLeft 10
#define marginX    10
#define marginY    10
#define H          20
- (void)layoutButtonsWithArr:(NSMutableArray*)dataMutArr
{
    // 数组反转
    NSArray *dataArr = [[dataMutArr reverseObjectEnumerator] allObjects];
    
    NSLog(@"dataArr---%@",dataArr);
    for (FQHisButton* button in self.hisBtnsArr) {
            [button removeFromSuperview];
        }
    
    CGFloat totalX = 0;
    CGFloat totalY = 24.5 + marginY;
    NSLog(@"_historyLabel%lf",CGRectGetMaxY(_historyLabel.frame));
    
    // 把第五行的button的text放入数组中
    NSMutableArray* fiveLineArr = [NSMutableArray array];
    // 创建buttons
    for (int i = 0; i<dataArr.count; i++) {
        // 计算出数组中每个content的长度
        CGFloat textW = [dataArr[i] boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]} context:nil].size.width;
        
        CGFloat W = textW + 10;
        NSLog(@"W---%lf",W);
        totalX += marginX;
        if (totalX + W > kScreenWidth - 2*marginLeft) { // 表示该换行了
            totalY = totalY + H + marginY;
            totalX = marginX;
        }
        
        FQHisButton* hisBtn = [[FQHisButton alloc]init];
        hisBtn.deleteItemblock = ^(NSString* name, NSInteger tag){ // 删除按钮的点击
          
            // 更改数据库内容, 并刷新数据源（在控制器中）
            if (self.updataBlock) {
                self.updataBlock(name,tag);
            }
        
        };
        
        hisBtn.frame = CGRectMake(totalX, totalY, W, H);
        [hisBtn setTitle:dataArr[i] forState:UIControlStateNormal];
        [hisBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [hisBtn addTarget:self action:@selector(buttonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        hisBtn.titleLabel.font = labelFont;
        hisBtn.tag = dataArr.count -1-i;
        [self addSubview:hisBtn];
        [self.hisBtnsArr addObject:hisBtn];
        totalX += W;
        
        // 如果出现第五行，则要把第五行的内容全部取出来，
        CGFloat fiveLineY = 4*H + 4*marginY + (24.5 + marginY);
        NSLog(@"totalY---->%lf",totalY);
        NSLog(@"fiveLineY---->%lf",fiveLineY);
        // 把第五行的button的text放入数组中
        if (totalY == fiveLineY) {
            if (hisBtn.titleLabel.text) {
                [fiveLineArr addObject:hisBtn.titleLabel.text];
            }
        }
        
        // 控制器去清除第五行的内容
        if (fiveLineArr.count>0) {
            if (self.removeFiveLineBlock) {
                self.removeFiveLineBlock(fiveLineArr);
            }
            [fiveLineArr removeAllObjects];
        }
    }
    
    for (FQHisButton* button in fiveLineArr) {
         NSLog(@"button.titleLabel---->%@",button.titleLabel.text);
    }
   
    if (totalY == (4*H + 4*marginY + (24.5 + marginY)) ) { // 第五行Y
        totalY =  (3*H + 3*marginY + (24.5 + marginY));    // 改为第四行Y
    }
    [self setupRecommendUIWithHeight:(totalY + H) dataArr:dataArr];

}

- (void)setupRecommendUIWithHeight:(CGFloat)height dataArr:(NSArray*)dataArr
{
    if (dataArr.count == 0) {
        NSLog(@"没有历史记录，直接展示搜索发现");
        [self addSubview:self.recommendLabel];
        [_recommendLabel  mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(10);
            make.leading.mas_equalTo(10);
        }];
    }else{
        NSLog(@"有历史记录，先历史记录，后搜索发现");
        self.trashButton.hidden = NO;
        [self setupHistoryUI];
        [self addSubview:self.recommendLabel];
        [_historyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(10);
            make.leading.mas_equalTo(10);
        }];
        [_trashButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_historyLabel.mas_centerY).offset(0);
            make.trailing.equalTo(self.mas_leading).mas_offset(kScreenWidth -10);
        }];
        
        [_recommendLabel  mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(height + 20);
            make.leading.mas_equalTo(10);
        }];
        
        // 重新排布推荐标签
        [self layoutRecomandButtonsWithArr:nil];
    
    }
    
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
}

- (void)layoutRecomandButtonsWithArr:(NSMutableArray*)dataArr
{
    
    CGFloat totalX = 0;
    CGFloat totalY = marginY + CGRectGetMaxY(_recommendLabel.frame);
    // 创建buttons
    for (int i = 0; i<dataArr.count; i++) {
        // 计算出数组中每个content的长度
        CGFloat textW = [dataArr[i] boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]} context:nil].size.width;
        
        CGFloat W = textW + 10;
        totalX += marginX;
        if (totalX + W > kScreenWidth - 2*marginLeft) { // 表示该换行了
            totalY = totalY + H + marginY;
            totalX = marginX;
        }
        
        UIButton* recBtn = [[UIButton alloc]init];
        [recBtn setTitle:dataArr[i] forState:UIControlStateNormal];
        [recBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        recBtn.backgroundColor = [UIColor lightGrayColor]; ;
        [recBtn addTarget:self action:@selector(recButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        recBtn.titleLabel.font = labelFont;
        [self addSubview:recBtn];
        
        [recBtn  mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_recommendLabel.mas_bottom).offset(marginY);
            make.width.mas_equalTo(W);
            make.height.mas_equalTo(H);
            make.leading.equalTo(self.mas_leading).offset(totalX);
        }];
        
        totalX += W;
    }
}

- (UILabel *)historyLabel {
    if (!_historyLabel) {
        _historyLabel                 = [[UILabel alloc]init];
        _historyLabel.backgroundColor = [UIColor whiteColor];
        _historyLabel.font            = [UIFont systemFontOfSize:12];
        _historyLabel.textColor       = [UIColor blackColor];
        _historyLabel.text            = @"历史搜索";
        [_historyLabel sizeToFit];
    }
    return _historyLabel;
}

- (UIButton *)trashButton {
    if (!_trashButton) {
        _trashButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_trashButton setImage:[UIImage imageNamed:@"trash"] forState:UIControlStateNormal];
        [_trashButton addTarget:self action:@selector(trashButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _trashButton;
}

- (UILabel *)recommendLabel {
    if (!_recommendLabel) {
        _recommendLabel                 = [[UILabel alloc]init];
        _recommendLabel.backgroundColor = [UIColor whiteColor];
        _recommendLabel.font            = [UIFont systemFontOfSize:12];
        _recommendLabel.textColor       = [UIColor blackColor];
        _recommendLabel.text            = @"搜索发现";
        [_recommendLabel sizeToFit];
    }
    return _recommendLabel;
}

- (void)trashButtonDidClick
{
    NSLog(@"清空按钮点击了");
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"确定清除历史记录"
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"确定", nil];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        for (FQHisButton* button in self.hisBtnsArr) {
            [button removeFromSuperview];
        }
        [self.hisBtnsArr removeAllObjects];
    
        if (self.clearBlock) {
            self.clearBlock();
        }
    
        // 更改约束,隐藏清空按钮
        self.trashButton.hidden = YES;
        [_recommendLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(10);
            make.leading.mas_equalTo(10);
        }];
    }
}

- (void)buttonDidClick:(FQHisButton*)button
{
    if (self.searchBlock) {
        self.searchBlock(button.titleLabel.text);
    }
   // 点击之后进行搜索，并重新刷新数据源数据
}

- (void)recButtonDidClick:(UIButton*)button
{
    if (self.recomandBlock) {
        self.recomandBlock(button.titleLabel.text);
    }
}

-(void)updataSourceData:(updataSourceData)updataBlock clearSourceData:(clearSourceData)clearBlock seachWithContent:(seachWithContent)searchBlock
{
    self.updataBlock = updataBlock;
    self.clearBlock  = clearBlock;
    self.searchBlock = searchBlock;
}


@end
