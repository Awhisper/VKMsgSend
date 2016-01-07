//
//  NSObject+idSelectorCall.h
//  IdSelectorCall
//
//  Created by Awhisper on 15/12/25.
//  Copyright © 2015年 Awhisper. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSObject (vk_msgSend)

+ (id)vk_callSelector:(SEL)selector error:(NSError *__autoreleasing *)error,...;

+ (id)vk_callSelectorName:(NSString *)selName error:(NSError *__autoreleasing *)error,...;

- (id)vk_callSelector:(SEL)selector error:(NSError *__autoreleasing *)error,...;

- (id)vk_callSelectorName:(NSString *)selName error:(NSError *__autoreleasing *)error,...;

@end
