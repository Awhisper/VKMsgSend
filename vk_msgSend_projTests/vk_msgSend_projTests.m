//
//  vk_msgSend_projTests.m
//  vk_msgSend_projTests
//
//  Created by Awhisper on 16/1/7.
//  Copyright © 2016年 Awhisper. All rights reserved.
//

#import <XCTest/XCTest.h>
//#import "NSObject+vk_msgSend.h"
#import "testClassA.h"
#import "vk_msgSend.h"
@interface vk_msgSend_projTests : XCTestCase

@end

@implementation vk_msgSend_projTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    
    
    Class cls = NSClassFromString(@"testClassA");
    
    NSNumber* clsreturn = [(id<vk_msgSend>)cls vk_callSelector:@selector(testfunction:withB:withH:) error:nil,4,3.5,@"haha"];
    XCTAssertEqual([clsreturn intValue], 1);
    
    id<vk_msgSend> abc = [[cls alloc]init];
    
    NSError *err;
    
    NSString *return1 = [abc vk_callSelector:@selector(testfunction:withB:) error:&err,4,3.5f];
    XCTAssert([return1 isEqualToString:@"hello"]);
    
    NSNumber *return2 = [[abc class] vk_callSelector:@selector(testfunction:withB:withH:) error:nil,4,3.5,@"haha"];
    NSInteger tureReturn2 = [return2 integerValue];
    XCTAssertEqual(tureReturn2, 1);
    
    NSNumber *return3 = [abc vk_callSelectorName:@"testfunction:withB:withC:" error:nil,4,3.5,@"haha"];
    NSInteger tureReturn3 = [return3 integerValue];
    XCTAssertEqual(tureReturn3, 1);
    
    NSString *return4 = [abc vk_callSelectorName:@"testfunction:withB:withC:withD:" error:nil,4,3.5,nil, CGRectMake(10, 10, 10, 10)];
    XCTAssert([return4 isEqualToString:@"hello"]);
    
    NSValue *return5 = [abc vk_callSelector:@selector(testfunction:withB:withC:withE:) error:nil,4,3.5,@"haha", NSMakeRange(1, 3)];
    CGRect trueReturn5 = [return5 CGRectValue];
    XCTAssert(CGRectEqualToRect(trueReturn5, CGRectZero));
    
    
    SEL argsel = @selector(testwoooo);
    NSString* return6 = [abc vk_callSelector:@selector(testFunctionWithSEL:) error:nil,argsel];
    XCTAssert([return6 isEqualToString:NSStringFromSelector(argsel)]);
    //写个匿名block 然后传进去
    void(^tempblock)(void)  = ^(void){
        NSLog(@"==== block run ====");
    };
    [abc vk_callSelector:@selector(testFunctionWithBlock:) error:nil,tempblock];
    
    [abc vk_callSelector:@selector(testFunctionCallBlock) error:nil];
    
    
    
    NSMutableArray* testerr = [[NSMutableArray alloc]init];
    [abc vk_callSelector:@selector(testFunctionIDStar:) error:nil,&testerr];
    XCTAssert(testerr.count>0);
    
    
    NSString *teststr = @"hello";
    Class stringcls = [teststr class];
    NSNumber *isCls = [abc vk_callSelectorName:@"testFunctionObject:isKindOfClass:" error:nil,teststr,stringcls];
    BOOL isClsBool = [isCls boolValue];
    XCTAssertEqual(isClsBool, 1);
    
//    NSError* testerr2;
//    [abc vk_callSelector:@selector(testFunctionError:) error:nil,&testerr2];
//    XCTAssert(testerr2);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
