//
//  CMEditPhonographViewController.m
//  Authentication
//
//  Created by zh_s on 2018/4/26.
//  Copyright © 2018年 HangZhou CheMao Network techonology Co.,Ltd. All rights reserved.
//

#import "CMEditPhonographViewController.h"
#import "UIImage+Rotate.h"//问题1
#import <AVFoundation/AVFoundation.h>


@interface CMEditPhonographViewController (){
    UIImage *imageIm;
    CGRect cropFrame;
}
@property (nonatomic,assign)BOOL isPop;
@property (nonatomic, strong)UIButton *shutterButton;
@property (nonatomic, strong)UIImageView *backImage;

@end

@implementation CMEditPhonographViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.userInteractionEnabled =YES;
    self.title =@"自定义相机";
    
    self.view.backgroundColor =[UIColor blackColor];
    //背景

    [self bottomView];

    
}
- (void)bottomView {
    
    
    UIView *topView =[[UIView alloc] init];
    [self.view addSubview:topView];
    topView.frame =CGRectMake(0, 0, SCREEN_WIDTH, 44);
    topView.backgroundColor =[UIColor blackColor];
    
    //前面拿过来的
    UIView *bottomView =[[UIView alloc] init];
    [self.view addSubview:bottomView];
//    bottomView.backgroundColor =RGB(26,29,34);
    bottomView.backgroundColor =[UIColor blackColor];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.view.mas_bottom);
        make.left.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH, 120));
    }];
    
    
    UIButton *rotatingBtn =[UIButton buttonWithType:UIButtonTypeCustom];
    [bottomView addSubview:rotatingBtn];
    [rotatingBtn setTitle:@"旋转" forState:UIControlStateNormal];
    [rotatingBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(bottomView.mas_bottom).mas_offset(-15);
        make.centerX.mas_equalTo(bottomView.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(56, 56));
    }];
    [rotatingBtn addTarget:self action:@selector(rotating) forControlEvents:UIControlEventTouchUpInside];
    
    self.shutterButton.tag =1021;
    self.shutterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [bottomView addSubview:self.shutterButton];
    [self.shutterButton setTitle:@"重拍" forState:UIControlStateNormal];
    [self.shutterButton addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.shutterButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(rotatingBtn.mas_centerY);
        make.left.mas_equalTo(20);
        make.size.mas_equalTo(CGSizeMake(50, 32));
    }];

    
    UIButton *flashlightBtn =[UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:flashlightBtn];
    [flashlightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(bottomView.mas_right).mas_offset(-20);
//        make.bottom.mas_equalTo(bottomView.mas_bottom).mas_offset(-15);
        make.centerY.mas_equalTo(rotatingBtn.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(87, 32));
    }];
    flashlightBtn.tag =1001;
    [flashlightBtn setTitle:@"使用图片" forState:UIControlStateNormal];
//    flashlightBtn.titleLabel.font =FONT(16);
    [flashlightBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
}


- (void)setDataImage:(UIImage *)dataImage {
    _dataImage =dataImage;
    UIImageView *image =[[UIImageView alloc] init];
    image.frame = self.view.frame;
    [self.view addSubview:image];
    image.image =_dataImage;
    //问题2
    image.contentMode =UIImageRenderingModeAlwaysOriginal;
    _backImage =image;
    //问题3
    if (_backImage.image.size.width >_backImage.image.size.height) {
        
    }else{
        self.backImage.image = [self.backImage.image rotate:UIImageOrientationRight];
    }
    [self.view sendSubviewToBack:self.backImage];
    
}
/*
 - (void)setData:(NSData *)data {
 _data = data;
 UIImageView *image =[[UIImageView alloc] init];
 image.frame = self.view.frame;
 //    image.frame =CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-HEIGHT_CONSTARIN(120));
 //CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-HEIGHT_CONSTARIN(120));
 [self.view addSubview:image];
 image.image =[UIImage imageWithData:_data];
 //    image.userInteractionEnabled =YES;
 image.contentMode =UIImageRenderingModeAlwaysOriginal;
 _backImage =image;
 if (_backImage.image.size.width >_backImage.image.size.height) {
 
 }else{
 self.backImage.image = [self.backImage.image rotate:UIImageOrientationRight];
 }
 [self.view sendSubviewToBack:self.backImage];
 }
 */


#pragma mark ---btnAction
- (void)btnClick:(UIButton *)sender {
    if (sender.tag ==1001) {//确认
        if (self.backImage.image.size.width <self.backImage.image.size.height) {
           
            return;
        }
        [self dismissViewControllerAnimated:NO completion:^{
            self.dataBlock(1, self.backImage.image);
        }];

//        [self saveImage:self.backImage.image];
        
        
    }else{//重拍
        [self dismissViewControllerAnimated:NO completion:^{
        }];
       
    }

}
#pragma mark --旋转
- (void)rotating {
    self.backImage.image = [self.backImage.image rotate:UIImageOrientationRight];
}

//保存本地,调试用
- (void)saveImage:(UIImage *)image {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{//        UIImage *imagenew =[image scaleImageToSize:CGSizeMake(3264, 2448)];
        
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    });
}

//参考:https://blog.csdn.net/czh880410/article/details/51745795
- (UIImage *)getImageByCuttingImage:( UIImage *)image Rect:( CGRect )rect{
    
    // 大图 bigImage
    
    // 定义 myImageRect ，截图的区域
    
    CGRect myImageRect = rect;
    
    UIImage * bigImage= image;
    
    CGImageRef imageRef = bigImage. CGImage ;
    
    CGImageRef subImageRef = CGImageCreateWithImageInRect (imageRef, myImageRect);
    
    CGSize size;
    
    size. width = rect. size . width ;
    
    size. height = rect. size . height ;
    
    UIGraphicsBeginImageContext (size);
    
    CGContextRef context = UIGraphicsGetCurrentContext ();
    
    CGContextDrawImage (context, myImageRect, subImageRef);
    
    UIImage * smallImage = [ UIImage imageWithCGImage :subImageRef];
    
    UIGraphicsEndImageContext ();
    
    return smallImage;
    
}




@end
