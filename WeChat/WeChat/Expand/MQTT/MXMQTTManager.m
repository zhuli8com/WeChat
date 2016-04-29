//
//  MXMQTTManager.m
//  WeChat
//
//  Created by lizhu on 16/4/28.
//  Copyright © 2016年 zhuli8. All rights reserved.
//

#import "MXMQTTManager.h"

@interface MXMQTTManager ()

@property (nonatomic,strong) MQTTSessionManager *mqttManager;
@end

@implementation MXMQTTManager
/*
 * MQTTClient: create an instance of MQTTSessionManager once and connect
 * will is set to let the broker indicate to other subscribers if the connection is lost
 */
- (void)initMQTT{
    self.mqttManager=[[MQTTSessionManager alloc] init];
    self.mqttManager.delegate=self;
    
    NSDictionary *subscriptions=[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:MQTTQosLevelExactlyOnce] forKey:[NSString stringWithFormat:@"%@/#",MQTT_BASE]];
    self.mqttManager.subscriptions=subscriptions;
    
    MQTTSSLSecurityPolicy *securityPolicy=[MQTTSSLSecurityPolicy policyWithPinningMode:MQTTSSLPinningModeNone];
    securityPolicy.allowInvalidCertificates=YES;
    [self.mqttManager connectTo:MQTT_HOST
                           port:MQTT_PORT
                            tls:MQTT_TLS
                      keepalive:60
                          clean:NO
                           auth:YES
                           user:@"root"
                           pass:@"minxing123"
                           will:YES
                      willTopic:[NSString stringWithFormat:@"%@",MQTT_BASE]
                        willMsg:[@"offline" dataUsingEncoding:NSUTF8StringEncoding]
                        willQos:MQTTQosLevelAtLeastOnce
                 willRetainFlag:NO
                   withClientId:MQTT_CLIENTID
                 securityPolicy:securityPolicy
                   certificates:nil
     ];
    
    /*
     * MQTTCLient: observe the MQTTSessionManager's state to display the connection status
     */
    [self.mqttManager addObserver:self
                       forKeyPath:@"state"
                          options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew
                          context:nil
     ];
}

/*
 * MQTTClient: send data to broker
 */
- (int)sendMessage:(NSString *)message{
    int result=[self.mqttManager sendData:[message dataUsingEncoding:NSUTF8StringEncoding]
                     topic:[NSString stringWithFormat:@"%@",MQTT_BASE]
                       qos:MQTTQosLevelAtLeastOnce
                    retain:NO];
    return result;
}

#pragma mark - singleton
static MXMQTTManager *manager;

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager=[super allocWithZone:zone];
    });
    return manager;
}

- (instancetype)init{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager=[super init];
    });
    return manager;
}

+ (instancetype)sharedManager{
    return [[MXMQTTManager alloc] init];
}

- (void)dealloc{
    [self.mqttManager removeObserver:self forKeyPath:@"state"];
}

#pragma mark - MQTTSessionManagerDelegate
- (void)handleMessage:(NSData *)data onTopic:(NSString *)topic retained:(BOOL)retained{
    NSString *dataString=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"Client收到新消息：%@---主题：%@---retained：%d",dataString,topic,retained);
    
    NSDictionary *message=[dataString JSONValue];
    if ([[message objectForKey:@"type"] isEqualToString:@"private_message"]) {
        NSLog(@"Client收到新消息：%@---主题：%@---retained：%d",dataString,topic,retained);
        
        MXConversation *conversation=[MXConversation conversationWithDictionary:[message objectForKey:@"data"]];
        NSLog(@"%@%@",conversation,conversation.body);
        [[NSNotificationCenter defaultCenter] postNotificationName:kMQTTHandleMessageNotification object:conversation];
    }
}

#pragma mark - kvo
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    NSLog(@"MQTT的当前状态为：%d",self.mqttManager.state);
}
@end
