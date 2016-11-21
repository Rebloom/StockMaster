//
//  RegisterViewController.h
//  StockMaster
//
//  Created by Rebloom on 14-8-1.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "BasicViewController.h"

#import "CheckCodeViewController.h"
#import "GFTextField.h"
#import "ForgetPasswordViewController.h"
#import "GFWebViewController.h"
#import "CHNAlertView.h"

@interface RegisterViewController : BasicViewController <CHNAlertViewDelegate,UITextFieldDelegate,CHNAlertViewDelegate>
{
    GFTextField * phone;
    
    UIButton * nextBtn;
    
    BOOL canRequest;
    
    UIView * mainView;
    
    UIImageView * feetView;
}

@property (nonatomic, assign) NSInteger type;
@property (nonatomic, copy) NSString * registPhone;
@property (nonatomic, copy) NSString * bindString;

@end
