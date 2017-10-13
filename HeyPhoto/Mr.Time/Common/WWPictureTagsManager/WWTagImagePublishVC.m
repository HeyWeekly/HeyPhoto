//
//  WWTagImagePublishVC.m
//  Mr.Time
//
//  Created by 王伟伟 on 2017/10/13.
//  Copyright © 2017年 Offape. All rights reserved.
//

#import "WWTagImagePublishVC.h"
#import "WWTagImageModel.h"
#import "LxGridViewFlowLayout.h"
#import "WWTagImageCell.h"
#import <YYText/YYText.h>
#import "TZImagePickerController.h"
#import <YYModel/YYModel.h>
#import "NSObject+ModelToDictionary.h"

@interface WWTagImagePublishVC ()<UINavigationControllerDelegate,UITextFieldDelegate,UICollectionViewDelegate,UICollectionViewDataSource,LxGridViewDataSource,YYTextViewDelegate>{
    
    CGFloat _itemWH;
    CGFloat _margin;
}
@property (nonatomic,strong ) UIScrollView                *scrollView;
@property (nonatomic, strong) WWTagImageModel      *model;
@property (nonatomic, strong) NSMutableArray              *dataSource;
@property (nonatomic, strong) NSArray                     *originImageArray;
@property (nonatomic, strong) NSArray                     *selectPhotoKey;
@property (nonatomic, strong) NSDictionary                *photoDict;//传进来的图片字典
@property (nonatomic, strong) NSArray <WWTagedImgListModel *> *tagedImgModel;//模型删除
@property (nonatomic, strong) WWNavigationVC *nav;
@property (strong, nonatomic) LxGridViewFlowLayout *layout;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UITextField *yearsField;
@property (nonatomic, strong) YYTextView *inputTextView;
@end

@implementation WWTagImagePublishVC

- (instancetype)initWithImageArray:(NSArray *)imageArray andMode:(WWTagImageModel *)model andCapImageArray:(NSArray *)capImageArray andSelectPhotoKey:(NSArray *)selectPhotoKey andoriginImageArray:(NSArray *)originImageArray andPhotoDict:(NSDictionary *)photoDict {
    if (self = [super init]) {
        self.view.backgroundColor = viewBackGround_Color;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData:) name:@"refreshData" object:nil];
        _dataSource = [NSMutableArray arrayWithCapacity:10];
        [self setupSubviews];
        self.imageArray = imageArray;
        self.originImageArray = originImageArray;
        self.selectPhotoKey = selectPhotoKey;
        self.dataSource = capImageArray.mutableCopy;
        self.model = model;
        self.photoDict = photoDict;
    }
    return self;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    NSInteger contentSizeH = 12 * 35 + 20;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.scrollView.contentSize = CGSizeMake(0, contentSizeH + 5);
    });
    _margin = 4;
    _itemWH = (self.view.width_sd - 2 * _margin - 4) / 3 - _margin;
    _layout.itemSize = CGSizeMake(_itemWH, _itemWH);
    _layout.minimumInteritemSpacing = _margin;
    _layout.minimumLineSpacing = _margin;
    [self.collectionView setCollectionViewLayout:_layout];
    self.collectionView.frame = CGRectMake(0, self.inputTextView.bottom+10, KWidth, self.view.height_sd - (self.inputTextView.bottom+10));
}

-(void)setupSubviews {
    [self.view addSubview:self.nav];
    [self.view addSubview:self.yearsField];
    [self.yearsField sizeToFit];
    self.yearsField.left_sd = 20*screenRate;
    self.yearsField.top = self.nav.bottom + 10;
    self.yearsField.width =KWidth-40*screenRate;

    [self.view addSubview:self.inputTextView];
    [self.inputTextView sizeToFit];
    self.inputTextView.left = 20*screenRate;
    self.inputTextView.top = self.yearsField.bottom_sd+10;
    self.inputTextView.width = KWidth-40*screenRate;
    self.inputTextView.height = 229*screenRate;
    
    _layout = [[LxGridViewFlowLayout alloc] init];
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_layout];
    _collectionView.alwaysBounceVertical = YES;
    _collectionView.backgroundColor = viewBackGround_Color;
    _collectionView.contentInset = UIEdgeInsetsMake(4, 4, 4, 4);
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.view addSubview:_collectionView];
    [_collectionView registerClass:[WWTagImageCell class] forCellWithReuseIdentifier:@"WWTagImageCell"];
}

#pragma mark - event
- (void)refreshData:(NSNotification *)text{
    NSDictionary *dict = text.userInfo;
    self.imageArray = dict[@"imageArray"];
    self.originImageArray = dict[@"originImageArray"];
    NSArray *captureImageArray = dict[@"captureImageArray"];
    self.dataSource = captureImageArray.mutableCopy;
    self.model = dict[@"modelArray"];
    self.selectPhotoKey = dict[@"selectPhotoKey"];
    self.photoDict = dict[@"photoDict"];
    [self.collectionView reloadData];
}

- (void )cancelBtnClick {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)postTagImageClick{
    if (self.yearsField.text.length <= 0) {
        [WWHUD showMessage:@"请添加标题" inView:self.view];
        return;
    }
    if (self.inputTextView.text.length <= 0) {
        [WWHUD showMessage:@"记录您此刻的心情吧~" inView:self.view];
        return;
    }
    if (self.dataSource.count == 0){
        [WWHUD showMessage:@"至少添加一张照片" inView:self.view];
        return;
    }
    if (self.yearsField.text.length > 30){
        [WWHUD showMessage:@"标题不多于15个字" inView:self.view];
        return;
    }
    if (_dataSource.count > 9){
        [WWHUD showMessage:@"最多添加9张图片" inView:self.view];
        return;
    }
    self.model.title = self.yearsField.text;
    self.model.username = @"林森";
    self.model.isPraise = @"NO";
    self.model.praise = @(14354);
    self.model.content = self.inputTextView.text;
    NSDictionary *dict =[[NSDictionary alloc] initWithObjectsAndKeys:self.model,@"model", nil];
    NSNotification *notification =[NSNotification notificationWithName:@"addModel" object:nil userInfo:dict];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

//删除
-(void)tapAvatarView:(UIButton *)sender {
    [_dataSource removeObjectAtIndex:sender.tag];

    NSMutableArray *imageMarray = [NSMutableArray arrayWithArray:self.imageArray];
    [imageMarray removeObjectAtIndex:sender.tag];
    self.imageArray = imageMarray.copy;

    NSMutableArray *originImageMarray = [NSMutableArray arrayWithArray:self.originImageArray];
    [originImageMarray removeObjectAtIndex:sender.tag];
    self.originImageArray = originImageMarray.copy;

    NSMutableArray *mArray = [NSMutableArray arrayWithCapacity:10];
    for (int i = 0 ; i<self.selectPhotoKey.count; i++) {
        [mArray addObject:self.model.tagImagesList[i]];
    }
    [mArray removeObjectAtIndex:sender.tag];
    WWTagImageModel *modelArray = [[WWTagImageModel alloc]initWithDict:nil];
    modelArray.tagImagesList = mArray.copy;
    self.model = modelArray;

    NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithDictionary:self.photoDict];
    [mDict removeObjectForKey:self.selectPhotoKey[sender.tag]];
    self.photoDict = mDict.copy;

    //选择图片的Key
    NSMutableArray *MselectPhotoKey = [NSMutableArray arrayWithArray:self.selectPhotoKey];
    [MselectPhotoKey removeObjectAtIndex:sender.tag];
    self.selectPhotoKey = MselectPhotoKey.copy;
    [self.collectionView reloadData];
}

- (void)addPicture {
    if (self.dataSource.count >= 9) {
        NSString *msg = [NSString stringWithFormat:@"最多选择 %lu 张图片",(unsigned long)self.selectPhotoKey.count];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:msg preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action];
        [alert addAction:action2];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
        WWImageTagPHPPicker *pickerVc = [[WWImageTagPHPPicker alloc] initWithModel:self.model andTailoringImageArray:self.imageArray andoriginImageArray:self.originImageArray andSelectPhotoKey:self.selectPhotoKey andPhotoDict:self.photoDict];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:pickerVc];
        [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - LxGridViewDataSource
- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.item < self.dataSource.count;
}

- (BOOL)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)sourceIndexPath canMoveToIndexPath:(NSIndexPath *)destinationIndexPath {
    return (sourceIndexPath.item < self.dataSource.count && destinationIndexPath.item < self.dataSource.count);
}

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)sourceIndexPath didMoveToIndexPath:(NSIndexPath *)destinationIndexPath {
    UIImage *image = self.dataSource[sourceIndexPath.item];
    [self.dataSource removeObjectAtIndex:sourceIndexPath.item];
    [self.dataSource insertObject:image atIndex:destinationIndexPath.item];
    
    UIImage *image1 = self.imageArray[sourceIndexPath.item];
    NSMutableArray *imageMarray = [NSMutableArray arrayWithArray:self.imageArray];
    [imageMarray removeObjectAtIndex:sourceIndexPath.item];
    [imageMarray insertObject:image1 atIndex:sourceIndexPath.item];
    self.imageArray = imageMarray.copy;
    
    UIImage *image2 = self.originImageArray[sourceIndexPath.item];
    NSMutableArray *originImageMarray = [NSMutableArray arrayWithArray:self.originImageArray];
    [originImageMarray removeObjectAtIndex:sourceIndexPath.item];
    [originImageMarray insertObject:image2 atIndex:sourceIndexPath.item];
    self.originImageArray = originImageMarray.copy;
    
    WWTagedImgListModel *model1 = self.model.tagImagesList[sourceIndexPath.item];
    NSMutableArray *mArray = [NSMutableArray arrayWithCapacity:10];
    for (int i = 0 ; i<self.selectPhotoKey.count; i++) {
        [mArray addObject:self.model.tagImagesList[i]];
    }
    [mArray removeObjectAtIndex:sourceIndexPath.item];
    [mArray insertObject:model1 atIndex:sourceIndexPath.item];
    WWTagImageModel *modelArray = [[WWTagImageModel alloc]initWithDict:nil];
    modelArray.tagImagesList = mArray.copy;
    self.model = modelArray;

    [_collectionView reloadData];
}

#pragma mark UICollectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count+1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WWTagImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"WWTagImageCell" forIndexPath:indexPath];
    if (indexPath.row == self.dataSource.count) {
        cell.imageView.image = [UIImage imageNamed:@"tianjia"];
        cell.deleteBtn.hidden = YES;
    } else {
        cell.imageView.image = self.dataSource[indexPath.row];
        cell.deleteBtn.hidden = NO;
    }
    cell.deleteBtn.tag = indexPath.row;
    [cell.deleteBtn addTarget:self action:@selector(tapAvatarView:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.dataSource.count) {
        [self addPicture];
    } else {
        [WWHUD showMessage:@"假装这是图片预览，不造轮子了~~~" inView:self.view];
    }
}

#pragma mark - delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.yearsField resignFirstResponder];
    return YES;
}

- (void)textViewDidEndEditing:(YYTextView *)textView {}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

#pragma mark - set && geter
- (void)setModel:(WWTagImageModel *)model {
    _model = model;
}

- (void)setImageArray:(NSArray *)imageArray {
    _imageArray = imageArray;
    [self.collectionView reloadData];
}

- (void)setDataSource:(NSMutableArray *)dataSource {
    _dataSource = dataSource;
    [self.collectionView reloadData];
}

- (WWNavigationVC *)nav {
    if (_nav == nil) {
        _nav = [[WWNavigationVC alloc]initWithFrame:CGRectMake(0, 20, KWidth, 44)];
        _nav.backBtn.hidden = NO;
        _nav.rightBtn.hidden = NO;
        _nav.navTitle.text = @"标签发布";
        _nav.rightName = @"发布";
        _nav.rightColor = RGBCOLOR(0xffffff);
        [_nav.rightBtn addTarget:self action:@selector(postTagImageClick) forControlEvents:UIControlEventTouchUpInside];
        [_nav.backBtn addTarget:self action:@selector(cancelBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nav;
}

- (YYTextView *)inputTextView {
    if (_inputTextView == nil) {
        _inputTextView = [[YYTextView alloc]initWithFrame:CGRectMake(0, 0, KWidth, KHeight)];
        _inputTextView.font = [UIFont fontWithName:kFont_SemiBold size:14*screenRate];
        _inputTextView.textColor = RGBCOLOR(0xffffff);
        _inputTextView.placeholderText = @"留下些什么？";
        _inputTextView.placeholderTextColor = RGBCOLOR(0x000000);
        _inputTextView.placeholderFont = [UIFont fontWithName:kFont_Medium size:14*screenRate];
        _inputTextView.keyboardType = UIKeyboardTypeDefault;
        _inputTextView.returnKeyType = UIReturnKeyDone;
        _inputTextView.delegate = self;
        _inputTextView.keyboardAppearance = UIKeyboardAppearanceDark;
    }
    return _inputTextView;
}

- (UITextField *)yearsField {
    if (!_yearsField) {
        _yearsField = [[UITextField alloc]init];
        _yearsField.placeholder = @"请填写标题";
        _yearsField.font = [UIFont fontWithName:kFont_DINAlternate size:18*screenRate];
        _yearsField.textColor = RGBCOLOR(0xffffff);
        _yearsField.keyboardType = UIKeyboardTypeDefault;
        _yearsField.keyboardAppearance = UIKeyboardAppearanceDark;
        _yearsField.returnKeyType = UIReturnKeyDone;
        _yearsField.delegate = self;
    }
    return _yearsField;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
