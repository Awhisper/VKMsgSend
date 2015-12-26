//
//  testClassA.m
//  IdSelectorCall
//
//  Created by Awhisper on 15/12/25.
//  Copyright © 2015年 Awhisper. All rights reserved.
//

#import "testClassA.h"
#import <UIKit/UIKit.h>

@implementation testClassA

+(NSInteger)testfunction:(int)num withB:(float)boolv withC:(NSString*)str{
    return 4;
}

-(NSString*)testfunction:(int)num withB:(float)boolv{
    NSLog(@"11");
    return @"11";
}

-(NSInteger)testfunction:(int)num withB:(float)boolv withC:(NSString*)str{
    return 4;
}

-(NSString*)testfunction:(int)num withB:(float)boolv withC:(NSString*)str withD:(CGRect)rect{
    return @"11";
}

-(CGRect)testfunction:(int)num withB:(float)boolv withC:(NSString*)str withE:(NSRange)rect{
    return CGRectZero;
}

@end
