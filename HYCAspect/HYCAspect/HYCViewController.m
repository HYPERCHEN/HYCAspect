//
//  HYCViewController.m
//  HYCAspect
//
//  Created by eric on 2018/3/1.
//  Copyright © 2018年 eric. All rights reserved.
//

#import "HYCViewController.h"
#import "HYCRuntime.h"

@interface HYCViewController ()

@end

@implementation HYCViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    NSLog(@"nslog %@",[self testInstanceMethod:@"21313"]);
    
}

-(NSString *)testInstanceMethod:(NSString *)str{
    
    [super testInstanceMethod:str];

    NSLog(@"HYCViewController testInstanceMethod %@",str);
    
    return [NSString stringWithFormat:@"Class Instance Return : %@",str];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
