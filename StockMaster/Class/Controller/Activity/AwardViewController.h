//
//  AwardViewController.h
//  StockMaster
//
//  Created by dalikeji on 15/1/28.
//  Copyright (c) 2015年 Rebloom. All rights reserved.
//

#import "BasicViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "GFTextField.h"

@interface AwardViewController : BasicViewController<UITextFieldDelegate,AVCaptureMetadataOutputObjectsDelegate,UIGestureRecognizerDelegate>
{
    GFTextField * awardTF;
    UIButton * awardBtn;
    UIView * mainView ;
    UILabel * captureLabel;
    NSString * codeString;
}
@property(strong, nonatomic) AVCaptureSession * AVSession; // 二维码生成的绘画
@property(strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;  // 二维码生成的图层

@end
