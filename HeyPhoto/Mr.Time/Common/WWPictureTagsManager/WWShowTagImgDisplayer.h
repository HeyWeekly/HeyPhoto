//
//  WWShowTagImgDisplayer.h
//  YaoKe
//
//  Created by steaest on 2016/11/22.
//  Copyright © 2016年 YaoKe. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WWTagImageModel;
@class WWTagedImgListModel;
@class WWShowTagImgDisplayer;
@class WWTagImageView;
@class WWTagedImgLabel;

/**
 *  三个代理方法 如果是编辑器那么就必须全部实现，如果是仅仅展现，那么仅仅实现需要的就可以
 */
@protocol WWShowTagImgDisplayerDelegate <NSObject>

@optional
// 关于tag
- (void)Showdisplayer:(WWShowTagImgDisplayer*)displayer whenTagDeleteBtnClickedWithTag:(WWTagImageView*)tag btn:(UIButton*)btn;
- (BOOL)ShowdisplayerAllowEditTag:(WWShowTagImgDisplayer*)displayer whenTagClickedWithTag:(WWTagImageView*)tag gesture:(UITapGestureRecognizer*)gesture;
- (BOOL)Showdisplayer:(WWShowTagImgDisplayer*)displayer canMoveTag:(WWTagImageView*)tag;
- (void)ShowdisplayerDidRemoveMaskView:(WWShowTagImgDisplayer*)displayer;
- (void)Showdisplayer:(WWShowTagImgDisplayer*)displayer longPressedWithTag:(WWTagImageView*)tag gesture:(UILongPressGestureRecognizer*)gesture;
- (void)Showdisplayer:(WWShowTagImgDisplayer*)displayer createdTagWithModel:(WWTagedImgLabel*)model tag:(WWTagImageView*)tag;
// 关于空白区域点击
- (BOOL)Showdisplayer:(WWShowTagImgDisplayer*)displayer canAddTagWithGesture:(UITapGestureRecognizer*)tap;
@end



@interface WWShowTagImgDisplayer : UIImageView
- (instancetype)initWithFrame:(CGRect)frame andWithModel:(WWTagImageModel *)model justForDisplay:(BOOL)justForDisplay andWithLabelModel:(WWTagedImgListModel *)labelModel;
- (void)changeModel:(WWTagImageModel*)model;
//- (void)addMaskWithImage:(UIImage*)image;
@property (nonatomic, weak) id<WWShowTagImgDisplayerDelegate> delegate;
// 用于重新定位labels
- (void)adjustPosition:(WWTagImageView*)tagView;
- (void)refreshView;
- (void)startTextAnimation;
- (void)moveLabelToGuidePostion;
- (void)resetLabelPositionAfterGuide;
@end
