//
//  HYCAspectCache.h
//  HYCAspect
//
//  Created by eric on 2018/2/26.
//  Copyright © 2018年 eric. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HYCAspectCache : NSObject

@property(nonatomic,strong)NSMutableArray *forbidPrefixArray;

@property(nonatomic,strong)NSMutableArray *forbidMethodArray;

@property(nonatomic,strong)NSMutableDictionary *targetDic;

+(instancetype)shareInstance;

@end
