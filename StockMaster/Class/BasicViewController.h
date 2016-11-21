//
//  BasicViewController.h
//  StockMaster
//
//  Created by Rebloom on 14-7-22.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <objc/runtime.h>

#import "Utility.h"
#import "HeaderView.h"
#import "TKAlertCenter.h"
#import "GFRequestManager.h"
#import "GFStaticData.h"
#import "UIImageView+WebCache.h"
#import "SDWebImageManager.h"
#import "CHNAlertView.h"
#import "MBProgressHUD.h"

#import "UIImage+UIColor.h"
#import "NSString+UIColor.h"
#import "NSTimer+Addition.h"
#import "Secret.h"

#import "StockInfoCoreDataStorage.h"
#import "UserInfoCoreDataStorage.h"

/*
 GUESSSTATUS = 1可猜时间但没猜过,
 = 2可猜时间猜过了但没到开奖时间,
 = 3过了开奖时间已猜过了,
 = 4过了开奖时间没猜过的;
 */
typedef enum GUESSSTATUS
{
    GuessOne = 1,
    GuessTwo,
    GuessThree,
    GuessFour,
}_GUESSSTATUS;

@interface BasicViewController : UIViewController <UITableViewDelegate, UITableViewDataSource,HeaderViewDelegate,ASIHTTPRequestDelegate,CHNAlertViewDelegate>
{
    UIView * statusBarView;
    
    HeaderView * headerView;
    
    UIScrollView * basicScrollView;
    
    NSDictionary * requestInfo;
    
    UIView * topShadowView;

    UILabel * topShowText;
    UIImageView * topShowImage;
    UIButton * bCloseBtn;
    UIImageView * closeImage;
    BOOL isShow;
    
    BOOL isFailedShow;
}

//从右侧划入
- (void)pushToViewController:(BasicViewController *)controller;

//从底部划出
- (void)subPushToViewController:(BasicViewController *)controller;

- (void)presentViewController:(BasicViewController *)controller;

- (void)back;

- (void)showTopShadow;

- (void)hideTopShadow;

@end
