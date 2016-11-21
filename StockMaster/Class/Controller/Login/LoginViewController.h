//
//  LoginViewController.h
//  StockMaster
//
//  Created by Rebloom on 14-7-28.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "BasicViewController.h"
#import "HomeViewController.h"
#import "RegisterViewController.h"
#import "GFTextField.h"
#import "CHNAlertView.h"

@interface LoginViewController : BasicViewController <UIGestureRecognizerDelegate,UITextFieldDelegate,CHNAlertViewDelegate>
{
    GFTextField * phone;
    GFTextField * password;
    
    BOOL isFirst;
    BOOL isSecond;
    
    BOOL isBack; //判断是否返回上一页面  如果是取消弹层判断
}

@property (nonatomic, copy) NSString * loginPhone;
@property (nonatomic, assign) NSInteger flag;
@property (nonatomic, assign) NSInteger selectType;//从哪个tabbar传过来的
@property (nonatomic, assign) NSInteger abandonType;//注册或重置密码放弃   type  = 1 ，其他为2

@end



