//
//  SecondLoginViewController.h
//  StockMaster
//
//  Created by dalikeji on 14/12/3.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "BasicViewController.h"
#import "GFTextField.h"
#import "CHNAlertView.h"

@interface SecondLoginViewController : BasicViewController<UITextFieldDelegate,CHNAlertViewDelegate>
{
    GFTextField * passWordTf;
}

@end
