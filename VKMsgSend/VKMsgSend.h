//
//  NSObject+idSelectorCall.h
//  IdSelectorCall
//
//  Created by Awhisper on 15/12/25.
//  Copyright © 2015年 Awhisper. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSObject (VKMsgSend)

+ (id)VKCallSelector:(SEL)selector err:(NSError *__autoreleasing *)error,...;

+ (id)VKCallSelectorName:(NSString *)selName err:(NSError *__autoreleasing *)error,...;

- (id)VKCallSelector:(SEL)selector err:(NSError *__autoreleasing *)error,...;

- (id)VKCallSelectorName:(NSString *)selName err:(NSError *__autoreleasing *)error,...;

@end

@interface NSString (VKMsgSend)

- (id)VKCallClassSelector:(SEL)selector err:(NSError *__autoreleasing *)error,...;

- (id)VKCallClassSelectorName:(NSString *)selName err:(NSError *__autoreleasing *)error,...;

- (id)VKCallClassAllocInitSelector:(SEL)selector err:(NSError *__autoreleasing *)error,...;

- (id)VKCallClassAllocInitSelectorName:(NSString *)selName err:(NSError *__autoreleasing *)error,...;

@end
