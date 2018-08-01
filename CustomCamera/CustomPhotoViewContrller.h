//
//  CustomPhotoViewContrller.h
//  BaseProject
//
//  Created by zh_s on 2018/4/18.
//  Copyright © 2018年 chemao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol CustomPhotoDelegate <NSObject>//协议

- (void)backWithImage:(UIImage *)image;//协议方法

@end

@interface CustomPhotoViewContrller :UIViewController;

@property (nonatomic, strong) AVCaptureSession* session;
/**
 *  输入设备
 */
@property (nonatomic, strong) AVCaptureDeviceInput* videoInput;
/**
 *  照片输出流
 */
@property (nonatomic, strong) AVCaptureStillImageOutput* stillImageOutput;
/**
 *  预览图层
 */
@property (nonatomic, strong) AVCaptureVideoPreviewLayer* previewLayer;

/**
 *  最后的缩放比例
 */
@property(nonatomic,assign)CGFloat effectiveScale;
@property (nonatomic, strong) UIView *backView;

@property(nonatomic, assign) id<CustomPhotoDelegate>delegate;

@end
