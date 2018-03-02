# HYCAspect
A usable framework to insert/replace function with AOP Thoughts

Refer to `Aspect` and `JSPatch`

## The difference

Unlike the `aspect` hook way, it hooks the match method directly, which is more likely `JSPatch`.

## Usage

```
#import "HYCAspect.h"
+(HYCAspectDesc *)hookMethodForClass:(NSString *)clz
                            selector:(NSString *)sel
                          methodType:(HYCAspectMethodType)type
                      aspectPosition:(HYCAspectPoistion)pos
                           withBlock:(id)Block;
```

## Examples

Aspect Before:

```
[HYCAspect hookMethodForClass:@"HYCViewController"
                         selector:@"viewDidLoad"
                       methodType:HYCAspectMethodInstance
                   aspectPosition:HYCAspectPoistionBefore
                        withBlock:^(id<HYCAspectInfo>obj){

                            NSLog(@"before ");

}];
```
Aspect After:

```
    [HYCAspect hookMethodForClass:@"HYCViewController"
                         selector:@"viewDidLoad"
                       methodType:HYCAspectMethodInstance
                   aspectPosition:HYCAspectPoistionAfter
                        withBlock:^(id<HYCAspectInfo>obj){

                            NSLog(@"after ");

    }];
    
```

Aspect Instead:

```
[HYCAspect hookMethodForClass:@"HYCViewController"
                         selector:@"testInstanceMethod:"
                       methodType:HYCAspectMethodInstance
                   aspectPosition:HYCAspectPoistionInstead
                        withBlock:^(id<HYCAspectInfo>obj){
                            
                            void *returnValue;
                
                            NSInvocation *invocation = obj.originalInvocation;
                            invocation.selector = [HYCRuntime hyc_selector:NSSelectorFromString(@"testInstanceMethod:") withPrefix:HYCHookMethodPrefix];
                            
                            [invocation invoke];
                            [invocation getReturnValue:&returnValue];
                            
                            NSString *string = (__bridge id)returnValue;
                            string = [NSString stringWithFormat:@"hook %@",string];
                            [invocation setReturnValue:&string];
                            
}];
```


