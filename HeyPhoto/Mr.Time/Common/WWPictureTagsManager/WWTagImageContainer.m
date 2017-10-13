//
//  WWTagImageContainer.m
//  Mr.Time
//
//  Created by steaest on 2017/9/7.
//  Copyright © 2017年 Offape. All rights reserved.
//

#import "WWTagImageContainer.h"
#import "WWTagImageScrollView.h"

@interface WWTagImageContainer ()
{
    CGFloat beginOriginY;
}
@property (nonatomic, strong) UICollectionView *collectionView;
@property (strong, nonatomic) WWTagImageScrollView *imageScrollView;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIView *nav;
@property (nonatomic, assign) CGRect cropRect;
@property (nonatomic, strong) UIView *leftView;
@property (nonatomic, strong) UIView *rightView;
@property (nonatomic, strong) UIImage *resultImage;
@end

@implementation WWTagImageContainer

- (instancetype)initWithImage:(UIImage *)image{
    if (self = [super init]) {
        [self setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:self.topView];
        [self addSubview:self.nav];
        [self.imageScrollView displayImage:image];
        [self.collectionView reloadData];
        [self addSubview:self.nav];
        [self addSubview:self.topView];
        [self pareperUI];
        
    }
    return self;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (velocity.y >= 2.0 && self.topView.frame.origin.y == 0) {
        
    }
}

//图片的默认裁剪
//TODO 原始图片

- (UIView *)topView {
    if (_topView == nil) {
        //topView:包括导航区域以及图片放置区域和拖拽区域
        CGRect rect = CGRectMake(0, 44, KWidth, KWidth);
        self.topView = [[UIView alloc] initWithFrame:rect];
        self.topView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        self.topView.backgroundColor = [UIColor clearColor];
        self.topView.clipsToBounds = YES;
        
        //图片放置区域
        rect = CGRectMake(0, 0, KWidth,KWidth);
        self.imageScrollView = [[WWTagImageScrollView alloc] initWithFrame:rect];
        self.imageScrollView.backgroundColor = RGBCOLOR(0xf2f2f2);
        [_topView addSubview:self.imageScrollView];
        [_topView sendSubviewToBack:self.imageScrollView];
    }
    return _topView;
}

- (void)pareperUI {
    
    UIButton *btnCen = [[UIButton alloc] init];
    [btnCen setImage:[UIImage imageNamed:@"1.1"] forState:UIControlStateNormal];
    [btnCen sizeToFit];
    btnCen.centerX = KWidth/2;
    btnCen.centerY = (KHeight-49-self.imageScrollView.bottom)/2+self.imageScrollView.bottom;
    btnCen.tag = 2;
    [btnCen addTarget:self action:@selector(doneClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btnCen];
    
    UIButton *btnLeft = [[UIButton alloc] init];
    [btnLeft setImage:[UIImage imageNamed:@"4.3"] forState:UIControlStateNormal];
    [btnLeft sizeToFit];
    btnLeft.bottom = btnCen.bottom;
    btnLeft.centerX = KWidth/4;
    btnLeft.tag = 1;
    [btnLeft addTarget:self action:@selector(doneClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btnLeft];
    
    UIButton *btnRight = [[UIButton alloc] init];
    [btnRight setImage:[UIImage imageNamed:@"3.4"] forState:UIControlStateNormal];
    [btnRight sizeToFit];
    btnRight.bottom = btnCen.bottom;
    btnRight.centerX = KWidth*3/4;
    btnRight.tag = 3;
    [btnRight addTarget:self action:@selector(doneClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btnRight];
    
    
    UIView *bottonView = [[UIView alloc] initWithFrame:CGRectMake(0, KHeight-49, KWidth, 49)];
    bottonView.backgroundColor = RGBCOLOR(0x333333);
    UIButton *leftBtn = [[UIButton alloc] init];
    [leftBtn setImage:[UIImage imageNamed:@"Cancel01"] forState:UIControlStateNormal];
    [leftBtn sizeToFit];
    leftBtn.left = 20;
    leftBtn.centerY = bottonView.height/2;
    [leftBtn addTarget:self action:@selector(cancelClick) forControlEvents:UIControlEventTouchUpInside];
    [bottonView addSubview:leftBtn];
    
    UIButton *rightBtn = [[UIButton alloc] init];
    [rightBtn setImage:[UIImage imageNamed:@"duihao01"] forState:UIControlStateNormal];
    [rightBtn sizeToFit];
    rightBtn.right = KWidth-20;
    rightBtn.centerY = leftBtn.centerY;
    [rightBtn addTarget:self action:@selector(sureClick) forControlEvents:UIControlEventTouchUpInside];
    [bottonView addSubview:rightBtn];
    
    UILabel *tailoring = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    tailoring.text = @"裁剪";
    tailoring.textColor = [UIColor whiteColor];
    tailoring.font = [UIFont fontWithName:kFont_Regular size:18*screenRate];
    tailoring.textAlignment = NSTextAlignmentCenter;
    [tailoring sizeToFit];
    tailoring.centerY = leftBtn.centerY;
    tailoring.centerX = KWidth/2;
    [bottonView addSubview:tailoring];
    
    [self addSubview:bottonView];
    
    [self doneClick:btnCen];
}

- (void)cancelClick {
    [self removeFromSuperview];
}

- (void)sureClick {
    
    UIButton *btn = [[UIButton alloc] init];
    if (_leftView.width==KWidth) {
        btn.tag = 1;
    }else if (_leftView.width==0) {
        btn.tag = 2;
    }else if (_leftView.width==KWidth/8) {
        btn.tag = 3;
    }
    [self doneClick:btn];
    
    if (_resultImageBlock) {
        self.resultImageBlock(self.resultImage);
    }
    [self removeFromSuperview];
}

- (void)doneClick:(UIButton *)btn {
    if (btn.tag==1) {
        CGFloat viewH = KWidth/8;
        self.leftView.frame = CGRectMake(0, 0, KWidth, viewH);
        self.rightView.frame = CGRectMake(0, KWidth-viewH, KWidth, viewH);
        self.imageScrollView.contentInset = UIEdgeInsetsMake(KWidth/8, 0, KWidth/8, 0);
    }else if (btn.tag==2) {
        self.leftView.frame = CGRectMake(0, 0, 0, 0);
        self.rightView.frame = CGRectMake(0, 0, 0, 0);
        self.imageScrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }else if (btn.tag==3) {
        CGFloat viewW = KWidth/8;
        self.leftView.frame = CGRectMake(0, 0, viewW, KWidth );
        self.rightView.frame = CGRectMake(KWidth - viewW, 0, viewW, KWidth);
        self.imageScrollView.contentInset = UIEdgeInsetsMake(0, KWidth/8, 0, KWidth/8);
    }
    [self.topView insertSubview:self.leftView aboveSubview:self.imageScrollView];
    [self.topView insertSubview:self.rightView aboveSubview:self.imageScrollView];
    
    self.cropRect = self.leftView.frame;
    self.resultImage = [self.imageScrollView captureCropImage:self.cropRect];
}

#pragma mark - 懒加载
- (UIView *)leftView {
    if (!_leftView) {
        _leftView = [[UIView alloc]init];
        _leftView.backgroundColor = RGBCOLOR(0x333333);
        _leftView.alpha = 0.8;
    }
    return _leftView;
}

- (UIView *)rightView {
    if (!_rightView) {
        _rightView = [[UIView alloc]init];
        _rightView.backgroundColor = RGBCOLOR(0x333333);
        _rightView.alpha = 0.8;
    }
    return _rightView;
}

- (UIView *)nav {
    if (_nav == nil) {
        //导航栏
        CGRect rect = CGRectMake(0, 0, CGRectGetWidth(self.topView.bounds), 44);
        UIView *navView = [[UIView alloc] initWithFrame:rect];//26 29 33
        navView.backgroundColor = [UIColor whiteColor];
        [self.topView addSubview:navView];
        
        rect = CGRectMake((KWidth - 200) / 2, 7, 200,30);
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, KWidth, 44)];
        titleLabel.text = @"照片裁剪";
        titleLabel.textColor = RGBCOLOR(0x333333);
        titleLabel.font = [UIFont fontWithName:kFont_Regular size:18*screenRate];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [navView addSubview:titleLabel];
        titleLabel.userInteractionEnabled = YES;
        _nav = navView;
    }
    return _nav;
}

@end
