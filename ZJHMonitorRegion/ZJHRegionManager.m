//
//  ZJHRegionManager.m
//  ZJHMonitorRegion
//
//  Created by ZhangJingHao48 on 2019/9/25.
//  Copyright © 2019 ZhangJingHao48. All rights reserved.
//

#import "ZJHRegionManager.h"
#import <CoreLocation/CoreLocation.h>
#import <UserNotifications/UserNotifications.h>
#import <UIKit/UIKit.h>

@interface ZJHRegionManager ()<CLLocationManagerDelegate>

@property (nonatomic ,strong) CLLocationManager *locationMgr;

@end

@implementation ZJHRegionManager

+ (instancetype)shareInstance {
    static ZJHRegionManager* manager = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        manager = [[ZJHRegionManager alloc] init];
    });
    return manager;
}

- (CLLocationManager *)locationMgr {
    if (!_locationMgr) {
        _locationMgr = [[CLLocationManager alloc] init];
        _locationMgr.delegate = self;
        _locationMgr.desiredAccuracy = kCLLocationAccuracyBest;
        _locationMgr.distanceFilter = 10;
        // 主动请求定位授权
        [_locationMgr requestAlwaysAuthorization];
        // 这是iOS9中针对后台定位推出的新属性 不设置的话 可是会出现顶部蓝条的哦(类似热点连接)
        [_locationMgr setAllowsBackgroundLocationUpdates:YES];
        _locationMgr.pausesLocationUpdatesAutomatically = NO;
    }
    return _locationMgr;
}

- (NSArray *)locationArr {
    if (!_locationArr) {
        // 配置需要监听的地理位置
        _locationArr = @[ @{@"latitude":@"39.907826)", @"longitude":@"116.391211"},
                          @{@"latitude":@"31.245105)", @"longitude":@"121.506377"} ];
    }
    return _locationArr;
}

// 开始监听
- (void)starMonitorRegion {
    for (NSDictionary *dict in self.locationArr) {
        CLLocationDegrees latitude = [dict[@"latitude"] doubleValue];
        CLLocationDegrees longitude = [dict[@"longitude"] doubleValue];
        CLLocationCoordinate2D location = CLLocationCoordinate2DMake(latitude, longitude);
        [self regionObserveWithLocation:location];
    }
}

// 设置监听的位置
- (void)regionObserveWithLocation:(CLLocationCoordinate2D)location {
    if (![CLLocationManager locationServicesEnabled]) {
        NSLog(@"您的设备不支持定位");
        return;
    }
    
    // 设置区域半径
    CLLocationDistance radius = 200;
    // 使用前必须判定当前的监听区域半径是否大于最大可被监听的区域半径
    if(radius > self.locationMgr.maximumRegionMonitoringDistance) {
        radius = self.locationMgr.maximumRegionMonitoringDistance;
    }
    // 设置id
    NSString *identifier =
    [NSString stringWithFormat:@"%f , %f", location.latitude, location.longitude];
    // 使用CLCircularRegion创建一个圆形区域，
    CLRegion *fkit = [[CLCircularRegion alloc] initWithCenter:location
                                                       radius:radius
                                                   identifier:identifier];
    // 开始监听fkit区域
    [self.locationMgr startMonitoringForRegion:fkit];
    // 请求区域状态(如果发生了进入或者离开区域的动作也会调用对应的代理方法)
    [self.locationMgr requestStateForRegion:fkit];
}

// 进入指定区域以后将弹出提示框提示用户
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    NSString *msg = [NSString stringWithFormat:@"进入指定区域 %@", region.identifier];
    [self dealAlertWithStr:msg];
}

// 离开指定区域以后将弹出提示框提示用户
- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    NSString *msg = [NSString stringWithFormat:@"离开指定区域 %@", region.identifier];
    [self dealAlertWithStr:msg];
}

- (void)dealAlertWithStr:(NSString *)msg {
    NSLog(@"%@", msg);
    
    // 程序在后台
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        [self registerNotificationWithMsg:msg];
    } else { // 程序在前台
        [self alertWithMsg:msg];
    }
}

// 监听区域失败时调用
- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    NSLog(@"监听区域失败 : %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"区域失败 : %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    NSLog(@"开始监听");
}

// 本地通知
- (void)registerNotificationWithMsg:(NSString *)msg {
    // 使用 UNUserNotificationCenter 来管理通知
    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
    // 需创建一个包含待通知内容的 UNMutableNotificationContent 对象
    UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
    content.title = [NSString localizedUserNotificationStringForKey:@"通知"
                                                          arguments:nil];
    content.body = [NSString localizedUserNotificationStringForKey:msg
                                                         arguments:nil];
    content.sound = [UNNotificationSound defaultSound];
    NSInteger alerTime = 1;
    // 在 alertTime 后推送本地推送
    UNTimeIntervalNotificationTrigger *trigger =
    [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:alerTime
                                                       repeats:NO];
    UNNotificationRequest* request =
    [UNNotificationRequest requestWithIdentifier:@"FiveSecond"
                                         content:content
                                         trigger:trigger];
    
    //添加推送成功后的处理！
    [center addNotificationRequest:request withCompletionHandler:^(NSError *error) {
        if (error) {
            NSLog(@"添加推送失败 error : %@", error);
        } else {
            NSLog(@"添加推送成功");
        }
    }];
}

- (void)alertWithMsg:(NSString *)msg {
    UIAlertController *alert =
    [UIAlertController alertControllerWithTitle:@"通知"
                                        message:msg
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"我知道了"
                                                     style:UIAlertActionStyleCancel
                                                   handler:nil];
    [alert addAction:action];
    UINavigationController *nav =
    [UIApplication sharedApplication].keyWindow.rootViewController;
    [nav.topViewController presentViewController:alert animated:YES completion:nil];
}

@end
