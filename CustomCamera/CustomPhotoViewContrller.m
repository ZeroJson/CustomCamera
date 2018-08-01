//
//  CustomPhotoViewContrller.m
//  BaseProject
//
//  Created by zh_s on 2018/4/18.
//  Copyright © 2018年 chemao. All rights reserved.
//

#import "CustomPhotoViewContrller.h"
#import "CMEditPhonographViewController.h"
#import <CoreMotion/CoreMotion.h>
#import "DeviceOrientation.h"
@interface CustomPhotoViewContrller ()<DeviceOrientationDelegate>{
    UIImage *imageIm;
    UIImageView *photoImage;
    DeviceOrientation *deviceMotion;
}
@property (nonatomic,assign)NSInteger requestTime;
@property (nonatomic,strong)AVCaptureDevice *device;

@property (nonatomic,strong)UIImageView *midImageView;//中间的方框
@property (nonatomic,strong)UIButton *torchButton;//手电筒图标
@property (nonatomic,strong)UIImageView *lineView;//指示线
@property (nonatomic,assign)CGFloat offset;//指示线的偏移量
@property (nonatomic,strong)NSTimer *timer;//打点计时器
@property (nonatomic,assign)BOOL hasRight;
@property (nonatomic,assign)NSInteger state;//1.不隐藏状态栏
@property (nonatomic,copy)  NSString *orderNum;
@property (nonatomic, copy) NSString *deviceOrientation;//设备方向

@property (nonatomic, strong)UIButton *shutterButton;
@property (nonatomic, strong)UIButton *flashlightBtn;
@property (nonatomic, strong)UIImageView *backImage;


@property (nonatomic, strong)UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) UIView *focusView;
@property (nonatomic, strong) UILabel *contentLab;

@end

@implementation CustomPhotoViewContrller

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title =@"自定义相机";
    //方向判断
    deviceMotion = [[DeviceOrientation alloc]initWithDelegate:self];
    [deviceMotion startMonitor];
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusRestricted || status == AVAuthorizationStatusDenied){
        _hasRight = NO;
        ALERT(@"请在iPhone的“设置-隐私-相机”选项中，允许***访问您的相机");
    }else {
        _hasRight = YES;
    }
    
    CMMotionManager *motionManager = [[CMMotionManager alloc] init];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    //加速器
    if (motionManager.accelerometerAvailable) {
        motionManager.accelerometerUpdateInterval =1;
        [motionManager startGyroUpdatesToQueue:queue withHandler:^(CMGyroData * _Nullable gyroData, NSError * _Nullable error) {
            if (error) {
                [motionManager stopAccelerometerUpdates];
//                NSLog(@"error=%@",error);
            }else{
//                NSLog(@"x 加速度--> %f\n y 加速度--> %f\n z 加速度--> %f\n", motionManager.accelerometerData.acceleration.x, motionManager.accelerometerData.acceleration.y, motionManager.accelerometerData.acceleration.z);
            }
        }];
        
    }
    //创建中间的图像框及其四周的阴影
    [self createMidRect];
    //设置相机属性
    [self initAVCaptureSession]; //设置相机属性
    self.effectiveScale = 1.0f;

    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    if (self.session) {
        [self.session startRunning];
    }
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    //隐藏状态栏
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:NO];

}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:YES];
    if (self.session) {
        
        [self.session stopRunning];
    }
    if (_state ==1) {
        [self.navigationController setNavigationBarHidden:YES animated:NO];
    }else{
        [self.navigationController setNavigationBarHidden:NO animated:NO];
    }
    //显示状态栏
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];

}

#pragma mark -- 添加中间的框框
- (void)createMidRect {
    self.view.userInteractionEnabled =YES;
    UIView *bgView =[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 120)];
    [self.view addSubview:bgView];
    bgView.userInteractionEnabled =YES;
    _backView =bgView;
  
    UIView *topView =[[UIView alloc] init];
    [self.view addSubview:topView];
    topView.frame =CGRectMake(0, 0, SCREEN_WIDTH, 44);
    topView.backgroundColor =[UIColor blackColor];
    
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    //画限制线
    UIView *view = nil;
    
    view = [[UIView alloc] initWithFrame:CGRectMake(90.0 / 414 * width, 44.0, 3, 552.0 / 736 * height)];
    if (width == 320 && [[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
        view = [[UIView alloc] initWithFrame:CGRectMake(87.0 / 414 * width, 64.0, 3, 436)];
    }
    
    [view setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:view];
    
    UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(324.0 / 414 * width, 44.0, 3, 552.0 / 736 * height)];
    if (width == 320 && [[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
        view2 = [[UIView alloc] initWithFrame:CGRectMake(324.0 / 414 * width, 64.0, 3, 436)];
    }
    
    [view2 setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:view2];
    
    UIView *view3 = [[UIView alloc] initWithFrame:CGRectMake(0, 120.0 / 736 * height, width, 3)];
    if (width == 320 && [[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
        view3 = [[UIView alloc] initWithFrame:CGRectMake(0, 130, width, 3)];
    }
    
    [view3 setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:view3];
    
    UIView *view4 = [[UIView alloc] initWithFrame:CGRectMake(0, 520.0 / 736 * height, width, 3)];
    if (width == 320 && [[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
        view4 = [[UIView alloc] initWithFrame:CGRectMake(0, 431, width, 3)];
    }
    
    [view4 setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:view4];

    
    UIView *bottomView =[[UIView alloc] init];
    [self.view addSubview:bottomView];
//    bottomView.backgroundColor =RGB(26,29,34);
    bottomView.backgroundColor =[UIColor blackColor];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.view.mas_bottom);
        make.left.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH, 120+44));
    }];

    
    /*
     * 对焦手势
     */
    _tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(focusGesture:)];
    [self.view addGestureRecognizer:_tapGesture];
    
    /*
     * 对焦效果view
     */
    _focusView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 80, 80)];
    _focusView.layer.borderWidth = 1.0;
    _focusView.layer.borderColor =[UIColor orangeColor].CGColor;
    _focusView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_focusView];
    _focusView.hidden = YES;

    self.shutterButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [bottomView addSubview:self.shutterButton];
    [self.shutterButton setBackgroundImage:IMAGE_NAME(@"确定") forState:UIControlStateNormal];
    [self.shutterButton setBackgroundImage:IMAGE_NAME(@"确定") forState:UIControlStateSelected];
//    self.shutterButton.backgroundColor =[UIColor whiteColor];
    [self.shutterButton addTarget:self action:@selector(buttondown) forControlEvents:UIControlEventTouchUpInside];
    [self.shutterButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(bottomView.mas_top).offset(40);
        make.centerX.equalTo(self.view.mas_centerX);
        make.width.mas_equalTo(64);
        make.height.mas_equalTo(64);
    }];
    
    //闪光灯
    UIButton *flashlightBtn =[UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:flashlightBtn];
    [flashlightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(bottomView.mas_right).mas_offset(-55);
        make.centerY.mas_equalTo(self.shutterButton.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(35, 35));
    }];
    
    [flashlightBtn setBackgroundImage:IMAGE_NAME(@"bd_ocr_light_off") forState:UIControlStateNormal];
    [flashlightBtn setBackgroundImage:IMAGE_NAME(@"bd_ocr_light_on") forState:UIControlStateSelected];
    [flashlightBtn addTarget:self action:@selector(flashlightBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    _flashlightBtn =flashlightBtn;
    
    self.shutterButton.tag =1021;
    self.shutterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [bottomView addSubview:self.shutterButton];
    [self.shutterButton setTitle:@"取消" forState:UIControlStateNormal];
    [self.shutterButton addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.shutterButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(flashlightBtn.mas_centerY);
        make.left.mas_equalTo(20);
        make.size.mas_equalTo(CGSizeMake(50, 32));
    }];

}


//设置相机属性
- (void)initAVCaptureSession{
    
    self.session = [[AVCaptureSession alloc] init];
    /*
     *NSString *const AVCaptureSessionPresetPhoto;//最高质量3264*2448 1.3
     *NSString *const AVCaptureSessionPresetHigh;
     *NSString *const AVCaptureSessionPresetMedium;
     *NSString *const AVCaptureSessionPresetLow;
     *NSString *const AVCaptureSessionPreset640x480;//1.3 模糊
     *NSString *const AVCaptureSessionPreset1280x720;//1.7
     *NSString *const AVCaptureSessionPreset1920x1080;//1.7
     *NSString *const AVCaptureSessionPresetiFrame960x540;//1.7
     *NSString *const AVCaptureSessionPresetiFrame1280x720;//1.7
     *NSString *const AVCaptureSessionPresetInputPriority;
     第一个代表高像素图片输出；接下来三种为相对预设(low, medium, high)，这些预设的编码配置会因设备不同而不同，如果选择high，那么你选定的相机会提供给你该设备所能支持的最高画质；再后面就是特定分辨率的预设(352x288 VGA, 1920x1080 VGA, 1280x720 VGA, 640x480 VGA, 960x540 iFrame, 1280x720 iFrame)；最后一个代表 capture session 不去控制音频与视频输出设置，而是通过已连接的捕获设备的 activeFormat 来反过来控制 capture session 的输出质量等级
     
     注意：所有对 capture session 的调用都是阻塞的，因此建议将它们分配到后台串行队列中，不过这里为了简单，不考虑性能，所以省略了dispatch queue
     链接：https://www.jianshu.com/p/8c7ca1dd7f02
     */
    [self.session setSessionPreset:AVCaptureSessionPresetPhoto];
    
    NSError *error;
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    _device =device;
    //更改这个设置的时候必须先锁定设备，修改完后再解锁，否则崩溃
    [device lockForConfiguration:nil];
    //设置闪光灯为自动
    [device setFlashMode:AVCaptureFlashModeOff];
    [device unlockForConfiguration];
    
    self.videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:device error:&error];
    AVCaptureVideoDataOutput *captureOutput = [[AVCaptureVideoDataOutput alloc] init];
    if (error) {
        NSLog(@"%@",error);
    }
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    //输出设置。AVVideoCodecJPEG   输出jpeg格式图片
    NSDictionary * outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey, nil];
    [self.stillImageOutput setOutputSettings:outputSettings];
    
    if ([self.session canAddInput:self.videoInput]) {
        [self.session addInput:self.videoInput];
    }
    if ([self.session canAddOutput:captureOutput]) {
        [self.session addOutput:captureOutput];
    }
    if ([self.session canAddOutput:self.stillImageOutput]) {
        [self.session addOutput:self.stillImageOutput];
    }
    
    //初始化预览图层
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    self.previewLayer.frame = CGRectMake(0, 0,SCREEN_WIDTH, SCREEN_HEIGHT -120 -44);
    self.backView.layer.masksToBounds = YES;
    [self.backView.layer addSublayer:self.previewLayer];
}
- (AVCaptureVideoOrientation)avOrientationForDeviceOrientation:(UIDeviceOrientation)deviceOrientation
{
    AVCaptureVideoOrientation result = (AVCaptureVideoOrientation)deviceOrientation;
    
    if ([_deviceOrientation isEqualToString:@"protrait"]) {//
        result = AVCaptureVideoOrientationPortrait;
    }else if ([_deviceOrientation isEqualToString:@"down"]){
        result = AVCaptureVideoOrientationLandscapeRight;
    }else if ([_deviceOrientation isEqualToString:@"right"]){
        result = AVCaptureVideoOrientationLandscapeLeft;
    }else if ([_deviceOrientation isEqualToString:@"left"]){
        result = AVCaptureVideoOrientationLandscapeRight;
    }
    return result;
}

#pragma mark ---pushEditImageVc
//照相按钮点击事件
-(void)buttondown{
    NSLog(@"takephotoClick...");
    AVCaptureConnection *stillImageConnection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    //获取设备方向
    UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
    //获取设备方向
//    UIInterfaceOrientation deviceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    //获取设备方向，再配置图片输出的时候需要使用
    AVCaptureVideoOrientation avcaptureOrientation = [self avOrientationForDeviceOrientation:curDeviceOrientation];
    [stillImageConnection setVideoOrientation:avcaptureOrientation];
    [stillImageConnection setVideoScaleAndCropFactor:self.effectiveScale];
//    AVCapturePhotoOutput ios10 替代AVCaptureStillImageOutput
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:stillImageConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (!error) {//两种解决方案 https://www.aliyun.com/jiaocheng/369599.html
            if (imageDataSampleBuffer ==NULL) {
                //没有获取到图片
            }
            NSData *jpegData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            UIImage *image =[UIImage imageWithData:jpegData];
//            UIImage *imagenew =[image scaleImageToSize:CGSizeMake(3264, 2448)];

            [self makeImageView:jpegData withImage:image];
        }else{
            //相机初始化失败
        }
    }];
}


//拍照之后调到相片详情页面
-(void)makeImageView:(NSData*)data withImage:(UIImage *)image{
    CMEditPhonographViewController *imageView = [[CMEditPhonographViewController alloc] init];
//    CMNavigationController * nav = [[CMNavigationController alloc]   initWithRootViewController:imageView];
    imageView.data = data;
    imageView.dataImage =image;
    
    imageView.block = ^{
        [self popViewController];
    };
    imageView.dataBlock = ^(NSInteger index, UIImage *imageData) {
        _state =index;
        [self dismissViewControllerAnimated:YES completion:^{
            if ([self.delegate respondsToSelector:@selector(backWithImage:)]) {
                [self.delegate backWithImage:imageData];
            }
        }];
//        [self pushVinPhotoVCWithImage:imageData];
    };
    
    [self presentViewController:imageView animated:NO completion:^{
        //切换不了状态
        [_flashlightBtn setImage:IMAGE_NAME(@"bd_ocr_light_off") forState:UIControlStateNormal];
    }];

    
}
- (void)pushVinPhotoVCWithImage:(UIImage *)image {
  
}

- (void)popViewController {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark ---Action
- (void)btnClick:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


//闪光灯
- (void)flashlightBtnClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    if ([_device hasTorch] && [_device hasFlash]){
        [_device lockForConfiguration:nil];
        if (sender.selected) {
            [_device setTorchMode:AVCaptureTorchModeOn];
            [_device setFlashMode:AVCaptureFlashModeOn];
        }else {
            [_device setTorchMode:AVCaptureTorchModeOff];
            [_device setFlashMode:AVCaptureFlashModeOff];
        }
        [_device unlockForConfiguration];
    }
}

//聚焦
- (void)focusGesture:(UITapGestureRecognizer*)gesture{
    CGPoint point = [gesture locationInView:gesture.view];
    [self focusAtPoint:point];
}

- (void)focusAtPoint:(CGPoint)point{
    //上下黑色部分 点击无效
    if (point.y >SCREEN_HEIGHT -120 ||point.y <45) {
        return;
    }
    CGSize size = self.view.bounds.size;
    CGPoint focusPoint = CGPointMake( point.y /size.height ,1-point.x/size.width );
    NSError *error;
    
//    AVCaptureTorchMode *captureManager;
    if ([_device lockForConfiguration:&error]) {
        if ([_device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            [_device setFocusPointOfInterest:focusPoint];
            [_device setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        [_device unlockForConfiguration];
    }
    /*
     * 下面是手触碰屏幕后对焦的效果
     */
    _focusView.center = point;
    _focusView.hidden = NO;
    
    [UIView animateWithDuration:0.3 animations:^{
        _focusView.transform = CGAffineTransformMakeScale(1.25, 1.25);
    }completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 animations:^{
            _focusView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            _focusView.hidden = YES;
        }];
    }];
}

- (void)directionChange:(TgDirection)direction {
    
    switch (direction) {
        case TgDirectionPortrait:
            
//            SHOW_TIPS(@"竖着");
            _deviceOrientation =@"protrait";
//            self.loglabel.text = @"protrait";
            
            break;
        case TgDirectionDown:
//            SHOW_TIPS(@"倒着");
            _deviceOrientation =@"down";
//            self.loglabel.text = @"down";
            
            break;
        case TgDirectionRight:
//            SHOW_TIPS(@"home在左手");
            _deviceOrientation =@"right";
//            self.loglabel.text = @"right";
            
            break;
        case TgDirectionleft:
//            SHOW_TIPS(@"home在右手");
            _deviceOrientation =@"left";
//            self.loglabel.text = @"left";
            
            break;
            
        default:
            break;
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
