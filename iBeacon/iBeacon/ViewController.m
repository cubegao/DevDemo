//
//  ViewController.m
//  iBeacon
//
//  Created by Gaowz on 2018/5/31.
//  Copyright © 2018年 gawoz. All rights reserved.
//

#import "ViewController.h"
#import "DiscoverBeaconViewController.h"
#import "SimulateBeaconViewController.h"

#define kScreenHeight ([UIScreen mainScreen].bounds.size.height)
#define kScreenWidth ([UIScreen mainScreen].bounds.size.width)
#define kScreenBounds [UIScreen mainScreen].bounds

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *discoverBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    discoverBtn.frame = CGRectMake((kScreenWidth-kScreenWidth/2)/2, 100, kScreenWidth/2, kScreenWidth/2);
    discoverBtn.backgroundColor = [UIColor colorWithRed:38/255.0 green:184/255.0 blue:242/255.0 alpha:1];
    discoverBtn.layer.cornerRadius = discoverBtn.frame.size.height/2;
    discoverBtn.layer.masksToBounds = YES;
    discoverBtn.layer.borderWidth = 1;
    discoverBtn.layer.borderColor = [UIColor clearColor].CGColor;
    [discoverBtn setTitle:@"discover beacon" forState:UIControlStateNormal];
    [self.view addSubview:discoverBtn];
    
    
    UIButton *simulateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    simulateBtn.frame = CGRectMake((kScreenWidth-kScreenWidth/2)/2, 100+kScreenWidth/2+50, kScreenWidth/2, kScreenWidth/2);
    simulateBtn.backgroundColor = [UIColor colorWithRed:38/255.0 green:184/255.0 blue:242/255.0 alpha:1];
    simulateBtn.layer.cornerRadius = simulateBtn.frame.size.height/2;
    simulateBtn.layer.masksToBounds = YES;
    simulateBtn.layer.borderWidth = 1;
    simulateBtn.layer.borderColor = [UIColor clearColor].CGColor;
    [simulateBtn setTitle:@"simulate beacon" forState:UIControlStateNormal];
    [self.view addSubview:simulateBtn];
    
    [discoverBtn addTarget:self action:@selector(pushTo:) forControlEvents:UIControlEventTouchUpInside];
    [simulateBtn addTarget:self action:@selector(pushTo:) forControlEvents:UIControlEventTouchUpInside];

}

- (void)pushTo:(UIButton *)btn
{
    if ([btn.titleLabel.text isEqual:@"discover beacon"]) {
        DiscoverBeaconViewController *dbVC = [[DiscoverBeaconViewController alloc] init];
        dbVC.title = @"discover beacon";
        [self.navigationController pushViewController:dbVC animated:YES];
        
    }else {
        SimulateBeaconViewController *sbVC = [[SimulateBeaconViewController alloc] init];
        sbVC.title = @"simulate beacon";
        [self.navigationController pushViewController:sbVC animated:YES];
        
    }
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
