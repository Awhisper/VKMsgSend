//
//  ViewController.m
//  vk_msgSend_proj
//
//  Created by Awhisper on 15/12/26.
//  Copyright © 2015年 Awhisper. All rights reserved.
//

#import "ViewController.h"
#import "VKMsgSend.h"
#import <objc/message.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    Class cls = NSClassFromString(@"testClassA");
    
    id abc = [[cls alloc]init];
    
    NSError *err;
    
    //this warning is ok Selector is in testClassA
    NSString *return1 = [abc VKCallSelector:@selector(testfunction:withB:) error:&err,4,3.5f];
    NSLog(@"%@",return1);

    NSNumber *return3 = [abc VKCallSelectorName:@"testfunction:withB:withC:" error:nil,4,3.5,@"haha"];
    NSInteger tureReturn3 = [return3 integerValue];
    NSLog(@"%@",@(tureReturn3));
    
    NSString *return4 = [abc VKCallSelectorName:@"testfunction:withB:withC:withD:" error:nil,4,3.5,nil, CGRectMake(10, 10, 10, 10)];
    NSLog(@"%@",return4);
    
    NSError* testerr2;
    [abc VKCallSelectorName:@"testFunctionError:" error:nil,&testerr2];
    
    NSLog(@"see more test case in XCTest Target");
    NSLog(@"vk_msgSend_projTests");
    
    //这是一段展示 performselector 缺点和不足的代码，有注释中文解释
    [self performShow];
    //这是一段展示 objc_msgsend 缺点和不足的代码，有注释和中文解释
    [self msgsendShow];
    //这是对比展示 VKMsgSend的代码
    [self vkshow];
}


-(void)performShow
{
    
    Class cls = NSClassFromString(@"testClassA");
    
    id abc = [[cls alloc]init];
    
    //-(NSString*)testfunction:(int)num withB:(float)boolv
    NSString * result = [abc performSelector:@selector(testfunction:withB:) withObject:@4 withObject:@3.5];
    //并且只支持id，如果你敢把基础数值类型封装成number传进去，数值还是错乱的
    //这样代码跑进去  int 传了个NSNumber进去 函数内指针全乱，参数值都飞了
    
    //3个参数就不支持了，打开注释你会发现，就没有传3个参数的方法
//    [abc performSelector:@selector(testfunction:withB:withC:) withObject:@4.5 withObject:@3 withObject:@"ssss"];
}

-(void)msgsendShow
{
    Class cls = NSClassFromString(@"testClassA");
    
    id abc = [[cls alloc]init];
//    NSString *result = objc_msgSend(abc, @selector(testfunction:withB:), 4, 3.5);
    
    //很抱歉上面这样的方法，看着用的很方便，但是在iOS 64位下会直接崩溃，xcode8下是直接无法编译
    NSString *result2 =  ((NSString* (*)(id, SEL, int,float))objc_msgSend)(abc, @selector(testfunction:withB:), 4, 3.5);
    
    //看到没必须这么费劲的写一坨C语言的函数指针强转才可以
    
    NSLog(@"11");
}

-(void)vkshow
{
    //理想状态下 旧的 objc_msgSend就已经很方便了，但是已经不能这么用了，那我就封装出了一个runtime工具
    Class cls = NSClassFromString(@"testClassA");
    id abc = [[cls alloc]init];
    NSError * error;
    
    //很方便吧
    [abc VKCallSelectorName:@"testfunction:withB:" error:&error,4,3.5];
    //支持所有基础类型，结构体，id类型，class类型，selector类型，block类型，还有指针类型 **
    
    //如果是使用类方法，还可以直接通过类名NSString
    [@"testClassA" VKCallClassSelectorName:@"testfunction:withB:withH" error:&error,4,3.5,@"aaa"];
    
    //如果是实例方法，可以直接通过类名NSString，调用init selector，哪怕initWithXX:XX:等自定义的初始化函数都可以
    id abcc = [@"testClassA" VKCallClassAllocInitSelectorName:@"init" error:nil];
    //省去了手写NSClassFromString 的事情
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
