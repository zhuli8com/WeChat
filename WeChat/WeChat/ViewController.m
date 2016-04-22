//
//  ViewController.m
//  WeChat
//
//  Created by account on 15/9/17.
//  Copyright (c) 2015年 zhuli8. All rights reserved.
//

#import "ViewController.h"
#import <MQTTClient/MQTTClient.h>
#import <MQTTClient/MQTTSessionManager.h>
#import "MXConversation.h"
#import <FMDB.h>

@interface ViewController () <MQTTSessionManagerDelegate>

@property (nonatomic,strong) MQTTSessionManager *mqttManager;
@end

@implementation ViewController
#pragma mark - life cycles
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
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
                        willQos:MQTTQosLevelExactlyOnce
                 willRetainFlag:NO
                   withClientId:MQTT_CLIENTID
                 securityPolicy:securityPolicy
                   certificates:nil
     ];
    
    [self.mqttManager addObserver:self
                       forKeyPath:@"state"
                          options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew
                          context:nil
     ];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    [self.mqttManager removeObserver:self forKeyPath:@"state"];
}

#pragma mark - MQTTSessionManagerDelegate
- (void)handleMessage:(NSData *)data onTopic:(NSString *)topic retained:(BOOL)retained{
    NSString *dataString=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"Client收到新消息：%@---主题：%@---retained：%d",dataString,topic,retained);

    /**
     *  {
     "data":
     {
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
     },
     "type":"private_message"
     }
     ---/u/eWgveuUL7Mvw3_MWKg2pfWi56FY=
     */
    NSDictionary *message=[dataString JSONValue];
    if ([[message objectForKey:@"type"] isEqualToString:@"private_message"]) {
        NSLog(@"Client收到新消息：%@---主题：%@---retained：%d",dataString,topic,retained);
    
        MXConversation *conversation=[MXConversation conversationWithDictionary:[message objectForKey:@"data"]];
        NSLog(@"%@%@",conversation,conversation.body);
        
        NSURL *aURL=[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        NSLog(@"aPath=%@",aURL.path);
        FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:[aURL.path stringByAppendingPathComponent:@"minxing.db"]];
        [queue inDatabase:^(FMDatabase *db) {
            //int real text blob
            [db executeUpdate:@"create table if not exists t_conversation (id int,sender_id int,conversation_id long,created_at text,system bool,type text,direct_to_user_id int,network_id int,body text,message_type text)"];
            //insert into 表名后面没有列是插入不进库的，所有数据都必须转成OC的对象
            [db executeUpdate:@"replace into t_conversation(id,sender_id,conversation_id,created_at,system,type,direct_to_user_id,network_id,body,message_type) values(?,?,?,?,?,?,?,?,?,?)",conversation.ID,@(conversation.sender_id),@(conversation.conversation_id),conversation.created_at,@(conversation.system),conversation.type,@(conversation.direct_to_user_id),@(conversation.network_id),conversation.body,conversation.message_type];
            FMResultSet *rs=[db executeQuery:@"select * from t_conversation"];
            while ([rs next]) {
                NSLog(@"%d",[rs intForColumn:@"id"]);
            }
        }];
    }
}

#pragma mark - kvo
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    NSLog(@"MQTT的当前状态为：%d",self.mqttManager.state);
}
@end
