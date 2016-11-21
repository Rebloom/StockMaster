//
//  ShakeViewController.h
//  StockMaster
//
//  Created by dalikeji on 14-10-27.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "BasicViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ShakeViewController : BasicViewController
{
    UIImageView * imgUp;
    UIImageView *  imgDown;
    SystemSoundID   soundID;
    UILabel * upLabel;
    UILabel * downLabel;
    UIImageView * showView;
    UIButton * selectBtn;
    UIImageView * imgView;
    BOOL isSelect;
    BOOL isShake;
    
    NSDictionary * stockData;
}

@end
