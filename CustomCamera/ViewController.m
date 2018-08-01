//
//  ViewController.m
//  CustomCamera
//
//  Created by zh_s on 2018/8/1.
//  Copyright © 2018年 chemao. All rights reserved.
//

#import "ViewController.h"
#import "CustomPhotoViewContrller.h"

@interface ViewController ()<CustomPhotoDelegate>{
    UIImageView *imageV;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *btn =[UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"拍照" forState:0];
    btn.backgroundColor =[UIColor blackColor];
    btn.frame =CGRectMake(100, 80, 160, 43);
    [self.view addSubview:btn];
    [btn addTarget:self action:sel_registerName("btnClick") forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *imageView =[[UIImageView alloc] init];
    imageView.frame =CGRectMake(50, 300, SCREEN_WIDTH -100, (SCREEN_WIDTH -100) /1.3);
    [self.view addSubview:imageView];
    imageV =imageView;

    // Do any additional setup after loading the view, typically from a nib.
}

#pragma mark --CustomePhototDelegate
- (void)backWithImage:(UIImage *)image {
    imageV.image =image;
}


- (void)btnClick {
    CustomPhotoViewContrller *vc =[[CustomPhotoViewContrller alloc] init];
    vc.delegate =self;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
