//
//  WWTagImageModel.m
//  Mr.Time
//
//  Created by steaest on 2017/9/7.
//  Copyright © 2017年 Offape. All rights reserved.
//

#import "WWTagImageModel.h"

@implementation WWTagedImgLabel
- (instancetype)initWithDict:(NSDictionary *)dict{
    if (self = [super initWithDict:dict]) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}
@end


@implementation WWTagedImgListModel
- (instancetype)initWithDict:(NSDictionary *)dict{
    if (self = [super initWithDict:dict]) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"tags" : [WWTagedImgLabel class]};
}
@end


@implementation WWTagImageModel
- (instancetype)initWithDict:(NSDictionary *)dict{
    if (self = [super initWithDict:dict]) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"tagImagesList" : [WWTagImageModel class]};
}
@end


@interface WWRootModel ()
@property (nonatomic, strong) NSArray<NSString*>* keysHaveRegisted;
@property (nonatomic, strong) NSDictionary<NSString*, NSDictionary<NSString*, observeBlock>*>* observeBlocks;
@property (nonatomic, strong) NSArray* allPropertyNames;
@end

@implementation WWRootModel

- (instancetype)initWithDict:(NSDictionary *)dict{
    if (self = [super init]) {
        if (dict) {
            if ([dict isKindOfClass:[NSDictionary class]]) {
                [self setValuesForKeysWithDictionary:dict];
            }
        }
    }
    return self;
}

+ (NSArray *)modelArrayWithArray:(NSArray *)array{
    NSMutableArray* mArray = [NSMutableArray array];
    for (NSDictionary* dict in array) {
        [mArray addObject:[[[self class] alloc] initWithDict:dict]];
    }
    return mArray.copy;
}

- (instancetype)init{
    if (self = [super init]) {
        NSAssert(0, @"请不要直接使用init,使用initWithDict:(NSDictionary*)dict needCacheImg:(BOOL)cache 作为替换");
    }
    return self;
}

- (void)setValuesForKeysWithDictionary:(NSDictionary<NSString *,id> *)keyedValues{
    [super setValuesForKeysWithDictionary:keyedValues];
}

- (NSArray *)allPropertyNames{
    if (_allPropertyNames == nil) {
        ///存储所有的属性名称
        NSMutableArray *allNames = [[NSMutableArray alloc] init];
        ///存储属性的个数
        unsigned int propertyCount = 0;
        ///通过运行时获取当前类的属性
        Class cls = [self class];
        while (![NSStringFromClass(cls) isEqualToString:@"NSObject"]) {
            objc_property_t *propertys = class_copyPropertyList(cls, &propertyCount);
            //把属性放到数组中
            for (int i = 0; i < propertyCount; i ++) {
                ///取出第一个属性
                objc_property_t property = propertys[i];
                
                const char * propertyName = property_getName(property);
                
                [allNames addObject:[NSString stringWithUTF8String:propertyName]];
            }
            ///释放
            free(propertys);
            cls = [cls superclass];
        }
        _allPropertyNames = allNames.copy;
    }
    return _allPropertyNames;
}

#pragma mark - 图片存储
- (BOOL)keyHaveRegist:(NSString*)key{
    for (NSString* keyhaveregist in self.keysHaveRegisted) {
        if ([key isEqualToString:keyhaveregist] ) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - 关于代理的一些方法
- (void)registMVVMProperty:(NSString*)string{
    if (!self.keysHaveRegisted) {
        self.keysHaveRegisted = [NSArray array];
    }
    if ([self keyHaveRegist:string]) {
        return;
    }
    [self addObserver:self forKeyPath:string options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}

- (void)addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context{
    [super addObserver:observer forKeyPath:keyPath options:options context:context];
    NSMutableArray* mArray = [NSMutableArray arrayWithArray:self.keysHaveRegisted];
    [mArray addObject:keyPath];
    self.keysHaveRegisted = mArray.copy;
}

- (void)removeMVVMProperty:(NSString*)string{
    if (!self.keysHaveRegisted) {
        self.keysHaveRegisted = [NSArray array];
    }
    if (![self keyHaveRegist:string]) {
        return;
    }
    [self removeObserver:self forKeyPath:string];
}

- (void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath{
    [super removeObserver:observer forKeyPath:keyPath];
    NSMutableArray* mArray = [NSMutableArray array];
    for (NSString* key in self.keysHaveRegisted) {
        if (![key isEqualToString:keyPath]) {
            [mArray addObject:key];
        }
    }
    self.keysHaveRegisted = mArray.copy;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    [self postNotifyToDelegateWhenKey:keyPath changedWithNewValue:change[NSKeyValueChangeNewKey] oldValue:change[NSKeyValueChangeOldKey]];
}

- (void)bindingProperty:(NSString*)key WithBlock:(observeBlock)block forIdentify:(NSString*)identify{
    NSAssert([self ownProperty:key], @"并不包含这个属性，请认真检查");
    [self registMVVMProperty:key];
    if (!self.observeBlocks) {
        self.observeBlocks = [NSDictionary dictionary];
    }
    NSMutableDictionary* mDict = [NSMutableDictionary dictionaryWithDictionary:self.observeBlocks];
    if (!mDict[key]) {
        [mDict setObject:[NSDictionary dictionary] forKey:key];
    }
    NSMutableDictionary* mDict2 = [NSMutableDictionary dictionaryWithDictionary:mDict[key]];
    [mDict2 setObject:[block copy] forKey:identify];
    mDict[key] = mDict2.copy;
    self.observeBlocks = mDict.copy;
}


- (BOOL)ownProperty:(NSString*)key{
    for (NSString* name in [self allPropertyNames]) {
        if ([name isEqualToString:key]) {
            return YES;
        }
    }
    return NO;
}

- (void)postNotifyToDelegateWhenKey:(NSString*)key changedWithNewValue:(id)Newvalue oldValue:(id)oldValue{
    if ([self.observeBlocks objectForKey:key]) {
        NSDictionary* dict = self.observeBlocks[key];
        [dict enumerateKeysAndObjectsUsingBlock:^(NSString*  _Nonnull key, observeBlock  _Nonnull obj, BOOL * _Nonnull stop) {
            obj(Newvalue, oldValue);
        }];
    }
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{};

- (id)valueForUndefinedKey:(NSString *)key {return nil;}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    for (NSString* key in self.keysHaveRegisted) {
        @try {
            [self removeObserver:self forKeyPath:key];
        } @catch (NSException *exception) {
            NSLog(@"移除监听出错");
            NSLog(@"%@",exception);
        } @finally {
            
        }
    }
}

- (id)copyWithZone:(NSZone *)zone{
    id instance = [[[self class] allocWithZone:zone] initWithDict:nil];
    for (NSString* key in [self allPropertyNames]) {
        if (![key isEqualToString:@"superclass"] && ![key isEqualToString:@"debugDescription"] && ![key isEqualToString:@"hash"] && ![key isEqualToString:@"description"] && ![key isEqualToString:@"keysHaveRegisted"]) {
            id value = [self valueForKey:key];
            if ([value  respondsToSelector:@selector(copyWithZone:)]) {
                value = [value copy];
            }
            [instance setValue:value forKey:key];
        }
    }
    return instance;
}

@end
