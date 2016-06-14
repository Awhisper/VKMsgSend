//
//  VKMsgSend_projTests.m
//  VKMsgSend_projTests
//
//  Created by Awhisper on 16/1/7.
//  Copyright © 2016年 Awhisper. All rights reserved.
//

#import <XCTest/XCTest.h>
//#import "NSObject+VKMsgSend.h"
#import "testClassA.h"
#import "VKMsgSend.h"
@interface VKMsgSend_projTests : XCTestCase

@end

@implementation VKMsgSend_projTests

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
    
    NSNumber* clsreturn = [(id)cls VKCallSelector:@selector(testfunction:withB:withH:) error:nil,4,3.5,@"haha"];
    XCTAssertEqual([clsreturn intValue], 1);
    
    NSNumber* clsreturn2 = [@"testClassA" VKCallClassSelector:@selector(testfunction:withB:withH:) error:nil,4,3.5,@"haha"];
    XCTAssertEqual([clsreturn2 intValue], 1);
    
    NSNumber* clsreturn3 = [@"testClassA" VKCallClassSelectorName:@"testfunction:withB:withH:" error:nil,4,3.5,@"haha"];
    XCTAssertEqual([clsreturn3 intValue], 1);
    
    
    
    NSNumber* clsallocreturn1 = [@"testClassA" VKCallClassAllocInitSelector:@selector(testfunction:withB:withC:) error:nil,4,3.5,@"haha"];
    XCTAssertEqual([clsallocreturn1 intValue], 1);
    
    NSNumber* clsallocreturn2 = [@"testClassA" VKCallClassAllocInitSelectorName:@"testfunction:withB:withC:" error:nil,4,3.5,@"haha"];
    XCTAssertEqual([clsallocreturn2 intValue], 1);
    
    NSError *clsreturnError;
    NSNumber* clsreturn4 = [@"testClassAA" VKCallClassSelectorName:@"testfunction:withB:withH:" error:&clsreturnError,4,3.5,@"haha"];
    XCTAssert(clsreturnError);
    
    id abc = [[cls alloc]init];
    
    NSError *err;
    
    NSString *return1 = [abc VKCallSelector:@selector(testfunction:withB:) error:&err,4,3.5f];
    XCTAssert([return1 isEqualToString:@"hello"]);
    
    NSNumber *return2 = [[abc class] VKCallSelector:@selector(testfunction:withB:withH:) error:nil,4,3.5,@"haha"];
    NSInteger tureReturn2 = [return2 integerValue];
    XCTAssertEqual(tureReturn2, 1);
    
    NSNumber *return3 = [abc VKCallSelectorName:@"testfunction:withB:withC:" error:nil,4,3.5,@"haha"];
    NSInteger tureReturn3 = [return3 integerValue];
    XCTAssertEqual(tureReturn3, 1);
    
    NSString *return4 = [abc VKCallSelectorName:@"testfunction:withB:withC:withD:" error:nil,4,3.5,nil, CGRectMake(10, 10, 10, 10)];
    XCTAssert([return4 isEqualToString:@"hello"]);
    
    NSValue *return5 = [abc VKCallSelector:@selector(testfunction:withB:withC:withE:) error:nil,4,3.5,@"haha", NSMakeRange(1, 3)];
    CGRect trueReturn5 = [return5 CGRectValue];
    XCTAssert(CGRectEqualToRect(trueReturn5, CGRectZero));
    
    
    SEL argsel = @selector(testwoooo);
    NSString* return6 = [abc VKCallSelector:@selector(testFunctionWithSEL:) error:nil,argsel];
    XCTAssert([return6 isEqualToString:NSStringFromSelector(argsel)]);
    //写个匿名block 然后传进去
    void(^tempblock)(void)  = ^(void){
        NSLog(@"==== block run ====");
    };
    [abc VKCallSelector:@selector(testFunctionWithBlock:) error:nil,tempblock];
    
    [abc VKCallSelector:@selector(testFunctionCallBlock) error:nil];
    
    
    
    NSMutableArray* testerr = [[NSMutableArray alloc]init];
    [abc VKCallSelector:@selector(testFunctionIDStar:) error:nil,&testerr];
    XCTAssert(testerr.count>0);
    
    
    NSString *teststr = @"hello";
    Class stringcls = [teststr class];
    NSNumber *isCls = [abc VKCallSelectorName:@"testFunctionObject:isKindOfClass:" error:nil,teststr,stringcls];
    BOOL isClsBool = [isCls boolValue];
    XCTAssertEqual(isClsBool, 1);
    
//    NSError* testerr2;
//    [abc VKCallSelector:@selector(testFunctionError:) error:nil,&testerr2];
//    XCTAssert(testerr2);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
