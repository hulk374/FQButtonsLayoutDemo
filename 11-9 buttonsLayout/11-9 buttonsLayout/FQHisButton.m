//
//  FQHisButton.m
//  11-9 buttonsLayout
//
//  Created by FQ on 16/11/9.
//  Copyright © 2016年 FQ. All rights reserved.
//

#import "FQHisButton.h"
#import "Masonry.h"
#import "UIView+Extension.h"

@interface FQHisButton ()

@end
/** 上一个被长按的按钮 */
static FQHisButton  *_lastButton;
@implementation FQHisButton

- (UIImageView *)imgView {
    if (!_imgView) {
        _imgView = [[UIImageView alloc]init];
        _imgView.image = [UIImage imageNamed:@"trash"];
        _imgView.userInteractionEnabled = YES;
        _imgView.hidden = YES;
    }
    return _imgView;
}

- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor lightGrayColor];
        [self addDelete];
        [self addLongPress];
    }
    return self;
}

- (void)addDelete {
    [self addSubview:self.imgView];
    [self addDleTap];
    
}
-(void)addDleTap{
    UITapGestureRecognizer* deleteTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(deleteTapAction:)];
    [self.imgView addGestureRecognizer:deleteTap];
}

- (void)addLongPress {
    UILongPressGestureRecognizer* longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressAction:)];
    [self addGestureRecognizer:longPress];

}

- (void)longPressAction:(UIGestureRecognizer*) Recognizer{
    if (Recognizer.state == UIGestureRecognizerStateBegan) {
        NSLog(@"长按了");
        if (!_lastButton) {  // 不存在上一次被长按的按钮
            [self setImgViewHidden:NO];
        }else{   // 存在上一次被长按的按钮
            [_lastButton setImgViewHidden:YES];
            [self setImgViewHidden:NO];
        }
            _lastButton = self;
    }
}

- (void)deleteTapAction:(UIGestureRecognizer*) Recognizer{
    NSLog(@"小删除按钮点击了");
    if (self.deleteItemblock) {
        self.deleteItemblock(self.titleLabel.text,self.tag);
    }
    NSLog(@"selg.tag--->%ld",self.tag);
    if (Recognizer.state != UIGestureRecognizerStateBegan) {
        return ;
    }
}

- (void)setImgViewHidden:(BOOL)hidden {
    if (hidden) {
        self.imgView.hidden = YES;
    }else{
        self.imgView.hidden = NO;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
//    [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.width.height.mas_equalTo(10);
//        make.top.equalTo(self.mas_top).offset(-5);
//        make.trailing.equalTo(self.mas_leading).offset(self.width - 5);
//    }];
    self.imgView.frame = CGRectMake(self.width - 5, -5, 10, 10);
//    NSLog(@"self.frame%@",NSStringFromCGRect(self.frame));
//    NSLog(@"%@",NSStringFromCGRect(self.imgView.frame));
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if (view == nil) {
        for (UIView *subView in self.subviews) {
            CGPoint tp = [subView convertPoint:point fromView:self];
            if (CGRectContainsPoint(subView.bounds, tp)) {
                view = subView;
            }
        }
    }
    
    return view;
}


@end
