//
//  AppDelegate.m
//  ZJHMonitorRegion
//
//  Created by ZhangJingHao48 on 2019/9/25.
//  Copyright © 2019 ZhangJingHao48. All rights reserved.
//

#import "AppDelegate.h"
#import <UserNotifications/UserNotifications.h>
#import "ZJHRegionManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self registerNotifaction];
    [self awakeForRegionWithOptions:launchOptions];
    return YES;
}

// APP被唤醒机制
- (void)awakeForRegionWithOptions:(NSDictionary *)launchOptions {
    // 应用启动时开启监听
    [[ZJHRegionManager shareInstance] starMonitorRegion];
    
    // 被区域监测唤醒
    // 我在模拟器测试，更改地理位置时，launchOptions数据为空
    if ([launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey]) {
        NSLog(@"区域监测唤醒");
    }
}


// 注册通知
- (void)registerNotifaction {
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert + UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
        NSLog(@"注册通知成功");
    }];
}



#pragma mark - UISceneSession lifecycle

- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
