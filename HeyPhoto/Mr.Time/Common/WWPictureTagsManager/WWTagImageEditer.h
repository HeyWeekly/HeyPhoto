//
//  WWTagImageEditer.h
//  Mr.Time
//
//  Created by steaest on 2017/9/7.
//  Copyright © 2017年 Offape. All rights reserved.
//

#import "WWRootViewController.h"

@class WWTagImageModel;
@class WWTagImageEditer;

/**
 使用文档:
 
 本类是一个给图片打标签的控制器
 用法为两步：
 1.- (instancetype)initWithImage:(UIImage*)image;  来初始化控制器
 2.遵守XER_ImgTagEditerDelegate代理并且实现- (void)editer:(XER_ImgTagEditer*)editer finishEditingWithModel:(XER_ImgTagModel*)model;这个方法，主要生成的数据在model中
 
 备:
 * 本控制器只有给图片加标签的功能，其他上传图片裁切图片的功能是没有的，所以需要外面的父控制器来做
 * 本控制器必须加入到一个nav控制器里面，有大量的push / pop操作
 
 - returns:
 */


@protocol WWTagImageEditerDelegate <NSObject>

- (void)tagedImgEditerWantPoped:(WWTagImageEditer*)editer;

@end

@interface WWTagImageEditer : WWRootViewController
@property (nonatomic, weak) id <WWTagImageEditerDelegate> delegate;
//已经裁剪的数组
@property (nonatomic, strong) NSArray *tailoringImageArray;
//原始图片数组
@property (nonatomic, strong) NSArray *originImageArray;
- (instancetype)initWithTailoringImageArray:(NSArray *)tailoringImageArray andWithOriginImageArray:(NSArray *)originImageArray andModelArray:(WWTagImageModel *)modelArray andSelectPhotoKey:(NSArray *)selectPhotoKey andDidSelectPhotoKey:(NSArray *)didSelectPhotoKey andPhotoDict:(NSDictionary *)photoDict;
@end
