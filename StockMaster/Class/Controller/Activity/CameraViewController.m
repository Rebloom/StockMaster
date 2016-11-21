//
//  CameraViewController.m
//  StockMaster
//
//  Created by dalikeji on 15/2/27.
//  Copyright (c) 2015年 Rebloom. All rights reserved.
//

#import "CameraViewController.h"

@interface CameraViewController ()

@end

@implementation CameraViewController
@synthesize AVSession;
@synthesize previewLayer;

- (void)dealloc
{
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    date = [[NSDate alloc] init];
    cameraTimer = [NSTimer scheduledTimerWithTimeInterval:1.9 target:self selector:@selector(saomiao) userInfo:nil repeats:YES];
    [cameraTimer fire];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [headerView loadComponentsWithTitle:@"扫描邀请码"];
    [headerView backButton];
    [headerView createLine];
    headerView.backgroundColor = kFontColorA;
    [headerView setStatusBarColor:kFontColorA];
    
    [self createUI];
    [self readQRcode];
}

#define ALPHA  0.5
- (void)createUI
{
    for (int i = 0; i<4; i++)
    {
        UIImageView * erweimaImageView = [[UIImageView alloc] init];
        if (i == 0)
        {
            erweimaImageView.frame = CGRectMake((screenWidth - 215)/2, CGRectGetMaxY(headerView.frame) +100, 14, 14);
            erweimaImageView.image = [UIImage imageNamed:@"icon_zuoshang"];
        }
        else if (i ==1 )
        {
            erweimaImageView.frame = CGRectMake((screenWidth - 215)/2+215, CGRectGetMaxY(headerView.frame) +100, 14, 14);
            erweimaImageView.image = [UIImage imageNamed:@"icon_youshang"];
        }
        else if (i == 2)
        {
            erweimaImageView.frame = CGRectMake((screenWidth - 215)/2, CGRectGetMaxY(headerView.frame) +315, 14, 14);
            erweimaImageView.image = [UIImage imageNamed:@"icon_zuoxia"];
        }
        else if (i ==3 )
        {
            erweimaImageView.frame = CGRectMake((screenWidth - 215)/2+215, CGRectGetMaxY(headerView.frame) +315, 14, 14);
            erweimaImageView.image = [UIImage imageNamed:@"icon_youxia"];
        }
        [self.view addSubview:erweimaImageView];
    }
    
    for (int i = 0; i<4; i++)
    {
        UILabel * lineLabel = [[UILabel alloc] init];
        lineLabel.backgroundColor = KLineNewBGColor5;
        if (i == 0)
        {
            lineLabel.frame = CGRectMake((screenWidth - 215)/2+14,CGRectGetMaxY(headerView.frame) + 102, 200, 0.5);
        }
        else if (i == 1)
        {
            lineLabel.frame = CGRectMake((screenWidth - 215)/2+2, CGRectGetMaxY(headerView.frame) +114, 0.5, 201);
        }
        else if (i == 2)
        {
            lineLabel.frame = CGRectMake((screenWidth - 215)/2+226, CGRectGetMaxY(headerView.frame) +114, 0.5, 201);
        }
        else if (i == 3)
        {
            lineLabel.frame = CGRectMake((screenWidth - 215)/2+14, CGRectGetMaxY(headerView.frame) +327, 201, 0.5);
        }
        [self.view addSubview:lineLabel];
        
        
        UIView * view1 = [[UIView alloc] init];
        view1.backgroundColor = [UIColor blackColor];
        if (i == 0)
        {
            view1.frame = CGRectMake(0, 65, screenWidth, 102);
        }
        else if (i ==1 )
        {
            view1.frame = CGRectMake(0, 167, (screenWidth - 215)/2+2, 225);
        }
        else if (i ==2 )
        {
            view1.frame = CGRectMake(CGRectGetMaxX(lineLabel.frame), 167, (screenWidth - 215)/2+2, 225);
            
        }
        else if (i == 3)
        {
            view1.frame = CGRectMake(0, 392, screenWidth, 500);
        }
        view1.alpha = ALPHA;
        [self.view addSubview:view1];
        
    }
    
    UILabel * nameLable = [[UILabel alloc] init];
    nameLable.text = @"将二维码/条形码放置框内,即开始扫描";
    nameLable.textColor = kFontColorA;
    nameLable.textAlignment = NSTextAlignmentCenter;
    nameLable.font = NormalFontWithSize(13);
    nameLable.backgroundColor = [UIColor clearColor];
    nameLable.frame = CGRectMake((screenWidth - 215)/2, CGRectGetMaxY(headerView.frame) +333, 220, 20);
    [self.view addSubview:nameLable];
    
    if (!saomiaoImageView)
    {
        saomiaoImageView = [[UIImageView alloc] init];
    }
    saomiaoImageView.image = [UIImage imageNamed:@"icon_shaomiao"];
    saomiaoImageView.frame = CGRectMake((screenWidth - 215)/2 +7, 170, 221, 6);
    [self.view addSubview:saomiaoImageView];
    
    //    for (int i = 0; i<4; i++)
    //    {
    //           }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [cameraTimer invalidate];
}

- (void)saomiao
{
    saomiaoImageView.frame = CGRectMake((screenWidth - 215)/2 +7, 170, 221, 6);
    saomiaoImageView.hidden = NO;
    
    [UIView beginAnimations:@"Animation" context:nil];
    [UIView setAnimationDuration:2];
    saomiaoImageView.frame = CGRectMake((screenWidth - 215)/2 +7, 390, 221, 6);
    [UIView commitAnimations];
}

#pragma mark - 读取二维码
- (void)readQRcode
{
    // 摄像头设备
    AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // 设置输入
    // 因为模拟器是没有摄像头的，因此在此最好做一个判断
    NSError *error = nil;
    AVCaptureDeviceInput * input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (error)
    {
        NSLog(@"没有摄像头-%@", error.localizedDescription);
        
        return;
    }
    
    // 设置输出(Metadata元数据)
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    
    // 设置输出的代理
    // 说明：使用主线程队列，相应比较同步，使用其他队列，相应不同步，容易让用户产生不好的体验
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    //    [output setMetadataObjectsDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    
    CGSize size = self.view.bounds.size;
    CGRect cropRect = CGRectMake((screenWidth - 215)/2+14, CGRectGetMaxY(headerView.frame) + 102, 201, 201);
    CGFloat p1 = size.height/size.width;
    CGFloat p2 = 1920./1080.;  //使用了1080p的图像输出
    if (p1 < p2) {
        CGFloat fixHeight = self.view.bounds.size.width * 1920. / 1080.;
        CGFloat fixPadding = (fixHeight - size.height)/2;
        output.rectOfInterest = CGRectMake((cropRect.origin.y + fixPadding)/fixHeight,
                                           cropRect.origin.x/size.width,
                                           cropRect.size.height/fixHeight,
                                           cropRect.size.width/size.width);
    } else {
        CGFloat fixWidth = self.view.bounds.size.height * 1080. / 1920.;
        CGFloat fixPadding = (fixWidth - size.width)/2;
        output.rectOfInterest = CGRectMake(cropRect.origin.y/size.height,
                                           (cropRect.origin.x + fixPadding)/fixWidth,
                                           cropRect.size.height/size.height,
                                           cropRect.size.width/fixWidth);
    }
    
    // 拍摄会话
    AVCaptureSession * session = [[AVCaptureSession alloc] init];
    
    // 添加session的输入和输出
    [session addInput:input];
    [session addOutput:output];
    
    // 设置输出的格式
    
    // 提示：一定要先设置会话的输出为output之后，再指定输出的元数据类型！
    [output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    
    // 设置预览图层（用来让用户能够看到扫描情况）
    AVCaptureVideoPreviewLayer *preview = [AVCaptureVideoPreviewLayer layerWithSession:session];
    
    // 设置preview图层的属性
    [preview setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    // 设置preview图层的大小
    [preview setFrame:self.view.bounds];
    
    // 将图层添加到视图的图层
    [self.view.layer insertSublayer:preview atIndex:0];
    self.previewLayer = preview;
    
    // 启动会话
    [session startRunning];
    
    self.AVSession = session;
    
}

#pragma mark - 二维码输出代理方法
// 此方法是在识别到QRCode，并且完成转换
// 如果QRCode的内容越大，转换需要的时间就越长
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection

{
    // 会频繁的扫描，调用代理方法
    // 如果扫描完成，停止会话
    [self.AVSession stopRunning];
    
    // 删除预览图层
    [self.previewLayer removeFromSuperlayer];
    
    NSLog(@"%@", metadataObjects);
    
    // 设置界面显示扫描结果
    if (metadataObjects.count > 0)
    {
        AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];
        
        // 提示：如果需要对url或者名片等信息进行扫描，可以在此进行扩展！
        //        captureLabel.text = obj.stringValue;
        
        NSString * str1 = obj.stringValue;
        NSString * str = nil;
        if (str1.length > 28)
        {
            str = [str1  substringWithRange:NSMakeRange(0,28)];
            
            if ([str isEqualToString:@"https://www.aizhangzhang.com"])
            {
                NSString * string = [str1 substringWithRange:NSMakeRange(str1.length-8, 8)];
                [GFStaticData saveObject:string forKey:KTagInvitationCode];
            }
            else
            {
                [GFStaticData saveObject:@"110" forKey:KTagInvitationCode];
            }
        }
        else
        {
            [GFStaticData saveObject:@"110" forKey:KTagInvitationCode];
        }
        
        [self back];
    }
}


- (void)back
{
    if (self.navigationController && self.navigationController.viewControllers.count>1)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
