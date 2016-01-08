//
//  ViewController.m
//  vk_msgSend_proj
//
//  Created by Awhisper on 15/12/26.
//  Copyright © 2015年 Awhisper. All rights reserved.
//

#import "ViewController.h"
#import "vk_msgSend.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    Class cls = NSClassFromString(@"testClassA");
    
    id<vk_msgSend> abc = [[cls alloc]init];
    
    NSError *err;
    
    //this warning is ok Selector is in testClassA
    NSString *return1 = [abc vk_callSelector:@selector(testfunction:withB:) error:&err,4,3.5f];
    NSLog(@"%@",return1);

    NSNumber *return3 = [abc vk_callSelectorName:@"testfunction:withB:withC:" error:nil,4,3.5,@"haha"];
    NSInteger tureReturn3 = [return3 integerValue];
    NSLog(@"%@",@(tureReturn3));
    
    NSString *return4 = [abc vk_callSelectorName:@"testfunction:withB:withC:withD:" error:nil,4,3.5,nil, CGRectMake(10, 10, 10, 10)];
    NSLog(@"%@",return4);
    
    
    NSLog(@"see more test case in XCTest Target");
    NSLog(@"vk_msgSend_projTests");
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
