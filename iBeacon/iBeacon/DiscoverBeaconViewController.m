//
//  DiscoverBeaconViewController.m
//  iBeacon
//
//  Created by Gaowz on 2018/5/31.
//  Copyright © 2018年 gawoz. All rights reserved.
//

#define kNotificationName @"kNotificationNamePostIbeacon"
#define Device_UUID @"29EA3478-2C37-4BAA-81C9-01FA5889AF2B"
#define kScreenHeight ([UIScreen mainScreen].bounds.size.height)
#define kScreenWidth ([UIScreen mainScreen].bounds.size.width)
#define kScreenBounds [UIScreen mainScreen].bounds

#import "DiscoverBeaconViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>
#import "LocalPush.h"
#import "AppDelegate.h"

@interface DiscoverBeaconViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic , strong) UITableView *tableView;
@property (nonatomic , strong) UILabel *waitLabel;
@property (nonatomic , strong) NSMutableDictionary *dataList;


@end

@implementation DiscoverBeaconViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:kNotificationName object:nil];
    
    [self _initSubViews];
    
    [(AppDelegate *)[UIApplication sharedApplication].delegate receive];
    
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


- (void)receiveNotification:(NSNotification *)info
{
    NSDictionary *dic = info.object;
    NSArray<CLBeacon *> *beacons = dic[@"beacons"];
    CLRegion *region = dic[@"region"];
    
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
