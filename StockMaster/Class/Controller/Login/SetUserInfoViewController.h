//
//  SetUserInfoViewController.h
//  StockMaster
//
//  Created by dalikeji on 14/12/2.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "BasicViewController.h"
#import "GFTextField.h"
#import "CHNAlertView.h"
@interface SetUserInfoViewController : BasicViewController<UITextFieldDelegate,UIScrollViewDelegate,CHNAlertViewDelegate,UIGestureRecognizerDelegate>
{
    GFTextField * nameTf;
    GFTextField * passTf;
    GFTextField * rePassTf;
    
    BOOL isFirst;
    BOOL isSecond;
    BOOL isThird;

    NSInteger flag;
    
    UIScrollView * scrollView;

    NSDate * date;
        
    NSInteger  time;
    
    BOOL isRequestRegister;
}
@property(nonatomic, copy) NSString * code;
@property(nonatomic, copy) NSString * phone;
@end
