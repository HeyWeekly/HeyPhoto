//
//  WWTagImageDisPlayer.h
//  Mr.Time
//
//  Created by steaest on 2017/9/7.
//  Copyright © 2017年 Offape. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WWTagImageModel.h"
#import "WWTagImageView.h"
#import "WWTagImageOrderModel.h"

@class WWTagImageDisPlayer;


/**
 *  三个代理方法 如果是编辑器那么就必须全部实现，如果是仅仅展现，那么仅仅实现需要的就可以
 */
@protocol WWTagImageDisPlayerDelegate <NSObject>

@optional
// 关于tag
- (void)displayer:(WWTagImageDisPlayer *)displayer whenTagDeleteBtnClickedWithTag:(WWTagImageView *)tag btn:(UIButton *)btn;
- (BOOL)displayerAllowEditTag:(WWTagImageDisPlayer*)displayer whenTagClickedWithTag:(WWTagImageView*)tag gesture:(UITapGestureRecognizer*)gesture;
- (BOOL)displayer:(WWTagImageDisPlayer*)displayer canMoveTag:(WWTagImageView*)tag;
//- (BOOL)displayer:(WWTagImageDisPlayer*)displayer canEditMaskView:(XER_StickerView*)maskView;
- (void)displayerDidRemoveMaskView:(WWTagImageDisPlayer*)displayer;
- (void)displayer:(WWTagImageDisPlayer*)displayer longPressedWithTag:(WWTagImageView*)tag gesture:(UILongPressGestureRecognizer*)gesture andIndex:(NSInteger )index;

- (void)displayer:(WWTagImageDisPlayer*)displayer createdTagWithModel:(WWTagedImgLabel*)model tag:(WWTagImageView*)tag andWithOrderModel:(WWTagImageOrderModel *)orderModel;
- (void)displayer:(WWTagImageDisPlayer*)displayer createdNoOrderTagWithModel:(WWTagedImgLabel*)model tag:(WWTagImageView*)tag;
// 关于空白区域点击
- (BOOL)displayer:(WWTagImageDisPlayer*)displayer canAddTagWithGesture:(UITapGestureRecognizer*)tap;
- (void)didSelectedOrderGoods;
@end

/**
 tag的显示视图 可以用于创建之后的feed显示
 */
@interface WWTagImageDisPlayer : UIView
//重写初始化方法
- (instancetype)initWithModel:(WWTagImageModel *)model justForDisplay:(BOOL)justForDisplay andImageArray:(NSArray *)array;
//截图
@property (nonatomic, strong) NSArray *tagImageViewArray;
//传进来的图片数组
@property (nonatomic, strong) NSArray *imageArray;
@property (nonatomic, strong) NSArray *originImageArray;
//滑动的scrollView
@property (nonatomic, strong) UIScrollView *scrollView;
// 用于重新定位labels
- (void)adjustPosition:(WWTagImageView*)tagView;
//里面存放的imageView用于加tag  废弃
//@property (nonatomic, strong) NSArray *imageViewArray;
//tap传出来的imageView
@property (nonatomic, strong) UIImageView *didImageView;
//测试数组
@property (nonatomic, strong) NSMutableArray *tagImageArray;
//didTag 选中图片的tag
@property (nonatomic, assign) NSInteger didTag;
//XER_ImgTagEditer需要的一个数组
@property (nonatomic, strong) NSArray *tagEditerArray;

@property (nonatomic, strong) WWTagImageModel *modelArray;

@property (nonatomic, weak) id<WWTagImageDisPlayerDelegate> delegate;

- (void)changeModel:(WWTagImageModel*)model;
- (void)addMaskWithImage:(UIImage*)image;
- (void)refreshView;
- (void)startTextAnimation;
- (void)moveLabelToGuidePostion;
- (void)resetLabelPositionAfterGuide;
@end
