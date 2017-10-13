//
//  WWTagImagePublishVC.h
//  Mr.Time
//
//  Created by 王伟伟 on 2017/10/13.
//  Copyright © 2017年 Offape. All rights reserved.
//

#import "WWRootViewController.h"

@class WWTagImageModel;

@protocol WWTagImagePublishVCDelegate <NSObject>
- (void)pubLishVCPopWithModel:(WWTagImageModel *)model;
@end

@interface WWTagImagePublishVC : WWRootViewController
@property (nonatomic,weak) id <WWTagImagePublishVCDelegate> delegate;
@property (nonatomic, strong) NSArray *imageArray;
- (instancetype)initWithImageArray:(NSArray *)imageArray andMode:(WWTagImageModel *)model andCapImageArray:(NSArray *)capImageArray andSelectPhotoKey:(NSArray *)selectPhotoKey andoriginImageArray:(NSArray *)originImageArray andPhotoDict:(NSDictionary *)photoDict;
@end
