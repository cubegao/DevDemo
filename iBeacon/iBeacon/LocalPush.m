//
//  LocalPush.m
//  iBeacon
//
//  Created by Gaowz on 2018/5/31.
//  Copyright © 2018年 gawoz. All rights reserved.
//

#import "LocalPush.h"

static NSString * const kUseDefaultSoundName = @"useDefaultSoundName";


@implementation LocalPush

static LocalPush *_instance = nil;

+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    
    return _instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.badgeNumber = 0;
    }
    return self;
}

- (void)pushLocalNotificationWithTitle:(NSString *)title body:(NSString *)body soundName:(NSString *)soundName delayTimeInterval:(NSTimeInterval)delayTimeInterval {
    
    
    self.badgeNumber ++;
    
    if (!([[UIDevice currentDevice].systemVersion floatValue] >= 10.0)) {
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.alertTitle = title;
        localNotification.alertBody = body;
        localNotification.soundName = soundName.length>0 ? soundName : UILocalNotificationDefaultSoundName;
        
        NSTimeInterval time =  [[NSDate date] timeIntervalSince1970];
        NSString *times = [NSString stringWithFormat:@"%lld",(long long int)time];
        localNotification.userInfo = [NSDictionary dictionaryWithObject:times forKey:times];
        
        NSDate *trigger = [NSDate dateWithTimeIntervalSinceNow:delayTimeInterval];
        localNotification.fireDate = trigger;
        localNotification.timeZone = [NSTimeZone localTimeZone];
        
        if (self.badgeNumber > 0) {
            [UIApplication sharedApplication].applicationIconBadgeNumber = self.badgeNumber;
        }
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        
    } else {
        
        if (@available(iOS 10.0, *)) {
            UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
            UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
            content.title = title;
            content.body = body;
            content.sound = soundName.length>0 ? [UNNotificationSound defaultSound] : [UNNotificationSound soundNamed:soundName];
            
            NSTimeInterval time =  [[NSDate date] timeIntervalSince1970];
            NSString *times = [NSString stringWithFormat:@"%lld",(long long int)time];
            NSLog(@"%@",times);
            content.userInfo = @{@"key":times};
            
            if (self.badgeNumber > 0) {
                [UIApplication sharedApplication].applicationIconBadgeNumber = self.badgeNumber;
            }
            
            UNTimeIntervalNotificationTrigger *trigger = nil;
            if (delayTimeInterval > 0) {
                trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:delayTimeInterval repeats:NO];
            }
            UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:NSStringFromClass(self.class) content:content trigger:trigger];
            
            [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
                
            }];
        } else {
            // Fallback on earlier versions
        }
    }
}

@end
