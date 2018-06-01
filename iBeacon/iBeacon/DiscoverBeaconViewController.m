//
//  DiscoverBeaconViewController.m
//  iBeacon
//
//  Created by Gaowz on 2018/5/31.
//  Copyright © 2018年 gawoz. All rights reserved.
//

#define Device_UUID @"29EA3478-2C37-4BAA-81C9-01FA5889AF2B"
#define kScreenHeight ([UIScreen mainScreen].bounds.size.height)
#define kScreenWidth ([UIScreen mainScreen].bounds.size.width)
#define kScreenBounds [UIScreen mainScreen].bounds

#import "DiscoverBeaconViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>
#import "LocalPush.h"

@interface DiscoverBeaconViewController ()<CLLocationManagerDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic , strong) UITableView *tableView;
@property (nonatomic , strong) UILabel *waitLabel;
@property (nonatomic , strong) NSMutableDictionary *dataList;


@property (nonatomic , strong) CLLocationManager *locationManager;
@property (nonatomic , strong) CLBeaconRegion *beaconRegion;

@end

@implementation DiscoverBeaconViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _initSubViews];
    
    [self receive];
}

- (void)_initSubViews
{
    if (!self.tableView) {
        self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
        [self.view addSubview:self.tableView];
        
        self.tableView.tableFooterView = [UIView new];
        self.dataList = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    
    if (!self.waitLabel) {
        self.waitLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 200, kScreenWidth, 100)];
        self.waitLabel.text = @"waiting...";
        self.waitLabel.font = [UIFont systemFontOfSize:18.0f];
        self.waitLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:self.waitLabel];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataList.allKeys.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    
    NSString *key = self.dataList.allKeys[indexPath.section];
    
    cell.textLabel.text = [self.dataList objectForKey:key];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSString *key = self.dataList.allKeys[section];
    return key;
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
        //        _beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:Beacon_Device_UUID] identifier:@"test"];
        _beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:Device_UUID] major:111 minor:222 identifier:@"test"];
        _beaconRegion.notifyEntryStateOnDisplay = YES;
        _beaconRegion.notifyOnEntry = YES;
        _beaconRegion.notifyOnExit = YES;
    }
    return _beaconRegion;
}


- (void)receive
{
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization];
    }
    
    
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
    if (beacons.count > 0 && self.waitLabel) {
        [self.waitLabel removeFromSuperview];
    }
    
    [self.dataList removeAllObjects];
    
    for (CLBeacon *beacon in beacons) {
        NSString *proximityUUID = [NSString stringWithFormat:@"%@",beacon.proximityUUID];
        [self.dataList setObject:proximityUUID forKey:@"UUID:"];
        

        NSString *identifier = [NSString stringWithFormat:@"%@",region.identifier];
        [self.dataList setObject:identifier forKey:@"identifier:"];
        
        NSString *major = [NSString stringWithFormat:@"%@",beacon.major];
        [self.dataList setObject:major forKey:@"major:"];

        NSString *minor = [NSString stringWithFormat:@"%@",beacon.minor];
        [self.dataList setObject:minor forKey:@"minor:"];

        NSString *proximity = [NSString stringWithFormat:@"%d",beacon.proximity];
        [self.dataList setObject:proximity forKey:@"proximity:"];

        NSString *accuracy = [NSString stringWithFormat:@"%f",beacon.accuracy];
        [self.dataList setObject:accuracy forKey:@"accuracy:"];

        NSString *rssi = [NSString stringWithFormat:@"%ld",(long)beacon.rssi];
        [self.dataList setObject:rssi forKey:@"rssi:"];
        
        [self.tableView reloadData];
    }
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



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
