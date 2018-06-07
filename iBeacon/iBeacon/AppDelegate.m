//
//  AppDelegate.m
//  iBeacon
//
//  Created by Gaowz on 2018/5/31.
//  Copyright © 2018年 gawoz. All rights reserved.
//

#import "AppDelegate.h"
#import <UserNotifications/UserNotifications.h>
#import "LocalPush.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>

#define kKeyWindow [UIApplication sharedApplication].keyWindow

#define Device_UUID @"29EA3478-2C37-4BAA-81C9-01FA5889AF2B"
#define kNotificationName @"kNotificationNamePostIbeacon"


@interface AppDelegate ()<CLLocationManagerDelegate>

@property (nonatomic , strong) CLLocationManager *locationManager;
@property (nonatomic , strong) CLBeaconRegion *beaconRegion;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [self registerLocalPush];
    
    [self receive];
    return YES;
}

- (void)registerLocalPush {
    if (([[UIDevice currentDevice].systemVersion floatValue] >= 10.0)) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = (id)[UIApplication sharedApplication].delegate;
        
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError * _Nullable error) {
        }];
    } else {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes: (UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert) categories:nil]];
    }
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}


- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    application.applicationIconBadgeNumber = 0;
    [[LocalPush shareInstance] setBadgeNumber:0];
    
    if (application.applicationState == UIApplicationStateActive ) {
        UIAlertController *ac =   [UIAlertController alertControllerWithTitle:nil message:notification.alertBody preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"收到了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [ac addAction:action];
        [self.window.rootViewController presentViewController:ac animated:YES completion:nil];
    }
}




#pragma mark - beacon
- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.activityType = CLActivityTypeFitness;
        _locationManager.distanceFilter = kCLDistanceFilterNone;
    }
    return _locationManager;
}

- (CLBeaconRegion *)beaconRegion {
    if (!_beaconRegion) {
        _beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:Device_UUID] major:111 minor:222 identifier:@"test"];
        _beaconRegion.notifyEntryStateOnDisplay = YES;
        _beaconRegion.notifyOnEntry = YES;
        _beaconRegion.notifyOnExit = YES;
    }
    return _beaconRegion;
}


- (void)receive
{
    
    BOOL availableMonitor = [CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]];
    
    if (availableMonitor) {
        CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
        switch (authorizationStatus) {
            case kCLAuthorizationStatusNotDetermined:
                [self.locationManager requestAlwaysAuthorization];
                break;
            case kCLAuthorizationStatusRestricted:
            case kCLAuthorizationStatusDenied:
                NSLog(@"受限制或者拒绝");
                break;
            case kCLAuthorizationStatusAuthorizedAlways:
            case kCLAuthorizationStatusAuthorizedWhenInUse:{
                [self.locationManager startMonitoringForRegion:self.beaconRegion];
                [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
            }
                break;
        }
    } else {
        NSLog(@"该设备不支持 CLBeaconRegion 区域检测");
    }
    
}



// Monitoring成功对应回调函数
- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
}

// 设备进入该区域时的回调
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    [[LocalPush shareInstance] pushLocalNotificationWithTitle:@"" body:@"设备进入该区域了" soundName:nil delayTimeInterval:0];
    
}

// 设备退出该区域时的回调 大约20S延时
- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    [[LocalPush shareInstance] pushLocalNotificationWithTitle:@"" body:@"设备离开该区域了" soundName:nil delayTimeInterval:0];
    
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(nullable CLRegion *)region withError:(NSError *)error
{
    
}

// Ranging成功对应回调函数
/// 检测到区域内的iBeacons时回调此函数，差不多1s刷新一次，这个方法会返回一个 CLBeacon 的数组，根据 CLBeacon 的 proximity 属性就可以判断设备和 beacon 之间的距离,proximity 属性有四个可能的值，unknown、immediate、near 和 far, 另外 CLBeacon 还有 accuracy 和 rssi 两个属性能提供更详细的距离数据
- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray<CLBeacon *> *)beacons inRegion:(CLBeaconRegion *)region
{
    NSDictionary *dic = @{@"beacons":beacons,@"region":region};
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName object:dic];
}

- (void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error
{
    
}


// 屏幕点亮就会回调此函数
- (void)locationManager:(CLLocationManager *)manager
      didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    NSLog(@"%ld-%@",state,region);
}



- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
