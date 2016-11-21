//
//  CameraViewController.h
//  StockMaster
//
//  Created by dalikeji on 15/2/27.
//  Copyright (c) 2015年 Rebloom. All rights reserved.
//

#import "BasicViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface CameraViewController : BasicViewController<AVCaptureMetadataOutputObjectsDelegate>
{
    UIImageView * saomiaoImageView;
    NSTimer * cameraTimer;
    NSDate * date;
}
@property(strong, nonatomic) AVCaptureSession * AVSession; // 二维码生成的绘画
@property(strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;  // 二维码生成的图层

@end
