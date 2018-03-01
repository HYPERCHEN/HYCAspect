//
//  HYCRuntime.h
//  HYCAspect
//
//  Created by eric on 2018/2/26.
//  Copyright © 2018年 eric. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <objc/message.h>

@interface HYCRuntime : NSObject

+ (SEL)hyc_selector:(SEL)selector withPrefix:(NSString *)prefix;

+ (const char *)getBlockMethodSignature:(id)block;

+ (NSInvocation *)invocationWithBaseInvocation:(NSInvocation *)baseInvocation
                                  targetObject:(id)object;


+ (Class)rootClassForInstanceRespondsToClass:(Class)clazz selector:(SEL)selector;

+ (Class)rootClassForClassRespondsToClass:(Class)clazz selector:(SEL)selector;

+ (BOOL)hasInstanceMethodForClass:(Class)clazz selector:(SEL)selector;

+ (BOOL)hasClassMethodForClass:(Class)clazz selector:(SEL)selector;

+ (BOOL)copyInstanceMethodForClass:(Class)clazz
                        atSelector:(SEL)selector
                        toSelector:(SEL)copySelector;

+ (BOOL)copyClassMethodForClass:(Class)clazz
                     atSelector:(SEL)selector
                     toSelector:(SEL)copySelector;

+ (void)overwritingMessageForwardInstanceMethodForClass:(Class)clazz selector:(SEL)selector withImp:(IMP)imp;

+ (void)overwritingMessageForwardClassMethodForClass:(Class)clazz selector:(SEL)selector withImp:(IMP)imp;


+ (void)overwritingMessageForwardInstanceMethodForClass:(Class)clazz selector:(SEL)selector;

+ (void)overwritingMessageForwardClassMethodForClass:(Class)clazz selector:(SEL)selector;

@end

#pragma mark - HYCBlock

typedef NS_OPTIONS(int, HYCBlockFlags){
    HYCBlockFlagsHasCopyDisposeHelpers = (1 << 25),
    HYCBlockFlagsHasSignature          = (1 << 30)
};

typedef struct HYCBlock{
    
    __unused Class isa;
    HYCBlockFlags flags;
    __unused int reserved;
    void (__unused *invoke)(struct HYCBlock *block, ...);
    
    struct{
        unsigned long int reserved;
        unsigned long int size;
        // requires HYCBlockFlagsHasCopyDisposeHelpers
        void (*copy)(void *dst, const void *src);
        void (*dispose)(const void *);
        // requires HYCBlockFlagsHasSignature
        const char *signature;
        const char *layout;
    } *descriptor;
    
} *HYCBlockRef;




























