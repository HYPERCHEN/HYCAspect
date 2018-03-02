//
//  HYCRuntime.m
//  HYCAspect
//
//  Created by eric on 2018/2/26.
//  Copyright © 2018年 eric. All rights reserved.
//

#import "HYCRuntime.h"

@implementation HYCRuntime

+ (Class)rootClassForInstanceRespondsToClass:(Class)clazz selector:(SEL)selector
{
    if (![HYCRuntime hasInstanceMethodForClass:clazz
                                      selector:selector]) {
        return nil;
    } else if ([HYCRuntime hasInstanceMethodForClass:class_getSuperclass(clazz)
                                            selector:selector]) {
        return [self rootClassForInstanceRespondsToClass:class_getSuperclass(clazz)
                                                selector:selector];
    }
    
    return clazz;
}

+ (Class)rootClassForClassRespondsToClass:(Class)clazz selector:(SEL)selector
{
    if (![HYCRuntime hasClassMethodForClass:clazz
                                   selector:selector]) {
        return nil;
    } else if ([HYCRuntime hasClassMethodForClass:class_getSuperclass(clazz)
                                         selector:selector]) {
        return [self rootClassForClassRespondsToClass:class_getSuperclass(clazz)
                                             selector:selector];
    }
    
    return clazz;
}

+ (BOOL)hasInstanceMethodForClass:(Class)clazz selector:(SEL)selector
{
    return class_getInstanceMethod(clazz, selector) != nil;
}

+ (BOOL)hasClassMethodForClass:(Class)clazz selector:(SEL)selector
{
    return class_getClassMethod(clazz, selector) != nil;
}

+ (SEL)hyc_selector:(SEL)selector withPrefix:(NSString *)prefix{
       return NSSelectorFromString([NSString stringWithFormat:@"%@%@", prefix, NSStringFromSelector(selector)]);
}

+ (BOOL)copyInstanceMethodForClass:(Class)clazz
                        atSelector:(SEL)selector
                        toSelector:(SEL)copySelector
{
    return class_addMethod(clazz,
                           copySelector,
                           method_getImplementation(class_getInstanceMethod(clazz, selector)),
                           method_getTypeEncoding(class_getInstanceMethod(clazz, selector)));
}

+ (BOOL)copyClassMethodForClass:(Class)clazz
                     atSelector:(SEL)selector
                     toSelector:(SEL)copySelector
{
    return class_addMethod(clazz,
                           copySelector,
                           method_getImplementation(class_getClassMethod(clazz, selector)),
                           method_getTypeEncoding(class_getClassMethod(clazz, selector)));
}

+ (void)overwritingMessageForwardInstanceMethodForClass:(Class)clazz selector:(SEL)selector withImp:(IMP)imp
{
    Method instanceMethod = class_getInstanceMethod(clazz, selector);
    method_setImplementation(instanceMethod, imp);
}

+ (void)overwritingMessageForwardClassMethodForClass:(Class)clazz selector:(SEL)selector withImp:(IMP)imp
{
    Method classMethod = class_getClassMethod(clazz, selector);
    method_setImplementation(classMethod, imp);
}

+ (void)overwritingMessageForwardInstanceMethodForClass:(Class)clazz selector:(SEL)selector
{
    Method instanceMethod = class_getInstanceMethod(clazz, selector);
    method_setImplementation(instanceMethod, [self msgForwardIMPWithMethod:instanceMethod]);
}

+ (void)overwritingMessageForwardClassMethodForClass:(Class)clazz selector:(SEL)selector
{
    Method classMethod = class_getClassMethod(clazz, selector);
    method_setImplementation(classMethod, [self msgForwardIMPWithMethod:classMethod]);
}

+ (const char *)getBlockMethodSignature:(id)block{
    
    HYCBlockRef blockRef = (__bridge void *)block;

    if (!(blockRef -> flags & HYCBlockFlagsHasSignature)){
        //NSString *description = [NSString stringWithFormat:@"The block %@ doesn't contain a type signature.", block];
        return nil;
    }

    void *desc = blockRef->descriptor;
    desc += 2 * sizeof(unsigned long int);
    if (blockRef ->flags & HYCBlockFlagsHasCopyDisposeHelpers) {
        desc += 2 *sizeof(void *);
    }

    if (!desc) {
        //NSString *description = [NSString stringWithFormat:@"The block %@ doesn't has a type signature.", block];
        return nil;
    }
    
    const char *signature = (*(const char* *)desc);
    
    return signature;
    
}

+ (NSInvocation *)invocationWithBaseInvocation:(NSInvocation *)baseInvocation
                                  targetObject:(id)object
{
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:baseInvocation.methodSignature];
    
    [invocation setArgument:(__bridge void *)(object) atIndex:0];
    
    void *argp = NULL;
    
    for (NSUInteger idx = 2; idx < baseInvocation.methodSignature.numberOfArguments; idx++) {
        const char *type = [baseInvocation.methodSignature getArgumentTypeAtIndex:idx];
        NSUInteger argSize;
        NSGetSizeAndAlignment(type, &argSize, NULL);
        if (!(argp = reallocf(argp, argSize))) {
            //            MOAspectsErrorLog(@"missing create invocation");
            return nil;
        }
        [baseInvocation getArgument:argp atIndex:idx];
        [invocation setArgument:argp atIndex:idx];
    }
    
    if (argp != NULL) {
        free(argp);
    }
    return invocation;
}

+(IMP)msgForwardIMPWithMethod:(Method)method{
    
    IMP msgForwardImp = _objc_msgForward;
    
#if !defined(__arm64__)
    const char *encoding = method_getTypeEncoding(method);
    BOOL methodReturnsStructValue = encoding[0] == _C_STRUCT_B;
    if (methodReturnsStructValue) {
        @try {
            NSUInteger valueSize = 0;
            NSGetSizeAndAlignment(encoding, &valueSize, NULL);
            
            if (valueSize == 1 || valueSize == 2 || valueSize == 4 || valueSize == 8) {
                methodReturnsStructValue = NO;
            }
        } @catch (NSException *e) {}
    }
    if (methodReturnsStructValue) {
        msgForwardImp = (IMP)_objc_msgForward_stret;
    }
#endif
    
    return msgForwardImp;
}

@end
