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

@interface ViewController () <MQTTSessionManagerDelegate>

@property (nonatomic,strong) MQTTSessionManager *mqttManager;
@end

@implementation ViewController

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

#pragma mark - MQTTSessionManagerDelegate
- (void)handleMessage:(NSData *)data onTopic:(NSString *)topic retained:(BOOL)retained{
    NSString *dataString=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"我收到新消息%@---%@",dataString,topic);
}

#pragma mark - kvo
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    NSLog(@"我的当前状态为：%d",self.mqttManager.state);
}
@end
