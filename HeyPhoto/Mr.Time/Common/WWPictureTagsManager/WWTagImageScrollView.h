//
//  WWTagImageScrollView.h
//  Mr.Time
//
//  Created by steaest on 2017/9/7.
//  Copyright © 2017年 Offape. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WWTagImageScrollView : UIScrollView <UIScrollViewDelegate>
{
    CGSize _imageSize;
}
@property (strong, nonatomic) UIImageView *imageView;
- (void)displayImage:(UIImage *)image;
- (UIImage *)captureCropImage:(CGRect)cropRect;

@end
