//
//  PublicTopView.h
//  StockMaster
//
//  Created by Rebloom on 15/2/12.
//  Copyright (c) 2015年 Rebloom. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CHNMacro.h"
#import "Utility.h"
#import "NSString+UIColor.h"
#import "RMDownloadIndicator.h"

@protocol PublicTopViewDelegate <NSObject>

- (void)setStatusBarColor:(UIColor *)color;

- (void)ruleBtnClicked:(id)sender;

@end

@interface PublicTopView : UIView
{
    BOOL isUp;
    UILabel * totalMoney;
    UIView * whitePoint;
    UIView * centerPoint;
    UIView * feetView;
    
    
    UIImageView * qipaoImage;
    UIImageView * rightImage;
    UIButton * ruleBtn;
    
    RMDownloadIndicator *closedIndicator;
    UILabel * headerDescLabel;
    
    UILabel * statusLabel;
}

//点信息
@property (nonatomic, strong) NSMutableArray * pointArr;

@property (nonatomic, strong) NSMutableArray * animateArr;

@property (nonatomic, weak) id <PublicTopViewDelegate> delegate;

@property (nonatomic, strong) NSDictionary * _userInfo;

@property (nonatomic, strong) CAShapeLayer * lineChart;

- (void)transInfo:(NSDictionary *)userInfo;

@end
