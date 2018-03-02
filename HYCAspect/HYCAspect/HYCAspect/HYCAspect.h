//
//  HYCAspect.h
//  HYCAspect
//
//  Created by eric on 2018/2/26.
//  Copyright © 2018年 eric. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HYCAspectDesc.h"
#import "HYCAspectCache.h"
#import "HYCRuntime.h"


@interface HYCAspect : NSObject

+(HYCAspectDesc *)hookMethodForClass:(NSString *)clz
                            selector:(NSString *)sel
                          methodType:(HYCAspectMethodType)type
                      aspectPosition:(HYCAspectPoistion)pos
                           withBlock:(id)Block;



                

@end
