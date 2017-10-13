//
//  WWShowTagImgDisplayer.m
//  YaoKe
//
//  Created by steaest on 2016/11/22.
//  Copyright © 2016年 YaoKe. All rights reserved.
//

#import "WWShowTagImgDisplayer.h"
#import "WWTagImageView.h"

@interface WWShowTagImgDisplayer () <WWTagImageViewDelegate,UIGestureRecognizerDelegate,CAAnimationDelegate>
@property (nonatomic, strong) WWTagImageModel* model;
@property (nonatomic, assign) BOOL isJustForDisplay;
@property (nonatomic, strong) UIImageView* labelsDisplaySwitcherImg;
@property (nonatomic, assign) BOOL isAsynLoadingImg;
@property (nonatomic, weak) WWTagImageView* guideLabel;
@property (nonatomic, strong) NSNumber* guideX;
@property (nonatomic, strong) NSNumber* guideY;
@property (nonatomic, strong) WWTagedImgListModel *labelModel;
@end

@implementation WWShowTagImgDisplayer
- (instancetype)initWithFrame:(CGRect)frame andWithModel:(WWTagImageModel *)model justForDisplay:(BOOL)justForDisplay andWithLabelModel:(WWTagedImgListModel *)labelModel{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = RGBCOLOR(0xF3F3F3);
        self.labelModel = labelModel;
        [self changeModel:model];
        self.isJustForDisplay = justForDisplay;
        if (!justForDisplay) {
            [self setUpSubviews];
        }
        UITapGestureRecognizer* tapOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showTagImgDisplayerImageClick)];
        tapOne.cancelsTouchesInView = NO;
        [self addGestureRecognizer:tapOne];
    }
    return self;
}

- (void)setLabelModel:(WWTagedImgListModel *)labelModel {
    _labelModel = labelModel;
}

- (void)changeModel:(WWTagImageModel*)model{
    self.model = model;
    self.isAsynLoadingImg = NO;
    [self setUpSubviews];
}

- (void)setImage:(UIImage *)image{
    if ([image isKindOfClass:[UIImage class]]) {
        [super setImage:image];
        if (image) {
            self.isAsynLoadingImg = NO;
            [self startTextAnimation];
        }
    }else{
        [super setImage:nil];
        self.isAsynLoadingImg = YES;
    }
}

- (void)setIsAsynLoadingImg:(BOOL)isAsynLoadingImg{
    _isAsynLoadingImg = isAsynLoadingImg;
}

- (void)moveLabelToGuidePostion{
    WWTagImageView* label = nil;
    for (UIView* subv in self.subviews) {
        if ([subv isKindOfClass:[WWTagImageView class]]) {
            label = (WWTagImageView*)subv;
            break;
        }
    }
    if (!label) {
        return;
    }
    self.guideLabel = label;
    self.guideX = label.model.siteX;
    self.guideY = label.model.siteY;
    [UIView animateWithDuration:0.4 animations:^{
        label.xCon.constant = KWidth * 0.55;
        label.yCon.constant = KWidth * 0.63;
        label.model.siteX = @(0.55);
        label.model.siteY = @(0.63);
        [self layoutIfNeeded];
    }];
}

- (void)resetLabelPositionAfterGuide{
    [UIView animateWithDuration:0.4 animations:^{
        self.guideLabel.xCon.constant = KWidth * self.guideX.doubleValue;
        self.guideLabel.yCon.constant = KWidth * self.guideY.doubleValue;
        self.guideLabel.model.siteX = self.guideX;
        self.guideLabel.model.siteY = self.guideY;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.guideLabel = nil;
        self.guideX = nil;
        self.guideY = nil;
    }];
}

- (void)refreshView{
    [self setUpSubviews];
}

// 文字出现动画入口1
- (void)startTextAnimation{
    if (self.window && !self.isAsynLoadingImg) {
        CGRect frame = [self convertRect:self.frame toView:self.window];
        if (frame.origin.y > 0 && frame.origin.y + frame.size.height < KHeight) {
            if (self.subviews.count < self.model.tagImagesList[self.tag].tags.count) {
                [self setUpSubviews];
            }
            BOOL isOn = NO;
            for (WWTagImageView* tag in self.subviews) {
                if ([tag isKindOfClass:[WWTagImageView class]]) {
                    [tag startTextAnimation];
                    if (!tag.point.alpha) {
                        isOn = NO;
                    }else{
                        isOn = YES;
                    }
                }
            }
        }
    }
}

- (void)showTagImgDisplayerImageClick {
    [self showTexts];
}

- (void)showTexts{
    for (WWTagImageView* tag in self.subviews) {
        NSLog(@"%@",self.subviews);
        if ([tag isKindOfClass:[WWTagImageView class]]) {
            [tag showText];
        }
    }
}

- (void)layoutSubviews{
    for (WWTagImageView* tag in self.subviews) {
        if ([tag isMemberOfClass:[WWTagImageView class]]) {
            WWTagedImgLabel* model = tag.model;
            CGFloat x = self.frame.size.width * model.siteX.floatValue;
            CGFloat y = self.frame.size.height * model.siteY.floatValue;
            tag.xCon.constant = x;
            tag.yCon.constant = y;
            [self adjustPosition:tag];
        }
    }
}

#pragma mark - gesture delegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if ([gestureRecognizer isMemberOfClass:[UIPanGestureRecognizer class]] || [gestureRecognizer isMemberOfClass:[UILongPressGestureRecognizer class]]) {
        return YES;
    }
    CGPoint point = [gestureRecognizer locationInView:self];
    for (WWTagImageView* tag in self.subviews) {
        if ([tag isMemberOfClass:[WWTagImageView class]]) {
            if (CGRectContainsPoint(tag.frame, point)) {
                return NO;
            }
            for (UIView* text in tag.subviews) {
                CGRect textFrame = [text convertRect:text.frame toView:self];
                if (CGRectContainsPoint(textFrame, point)) {
                    return NO;
                }
            }
        }
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    for (UIView* subview in self.subviews) {
        if ([otherGestureRecognizer.view isEqual:subview]) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    CGPoint point = [touch locationInView:self];
    for (WWTagImageView* tag in self.subviews) {
        if ([tag isMemberOfClass:[WWTagImageView class]]) {
            if (CGRectContainsPoint(tag.frame, point)) {
                return NO;
            }
            for (UIView* text in tag.subviews) {
                CGRect textFrame = [text convertRect:text.frame toView:self];
                if (CGRectContainsPoint(textFrame, point)) {
                    return NO;
                }
            }
        }
    }
    return ([touch.view isEqual:self]);
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceivePress:(UIPress *)press{
    for (UIGestureRecognizer* gesture in press.gestureRecognizers) {
        CGPoint point = [gesture locationInView:self];
        for (WWTagImageView* tag in self.subviews) {
            if ([tag isMemberOfClass:[WWTagImageView class]]) {
                if (CGRectContainsPoint(tag.frame, point)) {
                    return NO;
                }
                for (UIView* text in tag.subviews) {
                    CGRect textFrame = [text convertRect:text.frame toView:self];
                    if (CGRectContainsPoint(textFrame, point)) {
                        return NO;
                    }
                }
            }
        }
    }
    return YES;
}

#pragma mark - 代理事件
- (void)tagNeedAdjustPostion:(WWTagImageView *)tag{
    if (!self.isJustForDisplay) {
        [self adjustPosition:tag];
    }
}
- (BOOL)tagAllowEdit:(WWTagImageView *)tag clickedWithGesture:(UITapGestureRecognizer *)tap{
    if ([self.delegate respondsToSelector:@selector(ShowdisplayerAllowEditTag:whenTagClickedWithTag:gesture:)]) {
        BOOL allow = [self.delegate ShowdisplayerAllowEditTag:self whenTagClickedWithTag:tag gesture:tap];
        return  allow;
    }
    return NO;
}

- (void)adjustPosition:(WWTagImageView*)tagView{
    if (self.isJustForDisplay) {
        return;
    }
    CGRect unionFrame = [tagView unionFrame];
    if (!tagView.model.direction.boolValue) {
        if (tagView.xCon.constant < 0) {
            tagView.xCon.constant = 0;
        }
        if (tagView.yCon.constant - (tagView.textView.frame.size.height - tagView.frame.size.height) / 2 < 0) {
            tagView.yCon.constant = (tagView.textView.frame.size.height - tagView.frame.size.height) / 2;
        }
        if (tagView.xCon.constant + unionFrame.size.width > tagView.superview.frame.size.width) {
            tagView.xCon.constant = tagView.superview.frame.size.width - unionFrame.size.width;
        }
        if (tagView.yCon.constant + (tagView.textView.frame.size.height - tagView.frame.size.height) / 2 + tagView.frame.size.height > tagView.superview.frame.size.height ) {
            tagView.yCon.constant = tagView.superview.frame.size.height - ((tagView.textView.frame.size.height - tagView.frame.size.height) / 2 + tagView.frame.size.height);
        }
    }else{
        if (tagView.xCon.constant - (tagView.unionFrame.size.width - tagView.frame.size.width) < 0) {
            tagView.xCon.constant = (tagView.unionFrame.size.width - tagView.frame.size.width);
        }
        if (tagView.yCon.constant - (tagView.textView.frame.size.height - tagView.frame.size.height) / 2 < 0) {
            tagView.yCon.constant = (tagView.textView.frame.size.height - tagView.frame.size.height) / 2;
        }
        if (tagView.xCon.constant + tagView.frame.size.width > tagView.superview.frame.size.width) {
            tagView.xCon.constant = tagView.superview.frame.size.width - tagView.frame.size.width;
        }
        if (tagView.yCon.constant + (tagView.textView.frame.size.height - tagView.frame.size.height) / 2 + tagView.frame.size.height > tagView.superview.frame.size.height ) {
            tagView.yCon.constant = tagView.superview.frame.size.height - ((tagView.textView.frame.size.height - tagView.frame.size.height) / 2 + tagView.frame.size.height);
        }
    }
}

- (UIImageView *)labelsDisplaySwitcherImg{
    if (_labelsDisplaySwitcherImg == nil) {
        _labelsDisplaySwitcherImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"homeLookCellShowLabelImg"]];
        _labelsDisplaySwitcherImg.userInteractionEnabled = NO;
    }
    return _labelsDisplaySwitcherImg;
}
- (void)setUpSubviews{
    for (UIView* view in self.subviews) {
        if ([view isMemberOfClass:[WWTagImageView class]]) {
            [view removeFromSuperview];
        }
    }
        for (WWTagedImgLabel *label in self.labelModel.tags) {
            if (label) {
                WWTagImageView* tag = [self addTagWithModel:label];
                [self adjustPosition:tag];
                [self layoutIfNeeded];
            }
        }
    [self layoutIfNeeded];
}

- (WWTagImageView *)addTagWithModel:(WWTagedImgLabel *)model {
    WWTagImageView* tag = [[WWTagImageView alloc] initWithModel:model justForDisplay:self.isJustForDisplay];
    tag.translatesAutoresizingMaskIntoConstraints = NO;
    CGFloat x = self.frame.size.width * model.siteX.floatValue;
    CGFloat y = self.frame.size.height * model.siteY.floatValue;
    [self addSubview:tag];
    NSLayoutConstraint* yCon = [NSLayoutConstraint constraintWithItem:tag attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:y];
    NSLayoutConstraint* xCon = [NSLayoutConstraint constraintWithItem:tag attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:x];
    [self addConstraints:@[xCon,yCon]];
    tag.xCon = xCon;
    tag.yCon = yCon;
    tag.delegate = self;
    return tag;
}

@end
