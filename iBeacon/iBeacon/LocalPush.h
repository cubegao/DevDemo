//
//  LocalPush.h
//  iBeacon
//
//  Created by Gaowz on 2018/5/31.
//  Copyright © 2018年 gawoz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>

@interface LocalPush : NSObject

@property (nonatomic, assign) NSInteger badgeNumber;

+ (instancetype)shareInstance;

- (void)pushLocalNotificationWithTitle:(NSString *)title body:(NSString *)body soundName:(NSString *)soundName delayTimeInterval:(NSTimeInterval)delayTimeInterval;

@end
