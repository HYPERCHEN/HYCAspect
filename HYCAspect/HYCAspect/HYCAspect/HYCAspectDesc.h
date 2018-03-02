//
//  HYCAspectDesc.h
//  HYCAspect
//
//  Created by eric on 2018/2/26.
//  Copyright © 2018年 eric. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HYCAspectDesc;

typedef NS_ENUM(NSInteger,HYCAspectMethodType){
    HYCAspectMethodInstance,
    HYCAspectMethodClass
};

typedef NS_ENUM(NSInteger,HYCAspectPoistion){
    HYCAspectPoistionBefore,
    HYCAspectPoistionAfter,
    HYCAspectPoistionInstead
};

static NSString *HYCHookMethodPrefix = @"_hz_hyc_";

@protocol HYCAspectInfo

/// The instance that is currently hooked.
- (id)instance;

/// The original invocation of the hooked method.
- (NSInvocation *)originalInvocation;

/// All method arguments, boxed. This is lazily evaluated.
- (NSArray *)arguments;

- (SEL) originSelector;

@end

#pragma mark - HYCAspectInfo

@interface HYCAspectInfo : NSObject <HYCAspectInfo>

- (id)initWithInstance:(__unsafe_unretained id)instance
            invocation:(NSInvocation *)invocation;

@property (nonatomic, unsafe_unretained, readonly) id instance;

@property (nonatomic,assign)SEL originSelector;

@property (nonatomic, strong, readonly) NSInvocation *originalInvocation;

@end

#pragma mark - HYCAspectDesc

@interface HYCAspectDesc : NSObject

+(instancetype)initDescWithSelector:(SEL)selector
                              Class:(Class)clz
                              block:(id)block
                        
                         methodType:(HYCAspectMethodType)type
                     aspectPosition:(HYCAspectPoistion)position;

@property(nonatomic,assign)SEL selector;

@property(nonatomic,assign)Class clz;

@property(nonatomic,strong)id block;

@property(nonatomic,strong)NSMethodSignature *blockSignature;

@property(nonatomic,assign)HYCAspectMethodType type;

@property(nonatomic,assign)HYCAspectPoistion poistion;

- (BOOL)invokeWithInfo:(id<HYCAspectInfo>)info;

+(NSString *)getSelectorKey:(SEL)sel class:(Class)clz withType:(HYCAspectMethodType)type;

@end

#pragma mark - HYCAspectContainer

@interface HYCAspectContainer : NSObject

@property(nonatomic,strong)NSMutableArray<HYCAspectDesc *> *beforeAspects;
@property(nonatomic,strong)NSMutableArray<HYCAspectDesc *> *insteadAspects;
@property(nonatomic,strong)NSMutableArray<HYCAspectDesc *> *afterAspects;

+(instancetype)initContainer;

@end



