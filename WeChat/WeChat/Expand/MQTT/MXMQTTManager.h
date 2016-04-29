//
//  MXMQTTManager.h
//  WeChat
//
//  Created by lizhu on 16/4/28.
//  Copyright © 2016年 zhuli8. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MQTTClient/MQTTClient.h>
#import <MQTTClient/MQTTSessionManager.h>
#import "MXConversation.h"

#define kMQTTHandleMessageNotification @"kMQTTHandleMessageNotification"
#define MX_MQTTManager [MXMQTTManager sharedManager]

@interface MXMQTTManager : NSObject <MQTTSessionManagerDelegate>

- (void)initMQTT;
- (int)sendMessage:(NSString *)message;
+ (instancetype)sharedManager;
@end
