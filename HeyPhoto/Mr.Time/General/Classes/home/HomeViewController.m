//
//  HomeViewController.m
//  Mr.Time
//
//  Created by 王伟伟 on 2017/4/12.
//  Copyright © 2017年 Offape. All rights reserved.
//

#import "HomeViewController.h"
#import "TZImagePickerController.h"
#import <YYText/YYText.h>
#import "WWLabel.h"
#import "GCD.h"
#import "POP.h"
#import "SDCycleScrollView.h"
#import "WWTagImageEditer.h"
#import "WWImageTagPHPPicker.h"
#import "WWBaseTableView.h"
#import "WWCollectButton.h"
#import "WWRefreshHeaderView.h"
#import "WWTagImageModel.h"
#import "WWTagImageDetailVC.h"

@interface userPublishCell : UITableViewCell
@property (nonatomic, strong) UIImageView *coverImage;
@property (nonatomic, strong) UIView *sepView;
@property (nonatomic, strong) WWTagedImgListModel* model;
@end

@interface HomeYearsCell :UICollectionViewCell
@property (nonatomic,strong) UILabel *yearsNum;
@property (nonatomic,strong) UILabel *yearLbael;
@end

@interface HomeViewController ()<SDCycleScrollViewDelegate,TZImagePickerControllerDelegate,UITableViewDelegate,UITableViewDataSource>{
    SDCycleScrollView* _bannerView;
}
@property (nonatomic, strong) UIButton *puslishBtn;
@property (nonatomic, strong) NSMutableArray *originImageArray;
@property (nonatomic, strong) NSMutableArray *cutImageArray;
@property (nonatomic, strong) UIImageView *animationImageView;
@property (nonatomic, strong) WWBaseTableView *tableView;
@property (nonatomic, strong) NSMutableArray <WWTagImageModel*> *modelArray;
@end

#define totalColumns 10

@implementation HomeViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = viewBackGround_Color;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addTagModel:) name:@"addModel" object:nil];
    self.modelArray = [NSMutableArray array];
    NSArray *imagesURLStrings = @[@"",@""];
    _bannerView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(105*screenRate, 40, 175*screenRate, 140*screenRate) delegate:self placeholderImage:nil];
    _bannerView.currentPageDotImage = [UIImage imageNamed:@"pageControlCurrentDot"];
    _bannerView.pageDotImage = [UIImage imageNamed:@"pageControlDot"];
    _bannerView.imageURLStringsGroup = imagesURLStrings;
    _bannerView.autoScroll = NO;
    [self.view addSubview:_bannerView];
    [self setupSubViews];
}

- (void)addTagModel:(NSNotification *)model {
    WEAK_SELF;
    [self.tableView.mj_header beginRefreshing];
    NSDictionary *dict = model.userInfo;
    WWTagImageModel *model1 = (WWTagImageModel *)dict[@"model"];
    [self.modelArray addObject:model1];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf.tableView.mj_header endRefreshing];
        [weakSelf.tableView reloadData];
    });
}

#pragma mark - tableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.modelArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    userPublishCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userPublishCell"];
    if (!cell) {
        cell = [[userPublishCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"userPublishCell"];
    }
    cell.model = self.modelArray[indexPath.row].tagImagesList[0];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    WWTagImageDetailVC *vc = [[WWTagImageDetailVC alloc]initWithMolde:self.modelArray[indexPath.row]];
    [self.navigationController pushViewController:vc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 300*screenRate;
}

- (void)setupSubViews {
    [self.view addSubview:self.animationImageView];
    [self.animationImageView sizeToFit];
    self.animationImageView.left = 40*screenRate;
    self.animationImageView.top = 74;
    [GCDQueue executeInMainQueue:^{
        [self scaleAnimation];
    } afterDelaySecs:1.f];
    [self.view addSubview:self.puslishBtn];
    self.puslishBtn.right_sd = KWidth - 80*screenRate;
    self.puslishBtn.centerY_sd = self.animationImageView.centerY_sd-18*screenRate;
    self.puslishBtn.width_sd = 50*screenRate;
    self.puslishBtn.height_sd = 50*screenRate;
    [self.view addSubview:self.tableView];
    [self.tableView.mj_header beginRefreshing];
}

//心跳动画
- (void)scaleAnimation {
    POPBasicAnimation *scaleAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    scaleAnimation.name               = @"scaleSmallAnimation";
    scaleAnimation.delegate           = self;
    scaleAnimation.duration           = 0.25f;
    scaleAnimation.toValue            = [NSValue valueWithCGPoint:CGPointMake(1.15, 1.15)];
    [self.animationImageView pop_addAnimation:scaleAnimation forKey:nil];
}

- (void)pop_animationDidStop:(POPAnimation *)anim finished:(BOOL)finished {
    if ([anim.name isEqualToString:@"scaleSmallAnimation"]) {
        POPSpringAnimation *scaleAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
        scaleAnimation.name                = @"SpringAnimation";
        scaleAnimation.delegate            = self;
        scaleAnimation.toValue             = [NSValue valueWithCGPoint:CGPointMake(1, 1)];
        scaleAnimation.velocity            = [NSValue valueWithCGPoint:CGPointMake(-2, -2)];
        scaleAnimation.springBounciness    = 20.f;
        scaleAnimation.springSpeed         = 15.f;
        scaleAnimation.dynamicsTension     = 600.f;
        scaleAnimation.dynamicsFriction    = 22.f;
        scaleAnimation.dynamicsMass        = 2.f;
        [self.animationImageView pop_addAnimation:scaleAnimation forKey:nil];
    } else if ([anim.name isEqualToString:@"SpringAnimation"]) {
        [self performSelector:@selector(scaleAnimation) withObject:nil afterDelay:1];
    }
}

#pragma mark - delegate
- (Class)customCollectionViewCellClassForCycleScrollView:(SDCycleScrollView *)view {
    if (view != _bannerView) {
        return nil;
    }
    return [HomeYearsCell class];
}
- (void)setupCustomCell:(UICollectionViewCell *)cell forIndex:(NSInteger)index cycleScrollView:(SDCycleScrollView *)view {
    HomeYearsCell *myCell = (HomeYearsCell *)cell;
    WWUserModel *model =  [WWUserModel shareUserModel];
    model = (WWUserModel*)[NSKeyedUnarchiver unarchiveObjectWithFile:ArchiverPath];
    if (index == 0) {
        myCell.yearsNum.text = model.yearDay;
        myCell.yearLbael.text = @"YEARS OLD";
    }else if (index == 1){
        myCell.yearsNum.text = model.dataStr;
        myCell.yearLbael.text = @"DAY";
    }
}

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto {
    for (int i = 0; i<photos.count; i++) {
        UIImage *image = photos[i];
        [self.originImageArray addObject:image];
        UIImage *newImage = [image cutImageWithSize];
        [self.cutImageArray addObject:newImage];
    }
    WWTagImageEditer *imageEditerVC = [[WWTagImageEditer alloc]initWithTailoringImageArray:self.cutImageArray andWithOriginImageArray:self.originImageArray andModelArray:nil andSelectPhotoKey:nil andDidSelectPhotoKey:nil andPhotoDict:nil];
    [self.navigationController pushViewController:imageEditerVC animated:NO];
}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    CGFloat viewHeight = scrollView.height + scrollView.contentInset.top;
//    for (userPublishCell *cell in [self.tableView visibleCells]) {
//        CGFloat y = cell.centerY - scrollView.contentOffset.y;
//        CGFloat p = y - viewHeight / 2;
//        CGFloat scale = cos(p / viewHeight * 0.8) * 0.95;
//        [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState animations:^{
//            cell.transform = CGAffineTransformMakeScale(scale, scale);
//        } completion:NULL];
//    }
//}

#pragma mark - 点击事件
- (void)publishBtnClick {
//    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:9 columnNumber:3 delegate:self];
//    imagePickerVc.allowPickingOriginalPhoto = YES;
//    imagePickerVc.isSelectOriginalPhoto = YES;
//    imagePickerVc.allowPickingVideo = NO;
//    imagePickerVc.sortAscendingByModificationDate = NO;
//    imagePickerVc.photoWidth = KWidth;
//    imagePickerVc.autoDismiss = YES;
//    [self presentViewController:imagePickerVc animated:YES completion:nil];
    WWImageTagPHPPicker *imageVC = [[WWImageTagPHPPicker alloc]init];
    [self.navigationController pushViewController:imageVC animated:YES];
}

#pragma mark - lazyLoad
- (WWBaseTableView *)tableView {
    if (!_tableView) {
        _tableView = [[WWBaseTableView alloc] initWithFrame:CGRectMake(20*screenRate, _bannerView.bottom+29*screenRate, KWidth-40*screenRate, KHeight-(_bannerView.bottom+29*screenRate)-49)];
        _tableView.delegate = self;
        _tableView.dataSource  = self;
        _tableView.backgroundColor = viewBackGround_Color;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        WEAK_SELF;
        _tableView.mj_header = [WWRefreshHeaderView headerWithRefreshingBlock:^{
            [weakSelf loadNewData];
        }];
    }
    return _tableView;
}

- (UIImageView *)animationImageView {
    if (_animationImageView == nil) {
        _animationImageView = [[UIImageView alloc]init];
        _animationImageView.image = [UIImage imageNamed:@"boolRedLike"];
    }
    return _animationImageView;
}

- (UIButton *)puslishBtn {
    if (_puslishBtn == nil) {
        _puslishBtn = [[UIButton alloc]init];
        [_puslishBtn setImage:[UIImage imageNamed:@"homePublish"] forState:UIControlStateNormal];
        [_puslishBtn addTarget:self action:@selector(publishBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _puslishBtn;
}

- (NSMutableArray *)originImageArray {
    if (!_originImageArray) {
        _originImageArray = [NSMutableArray arrayWithCapacity:10];
    }
    return _originImageArray;
}

- (NSMutableArray *)cutImageArray {
    if (_cutImageArray == nil) {
        _cutImageArray = [NSMutableArray arrayWithCapacity:10];
    }
    return _cutImageArray;
}

- (void)loadNewData {
    WEAK_SELF;
    NSMutableArray *mArray = [NSMutableArray arrayWithCapacity:10];
    NSMutableArray *mLabelArray = [NSMutableArray arrayWithCapacity:10];
    for (int i = 0; i < 4; i++) {
        if (i == 0) {
            WWTagedImgListModel *model = [[WWTagedImgListModel alloc] initWithDict:nil];
            UIImage *image = [UIImage imageNamed:@"womencat"];
            model.image = image;
            for (int j = 0; j<2; j++) {
                if (j == 0) {
                    WWTagedImgLabel *labelModel = [[WWTagedImgLabel alloc]initWithDict:nil];
                    labelModel.direction = @(0);
                    labelModel.siteX = @(0.5226666);
                    labelModel.siteY = @(0.6671111);
                    labelModel.tagLink = @"EMPTY";
                    labelModel.tagColor = @"77EEDF";
                    labelModel.tagfont = @"Copperplate";
                    labelModel.tagText = @"好好吃😆";
                    [mLabelArray addObject:labelModel];
                }
                if (j == 1) {
                    WWTagedImgLabel *labelModel = [[WWTagedImgLabel alloc]initWithDict:nil];
                    labelModel.direction = @(1);
                    labelModel.siteX = @(0.4066667);
                    labelModel.siteY = @(0.6457778);
                    labelModel.tagLink = @"EMPTY";
                    labelModel.tagColor = @"FC577A";
                    labelModel.tagfont = @"PingFangSC-Semibold";
                    labelModel.tagText = @"大长腿😆";
                    [mLabelArray addObject:labelModel];
                }
            }
            model.tags = mLabelArray.copy;
            [mArray addObject:model];
        }
        if (i == 1) {
            [mLabelArray removeAllObjects];
            WWTagedImgListModel *model = [[WWTagedImgListModel alloc] initWithDict:nil];
            UIImage *image = [UIImage imageNamed:@"gouzi"];
            model.image = image;
            for (int k = 0; k < 3; k++) {
                if (k == 0) {
                    WWTagedImgLabel *labelModel = [[WWTagedImgLabel alloc]initWithDict:nil];
                    labelModel.direction = @(0);
                    labelModel.siteX = @(0.5053333);
                    labelModel.siteY = @(0.09333333);
                    labelModel.tagLink = @"EMPTY";
                    labelModel.tagColor = @"F8E71C";
                    labelModel.tagfont = @"PingFangSC-Semibold";
                    labelModel.tagText = @"这个逗比😆";
                    [mLabelArray addObject:labelModel];
                }
                if (k == 1) {
                    WWTagedImgLabel *labelModel = [[WWTagedImgLabel alloc]initWithDict:nil];
                    labelModel.direction = @(0);
                    labelModel.siteX = @(0.488);
                    labelModel.siteY = @(0.3253333);
                    labelModel.tagLink = @"EMPTY";
                    labelModel.tagColor = @"292929";
                    labelModel.tagfont = @"PingFangSC-Semibold";
                    labelModel.tagText = @"逗比不要看我😤";
                    [mLabelArray addObject:labelModel];
                }
                if (k == 2) {
                    WWTagedImgLabel *labelModel = [[WWTagedImgLabel alloc]initWithDict:nil];
                    labelModel.direction = @(0);
                    labelModel.siteX = @(0.2991111);
                    labelModel.siteY = @(0.2306667);
                    labelModel.tagLink = @"EMPTY";
                    labelModel.tagColor = @"77EEDF";
                    labelModel.tagfont = @"Copperplate";
                    labelModel.tagText = @"瞅你咋滴？";
                    [mLabelArray addObject:labelModel];
                }
            }
            model.tags = mLabelArray.copy;
            [mArray addObject:model];
        }
        if (i == 2) {
            [mLabelArray removeAllObjects];
            WWTagedImgListModel *model = [[WWTagedImgListModel alloc] initWithDict:nil];
            UIImage *image = [UIImage imageNamed:@"sleepcat"];
            model.image = image;
            for (int q = 0; q<2; q++) {
                if (q == 0) {
                    WWTagedImgLabel *labelModel = [[WWTagedImgLabel alloc]initWithDict:nil];
                    labelModel.direction = @(1);
                    labelModel.siteX = @(0.2853333);
                    labelModel.siteY = @(0.3524444);
                    labelModel.tagLink = @"EMPTY";
                    labelModel.tagColor = @"ffffff";
                    labelModel.tagfont = @"PingFangSC-Regular";
                    labelModel.tagText = @"我们去睡吧😝";
                    labelModel.direction = @(1);
                    [mLabelArray addObject:labelModel];
                }
                if (q == 1) {
                    WWTagedImgLabel *labelModel = [[WWTagedImgLabel alloc]initWithDict:nil];
                    labelModel.siteX = @(0.5226666);
                    labelModel.siteY = @(0.164);
                    labelModel.tagLink = @"EMPTY";
                    labelModel.tagColor = @"FC577A";
                    labelModel.tagfont = @"PingFangSC-Semibold";
                    labelModel.tagText = @"好困啊💤";
                    [mLabelArray addObject:labelModel];
                }
            }
            model.tags = mLabelArray.copy;
            [mArray addObject:model];
        }
        if (i == 3) {
            WWTagedImgListModel *model = [[WWTagedImgListModel alloc] initWithDict:nil];
            UIImage *image = [UIImage imageNamed:@"minebuou"];
            model.image = image;
            [mArray addObject:model];
        }
        if (i == 4) {
            WWTagedImgListModel *model = [[WWTagedImgListModel alloc] initWithDict:nil];
            UIImage *image = [UIImage imageNamed:@"chongqing"];
            model.image = image;
            [mArray addObject:model];
        }
        if (i == 5) {
            WWTagedImgListModel *model = [[WWTagedImgListModel alloc] initWithDict:nil];
            UIImage *image = [UIImage imageNamed:@"shijianxiansheng"];
            model.image = image;
            [mArray addObject:model];
        }
    }
    
    WWTagImageModel *model = [[WWTagImageModel alloc]initWithDict:nil];
    model.username = @"林森";
    model.isPraise = @"NO";
    model.praise = @(14354);
    model.content = @"      周某是上海市几十万猫奴之一。猫和普通的毒品不同，没有《动物保护法》去保护一只猫的权利，当然也就不负任何法律责任。中了猫毒的人，也不用被关进戒猫所，所以周某只能在家里自生自灭。\n      微瘦、长发、一脸面瘫，稚嫩地举止和衣着实在不像是一个28岁的职业女性，大学曾获两次二等奖学金的她，现在是一名动画片编剧，有良好的表达能力，但是在一次戒猫同好会上，她第一次讲诉了自己吸猫的经历时，几次泣不成声。\n      童年的周某父母离异，虽然得到了母亲的很多爱，童年对她来说是很孤独的。为了可以独立生活，她努力学习，获得了学校的奖学金，加油学习动画专业技能，哪里知道毕业是一条绝路。在学校根本没学到该有的技能，这让面临毕业的她面临待遇差、独孤、陌生环境等问题。\n      “那时的我坚决不要家里的钱，就是想独立起来。没想到毕业以后社会带来的生存问题这么困难。拒绝任何社交、聚会。我甚至觉得自己是个垃圾，恨不得去死。”\n      直到那天，一个平时看似好心的同事，把周某带进了那个地方——猫咪咖啡馆。 ";
    model.title = @"      吸猫日记";
    model.tagImagesList = mArray.copy;
    [self.modelArray addObject:model];
    [self.modelArray addObject:model];
    [self.modelArray addObject:model];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf.tableView.mj_header endRefreshing];
        [weakSelf.tableView reloadData];
    });
}

@end


@implementation HomeYearsCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.yearsNum];
        [self.yearsNum sizeToFit];
        self.yearsNum.left = 0;
        self.yearsNum.top = 5;
        [self addSubview:self.yearLbael];
        [self.yearLbael sizeToFit];
        self.yearLbael.centerX = self.yearsNum.centerX;
        self.yearLbael.top = self.yearsNum.bottom;
    }
    return self;
}

- (UILabel *)yearLbael {
    if (_yearLbael == nil) {
        _yearLbael = [[UILabel alloc]init];
        _yearLbael.text = @"YEARS OLD";
        _yearLbael.textAlignment = NSTextAlignmentCenter;
        _yearLbael.font = [UIFont fontWithName:kFont_DINAlternate size:21*screenRate];
        _yearLbael.textColor = RGBCOLOR(0x545454);
    }
    return _yearLbael;
}

- (UILabel *)yearsNum {
    if (_yearsNum == nil) {
        _yearsNum = [[UILabel alloc]init];
        _yearsNum.textAlignment = NSTextAlignmentCenter;
        _yearsNum.text = @"9,9999";
        _yearsNum.font = [UIFont fontWithName:kFont_DINAlternate size:66*screenRate];
        _yearsNum.textColor = [UIColor whiteColor];
        _yearsNum.layer.shadowColor = [UIColor blackColor].CGColor;
        _yearsNum.layer.shadowOpacity = 0.5;
        _yearsNum.layer.shadowRadius = 10;
        _yearsNum.layer.shadowOffset = CGSizeMake(0, 8*screenRate);
    }
    return _yearsNum;
}

@end


@implementation userPublishCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.coverImage];
        [self.coverImage sizeToFit];
        self.coverImage.left = 0;
        self.coverImage.top = 0;
        self.coverImage.width_sd = self.width_sd;
        self.coverImage.height_sd = 280*screenRate;
        [self addSubview:self.sepView];
        self.sepView.frame = CGRectMake(0, self.coverImage.bottom, self.width_sd, 20*screenRate);
    }
    return self;
}


- (void)setModel:(WWTagedImgListModel* )model {
    _model = model;
    self.coverImage.image = model.image;
}

- (UIImageView *)coverImage {
    if (!_coverImage) {
        _coverImage = [[UIImageView alloc]init];
        _coverImage.contentMode = UIViewContentModeScaleAspectFill;
        _coverImage.layer.cornerRadius = 20*screenRate;
        _coverImage.clipsToBounds = YES;
    }
    return _coverImage;
}

- (UIView *)sepView {
    if (!_sepView) {
        _sepView = [[UIView alloc]init];
        _sepView.backgroundColor = viewBackGround_Color;
    }
    return _sepView;
}
@end
