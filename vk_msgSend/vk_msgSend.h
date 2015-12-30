//
//  vk_msgSend.h
//  vk_msgSend_proj
//
//  Created by Awhisper on 15/12/26.
//  Copyright © 2015年 Awhisper. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol vk_msgSend <NSObject>

+ (id)vk_callSelector:(SEL)selector error:(NSError *__autoreleasing *)error,...;

+ (id)vk_callSelectorName:(NSString *)selName error:(NSError *__autoreleasing *)error,...;

- (id)vk_callSelector:(SEL)selector error:(NSError *__autoreleasing *)error,...;

- (id)vk_callSelectorName:(NSString *)selName error:(NSError *__autoreleasing *)error,...;

@end
