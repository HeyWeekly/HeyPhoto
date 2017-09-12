//
//  WWTagImageModel.h
//  Mr.Time
//
//  Created by steaest on 2017/9/7.
//  Copyright © 2017年 Offape. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void (^observeBlock)(id newValue,id oldValue);

@interface WWRootModel : NSObject <NSCopying>
- (instancetype)initWithDict:(NSDictionary*)dict;
// 实时监听
- (void)bindingProperty:(NSString*)key WithBlock:(observeBlock)block forIdentify:(NSString*)identify;

@end


@interface WWTagedImgLabel : WWRootModel
@property (nonatomic, copy) NSString* tagText;
@property (nonatomic, strong) NSNumber* direction;
@property (nonatomic, strong) NSNumber* siteX;
@property (nonatomic, strong) NSNumber* siteY;
@property (nonatomic, copy) NSString *itemId;
@property (nonatomic, copy) NSString *tagLink;
@property (nonatomic, copy) NSString *storeId;
@property (nonatomic, copy) NSString *brandId;
@property (nonatomic, copy) NSString *brandName;
@end


@interface WWTagedImgListModel : WWRootModel
@property (nonatomic, copy) NSString* imageUrl;
@property (nonatomic, copy) NSString* sort;
@property (nonatomic, copy) NSString *oneSort;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImageView *oldImageView;
@property (nonatomic, copy) NSArray<WWTagedImgLabel*>* tags;
@end


@interface WWTagImageModel : WWRootModel
@property (nonatomic, copy) NSString* cityId;
@property (nonatomic, copy) NSString *countryId;
@property (nonatomic, copy) NSString* content;
@property (nonatomic, copy) NSArray<WWTagedImgListModel*>* tagImagesList;
@property (nonatomic, copy) NSString* indexImageUrl;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) NSNumber *createTime;
@property (nonatomic, copy  ) NSString *mid;
@property (nonatomic, strong) NSNumber *praise;
@property (nonatomic, copy  ) NSString *userHeadUrl;
@property (nonatomic, copy  ) NSString *userId;
@property (nonatomic, copy  ) NSString *isPraise; /// 是否点赞
@property (nonatomic, copy  ) NSString *username;
@end

