//
//  WWTagImageCell.h
//  Mr.Time
//
//  Created by 王伟伟 on 2017/10/13.
//  Copyright © 2017年 Offape. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WWTagImageCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *deleteBtn;
@property (nonatomic, assign) NSInteger row;
- (UIView *)snapshotView;
@end
