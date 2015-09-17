//
//  AppDelegate+XMPP.m
//  WeChat
//
//  Created by account on 15/9/17.
//  Copyright (c) 2015年 zhuli8. All rights reserved.
//

#import "AppDelegate+XMPP.h"
#import <objc/runtime.h>

@implementation AppDelegate (XMPP)

#pragma mark -  getters and setters
- (XMPPStream *)xmppStream{
   return objc_getAssociatedObject(self, _cmd);
}

- (void)setXmppStream:(XMPPStream *)xmppStream{
    objc_setAssociatedObject(self, @selector(xmppStream), xmppStream, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end
