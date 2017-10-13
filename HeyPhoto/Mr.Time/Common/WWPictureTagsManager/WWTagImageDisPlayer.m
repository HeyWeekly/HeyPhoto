//
//  WWTagImageDisPlayer.m
//  Mr.Time
//
//  Created by steaest on 2017/9/7.
//  Copyright © 2017年 Offape. All rights reserved.
//

#import "WWTagImageDisPlayer.h"
#import "WWTagImageLayer.h"
#import "WWTagImageContainer.h"

@interface XER_TagedImgDisplayerProcessLayer : CALayer
@property (nonatomic, assign) CGFloat process;
@end

@interface WWTagImageDisPlayer () <WWTagImageViewDelegate,UIGestureRecognizerDelegate,WWTagImageLayerDelegate>

@property (nonatomic, assign) BOOL isJustForDisplay;
@property (nonatomic, strong) UIImageView* labelsDisplaySwitcherImg;
@property (nonatomic, strong) UIButton* labelsDisplaySwitcher;
@property (nonatomic, strong) XER_TagedImgDisplayerProcessLayer* processLayer;
@property (nonatomic, assign) BOOL isAsynLoadingImg;
@property (nonatomic, weak) WWTagImageView* guideLabel;
//衣橱的阴影手势
@property (nonatomic, strong) UIView *cabinetMaskView;
@property (nonatomic, strong) NSNumber* guideX;
@property (nonatomic, strong) NSNumber* guideY;
//手指的原始坐标点
@property (nonatomic, assign) CGPoint tapPoint;
//图片手势
@property (nonatomic, strong) UITapGestureRecognizer *tap;
//记录原始坐标点
@property (nonatomic, assign) CGPoint orginPoint;
@property (nonatomic, strong) WWTagImageLayer *moreView;
//临时属性，记录图片上的坐标点
@property (nonatomic, assign) CGPoint photoTapPoint;
@property (nonatomic, strong) NSArray *oldImageArray;
@property (nonatomic, strong) NSMutableArray *modelImageArray;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) NSInteger imageIndex;
@end

@implementation WWTagImageDisPlayer
//初始化方法
- (instancetype)initWithModel:(WWTagImageModel *)model justForDisplay:(BOOL)justForDisplay andImageArray:(NSArray *)array{
    if (self = [super init]) {
        self.modelArray = model;
        self.didTag = -2;
        self.index = 0;
        self.imageIndex = -3;
        self.imageArray = array;
        self.tap = nil;
        self.tapPoint = CGPointZero;
        [self changeModel:model];
        self.isJustForDisplay = justForDisplay;
        if (!justForDisplay) {
            [self setUpSubviews];
        }
        self.userInteractionEnabled = YES;
    }
    return self;
}

//视图布局
- (void)setUpSubviews{
    [self addSubview:self.scrollView];
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *dict = @{@"coll":self.scrollView};
    NSDictionary *metrics = @{@"collsizeH":@(KWidth),@"collsizeW":@(300*screenRate)};
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[coll(==collsizeH)]-0-|" options:0 metrics:metrics views:dict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[coll(==collsizeH)]" options:0 metrics:metrics views:dict]];
    //如果有tag，把tag移除
    for (UIView* view in self.subviews) {
        if ([view isMemberOfClass:[WWTagImageView class]]) {
            [view removeFromSuperview];
        }
    }
    
    for (int i = 0; i<self.modelArray.tagImagesList.count; i++) {
        WWTagedImgListModel* imageListModel = self.modelArray.tagImagesList[i];
        for (int k = 0; k<imageListModel.tags.count; k++) {
            WWTagedImgLabel *labelmodel = imageListModel.tags[k];
            WWTagImageView* tag = [self addTagWithModel:labelmodel andVar:i];
            [self adjustPosition:tag];
            [self layoutIfNeeded];
        }
    }
    [self layoutIfNeeded];
}

- (WWTagImageView *)addTagWithModel:(WWTagedImgLabel*)model andVar:(int )var{
    WWTagImageView* tag = [[WWTagImageView alloc] initWithModel:model justForDisplay:self.isJustForDisplay];
    tag.translatesAutoresizingMaskIntoConstraints = NO;
    if (var != 100 && self.modelImageArray.count != 0) {
        if (self.imageIndex == 1 || self.didImageView == nil) {
            if ([self.imageArray containsObject:self.modelImageArray[var]] ) {
                self.didImageView = self.tagImageViewArray[var];
            }
        }
    }
    
    CGFloat x = self.didImageView.bounds.size.width * model.siteX.floatValue;
    CGFloat y = self.didImageView.bounds.size.height * model.siteY.floatValue;
    [self.didImageView addSubview:tag];
    
    if (self.didImageView.tag != self.didTag ) {
        self.didTag = self.didImageView.tag;
    }
    
    NSLayoutConstraint* yCon = [NSLayoutConstraint constraintWithItem:tag attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.didImageView attribute:NSLayoutAttributeTop multiplier:1.0 constant:y];
    NSLayoutConstraint* xCon = [NSLayoutConstraint constraintWithItem:tag attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.didImageView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:x];
    [self addConstraints:@[xCon,yCon]];
    tag.xCon = xCon;
    tag.yCon = yCon;
    tag.delegate = self;
    return tag;
}

- (NSMutableArray *)modelImageArray {
    if (_modelImageArray == nil) {
        _modelImageArray = [NSMutableArray arrayWithCapacity:9];
    }
    return _modelImageArray;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, KWidth, KWidth )];
        NSMutableArray *mArray = [NSMutableArray arrayWithCapacity:10];
        for (int i=0; i<self.imageArray.count; i++) {
            UIView *bottonView = [[UIView alloc] initWithFrame:CGRectMake(i*KWidth, 0, KWidth, KWidth)];
            bottonView.backgroundColor = [UIColor blackColor];
            WWTagedImgListModel *sortModel = self.modelArray.tagImagesList[i];
            sortModel.sort = [NSString stringWithFormat:@"%d",i];
            UIImageView *imageView = [[UIImageView alloc]init];
            imageView.tag = i;
            UIImage *image = [[UIImage alloc]init];
            if ([self.imageArray[i] isEqual:sortModel.image]) {
                image = sortModel.image;
                imageView = sortModel.oldImageView;
                [self.modelImageArray addObject:image];
                self.imageIndex = 1;
            }else {
                image = self.imageArray[i];
                imageView.frame = CGRectMake(0, 0, KWidth, KWidth);
                sortModel.oldImageView = imageView;
                sortModel.image = self.imageArray[i];
                
                if (image.size.width>image.size.height) {
                    if (image.size.width-image.size.height>10) {
                        imageView.frame = CGRectMake(0, KWidth/8, KWidth, KWidth*3/4);
                    }
                }else if (image.size.width<image.size.height) {
                    if (image.size.height-image.size.width>10) {
                        imageView.frame = CGRectMake(KWidth/8, 0, KWidth*3/4, KWidth);
                    }
                }
            }
            imageView.userInteractionEnabled = YES;
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            imageView.image = image;
            UITapGestureRecognizer* tapOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageClick:)];
            tapOne.cancelsTouchesInView = NO;
            [imageView addGestureRecognizer:tapOne];
            UILongPressGestureRecognizer *longPre = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(imageLongClick:)];
            [imageView addGestureRecognizer:longPre];
            
            [mArray addObject:imageView];
            [bottonView addSubview:imageView];
            [_scrollView addSubview:bottonView];
        }
        self.tagImageViewArray = mArray.copy;
        _scrollView.pagingEnabled= YES;
        _scrollView.contentSize = CGSizeMake(KWidth*self.imageArray.count, KWidth);
        _scrollView.bounces = NO;
        
    }
    return _scrollView;
}

- (void)imageClick:(UITapGestureRecognizer *)tap{
    UIImageView *didImageViewTag = (UIImageView *)tap.view;
    if ([self.delegate respondsToSelector:@selector(displayer:canAddTagWithGesture:)]) {
        BOOL canAddTag = [self.delegate displayer:self canAddTagWithGesture:self.tap];
        if (self.modelArray.tagImagesList[didImageViewTag.tag].tags.count >= 5) {
            [WWHUD showMessage:@"最多添加五个标签" inView:self];            return;
        }
        if (canAddTag) {
            self.didImageView = (UIImageView *)tap.view;
            self.tapPoint = [tap locationInView:self.didImageView];
            self.tap = tap;
            
            NSArray *array = [NSArray array];
            NSMutableArray *mArray = [NSMutableArray arrayWithCapacity:10];
            [mArray addObject:self.imageArray[self.didImageView.tag]];
            array = mArray.copy;
            
            self.moreView = nil;
            self.moreView = [[WWTagImageLayer alloc]initWithImageArray:array];
            self.moreView.frame = self.superview.bounds;
            self.moreView.delegate = self;
            UIWindow *window = [UIApplication sharedApplication].keyWindow;
            // 添加到窗口
            [window addSubview:self.moreView];
        }
    }
}

- (void)imageLongClick:(UILongPressGestureRecognizer *)longPre {
    UIImageView *imageView = (UIImageView*)longPre.view;
    
    if (longPre.state == UIGestureRecognizerStateEnded) {
        if (self.modelArray.tagImagesList[imageView.tag].tags.count >0 ) {
            WWActionSheet *actionSheet = [[WWActionSheet alloc] initWithTitle:@"图片裁剪后标签需要重新添加"];
            WWActionSheetAction *action = [WWActionSheetAction actionWithTitle:@"裁剪" handler:^(WWActionSheetAction *action) {
                WWTagImageContainer *vc = [[WWTagImageContainer alloc] initWithImage:self.originImageArray[imageView.tag]];
                vc.frame = [UIScreen mainScreen].bounds;
                vc.resultImageBlock = ^(UIImage *image) {
                    NSArray <WWTagedImgLabel *> *labelModel = self.modelArray.tagImagesList[imageView.tag].tags;
                    NSMutableArray *mArray = [NSMutableArray arrayWithArray:labelModel];
                    if (mArray.count != 0) {
                        NSInteger j = mArray.count;
                        for (int i = 0; i < j; i++) {
                            [mArray removeObjectAtIndex:0];
                        }
                        labelModel = mArray.copy;
                    }else {
                        labelModel = nil;
                    }
                    self.modelArray.tagImagesList[imageView.tag].tags = labelModel;
                    for (UIView *subviews in [imageView subviews]) {
                        if ([[subviews class] isSubclassOfClass:[WWTagImageView class]]) {
                            [subviews removeFromSuperview];
                        }
                    }
                    ((UIImageView*)longPre.view).image = image;
                    long int tag = imageView.tag;
                    
                    if (image.size.width==image.size.height) {
                        imageView.frame = CGRectMake(0, 0, KWidth, KWidth);
                    }else if (image.size.width>image.size.height) {
                        if (image.size.width-image.size.height<image.size.height/4) {
                            imageView.frame = CGRectMake(0, 0, KWidth, KWidth);
                        }else {
                            imageView.frame = CGRectMake(0, KWidth/8, KWidth, KWidth*3/4);
                        }
                    }else if (image.size.width<image.size.height) {
                        if (image.size.height-image.size.width<image.size.width/4) {
                            imageView.frame = CGRectMake(0, 0, KWidth, KWidth);
                        }else{
                            imageView.frame = CGRectMake(KWidth/8, 0, KWidth*3/4, KWidth);
                        }
                    }
                    [self.scrollView inputView];
                    NSMutableArray *muArr = [NSMutableArray arrayWithArray:self.imageArray.mutableCopy];
                    muArr[tag] = image;
                    WWTagedImgListModel *sortModel = self.modelArray.tagImagesList[tag];
                    sortModel.image = image;
                    self.imageArray = muArr.copy;
                };
                [[UIApplication sharedApplication].keyWindow addSubview:vc];
            } style:kWWActionStyleDestructive];

            [actionSheet addAction:action];
            [actionSheet showInWindow:[WWGeneric popOverWindow]];
        }
    }
}

#pragma mark - 响应事件
-(void)tagDoneText:(NSString *)text {
    [UIView animateWithDuration:0.25 animations:^{
        [self.moreView removeFromSuperview];
        self.moreView = nil;
    }];
    if ([self.delegate respondsToSelector:@selector(displayer:canAddTagWithGesture:)]) {
        BOOL canAddTag = [self.delegate displayer:self canAddTagWithGesture:self.tap];
        if (self.modelArray.tagImagesList[self.didImageView.tag].tags.count >= 5) {
            [WWHUD showMessage:@"最多添加五个标签" inView:self];
            return;
        }
        if (canAddTag) {
            CGFloat x = self.tapPoint.x;
            CGFloat y = self.tapPoint.y;
            NSDictionary *dict = @{@"tagText":text,@"tagLink":@"EMPTY"};
            WWTagedImgLabel* model = [[WWTagedImgLabel alloc] initWithDict:dict];
            CGFloat xRate =  x / self.didImageView.bounds.size.width;
            CGFloat yRate = y / self.didImageView.bounds.size.height;
            model.siteX = [NSNumber numberWithFloat:xRate];
            model.siteY = [NSNumber numberWithFloat:yRate];
            model.direction = @(0);
            model.tagfont = @"PingFangSC-Regular";
            model.tagColor = @"ffffff";
            if (!self.modelArray.tagImagesList[self.didImageView.tag].tags) {
                self.modelArray.tagImagesList[self.didImageView.tag].tags = [NSArray array];
            }
            NSMutableArray* mArray = [NSMutableArray arrayWithArray:self.modelArray.tagImagesList[self.didImageView.tag].tags];
            [mArray addObject:model];
            self.modelArray.tagImagesList[self.didImageView.tag].tags = mArray.copy;
            WWTagImageView* tag = [self addTagWithModel:model andVar:100];
            [self.didImageView layoutIfNeeded];
            for (WWTagImageView* tagView in self.subviews) {
                if ([tagView isKindOfClass:[WWTagImageView class]] && ![tagView isEqual:tag]) {
                    if (CGRectIntersectsRect([tagView unionFrame], [tag unionFrame])) {
                        tag.yCon.constant = tagView.yCon.constant + 29*screenRate;
                        model.siteY = [NSNumber numberWithFloat:tag.yCon.constant / self.didImageView.bounds.size.height];
                    }
                }
            }
            [self adjustPosition:tag];
            tag.model.siteX = [NSNumber numberWithFloat:(tag.xCon.constant / (self.didImageView.bounds.size.width ? self.didImageView.bounds.size.width : 1.0))];
            tag.model.siteY = [NSNumber numberWithFloat:(tag.yCon.constant / (self.didImageView.bounds.size.height ? self.didImageView.bounds.size.height : 1.0))];
            [self.didImageView layoutIfNeeded];
            if ([self.delegate respondsToSelector:@selector(displayer:createdNoOrderTagWithModel:tag:)]) {
                [self.delegate displayer:self createdNoOrderTagWithModel:self.modelArray.tagImagesList[self.didImageView.tag].tags.lastObject tag:tag];
            }
        }
    }
}

#pragma mark - 获取图片
- (void)setImageArray:(NSArray *)imageArray{
    _imageArray = imageArray;
}

- (void)setImage:(UIImage *)image{
    if ([image isKindOfClass:[UIImage class]]) {
        //        [super setImage:image];
        if ([image isKindOfClass:[UIImage class]]) {
            //            NSLog(@" ------ displayer set image real url : \n%@",((XER_Image*)image).url);
        }
        if (image) {
            self.isAsynLoadingImg = NO;
            [self startTextAnimation];
        }
    }else{
        //        [super setImage:nil];
        self.isAsynLoadingImg = YES;
    }
}

- (void)setIsAsynLoadingImg:(BOOL)isAsynLoadingImg{
    _isAsynLoadingImg = isAsynLoadingImg;
    if (_isAsynLoadingImg && !self.processLayer) {
        self.processLayer = [[XER_TagedImgDisplayerProcessLayer alloc] init];
        self.processLayer.frame = CGRectMake((KWidth - 100*screenRate)/2, (KWidth - 5*screenRate)/2, 100*screenRate, 5*screenRate);
        self.processLayer.process = 0.0;
        [self.layer addSublayer:self.processLayer];
    }else{
        [self.processLayer removeFromSuperlayer];
        self.processLayer = nil;
        
    }
}
// x 0.55
// y 0.63
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
            if (self.subviews.count < self.modelArray.tagImagesList[self.didImageView.tag].tags.count) {
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
            [self labelSwitcherAnimateWithIsOn:isOn];
        }
    }
}

// 文字出现动画入口2
- (void)showAllText:(UIButton*)btn{
    [self showTexts];
}

- (void)labelSwitcherAnimateWithIsOn:(BOOL)isON{
    if (isON) {
        if (self.labelsDisplaySwitcherImg.alpha == 1.0) {
            return;
        }
    }else{
        if (self.labelsDisplaySwitcherImg.alpha != 1.0) {
            return;
        }
    }
    [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.labelsDisplaySwitcherImg.transform = CGAffineTransformMakeScale(0.6, 0.6);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.labelsDisplaySwitcherImg.transform = CGAffineTransformMakeScale(1.0, 1.0);
        } completion:^(BOOL finished) {
            self.labelsDisplaySwitcherImg.transform = CGAffineTransformIdentity;
        }];
    }];
    [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.labelsDisplaySwitcherImg.alpha = isON ? 1.0 : 4.0 / 7.0;
    } completion:^(BOOL finished) {
    }];
}

- (void)showTexts{
    BOOL isOn = NO;
    for (WWTagImageView* tag in self.subviews) {
        if ([tag isKindOfClass:[WWTagImageView class]]) {
            [tag showText];
            if (!tag.point.alpha) {
                isOn = NO;
            }else{
                isOn = YES;
            }
        }
        
    }
    [self labelSwitcherAnimateWithIsOn:isOn];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    for (WWTagImageView* tag in self.subviews) {
        if ([tag isMemberOfClass:[WWTagImageView class]]) {
            WWTagedImgLabel* model = tag.model;
            CGFloat x = self.didImageView.bounds.size.width * model.siteX.floatValue;
            CGFloat y = self.didImageView.bounds.size.height * model.siteY.floatValue;
            tag.xCon.constant = x;
            tag.yCon.constant = y;
            [self adjustPosition:tag];
        }
    }
    if (self.isJustForDisplay) {
        [self addSubview:self.labelsDisplaySwitcher];
        self.labelsDisplaySwitcher.translatesAutoresizingMaskIntoConstraints = NO;
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.labelsDisplaySwitcher attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:-15]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.labelsDisplaySwitcher attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-15]];
        [super layoutSubviews];
    }
}

#pragma mark - 代理事件
- (void)tagNeedAdjustPostion:(WWTagImageView *)tag{
    if (!self.isJustForDisplay) {
        [self adjustPosition:tag];
    }
}

- (void)tag:(WWTagImageView *)tag deleteBtnClicked:(UIButton *)btn{
    if ([self.delegate respondsToSelector:@selector(displayer:whenTagDeleteBtnClickedWithTag:btn:)]) {
        [self.delegate displayer:self whenTagDeleteBtnClickedWithTag:tag btn:btn];
    }
}

- (BOOL)tagAllowEdit:(WWTagImageView *)tag clickedWithGesture:(UITapGestureRecognizer *)tap{
    if ([self.delegate respondsToSelector:@selector(displayerAllowEditTag:whenTagClickedWithTag:gesture:)]) {
        BOOL allow = [self.delegate displayerAllowEditTag:self whenTagClickedWithTag:tag gesture:tap];
        return  allow;
    }
    return NO;
}

- (void)tag:(WWTagImageView*)tag panedWithGesture:(UIPanGestureRecognizer*)pan{
    if ([self.delegate respondsToSelector:@selector(displayer:canMoveTag:)]) {
        BOOL canMove = [self.delegate displayer:self canMoveTag:tag];
        if (canMove) {
            
            UIGestureRecognizerState state = pan.state;
            if (state == UIGestureRecognizerStateBegan) {
                tag.startPoint = [NSValue valueWithCGPoint:tag.unionFrame.origin];
                tag.originPoint = [NSValue valueWithCGPoint:[pan translationInView:tag]];
                tag.originCon = [NSValue valueWithCGPoint:CGPointMake(tag.xCon.constant, tag.yCon.constant)];
                [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    tag.containerView.transform = CGAffineTransformScale(tag.containerView.transform, 1.5, 1.5);
                } completion:nil];
                return;
            }
            if (state == UIGestureRecognizerStateChanged || state == UIGestureRecognizerStateEnded) {
                CGPoint location = [pan translationInView:tag];
                CGPoint originPoint = tag.originPoint.CGPointValue;
                CGPoint originCon = tag.originCon.CGPointValue;
                CGPoint startPoint = tag.startPoint.CGPointValue;
                CGFloat disX = (location.x - originPoint.x);
                CGFloat disY = (location.y - originPoint.y);
                for (WWTagImageView* tagView in self.subviews) {
                    if (![tagView isMemberOfClass:[WWTagImageView class]]) {
                        continue;
                    }
                    if ([tagView isEqual:tag]) {
                        continue;
                    }
                    CGRect judgeFrame = tagView.unionFrame;
                    CGRect changedFrame = CGRectMake(startPoint.x + disX, startPoint.y + disY, tag.unionFrame.size.width, tag.unionFrame.size.height);
                    
                    if (CGRectIntersectsRect(changedFrame, judgeFrame)) {
                        CGFloat changedY = startPoint.y + disY;
                        if (judgeFrame.origin.y - changedY > - judgeFrame.size.height / 2) {
                            disY = (judgeFrame.origin.y - [tag unionFrame].size.height) - startPoint.y;
                        }else{
                            disY = (judgeFrame.origin.y + [tag unionFrame].size.height) - startPoint.y;
                        }
                    }
                }
                CGFloat nX = originCon.x + disX;
                CGFloat nY = originCon.y + disY;
                tag.xCon.constant = nX;
                tag.yCon.constant = nY;
                CGFloat xRate = tag.xCon.constant / tag.superview.frame.size.width ? tag.superview.frame.size.width : 1;
                CGFloat yRate = tag.yCon.constant / tag.superview.frame.size.height ? tag.superview.frame.size.height : 1;
                tag.model.siteX = [NSNumber numberWithFloat:xRate];
                tag.model.siteY = [NSNumber numberWithFloat:yRate];
                [self adjustPosition:tag];
                tag.model.siteX = [NSNumber numberWithFloat:(tag.xCon.constant / (self.didImageView.bounds.size.width ? self.didImageView.bounds.size.width : 1.0))];
                tag.model.siteY = [NSNumber numberWithFloat:(tag.yCon.constant / (self.didImageView.bounds.size.height ? self.didImageView.bounds.size.height : 1.0))];
                [self layoutIfNeeded];
                if (state != UIGestureRecognizerStateChanged) {
                    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                        tag.containerView.transform = CGAffineTransformIdentity;
                    } completion:nil];
                }
            }
            
        }
    }
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


- (void)tag:(WWTagImageView*)tag longPressWithGesture:(UILongPressGestureRecognizer*)longPress{
    if ([self.delegate respondsToSelector:@selector(displayer:longPressedWithTag:gesture:andIndex:)]) {
        [self.delegate displayer:self longPressedWithTag:tag gesture:longPress andIndex:self.didImageView.tag];
    }
}

- (UIButton *)labelsDisplaySwitcher{
    if (_labelsDisplaySwitcher == nil) {
        _labelsDisplaySwitcher = [[UIButton alloc] init];
        [_labelsDisplaySwitcher setImage:[UIImage imageNamed:@"homeLookCellShowLabelBtn"] forState:UIControlStateNormal];
        [_labelsDisplaySwitcher addTarget:self action:@selector(showAllText:) forControlEvents:UIControlEventTouchUpInside];
        [_labelsDisplaySwitcher addSubview:self.labelsDisplaySwitcherImg];
        self.labelsDisplaySwitcherImg.translatesAutoresizingMaskIntoConstraints = NO;
        [_labelsDisplaySwitcher addConstraint:[NSLayoutConstraint constraintWithItem:self.labelsDisplaySwitcherImg attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_labelsDisplaySwitcher attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
        [_labelsDisplaySwitcher addConstraint:[NSLayoutConstraint constraintWithItem:self.labelsDisplaySwitcherImg attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_labelsDisplaySwitcher attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    }
    return _labelsDisplaySwitcher;
}

- (UIImageView *)labelsDisplaySwitcherImg{
    if (_labelsDisplaySwitcherImg == nil) {
        _labelsDisplaySwitcherImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"homeLookCellShowLabelImg"]];
        _labelsDisplaySwitcherImg.userInteractionEnabled = NO;
    }
    return _labelsDisplaySwitcherImg;
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

// called before touchesBegan:withEvent: is called on the gesture recognizer for a new touch. return NO to prevent the gesture recognizer from seeing this touch
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

//called before pressesBegan:withEvent: is called on the gesture recognizer for a new press. return NO to prevent the gesture recognizer from seeing this press
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
#pragma mark - mask 相关
- (void)addMaskWithImage:(UIImage*)image{
    if (!image) {
        return;
    }
    [self addSubview:self.maskView];
}

- (void)maskViewTaped:(UITapGestureRecognizer*)tap{
    
}
#pragma mark - 待还原方法
//原始获取图片方法
- (void)getImg{
    
}
- (void)changeModel:(WWTagImageModel *)model{
    self.modelArray = model;
    self.isAsynLoadingImg = NO;
    if (self.isJustForDisplay) {
        for (int i = 0; i<self.modelArray.tagImagesList.count; i++) {
            if (self.modelArray.tagImagesList) {
                self.imageArray = self.imageArray;
            }
        }
    }else{
        self.imageArray = self.imageArray;
    }
    //    [self setUpSubviews];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    
}

@end

@implementation XER_TagedImgDisplayerProcessLayer
- (instancetype)init{
    if (self = [super init]) {
        self.backgroundColor = RGBCOLOR(0xCECECE).CGColor;
        _process = 0;
    }
    return self;
}

+ (BOOL)needsDisplayForKey:(NSString *)key{
    if ([key isEqualToString:@"process"]) {
        return YES;
    }
    return [super needsDisplayForKey:key];
}

- (void)drawInContext:(CGContextRef)ctx{
    CGContextMoveToPoint(ctx, 0, 0);
    CGContextAddLineToPoint(ctx, self.frame.size.width * self.process, 0);
    CGContextAddLineToPoint(ctx, self.frame.size.width * self.process, self.frame.size.height);
    CGContextAddLineToPoint(ctx, 0, self.frame.size.height);
    CGContextClosePath(ctx);
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextFillPath(ctx);
}

- (void)setProcess:(CGFloat)process{
    if (process < _process) {
        return;
    }
    _process = process;
}
@end
