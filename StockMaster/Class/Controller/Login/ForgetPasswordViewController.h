//
//  ForgetPasswordViewController.h
//  StockMaster
//
//  Created by dalikeji on 14-8-29.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "BasicViewController.h"
#import "GFTextField.h"
#import "CheckCodeViewController.h"
#import "CHNAlertView.h"

@interface ForgetPasswordViewController : BasicViewController<UITextFieldDelegate,CHNAlertViewDelegate,CHNAlertViewDelegate>
{
    GFTextField * phone;
    UIView * mainView;
    
    UIImageView * feetView;
    
    NSDate * date;
    
    NSInteger  time;
}
@property (nonatomic, assign)NSInteger type;
@property (nonatomic, copy) NSString * phoneNum;
@end
