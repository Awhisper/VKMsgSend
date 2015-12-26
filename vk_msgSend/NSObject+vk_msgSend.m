//
//  NSObject+idSelectorCall.m
//  IdSelectorCall
//
//  Created by Awhisper on 15/12/25.
//  Copyright © 2015年 Awhisper. All rights reserved.
//

#import "NSObject+vk_msgSend.h"
#import <objc/runtime.h>


//#define VK_MsgSendStructBoxing(_type,struct)\
[NSValue valueWithBytes:&(struct) objCType:@encode(_type)]



#if TARGET_OS_IPHONE
#import <UIKit/UIApplication.h>
#endif



@interface vk_nilObject : NSObject

@end

@implementation vk_nilObject


@end


static NSLock *_vkMethodSignatureLock;
static NSMutableDictionary *_vkMethodSignatureCache;
static vk_nilObject* vknilPointer = nil;

//learn & copy from JSPatch code source
static NSString *vk_extractStructName(NSString *typeEncodeString)
{
    NSArray *array = [typeEncodeString componentsSeparatedByString:@"="];
    NSString *typeString = array[0];
    int firstValidIndex = 0;
    for (int i = 0; i< typeString.length; i++) {
        char c = [typeString characterAtIndex:i];
        if (c == '{' || c=='_') {
            firstValidIndex++;
        }else {
            break;
        }
    }
    return [typeString substringFromIndex:firstValidIndex];
};

static NSMethodSignature *vk_getMethodSignature(Class cls,SEL selector)
{
    [_vkMethodSignatureLock lock];
    if (!_vkMethodSignatureCache[cls]) {
        _vkMethodSignatureCache[(id<NSCopying>)cls] = [[NSMutableDictionary alloc]init];
    }
    
    const char *selNameCstr = sel_getName(selector);
    NSString *selName =[[NSString alloc] initWithUTF8String:selNameCstr];
    NSMethodSignature *methodSignature = _vkMethodSignatureCache[cls][selName];
    if (!methodSignature) {
        methodSignature = [cls instanceMethodSignatureForSelector:selector];
        _vkMethodSignatureCache[cls][selName] = methodSignature;
    }
    [_vkMethodSignatureLock unlock];
    return methodSignature;
}

static NSString *vk_getSelectorName(SEL selector){
    const char *selNameCstr = sel_getName(selector);
    NSString *selName =[[NSString alloc] initWithUTF8String:selNameCstr];
    return selName;
}

static void vk_generateError(NSString *errorInfo, NSError **error){
     *error = [NSError errorWithDomain:@"message send reciver is nil" code:0 userInfo:nil];
}

static id vk_targetCallSelectorWithArgumentError(id target,SEL selector,NSArray *argsArr,NSError *__autoreleasing*error){
    
    Class cls = [target class];
    NSMethodSignature * methodSignature = vk_getMethodSignature(cls, selector);
    
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    [invocation setTarget:target];
    [invocation setSelector:selector];
    
    for (int i = 2; i < [methodSignature numberOfArguments]; i++) {
        const char *argumentType = [methodSignature getArgumentTypeAtIndex:i];
        id valObj = argsArr[i-2];
        switch (argumentType[0] == 'r' ? argumentType[1] : argumentType[0]) {
                
#define VK_CALL_ARG_CASE(_typeString, _type, _selector) \
case _typeString: {                              \
_type value = [valObj _selector];                     \
[invocation setArgument:&value atIndex:i];\
break; \
}
                
                VK_CALL_ARG_CASE('c', char, charValue)
                VK_CALL_ARG_CASE('C', unsigned char, unsignedCharValue)
                VK_CALL_ARG_CASE('s', short, shortValue)
                VK_CALL_ARG_CASE('S', unsigned short, unsignedShortValue)
                VK_CALL_ARG_CASE('i', int, intValue)
                VK_CALL_ARG_CASE('I', unsigned int, unsignedIntValue)
                VK_CALL_ARG_CASE('l', long, longValue)
                VK_CALL_ARG_CASE('L', unsigned long, unsignedLongValue)
                VK_CALL_ARG_CASE('q', long long, longLongValue)
                VK_CALL_ARG_CASE('Q', unsigned long long, unsignedLongLongValue)
                VK_CALL_ARG_CASE('f', float, floatValue)
                VK_CALL_ARG_CASE('d', double, doubleValue)
                VK_CALL_ARG_CASE('B', BOOL, boolValue)
            case ':': {
//                SEL value = va_arg(argList, SEL);
//                [invocation setArgument:&value atIndex:i];
                NSCAssert(NO, @"argument boxing wroing,selector not support");
                break;
            }
            case '{': {
                NSString *typeString = vk_extractStructName([NSString stringWithUTF8String:argumentType]);
                NSValue *val = (NSValue*)valObj;
#define VK_CALL_ARG_STRUCT(_type, _methodName) \
if ([typeString rangeOfString:@#_type].location != NSNotFound) {    \
_type value = [val _methodName];  \
[invocation setArgument:&value atIndex:i];  \
break; \
}
                VK_CALL_ARG_STRUCT(CGRect, CGRectValue)
                VK_CALL_ARG_STRUCT(CGPoint, CGPointValue)
                VK_CALL_ARG_STRUCT(CGSize, CGSizeValue)
                VK_CALL_ARG_STRUCT(NSRange, rangeValue)
                VK_CALL_ARG_STRUCT(CGAffineTransform, CGAffineTransformValue)
                VK_CALL_ARG_STRUCT(UIEdgeInsets, UIEdgeInsetsValue)
                VK_CALL_ARG_STRUCT(UIOffset, UIOffsetValue)
                VK_CALL_ARG_STRUCT(CGVector, CGVectorValue)
                
                break;
            }
            case '*':{
                NSCAssert(NO, @"argument boxing wroing,char* not support");
                break;
            }
            case '^': {
                NSCAssert(NO, @"argument boxing wroing,pointer not support");
                break;
            }
            case '#': {
                NSCAssert(NO, @"argument boxing wroing,class not support");
                break;
            }
            default: {
                //i dont't known why [valObj isKindOfClass:[vk_nilObject Class]] can't work at here
                NSString *className = NSStringFromClass([(id)valObj class]);
                if ([className isEqualToString:@"vk_nilObject"]) {
                    [invocation setArgument:&vknilPointer atIndex:i];
                }else{
                    [invocation setArgument:&valObj atIndex:i];
                }
                
            }
        }
    }
    
    
    [invocation invoke];
    const char *returnType = [methodSignature methodReturnType];
    NSString* selName = vk_getSelectorName(selector);
    if (strncmp(returnType, "v", 1) != 0) {
        if (strncmp(returnType, "@", 1) == 0) {
            void *result;
            [invocation getReturnValue:&result];
            
            if (result == NULL) {
                return nil;
            }
            
            id returnValue;
            //For performance, ignore the other methods prefix with alloc/new/copy/mutableCopy
            if ([selName isEqualToString:@"alloc"] || [selName isEqualToString:@"new"] ||
                [selName isEqualToString:@"copy"] || [selName isEqualToString:@"mutableCopy"]) {
                returnValue = (__bridge_transfer id)result;
            } else {
                returnValue = (__bridge id)result;
            }
            return returnValue;
            
        } else {
            switch (returnType[0] == 'r' ? returnType[1] : returnType[0]) {
                    
#define VK_CALL_RET_CASE(_typeString, _type) \
case _typeString: {                              \
_type returnValue; \
[invocation getReturnValue:&returnValue];\
return @(returnValue); \
break; \
}
                    
                    VK_CALL_RET_CASE('c', char)
                    VK_CALL_RET_CASE('C', unsigned char)
                    VK_CALL_RET_CASE('s', short)
                    VK_CALL_RET_CASE('S', unsigned short)
                    VK_CALL_RET_CASE('i', int)
                    VK_CALL_RET_CASE('I', unsigned int)
                    VK_CALL_RET_CASE('l', long)
                    VK_CALL_RET_CASE('L', unsigned long)
                    VK_CALL_RET_CASE('q', long long)
                    VK_CALL_RET_CASE('Q', unsigned long long)
                    VK_CALL_RET_CASE('f', float)
                    VK_CALL_RET_CASE('d', double)
                    VK_CALL_RET_CASE('B', BOOL)
                    
                case '{': {
                    NSString *typeString = vk_extractStructName([NSString stringWithUTF8String:returnType]);
#define VK_CALL_RET_STRUCT(_type) \
if ([typeString rangeOfString:@#_type].location != NSNotFound) {    \
_type result;   \
[invocation getReturnValue:&result];\
NSValue * returnValue = [NSValue valueWithBytes:&(result) objCType:@encode(_type)];\
return returnValue;\
}
                    VK_CALL_RET_STRUCT(CGRect)
                    VK_CALL_RET_STRUCT(CGPoint)
                    VK_CALL_RET_STRUCT(CGSize)
                    VK_CALL_RET_STRUCT(NSRange)
                    VK_CALL_RET_STRUCT(CGAffineTransform)
                    VK_CALL_RET_STRUCT(UIEdgeInsets)
                    VK_CALL_RET_STRUCT(UIOffset)
                    VK_CALL_RET_STRUCT(CGVector)
                    
                    break;
                }
                case '*':
                case '^': {
                    
                    break;
                }
                case '#': {
                    
                    break;
                }
            }
            return nil;
        }
    }
    return nil;
    
};


@implementation NSObject (vk_msgSend)

// help!!!help!!!help!!! how to reuse va_list argumenst like this!
// I hate copy  va_list va_start va_arg va_end so many times!
// help!!!
//- (id)vk_callSelectorName:(NSString*)selName error:(NSError*__autoreleasing*)error,...{
//    SEL selector = NSSelectorFromString(selName);
//    [self vk_callSelector:selector error:error,...];
//}
+ (id)vk_callSelectorName:(NSString*)selName error:(NSError*__autoreleasing*)error,...{
    
    va_list argList;
    va_start(argList, error);
    
    Class cls = [self class];
    SEL selector = NSSelectorFromString(selName);
    NSMethodSignature *methodSignature = vk_getMethodSignature(cls, selector);
    
    if (!methodSignature) {
        NSString* errorStr = [NSString stringWithFormat:@"unrecognized selector (%@)", selName];
        vk_generateError(errorStr,error);
        return nil;
    }
    
    
    
    NSMutableArray *argumentsBoxingArray = [[NSMutableArray alloc]init];
    
    for (int i = 2; i < [methodSignature numberOfArguments]; i++) {
        const char *argumentType = [methodSignature getArgumentTypeAtIndex:i];
        
        switch (argumentType[0] == 'r' ? argumentType[1] : argumentType[0]) {
                
#define VK_BOXING_ARG_CASE(_typeString, _type)\
case _typeString: {\
_type value = va_arg(argList, _type);\
[argumentsBoxingArray addObject:@(value)];\
break; \
}\

                VK_BOXING_ARG_CASE('c', char)
                VK_BOXING_ARG_CASE('C', unsigned char)
                VK_BOXING_ARG_CASE('s', short)
                VK_BOXING_ARG_CASE('S', unsigned short)
                VK_BOXING_ARG_CASE('i', int)
                VK_BOXING_ARG_CASE('I', unsigned int)
                VK_BOXING_ARG_CASE('l', long)
                VK_BOXING_ARG_CASE('L', unsigned long)
                VK_BOXING_ARG_CASE('q', long long)
                VK_BOXING_ARG_CASE('Q', unsigned long long)
                VK_BOXING_ARG_CASE('f', float)
                VK_BOXING_ARG_CASE('d', double)
                VK_BOXING_ARG_CASE('B', BOOL)
                
            case ':': {
                //                SEL value = va_arg(argList, SEL);
                //                [invocation setArgument:&value atIndex:i];
                vk_generateError(@"unsupport selector argumenst",error);
                return nil;
                break;
            }
            case '{': {
                NSString *typeString = vk_extractStructName([NSString stringWithUTF8String:argumentType]);
                
#define JP_CALL_ARG_STRUCT(_type, _methodName) \
if ([typeString rangeOfString:@#_type].location != NSNotFound) {    \
_type val = va_arg(argList, _type);\
NSValue* value = [NSValue _methodName:val];\
[argumentsBoxingArray addObject:value];  \
break; \
}
                JP_CALL_ARG_STRUCT(CGRect, valueWithCGRect)
                JP_CALL_ARG_STRUCT(CGPoint, valueWithCGPoint)
                JP_CALL_ARG_STRUCT(CGSize, valueWithCGSize)
                JP_CALL_ARG_STRUCT(NSRange, valueWithRange)
                JP_CALL_ARG_STRUCT(CGAffineTransform, valueWithCGAffineTransform)
                JP_CALL_ARG_STRUCT(UIEdgeInsets, valueWithUIEdgeInsets)
                JP_CALL_ARG_STRUCT(UIOffset, valueWithUIOffset)
                JP_CALL_ARG_STRUCT(CGVector, valueWithCGVector)
                //
                
                break;
            }
            case '*':{
                vk_generateError(@"unsupport char* argumenst",error);
                return nil;
                break;
            }
            case '^': {
                vk_generateError(@"unsupport pointer argumenst",error);
                return nil;
                break;
            }
            case '#': {
                vk_generateError(@"unsupport class argumenst",error);
                return nil;
                break;
            }
            default: {
                id value = va_arg(argList, id);
                if (value) {
                    [argumentsBoxingArray addObject:value];
                }else{
                    [argumentsBoxingArray addObject:[vk_nilObject new]];
                }
                
            }
        }
    }
    
    va_end(argList);
    
    return vk_targetCallSelectorWithArgumentError(self, selector, [argumentsBoxingArray copy], error);
}

// help!!!help!!!help!!! how to reuse va_list argumenst like this!
// I hate copy  va_list va_start va_arg va_end so many times!
// help!!!
//- (id)vk_callSelectorName:(NSString*)selName error:(NSError*__autoreleasing*)error,...{
//    SEL selector = NSSelectorFromString(selName);
//    [self vk_callSelector:selector error:error,...];
//}
+ (id)vk_callSelector:(SEL)selector error:(NSError*__autoreleasing*)error,...{
    
    va_list argList;
    va_start(argList, error);
    
    Class cls = [self class];
    NSMethodSignature *methodSignature = vk_getMethodSignature(cls, selector);
    
    NSString* selName = vk_getSelectorName(selector);
    
    if (!methodSignature) {
        NSString* errorStr = [NSString stringWithFormat:@"unrecognized selector (%@)", selName];
        vk_generateError(errorStr,error);
        return nil;
    }
    
    
    
    NSMutableArray *argumentsBoxingArray = [[NSMutableArray alloc]init];
    
    for (int i = 2; i < [methodSignature numberOfArguments]; i++) {
        const char *argumentType = [methodSignature getArgumentTypeAtIndex:i];
        
        switch (argumentType[0] == 'r' ? argumentType[1] : argumentType[0]) {
                
#define VK_BOXING_ARG_CASE(_typeString, _type)\
case _typeString: {\
_type value = va_arg(argList, _type);\
[argumentsBoxingArray addObject:@(value)];\
break; \
}\

                VK_BOXING_ARG_CASE('c', char)
                VK_BOXING_ARG_CASE('C', unsigned char)
                VK_BOXING_ARG_CASE('s', short)
                VK_BOXING_ARG_CASE('S', unsigned short)
                VK_BOXING_ARG_CASE('i', int)
                VK_BOXING_ARG_CASE('I', unsigned int)
                VK_BOXING_ARG_CASE('l', long)
                VK_BOXING_ARG_CASE('L', unsigned long)
                VK_BOXING_ARG_CASE('q', long long)
                VK_BOXING_ARG_CASE('Q', unsigned long long)
                VK_BOXING_ARG_CASE('f', float)
                VK_BOXING_ARG_CASE('d', double)
                VK_BOXING_ARG_CASE('B', BOOL)
                
            case ':': {
                //                SEL value = va_arg(argList, SEL);
                //                [invocation setArgument:&value atIndex:i];
                vk_generateError(@"unsupport selector argumenst",error);
                return nil;
                break;
            }
            case '{': {
                NSString *typeString = vk_extractStructName([NSString stringWithUTF8String:argumentType]);
                
#define JP_CALL_ARG_STRUCT(_type, _methodName) \
if ([typeString rangeOfString:@#_type].location != NSNotFound) {    \
_type val = va_arg(argList, _type);\
NSValue* value = [NSValue _methodName:val];\
[argumentsBoxingArray addObject:value];  \
break; \
}
                JP_CALL_ARG_STRUCT(CGRect, valueWithCGRect)
                JP_CALL_ARG_STRUCT(CGPoint, valueWithCGPoint)
                JP_CALL_ARG_STRUCT(CGSize, valueWithCGSize)
                JP_CALL_ARG_STRUCT(NSRange, valueWithRange)
                JP_CALL_ARG_STRUCT(CGAffineTransform, valueWithCGAffineTransform)
                JP_CALL_ARG_STRUCT(UIEdgeInsets, valueWithUIEdgeInsets)
                JP_CALL_ARG_STRUCT(UIOffset, valueWithUIOffset)
                JP_CALL_ARG_STRUCT(CGVector, valueWithCGVector)
                //
                
                break;
            }
            case '*':{
                vk_generateError(@"unsupport char* argumenst",error);
                return nil;
                break;
            }
            case '^': {
                vk_generateError(@"unsupport pointer argumenst",error);
                return nil;
                break;
            }
            case '#': {
                vk_generateError(@"unsupport class argumenst",error);
                return nil;
                break;
            }
            default: {
                id value = va_arg(argList, id);
                if (value) {
                    [argumentsBoxingArray addObject:value];
                }else{
                    [argumentsBoxingArray addObject:[vk_nilObject new]];
                }
                
            }
        }
    }
    
    va_end(argList);
    
    return vk_targetCallSelectorWithArgumentError(self, selector, [argumentsBoxingArray copy], error);
}

// help!!!help!!!help!!! how to reuse va_list argumenst like this!
// I hate copy  va_list va_start va_arg va_end so many times!
// help!!!
//- (id)vk_callSelectorName:(NSString*)selName error:(NSError*__autoreleasing*)error,...{
//    SEL selector = NSSelectorFromString(selName);
//    [self vk_callSelector:selector error:error,...];
//}
- (id)vk_callSelectorName:(NSString*)selName error:(NSError*__autoreleasing*)error,...{
    
    va_list argList;
    va_start(argList, error);
    
    Class cls = [self class];
    SEL selector = NSSelectorFromString(selName);
    NSMethodSignature *methodSignature = vk_getMethodSignature(cls, selector);
    
//    NSString* selName = vk_getSelectorName(selector);
    
    if (!methodSignature) {
        NSString* errorStr = [NSString stringWithFormat:@"unrecognized selector (%@)", selName];
        vk_generateError(errorStr,error);
        return nil;
    }
    
    
    
    NSMutableArray *argumentsBoxingArray = [[NSMutableArray alloc]init];
    
    for (int i = 2; i < [methodSignature numberOfArguments]; i++) {
        const char *argumentType = [methodSignature getArgumentTypeAtIndex:i];
        
        switch (argumentType[0] == 'r' ? argumentType[1] : argumentType[0]) {
                
#define VK_BOXING_ARG_CASE(_typeString, _type)\
case _typeString: {\
_type value = va_arg(argList, _type);\
[argumentsBoxingArray addObject:@(value)];\
break; \
}\

                VK_BOXING_ARG_CASE('c', char)
                VK_BOXING_ARG_CASE('C', unsigned char)
                VK_BOXING_ARG_CASE('s', short)
                VK_BOXING_ARG_CASE('S', unsigned short)
                VK_BOXING_ARG_CASE('i', int)
                VK_BOXING_ARG_CASE('I', unsigned int)
                VK_BOXING_ARG_CASE('l', long)
                VK_BOXING_ARG_CASE('L', unsigned long)
                VK_BOXING_ARG_CASE('q', long long)
                VK_BOXING_ARG_CASE('Q', unsigned long long)
                VK_BOXING_ARG_CASE('f', float)
                VK_BOXING_ARG_CASE('d', double)
                VK_BOXING_ARG_CASE('B', BOOL)
                
            case ':': {
                //                SEL value = va_arg(argList, SEL);
                //                [invocation setArgument:&value atIndex:i];
                vk_generateError(@"unsupport selector argumenst",error);
                return nil;
                break;
            }
            case '{': {
                NSString *typeString = vk_extractStructName([NSString stringWithUTF8String:argumentType]);
                
#define JP_CALL_ARG_STRUCT(_type, _methodName) \
if ([typeString rangeOfString:@#_type].location != NSNotFound) {    \
_type val = va_arg(argList, _type);\
NSValue* value = [NSValue _methodName:val];\
[argumentsBoxingArray addObject:value];  \
break; \
}
                JP_CALL_ARG_STRUCT(CGRect, valueWithCGRect)
                JP_CALL_ARG_STRUCT(CGPoint, valueWithCGPoint)
                JP_CALL_ARG_STRUCT(CGSize, valueWithCGSize)
                JP_CALL_ARG_STRUCT(NSRange, valueWithRange)
                JP_CALL_ARG_STRUCT(CGAffineTransform, valueWithCGAffineTransform)
                JP_CALL_ARG_STRUCT(UIEdgeInsets, valueWithUIEdgeInsets)
                JP_CALL_ARG_STRUCT(UIOffset, valueWithUIOffset)
                JP_CALL_ARG_STRUCT(CGVector, valueWithCGVector)
                //
                
                break;
            }
            case '*':{
                vk_generateError(@"unsupport char* argumenst",error);
                return nil;
                break;
            }
            case '^': {
                vk_generateError(@"unsupport pointer argumenst",error);
                return nil;
                break;
            }
            case '#': {
                vk_generateError(@"unsupport class argumenst",error);
                return nil;
                break;
            }
            default: {
                id value = va_arg(argList, id);
                if (value) {
                    [argumentsBoxingArray addObject:value];
                }else{
                    [argumentsBoxingArray addObject:[vk_nilObject new]];
                }
                
            }
        }
    }
    
    va_end(argList);
    
    return vk_targetCallSelectorWithArgumentError(self, selector, [argumentsBoxingArray copy], error);
}


- (id)vk_callSelector:(SEL)selector error:(NSError*__autoreleasing*)error,...{
   
    va_list argList;
    va_start(argList, error);
    
    Class cls = [self class];
    NSMethodSignature *methodSignature = vk_getMethodSignature(cls, selector);
    
    NSString* selName = vk_getSelectorName(selector);
    
    if (!methodSignature) {
        NSString* errorStr = [NSString stringWithFormat:@"unrecognized selector (%@)", selName];
        vk_generateError(errorStr,error);
        return nil;
    }
    
    
    
    NSMutableArray *argumentsBoxingArray = [[NSMutableArray alloc]init];
    
    for (int i = 2; i < [methodSignature numberOfArguments]; i++) {
        const char *argumentType = [methodSignature getArgumentTypeAtIndex:i];
        
        switch (argumentType[0] == 'r' ? argumentType[1] : argumentType[0]) {
                
#define VK_BOXING_ARG_CASE(_typeString, _type)\
case _typeString: {\
_type value = va_arg(argList, _type);\
[argumentsBoxingArray addObject:@(value)];\
break; \
}\

                VK_BOXING_ARG_CASE('c', char)
                VK_BOXING_ARG_CASE('C', unsigned char)
                VK_BOXING_ARG_CASE('s', short)
                VK_BOXING_ARG_CASE('S', unsigned short)
                VK_BOXING_ARG_CASE('i', int)
                VK_BOXING_ARG_CASE('I', unsigned int)
                VK_BOXING_ARG_CASE('l', long)
                VK_BOXING_ARG_CASE('L', unsigned long)
                VK_BOXING_ARG_CASE('q', long long)
                VK_BOXING_ARG_CASE('Q', unsigned long long)
                VK_BOXING_ARG_CASE('f', float)
                VK_BOXING_ARG_CASE('d', double)
                VK_BOXING_ARG_CASE('B', BOOL)
                
            case ':': {
//                SEL value = va_arg(argList, SEL);
//                [invocation setArgument:&value atIndex:i];
                vk_generateError(@"unsupport selector argumenst",error);
                return nil;
                break;
            }
            case '{': {
                NSString *typeString = vk_extractStructName([NSString stringWithUTF8String:argumentType]);
                
#define JP_CALL_ARG_STRUCT(_type, _methodName) \
if ([typeString rangeOfString:@#_type].location != NSNotFound) {    \
_type val = va_arg(argList, _type);\
NSValue* value = [NSValue _methodName:val];\
[argumentsBoxingArray addObject:value];  \
break; \
}
                JP_CALL_ARG_STRUCT(CGRect, valueWithCGRect)
                JP_CALL_ARG_STRUCT(CGPoint, valueWithCGPoint)
                JP_CALL_ARG_STRUCT(CGSize, valueWithCGSize)
                JP_CALL_ARG_STRUCT(NSRange, valueWithRange)
                JP_CALL_ARG_STRUCT(CGAffineTransform, valueWithCGAffineTransform)
                JP_CALL_ARG_STRUCT(UIEdgeInsets, valueWithUIEdgeInsets)
                JP_CALL_ARG_STRUCT(UIOffset, valueWithUIOffset)
                JP_CALL_ARG_STRUCT(CGVector, valueWithCGVector)
                //
                
                break;
            }
            case '*':{
                vk_generateError(@"unsupport char* argumenst",error);
                return nil;
                break;
            }
            case '^': {
                vk_generateError(@"unsupport pointer argumenst",error);
                return nil;
                break;
            }
            case '#': {
                vk_generateError(@"unsupport class argumenst",error);
                return nil;
                break;
            }
            default: {
                id value = va_arg(argList, id);
                if (value) {
                    [argumentsBoxingArray addObject:value];
                }else{
                    [argumentsBoxingArray addObject:[vk_nilObject new]];
                }
                
            }
        }
    }
    
    va_end(argList);
    
    return vk_targetCallSelectorWithArgumentError(self, selector, [argumentsBoxingArray copy], error);
}



@end
