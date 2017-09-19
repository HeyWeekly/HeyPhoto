//
//  WWStikerSeleectVC.h
//  Mr.Time
//
//  Created by 王伟伟 on 2017/9/18.
//  Copyright © 2017年 Offape. All rights reserved.
//

#import "WWRootViewController.h"

@class WWTagedImgLabel;
@class WWStikerSeleectVC;

@protocol XER_ImgTagCabinetDelegate <NSObject>
- (void)cabinet:(WWStikerSeleectVC*)cabinet selectedGoodsWithModel:(id )model;
@end

@interface WWStikerSeleectVC : WWRootViewController
@property (nonatomic, copy, readonly) NSString* tracer;
@property (nonatomic, weak) id <XER_ImgTagCabinetDelegate> delegate;
- (instancetype)initWithGoods:(id)model withSelectGoods_ID:(NSString*)goods_id searchCondition:(WWTagedImgLabel*)label;
@end
