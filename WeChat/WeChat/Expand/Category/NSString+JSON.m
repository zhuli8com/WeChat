//
//  NSString+JSON.m
//  WeChat
//
//  Created by lizhu on 16/4/22.
//  Copyright © 2016年 zhuli8. All rights reserved.
//

#import "NSString+JSON.h"

@implementation NSString (JSON)

- (id)JSONValue{
    NSData *data=[self dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error=nil;
    id result=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    if (!error) {
        return result;
    }
    return nil;
}
@end
