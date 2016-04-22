//
//  MXConversation.m
//  WeChat
//
//  Created by lizhu on 16/4/22.
//  Copyright © 2016年 zhuli8. All rights reserved.
//

#import "MXConversation.h"
#import <objc/runtime.h>

@implementation MXConversation

+ (instancetype)conversationWithDictionary:(NSDictionary *)dict{
    
    MXConversation *conversation=[[MXConversation alloc] init];
    
    unsigned int outCount=0;
    objc_property_t *properties=class_copyPropertyList([self class], &outCount);
    for (int i=0; i<outCount; i++) {
        const char *name=property_getName(properties[i]);
        NSString *key=[NSString stringWithUTF8String:name];
        if ([key isEqualToString:@"ID"]) {
            conversation.ID=[dict[@"id"] integerValue];
        }else{
            [conversation setValue:dict[key] forKey:key];
        }
    }
    return conversation;
}
@end
