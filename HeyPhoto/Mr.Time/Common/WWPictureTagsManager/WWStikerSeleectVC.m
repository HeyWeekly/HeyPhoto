//
//  WWStikerSeleectVC.m
//  Mr.Time
//
//  Created by 王伟伟 on 2017/9/18.
//  Copyright © 2017年 Offape. All rights reserved.
//

#import "WWStikerSeleectVC.h"
#import "WWCollectionViewLayout.h"
#import "WWAlbumTitle.h"


@interface WWStikerSeleectCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *goodsImage;
@property (nonatomic, strong) UILabel *goodsDesc;
@property (nonatomic, strong) UILabel *goodsPrice;
@property (nonatomic, copy) NSString* title;
@end

@interface WWStikerSeleectVC () <UICollectionViewDelegate,UICollectionViewDataSource,WWCollectionViewLayoutDelegate>
@property (nonatomic, strong) NSNumber* page;
@property (nonatomic, strong) NSArray* sectionOneArray;
@property (nonatomic, strong) NSArray* sectionTwoArray;
@property (nonatomic, strong) UICollectionView* collection;
@property (nonatomic, strong) WWCollectionViewLayout* layout;
@property (nonatomic, copy) NSString* tracer;
@property (nonatomic, strong) NSString* selectGoods_id;
@property (nonatomic,strong) UILabel *emptyLabel;
@property (nonatomic, strong) id model;
@property (nonatomic, strong) WWAlbumTitle *closeBtn;
@end

@implementation WWStikerSeleectVC

- (instancetype)initWithGoods:(id)model withSelectGoods_ID:(NSString*)goods_id searchCondition:(WWTagedImgLabel *)label{
    if (self = [super init]) {
        self.model = model;
        self.selectGoods_id = goods_id;
    }
    return self;
}
- (void)viewDidLoad{
    self.view.backgroundColor = [UIColor whiteColor];
    [self setUpSubviews];
}
- (void)setModel:(id )model {
    _model = model;
}

#pragma mark - collection delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 20;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WWStikerSeleectCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"XER_ImgTagCabinetCell" forIndexPath:indexPath];
//    cell.goodsDesc.text = self.model.data[indexPath.row].itemName;
//    cell.goodsPrice.text = [NSString stringWithFormat:@"%@%@",self.model.data[indexPath.row].exchangeunit.exchangeSign,[self.model.data[indexPath.row].itemPrice toCurrency]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self.collection reloadData];
    if ([self.delegate respondsToSelector:@selector(cabinet:selectedGoodsWithModel:)]) {
        [self.delegate cabinet:self selectedGoodsWithModel:nil];
    }
}

- (CGSize)layout:(WWCollectionViewLayout *)layout sizeForCellAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(175*screenRate, 260*screenRate);
}
- (CGFloat)layout:(WWCollectionViewLayout *)layout absoluteSideForSection:(NSUInteger)section {
    return 260*screenRate;
}
//#pragma mark - 视图
- (void)setUpSubviews{
    [self.view addSubview:self.collection];
    [self.view addSubview:self.closeBtn];
    self.collection.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary* dict = @{@"col":self.collection};
    NSDictionary* metrics = @{@"h":@([UIScreen mainScreen].bounds.size.width),@"conformH":@(44)};
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-conformH-[col]-0-|" options:0 metrics:metrics views:dict]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[col]-0-|" options:0 metrics:nil views:dict]];
}

- (void)cancelSelectSticker {
    if ([self.delegate respondsToSelector:@selector(cabinet:selectedGoodsWithModel:)]) {
        [self.delegate cabinet:self selectedGoodsWithModel:nil];
    }
}

#pragma mark - 懒加载
- (UICollectionView *)collection {
    if (_collection == nil) {
        _collection = [[UICollectionView alloc]initWithFrame:[UIScreen mainScreen].bounds collectionViewLayout:self.layout];
        _collection.delegate = self;
        _collection.dataSource = self;
        _collection.backgroundColor = viewBackGround_Color;
        UIView* backView = [[UIView alloc] init];
        backView.backgroundColor = viewBackGround_Color;
        _collection.backgroundView = backView;
        [_collection registerClass:[WWStikerSeleectCell class] forCellWithReuseIdentifier:@"XER_ImgTagCabinetCell"];
    }
    return _collection;
}

- (WWCollectionViewLayout *)layout {
    if (_layout == nil) {
        _layout = [[WWCollectionViewLayout alloc]init];
        _layout.LineSpacing = 7*screenRate;
        _layout.InteritemSpacing = 7*screenRate;
        _layout.sectionInset = UIEdgeInsetsMake(0,8*screenRate, 0,0);
        _layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _layout.delegate = self;
        _layout.lineBreak = YES;
    }
    return _layout;
}

- (WWAlbumTitle *)closeBtn {
    if (_closeBtn == nil) {
        _closeBtn = [WWAlbumTitle buttonWithType:UIButtonTypeCustom];
        _closeBtn.frame = CGRectMake(0, 0, KWidth, 44);
        _closeBtn.backgroundColor = viewBackGround_Color;
        [_closeBtn setImage:[UIImage imageNamed:@"albumxiala"] forState:UIControlStateNormal];
        [_closeBtn setTitle:@"贴纸" forState:UIControlStateNormal];
        [_closeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _closeBtn.titleLabel.font = [UIFont fontWithName:kFont_DINAlternate size:19*screenRate];
        _closeBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_closeBtn addTarget:self action:@selector(cancelSelectSticker) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}
@end


@implementation WWStikerSeleectCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        [self setUpSubviews];
    }
    return self;
}

- (void)setUpSubviews{
    [self addSubview:self.goodsImage];
    [self addSubview:self.goodsDesc];
    [self addSubview:self.goodsPrice];
    self.goodsImage.translatesAutoresizingMaskIntoConstraints = NO;
    self.goodsDesc.translatesAutoresizingMaskIntoConstraints = NO;
    self.goodsPrice.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary* dict = @{@"goodsimage":self.goodsImage,@"goodsDesc":self.goodsDesc,@"goodsPrice":self.goodsPrice};
    NSDictionary *metrics = @{@"Hgoods":@(15*screenRate),@"goodsS":@(175*screenRate),@"goodsde":@(10*screenRate)};
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[goodsimage]-0-|" options:0 metrics:nil views:dict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-Hgoods-[goodsDesc]-Hgoods-|" options:0 metrics:metrics views:dict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-Hgoods-[goodsPrice]-Hgoods-|" options:0 metrics:metrics views:dict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[goodsimage(==goodsS)]-goodsde-[goodsDesc]" options:0 metrics:metrics views:dict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[goodsPrice]-goodsde-|" options:0 metrics:metrics views:dict]];
}

- (UIImageView *)goodsImage {
    if (_goodsImage == nil) {
        _goodsImage = [[UIImageView alloc]init];
        _goodsImage.userInteractionEnabled = YES;
        _goodsImage.contentMode = UIViewContentModeScaleAspectFill;
        _goodsImage.clipsToBounds = YES;
    }
    return _goodsImage;
}
- (UILabel *)goodsDesc {
    if (_goodsDesc == nil) {
        _goodsDesc = [[UILabel alloc]init];
        _goodsDesc.font = [UIFont fontWithName:kFont_Regular size:12*screenRate];
        _goodsDesc.numberOfLines = 2;
        _goodsDesc.textAlignment = NSTextAlignmentLeft;
        _goodsDesc.textColor = viewBackGround_Color;
    }
    return _goodsDesc;
}
- (UILabel *)goodsPrice {
    if (_goodsPrice == nil) {
        _goodsPrice = [[UILabel alloc]init];
        _goodsPrice.font = [UIFont fontWithName:kFont_Regular size:16*screenRate];
        _goodsPrice.numberOfLines = 1;
        _goodsPrice.textAlignment = NSTextAlignmentLeft;
        _goodsPrice.textColor = viewBackGround_Color;
    }
    return _goodsPrice;
}
@end
