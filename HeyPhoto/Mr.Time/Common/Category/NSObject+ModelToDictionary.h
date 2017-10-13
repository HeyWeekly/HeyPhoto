//
//  NSObject+ModelToDictionary.h
//  YaoKe
//
//  Created by MacroHong on 16/8/11.
//  Copyright © 2016年 YaoKe. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface NSObject (ModelToDictionary)
/**
 *  模型转字典
 *
 *  @return 字典
 */
- (NSDictionary *_Nonnull)dictionaryFromModel;

/**
 *  带model的数组或字典转字典
 *
 *  @param object 带model的数组或字典转
 *
 *  @return 字典
 */
- (id _Nonnull)idFromObject:(nonnull id)object;

/**
 *  数组转json
 */
+ (NSString *_Nullable)ArrayToJSON:(id _Nullable )dictionaryOrArray;
@end
