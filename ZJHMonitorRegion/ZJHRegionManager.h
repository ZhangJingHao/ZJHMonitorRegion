//
//  ZJHRegionManager.h
//  ZJHMonitorRegion
//
//  Created by ZhangJingHao48 on 2019/9/25.
//  Copyright © 2019 ZhangJingHao48. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZJHRegionManager : NSObject

+ (instancetype)shareInstance;

@property (nonatomic, strong) NSArray *locationArr;

- (void)starMonitorRegion;

// 本地通知
- (void)registerNotificationWithMsg:(NSString *)msg;

@end

NS_ASSUME_NONNULL_END
