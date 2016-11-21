//
//  InviteViewController.h
//  StockMaster
//
//  Created by dalikeji on 15/1/28.
//  Copyright (c) 2015年 Rebloom. All rights reserved.
//

#import "BasicViewController.h"
#import "ShareView.h"

@interface InviteViewController : BasicViewController<ShareViewDelegate>
{
    UIButton * mineBtn;
    UIButton * friendBtn;
    UIButton * secondFriendBtn;
    UILabel * nameLabel;
    UIImageView * photoImageView;
    
    UIImageView * fingerImageView;
    
    UIButton * firstBtn;
    UIButton * secondBtn;
    
    UIButton * leftBtn;
    UIButton * rightBtn;
    
    UIView * upView;
    UIView * downView;
    
    UIView * mainView;
    UIImageView * feetView;
    
    NSDate * circleDate;
    NSTimer * circleTimer;
    
    NSInteger  time;
    NSInteger  friendNum;
    
    NSMutableArray * awardArr;
    NSMutableArray * taskIdArr;
    CGRect temp ;
    NSInteger num;
    NSInteger circle;
    
    UIImageView * tipView;
    UILabel * tipLabel;
    UILabel * tipTwoView;
    UILabel * tipTwoLable;
    UIView * bgView;
    UIView * xiaView;
        
    BOOL isMine;//是否在自己的关系上面有提示窗
    BOOL isFirst;//判断是否第一次进入界面
}
@end
