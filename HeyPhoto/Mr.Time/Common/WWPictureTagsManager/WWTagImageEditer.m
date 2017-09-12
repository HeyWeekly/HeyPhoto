//
//  WWTagImageEditer.m
//  Mr.Time
//
//  Created by steaest on 2017/9/7.
//  Copyright © 2017年 Offape. All rights reserved.
//

#import "WWTagImageEditer.h"
#import "WWTagImageModel.h"
#import "WWTagImageDisPlayer.h"
#import "WWTagImageOrderModel.h"
#import "WWCollectionViewLayout.h"
#import "WWTagImageView.h"

@interface WWLabelDetailCBCell : UIButton
@property (nonatomic, copy) NSString* title;
@property (nonatomic, assign) BOOL disabled;
@property (nonatomic, strong) UIImageView* imgView;
@end


@class WWLabelDetailCB;
@protocol WWLabelDetailCBDelegate <NSObject>
- (void)didCheckLabel;
@end

@interface WWLabelDetailCB : UIView
@property (nonatomic, weak) id <WWLabelDetailCBDelegate> delegate;
@property (nonatomic, strong) UIView* maskView;
@property (nonatomic, strong) UIButton* conformBtn;
@property (nonatomic, strong) UILabel* searchResultLabel;
@property (nonatomic, strong) WWCollectionViewLayout* layout;
@property (nonatomic, strong) UIView* btnContainer;
@property (nonatomic, strong) WWLabelDetailCBCell* brandBtn;
@property (nonatomic, strong) WWLabelDetailCBCell* storeBtn;
@property (nonatomic, strong) WWLabelDetailCBCell* activityBtn;
@property (nonatomic, strong) WWLabelDetailCBCell* goodsBtn;
@property (nonatomic, strong) UILabel* commendLabel;
@property (nonatomic, assign) CGFloat bottomHeight;
@property (nonatomic, strong) NSLayoutConstraint* btnCon;
@property (nonatomic, strong) WWTagedImgLabel* model;
@property (nonatomic, weak) UIViewController* viewController;
@property (nonatomic, strong) NSDate* timestamp;
@property (nonatomic, strong) WWTagImageOrderModel *orderModel;
@end

@interface WWTagImageEditer ()
@property (nonatomic, strong) NSArray <WWTagedImgListModel*> *tagedImgModel;
@property (nonatomic, strong) WWTagImageModel *modelArray;
@property (nonatomic, strong) UIImage* originalImage;
@property (nonatomic, strong) WWTagImageDisPlayer* imgView;
@property (nonatomic, strong) UIView* nav;
@property (nonatomic, strong) WWLabelDetailCB* labelCB;
@property (nonatomic, assign) BOOL isCreatingTag;
@property (nonatomic, strong) NSLayoutConstraint* tagEditConTop;
///截图出来打标签的图片
@property (nonatomic, strong) NSArray *captureImageArray;
@property (nonatomic, strong) NSArray *didSelectPhotoKey;
//裁剪图片
@property (nonatomic, assign) NSInteger tailorPhoto;
///选择图片的key
@property (nonatomic, strong) NSArray *selectPhotoKey;
///传进来的图片字典
@property (nonatomic, strong) NSDictionary *photoDict;
@end

@implementation WWTagImageEditer
- (instancetype)initWithTailoringImageArray:(NSArray *)tailoringImageArray andWithOriginImageArray:(NSArray *)originImageArray andModelArray:(WWTagImageModel *)modelArray andSelectPhotoKey:(NSArray *)selectPhotoKey andDidSelectPhotoKey:(NSArray *)didSelectPhotoKey andPhotoDict:(NSDictionary *)photoDict {
    if (self = [super init]) {
        self.tailoringImageArray = [tailoringImageArray copy];
        self.originImageArray = [originImageArray copy];
        self.selectPhotoKey = [selectPhotoKey copy];
        self.didSelectPhotoKey = [didSelectPhotoKey copy];
        self.photoDict = [photoDict copy];
        self.isCreatingTag = YES;
        if (modelArray == nil) {
            [self createModel];
        }else {
            self.modelArray = modelArray;
            [self addNewModel];
        }
    }
    return self;
}
- (void)viewDidLoad{
    [super viewDidLoad];
    [self setUpSubviews];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    for (WWTagImageView* view in self.imgView.subviews) {
        if ([view isMemberOfClass:[WWTagImageView class]]) {
            [self.imgView adjustPosition:view];
        }
    }
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

#pragma mark - 模型相关
- (void)createModel{
    NSMutableArray *mArray = [NSMutableArray arrayWithCapacity:10];
    for (int i = 0; i < self.tailoringImageArray.count; i++) {
        WWTagedImgListModel *model = [[WWTagedImgListModel alloc] initWithDict:nil];
        [mArray addObject:model];
    }
    self.tagedImgModel = mArray.copy;
    
//    WWTagImageModel *modelArray = [[WWTagImageModel alloc]initWithDict:nil];
    WWTagImageModel *modelArray = [[WWTagImageModel alloc]initWithDict:nil];
    modelArray.tagImagesList = mArray.copy;
    self.modelArray = modelArray;
}

- (void)addNewModel{
//    NSMutableArray *mArray = [NSMutableArray arrayWithCapacity:10];
//    NSInteger count = self.selectPhotoKey.count - self.didSelectPhotoKey.count;
//    for (int i = 0 ; i<self.didSelectPhotoKey.count; i++) {
//        [mArray addObject:self.modelArray.data.tagImagesList[i]];
//    }
//    for (int i = 0; i < count; i++) {
//        XER_TagedImgListModel *model = [[XER_TagedImgListModel alloc] initWithDict:nil];
//        [mArray addObject:model];
//    }
//    self.tagedImgModel = mArray.copy;
//    
//    XER_JasonTagedImgModel *modelArray = [[XER_JasonTagedImgModel alloc]initWithDict:nil];
//    XER_TagedImgModel *imgModel = [[XER_TagedImgModel alloc]initWithDict:nil];
//    imgModel.tagImagesList = mArray.copy;
//    modelArray.data = imgModel;
//    self.modelArray = modelArray;
}
//模型赋值
- (void)setTagedImgModel:(NSArray<WWTagedImgListModel *> *)tagedImgModel {
    _tagedImgModel = tagedImgModel;
}

#pragma mark - 响应方法
-(UIImage*)captureView: (UIView *)theView
{
    CGRect rect = theView.frame;
    UIGraphicsBeginImageContextWithOptions(rect.size, theView.opaque, 0.0);
    [theView drawViewHierarchyInRect:theView.bounds afterScreenUpdates:NO];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}
//跳转发布按钮
- (void)goNextStep{
    if (self.navigationController.viewControllers.count==2) {
        self.captureImageArray = nil;
        NSMutableArray *mArray = [NSMutableArray arrayWithCapacity:10];
        for (int i = 0; i<self.imgView.tagImageViewArray.count; i++) {
            UIImage *image = [self captureView:self.imgView.tagImageViewArray[i]];
            [mArray addObject:image];
        }
        self.captureImageArray = mArray.copy;
        NSDictionary *dict =[[NSDictionary alloc] initWithObjectsAndKeys:self.imgView.imageArray,@"imageArray",self.imgView.modelArray,@"modelArray", self.captureImageArray,@"captureImageArray",self.selectPhotoKey,@"selectPhotoKey",self.originImageArray,@"originImageArray",self.photoDict,@"photoDict",nil];
        NSNotification *notification =[NSNotification notificationWithName:@"refreshData" object:nil userInfo:dict];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }else {
        NSMutableArray *mArray = [NSMutableArray arrayWithCapacity:10];
        for (int i = 0; i<self.imgView.tagImageViewArray.count; i++) {
            UIImage *image = [self captureView:self.imgView.tagImageViewArray[i]];
            [mArray addObject:image];
        }
        self.captureImageArray = mArray.copy;
//        GoIntoPhotoViewController* photoVC = [[GoIntoPhotoViewController alloc] initWithImageArray:self.imgView.imageArray andMode:self.imgView.modelArray andCapImageArray:self.captureImageArray andSelectPhotoKey:self.selectPhotoKey andoriginImageArray:self.originImageArray andPhotoDict:self.photoDict];
//        [self.navigationController pushViewController:photoVC animated:YES];
    }
}

#pragma mark - displayer delegate
- (BOOL)displayerAllowEditTag:(WWTagImageDisPlayer*)displayer whenTagClickedWithTag:(WWTagImageView*)tag gesture:(UITapGestureRecognizer*)gesture{
    [tag changeDirectionSwitcherClick];
    return NO;
}
// 模型关联 走方法了 判断不对
- (BOOL)displayer:(WWTagImageDisPlayer*)displayer canMoveTag:(WWTagImageView*)tag{
    if (!self.labelCB) {
        return YES;
    }
    if ([tag.model isEqual:self.labelCB.model]) {
        return YES;
    }else{
        return NO;
    }
}
- (void)displayer:(WWTagImageDisPlayer*)displayer longPressedWithTag:(WWTagImageView*)tag gesture:(UILongPressGestureRecognizer*)gesture andIndex:(NSInteger)index{
    if ([gesture state] == UIGestureRecognizerStateBegan) {
        if (self.labelCB || (self.imgView.maskView)) {
            if ([self.labelCB.model isEqual:tag.model]) {
//                YKAlertView *alertView = [[YKAlertView alloc] initWithTitle:L10NString(@"Hint") andText:L10NString(@"querenshanchubiaoqian") andCancel:YES];
//                __weak __typeof__(self) weakSelf = self;
//                alertView.sureBtnClick = ^() {
//                    XER_TagedImgLabel* model = tag.model;
//                    NSArray* labels = weakSelf.tagedImgModel[index].tags;
//                    NSMutableArray* mArray = [NSMutableArray arrayWithArray:labels];
//                    [mArray removeObject:model];
//                    weakSelf.tagedImgModel[index].tags = mArray.copy;
//                    [tag removeFromSuperview];
//                    [weakSelf didCheckLabel];
//                };
//                [alertView show:YES];
            }
            return;
        }
//        YKAlertView *alertView = [[YKAlertView alloc] initWithTitle:L10NString(@"Hint") andText:L10NString(@"querenshanchubiaoqian") andCancel:YES];
//        __weak __typeof__(self) weakSelf = self;
//        alertView.sureBtnClick = ^() {
//            XER_TagedImgLabel* model = tag.model;
//            NSArray* labels = weakSelf.tagedImgModel[index].tags;
//            NSMutableArray* mArray = [NSMutableArray arrayWithArray:labels];
//            [mArray removeObject:model];
//            weakSelf.tagedImgModel[index].tags = mArray.copy;
//            [tag removeFromSuperview];
//            [weakSelf didCheckLabel];
//        };
//        [alertView show:YES];
    }
}

// 关于空白区域点击
- (BOOL)displayer:(WWTagImageDisPlayer*)displayer canAddTagWithGesture:(UITapGestureRecognizer*)tap{
    if (self.imgView.maskView) {
        return NO;
    }
    if (self.labelCB) {
        return NO;
    }else{
        return YES;
    }
}

- (void)displayer:(WWTagImageDisPlayer *)displayer createdTagWithModel:(WWTagedImgLabel *)model tag:(WWTagImageView *)tag andWithOrderModel:(WWTagImageOrderModel *)orderModel{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.25 animations:^{
            self.labelCB.commendLabel.alpha = 1;
        }];
        [[NSUserDefaults standardUserDefaults] synchronize];
    });
    [self startLabelEditingWithModel:model andOrderModel:orderModel];
    [tag endEditing];
}
- (void)displayer:(WWTagImageDisPlayer*)displayer createdNoOrderTagWithModel:(WWTagedImgLabel*)model tag:(WWTagImageView*)tag{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.25 animations:^{
        }];
        [[NSUserDefaults standardUserDefaults] synchronize];
    });
    [tag startEditing];
}

#pragma mark - 视图
- (void)setUpSubviews{
    self.view.clipsToBounds = YES;
    [self.view addSubview:self.imgView];
    self.imgView.translatesAutoresizingMaskIntoConstraints = NO;
    self.nav.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary* dict = @{@"img":self.imgView};
    NSDictionary<NSString*, NSNumber*>* metrics = @{@"h":@([UIScreen mainScreen].bounds.size.width),@"maskBtnH":@(30*screenRate),@"maskMg":@(12*screenRate),@"imgTopro":@(31*screenRate),@"pMg":@(15*screenRate),@"sepToMask":@(54*screenRate)};
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.imgView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.imgView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-44-[img(==h)]" options:0 metrics:metrics views:dict]];
    UIImage* img = [UIImage imageNamed:@"lookPublishPromptText"];
    CGRect bottomArea = CGRectMake(0, 64 + KWidth, KWidth, KHeight - 64 - KWidth);
    UIImageView* promptImg = [[UIImageView alloc] initWithImage:img];
    promptImg.contentMode = UIViewContentModeCenter;
    promptImg.frame = CGRectMake((KWidth - img.size.width)/2.0, bottomArea.origin.y + (bottomArea.size.height - img.size.height)/2.0, img.size.width, img.size.height);
    [self.view addSubview:promptImg];
    
}

#pragma mark - label editer
- (void)startLabelEditingWithModel:(WWTagedImgLabel*)model andOrderModel:(WWTagImageOrderModel *)orderModel{
    self.imgView.scrollView.userInteractionEnabled = NO;
    self.labelCB = [[WWLabelDetailCB alloc] initWithFrame:CGRectMake(0, 44 + KWidth + 100, KWidth, KHeight - 44 - KWidth)];
    self.labelCB.alpha = 0;
    self.labelCB.model = model;
    self.labelCB.orderModel = orderModel;
    self.labelCB.viewController = self;
    self.labelCB.delegate = self;
    [self.view addSubview:self.labelCB];
    [UIView animateWithDuration:0.25 delay:0 options:7 animations:^{
        self.labelCB.alpha = 1.0;
        self.labelCB.frame = CGRectMake(0, 44 + KWidth, KWidth, KHeight - 44 - KWidth);
    } completion:^(BOOL finished) {
        
    }];
}

- (void)didCheckLabel{
    [UIView animateWithDuration:0.25 delay:0 options:7 animations:^{
        self.labelCB.frame = CGRectOffset(self.labelCB.frame, 0, 100);
        self.labelCB.alpha = 0;
        self.imgView.scrollView.userInteractionEnabled = YES;
    } completion:^(BOOL finished) {
        [self.labelCB removeFromSuperview];
        self.labelCB = nil;
    }];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}
#pragma mark - lazy load
- (WWTagImageDisPlayer *)imgView{
    if (_imgView == nil) {
        _imgView = [[WWTagImageDisPlayer alloc] initWithModel:self.modelArray justForDisplay:NO andImageArray:self.tailoringImageArray];
        _imgView.originImageArray = self.originImageArray;
        _imgView.delegate = self;
    }
    return _imgView;
}

- (void)goBackNav{
    if ([self.delegate respondsToSelector:@selector(tagedImgEditerWantPoped:)]) {
        [self.delegate tagedImgEditerWantPoped:self];
    }
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}

- (UIView *)rightItemView {
    UIButton *goBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [goBtn setTitle:@"下一步" forState:UIControlStateNormal];
    [goBtn setTitleColor:RGBCOLOR(0x333333) forState:UIControlStateNormal];
    goBtn.titleLabel.font = [UIFont fontWithName:kFont_Regular size:14];
    [goBtn addTarget:self action:@selector(goNextStep) forControlEvents:UIControlEventTouchUpInside];
    return goBtn;
}
- (NSString *)navgationBarTitle {
    return @"添加标签";
}
@end



@implementation WWLabelDetailCB
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.model.tagLink = @"EMPTY";
        self.bottomHeight = 40.0*screenRate;
        [self setupSubviews];
    }
    return self;
}
- (void)setModel:(WWTagedImgLabel *)model {
    _model = model;
}
- (void)setOrderModel:(WWTagImageOrderModel *)orderModel {
    _orderModel = orderModel;
//    if ([_orderModel.storeType isEqualToString:@"STORE"]) {
//        self.storeBtn.imgView.image = [UIImage imageNamed:L10NString(@"mendianmeixuan")];
//        self.activityBtn.imgView.image = [UIImage imageNamed:L10NString(@"huodongbukedianji")];
//    }else if ([self.orderModel.storeType isEqualToString:@"AVTIVITY"]) {
//        self.storeBtn.imgView.image = [UIImage imageNamed:L10NString(@"mendianbukedianji")];
//        self.activityBtn.imgView.image = [UIImage imageNamed:L10NString(@"huodongmeixuan")];
//    }
}
//点击品牌
- (void)brandBtnClick {
//    self.model.tagLink = @"BRAND";
////    DebugLog(@"%s",__FUNCTION__);
//    self.goodsBtn.imgView.image = [UIImage imageNamed:L10NString(@"shangpinmeixuan")];
//    if ([self.orderModel.storeType isEqualToString:@"STORE"]) {
//        self.storeBtn.imgView.image = [UIImage imageNamed:L10NString(@"mendianmeixuan")];
//        self.activityBtn.imgView.image = [UIImage imageNamed:L10NString(@"huodongbukedianji")];
//    }else if ([self.orderModel.storeType isEqualToString:@"AVTIVITY"]) {
//        self.storeBtn.imgView.image = [UIImage imageNamed:L10NString(@"mendianbukedianji")];
//        self.activityBtn.imgView.image = [UIImage imageNamed:L10NString(@"huodongmeixuan")];
//    }
//    self.brandBtn.imgView.image = [UIImage imageNamed:L10NString(@"pinpaixuanzhong")];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"brandBtnClickPhoto" object:nil];
}
- (void)storeBtnClick {
    
//    if ([self.orderModel.storeType isEqualToString:@"STORE"]) {
//        self.model.tagLink = @"STORE";
//        self.goodsBtn.imgView.image = [UIImage imageNamed:L10NString(@"shangpinmeixuan")];
//        self.activityBtn.imgView.image = [UIImage imageNamed:L10NString(@"huodongbukedianji")];
//        self.storeBtn.imgView.image = [UIImage imageNamed:L10NString(@"mendianxuanzhong")];
//        self.brandBtn.imgView.image = [UIImage imageNamed:L10NString(@"pinpaimeixuan")];
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"brandBtnClickPhoto" object:nil];
//    }else {
//        return;
//    }
    
}
- (void)activityBtnClick {
    
//    if ([self.orderModel.storeType isEqualToString:@"AVTIVITY"]) {
//        self.model.tagLink = @"ACTIVITY";
//        self.goodsBtn.imgView.image = [UIImage imageNamed:L10NString(@"shangpinmeixuan")];
//        self.activityBtn.imgView.image = [UIImage imageNamed:L10NString(@"huodongxuanzhong")];
//        self.storeBtn.imgView.image = [UIImage imageNamed:L10NString(@"mendianbukedianji")];
//        self.brandBtn.imgView.image = [UIImage imageNamed:L10NString(@"pinpaimeixuan")];
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"brandBtnClickPhoto" object:nil];
//    }else {
//        return;
//    }
    
}
- (void)goodsBtnClick {
//    self.model.tagLink = @"ITEM";
////    DebugLog(@"%s",__FUNCTION__);
//    self.goodsBtn.imgView.image = [UIImage imageNamed:L10NString(@"shangpinxuanzhong")];
//    if ([self.orderModel.storeType isEqualToString:@"STORE"]) {
//        self.storeBtn.imgView.image = [UIImage imageNamed:L10NString(@"mendianmeixuan")];
//        self.activityBtn.imgView.image = [UIImage imageNamed:L10NString(@"huodongbukedianji")];
//    }else if ([self.orderModel.storeType isEqualToString:@"AVTIVITY"]) {
//        self.storeBtn.imgView.image = [UIImage imageNamed:L10NString(@"mendianbukedianji")];
//        self.activityBtn.imgView.image = [UIImage imageNamed:L10NString(@"huodongmeixuan")];
//    }
//    self.brandBtn.imgView.image = [UIImage imageNamed:L10NString(@"pinpaimeixuan")];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"brandBtnClickPhoto" object:nil];
}

#pragma mark - 视图
- (void)setupSubviews{
    [self addSubview:self.commendLabel];
    [self addSubview:self.btnContainer];
    [self addSubview:self.conformBtn];
    self.conformBtn.alpha = 1;
    [self.layout prepareLayout];
    self.brandBtn  = [[WWLabelDetailCBCell alloc] initWithFrame:[self.layout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]].frame];
    self.storeBtn  = [[WWLabelDetailCBCell alloc] initWithFrame:[self.layout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0]].frame];
    self.activityBtn  = [[WWLabelDetailCBCell alloc] initWithFrame:[self.layout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:2 inSection:0]].frame];
    self.goodsBtn  = [[WWLabelDetailCBCell alloc] initWithFrame:[self.layout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:3 inSection:0]].frame];
    
    self.brandBtn.imgView.image = [UIImage imageNamed:@"defaultHead"];
    self.brandBtn.contentMode = UIViewContentModeScaleAspectFit;
    self.brandBtn.clipsToBounds = YES;
    [self.btnContainer addSubview:self.brandBtn];
    [self.brandBtn addTarget:self action:@selector(brandBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    
//    if ([self.orderModel.storeType isEqualToString:@"STORE"]) {
//        self.storeBtn.imgView.image = [UIImage imageNamed:L10NString(@"mendianmeixuan")];
//        self.activityBtn.imgView.image = [UIImage imageNamed:L10NString(@"huodongbukedianji")];
//    }else if ([self.orderModel.storeType isEqualToString:@"AVTIVITY"]) {
//        self.storeBtn.imgView.image = [UIImage imageNamed:L10NString(@"mendianbukedianji")];
//        self.activityBtn.imgView.image = [UIImage imageNamed:L10NString(@"huodongmeixuan")];
//    }else {
//        self.activityBtn.imgView.image = [UIImage imageNamed:L10NString(@"huodongbukedianji")];
//        self.storeBtn.imgView.image = [UIImage imageNamed:L10NString(@"mendianbukedianji")];
//    }
    self.storeBtn.contentMode = UIViewContentModeScaleAspectFit;
    self.storeBtn.clipsToBounds = YES;
    [self.btnContainer addSubview:self.storeBtn];
    [self.storeBtn addTarget:self action:@selector(storeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    self.activityBtn.contentMode = UIViewContentModeScaleAspectFit;
    self.activityBtn.clipsToBounds = YES;
    [self.btnContainer addSubview:self.activityBtn];
    [self.activityBtn addTarget:self action:@selector(activityBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
//    self.goodsBtn.imgView.image = [UIImage imageNamed:L10NString(@"shangpinxuanzhong")];
    self.goodsBtn.contentMode = UIViewContentModeScaleAspectFit;
    self.goodsBtn.clipsToBounds = YES;
    [self.btnContainer addSubview:self.goodsBtn];
    self.model.tagLink = @"ITEM";
    [self.goodsBtn addTarget:self action:@selector(goodsBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    self.btnContainer.translatesAutoresizingMaskIntoConstraints = NO;
    self.commendLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.conformBtn.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary* dict = @{@"btn":self.btnContainer,@"commend":self.commendLabel,@"conform":self.conformBtn};
    NSDictionary* metrics = @{@"btnM":@(44*screenRate),@"cabH":@(_bottomHeight),@"commendT":@(30*screenRate),@"btnH":@(65*screenRate),@"resultB":@((40+20)*screenRate),@"resultH":@(50*screenRate),@"resultW":@(KWidth-30*screenRate*2)};
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-commendT-[btn]-commendT-|" options:0 metrics:metrics views:dict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[btn(==btnH)]" options:0 metrics:metrics views:dict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[conform]-0-|" options:0 metrics:metrics views:dict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[conform(==cabH)]-0-|" options:0 metrics:metrics views:dict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-commendT-[commend]" options:0 metrics:metrics views:dict]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.commendLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    self.btnCon = [NSLayoutConstraint constraintWithItem:self.btnContainer attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:85*screenRate];
    [self addConstraint:self.btnCon];
}

#pragma mark - cb layout
- (NSInteger)layoutNumberOfSection:(WWCollectionViewLayout *)layout{
    return 1;
}
- (NSInteger)layout:(WWCollectionViewLayout *)layout numberOfItemsForSection:(NSInteger)section{
    return 4;
}

- (CGSize)layout:(WWCollectionViewLayout *)layout sizeForCellAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(42*screenRate, 65*screenRate);
}
- (WWCollectionViewLayout *)layout{
    if (_layout == nil) {
        _layout = [[WWCollectionViewLayout alloc] init];
        _layout.InteritemSpacing = 47*screenRate;
        _layout.expectSize = [NSValue valueWithCGSize:CGSizeMake(KWidth - 25*2*screenRate, 65*screenRate)];
        _layout.delegate = self;
        _layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return _layout;
}
- (UIView *)btnContainer{
    if (_btnContainer == nil) {
        _btnContainer = [UIView new];
    }
    return _btnContainer;
}

- (UILabel *)commendLabel{
    if (_commendLabel == nil) {
        _commendLabel = [[UILabel alloc] init];
        _commendLabel.font = [UIFont fontWithName:kFont_Regular size:14*screenRate];
        _commendLabel.textColor = RGBCOLOR(0x333333);
        _commendLabel.text = @"大傻逼";
    }
    return _commendLabel;
}

- (UIButton *)conformBtn{
    if (_conformBtn == nil) {
        _conformBtn = [[UIButton alloc] init];
        _conformBtn.backgroundColor = RGBCOLOR(0x333333);
        [_conformBtn setTitle:@"添加" forState:UIControlStateNormal];
        [_conformBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _conformBtn.titleLabel.font = [UIFont fontWithName:kFont_Regular size:14*screenRate];
        [_conformBtn addTarget:self action:@selector(conformBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _conformBtn;
}
//底部的添加按钮的点击事件
- (void)conformBtnClick{
    if ([self.delegate respondsToSelector:@selector(didCheckLabel)]) {
        [self.delegate didCheckLabel];
    }
}
@end



@implementation WWLabelDetailCBCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setUpSubviews];
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)setUpSubviews{
    [self addSubview:self.imgView];
    self.imgView.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary* dict = @{@"img":self.imgView};
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[img]-0-|" options:0 metrics:nil views:dict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[img]-0-|" options:0 metrics:nil views:dict]];
}

- (UIImageView *)imgView{
    if (_imgView == nil) {
        _imgView = [[UIImageView alloc] init];
        _imgView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imgView;
}
@end
