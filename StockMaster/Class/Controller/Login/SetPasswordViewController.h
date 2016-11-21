//
//  SetPasswordViewController.h
//  StockMaster
//
//  Created by Rebloom on 14-8-1.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "BasicViewController.h"

#import "SetNicknameViewController.h"
#import "GFTextField.h"
#import "CHNAlertView.h"
@interface SetPasswordViewController : BasicViewController<UITextFieldDelegate,CHNAlertViewDelegate,UIGestureRecognizerDelegate>
{
    GFTextField * firstPass;
    GFTextField * secondPass;
    NSInteger  alertViewTag;
    
    BOOL isFirst; //判断是否输入密码
    BOOL isSecond; //判断是否重新输入密码
    BOOL isBack;
}

@property (nonatomic, copy) NSString * passPhone;
@property (nonatomic, copy) NSString * sms_code;
@property (nonatomic, assign) NSInteger flag;
@end
