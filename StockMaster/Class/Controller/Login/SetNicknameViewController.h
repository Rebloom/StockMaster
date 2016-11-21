//
//  SetNicknameViewController.h
//  StockMaster
//
//  Created by Rebloom on 14-8-1.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "BasicViewController.h"
#import "GFTextField.h"
#import "CHNAlertView.h"

@interface SetNicknameViewController : BasicViewController<UITextFieldDelegate,CHNAlertViewDelegate>
{
    GFTextField * nickName;
    NSString * nameStr ;
}

@property (nonatomic, assign) NSInteger type;
@property (nonatomic, copy) NSString * nameStr;

@end
