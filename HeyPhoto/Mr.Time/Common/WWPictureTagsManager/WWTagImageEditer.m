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
#import "WWStikerSeleectVC.h"
#import "WWAlbumTitle.h"

@interface WWTagCustomSettingCell : UICollectionViewCell
@property (nonatomic, copy) NSString* title;
@property (nonatomic, strong) UILabel* textLabel;
@property (nonatomic, strong) UIImageView* imgView;
@property (nonatomic, strong) UIView* colorView;
@property (nonatomic, strong) UIImage* image;
@property (nonatomic, strong) NSString* color;
@end


@interface WWTagCustomSetting : UIView <UICollectionViewDelegate, UICollectionViewDataSource, WWCollectionViewLayoutDelegate>
@property (nonatomic, strong) UILabel* commendLabel;
@property (nonatomic, strong) UIButton* conformBtn;
@property (nonatomic, strong) UICollectionView* collection;
@property (nonatomic, strong) WWCollectionViewLayout* layout;
@property (nonatomic, copy) NSArray* modelArray;
@property (nonatomic, strong) void (^clickCallBack)(UICollectionView* collectionView,NSIndexPath* indexPath);
- (instancetype)initWithModelArray:(NSArray*)modelArray clickCallBack:(void (^)(UICollectionView* collectionView,NSIndexPath* indexPath))callBack;
@end


@interface WWLabelDetailCBCell : UIButton
@property (nonatomic, copy) NSString* title;
@property (nonatomic, assign) BOOL disabled;
@property (nonatomic, strong) UILabel* customTagOption;
@end


@class WWLabelDetailCB;
@protocol WWLabelDetailCBDelegate <NSObject>
- (void)didCheckLabel;
@end

@interface WWLabelDetailCB : UIView<WWCollectionViewLayoutDelegate>
@property (nonatomic, strong) WWTagCustomSetting *tagSetting;
@property (nonatomic, weak) id <WWLabelDetailCBDelegate> delegate;
@property (nonatomic, strong) UIView* maskView;
@property (nonatomic, strong) UIButton* conformBtn;
@property (nonatomic, strong) UILabel* searchResultLabel;
@property (nonatomic, strong) WWCollectionViewLayout* layout;
@property (nonatomic, strong) UIView* btnContainer;
@property (nonatomic, strong) WWLabelDetailCBCell* colorBtn;
@property (nonatomic, strong) WWLabelDetailCBCell* fontBtn;
@property (nonatomic, strong) WWLabelDetailCBCell* shapeBtn;
@property (nonatomic, strong) UILabel* commendLabel;
@property (nonatomic, assign) CGFloat bottomHeight;
@property (nonatomic, strong) NSLayoutConstraint* btnCon;
@property (nonatomic, strong) WWTagedImgLabel* model;
@property (nonatomic, weak) UIViewController* viewController;
@property (nonatomic, strong) NSDate* timestamp;
@end

@interface WWTagImageEditer ()<WWLabelDetailCBDelegate,WWTagImageDisPlayerDelegate,XER_ImgTagCabinetDelegate>
@property (nonatomic, strong) WWNavigationVC *nav;
@property (nonatomic, strong) WWAlbumTitle *stickerBtn;
@property (nonatomic, strong) NSArray <WWTagedImgListModel*> *tagedImgModel;
@property (nonatomic, strong) WWTagImageModel *modelArray;
@property (nonatomic, strong) UIImage* originalImage;
@property (nonatomic, strong) WWTagImageDisPlayer* imgView;
@property (nonatomic, strong) WWStikerSeleectVC *selectStickerVC;
@property (nonatomic, strong) UIView* maskView;
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
@property (nonatomic, strong) NSArray *asset;
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
    NSMutableArray *mArray = [NSMutableArray arrayWithCapacity:10];
    NSInteger count = self.selectPhotoKey.count - self.didSelectPhotoKey.count;
    for (int i = 0 ; i<self.didSelectPhotoKey.count; i++) {
        [mArray addObject:self.modelArray.tagImagesList[i]];
    }
    for (int i = 0; i < count; i++) {
        WWTagedImgListModel *model = [[WWTagedImgListModel alloc] initWithDict:nil];
        [mArray addObject:model];
    }
    self.tagedImgModel = mArray.copy;
    
//    XER_JasonTagedImgModel *modelArray = [[XER_JasonTagedImgModel alloc]initWithDict:nil];
    WWTagImageModel *modelArray = [[WWTagImageModel alloc]initWithDict:nil];
    modelArray.tagImagesList = mArray.copy;
//    modelArray.data = imgModel;
    self.modelArray = modelArray;
}

- (void)setTagedImgModel:(NSArray<WWTagedImgListModel *> *)tagedImgModel {
    _tagedImgModel = tagedImgModel;
}

#pragma mark - 视图
- (void)setUpSubviews{
    self.view.clipsToBounds = YES;
    [self.view addSubview:self.nav];
    [self.view addSubview:self.imgView];
    self.imgView.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary* dict = @{@"img":self.imgView};
    NSDictionary<NSString*, NSNumber*>* metrics = @{@"h":@([UIScreen mainScreen].bounds.size.width),@"maskBtnH":@(30*screenRate),@"maskMg":@(12*screenRate),@"imgTopro":@(31*screenRate),@"pMg":@(15*screenRate),@"sepToMask":@(54*screenRate)};
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.imgView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.imgView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-44-[img(==h)]" options:0 metrics:metrics views:dict]];
    UIImage* img = [UIImage imageNamed:@"lookPublishPromptText"];
    CGRect bottomArea = CGRectMake(0, 64 + KWidth, KWidth, KHeight - 64 - KWidth);
    UIImageView* promptImg = [[UIImageView alloc] initWithImage:img];
    promptImg.contentMode = UIViewContentModeCenter;
    promptImg.frame = CGRectMake((KWidth - img.size.width)/2.0, bottomArea.origin.y + (bottomArea.size.height - img.size.height)/2.0-30, img.size.width, img.size.height);
    [self.view addSubview:promptImg];
    
    [self.view addSubview:self.stickerBtn];
    
}

- (void)cabinet:(WWStikerSeleectVC *)cabinet selectedGoodsWithModel:(id)model {
    [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.selectStickerVC.view.frame = CGRectMake(0, KHeight-40*screenRate, KWidth, KHeight - 137*screenRate);
        self.maskView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.maskView removeFromSuperview];
        [self.selectStickerVC.view removeFromSuperview];
        self.maskView = nil;
        self.selectStickerVC = nil;
    }];
    if (!model) {
        return;
    }
}

- (void)selectSticker{
    WWStikerSeleectVC* selectStickerVC = [[WWStikerSeleectVC alloc]initWithGoods:nil withSelectGoods_ID:nil searchCondition:nil];
    self.selectStickerVC = selectStickerVC;
    self.selectStickerVC.delegate = self;
    self.maskView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.maskView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    [self.maskView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(maskViewClick)]];
    [self.view.window addSubview:self.maskView];
    self.maskView.alpha = 0;
    [self.view.window addSubview:self.selectStickerVC.view];
    self.selectStickerVC.view.frame = CGRectMake(0, KHeight-40*screenRate, KWidth, KHeight - 137*screenRate);
    [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.selectStickerVC.view.frame = CGRectMake(0, 137*screenRate, KWidth, KHeight-137*screenRate);
        self.maskView.alpha = 1.0;
    } completion:^(BOOL finished) {
    }];
}

- (void)maskViewClick{
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.selectStickerVC.view.frame = CGRectMake(0,KHeight - 40*screenRate, KWidth, KHeight - 137*screenRate);
        self.maskView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.maskView removeFromSuperview];
        [self.selectStickerVC.view removeFromSuperview];
        self.maskView = nil;
    }];
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.maskView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.maskView removeFromSuperview];
        self.maskView = nil;
    }];
}

- (WWAlbumTitle *)stickerBtn{
    if (_stickerBtn == nil) {
        _stickerBtn = [WWAlbumTitle buttonWithType:UIButtonTypeCustom];
        _stickerBtn.frame = CGRectMake(0, KHeight-44, KWidth, 44);
        _stickerBtn.backgroundColor = viewBackGround_Color;
        [_stickerBtn setImage:[UIImage imageNamed:@"albumxiala"] forState:UIControlStateNormal];
        _stickerBtn.imageView.transform = CGAffineTransformMakeRotation(M_PI);
        [_stickerBtn setTitle:@"贴纸" forState:UIControlStateNormal];
        [_stickerBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _stickerBtn.titleLabel.font = [UIFont fontWithName:kFont_DINAlternate size:19*screenRate];
        _stickerBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_stickerBtn addTarget:self action:@selector(selectSticker) forControlEvents:UIControlEventTouchUpInside];
    }
    return _stickerBtn;
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

- (void)displayer:(WWTagImageDisPlayer*)displayer createdNoOrderTagWithModel:(WWTagedImgLabel*)model tag:(WWTagImageView*)tag{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.25 animations:^{
            self.labelCB.commendLabel.alpha = 1;
        }];
        [[NSUserDefaults standardUserDefaults] synchronize];
    });
    [self startLabelEditingWithModel:model andOrderModel:nil];
    
    [tag startEditing];
}

#pragma mark - label editer
- (void)startLabelEditingWithModel:(WWTagedImgLabel*)model andOrderModel:(WWTagImageOrderModel *)orderModel{
    self.imgView.scrollView.userInteractionEnabled = NO;
    self.labelCB = [[WWLabelDetailCB alloc] initWithFrame:CGRectMake(0, 44 + KWidth + 100, KWidth, KHeight - 44 - KWidth)];
    self.labelCB.alpha = 0;
    self.labelCB.model = model;
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

#pragma mark - 响应方法
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

-(UIImage*)captureView: (UIView *)theView
{
    CGRect rect = theView.frame;
    UIGraphicsBeginImageContextWithOptions(rect.size, theView.opaque, 0.0);
    [theView drawViewHierarchyInRect:theView.bounds afterScreenUpdates:NO];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (void)goBackNav{
    if ([self.delegate respondsToSelector:@selector(tagedImgEditerWantPoped:)]) {
        [self.delegate tagedImgEditerWantPoped:self];
    }
}

- (void)backto {
    [self.navigationController popViewControllerAnimated:YES];
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

- (WWNavigationVC *)nav {
    if (_nav == nil) {
        _nav = [[WWNavigationVC alloc]initWithFrame:CGRectMake(0, 0, KWidth, 44)];
        _nav.backBtn.hidden = NO;
        _nav.rightBtn.hidden = NO;
        _nav.navTitle.text = @"添加标签";
        _nav.rightName = @"下一步";
        _nav.imageName = @"backBtnBlack";
        _nav.titColor = RGBCOLOR(0x292929);
        _nav.rightColor = RGBCOLOR(0x292929);
        [_nav.rightBtn addTarget:self action:@selector(goNextStep) forControlEvents:UIControlEventTouchUpInside];
        [_nav.backBtn addTarget:self action:@selector(backto) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nav;
}

- (BOOL)prefersStatusBarHidden{
    return YES;
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

#pragma mark - 视图
- (void)setupSubviews{
    
    [self addSubview:self.commendLabel];
    [self addSubview:self.btnContainer];
    [self addSubview:self.conformBtn];
    self.conformBtn.alpha = 1;
    [self.layout prepareLayout];
    self.colorBtn = [[WWLabelDetailCBCell alloc] initWithFrame:[self.layout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]].frame];
    self.fontBtn = [[WWLabelDetailCBCell alloc] initWithFrame:[self.layout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0]].frame];
    self.shapeBtn = [[WWLabelDetailCBCell alloc] initWithFrame:[self.layout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:2 inSection:0]].frame];
    [self.colorBtn setTitle:@"颜色" forState:UIControlStateNormal];
    [self.fontBtn setTitle:@"字体" forState:UIControlStateNormal];
    [self.shapeBtn setTitle:@"形状" forState:UIControlStateNormal];
    [self.colorBtn addTarget:self action:@selector(colorBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.fontBtn addTarget:self action:@selector(fontBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.shapeBtn addTarget:self action:@selector(shapeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    self.shapeBtn.userInteractionEnabled = YES;
    [self.btnContainer addSubview:self.colorBtn];
    [self.btnContainer addSubview:self.fontBtn];
    [self.btnContainer addSubview:self.shapeBtn];
    self.btnContainer.translatesAutoresizingMaskIntoConstraints = NO;
    self.commendLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.conformBtn.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary* dict = @{@"btn":self.btnContainer,@"commend":self.commendLabel,@"conform":self.conformBtn};
    NSDictionary* metrics = @{@"btnM":@(44*screenRate),@"cabH":@(_bottomHeight),@"commendT":@(45*screenRate),@"btnH":@(65*screenRate),@"resultB":@((40+20)*screenRate),@"resultH":@(50*screenRate),@"resultW":@(KWidth-30*screenRate*2)};
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-commendT-[btn]" options:0 metrics:metrics views:dict]];
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
    return 3;
}

- (CGSize)layout:(WWCollectionViewLayout *)layout sizeForCellAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(65*screenRate, 65*screenRate);
}

- (void)resetTwiceCBWithCallBack:(void (^)(BOOL finished))callback{
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        weakSelf.tagSetting.frame = CGRectOffset(self.bounds, 0, 50);
        weakSelf.tagSetting.alpha = 0;
    } completion:^(BOOL finished) {
        [weakSelf.tagSetting removeFromSuperview];
        weakSelf.tagSetting = nil;
        if (callback) {
            callback(finished);
        }
    }];
}

- (void)colorBtnClick{
    __weak typeof(self) weakSelf = self;
    if (self.tagSetting) {
        [self resetTwiceCBWithCallBack:^(BOOL finished) {
            [weakSelf showColor];
        }];
    }else{
        [self showColor];
    }
}
- (void)showColor{
    __weak typeof(self) weakSelf = self;
    self.tagSetting = [[WWTagCustomSetting alloc] initWithModelArray:nil clickCallBack:^(UICollectionView *collectionView, NSIndexPath *indexPath) {
        if (indexPath.row >= 0) {
//            XER_SKUModel* model = [XER_LookPublish_Conditions sharedLookPublish_Conditions].colors[indexPath.row];
//            if (![model.id_color isEqualToString:weakSelf.model.goods.sku.id_color]) {
//                weakSelf.model.goods.sku = model.copy;
//                [weakSelf clearGoods];
//            }
        }
        [self resetTwiceCBWithCallBack:nil];
    }];
    self.tagSetting.frame = CGRectOffset(self.bounds, 0, 50);
    self.tagSetting.alpha = 0;
    [self addSubview:self.tagSetting];
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        weakSelf.tagSetting.frame = self.bounds;
        weakSelf.tagSetting.alpha = 1.0;
    } completion:nil];
}

- (void)fontBtnClick{
    __weak typeof(self) weakSelf = self;
    if (self.tagSetting) {
        [self resetTwiceCBWithCallBack:^(BOOL finished) {
            [weakSelf showFont];
        }];
    }else{
        [weakSelf showFont];
    }
    
}
- (void)showFont{
    
    __weak typeof(self) weakSelf = self;
    self.tagSetting = [[WWTagCustomSetting alloc] initWithModelArray:nil clickCallBack:^(UICollectionView *collectionView, NSIndexPath *indexPath) {
        if (indexPath.row >= 0) {
//            XER_SKUModel* model = [XER_LookPublish_Conditions sharedLookPublish_Conditions].colors[indexPath.row];
//            if (![model.id_color isEqualToString:weakSelf.model.goods.sku.id_color]) {
//                weakSelf.model.goods.sku = model.copy;
//                [weakSelf clearGoods];
//            }
        }
        [self resetTwiceCBWithCallBack:nil];
    }];
    self.tagSetting.frame = CGRectOffset(self.bounds, 0, 50);
    self.tagSetting.alpha = 0;
    [self addSubview:self.tagSetting];
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        weakSelf.tagSetting.frame = self.bounds;
        weakSelf.tagSetting.alpha = 1.0;
    } completion:nil];
}

- (void)shapeBtnClick {
    __weak typeof(self) weakSelf = self;
    if (self.tagSetting) {
        [self resetTwiceCBWithCallBack:^(BOOL finished) {
            [weakSelf changeShape];
        }];
    }else{
        [weakSelf changeShape];
    }
    
}
- (void)changeShape{
    NSLog(@"12345");
}
#pragma mark - 懒加载
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
        _commendLabel.textColor = viewBackGround_Color;
        _commendLabel.text = @"个性化设置";
    }
    return _commendLabel;
}

- (UIButton *)conformBtn{
    if (_conformBtn == nil) {
        _conformBtn = [[UIButton alloc] init];
        _conformBtn.backgroundColor = viewBackGround_Color;
        [_conformBtn setTitle:@"确定" forState:UIControlStateNormal];
        [_conformBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _conformBtn.titleLabel.font = [UIFont fontWithName:kFont_DINAlternate size:15*screenRate];
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
        self.backgroundColor = viewBackGround_Color;
        self.layer.cornerRadius = self.bounds.size.width/2;
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)setUpSubviews{
    [self.customTagOption sizeToFit];
    self.customTagOption.centerX = self.width/2;
    self.customTagOption.centerY = self.height/2;
    [self addSubview:self.customTagOption];
}

- (UILabel *)customTagOption {
    if (_customTagOption == nil) {
        _customTagOption = [[UILabel alloc]init];
        _customTagOption.textColor = [UIColor whiteColor];
        _customTagOption.textAlignment = NSTextAlignmentCenter;
        _customTagOption.font = [UIFont fontWithName:kFont_DINAlternate size:16*screenRate];
    }
    return _customTagOption;
}

@end


@implementation WWTagCustomSetting

- (instancetype)initWithModelArray:(NSArray*)modelArray clickCallBack:(void (^)(UICollectionView* collectionView,NSIndexPath* indexPath))callBack{
    if (self = [super init]) {
        self.modelArray = modelArray;
        self.clickCallBack = callBack;
        self.backgroundColor = [UIColor whiteColor];
        [self setUpSubviews];
    }
    return self;
}

- (void)conformBtnClick{
    self.clickCallBack(self.collection,[NSIndexPath indexPathForItem:-1 inSection:0]);
}

- (void)setUpSubviews{
    [self addSubview:self.commendLabel];
    [self addSubview:self.collection];
    [self addSubview:self.conformBtn];
    self.collection.translatesAutoresizingMaskIntoConstraints = NO;
    self.commendLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.conformBtn.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary* dict = @{@"col":self.collection,@"conform":self.conformBtn,@"commend":self.commendLabel};
    NSDictionary* metrics = @{@"commendT":@(30*screenRate),@"commendH":@(16*screenRate),@"colH":@(100*screenRate),@"conformH":@(40*screenRate)};
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[col]-0-|" options:0 metrics:nil views:dict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[conform]-0-|" options:0 metrics:nil views:dict]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.commendLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-commendT-[commend]-commendT-[col(==colH)]-(>=0)-[conform(==conformH)]-0-|" options:0 metrics:metrics views:dict]];
    
}

#pragma mark - layout delegate
- (CGSize)layout:(WWCollectionViewLayout*)layout sizeForCellAtIndexPath:(NSIndexPath*)indexPath{
    return CGSizeMake(72, 100);
}
- (CGFloat)layout:(WWCollectionViewLayout*)layout absoluteSideForSection:(NSUInteger)section{
    return 100*screenRate;
}

#pragma mark - collection delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.modelArray.count;
}
- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    WWTagCustomSettingCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    __weak typeof(self) weakSelf = self;
    if ([self.modelArray[0] isKindOfClass:[UILabel class]]) {
        cell.image = nil;
        cell.imgView.layer.borderColor = [UIColor clearColor].CGColor;
        cell.imgView.layer.borderWidth = 0;
        cell.imgView.layer.cornerRadius = 0;
        cell.imgView.clipsToBounds = YES;
        cell.backgroundColor = RandomColor;
    }
    if ([self.modelArray[0] isKindOfClass:[UILabel class]]) {
        cell.backgroundColor = [UIColor redColor];
    }
    if ([self.modelArray[0] isKindOfClass:[UIImage class]]) {
        cell.backgroundColor = [UIColor blueColor];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    self.clickCallBack(collectionView,indexPath);
}

#define kDragVelocityDampener .85
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset {
    /**
     * Here we target a specific cell index to move towards
     */
    if (targetContentOffset->x == 0) {
        return;
    }else if ((int)targetContentOffset->x == (int)(scrollView.contentSize.width - scrollView.frame.size.width)){
        return;
    }
    *targetContentOffset = CGPointMake((targetContentOffset->x - scrollView.contentOffset.x)*2.5 + scrollView.contentOffset.x, targetContentOffset->y);
}


- (UICollectionView *)collection{
    if (_collection == nil) {
        _collection = [[UICollectionView alloc] initWithFrame:[UIScreen mainScreen].bounds collectionViewLayout:self.layout];
        _collection.delegate = self;
        _collection.dataSource = self;
        [_collection registerClass:[WWTagCustomSettingCell class] forCellWithReuseIdentifier:@"cell"];
        UIView* backView = [[UIView alloc] init];
        backView.backgroundColor = [UIColor whiteColor];
        _collection.backgroundView = backView;
        _collection.backgroundColor = [UIColor whiteColor];
        _collection.showsVerticalScrollIndicator = NO;
        _collection.showsHorizontalScrollIndicator = NO;
        _collection.decelerationRate = UIScrollViewDecelerationRateFast;
    }
    return _collection;
}
- (WWCollectionViewLayout *)layout{
    if (_layout == nil) {
        _layout = [[WWCollectionViewLayout alloc] init];
        _layout.delegate = self;
        _layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _layout.sectionInset = UIEdgeInsetsMake(0, 20, 0, 20);
        _layout.InteritemSpacing = 30;
        _layout.LineSpacing = 0;
    }
    return _layout;
}
- (UIButton *)conformBtn{
    if (_conformBtn == nil) {
        _conformBtn = [[UIButton alloc] init];
        _conformBtn.backgroundColor = RGBCOLOR(0xe8e8e8);
        [_conformBtn setImage:[UIImage imageNamed:@"lookPublishLabelDetailCancelBtn"] forState:UIControlStateNormal];
        [_conformBtn addTarget:self action:@selector(conformBtnClick) forControlEvents:UIControlEventTouchUpInside];
        _conformBtn.imageView.contentMode = UIViewContentModeCenter;
    }
    return _conformBtn;
}

- (UILabel *)commendLabel{
    if (_commendLabel == nil) {
        _commendLabel = [[UILabel alloc] init];
        _commendLabel.font = [UIFont fontWithName:kFont_Regular size:14];
        _commendLabel.textColor = RGBCOLOR(0x292929);
        if (self.modelArray.count) {
            if ([self.modelArray[0] isKindOfClass:[UILabel class]]) {
                _commendLabel.text = @"选择分类";
            }
            if ([self.modelArray[0] isKindOfClass:[UILabel class]]) {
                _commendLabel.text = @"选择颜色";
            }
        }else{
            _commendLabel.text = @"选择贴纸";
        }
    }
    return _commendLabel;
}

@end

@implementation WWTagCustomSettingCell
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setUpSubviews];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


- (void)setUpSubviews{
    [self addSubview:self.imgView];
    [self addSubview:self.colorView];
    [self addSubview:self.textLabel];
    
    self.imgView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.width);
    self.colorView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.width);
    self.colorView.layer.cornerRadius = self.frame.size.width / 2;
    self.imgView.layer.cornerRadius = self.frame.size.width / 2;
    self.textLabel.frame = CGRectMake(0, self.frame.size.height - 14, self.frame.size.width, 14 * screenRate);
}

- (void)setTitle:(NSString *)title{
    _title = title.copy;
    self.textLabel.text = _title;
}

- (void)setImage:(UIImage *)image{
    _image = image;
    self.imgView.image = image;
    self.colorView.hidden = YES;
    self.imgView.hidden = NO;
}

- (void)setColor:(NSString *)color{
    _color = color;
//    self.colorView.backgroundColor = [UIColor colorWithHexValue:_color];
    self.colorView.hidden = NO;
    self.imgView.hidden = YES;
}

- (UILabel *)textLabel{
    if (_textLabel == nil) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.font = [UIFont fontWithName:kFont_Regular size:12 * screenRate];
        _textLabel.textColor = RGBCOLOR(0x292929);
        _textLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _textLabel;
}

- (UIView *)colorView{
    if (_colorView == nil) {
        _colorView = [[UIView alloc] init];
        _colorView.layer.cornerRadius = 15;
        _colorView.clipsToBounds = YES;
    }
    return _colorView;
}

- (UIImageView *)imgView{
    if (_imgView == nil) {
        _imgView = [[UIImageView alloc] init];
        _imgView.contentMode = UIViewContentModeScaleAspectFill;
        _imgView.clipsToBounds = YES;
    }
    return _imgView;
}
@end

