//
//  AppDelegate.m
//  WeChat
//
//  Created by account on 15/9/17.
//  Copyright (c) 2015年 zhuli8. All rights reserved.
//

#import "AppDelegate.h"
#import "MXTabBarController.h"
#import "MXNavigationController.h"
#import "MXMessageViewController.h"
#import "MXContactViewController.h"
#import "MXAppCenterViewController.h"
#import "MXWorkCircleViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window=[[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    MXMessageViewController *messageVC=[[MXMessageViewController alloc] init];
    MXNavigationController *navgationoVC1=[[MXNavigationController alloc] initWithRootViewController:messageVC];
    messageVC.title=@"敏信";
    messageVC.tabBarItem.image=[UIImage imageNamed:@"mx_icon_bottombar_im_normal_phone"];
    messageVC.tabBarItem.selectedImage=[UIImage imageNamed:@"mx_icon_bottombar_im_selected_phone"];
    
    MXContactViewController *contactVC=[[MXContactViewController alloc] init];
    MXNavigationController *navgationoVC2=[[MXNavigationController alloc] initWithRootViewController:contactVC];
    contactVC.title=@"通讯录";
    contactVC.tabBarItem.image=[UIImage imageNamed:@"mx_icon_bottombar_address_book_normal_phone"];
    contactVC.tabBarItem.selectedImage=[UIImage imageNamed:@"mx_icon_bottombar_address_book_selected_phone"];

    MXAppCenterViewController *appCenterVC=[[MXAppCenterViewController alloc] init];
    MXNavigationController *navgationoVC3=[[MXNavigationController alloc] initWithRootViewController:appCenterVC];
    appCenterVC.title=@"我的应用";
    appCenterVC.tabBarItem.image=[UIImage imageNamed:@"mx_icon_bottombar_app_center_normal_phone"];
    appCenterVC.tabBarItem.selectedImage=[UIImage imageNamed:@"mx_icon_bottombar_app_center_selected_phone"];
    
    MXWorkCircleViewController *workCircleVC=[[MXWorkCircleViewController alloc] init];
    MXNavigationController *navgationoVC4=[[MXNavigationController alloc] initWithRootViewController:workCircleVC];
    workCircleVC.title=@"工作圈";
    workCircleVC.tabBarItem.image=[UIImage imageNamed:@"mx_icon_bottombar_sns_normal_phone"];
    workCircleVC.tabBarItem.selectedImage=[UIImage imageNamed:@"mx_icon_bottombar_sns_selectedd_phone"];
    
    MXTabBarController *tabVC=[[MXTabBarController alloc] init];
    tabVC.viewControllers=@[navgationoVC1,navgationoVC2,navgationoVC3,navgationoVC4];
    
    self.window.rootViewController=tabVC;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
