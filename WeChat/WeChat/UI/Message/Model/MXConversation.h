//
//  MXConversation.h
//  WeChat
//
//  Created by lizhu on 16/4/22.
//  Copyright © 2016年 zhuli8. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MXConversation : NSObject

/**
 *  
 "id":4698,
 "sender_id":666,
 "conversation_id"20022056,
 "created_at":"2016-04-22T15:34:00+08:00",
 "system":false,
 "type":"message",
 "direct_to_user_id":667,
 "network_id":2,
 "body":"nihao",
 "message_type":"text_message"
 */
@property (nonatomic,assign) NSInteger ID;
@property (nonatomic,assign) NSInteger sender_id;
@property (nonatomic,assign) long long conversation_id;
@property (nonatomic,strong) NSString *created_at;
@property (nonatomic,assign) BOOL system;
@property (nonatomic,strong) NSString *type;
@property (nonatomic,assign) NSInteger direct_to_user_id;
@property (nonatomic,assign) NSInteger network_id;
@property (nonatomic,strong) NSString *body;
@property (nonatomic,strong) NSString *message_type;

+ (instancetype)conversationWithDictionary:(NSDictionary *)dict;
@end
