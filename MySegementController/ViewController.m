//
//  ViewController.m
//  MySegementController
//
//  Created by 金峰 on 16/9/11.
//  Copyright © 2016年 金峰. All rights reserved.
//

#import "ViewController.h"
#import "CCZSegementController.h"
#import "FirstViewController.h"
#import "SecondViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor  =[UIColor blackColor];
    
    FirstViewController *f = [[FirstViewController alloc] init];
    SecondViewController *s = [[SecondViewController alloc] init];
    FirstViewController *f1 = [[FirstViewController alloc] init];
    SecondViewController *s1 = [[SecondViewController alloc] init];

    FirstViewController *f2 = [[FirstViewController alloc] init];
    SecondViewController *s2 = [[SecondViewController alloc] init];

    FirstViewController *f3 = [[FirstViewController alloc] init];
    SecondViewController *s3 = [[SecondViewController alloc] init];
    
    FirstViewController *f4 = [[FirstViewController alloc] init];
    SecondViewController *s4 = [[SecondViewController alloc] init];
    
    FirstViewController *f5 = [[FirstViewController alloc] init];
    SecondViewController *s5 = [[SecondViewController alloc] init];


    
    CCZSegementController *segement = [CCZSegementController segementControllerWithFrame:CGRectMake(0, 100, self.view.bounds.size.width, self.view.bounds.size.height) titles:@[@"热门",@"游戏直播",@"天天向上",@"天气",@"我的天这是复哈风",@"新闻",@"直播",@"哈哈哈哈哈",@"Top10",@"新闻",@"直播",@"Top10"]];
    [segement setSegementTintColor:[UIColor greenColor]];
    [segement setSegementViewControllers:@[f,s,f1,s1,f2,s2,s3,f3,f4,s4,f5,s5]];
    [segement setSelectedItemAtIndex:3];
    [segement selectedAtIndex:^(NSInteger index) {
        NSLog(@"index %ld",index);
    }];
    [self.view addSubview:segement.view];
    [self addChildViewController:segement];
    
}


@end
