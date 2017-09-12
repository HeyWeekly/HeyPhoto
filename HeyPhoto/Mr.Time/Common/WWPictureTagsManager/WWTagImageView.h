//
//  WWTagImageView.h
//  Mr.Time
//
//  Created by steaest on 2017/9/7.
//  Copyright © 2017年 Offape. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WWTagImageModel.h"

@class WWTagImageView;

@interface WWTagImageShopingCateView : UIImageView
@end

@protocol WWTagImageViewDelegate <NSObject>
@optional
- (BOOL)tagAllowEdit:(WWTagImageView*)tag clickedWithGesture:(UITapGestureRecognizer*)tap;
- (void)tag:(WWTagImageView*)tag panedWithGesture:(UIPanGestureRecognizer*)pan;
- (void)tag:(WWTagImageView*)tag longPressWithGesture:(UILongPressGestureRecognizer*)longPress;
- (void)tagNeedAdjustPostion:(WWTagImageView*)tag;
@end

@class WWTagImgViewTextView;
@protocol WWTagImgViewTextViewDelegate <NSObject>

- (void)text:(WWTagImgViewTextView*)text tapedWithGesture:(UITapGestureRecognizer*)tap;
- (void)text:(WWTagImgViewTextView*)text pannedWithGesture:(UIPanGestureRecognizer*)pan;
- (void)text:(WWTagImgViewTextView*)text longPressedWithGesture:(UILongPressGestureRecognizer*)longPress;

@end

@interface WWTagImagePointView : UIImageView
@property (nonatomic, assign,readonly) CGSize size;
@end


@interface WWTagImgViewTextView : UIView
@property (nonatomic, copy) NSString* title;
@property (nonatomic, weak) id <WWTagImgViewTextViewDelegate> delegate;
- (instancetype)initWithLeftForward:(BOOL)leftForward;
@end


@interface WWTagImageDirectionSwitcher : UIButton
@end

@interface WWTagImageView : UIView
- (void)changeDirectionSwitcherClick;
- (void)showText;
- (void)startTextAnimation;
- (instancetype)initWithModel:(WWTagedImgLabel*)model justForDisplay:(BOOL)justForDisplay;
- (void)startEditing;
- (void)endEditing;
// 暂时不支持换样式
//- (void)refreshView;

/**
 *  若引用他们自己的约束
 */
@property (nonatomic, weak) NSLayoutConstraint* xCon;
@property (nonatomic, weak) NSLayoutConstraint* yCon;
@property (nonatomic, strong) UIView* containerView;
@property (nonatomic, assign) BOOL textHadShown;
@property (nonatomic, strong, readonly) WWTagImagePointView* point;
/**
 *  记录他们自己的原始位置和原始约束
 */
@property (nonatomic, strong) NSValue* originPoint;
@property (nonatomic, strong) NSValue* originCon;
@property (nonatomic, strong) NSValue* startPoint;
@property (nonatomic, assign, readonly) BOOL isAnimating;

@property (nonatomic, strong, readonly) WWTagImgViewTextView* textView;

@property (nonatomic, assign) CGRect unionFrame;

@property (nonatomic, readonly) WWTagedImgLabel* model;
@property (nonatomic, weak) id<WWTagImageViewDelegate> delegate;
@end
