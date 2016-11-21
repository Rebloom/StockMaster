//
//  FeedbackViewController.h
//  StockMaster
//
//  Created by Rebloom on 14-7-31.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "BasicViewController.h"
#import "GFTextField.h"
#import "CHNAlertView.h"

@interface FeedbackViewController : BasicViewController<UITextFieldDelegate,UITextViewDelegate,UIScrollViewDelegate,CHNAlertViewDelegate>
{
    GFTextField * inputText;
    UITextView * inputView;
    UILabel * placeholderLb;
    UIScrollView * scrollView;
    NSInteger type;
}

@end
