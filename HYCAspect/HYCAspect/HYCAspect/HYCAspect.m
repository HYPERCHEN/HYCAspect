//
//  HYCAspect.m
//  HYCAspect
//
//  Created by eric on 2018/2/26.
//  Copyright © 2018年 eric. All rights reserved.
//

#import "HYCAspect.h"

@implementation HYCAspect


+(BOOL)hookMethodForClass:(NSString *)clzstr
               selector:(NSString *)selstr
             methodType:(HYCAspectMethodType)methodType
         aspectPosition:(HYCAspectPoistion)pos
                withBlock:(id)block{
    
    Class clazz = NSClassFromString(clzstr);
    SEL sel = NSSelectorFromString(selstr);

    BOOL isAbleHooked = [self isAbleHooked:clazz selector:sel methodType:methodType];
    if (!isAbleHooked) {
        return NO;
    }
    
    Class tempRootClass;

    NSString *key = [HYCAspectDesc getSelectorKey:sel class:clazz withType:methodType];

   
        
        Class rootResponderClassForForwardInvocation = [self rootClassForResponodsToClass:clazz
                                                                         selector:@selector(forwardInvocation:)
                                                                           methodType:methodType];
    
        if (![self putMethodForClass:clazz
                            selector:@selector(forwardInvocation:)
                          methodTyoe:methodType]) {
            return NO;
        }
        
        Class rootResponderClassForSelector = [self rootClassForResponodsToClass:clazz
                                                                                 selector:sel
                                                                               methodType:methodType];
    

    
        if ([self putMethodForClass:clazz
                            selector:sel
                          methodTyoe:methodType]) {
            [self overwritingMessageForwardMethodForClass:clazz selector:sel methodType:methodType];
        }else{
            return NO;
        }
    
        
    [self overwritingMethodForClass:clazz selector:@selector(forwardInvocation:) methodType:methodType withImp:(void *)__ASPECTS_ARE_BEING_CALLED__];
        
 
    
    HYCAspectDesc *desc = [HYCAspect getAspectDescWithClass:clazz
                                                   selector:sel
                                                 methodType:methodType
                                             aspectPosition:pos
                                                      block:block];
    
    
    return  YES;
}


#define aspect_invoke(aspects, info) \
for (HYCAspectDesc *aspect in aspects) {\
[aspect invokeWithInfo:info];\
}

static void __ASPECTS_ARE_BEING_CALLED__(id obj, SEL selector, NSInvocation *invocation) {
    
    NSString *key = [HYCAspect getAspectDicKey:obj withInvocation:invocation];

    HYCAspectContainer *container = [HYCAspect getContainerWithKey:key];

    SEL aspectSelector = [HYCRuntime hyc_selector:invocation.selector withPrefix:HYCHookMethodPrefix];

    HYCAspectInfo *info = [[HYCAspectInfo alloc] initWithInstance:obj invocation:invocation];

    if (container) {

        aspect_invoke(container.beforeAspects, info);

        if (container.insteadAspects.count == 0) {
            invocation.selector = aspectSelector;
            [invocation invoke];
        }else{
            aspect_invoke(container.insteadAspects, info);
        }
        
        aspect_invoke(container.afterAspects, info);

    }else{

        invocation.selector = [HYCRuntime hyc_selector:@selector(forwardInvocation:) withPrefix:HYCHookMethodPrefix];

        [invocation invoke];

    }
    
}

+(HYCAspectContainer *)getContainerWithKey:(NSString *)key{
    HYCAspectContainer *container;
   
    
    if ([[HYCAspectCache shareInstance].targetDic.allKeys containsObject:key]) {
        container = [HYCAspectCache shareInstance].targetDic[key];
    }
    return container;
}

+(NSString *)getAspectDicKey:(id)obj withInvocation:(NSInvocation *)invocation{
    
    BOOL isClass = object_isClass(obj);
    
    SEL selector = invocation.selector;
    
    HYCAspectMethodType type = isClass ? HYCAspectMethodClass : HYCAspectMethodInstance;
    
    Class rootResponderClass = [HYCAspect rootClassForResponodsToClass:[obj class]
                                                                                                             selector:selector
                                                                                                           methodType:type];
    rootResponderClass = [obj class];
    
    return  [HYCAspectDesc getSelectorKey:selector class:rootResponderClass withType:type];
    
}

+ (void)overwritingMethodForClass:(Class)clazz
                        selector:(SEL)selector
                      methodType:(HYCAspectMethodType)methodType
                             withImp:(IMP)imp
{
    if (methodType == HYCAspectMethodClass) {
        return [HYCRuntime overwritingMessageForwardClassMethodForClass:clazz selector:selector withImp:imp];
    } else {
        return [HYCRuntime overwritingMessageForwardInstanceMethodForClass:clazz selector:selector withImp:imp];
    }
}


+ (void)overwritingMessageForwardMethodForClass:(Class)clazz
                                       selector:(SEL)selector
                                     methodType:(HYCAspectMethodType)methodType
{
    if (methodType == HYCAspectMethodClass) {
        return [HYCRuntime overwritingMessageForwardClassMethodForClass:clazz selector:selector];
    } else {
        return [HYCRuntime overwritingMessageForwardInstanceMethodForClass:clazz selector:selector];
    }
}

+ (BOOL)putMethodForClass:(Class)clazz selector:(SEL)selector methodTyoe:(HYCAspectMethodType)methodType
{
    SEL aspectsSelector = [HYCRuntime hyc_selector:selector withPrefix:HYCHookMethodPrefix];
    
    if (![self hasMethodForClass:clazz selector:aspectsSelector methodType:methodType]) {
        
        if (![self copyMethodForClass:clazz atSelector:selector toSelector:aspectsSelector methodType:methodType])
        {
            
           
            return NO;
        }
    }
    
    return YES;
}

+ (BOOL)copyMethodForClass:(Class)clazz
                atSelector:(SEL)selector
                toSelector:(SEL)copySelector
                methodType:(HYCAspectMethodType)methodType
{
    if (methodType == HYCAspectMethodClass) {
        return [HYCRuntime copyClassMethodForClass:clazz atSelector:selector toSelector:copySelector];
    } else {
        return [HYCRuntime copyInstanceMethodForClass:clazz atSelector:selector toSelector:copySelector];
    }
}

+ (Class)rootClassForResponodsToClass:(Class)clazz selector:(SEL)selector methodType:(HYCAspectMethodType)methodType
{
    if (methodType == HYCAspectMethodClass) {
        return [HYCRuntime rootClassForClassRespondsToClass:clazz selector:selector];
    } else {
        return [HYCRuntime rootClassForInstanceRespondsToClass:clazz selector:selector];
    }
}

+ (BOOL)hasMethodForClass:(Class)clazz selector:(SEL)selector methodType:(HYCAspectMethodType)methodType
{
    if (methodType == HYCAspectMethodClass) {
        return [HYCRuntime hasClassMethodForClass:clazz selector:selector];
    } else {
        return [HYCRuntime hasInstanceMethodForClass:clazz selector:selector];
    }
}

+(HYCAspectDesc *)getAspectDescWithClass:(Class)clz selector:(SEL)sel methodType:(HYCAspectMethodType)type aspectPosition:(HYCAspectPoistion)poistion block:(id)block{
    
    // -[ViewController getNumber]
    NSString *key = [HYCAspectDesc getSelectorKey:sel class:clz withType:type];
    
    // Get Desc Model
    HYCAspectDesc *desc = [HYCAspectDesc initDescWithSelector:sel
                                                        Class:clz
                                                        block:block
                                                   methodType:type
                                               aspectPosition:poistion];
    
    
    
    if ([[HYCAspectCache shareInstance].targetDic.allKeys containsObject:key]) {
        
        HYCAspectContainer *container = [HYCAspectCache shareInstance].targetDic[key];
        
        switch (poistion) {
            case HYCAspectPoistionBefore:
            {
                [container.beforeAspects addObject:desc];
            }
                break;
            case HYCAspectPoistionInstead:
            {
                [container.insteadAspects addObject:desc];
            }
                break;
            case HYCAspectPoistionAfter:
            {
                [container.afterAspects addObject:desc];
            }
                break;
        }
        
    }else{
        
        HYCAspectContainer *container = [HYCAspectContainer initContainer];
        
        switch (poistion) {
            case HYCAspectPoistionBefore:
            {
                [container.beforeAspects addObject:desc];
            }
                break;
            case HYCAspectPoistionInstead:
            {
                 [container.insteadAspects addObject:desc];
            }
                break;
            case HYCAspectPoistionAfter:
            {
                 [container.afterAspects addObject:desc];
            }
                break;
        }
        
        [HYCAspectCache shareInstance].targetDic[key] = container;
    }
    
    return desc;
}



+(BOOL)isAbleHooked:(Class)clz selector:(SEL)sel methodType:(HYCAspectMethodType)methodType{
    
    if (!clz) {
        return NO;
    }
    
    if (!sel) {
        return NO;
    }
    
    NSString *selName = NSStringFromSelector(sel);
    if ([self isHaveForbidPreFix:selName]) {
        return NO;
    }
    
    if ([self isHaveForbidMethod:selName]) {
        return NO;
    }
    
    if (![self hasSelector:sel inClass:clz withMethodType:methodType]) {
        return NO;
    }
    
    return  YES;
    
}

+(BOOL)hasSelector:(SEL)sel inClass:(Class)clz withMethodType:(HYCAspectMethodType)type{
    
    return YES;
    
}

+(BOOL)isHaveForbidPreFix:(NSString *)selName{
    __block BOOL isHaveForbidPrefix = NO;
    [[HYCAspectCache shareInstance].forbidPrefixArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *prefix = (NSString *)obj;
        if ([selName hasPrefix:prefix]) {
            isHaveForbidPrefix = YES;
        }
    }];
    return isHaveForbidPrefix;
}

+(BOOL)isHaveForbidMethod:(NSString *)selName{
    __block BOOL isHaveForbidMethod = NO;
    [[HYCAspectCache shareInstance].forbidPrefixArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *forbidMethod = (NSString *)obj;
        if ([selName isEqualToString:forbidMethod]) {
            isHaveForbidMethod = YES;
        }
    }];
    return isHaveForbidMethod;
}







@end
