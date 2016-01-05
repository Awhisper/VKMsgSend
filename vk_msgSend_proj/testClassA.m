//
//  testClassA.m
//  IdSelectorCall
//
//  Created by Awhisper on 15/12/25.
//  Copyright © 2015年 Awhisper. All rights reserved.
//

#import "testClassA.h"
#import <UIKit/UIKit.h>

typedef void(^blockType)(void);
@interface testClassA ()

@property(nonatomic,copy) blockType block;

@end

@implementation testClassA

+(NSInteger)testfunction:(int)num withB:(float)boolv withH:(NSString*)str{
    return 1;
}

-(NSString*)testfunction:(int)num withB:(float)boolv{
    NSLog(@"I'm testfunction: withB:");
    return @"hello";
}

-(NSInteger)testfunction:(int)num withB:(float)boolv withC:(NSString*)str{
    NSLog(@"I'm testfunction: withB: withC:");
    return 1;
}

-(NSString*)testfunction:(int)num withB:(float)boolv withC:(NSString*)str withD:(CGRect)rect{
    NSLog(@"I'm testfunction: withB: withC: withD:");
    return @"hello";
}

-(CGRect)testfunction:(int)num withB:(float)boolv withC:(NSString*)str withE:(NSRange)rect{
    NSLog(@"I'm testfunction: withB: withC: withD: withE:");
    return CGRectZero;
}

-(NSString *)testfunctionWithProtocol:(id)protocol
{
    Protocol *pro = (Protocol*)protocol;
    NSLog(@"%@",NSStringFromProtocol(pro));
    return @"hello";
}

-(NSString *)testFunctionWithSEL:(SEL)selector
{
    return NSStringFromSelector(selector);
}

-(void)testFunctionWithBlock:(blockType)block
{
    self.block = block;
}

-(void)testFunctionCallBlock{
    if (self.block) {
        self.block();
    }
}

-(void)testFunctionIDStar:(NSError **)error{
    if (error) {
        *error = [NSError errorWithDomain:@"xxxx" code:0 userInfo:nil];
    }
}

@end
