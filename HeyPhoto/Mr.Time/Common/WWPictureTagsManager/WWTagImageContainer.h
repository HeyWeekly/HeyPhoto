//
//  WWTagImageContainer.h
//  Mr.Time
//
//  Created by steaest on 2017/9/7.
//  Copyright © 2017年 Offape. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WWTagImageContainer : UIView

@property (nonatomic, copy) void (^resultImageBlock)(UIImage *image);

- (instancetype)initWithImage:(UIImage *)image;

@end
