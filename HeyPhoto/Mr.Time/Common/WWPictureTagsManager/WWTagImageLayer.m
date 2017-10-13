//
//  WWTagImageLayer.m
//  Mr.Time
//
//  Created by steaest on 2017/9/8.
//  Copyright © 2017年 Offape. All rights reserved.
//

#import "WWTagImageLayer.h"

@interface WWTagImageLayer ( ) <UITextFieldDelegate>
@property (nonatomic, strong) id model;
@property (nonatomic, strong) UIImageView *cardCarousel;
@property (nonatomic, strong) UIView  *containerView;
@property (nonatomic, strong) NSArray<id>*modelArray;
@property (nonatomic, strong) UIButton *close;
@property (nonatomic, strong) UIBlurEffect *effect;
@property (nonatomic, strong) UIVisualEffectView *effectView;
@property (nonatomic, strong) NSArray *imageArray;
@property (nonatomic, strong) UIView *searchLine;
@property (nonatomic, strong) UITextField* inputView;
@property (nonatomic, strong) UIButton *doneBtn;
@end

@implementation WWTagImageLayer

-(instancetype)initWithImageArray:(NSArray *)imageArray {
    if (self = [super init]) {
        self.imageArray = imageArray;
        self.backgroundColor =[UIColor clearColor];
        self.frame = CGRectMake(0, 44, KWidth, KHeight-44);
        [self setUpSubviews];
    }
    return self;
}

#pragma mark - 动画
- (void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    self.effectView.alpha = 0;
    self.cardCarousel.transform = CGAffineTransformTranslate(self.cardCarousel.transform, 0, -KWidth*0.7);
    self.cardCarousel.alpha = 0;
    self.close.alpha = 0;
}
- (void)didMoveToWindow{
    [super didMoveToWindow];
    [UIView animateWithDuration:0.3 animations:^{
    }];
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.effectView.alpha = 1.0;
        self.cardCarousel.transform = CGAffineTransformIdentity;
        self.cardCarousel.alpha = 1.0;
        self.close.alpha = 1.0;
    } completion:nil];
}

#pragma mark - 视图
- (void)setUpSubviews {
    [self addSubview:self.effectView];
    [self addSubview:self.cardCarousel];
    
    self.searchLine.left = 80*screenRate;
    self.searchLine.top = self.cardCarousel.bottom + 60*screenRate;
    self.searchLine.height = 1;
    self.searchLine.width = KWidth - 160*screenRate;
    [self addSubview:self.searchLine];
    
    self.inputView.left = 80*screenRate;
    self.inputView.top = self.cardCarousel.bottom + 25*screenRate;
    self.inputView.height = 35*screenRate;
    self.inputView.width = KWidth - 160*screenRate;
    [self addSubview:self.inputView];
    
    self.close.left = 80*screenRate;
    self.close.top = self.searchLine.bottom+60*screenRate;
    self.close.width = 80*screenRate;
    self.close.height = 33*screenRate;
    [self addSubview:self.close];
    
    self.doneBtn.left = 160*screenRate+(self.searchLine.width - 160*screenRate);
    self.doneBtn.top = self.close.top;
    self.doneBtn.width = 80*screenRate;
    self.doneBtn.height = 33*screenRate;
    [self addSubview:self.doneBtn];
    
}

- (void)setImageArray:(NSArray *)imageArray {
    _imageArray = imageArray;
    self.cardCarousel.image = self.imageArray.firstObject;
}

#pragma mark - 代理
- (void)buyNowClick{
    if (self.inputView.text.length > 0) {
        if ([self.delegate respondsToSelector:@selector(tagDoneText:)]) {
            [self.delegate tagDoneText:self.inputView.text];
        }
    }else {
        [WWHUD showMessage:@"无输入内容，请点击关闭按钮" inView:self afterDelayTime:1.5f];
    }
}

- (void)closeMore {
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.alpha = 0.0;
        self.cardCarousel.transform = CGAffineTransformTranslate(self.cardCarousel.transform, 0, KHeight * 0.8);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.inputView endEditing:YES];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    self.inputView.placeholder = nil;
}

#pragma mark - 通知事件
#define DESMAX_STARWORDS_LENGTH 16
//中英文的分别判断字符个数
-(void)textFiledEditChanged:(NSNotification *)obj{
    __block NSInteger count = 0;
    UITextField *textField = self.inputView;
    NSString *toBeString = textField.text;
    // 获取高亮部分
    UITextRange *selectedRange = [textField markedTextRange];
    UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
    // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
    if (!position){
        if (toBeString.length > DESMAX_STARWORDS_LENGTH){
            NSRange rangeIndex = [toBeString rangeOfComposedCharacterSequenceAtIndex:DESMAX_STARWORDS_LENGTH];
            if (rangeIndex.length == 1){
                textField.text = [toBeString substringToIndex:DESMAX_STARWORDS_LENGTH];
            }else{
                NSRange rangeRange = [toBeString rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, DESMAX_STARWORDS_LENGTH)];
                textField.text = [toBeString substringWithRange:rangeRange];
            }
        }
    }
    __weak typeof(self) weakSelf = self;
    [textField.text enumerateSubstringsInRange:NSMakeRange(0, textField.text.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
         char commitChar = [toBeString characterAtIndex:0];
         NSString *temp = [toBeString substringWithRange:NSMakeRange(0,1)];
         const char *u8Temp = [temp UTF8String];
         if ([weakSelf stringContainsEmoji:substring]) {
             count += 1;
         }else if (u8Temp && 3==strlen(u8Temp)) {
             count += 2;
         }else if(commitChar >= 0 && commitChar <= 127){
             count++;
         }else{
             count++;
         }
     }];
}

- (BOOL)stringContainsEmoji:(NSString *)string {
    __block BOOL returnValue = NO;
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
         const unichar hs = [substring characterAtIndex:0];
         // surrogate pair
         if (0xd800 <= hs && hs <= 0xdbff) {
             if (substring.length > 1) {
                 const unichar ls = [substring characterAtIndex:1];
                 const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                 if (0x1d000 <= uc && uc <= 0x1f77f) {
                     returnValue = YES;
                 }
             }
         } else if (substring.length > 1) {
             const unichar ls = [substring characterAtIndex:1];
             if (ls == 0x20e3) {
                 returnValue = YES;
             }
             
         } else {
             // non surrogate
             if (0x2100 <= hs && hs <= 0x27ff) {
                 returnValue = YES;
             } else if (0x2B05 <= hs && hs <= 0x2b07) {
                 returnValue = YES;
             } else if (0x2934 <= hs && hs <= 0x2935) {
                 returnValue = YES;
             } else if (0x3297 <= hs && hs <= 0x3299) {
                 returnValue = YES;
             } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                 returnValue = YES;
             }
         }
     }];
    return returnValue;
}

#pragma mark - lazyload
- (UIImageView *)cardCarousel {
    if (!_cardCarousel) {
        _cardCarousel = [[UIImageView alloc]initWithFrame:CGRectMake(32*screenRate, 44, KWidth - 64*screenRate, 375*screenRate)];
        _cardCarousel.contentMode = UIViewContentModeScaleAspectFill;
        _cardCarousel.clipsToBounds = YES;
    }
    return _cardCarousel;
}

- (UIButton *)close {
    if (_close == nil) {
        _close = [[UIButton alloc]init];
        [_close setBackgroundColor:[UIColor whiteColor]];
        [_close setTitle:@"关闭" forState:UIControlStateNormal];
        [_close setTitleColor:RGBCOLOR(0x333333) forState:UIControlStateNormal];
        _close.titleLabel.font = [UIFont fontWithName:kFont_Regular size:16*screenRate];
        _close.layer.masksToBounds = YES;
        _close.layer.borderColor = RGBCOLOR(0x999999).CGColor;
        _close.layer.borderWidth = 1;
        [_close addTarget:self action:@selector(closeMore) forControlEvents:UIControlEventTouchUpInside];
    }
    return _close;
}

- (UIBlurEffect *)effect {
    if (_effect == nil) {
        _effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    }
    return _effect;
}
- (UIVisualEffectView *)effectView {
    if (_effectView == nil) {
        _effectView = [[UIVisualEffectView alloc]initWithEffect:self.effect];
        _effectView.frame = CGRectMake(0, 44, KWidth, KHeight-44);
    }
    return _effectView;
}

- (UIView *)searchLine {
    if (_searchLine == nil) {
        _searchLine = [[UIView alloc]init];
        _searchLine.backgroundColor = RGBCOLOR(0x999999);
    }
    return _searchLine;
}

- (UITextField *)inputView{
    if (_inputView == nil) {
        _inputView = [[UITextField alloc] init];
        _inputView.tintColor = RGBCOLOR(0x333333);
        _inputView.font = [UIFont fontWithName:kFont_Bold size:15*screenRate];
        _inputView.textColor = RGBCOLOR(0x333333);
        _inputView.placeholder = @"请输入标签内容";
        _inputView.textAlignment = NSTextAlignmentCenter;
        _inputView.keyboardType = UIKeyboardTypeDefault;
        _inputView.keyboardAppearance = UIKeyboardAppearanceDark;
        _inputView.returnKeyType = UIReturnKeyDone;
        _inputView.adjustsFontSizeToFitWidth = YES;
        _inputView.delegate = self;

    }
    return _inputView;
}

- (UIButton *)doneBtn {
    if (_doneBtn == nil) {
        _doneBtn = [[UIButton alloc]init];
        [_doneBtn setBackgroundColor:RGBCOLOR(0x333333)];
        [_doneBtn setTitle:@"完成" forState:UIControlStateNormal];
        [_doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _doneBtn.titleLabel.font = [UIFont fontWithName:kFont_Regular size:16*screenRate];
        _doneBtn.layer.masksToBounds = YES;
        [_doneBtn addTarget:self action:@selector(buyNowClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _doneBtn;
}

@end
