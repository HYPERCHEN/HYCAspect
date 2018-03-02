//
//  HYCAspectDesc.m
//  HYCAspect
//
//  Created by eric on 2018/2/26.
//  Copyright © 2018年 eric. All rights reserved.
//

#import "HYCAspectDesc.h"
#import "HYCRuntime.h"

#pragma mark - HYCAspectInfo

@implementation HYCAspectInfo

- (id)initWithInstance:(__unsafe_unretained id)instance invocation:(NSInvocation *)invocation{

    if (self = [super init]) {
        _instance = instance;
        _originalInvocation = invocation;
    }
    
    return self;
}

@end

#pragma mark - HYCAspectDesc

@implementation HYCAspectDesc

+(instancetype)initDescWithSelector:(SEL)selector
                              Class:(Class)clz
                              block:(id)block
                         methodType:(HYCAspectMethodType)type
                     aspectPosition:(HYCAspectPoistion)position{
    
    HYCAspectDesc *desc = [[HYCAspectDesc alloc] init];
    
    desc.selector = selector;
    desc.clz = clz;
    desc.block = block;
    
    NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes: [HYCRuntime getBlockMethodSignature:block]];
    
    desc.blockSignature = signature;
    
    desc.type = type;
    desc.poistion = position;
    
    return desc;
    
}

+(NSString *)getSelectorKey:(SEL)sel class:(Class)clz withType:(HYCAspectMethodType)type{
    return [NSString stringWithFormat:@"%@[%@ %@]",type == HYCAspectMethodClass?@"+":@"-",NSStringFromClass(clz),NSStringFromSelector(sel)];
}

- (BOOL)invokeWithInfo:(id<HYCAspectInfo>)info {
    
    NSInvocation *blockInvocation = [NSInvocation invocationWithMethodSignature:self.blockSignature];
    
    NSInvocation *originalInvocation = info.originalInvocation;
    
    NSUInteger numberOfArguments = self.blockSignature.numberOfArguments;
    
    // Be extra paranoid. We already check that on hook registration.
    if (numberOfArguments > originalInvocation.methodSignature.numberOfArguments) {
        return NO;
    }
    
    // The `self` of the block will be the AspectInfo. Optional.
    if (numberOfArguments > 1) {
        [blockInvocation setArgument:&info atIndex:1];
    }
    
    void *argBuf = NULL;
    for (NSUInteger idx = 2; idx < numberOfArguments; idx++) {
        const char *type = [originalInvocation.methodSignature getArgumentTypeAtIndex:idx];
        NSUInteger argSize;
        NSGetSizeAndAlignment(type, &argSize, NULL);
        
        if (!(argBuf = reallocf(argBuf, argSize))) {
           
            return NO;
        }
        
        [originalInvocation getArgument:argBuf atIndex:idx];
        [blockInvocation setArgument:argBuf atIndex:idx];
    }
   
    
    [blockInvocation invokeWithTarget:self.block];
    
    if (argBuf != NULL) {
        free(argBuf);
    }
    return YES;
}

@end

#pragma mark - HYCAspectContainer

@implementation HYCAspectContainer

+(instancetype)initContainer{
    HYCAspectContainer *container = [HYCAspectContainer new];
    container.beforeAspects  = [@[] mutableCopy];
    container.insteadAspects = [@[] mutableCopy];
    container.afterAspects   = [@[] mutableCopy];
    return container;
}



@end
