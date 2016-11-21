//
//  CheckCodeViewController.h
//  StockMaster
//
//  Created by Rebloom on 14-8-1.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "BasicViewController.h"
#import "GFTextField.h"
@interface CheckCodeViewController : BasicViewController<HeaderViewDelegate,UITextFieldDelegate>
{
    GFTextField * phone;
    UIButton * getBtn;
    NSTimer * checkTimer;
    NSInteger time;
    NSInteger codeFlag;
    NSDate * date;
}

@property (nonatomic, copy) NSString * passPhone;
@property (nonatomic, copy) NSString * passCode;
@property (nonatomic, assign) NSInteger flag;
@property (nonatomic, assign) NSInteger type;

@end
