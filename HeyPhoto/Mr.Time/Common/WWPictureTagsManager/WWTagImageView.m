//
//  WWTagImageView.m
//  Mr.Time
//
//  Created by steaest on 2017/9/7.
//  Copyright © 2017年 Offape. All rights reserved.
//

#import "WWTagImageView.h"
#import "WWTagImageModel.h"
#import "UIColor+WWExt.h"

@interface WWTagImageView () <UIGestureRecognizerDelegate, WWTagImgViewTextViewDelegate>
@property (nonatomic, strong) WWTagImagePointView* point;
@property (nonatomic, assign) BOOL isEditing;
@property (nonatomic, strong) WWTagImgViewTextView* textView;
@property (nonatomic, strong) WWTagImageShopingCateView* catView;
@property (nonatomic, strong) NSLayoutConstraint* catCon;
@property (nonatomic, strong) NSLayoutConstraint* dirCon;
@property (nonatomic, assign) BOOL isJustForDisplay;
@property (nonatomic, strong) NSLayoutConstraint* textCon;
@property (nonatomic, strong) NSTimer* editingAnimationTimer;
@property (nonatomic, assign) BOOL showTextAnimating;
@end

static CGFloat height;

@implementation WWTagImageView

- (instancetype)initWithModel:(WWTagedImgLabel*)model justForDisplay:(BOOL)justForDisplay{
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(brandBtnClickPhoto) name:@"brandBtnClickPhoto" object:nil];
        self.showTextAnimating = NO;
        self.isJustForDisplay = justForDisplay;
        height = 26*screenRate;
        _model = model;
        [self setUpSubviews];
        [self tagSingleModelChanged:_model];
        self.isEditing = NO;
        [self tagSingleModelChanged:self.model];
        if (!self.isJustForDisplay) {
            WEAK_SELF;
            [_model bindingProperty:@"direction" WithBlock:^(id newValue, id oldValue) {
                [weakSelf directionChanged];
            } forIdentify:@"directionC"];
            [_model bindingProperty:@"tagfont" WithBlock:^(id newValue, id oldValue) {
                [weakSelf fontChange];
            } forIdentify:@"fontC"];
            [_model bindingProperty:@"tagColor" WithBlock:^(id newValue, id oldValue) {
                [weakSelf colorChange];
            } forIdentify:@"colorC"];
            [self setGestureRecognizers];
        }
    }
    return self;
}

#pragma mark - 通知监听
- (void)brandBtnClickPhoto {
    if ([self.model.tagLink isEqualToString:@"BRAND"]) {
        self.catView.image = [UIImage imageNamed:@"brandBtnGlodsmall"];
    }else if ([self.model.tagLink isEqualToString:@"STORE"]) {
        self.catView.image = [UIImage imageNamed:@"storeBtnGlodsmall"];
    }else if ([self.model.tagLink isEqualToString:@"ACTIVITY"]){
        self.catView.image = [UIImage imageNamed:@"activityBtnGlodsmall"];
    }else if ([self.model.tagLink isEqualToString:@"ITEM"]){
        self.catView.image = [UIImage imageNamed:@"goodsBtnGlodsmall"];
    }
}

- (BOOL)textHadShown{
    return _point.alpha;
}

#pragma mark - 相应方法
- (void)setIsEditing:(BOOL)isEditing{
    _isEditing = isEditing;
    //    _directionSwitcher.hidden = !_isEditing;
    _dirCon.constant = _isEditing ? height : 0;
    
    [self.superview layoutIfNeeded];
    if (_isEditing) {
        //        [self adjustPosition:self];
    }
    if (isEditing && !self.editingAnimationTimer) {
        __weak typeof(self) weakSelf = self;
        self.editingAnimationTimer = [NSTimer timerWithTimeInterval:4.0 target:weakSelf selector:@selector(editingAnimation) userInfo:nil repeats:YES];
        [self.editingAnimationTimer fire];
        [[NSRunLoop currentRunLoop] addTimer:self.editingAnimationTimer forMode:NSRunLoopCommonModes];
    }
    if (!isEditing) {
        [self.editingAnimationTimer invalidate];
        self.editingAnimationTimer = nil;
    }
}

- (void)editingAnimation{
    [self animationStepTwoWithCallBack:^(BOOL finished) {
        [self animationStepThreeWithCallBack:^(BOOL finished) {
            
        }];
    }];
}

- (void)removeFromSuperview{
    [_textView removeFromSuperview];
    [_catView removeFromSuperview];
    [super removeFromSuperview];
}

- (void)changeDirectionSwitcherClick{
//    self.model.direction = [NSNumber numberWithBool:!self.model.direction.boolValue];
    if (self.model.direction.boolValue == 1) {
        self.model.direction = @(0);
    }else {
        self.model.direction = @(1);
    }
}

- (void)colorChange {
    self.textView.label.textColor = [UIColor colorWithHexValue:self.model.tagColor];
    self.point.centerView.backgroundColor = [UIColor colorWithHexValue:self.model.tagColor];
    self.point.flashView.backgroundColor = [UIColor colorWithHexValue:self.model.tagColor];
}

- (void)fontChange {
    self.textView.label.font = [UIFont fontWithName:self.model.tagfont size:12*screenRate];
}

- (void)directionChanged{
    [_textView removeFromSuperview];
    [_catView removeFromSuperview];
    _textView = nil;
    _catView = nil;
    [self didMoveToSuperview];
    [self tagSingleModelChanged:self.model];
    [self.superview layoutIfNeeded];
    //    [((XER_TagedImgDisplayer*)self.superview) adjustPosition:self];
    self.model.siteX = [NSNumber numberWithFloat:(self.xCon.constant / (self.superview.frame.size.width ? self.superview.frame.size.width : 1.0))];
    self.model.siteY = [NSNumber numberWithFloat:(self.yCon.constant / (self.superview.frame.size.height ? self.superview.frame.size.height : 1.0))];
    [self.superview layoutIfNeeded];
}

- (CGRect)unionFrame{
    if (!self.model.direction.boolValue) {
        return CGRectMake(self.frame.origin.x, _textView.frame.origin.y, self.frame.size.width + _textView.frame.size.width + _catView.frame.size.width + 3*screenRate , _textView.frame.size.height);
    }else{
        return CGRectMake(self.frame.origin.x - (_textView.frame.size.width + _catView.frame.size.width + 3*screenRate), _textView.frame.origin.y, self.frame.size.width + _textView.frame.size.width + _catView.frame.size.width , _textView.frame.size.height);
    }
}
//设置🏷的手势
- (void)setGestureRecognizers{
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapEventInvoke:)];
    UIPanGestureRecognizer* pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panEventInvoke:)];
    UILongPressGestureRecognizer* longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressEventInvoke:)];
    tap.cancelsTouchesInView = NO;
    pan.cancelsTouchesInView = NO;
    longPress.cancelsTouchesInView = NO;
    tap.delegate = self;
    pan.delegate = self;
    longPress.delegate = self;
    [self setGestureRecognizers:@[tap,pan,longPress]];
}

//设置标签前面的点的约束
- (void)setUpSubviews{
    if (self.isJustForDisplay) {
        return;
    }
    self.containerView = [[UIView alloc] init];
    [self addSubview:self.containerView];
    [self.containerView addSubview:self.point];
    self.point.translatesAutoresizingMaskIntoConstraints = NO;
    self.containerView.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary* dict = @{@"point":self.point,@"con":self.containerView};
    NSDictionary* metrics = @{@"pH":@(30)};
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[con(==pH)]-0-|" options:0 metrics:metrics views:dict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[con(==pH)]-0-|" options:0 metrics:metrics views:dict]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[point(==pH)]-0-|" options:0 metrics:metrics views:dict]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[point(==pH)]-0-|" options:0 metrics:metrics views:dict]];
}

- (void)addText{
    [self addSubview:self.point];
    self.point.alpha = 0;
    self.point.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary* pdict = @{@"point":self.point};
    NSDictionary* pmetrics = @{@"pH":@(30)};
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[point(==pH)]-0-|" options:0 metrics:pmetrics views:pdict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[point(==pH)]-0-|" options:0 metrics:pmetrics views:pdict]];
    [self.superview addSubview:self.textView];
    [self.superview addSubview:self.catView];
    self.textView.alpha = 0;
    self.catView.alpha = 0;
    self.textView.translatesAutoresizingMaskIntoConstraints = NO;
    self.catView.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary* dict = @{@"point":self.point,@"text":self.textView,@"self":self,@"cat":self.catView};
    NSDictionary* metrics = @{@"pMg":@(5*screenRate)};
    BOOL  isHeight  = NO;
    if ([self.model.tagLink isEqualToString:@"BRAND"] ||
        [self.model.tagLink isEqualToString:@"STORE"] ||
        [self.model.tagLink isEqualToString:@"ACTIVITY"] ||
        [self.model.tagLink isEqualToString:@"ITEM"]) {
        isHeight = YES;
    }else if([self.model.tagLink isEqualToString:@"EMPTY"]){
        isHeight = NO;
    }
    self.catCon = [NSLayoutConstraint constraintWithItem:self.catView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:isHeight ? height : 0];
    [self.superview addConstraint:self.catCon];
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.catView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:height]];
    if (!self.model.direction.boolValue) {
        self.textCon = [NSLayoutConstraint constraintWithItem:self.textView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:3*screenRate];
        [self.superview addConstraint:self.textCon];
        [self.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[text]-0-[cat]" options:0 metrics:metrics views:dict]];
        [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.textView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
        [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.catView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    }else{
        self.textCon = [NSLayoutConstraint constraintWithItem:self.textView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:-3*screenRate];
        [self.superview addConstraint:self.textCon];
        [self.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[cat]-0-[text]" options:0 metrics:metrics views:dict]];
        [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.textView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
        [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.catView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    }
    [self.superview layoutIfNeeded];
}

- (void)animationStepOneWithCallBack:(void (^)(BOOL finished))callback{
//    self.point.transform = CGAffineTransformRotate(self.point.transform, -M_PI / 4);
    self.point.alpha = 0;
    [UIView animateWithDuration:9.0/30.0 animations:^{
        self.point.alpha = 1.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 delay:6.0/30.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
//            self.point.transform = CGAffineTransformRotate(self.point.transform, M_PI / 4 + M_PI / 8);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:6.0/30.0 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
//                self.point.transform = CGAffineTransformRotate(self.point.transform, -M_PI / 8);
            } completion:^(BOOL finished) {
                if (callback) {
                    callback(finished);
                }
            }];
        }];
    }];
}

- (void)animationStepTwoWithCallBack:(void (^)(BOOL finished))callback{
//    self.point.transform = CGAffineTransformIdentity;
    [UIView animateWithDuration:8.0/30.0 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.point.alpha = 1.0;
//        self.point.transform = CGAffineTransformScale(self.point.transform, 1.3, 1.3);
    } completion:^(BOOL finished) {
        callback(finished);
    }];
}

- (void)animationStepThreeWithCallBack:(void (^)(BOOL finished))callback{
    [UIView animateWithDuration:8.0/30.0 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
//        self.point.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        if (callback) {
            callback(finished);
        }
    }];
}

- (void)animationStepFourWithCallBack:(void (^)(BOOL finished))callback{
    
    if (self.model.direction.boolValue) {
        self.textCon.constant = 30*screenRate;
    }else{
        self.textCon.constant = -30*screenRate;
    }
    [self.superview layoutIfNeeded];
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        if (self.model.direction.boolValue) {
            self.textCon.constant = -3*screenRate;
        }else{
            self.textCon.constant = 3*screenRate;
        }
        self.textView.alpha = 1.0;
        self.catView.alpha = 1.0;
        [self.superview layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (callback) {
            callback(finished);
        }
    }];
}

- (void)startTextAnimation{
    CGRect startFrame = [self convertRect:self.bounds toView:self.window];
    if (_point == nil || _textView == nil || _catView == nil ) {
        [self addText];
        [self tagSingleModelChanged:self.model];
    }
    if (!_point.alpha && !_textView.alpha && !_catView.alpha && self.window && startFrame.origin.y == [self convertRect:self.bounds toView:self.window].origin.y && !self.showTextAnimating) {
//        DebugLog(@"%s",__FUNCTION__);
        self.showTextAnimating = YES;
        [self animationStepTwoWithCallBack:^(BOOL finished) {
            [self animationStepThreeWithCallBack:^(BOOL finished) {
                
            }];
            [self animationStepFourWithCallBack:^(BOOL finished) {
                self.showTextAnimating = NO;
//                DebugLog(@"%s end show text",__FUNCTION__);
            }];
        }];
    }
}

- (void)showText{
    if (!self.isJustForDisplay) {
        if (_textView.alpha == 0 && !self.showTextAnimating) {
            self.showTextAnimating = YES;
            if (_point == nil || _textView == nil || _catView == nil) {
                [self addText];
                [self tagSingleModelChanged:self.model];
            }
//            self.point.transform = CGAffineTransformIdentity;
            self.point.alpha = 0;
            [UIView animateWithDuration:8.0/30.0 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.point.alpha = 1.0;
//                self.point.transform = CGAffineTransformScale(self.point.transform, 1.3, 1.3);
            } completion:^(BOOL finished) {
                [self animationStepThreeWithCallBack:^(BOOL finished) {
                    
                }];
                [self animationStepFourWithCallBack:^(BOOL finished) {
                    self.showTextAnimating = NO;
//                    DebugLog(@"%s end show text",__FUNCTION__);
                }];
            }];
        }else if(!self.showTextAnimating){
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                if (self.model.direction.boolValue) {
                    self.textView.transform = CGAffineTransformTranslate(self.textView.transform, 30, 0);
                    self.catView.transform = CGAffineTransformTranslate(self.textView.transform, 30, 0);
                }else{
                    self.textView.transform = CGAffineTransformTranslate(self.textView.transform, -30, 0);
                    self.catView.transform = CGAffineTransformTranslate(self.textView.transform, -30, 0);
                }
                self.textView.alpha = 0;
                self.catView.alpha = 0;
                self.point.alpha = 0;
            } completion:^(BOOL finished) {
                [self.point removeFromSuperview];
                [self.textView removeFromSuperview];
                [self.catView removeFromSuperview];
                self.point = nil;
                self.textView = nil;
                self.catView = nil;
            }];
        }
    }
}

- (void)wavePointAnimationWithCallBack:(void (^)(BOOL finished))callback {
    if (_isAnimating) {
        return;
    }
    WWTagImagePointView* point = [[WWTagImagePointView alloc] initWithFrame:self.bounds];
    _isAnimating = YES;
    [self addSubview:point];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:point attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:point attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    [UIView animateWithDuration:1.2 delay:0.1 options:UIViewAnimationOptionCurveEaseOut animations:^{
        //        point.transform = CGAffineTransformRotate(point.transform, M_PI);
        point.transform = CGAffineTransformScale(point.transform, 4.0, 4.0);
        point.alpha = 0.0;
    } completion:^(BOOL finished) {
        [point removeFromSuperview];
        _isAnimating = NO;
        if (callback) {
            callback(finished);
        }
    }];
}

- (void)didMoveToSuperview{
    if (self.isJustForDisplay) {
    }else{
        [super didMoveToSuperview];
        [self.superview addSubview:self.textView];
        [self.superview addSubview:self.catView];
        self.textView.translatesAutoresizingMaskIntoConstraints = NO;
        self.catView.translatesAutoresizingMaskIntoConstraints = NO;
        NSDictionary* dict = @{@"point":self.point,@"text":self.textView,@"self":self,@"cat":self.catView};
        NSDictionary* metrics = @{@"pMg":@(3*screenRate)};
        self.catCon = [NSLayoutConstraint constraintWithItem:self.catView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant: 0];
        [self.superview addConstraint:self.catCon];
        [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.catView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:height]];
        if (!self.model.direction.boolValue) {
            [self.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[self]-pMg-[text]-0-[cat]" options:0 metrics:metrics views:dict]];
            [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.textView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
            [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.catView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
        }else{
            [self.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[cat]-0-[text]-pMg-[self]" options:0 metrics:metrics views:dict]];
            [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.textView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
            [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.catView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
        }
        [self.superview layoutIfNeeded];
        [self tagSingleModelChanged:self.model ];
    }
}

#pragma mark - model delegate
- (void)tagSingleModelChanged:(WWTagedImgLabel*)model{
    if ([self.model.tagLink isEqualToString:@"BRAND"] ||
        [self.model.tagLink isEqualToString:@"STORE"] ||
        [self.model.tagLink isEqualToString:@"ACTIVITY"] ||
        [self.model.tagLink isEqualToString:@"ITEM"]) {
        
        if ([self.model.tagLink isEqualToString:@"BRAND"]) {
            self.catView.image = [UIImage imageNamed:@"brandBtnGlodsmall"];
        }else if ([self.model.tagLink isEqualToString:@"STORE"]) {
            self.catView.image = [UIImage imageNamed:@"storeBtnGlodsmall"];
        }else if ([self.model.tagLink isEqualToString:@"ACTIVITY"]){
            self.catView.image = [UIImage imageNamed:@"activityBtnGlodsmall"];
        }else if ([self.model.tagLink isEqualToString:@"ITEM"]){
            self.catView.image = [UIImage imageNamed:@"goodsBtnGlodsmall"];
        }
        
        _textView.title = self.model.tagText;
        _catView.hidden = NO;
        _catCon.constant = height;
        [self.superview layoutIfNeeded];
    }else{
        _textView.title = self.model.tagText;
        _catView.hidden = YES;
        _catCon.constant = 0;
        [self.superview layoutIfNeeded];
    }
    
    if ([self.delegate respondsToSelector:@selector(tagNeedAdjustPostion:)]) {
        [self.delegate tagNeedAdjustPostion:self];
    }
}

#pragma mark - text Gesture delegte
- (void)text:(WWTagImgViewTextView *)text tapedWithGesture:(UITapGestureRecognizer *)tap{
    if ([self.delegate respondsToSelector:@selector(tagAllowEdit:clickedWithGesture:)]) {
        BOOL canEdit = [self.delegate tagAllowEdit:self clickedWithGesture:tap];
        if (canEdit) {
            self.isEditing = YES;
        }
    }
}

- (void)text:(WWTagImgViewTextView *)text pannedWithGesture:(UIPanGestureRecognizer *)pan{
    if ([self.delegate respondsToSelector:@selector(tag:panedWithGesture:)]) {
        [self.delegate tag:self panedWithGesture:pan];
    }
}

- (void)text:(WWTagImgViewTextView *)text longPressedWithGesture:(UILongPressGestureRecognizer *)longPress{
    if ([self.delegate respondsToSelector:@selector(tag:longPressWithGesture:)]) {
        [self.delegate tag:self longPressWithGesture:longPress];
    }
}

#pragma mark - 响应事件
- (void)tapEventInvoke:(UITapGestureRecognizer*)tap{
    if ([self.delegate respondsToSelector:@selector(tagAllowEdit:clickedWithGesture:)]) {
        BOOL canEdit = [self.delegate tagAllowEdit:self clickedWithGesture:tap];
        if (canEdit) {
            self.isEditing = YES;
        }else{
            self.isEditing = NO;
        }
    }
}
- (void)panEventInvoke:(UIPanGestureRecognizer*)pan{
    if ([self.delegate respondsToSelector:@selector(tag:panedWithGesture:)]) {
        [self.delegate tag:self panedWithGesture:pan];
    }
}
- (void)longPressEventInvoke:(UILongPressGestureRecognizer*)longPress{
    if ([self.delegate respondsToSelector:@selector(tag:longPressWithGesture:)]) {
        [self.delegate tag:self longPressWithGesture:longPress];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    return  (![touch.view isEqual:self]);
}
- (void)startEditing{
    self.isEditing = YES;
}

- (void)endEditing{
    self.isEditing = NO;
}

- (WWTagImgViewTextView *)textView{
    if (_textView == nil) {
        _textView = [[WWTagImgViewTextView alloc] initWithLeftForward:self.model.direction.boolValue];
        _textView.colorName = self.model.tagColor;
        _textView.fontName = self.model.tagfont;
        _textView.delegate = self;
    }
    return _textView;
}

- (WWTagImagePointView *)point{
    if (_point == nil) {
        _point = [[WWTagImagePointView alloc] initWithFrame:self.bounds];
        _point.colorName = self.model.tagColor;
    }
    return _point;
}

- (WWTagImageShopingCateView *)catView{
    if (_catView == nil) {
        _catView = [[WWTagImageShopingCateView alloc] init];
        _catView.image = [UIImage imageNamed:@"goodsBtnGlodsmall"];
        _catView.contentMode = UIViewContentModeScaleToFill;
        _catView.clipsToBounds = YES;
        _catView.userInteractionEnabled = YES;
        [_catView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapEventInvoke:)]];
        _catView.hidden = YES;
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapEventInvoke:)];
        UIPanGestureRecognizer* pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panEventInvoke:)];
        UILongPressGestureRecognizer* longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressEventInvoke:)];
        [_catView addGestureRecognizer:tap];
        [_catView addGestureRecognizer:pan];
        [_catView addGestureRecognizer:longPress];
    }
    return _catView;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end


@implementation WWTagImagePointView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    self.flashView.frame = CGRectMake((width - flashWidth) * 0.5, (height - flashWidth) * 0.5, flashWidth, flashWidth);
    self.centerView.frame = CGRectMake((width - centerWidth) * 0.5, (height - centerWidth) * 0.5, centerWidth, centerWidth);
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    [self begigFlashAnimation];
    [self prepareTimer];
}

- (void)startFlashAnimation {
    [self prepareTimer];
}

- (void)stopFlashAnimation {
    [self invalidateTimer];
}

- (void)prepareTimer {
    if (self.showTimer) {
        [self invalidateTimer];
    }
    self.showTimer = [NSTimer scheduledTimerWithTimeInterval:defaultTime target:self selector:@selector(begigFlashAnimation) userInfo:nil repeats:true];
    [[NSRunLoop currentRunLoop] addTimer:self.showTimer forMode:NSDefaultRunLoopMode];
}

- (void)invalidateTimer {
    [self.showTimer invalidate];
    self.showTimer = nil;
}

-(void)begigFlashAnimation {
    // 缩放 + 透明度动画
    self.flashView.transform = CGAffineTransformMakeScale(0.1, 0.1);
    [UIView animateWithDuration:3 animations:^{
        self.flashView.transform = CGAffineTransformMakeScale(1,1);
        self.flashView.alpha = 1.0;
        [UIView beginAnimations:@"flash" context:nil];
        [UIView setAnimationDuration:2];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        self.flashView.alpha = 0;
        [UIView commitAnimations];
    }];
}

#pragma mark - set &&get
- (void)setColorName:(NSString *)colorName {
    _colorName = colorName;
    self.centerView.backgroundColor = [UIColor colorWithHexValue:colorName];
    self.flashView.backgroundColor = [UIColor colorWithHexValue:colorName];
}

- (UIView *)flashView {
    if (!_flashView) {
        _flashView =  [[UIView alloc] init];
        [self addSubview:_flashView];
        _flashView.backgroundColor = [UIColor whiteColor];
        _flashView.layer.cornerRadius = flashWidth * 0.5;
        _flashView.alpha = 0;
    }
    return _flashView;
}

- (UIView *)centerView {
    if (!_centerView) {
        _centerView =  [[UIView alloc] init];
        [self addSubview:_centerView];
        _centerView.backgroundColor = [UIColor whiteColor];
        _centerView.layer.cornerRadius = centerWidth * 0.5;
    }
    return _centerView;
}

- (void)dealloc {
    // 关闭定时器
    [self invalidateTimer];
}
@end


@interface WWTagImgViewTextView () <UIGestureRecognizerDelegate>
@property (nonatomic, strong) NSLayoutConstraint* leftCon;
@property (nonatomic, strong) NSLayoutConstraint* wCon;
@property (nonatomic, assign) BOOL leftForward;
@end

@implementation WWTagImgViewTextView

- (instancetype)initWithLeftForward:(BOOL)leftForward{
    if (self = [super init]) {
        self.leftForward = leftForward;
        [self setUpSuviews];
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapEventInvoke:)];
        UIPanGestureRecognizer* pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panEventInvoke:)];
        UILongPressGestureRecognizer* longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressEventInvoke:)];
        tap.cancelsTouchesInView = NO;
        pan.cancelsTouchesInView = NO;
        longPress.cancelsTouchesInView = NO;
        tap.delegate = self;
        pan.delegate = self;
        longPress.delegate = self;
        [self addGestureRecognizer:tap];
        [self addGestureRecognizer:pan];
        [self addGestureRecognizer:longPress];
    }
    return self;
}

- (void)layoutSubviews{
    if (!self.leftForward) {
        self.leftCon.constant = self.frame.size.height / 3 + 5*screenRate;
    }else{
        self.leftCon.constant = -(self.frame.size.height / 3 + 5*screenRate);
    }
}

- (void)drawRect:(CGRect)rect{
    CGFloat w = self.frame.size.width;
    CGFloat h = height;
    if (!self.leftForward) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextMoveToPoint(context, 0, h / 2);
        CGContextAddLineToPoint(context, h / 3, 0);
        CGContextAddLineToPoint(context, w, 0);
        CGContextAddLineToPoint(context, w, h);
        CGContextAddLineToPoint(context, h / 3, h);
        CGContextClosePath(context);
        CGContextSetFillColorWithColor(context, RGBCOLOR(0x2A2A2A).CGColor);
        CGContextSetAlpha(context, 0.5);
        CGContextFillPath(context);
    }else{
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextMoveToPoint(context, w, h / 2);
        CGContextAddLineToPoint(context, w - h / 3, 0);
        CGContextAddLineToPoint(context, 0, 0);
        CGContextAddLineToPoint(context, 0, h);
        CGContextAddLineToPoint(context, w - h / 3, h);
        CGContextClosePath(context);
        CGContextSetFillColorWithColor(context, RGBCOLOR(0x2A2A2A).CGColor);
        CGContextSetAlpha(context, 0.5);
        CGContextFillPath(context);
    }
}

//移动的时候调用这个方法
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([gestureRecognizer.view isEqual:self.superview]) {
        return NO;
    }else{
        return YES;
    }
}

- (void)tapEventInvoke:(UITapGestureRecognizer*)tap{
    if ([self.delegate respondsToSelector:@selector(text:tapedWithGesture:)]) {
        [self.delegate text:self tapedWithGesture:tap];
    }
}

- (void)panEventInvoke:(UIPanGestureRecognizer*)pan{
    if ([self.delegate respondsToSelector:@selector(text:pannedWithGesture:)]) {
        [self.delegate text:self pannedWithGesture:pan];
    }
}
- (void)longPressEventInvoke:(UILongPressGestureRecognizer*)longPress{
    if ([self.delegate respondsToSelector:@selector(text:longPressedWithGesture:)]) {
        [self.delegate text:self longPressedWithGesture:longPress];
    }
}

- (void)setUpSuviews{
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.label];
    self.label.translatesAutoresizingMaskIntoConstraints = NO;
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.wCon = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:height];
    [self addConstraint:self.wCon];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.label attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.label attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:125*screenRate - height / 3 - 10*screenRate]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:height]];
    if (!self.leftForward) {
        self.leftCon = [NSLayoutConstraint constraintWithItem:self.label attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:height / 3 + 5*screenRate];
        [self addConstraint:self.leftCon];
    }else{
        self.leftCon = [NSLayoutConstraint constraintWithItem:self.label attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:-(height / 3 + 5*screenRate)];
        [self addConstraint:self.leftCon];
    }
}

#pragma mark - set &&get
- (void)setTitle:(NSString *)title{
    _title = title.copy;
    self.label.text = _title;
    CGSize size = [_title boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, height) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName:self.label.font} context:nil].size;
    self.wCon.constant = height / 3 + 5*screenRate + size.width + 8*screenRate > 125*screenRate ? 125*screenRate : height / 3 + 5*screenRate + size.width + 8*screenRate;
    [self layoutIfNeeded];
    [self setNeedsDisplay];
}

- (void)setColorName:(NSString *)colorName {
    _colorName = colorName;
    self.label.textColor = [UIColor colorWithHexValue:colorName];
}

- (void)setFontName:(NSString *)fontName {
    _fontName = fontName;
    self.label.font = [UIFont fontWithName:fontName size:12*screenRate];
}

- (UILabel *)label{
    if (_label == nil) {
        _label = [[UILabel alloc] init];
        _label.font = [UIFont fontWithName:kFont_Regular size:12*screenRate];
        _label.textColor = [UIColor whiteColor];
        _label.numberOfLines = 1;
        _label.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _label;
}

@end


@implementation WWTagImageShopingCateView
- (instancetype)init{
    if (self = [super init]) {
        self.backgroundColor = [UIColor clearColor];
        self.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return self;
}
@end


@implementation WWTagImageDirectionSwitcher
- (instancetype)init{
    if (self = [super init]) {
    }
    return self;
}
@end
