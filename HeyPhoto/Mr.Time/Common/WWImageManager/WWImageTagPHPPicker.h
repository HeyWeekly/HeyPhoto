//
//  WWImageTagPHPPicker.h
//  YaoKe
//
//  Created by steaest on 2016/11/1.
//  Copyright © 2016年 YaoKe. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WWImageTagPHPPicker;
@class WWTagImageModel;

@protocol WWImageTagPHPPickerDelegate <NSObject>
@optional
- (void)photoPickerController:(NSArray *)imagearray;
@end

@interface WWImageTagPHPPicker : WWRootViewController
@property (nonatomic, weak) id <WWImageTagPHPPickerDelegate> delegate;
@property (nonatomic, copy) void(^cropBlock)(UIImage *image);
- (instancetype)initWithModel:(WWTagImageModel *)modelArray andTailoringImageArray:(NSArray *)tailoringImageArray andoriginImageArray:(NSArray *)originImageArray andSelectPhotoKey:(NSArray *)selectPhotoKey andPhotoDict:(NSDictionary *)photoDict;
@end
