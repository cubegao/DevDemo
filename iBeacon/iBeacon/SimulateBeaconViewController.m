//
//  SimulateBeaconViewController.m
//  iBeacon
//
//  Created by Gaowz on 2018/5/31.
//  Copyright © 2018年 gawoz. All rights reserved.
//

#import "SimulateBeaconViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>

#define Device_UUID @"29EA3478-2C37-4BAA-81C9-01FA5889AF2B"


@interface SimulateBeaconViewController ()<CBPeripheralManagerDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic , strong) CBPeripheralManager *peripheralManager;

@property (nonatomic , strong) UITableView *tableView;
@property (nonatomic , strong) NSMutableDictionary *dataList;

@end

@implementation SimulateBeaconViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _initSubViews];
    
    if (!self.peripheralManager) {
        self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:nil];
    }

}


- (void)send
{
    if (self.dataList) {
        [self.dataList removeAllObjects];
    }
    
    NSString *UUID = [NSString stringWithFormat:@"%@",Device_UUID];
    [self.dataList setObject:UUID forKey:@"UUID:"];
    
    
    NSString *major = [NSString stringWithFormat:@"%@",@"111"];
    [self.dataList setObject:major forKey:@"major:"];
    
    NSString *minor = [NSString stringWithFormat:@"%@",@"222"];
    [self.dataList setObject:minor forKey:@"minor:"];
    
    NSString *identifier = [NSString stringWithFormat:@"%@",@"test"];
    [self.dataList setObject:identifier forKey:@"identifier:"];
    
    
    NSUUID *proximityUUID = [[NSUUID alloc] initWithUUIDString:UUID];
    //创建beacon区域
    CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID major:[major integerValue] minor:[minor integerValue] identifier:identifier];
    NSDictionary *beaconPeripheraData = [beaconRegion peripheralDataWithMeasuredPower:nil];
    
    if(beaconPeripheraData) {
        [self.peripheralManager startAdvertising:beaconPeripheraData];;//开始广播
    }
    
}


- (void)peripheralManagerDidUpdateState:(nonnull CBPeripheralManager *)peripheral {
    
    if (peripheral.state == CBManagerStatePoweredOn)
    {
        // Bluetooth is on
        
        // Update our status label
        NSLog(@"Broadcasting...");
        
        // Start broadcasting
        [self send];
        [self.dataList setObject:@"Broadcasting..." forKey:@"当前状态:"];

    }
    else if (peripheral.state == CBManagerStatePoweredOff)
    {
        // Update our status label
        NSLog(@"Stopped...");
        [self.dataList setObject:@"Stopped" forKey:@"当前状态:"];

    }
    
    [self.tableView reloadData];
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
}

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
