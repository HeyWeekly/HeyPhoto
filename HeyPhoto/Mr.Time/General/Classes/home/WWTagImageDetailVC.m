//
//  WWTagImageDetailVC.m
//  Mr.Time
//
//  Created by 王伟伟 on 2017/10/13.
//  Copyright © 2017年 Offape. All rights reserved.
//

#import "WWTagImageDetailVC.h"
#import "WWShowTagImgDisplayer.h"
#import "WWTagImageModel.h"
#import "WWCollectButton.h"

@interface WWTagImageDetailVC ()
<UITableViewDataSource,UIScrollViewDelegate,WWShowTagImgDisplayerDelegate>
@property (nonatomic, strong) WWTagImageModel *tagModel;
@property (nonatomic, strong) UILabel *numLabel;    // 点赞数量
@property (nonatomic, strong) UIButton *praiseBtn;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UILabel *imageNumLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) NSMutableArray *imageHeightArr;
@property (nonatomic, assign) double lastOfset;
@property (nonatomic, assign) double lastHight;
@property (nonatomic, strong) WWShowTagImgDisplayer *tagedImgDisplayer;
@property (nonatomic, strong) NSArray  *imageArray;
@property (nonatomic, strong) WWNavigationVC *nav;
@property (nonatomic, strong) WWCollectButton *likeImage;
@property (nonatomic, assign) BOOL islike;
@end

@implementation WWTagImageDetailVC

- (instancetype)initWithMolde:(WWTagImageModel *)model {
    if (self = [super init]) {
        self.tagModel = model;
        [self getHeightOver];
    }
    return self;
}

- (void)getHeightOver {
    for (int i = 0; i < self.tagModel.tagImagesList.count; i++) {
        CGSize size = self.tagModel.tagImagesList[i].image.size;
        CGFloat imageW = size.width;
        CGFloat imageH = size.height;
        if (!imageH || !imageW) {
            imageW = KWidth;
            imageH = KWidth;
        }
        long h = imageH*KWidth/imageW;
        
        if (h>KWidth*1.5) {
            h = KWidth*1.5;
        }else if (h<KWidth/1.5) {
            h = KWidth/1.5;
        }
        [self.imageHeightArr addObject:[NSString stringWithFormat:@"%ld",h]];
    }
    [self pareparUI];
}

- (void)pareparUI {
    [self.view addSubview:self.nav];
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, KWidth, 53)];
    [self.view addSubview:topView];
    // 头像
    UIImageView *headImage = [[UIImageView alloc] initWithFrame:CGRectMake(12, 0, 33, 33)];
    headImage.layer.cornerRadius = headImage.width*0.5;
    WWUserModel *model = [WWUserModel shareUserModel];
    model = (WWUserModel*)[NSKeyedUnarchiver unarchiveObjectWithFile:ArchiverPath];
    headImage.image = model.headimg;
    headImage.centerY = topView.height/2;
    headImage.clipsToBounds = YES;
    [topView addSubview:headImage];
    //姓名
    UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(headImage.right+10, 0, 0, 0)];
    nameLabel.text = self.tagModel.username;
    nameLabel.font = [UIFont fontWithName:kFont_Regular size:14*screenRate];
    nameLabel.textColor = RGBCOLOR(0xffffff);
    nameLabel.textAlignment = NSTextAlignmentLeft;
    nameLabel.numberOfLines = 1;
    [nameLabel sizeToFit];
    nameLabel.centerY = headImage.centerY;
    [topView addSubview:nameLabel];
    
    self.numLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    self.numLabel.text = [NSString stringWithFormat:@"%@",self.tagModel.praise];
    self.numLabel.font = [UIFont fontWithName:kFont_Light size:12*screenRate];
    self.numLabel.textColor = RGBCOLOR(0xffffff) ;
    self.numLabel.textAlignment = NSTextAlignmentRight;
    self.numLabel.numberOfLines = 1;
    [self.numLabel sizeToFit];
    self.numLabel.centerY =nameLabel.centerY;
    self.numLabel.right = KWidth-12;
    [topView addSubview:self.numLabel];
    
    //点赞
    _likeImage = [[WWCollectButton alloc] init];
    _likeImage.imageView.contentMode = UIViewContentModeCenter;
    _likeImage.favoType = 1;
    [_likeImage sizeToFit];
    _likeImage.right = _numLabel.left-2;
    _likeImage.centerY = _numLabel.centerY;
    [_likeImage addTarget:self action:@selector(likeClick) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:_likeImage];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, topView.bottom, KWidth, KHeight-topView.bottom)];
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.bounces = NO;
    [self.view addSubview:_tableView];
    
    UIView *tableHeadView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KWidth, KWidth)];
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, KWidth, [self.imageHeightArr.firstObject doubleValue])];
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.pagingEnabled = YES;
    _scrollView.bounces = NO;
    _scrollView.delegate = self;
    _scrollView.contentOffset = CGPointMake(0, 0);
    if (self.navigationController.interactivePopGestureRecognizer) {
        [_scrollView.panGestureRecognizer requireGestureRecognizerToFail:self.navigationController.interactivePopGestureRecognizer];
    }
    [self loadImageView];
    [tableHeadView addSubview:_scrollView];
    
    _imageNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(KWidth-45, _scrollView.bottom-40, 33, 33)];
    _imageNumLabel.textAlignment = NSTextAlignmentCenter;
    _imageNumLabel.textColor = [UIColor whiteColor];
    _imageNumLabel.text = [NSString stringWithFormat:@"1/%ld",self.tagModel.tagImagesList.count];
    _imageNumLabel.backgroundColor = RGBCOLOR(0xcccccc);
    _imageNumLabel.layer.cornerRadius = _imageNumLabel.width*0.5;
    _imageNumLabel.clipsToBounds = YES;
    [tableHeadView addSubview:_imageNumLabel];
    
    self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(12, _scrollView.bottom+10, KWidth-24, 0)];
    self.titleLabel.font = [UIFont fontWithName:kFont_Medium size:18];
    self.titleLabel.textColor = RGBCOLOR(0x333333);
    self.titleLabel.text = self.tagModel.title;
    [self.titleLabel sizeToFit];
    [tableHeadView addSubview:self.titleLabel];
    
    self.contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(12, _titleLabel.bottom+5, KWidth-24, 0)];
    self.contentLabel.font = [UIFont fontWithName:kFont_Regular size:14];
    self.contentLabel.textColor = RGBCOLOR(0x333333);
    self.contentLabel.numberOfLines = 0;
    self.contentLabel.text = self.tagModel.content;
    [self.contentLabel sizeToFit];
    [tableHeadView addSubview:self.contentLabel];
    tableHeadView.height = self.contentLabel.bottom+20;//底部空隙.以后可能不要
    
    _tableView.tableHeaderView = tableHeadView;
}

- (void)loadImageView {
    NSMutableArray *mArray = [NSMutableArray arrayWithCapacity:10];
    _scrollView.contentSize = CGSizeMake(self.tagModel.tagImagesList.count * KWidth, 0);
    for (int i=0; i<self.tagModel.tagImagesList.count; i++) {
        if (self.imageHeightArr.count>i) {
            [mArray addObject:self.tagModel.tagImagesList[i].image];
            self.imageArray = mArray.copy;
            WWShowTagImgDisplayer *imageView = [[WWShowTagImgDisplayer alloc] initWithFrame:CGRectMake(i*KWidth, 0, KWidth, [self.imageHeightArr[i] doubleValue]) andWithModel:self.tagModel justForDisplay:YES andWithLabelModel:self.tagModel.tagImagesList[i]];
            imageView.image = self.tagModel.tagImagesList[i].image;
            imageView.delegate = self;
            imageView.userInteractionEnabled = YES;
            imageView.tag = i;
            [imageView setClipsToBounds:YES];
            [_scrollView addSubview:imageView];
        }
    }
}

//点赞
- (void)likeClick {
    self.islike = !self.islike;
    if (self.islike) {
        [self.likeImage setFavo:YES withAnimate:YES];
    }else {
        [self.likeImage setFavo:NO withAnimate:YES];
    }
}

#pragma mark - scrolldelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _lastOfset = scrollView.contentOffset.x;
    _lastHight = _scrollView.height;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    int page = _scrollView.contentOffset.x / KWidth;
    double quyu = (int)_scrollView.contentOffset.x % (int)KWidth;
    double h=_lastHight;
    CGFloat offsetX = scrollView.contentOffset.x;
    offsetX = (int)offsetX % (int)KWidth;
    
    if (scrollView.contentOffset.x>_lastOfset) {
        //右滑
        if (quyu>0) {
            page = page+1;
            h = [[self.imageHeightArr objectAtIndex:page] doubleValue];
        }
        if (h!=_lastHight) {
            _scrollView.height = _lastHight - ((_lastHight-h)*offsetX/KWidth);
        }
    }else if (scrollView.contentOffset.x<_lastOfset){
        //左滑
        if (quyu>0) {
            page = page;
            h = [[self.imageHeightArr objectAtIndex:page] doubleValue];
        }
        if (h!=_lastHight) {
            _scrollView.height = h + (_lastHight-h)*offsetX/KWidth;
        }
    }
    
    [_scrollView.subviews enumerateObjectsUsingBlock:^(__kindof WWShowTagImgDisplayer * _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat scale =  view.width / view.height;
        view.height = _scrollView.height;
        CGFloat scaleW = view.height * scale;
        view.width  = scaleW;
        
        NSInteger offset =  scrollView.contentOffset.x /  KWidth;
        if (view.tag == offset) {
            view.left = (offset+1)*KWidth -view.width;
        }else{
            view.left = idx*KWidth;
        }
    }];
    _titleLabel.top = _scrollView.bottom + 10;
    _contentLabel.top = _titleLabel.bottom + 5;
    _tableView.contentSize = CGSizeMake(KWidth, _contentLabel.bottom+20);
    _tableView.tableHeaderView.height = _contentLabel.bottom+20;
    _imageNumLabel.bottom = _scrollView.bottom-7;
    _imageNumLabel.text = [NSString stringWithFormat:@"%d/%lu",page+1,(unsigned long)self.tagModel.tagImagesList.count];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    int page = _scrollView.contentOffset.x / KWidth;
    _scrollView.height = [self.imageHeightArr[page] doubleValue];
    [_scrollView.subviews enumerateObjectsUsingBlock:^(__kindof WWShowTagImgDisplayer * _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
        if (view.tag == page) {
            view.height = [self.imageHeightArr[page] doubleValue];
            view.left = page*KWidth;
            view.width = KWidth;
            
        }
    }];
    _titleLabel.top = _scrollView.bottom + 10;
    _contentLabel.top = _titleLabel.bottom + 5;
    _tableView.contentSize = CGSizeMake(KWidth, _contentLabel.bottom+20);
    _tableView.tableHeaderView.height = _contentLabel.bottom+20;
    _imageNumLabel.bottom = _scrollView.bottom-7;
    _imageNumLabel.text = [NSString stringWithFormat:@"%d/%lu",page+1,(unsigned long)self.tagModel.tagImagesList.count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [UITableViewCell new];
}

- (void)backClick {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - set && get
- (WWNavigationVC *)nav {
    if (_nav == nil) {
        _nav = [[WWNavigationVC alloc]initWithFrame:CGRectMake(0, 20, KWidth, 44)];
        _nav.backBtn.hidden = NO;
        [_nav.backBtn addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
        _nav.navTitle.text = @"标签详情";
        _nav.rightBtn.hidden = YES;
    }
    return _nav;
}

- (NSMutableArray *)imageHeightArr {
    if (!_imageHeightArr) {
        _imageHeightArr = [[NSMutableArray alloc] init];
    }
    return _imageHeightArr;
}
@end
