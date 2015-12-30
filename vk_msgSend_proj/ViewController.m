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
    
    [(id<vk_msgSend>)cls vk_callSelector:@selector(testfunction:withB:withH:) error:nil,4,3.5,@"haha"];
    
    id<vk_msgSend> abc = [[cls alloc]init];
    
    NSError *err;
    
    NSString *return1 = [abc vk_callSelector:@selector(testfunction:withB:) error:&err,4,3.5f];
    
    NSNumber *return2 = [[abc class] vk_callSelector:@selector(testfunction:withB:withH:) error:&err,4,3.5,@"haha"];
    NSInteger tureReturn2 = [return2 integerValue];
    // need intValue
    
    NSNumber *return3 = [abc vk_callSelectorName:@"testfunction:withB:withC:" error:&err,4,3.5,@"haha"];
    NSInteger tureReturn3 = [return3 integerValue];
    // need intValue
    
    NSString *return4 = [abc vk_callSelectorName:@"testfunction:withB:withC:withD:" error:nil,4,3.5,nil, CGRectMake(10, 10, 10, 10)];
    
    NSValue *return5 = [abc vk_callSelector:@selector(testfunction:withB:withC:withE:) error:nil,4,3.5,@"haha", NSMakeRange(1, 3)];
    CGRect trueReturn5 = [return5 CGRectValue];
    //need CGRectValue
    
    NSLog(@"that's all");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
