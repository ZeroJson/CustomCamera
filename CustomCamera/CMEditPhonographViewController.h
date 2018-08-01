//
//  CMEditPhonographViewController.h
//  Authentication
//
//  Created by zh_s on 2018/4/26.
//  Copyright © 2018年 HangZhou CheMao Network techonology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^EditPhonigraohblock)();
typedef void(^EditPhonigraohblockData)(NSInteger index,UIImage *imageData);

@interface CMEditPhonographViewController : UIViewController

@property(nonatomic,strong)NSData *data;
@property(nonatomic,strong)UIImage *dataImage;

@property (nonatomic, copy)EditPhonigraohblock block;
@property (nonatomic, copy)EditPhonigraohblockData dataBlock;

@end
