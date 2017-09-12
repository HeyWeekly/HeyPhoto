//
//  WWTagImageLayer.h
//  Mr.Time
//
//  Created by steaest on 2017/9/8.
//  Copyright © 2017年 Offape. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WWTagImageLayerDelegate <NSObject>
- (void)tagDoneText:(NSString *)text;
@end

@interface WWTagImageLayer : UIView
@property (nonatomic, weak) id<WWTagImageLayerDelegate> delegate;
-(instancetype)initWithImageArray:(NSArray *)imageArray;
@end
