//
//  WWNavigationVC.h
//  Mr.Time
//
//  Created by steaest on 2017/6/8.
//  Copyright © 2017年 Offape. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WWNavigationVC : UIView
@property (nonatomic, strong) UIColor *titColor;
@property (nonatomic, strong) UIColor *rightColor;
@property (nonatomic, copy) NSString *imageName;
@property (nonatomic, copy) NSString *rightName;
@property (nonatomic, strong) UIButton *backBtn;
@property(nonatomic, strong) UILabel* navTitle;
@property (nonatomic, strong) UIButton *rightBtn;
@end
