//
//  ManageCardViewController.h
//  StockMaster
//
//  Created by dalikeji on 14-10-9.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "BasicViewController.h"
#import "GFTextField.h"
#import "CHNAlertView.h"
@interface ManageCardViewController : BasicViewController<UITextFieldDelegate,CHNAlertViewDelegate,UIScrollViewDelegate>
{
    UIImageView * bgView;
    UIButton * submitBtn;
    UIScrollView * scrollView;
    
    UIButton * changeBtn;
}
@property (nonatomic, strong) NSMutableDictionary * deliverDic;

@end
