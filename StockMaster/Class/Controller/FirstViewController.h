//
//  FirstViewController.h
//  StockMaster
//
//  Created by Rebloom on 14-7-22.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "BasicViewController.h"
#import "EGORefreshTableHeaderView.h"
#import "PropView.h"
#import "PublicTopView.h"
#import "WXApi.h"
#import "WXApiObject.h"


// type = 1 新用户;  = 2 盈利用户; = 3 小赔用户;  = 4 大赔用户
typedef enum USERSTATUS
{
    NewUser = 1,
    BenifitUser,
    SmallLoseUser,
    BigLoseUser,
}_USERRSTATUS;

//taskId  = 5 猜大盘; = 7 新手任务
typedef enum TASKID
{
    GuessMarket = 5,
    NewUserTask = 7,
}_TASKID;


//taskStatus = 0没有做;  = 1 做过没领奖;  = 2 领奖了
typedef enum TASKSTATUS
{
    NotDo = 0,
    DoNotReward,
    Reward,
}_TASKSTATUS;

#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]

@interface FirstViewController : BasicViewController<HeaderViewDelegate,CHNAlertViewDelegate,EGORefreshTableHeaderDelegate,PublicTopViewDelegate,WXApiDelegate,ASIHTTPRequestDelegate,cardFounctionDelegate>
{
    UITableView * infoTable;
    NSArray * infoArr;
    
    UILabel * desc3;
    
    UILabel * firstLearnLabel;
    UIImageView * firstLearnImage;
    UIButton * firstLearnBtn;
    
    NSDictionary * infoDic;
    NSDictionary * notifiDic;
    NSDictionary * cardDic;
    NSMutableArray * cardArr;
    NSMutableArray * emotionNumArr;
    
    UIImageView * guessResultImage;
    UILabel * guessResultLabel;
    UILabel * guessResultDescLabel;
    UIImageView * guessIcon;
    UILabel * desc1Label;
    UIButton * upBtn;
    UIButton * downBtn;
    UILabel * upGuess;
    UILabel * downGuess;
    PropView * prop;
    
    NSInteger taskStatus;
        
    UIButton * topRewardBtn;
    
    UILabel * useableMoney;
    
    NSString * ruleUrlStr;
        
    EGORefreshTableHeaderView * refreshview;
    BOOL isEgoRefresh;
    
    UIImageView * topImage1;
    UILabel * topLabel1;
    
    UIImageView * topImage2;
    UILabel * topLabel2;
    
    NSString * cardName;
    NSInteger selectedIndex;
    NSInteger propFlag;
    
    UIView * homeHeaderView;
    UIView * propView;
    UIScrollView * cardSV;
        
    PublicTopView * publicTop;
        
    BOOL getStock;
    
    NSInteger currentTab;
    
    BOOL needLoad1;
    BOOL needLoad2;
    BOOL needLoad3;
    
    
    UIButton * btn1;
    UIButton * btn2;
    UIButton * btn3;
        
    BOOL refreshLoading;
    BOOL needRefresh;
}

@end
