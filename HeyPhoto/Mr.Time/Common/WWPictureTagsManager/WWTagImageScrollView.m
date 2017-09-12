//
//  WWTagImageScrollView.m
//  Mr.Time
//
//  Created by steaest on 2017/9/7.
//  Copyright © 2017年 Offape. All rights reserved.
//

#import "WWTagImageScrollView.h"

#define rad(angle) ((angle) / 180.0 * M_PI)

@implementation WWTagImageScrollView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = NO;
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.alwaysBounceHorizontal = YES;
        self.alwaysBounceVertical = YES;
        self.bouncesZoom = YES;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.delegate = self;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // center the zoom view as it becomes smaller than the size of the screen
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = self.imageView.frame;
    
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    else
        frameToCenter.origin.x = 0;
    
    // center vertically
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    else
        frameToCenter.origin.y = 0;
    
    self.imageView.frame = frameToCenter;
}

/**
 *  cropping image not just snapshot , inpired by https://github.com/gekitz/GKImagePicker
 *
 *  @return image cropped
 */
- (UIImage *)captureCropImage:(CGRect)cropRect{
    CGRect visibleRect = [self _calcVisibleRectForCropAreaCropImage:cropRect];//caculate visible rect for crop
    CGAffineTransform rectTransform = [self _orientationTransformedRectOfImage:self.imageView.image];//if need rotate caculate
    visibleRect = CGRectApplyAffineTransform(visibleRect, rectTransform);
    
    CGImageRef ref = CGImageCreateWithImageInRect([self.imageView.image CGImage], visibleRect);//crop
    UIImage* cropped = [[UIImage alloc] initWithCGImage:ref scale:self.imageView.image.scale orientation:self.imageView.image.imageOrientation];
    CGImageRelease(ref);
    ref = NULL;
    return cropped;
}

static CGRect TWScaleRect(CGRect rect, CGFloat scale) {
    return CGRectMake(rect.origin.x * scale, rect.origin.y * scale, rect.size.width * scale, rect.size.height * scale);
}


-(CGRect)_calcVisibleRectForCropAreaCropImage:(CGRect)cropRect {
    if (cropRect.size.width==KWidth/8) {
        CGPoint bounsOrigin = self.bounds.origin;
        CGSize bounsSize = self.bounds.size;
        bounsOrigin.x = bounsOrigin.x + cropRect.size.width;
        bounsSize.width = bounsSize.width *3 / 4;
        CGFloat sizeScale = self.imageView.image.size.width / self.imageView.frame.size.width;
        sizeScale *= self.zoomScale;
        CGRect visibleRect = [self convertRect:CGRectMake(bounsOrigin.x, bounsOrigin.y, bounsSize.width, bounsSize.height) toView:self.imageView];
        return visibleRect = TWScaleRect(visibleRect, sizeScale);
    }else if (cropRect.size.width==KWidth) {
        CGPoint bounsOrigin = self.bounds.origin;
        CGSize bounsSize = self.bounds.size;
        bounsOrigin.y = bounsOrigin.y + cropRect.size.height;
        bounsSize.height = bounsSize.height *3 / 4;
        CGFloat sizeScale = self.imageView.image.size.width / self.imageView.frame.size.width;
        sizeScale *= self.zoomScale;
        CGRect visibleRect = [self convertRect:CGRectMake(bounsOrigin.x, bounsOrigin.y, bounsSize.width, bounsSize.height) toView:self.imageView];
        return visibleRect = TWScaleRect(visibleRect, sizeScale);
    }else{
        CGFloat sizeScale = self.imageView.image.size.width / self.imageView.frame.size.width;
        sizeScale *= self.zoomScale;
        CGRect visibleRect = [self convertRect:self.bounds toView:self.imageView];
        visibleRect = TWScaleRect(visibleRect, sizeScale);
        return visibleRect;
    }
}

- (CGAffineTransform)_orientationTransformedRectOfImage:(UIImage *)img {
    CGAffineTransform rectTransform;
    switch (img.imageOrientation)
    {
        case UIImageOrientationLeft:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(90)), 0, -img.size.height);
            break;
        case UIImageOrientationRight:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(-90)), -img.size.width, 0);
            break;
        case UIImageOrientationDown:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(-180)), -img.size.width, -img.size.height);
            break;
        default:
            rectTransform = CGAffineTransformIdentity;
    };
    
    return CGAffineTransformScale(rectTransform, img.scale, img.scale);
}


- (void)displayImage:(UIImage *)image {
    // clear the previous image
    [self.imageView removeFromSuperview];
    self.imageView = nil;
    
    // reset our zoomScale to 1.0 before doing any further calculations
    self.zoomScale = 1.0;
    
    // make a new UIImageView for the new image
    self.imageView = [[UIImageView alloc] initWithImage:image];
    self.imageView.clipsToBounds = NO;
    [self addSubview:self.imageView];
    
    CGRect frame = self.imageView.frame;
    if (image.size.height > image.size.width) {
        frame.size.width = self.bounds.size.width;
        frame.size.height = self.bounds.size.width/image.size.width * image.size.height;
    } else {
        frame.size.height = self.bounds.size.height;
        frame.size.width = self.bounds.size.height/image.size.height*image.size.width;
    }
    self.imageView.frame = frame;
    [self configureForImageSize:self.imageView.bounds.size];
}

//image size
- (void)configureForImageSize:(CGSize)imageSize {
    _imageSize = imageSize;
    self.contentSize = imageSize;
    //to center
    if (imageSize.width > imageSize.height) {
        self.contentOffset = CGPointMake((imageSize.width - self.frame.size.width) / 2, 0);
    } else if (imageSize.width < imageSize.height) {
        self.contentOffset = CGPointMake(0, (imageSize.height - self.frame.size.height) / 2);
    }
    
    [self setMaxMinZoomScalesForCurrentBounds];
    self.zoomScale = 1.0;
}

- (void)setMaxMinZoomScalesForCurrentBounds {
    self.minimumZoomScale = 1.0;
    self.maximumZoomScale = 5.0;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

@end
