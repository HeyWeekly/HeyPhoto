//
//  CollectViewController.m
//  Mr.Time
//
//  Created by 王伟伟 on 2017/4/12.
//  Copyright © 2017年 Offape. All rights reserved.
//

#import "CollectViewController.h"
#import <YYText/YYText.h>
#import "Mr_Time-Swift.h"
#import "WWLabel.h"
#import "WWTagImageModel.h"
#import "WWTagImageDetailVC.h"

@interface  CollectCardView : UIView
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong,readwrite) YYLabel *toLabel;
@property (nonatomic, strong,readwrite) WWLabel *yearNumLabel;
@property (nonatomic, strong,readwrite) YYLabel *yearsLabel;
@property (nonatomic, strong,readwrite) YYLabel *countLabel;
@end

@interface CollectViewController ()<UICollectionViewDataSource>
@property (nonatomic, strong) WWNavigationVC *nav;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *listArray;
@property (nonatomic, strong) CardView *cardView;
@property (nonatomic, strong) NSMutableArray <WWTagImageModel*> *modelArray;
@end

@implementation CollectViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = viewBackGround_Color;
    [self loadData];
    [self setupViews];
}
- (void)setupViews {
    [self.view addSubview:self.nav];
    [self.view addSubview:self.cardView];
    NSMutableArray *arr = [self generateCardInfoWithCardCount:10];
    [self.cardView setWithCards:arr];
    [self.cardView showStyleWithStyle:1];
}

#pragma mark - tableView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.cardView.filterArr.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CardCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:self.cardView.filterArr[indexPath.row] forIndexPath:indexPath];
    UIView *view = [cell viewWithTag:2000];
    [view removeFromSuperview];
    cell.collectionV = collectionView;
    cell.reloadBlock = ^{
        if ([collectionView.collectionViewLayout isKindOfClass:[CustomCardLayout class]]) {
            CustomCardLayout *layout = (CustomCardLayout *)collectionView.collectionViewLayout;
            layout.selectIdx = indexPath.row;
        }
    };
    cell.backgroundColor = [UIColor redColor];
    UIButton *collView = [[UIButton alloc]init];
    collView.frame = cell.bounds;
    [collView setImage:self.modelArray[indexPath.row].tagImagesList[indexPath.row].image forState:UIControlStateNormal];
    collView.imageView.contentMode = UIViewContentModeScaleAspectFill;
    collView.tag = 2000;
    [cell addSubview:collView];
    return cell;
}
#pragma mark - 懒加载
- (NSMutableArray *)generateCardInfoWithCardCount:(int)cardCount {
    NSMutableArray *arr = [NSMutableArray array];
    NSArray *arrName = @[@"CardA"];
    for (int i=0; i<cardCount; i++) {
        int value = arc4random_uniform(1);
        [arr addObject:arrName[value]];
    }
    return arr;
}

- (CardView *)cardView {
    if (!_cardView) {
        _cardView = [[CardView alloc] initWithFrame:CGRectMake(0, 64, KWidth, KHeight-64-49)];
        _cardView.collectionView.dataSource = self;
        [_cardView registerCardCellWithC:[CardCell class] identifier:@"CardA"];
    }
    return _cardView;
}

- (WWNavigationVC *)nav {
    if (_nav == nil) {
        _nav = [[WWNavigationVC alloc]initWithFrame:CGRectMake(0, 20, KWidth, 44)];
        _nav.backBtn.hidden = YES;
        _nav.navTitle.text = @"收藏";
    }
    return _nav;
}

- (void)loadData {
    NSMutableArray *mArray = [NSMutableArray arrayWithCapacity:10];
    NSMutableArray *mLabelArray = [NSMutableArray arrayWithCapacity:10];
    for (int i = 0; i < 6; i++) {
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
            UIImage *image = [UIImage imageNamed:@"minebuou"];
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
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end




@implementation CollectCardView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self setupViews];
    }
    return self;
}
- (void)setupViews{
    [self addSubview:self.toLabel];
    [self.toLabel sizeToFit];
    self.toLabel.left = 20*screenRate;
    self.toLabel.top = 15*screenRate;
    
    [self addSubview:self.yearNumLabel];
    [self.yearNumLabel sizeToFit];
    self.yearNumLabel.left = self.toLabel.right+3;
    self.yearNumLabel.top = 15*screenRate;

    [self addSubview:self.yearsLabel];
    [self.yearsLabel sizeToFit];
    self.yearsLabel.left = self.yearNumLabel.right+3;
    self.yearsLabel.top = 15*screenRate;
    
    [self addSubview:self.countLabel];
    [self.countLabel sizeToFit];
    self.countLabel.right = KWidth - 20*screenRate;
    self.countLabel.top = 15*screenRate;
    
}
- (YYLabel *)toLabel {
    if (_toLabel == nil) {
        _toLabel = [[YYLabel alloc]init];
        _toLabel.text = @"TO";
        _toLabel.textColor = RGBCOLOR(0x50616E);
        _toLabel.font = [UIFont fontWithName:kFont_DINAlternate size:24*screenRate];
    }
    return _toLabel;
}
- (WWLabel *)yearNumLabel {
    if (_yearNumLabel == nil) {
        _yearNumLabel = [[WWLabel alloc]init];
        _yearNumLabel.font = [UIFont fontWithName:kFont_DINAlternate size:24*screenRate];
        _yearNumLabel.text = @"25";
        NSArray *gradientColors = @[(id)RGBCOLOR(0x15C2FF).CGColor, (id)RGBCOLOR(0x2EFFB6).CGColor];
        _yearNumLabel.colors =gradientColors;
    }
    return _yearNumLabel;
}
- (YYLabel *)yearsLabel {
    if (_yearsLabel == nil) {
        _yearsLabel = [[YYLabel alloc]init];
        _yearsLabel.textColor = RGBCOLOR(0x50616E);
        _yearsLabel.font = [UIFont fontWithName:kFont_DINAlternate size:24*screenRate];
        _yearsLabel.text = @"YEARS OLD";
    }
    return _yearsLabel;
}
- (YYLabel *)countLabel {
    if (_countLabel == nil) {
        _countLabel = [[YYLabel alloc]init];
        _countLabel.text = @"5";
        _countLabel.textColor = RGBCOLOR(0x15C2FF);
        _countLabel.font = [UIFont fontWithName:kFont_DINAlternate size:24*screenRate];
    }
    return _countLabel;
}
@end
