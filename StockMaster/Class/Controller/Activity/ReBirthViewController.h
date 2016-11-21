//
//  ReBirthViewController.h
//  StockMaster
//
//  Created by Rebloom on 14/11/25.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "BasicViewController.h"
#import "WXApi.h"

@interface ReBirthViewController : BasicViewController <CHNAlertViewDelegate>
{
    UILabel * descLabel;
    UIView * totalView;
    UIView * presentView;
    UILabel * presentMoney;
    UIButton * recoverBtn;
    
    UIImageView * getOutImage;
    
    BOOL canRequest;
}

@end
