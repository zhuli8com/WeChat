//
//  AppDelegate+XMPP.h
//  WeChat
//
//  Created by account on 15/9/17.
//  Copyright (c) 2015年 zhuli8. All rights reserved.
//

#import "AppDelegate.h"
#import "XMPP.h"

@interface AppDelegate (XMPP)

@property (nonatomic,strong)  XMPPStream *xmppStream;
@end
