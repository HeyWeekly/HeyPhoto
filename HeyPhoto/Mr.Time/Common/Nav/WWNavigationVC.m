//
//  WWNavigationVC.m
//  Mr.Time
//
//  Created by steaest on 2017/6/8.
//  Copyright © 2017年 Offape. All rights reserved.
//

#import "WWNavigationVC.h"

@interface WWNavigationVC ()
//@property (nonatomic, strong) UIButton *textBtn;
@end

@implementation WWNavigationVC

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    [self.backBtn sizeToFit];
    self.backBtn.left = 20;
    self.backBtn.top = 14;
    [self addSubview:self.backBtn];
    
    [self.navTitle sizeToFit];
    self.navTitle.centerX = self.centerX;
    self.navTitle.top = 11;
    [self addSubview:self.navTitle];
    
    [self addSubview:self.rightBtn];
    [self.rightBtn sizeToFit];
    self.rightBtn.right = KWidth - 20*screenRate;
    self.rightBtn.top = 14;
}

- (void)setImageName:(NSString *)imageName {
    _imageName = imageName;
    [self.backBtn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
}

- (void)setTitColor:(UIColor *)titColor {
    _titColor = titColor;
    self.navTitle.textColor = titColor;
}

- (void)setRightColor:(UIColor *)rightColor {
    _rightColor = rightColor;
    [self.rightBtn setTitleColor:rightColor forState:UIControlStateNormal];
}

- (void)setRightName:(NSString *)rightName {
    _rightName = rightName;
    [self.rightBtn setImage:nil forState:UIControlStateNormal];
    [self.rightBtn setTitle:rightName forState:UIControlStateNormal];
    self.rightBtn.left = KWidth - 60*screenRate;
    self.rightBtn.top = 10;
    [self.rightBtn sizeToFit];
}

#pragma mark - 懒加载
- (UIButton *)backBtn {
    if (_backBtn == nil) {
        _backBtn = [[UIButton alloc]init];
        [_backBtn setImage:[UIImage imageNamed:@"bacBackBtn"] forState:UIControlStateNormal];
    }
    return _backBtn;
}

-(UILabel *)navTitle {
    if (_navTitle == nil) {
        _navTitle = [[UILabel alloc]init];
        _navTitle.textColor = [UIColor whiteColor];
        _navTitle.textAlignment = NSTextAlignmentCenter;
        _navTitle.font = [UIFont fontWithName:kFont_DINAlternate size:20];
        _navTitle.text = @"时间先生hdsalkhhfs";
    }
    return _navTitle;
}

- (UIButton *)rightBtn {
    if (_rightBtn == nil) {
        _rightBtn = [[UIButton alloc]init];
        [_rightBtn setImage:[UIImage imageNamed:@"navrightBtn"] forState:UIControlStateNormal];
        _rightBtn.titleLabel.font = [UIFont fontWithName:kFont_DINAlternate size:15];
        [_rightBtn setTitleColor:RGBCOLOR(0x292929) forState:UIControlStateNormal];
        _rightBtn.hidden = YES;
    }
    return _rightBtn;
}
@end
