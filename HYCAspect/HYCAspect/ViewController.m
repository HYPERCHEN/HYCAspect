//
//  ViewController.m
//  HYCAspect
//
//  Created by eric on 2018/2/26.
//  Copyright © 2018年 eric. All rights reserved.
//

#import "ViewController.h"

#import "HYCViewController.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    NSLog(@"ViewControll viewDidLoad");
    

}

-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
}



-(NSString *)testInstanceMethod:(NSString *)str{
    NSLog(@"ViewController testInstanceMethod %@",str);
    return [NSString stringWithFormat:@"Class Instance Return : %@",str];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
