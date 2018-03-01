//
//  HYCAspectCache.m
//  HYCAspect
//
//  Created by eric on 2018/2/26.
//  Copyright © 2018年 eric. All rights reserved.
//

#import "HYCAspectCache.h"

@implementation HYCAspectCache

#pragma mark - Singleton
+(instancetype)shareInstance{
    static HYCAspectCache *shareInstance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        shareInstance = [[HYCAspectCache alloc] init];
    });
    
    return shareInstance;
}

#pragma mark - Lazy Init
-(NSMutableArray *)forbidMethodArray{
    if (!_forbidMethodArray) {
        _forbidMethodArray = [@[] mutableCopy];
    }
    return _forbidMethodArray;
}

-(NSMutableArray *)forbidPrefixArray{
    if (!_forbidPrefixArray) {
        _forbidPrefixArray = [@[] mutableCopy];
    }
    return _forbidPrefixArray;
}

-(NSMutableDictionary *)targetDic{
    if (!_targetDic) {
        _targetDic = [@{} mutableCopy];
    }
    return _targetDic;
}

@end
