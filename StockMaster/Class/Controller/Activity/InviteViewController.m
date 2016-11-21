//
//  InviteViewController.m
//  StockMaster
//
//  Created by dalikeji on 15/1/28.
//  Copyright (c) 2015年 Rebloom. All rights reserved.
//

#import "InviteViewController.h"
#import "InvitationCodeViewController.h"
#import "AwardViewController.h"
#import "FriendShipViewController.h"
#import "EarnMoneyViewController.h"
#import "ShareManager.h"

#define inviteTag   100
#define leftTag     200
#define rightTag    300
#define centerTag   0
#define KTagLeftView 10
#define KTagRightView  20

#define mineTag     400
#define friendTag   500
#define secondFriendTag  600


@interface InviteViewController ()

@end

@implementation InviteViewController

- (void)dealloc
{
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [self clearDownView];
    [self requestData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = KSelectNewColor;
    
    [headerView loadComponentsWithTitle:@"邀请"];
    [headerView backButton];
    [headerView createLine];
    headerView.backgroundColor = kFontColorA;
    [headerView setStatusBarColor:kFontColorA];
    
    isFirst = YES;
    isMine = YES;
    friendNum = 0;
    circle = 2;
    awardArr = [[NSMutableArray alloc] initWithCapacity:10];
    taskIdArr = [[NSMutableArray alloc] initWithCapacity:10];
    
    UIButton * inviteBtn = [[UIButton alloc] init];
    inviteBtn.tag = inviteTag;
    inviteBtn.frame = CGRectMake(screenWidth -80, 20, 80, 44);
    
    UIImageView * duimianImageView = [[UIImageView alloc] init];
    duimianImageView.image = [UIImage imageNamed:@"icon_mianduimian"];
    duimianImageView.frame = CGRectMake(43, 11.5, 22, 19);
    [inviteBtn addSubview:duimianImageView];
    
    [inviteBtn addTarget:self action:@selector(BtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:inviteBtn];
    
    [self createFriendShip];
    [self performSelector:@selector(hiddenTipView) withObject:self afterDelay:0.5];
    
    //邀请优化 --- 测试手指点击动画
    //    [self createFingerTouch];
}

//数据请求
- (void)requestData
{
    NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
    [GFRequestManager connectWithDelegate:self action:Get_invitation_task param:paramDic];
    
    NSMutableDictionary * parDic = [NSMutableDictionary dictionary];
    [GFRequestManager connectWithDelegate:self action:Get_invitation_friends_num param:parDic];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    [super requestFinished:request];
    
    ASIFormDataRequest * formdataRequest = (ASIFormDataRequest *)request;
    
    if ([formdataRequest.action isEqualToString:Get_invitation_task])
    {
        NSMutableArray * tempArr = [[requestInfo objectForKey:@"data"] objectForKey:@"task_list"];
        
        [self createCircle];
        
        [self deliverBtnData:[tempArr mutableCopy]];
    }
    else if ([formdataRequest.action isEqualToString:Get_invitation_friends_num])
    {
        NSDictionary * data = [requestInfo objectForKey:@"data"];
        // 去掉头像url后面的参数，因为参数为随机变动时间
        NSArray *urlArray = [[data objectForKey:@"head"] componentsSeparatedByString:@"?"];
        NSString *headUrl = urlArray.firstObject;
        [photoImageView sd_setImageWithURL:[NSURL URLWithString:headUrl]
                       placeholderImage:[UIImage imageNamed:@"icon_touxiang"]
                                   options:SDWebImageRefreshCached];
        nameLabel.text = [data objectForKey:@"nickname"];
        friendNum = [[data objectForKey:@"friends_num"] integerValue];
        [friendBtn setTitle:[NSString stringWithFormat:@"%@\n好友数 ",[data objectForKey:@"friends_num"]] forState:UIControlStateNormal];
        [secondFriendBtn setTitle:[NSString stringWithFormat:@"%@\n好友朋友数",[data objectForKey:@"friends_friends_num"]] forState:UIControlStateNormal];
    }
    else if ([formdataRequest.action isEqualToString:Get_invitation_reward])
    {
        NSString * status = [[requestInfo objectForKey:@"data"] objectForKey:@"status"];
        if ([status isEqualToString:@"1"])
        {
            NSDictionary * dic = [requestInfo objectForKey:@"data"];
            
            [[CHNAlertView defaultAlertView] initWithAwardText:CHECKDATA(@"money") desc1:CHECKDATA(@"prompt1") desc2:CHECKDATA(@"prompt2") buttonDesc:@"知道了，退下~" delegate:self];
        }
    }
}

-(void)requestFailed:(ASIHTTPRequest *)request
{
    [super requestFailed:request];
}

- (void)buttonClickedAtIndex:(NSInteger)index
{
    [self clearDownView];
    [self requestData];
}

- (void)clearDownView
{
    if (bgView)
    {
        for (UIView * view in bgView.subviews)
        {
            [view removeFromSuperview];
        }
    }
    if (downView)
    {
        for (UIView * view in downView.subviews)
        {
            [view removeFromSuperview];
        }
    }
}

- (void)deliverBtnData:(NSMutableArray*)arr
{
    num = arr.count;
    downView.frame = CGRectMake(0, 0, screenWidth/2 * num, 44);
    
    NSMutableArray * tempArr = [[NSMutableArray alloc] initWithCapacity:10];
    NSMutableArray * infoArr = [[NSMutableArray alloc] initWithCapacity:10];
    
    for(int i = 0 ; i< num ; i++)
    {
        NSDictionary  * dict = [arr objectAtIndex:i];
        NSInteger  status  = [[dict objectForKey:@"get_award"] integerValue];
        NSInteger  invitation_id = [[dict objectForKey:@"invitation_id"] integerValue];
        NSString * str1 = [[dict objectForKey:@"invitation_task_description"] description];
        
        NSString * str2 = nil;
        [infoArr addObject:[[dict objectForKey:@"invitation_id"] description]];
        if (status == 1)
        {
            //未完成
            if (invitation_id == 1 || invitation_id ==2)
            {
                str2 = @"可领:0";
            }
            else if (invitation_id == 4)
            {
                str2 = @"未完成";
            }
            else if (invitation_id == 3)
            {
                str2 = @"我要被邀请";
            }
            else if (invitation_id == 5)
            {
                str2 = @"未完成";
            }
        }
        else if (status == 2)
        {
            //完成
            if (invitation_id == 1 || invitation_id ==2)
            {
                str2 =[NSString stringWithFormat:@"可领:%@",[[dict objectForKey:@"get_money"] description]];
            }
            else if (invitation_id == 4 ||invitation_id == 3 )
            {
                str2 = @"已完成";
            }
            else if (invitation_id == 5)
            {
                str2 =[NSString stringWithFormat:@"可领:%@",[[dict objectForKey:@"invitation_task_money"] description]];
            }
            
            [tempArr addObject:[dict objectForKey:@"invitation_id"]];
        }
        
        UIButton * button = [[UIButton alloc] init];
        button.tag = i;
        button.frame = CGRectMake((screenWidth/2 * i )+10 , 0, screenWidth/2-20, 53);
        [button setTitleColor:kFontColorA forState:UIControlStateNormal];
        [button addTarget:self action:@selector(taskBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
        [downView addSubview:button];
        
        for (int j=0; j<2; j++)
        {
            UILabel * lable = [[UILabel alloc] init];
            if (j == 0)
            {
                lable.frame = CGRectMake(0 , 8, screenWidth/2-20, 13);
                lable.text = str2;
                lable.font = BoldFontWithSize(13);
                lable.textColor = kFontColorA;
            }
            else if (j == 1)
            {
                lable.frame = CGRectMake(0 , 21, screenWidth/2-10, 25);
                lable.text = str1;
                lable.numberOfLines = 0;
                lable.lineBreakMode = NSLineBreakByWordWrapping;
                lable.font = NormalFontWithSize(10);
                lable.textColor = KFontNewColorK;
            }
            lable.textAlignment = NSTextAlignmentCenter;
            lable.numberOfLines = 0;
            lable.backgroundColor = [UIColor clearColor];
            [button addSubview:lable];
        }
        
        UIView * view = [[UIView alloc] init];
        view.frame = CGRectMake(screenWidth * i, 0, screenWidth, 48);
        if (status == 2)
        {
            view.backgroundColor = kRedColor;
        }
        else if(status == 1)
        {
            view.backgroundColor = KNewColorOrange;
        }
        [xiaView addSubview:view];
    }
    awardArr = [tempArr mutableCopy];
    taskIdArr = [infoArr mutableCopy];
}

//创建切换任务视图
- (void)createCircle
{
    if (!bgView)
    {
        bgView = [[UIView alloc] init];
    }
    bgView.frame = CGRectMake(0, screenHeight - 48, screenWidth, 48);
    bgView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:bgView];
    
    UIView * layerView = [[UIView alloc] init];
    layerView.frame = CGRectMake(screenWidth/4, 0, screenWidth/2, 48);
    layerView.clipsToBounds = YES;
    layerView.backgroundColor = [UIColor clearColor];
    [bgView addSubview:layerView];
    
    if (!xiaView)
    {
        xiaView = [[UIView alloc]init];
    }
    xiaView.frame = CGRectMake(0, 0, screenWidth, 48);
    xiaView.backgroundColor = [UIColor clearColor];
    [bgView addSubview:xiaView];
    [bgView sendSubviewToBack:xiaView];
    
    if (!downView)
    {
        downView = [[UIView alloc] init];
    }
    downView.frame = CGRectMake(0, 0, screenWidth/2, 48);
    downView.backgroundColor = [UIColor clearColor];
    downView.clipsToBounds = YES;
    [layerView addSubview:downView];
    
    if (!leftBtn)
    {
        leftBtn = [[UIButton alloc] init];
    }
    leftBtn.tag = leftTag;
    leftBtn.enabled = NO;
    leftBtn.frame = CGRectMake(0,0, 70, 48);
    [leftBtn addTarget:self action:@selector(BtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:leftBtn];
    
    UIImageView * leftView = [[UIImageView alloc] init];
    leftView.alpha = 0.4;
    leftView.tag = KTagLeftView;
    leftView.image = [UIImage imageNamed:@"icon_zuo"];
    leftView.frame = CGRectMake(25, 14.5, 11, 19);
    [leftBtn addSubview:leftView];
    
    if (!rightBtn)
    {
        rightBtn = [[UIButton alloc] init];
    }
    rightBtn.tag = rightTag;
    rightBtn.enabled = YES;
    rightBtn.frame = CGRectMake(screenWidth - 70, 0, 70, 48);
    [rightBtn addTarget:self action:@selector(BtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:rightBtn];
    
    UIImageView * rightView = [[UIImageView alloc] init];
    rightView.image = [UIImage imageNamed:@"icon_you"];
    rightView.alpha = 1;
    rightView.tag = KTagRightView;
    rightView.frame = CGRectMake(34, 14.5, 11, 19);
    [rightBtn addSubview:rightView];
}

//点击领取任务奖金
- (void)taskBtnOnClick:(UIButton*)sender
{
    [GFStaticData saveObject:nil forKey:KTagCardInfo];
    
    //恢复弹窗位置
    [upView bringSubviewToFront:tipView];
    CGAffineTransform newTransform = CGAffineTransformMakeScale(1.0, 1.0);
    [tipView setTransform:newTransform];
    
    NSMutableDictionary * parDic = [NSMutableDictionary dictionary];
    
    if (sender.tag == 0)
    {
        if (awardArr.count > 0)
        {
            NSString * award_id = [awardArr objectAtIndex:0];
            if ([award_id isEqualToString:@"5"])
            {
                EarnMoneyViewController  * EMVC = [[EarnMoneyViewController alloc] init];
                [self pushToViewController:EMVC];
            }
            else
            {
                [parDic setObject:award_id forKey:@"task_id"];
                [GFRequestManager connectWithDelegate:self action:Get_invitation_reward param:parDic];
            }
        }
        else
        {
            NSString * task_id = [taskIdArr objectAtIndex:0];
            if ([task_id isEqualToString:@"1"])
            {
                [self createFriendTip:@"快去邀请小伙伴\n成功会再此显示"];
            }
            else if ([task_id isEqualToString:@"2"])
            {
                [self createSecondFriendTip];
            }
            else if ([task_id isEqualToString:@"5"])
            {
                [self createFriendTip:@"必须邀请新用户才可以哦"];
            }
        }
    }
    else if (sender.tag == 1)
    {
        if (awardArr.count > 1)
        {
            if (awardArr.count > 0)
            {
                NSString * award_id = [awardArr objectAtIndex:1];
                if ([award_id isEqualToString:@"5"])
                {
                    EarnMoneyViewController  * EMVC = [[EarnMoneyViewController alloc] init];
                    [self pushToViewController:EMVC];
                }
                else
                {
                    [parDic setObject:award_id forKey:@"task_id"];
                    [GFRequestManager connectWithDelegate:self action:Get_invitation_reward param:parDic];
                }
            }
        }
        else
        {
            NSString * task_id = [taskIdArr objectAtIndex:1];
            if ([task_id isEqualToString:@"1"])
            {
                [self createFriendTip:@"快去邀请小伙伴\n成功会再此显示"];
            }
            else if ([task_id isEqualToString:@"2"])
            {
                [self createSecondFriendTip];
            }
            else if ([task_id isEqualToString:@"5"])
            {
                [self createFriendTip:@"必须邀请新用户\n才可以哦"];
            }
        }
    }
    if (num == 3)
    {
        if (sender.tag == 2)
        {
            if (awardArr.count > 2)
            {
                if (awardArr.count > 0)
                {
                    NSString * award_id = [awardArr objectAtIndex:2];
                    if ([award_id isEqualToString:@"5"])
                    {
                        EarnMoneyViewController  * EMVC = [[EarnMoneyViewController alloc] init];
                        [self pushToViewController:EMVC];
                    }
                    else
                    {
                        [parDic setObject:award_id forKey:@"task_id"];
                        [GFRequestManager connectWithDelegate:self action:Get_invitation_reward param:parDic];
                    }
                }
            }
            else
            {
                NSString * taskId = [taskIdArr objectAtIndex:2];
                if ([taskId isEqualToString: @"3"])
                {
                    AwardViewController * AVC = [[AwardViewController alloc] init];
                    [self pushToViewController:AVC];
                }
                else if ([taskId isEqualToString:@"1"])
                {
                    [self createFriendTip:@"快去邀请小伙伴\n成功会再此显示"];
                }
                else if ([taskId isEqualToString:@"2"])
                {
                    [self createSecondFriendTip];
                }
                else if ([taskId isEqualToString:@"5"])
                {
                    [self createFriendTip:@"必须邀请新用户\n才可以哦"];
                }
            }
        }
    }
    if (num == 4)
    {
        if (sender.tag == 2)
        {
            if (awardArr.count > 2)
            {
                if (awardArr.count > 0)
                {
                    NSString * award_id = [awardArr objectAtIndex:2];
                    if ([award_id isEqualToString:@"5"])
                    {
                        EarnMoneyViewController  * EMVC = [[EarnMoneyViewController alloc] init];
                        [self pushToViewController:EMVC];
                    }
                    else
                    {
                        [parDic setObject:award_id forKey:@"task_id"];
                        [GFRequestManager connectWithDelegate:self action:Get_invitation_reward param:parDic];
                    }
                }
            }
            else
            {
                NSString * taskId = [taskIdArr objectAtIndex:2];
                if ([taskId isEqualToString: @"3"])
                {
                    AwardViewController * AVC = [[AwardViewController alloc] init];
                    [self pushToViewController:AVC];
                }
                else if ([taskId isEqualToString:@"1"])
                {
                    [self createFriendTip:@"快去邀请小伙伴\n成功会再此显示"];
                }
                else if ([taskId isEqualToString:@"2"])
                {
                    [self createSecondFriendTip];
                }
                else if ([taskId isEqualToString:@"5"])
                {
                    [self createFriendTip:@"必须邀请新用户\n才可以哦"];
                }
            }
        }
        if (sender.tag == 3)
        {
            if (awardArr.count > 3)
            {
                if (awardArr.count > 0)
                {
                    NSString * award_id = [awardArr objectAtIndex:3];
                    if ([award_id isEqualToString:@"5"])
                    {
                        EarnMoneyViewController  * EMVC = [[EarnMoneyViewController alloc] init];
                        [self pushToViewController:EMVC];
                    }
                    else
                    {
                        [parDic setObject:award_id forKey:@"task_id"];
                        [GFRequestManager connectWithDelegate:self action:Get_invitation_reward param:parDic];
                    }
                }
            }
            else
            {
                NSString * taskId = [taskIdArr objectAtIndex:3];
                if ([taskId isEqualToString: @"3"])
                {
                    AwardViewController * AVC = [[AwardViewController alloc] init];
                    [self pushToViewController:AVC];
                }
                else if ([taskId isEqualToString:@"1"])
                {
                    [self createFriendTip:@"快去邀请小伙伴\n成功会再此显示"];
                }
                else if ([taskId isEqualToString:@"2"])
                {
                    [self createSecondFriendTip];
                }
                else if ([taskId isEqualToString:@"5"])
                {
                    [self createFriendTip:@"必须邀请新用户\n才可以哦"];
                }
            }
        }
    }
    else if (num == 5)
    {
        if (sender.tag == 2)
        {
            if (awardArr.count > 2)
            {
                if (awardArr.count > 0)
                {
                    NSString * award_id = [awardArr objectAtIndex:2];
                    if ([award_id isEqualToString:@"5"])
                    {
                        EarnMoneyViewController  * EMVC = [[EarnMoneyViewController alloc] init];
                        [self pushToViewController:EMVC];
                    }
                    else
                    {
                        [parDic setObject:award_id forKey:@"task_id"];
                        [GFRequestManager connectWithDelegate:self action:Get_invitation_reward param:parDic];
                    }
                }
            }
            else
            {
                NSString * taskId = [taskIdArr objectAtIndex:2];
                if ([taskId isEqualToString: @"3"])
                {
                    AwardViewController * AVC = [[AwardViewController alloc] init];
                    [self pushToViewController:AVC];
                }
                else if ([taskId isEqualToString:@"1"])
                {
                    [self createFriendTip:@"快去邀请小伙伴\n成功会再此显示"];
                }
                else if ([taskId isEqualToString:@"2"])
                {
                    [self createSecondFriendTip];
                }
                else if ([taskId isEqualToString:@"5"])
                {
                    [self createFriendTip:@"必须邀请新用户\n才可以哦"];
                }
            }
        }
        if (sender.tag == 3)
        {
            if (awardArr.count > 3)
            {
                if (awardArr.count > 0)
                {
                    NSString * award_id = [awardArr objectAtIndex:3];
                    if ([award_id isEqualToString:@"5"])
                    {
                        EarnMoneyViewController  * EMVC = [[EarnMoneyViewController alloc] init];
                        [self pushToViewController:EMVC];
                    }
                    else
                    {
                        [parDic setObject:award_id forKey:@"task_id"];
                        [GFRequestManager connectWithDelegate:self action:Get_invitation_reward param:parDic];
                    }
                }
            }
            else
            {
                NSString * taskId = [taskIdArr objectAtIndex:3];
                if ([taskId isEqualToString: @"3"])
                {
                    AwardViewController * AVC = [[AwardViewController alloc] init];
                    [self pushToViewController:AVC];
                }
                else if ([taskId isEqualToString:@"1"])
                {
                    [self createFriendTip:@"快去邀请小伙伴\n成功会再此显示"];
                }
                else if ([taskId isEqualToString:@"2"])
                {
                    [self createSecondFriendTip];
                }
                else if ([taskId isEqualToString:@"5"])
                {
                    [self createFriendTip:@"必须邀请新用户\n才可以哦"];
                }
            }
        }
        if (sender.tag == 4)
        {
            if (awardArr.count > 4)
            {
                if (awardArr.count > 0)
                {
                    NSString * award_id = [awardArr objectAtIndex:4];
                    if ([award_id isEqualToString:@"5"])
                    {
                        EarnMoneyViewController  * EMVC = [[EarnMoneyViewController alloc] init];
                        [self pushToViewController:EMVC];
                    }
                    else
                    {
                        [parDic setObject:award_id forKey:@"task_id"];
                        [GFRequestManager connectWithDelegate:self action:Get_invitation_reward param:parDic];
                    }
                }
            }
            else
            {
                NSString * taskId = [taskIdArr objectAtIndex:4];
                if ([taskId isEqualToString: @"3"])
                {
                    AwardViewController * AVC = [[AwardViewController alloc] init];
                    [self pushToViewController:AVC];
                }
                else if ([taskId isEqualToString:@"1"])
                {
                    [self createFriendTip:@"快去邀请小伙伴\n成功会再此显示"];
                }
                else if ([taskId isEqualToString:@"2"])
                {
                    [self createSecondFriendTip];
                }
                else if ([taskId isEqualToString:@"5"])
                {
                    [self createFriendTip:@"必须邀请新用户\n才可以哦"];
                }
            }
        }
    }
}

//创建关系网视图
- (void)createFriendShip
{
    if (!upView)
    {
        upView = [[UIView alloc] init];
    }
    
    upView.userInteractionEnabled = YES;
    upView.backgroundColor = [UIColor clearColor];
    upView.frame = CGRectMake(0, CGRectGetMaxY(headerView.frame), screenWidth, screenWidth+80);
    [self.view addSubview:upView];
    
    UIImageView * quanImageView = [[UIImageView alloc] init];
    quanImageView.image = [UIImage imageNamed:@"bj_quanquan@2x"];
    quanImageView.frame = CGRectMake((screenWidth - 262)/2, 36, 262, 336);
    quanImageView.userInteractionEnabled = YES;
    [upView addSubview:quanImageView];
    [upView sendSubviewToBack:quanImageView];
    
    if(!nameLabel)
    {
        nameLabel = [[UILabel alloc] init];
    }
    nameLabel.textColor = KFontNewColorA;
    nameLabel.frame = CGRectMake(0, 90, screenWidth, 20);
    nameLabel.font = NormalFontWithSize(15);
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.backgroundColor = [UIColor clearColor];
    [upView addSubview:nameLabel];
    
    if (!mineBtn)
    {
        mineBtn = [[UIButton alloc] init];
    }
    mineBtn.tag = mineTag;
    mineBtn.frame = CGRectMake((screenWidth - 78)/2 - 0.5, 125.5, 78, 78);
    mineBtn.layer.cornerRadius = 39;
    mineBtn.backgroundColor = [UIColor clearColor];
    
    if (!photoImageView)
    {
        photoImageView = [[UIImageView alloc] init];
    }
    photoImageView.image = [UIImage imageNamed:@"icon_touxiang"];
    photoImageView.frame = CGRectMake(0, 0, 78, 78);
    photoImageView.layer.cornerRadius = 39;
    photoImageView.layer.masksToBounds = YES;
    [mineBtn addSubview:photoImageView];
    
    
    [mineBtn addTarget:self action:@selector(friendShipBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
    [upView addSubview:mineBtn];
    
    if (!friendBtn)
    {
        friendBtn = [[UIButton alloc] init];
    }
    friendBtn.tag = friendTag;
    friendBtn.frame = CGRectMake(screenWidth/2-67, 257, 70, 70);
    friendBtn.layer.cornerRadius = 35;
    friendBtn.backgroundColor = kRedColor;
    friendBtn.titleLabel.font = NormalFontWithSize(13);
    friendBtn.titleLabel.numberOfLines = 0;
    friendBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [friendBtn setTitleColor:kFontColorA forState:UIControlStateNormal];
    [friendBtn addTarget:self action:@selector(friendShipBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
    [upView addSubview:friendBtn];
    
    if (!secondFriendBtn)
    {
        secondFriendBtn = [[UIButton alloc] init];
    }
    secondFriendBtn.tag = secondFriendTag;
    secondFriendBtn.frame = CGRectMake(screenWidth/2+2, 308.5, 58, 58);
    secondFriendBtn.layer.cornerRadius = 29;
    secondFriendBtn.enabled = YES;
    secondFriendBtn.backgroundColor = KNewColorOrange;
    secondFriendBtn.titleLabel.font = BoldFontWithSize(11);
    secondFriendBtn.titleLabel.numberOfLines = 0;
    secondFriendBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [secondFriendBtn setTitleColor:kFontColorA forState:UIControlStateNormal];
    [secondFriendBtn addTarget:self action:@selector(friendShipBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
    [upView addSubview:secondFriendBtn];
    
    if (!tipView)
    {
        tipView = [[UIImageView alloc] init];
    }
    tipView.image = [UIImage imageNamed:@"tishi8"];
    tipView.hidden = YES;
    [upView addSubview:tipView];
    [upView bringSubviewToFront:tipView];
    
    if(!tipLabel)
    {
        tipLabel = [[UILabel alloc] init];
    }
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.textColor = KFontNewColorA;
    tipLabel.font = NormalFontWithSize(11);
    tipLabel.numberOfLines = 0;
    tipLabel.backgroundColor = [UIColor whiteColor];
    [tipView addSubview:tipLabel];
    
}

//创建点击手指视图
-(void)createFingerTouch
{
    //    if (!fingerImageView)
    //    {
    //        fingerImageView = [[UIImageView alloc] init];
    //        fingerImageView.image = [UIImage imageNamed:@"finger"];
    //        fingerImageView.frame = CGRectMake(screenWidth/2 - 5, CGRectGetMidY(mineBtn.frame), 35 , 60);
    //        [upView addSubview:fingerImageView];
    //    }
    //    fingerImageView.hidden = NO;
    //
    //
    //    CABasicAnimation *translation = [CABasicAnimation animationWithKeyPath:@"transform"];
    //    translation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    //    translation.toValue=[NSValue valueWithCATransform3D:CATransform3DMakeRotation(0.35,0.0,0.0, -1.0)];
    //    CGAffineTransform newTransform = CGAffineTransformMakeScale(1.3, 1.3);
    //    [fingerImageView setTransform:newTransform];
    //    translation.duration = 0.25;
    //    translation.repeatCount = 1000;
    //    translation.autoreverses = YES;
    //    [fingerImageView.layer addAnimation:translation forKey:@"translation"];
}

//左右切换任务
- (void)BtnOnClick:(UIButton *)sender
{
    if (sender.tag == inviteTag)
    {
        InvitationCodeViewController * ICVC = [[InvitationCodeViewController alloc] init];
        [self pushToViewController:ICVC];
    }
    else if (sender.tag == leftTag)
    {
        temp = downView.frame;
        circle = 1;
        
        [self timeFire];
        
    }
    else if (sender.tag == rightTag)
    {
        temp = downView.frame;
        circle = 2;
        
        [self timeFire];
    }
}

- (void)timeFire
{
    if (circle == 2)
    {
        leftBtn.enabled = YES;
        
        UIImageView * leftview = (UIImageView*)[leftBtn viewWithTag:KTagLeftView];
        leftview.alpha = 1;
        
        xiaView.frame = CGRectMake(xiaView.frame.origin.x - screenWidth, xiaView.frame.origin.y, xiaView.frame.size.width, xiaView.frame.size.height);
        
        [UIView beginAnimations:@"Animation" context:nil];
        [UIView setAnimationDuration:0.4];
        downView.frame = CGRectMake(downView.frame.origin.x - screenWidth/2, downView.frame.origin.y, downView.frame.size.width, downView.frame.size.height);
        [UIView commitAnimations];
        
        if (downView.frame.origin.x <= -((num-1)*screenWidth/2-10))
        {
            rightBtn.enabled = NO;
            
            UIImageView * rightView = (UIImageView*)[rightBtn viewWithTag:KTagRightView];
            rightView.alpha = 0.4;
            
            downView.frame = CGRectMake(-((num - 1)*screenWidth/2), downView.frame.origin.y, downView.frame.size.width, downView.frame.size.height);
            xiaView.frame = CGRectMake(-((num - 1)*screenWidth), xiaView.frame.origin.y, xiaView.frame.size.width, xiaView.frame.size.height);
            
        }
    }
    else if (circle == 1)
    {
        rightBtn.enabled = YES;
        
        UIImageView * leftView = (UIImageView*)[rightBtn viewWithTag:KTagRightView];
        leftView.alpha = 1;
        
        xiaView.frame = CGRectMake(xiaView.frame.origin.x + screenWidth, xiaView.frame.origin.y, xiaView.frame.size.width, xiaView.frame.size.height);
        
        [UIView beginAnimations:@"Animation" context:nil];
        [UIView setAnimationDuration:0.4];
        downView.frame = CGRectMake(downView.frame.origin.x + screenWidth/2, downView.frame.origin.y, downView.frame.size.width, downView.frame.size.height);
        [UIView commitAnimations];
        
        if (downView.frame.origin.x >= 0)
        {
            
            downView.frame = CGRectMake(-0, 0, downView.frame.size.width, downView.frame.size.height);
            xiaView.frame = CGRectMake(-0, 0, xiaView.frame.size.width, xiaView.frame.size.height);
            
            leftBtn.enabled = NO;
            UIImageView * rightView = (UIImageView*)[leftBtn viewWithTag:KTagLeftView];
            rightView.alpha = 0.4;
            
        }
    }
}

//好友关系点击事件
- (void)friendShipBtnOnClick:(UIButton*)sender
{
    [upView bringSubviewToFront:tipView];
    CGAffineTransform newTransform = CGAffineTransformMakeScale(1.0, 1.0);
    [tipView setTransform:newTransform];
    if (sender.tag == mineTag)
    {
        //        fingerImageView.hidden = YES;
        [self createActionSheet];
    }
    else if (sender.tag == friendTag)
    {
        [self createFriendOnClick];
    }
    else if (sender.tag == secondFriendTag)
    {
        [self createSecondFriendTip];
    }
}

- (void)createFriendOnClick
{
    if (friendNum == 0)
    {
        [self createFriendTip:@"快去邀请小伙伴\n成功会再此显示"];
    }
    else
    {
        FriendShipViewController * FSVC = [[FriendShipViewController alloc] init];
        [self pushToViewController:FSVC];
    }
}

- (void)createFriendTip:(NSString*)str
{
    downView.userInteractionEnabled = NO;
    
    tipLabel.text = str;
    tipView.hidden = NO;
    tipView.frame = CGRectMake(screenWidth/2-85 , 257,110, 40);
    tipLabel.frame = CGRectMake(1, 1, CGRectGetWidth(tipView.frame)-5, CGRectGetHeight(tipView.frame)-10);
    
    [UIView beginAnimations:@"Animation" context:nil];
    [UIView animateWithDuration:4 animations:^{
        tipView.frame = CGRectMake(screenWidth/2-85, 257-40, 110, 40);
        CGAffineTransform newTransform = CGAffineTransformMakeScale(1.2, 1.2);
        [tipView setTransform:newTransform];
    }
                     completion:^(BOOL finished){
                         mineBtn.enabled = NO;
                         friendBtn.enabled = NO;
                         secondFriendBtn.enabled = NO;
                         isMine = YES;
                         [self performSelector:@selector(hiddenTipView) withObject:self afterDelay:2];
                     }];
    [UIView commitAnimations];
}

- (void)createSecondFriendTip
{
    downView.userInteractionEnabled = NO;
    
    tipView.frame = CGRectMake(screenWidth/2-18, 298, 100, 40);
    tipLabel.text = @"我增加你才能领钱";
    tipView.hidden = NO;
    tipLabel.frame = CGRectMake(1, 1, CGRectGetWidth(tipView.frame)-5, CGRectGetHeight(tipView.frame)-10);
    
    [UIView beginAnimations:@"Animation" context:nil];
    [UIView animateWithDuration:4 animations:^{
        tipView.frame = CGRectMake(screenWidth/2-18, 298 - 30, 100, 40);
        CGAffineTransform newTransform = CGAffineTransformMakeScale(1.2, 1.2);
        [tipView setTransform:newTransform];
    }
                     completion:^(BOOL finished){
                         mineBtn.enabled = NO;
                         friendBtn.enabled = NO;
                         secondFriendBtn.enabled = NO;
                         isMine = NO;
                         [self performSelector:@selector(hiddenFriendShipView) withObject:self afterDelay:2];
                     }];
    [UIView commitAnimations];
}

- (void)hiddenTipView
{
    CGAffineTransform newTransform = CGAffineTransformMakeScale(1.0, 1.0);
    [tipView setTransform:newTransform];
    
    if (isMine)
    {
        tipView.hidden = NO;
        tipView.frame = CGRectMake(screenWidth/2-55, 110, 110, 40);
        
        NSString * str1 = @"点头像马上";
        NSString * str2 = @"邀请";
        NSString * str3 = @"好友";
        
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@%@",str1,str2,str3]];
        
        [str addAttribute:NSForegroundColorAttributeName value:KFontNewColorA range:NSMakeRange(0,str1.length)];
        [str addAttribute:NSForegroundColorAttributeName value:kRedColor range:NSMakeRange(str1.length,str2.length)];
        [str addAttribute:NSForegroundColorAttributeName value:KFontNewColorA range:NSMakeRange(str1.length+str2.length,str3.length)];
        
        [str addAttribute:NSFontAttributeName value:NormalFontWithSize(11) range:NSMakeRange(0,str1.length)];
        [str addAttribute:NSFontAttributeName value:NormalFontWithSize(11) range:NSMakeRange(str1.length,str2.length)];
        [str addAttribute:NSFontAttributeName value:NormalFontWithSize(11) range:NSMakeRange(str1.length+str2.length,str3.length)];
        
        tipLabel.attributedText = str;
        
        tipLabel.frame = CGRectMake(1, 1, CGRectGetWidth(tipView.frame)-5, CGRectGetHeight(tipView.frame)-10);
        
        [UIView beginAnimations:@"Animation" context:nil];
        [UIView animateWithDuration:4 animations:^{
            tipView.frame = CGRectMake(screenWidth/2-55, 110-30, 110, 40);
            CGAffineTransform newTransform = CGAffineTransformMakeScale(1.2, 1.2);
            [tipView setTransform:newTransform];
        }
                         completion:^(BOOL finished){
                             isMine = NO;
                             mineBtn.enabled = NO;
                             friendBtn.enabled = NO;
                             secondFriendBtn.enabled = NO;
                             [self performSelector:@selector(hiddenMineView) withObject:self  afterDelay:2];
                         }];
        [UIView commitAnimations];
    }
    else
    {
        [self hiddenMineView];
    }
}

- (void)hiddenFriendShipView
{
    CGAffineTransform newTransform = CGAffineTransformMakeScale(1.0, 1.0);
    [tipView setTransform:newTransform];
    
    tipLabel.text = @"发动我去邀请吧";
    tipView.hidden = NO;
    tipView.frame = CGRectMake(screenWidth/2-85, 257,110, 40);
    tipLabel.frame = CGRectMake(1, 1, CGRectGetWidth(tipView.frame)-5, CGRectGetHeight(tipView.frame)-10);
    
    [UIView beginAnimations:@"Animation" context:nil];
    [UIView animateWithDuration:4 animations:^{
        tipView.frame = CGRectMake(screenWidth/2-85, 257-40, 110, 40);
        CGAffineTransform newTransform = CGAffineTransformMakeScale(1.2, 1.2);
        [tipView setTransform:newTransform];
    }
                     completion:^(BOOL finished){
                         mineBtn.enabled = NO;
                         friendBtn.enabled = NO;
                         secondFriendBtn.enabled = NO;
                         isMine = YES;
                         [self performSelector:@selector(hiddenMineView) withObject:self afterDelay:2];
                     }];
    [UIView commitAnimations];
}

- (void)hiddenMineView
{
    if (isFirst)
    {
        tipView.hidden = NO;
        isFirst = NO;
    }
    else
    {
        tipView.hidden = YES;
    }
    mineBtn.enabled = YES;
    friendBtn.enabled = YES;
    secondFriendBtn.enabled = YES;
    downView.userInteractionEnabled = YES;
}

// 初始化自定义actionSheet
- (void)createActionSheet
{
    ShareView *shareView = [[ShareView defaultShareView] initViewWtihNumber:4 Delegate:self WithViewController:self];
    [shareView showView];
}

//分享
- (void)shareAtIndex:(NSInteger)index
{
    UserInfoEntity *userInfo = [[UserInfoCoreDataStorage sharedInstance] getCurrentUserInfo];
    if (index == 0)
    {
        if ([TencentOAuth iphoneQQInstalled])
        {
            [[ShareManager defaultShareManager] sendTencentWithType:SHARETOQQ WithUid:userInfo.uid];
        }
        else
        {
            [[CHNAlertView defaultAlertView] showContent:@"还没有安装QQ哟~" cancelTitle:nil sureTitle:@"确定" withDelegate:self withType:6];
        }
    }
    else if (index == 1)
    {
        if ([TencentOAuth iphoneQQInstalled])
        {
            [[ShareManager defaultShareManager] sendTencentWithType:SHARETOQZONE WithUid:userInfo.uid];
        }
        else
        {
            [[CHNAlertView defaultAlertView] showContent:@"还没有安装QQ哟~" cancelTitle:nil sureTitle:@"确定" withDelegate:self withType:6];
        }
    }
    else if (index == 2)
    {
        if ([WXApi isWXAppInstalled])
        {
            [[ShareManager defaultShareManager] sendWXWithType:WXSceneTimeline WithUid:userInfo.uid];
        }
        else
        {
            [[CHNAlertView defaultAlertView] showContent:@"还没有安装微信哟~" cancelTitle:nil sureTitle:@"确定" withDelegate:self withType:6];
        }
    }
    else if (index == 3)
    {
        if ([WXApi isWXAppInstalled])
        {
            [[ShareManager defaultShareManager] sendWXWithType:WXSceneSession WithUid:userInfo.uid];
        }
        else
        {
            [[CHNAlertView defaultAlertView] showContent:@"还没有安装微信哟~" cancelTitle:nil sureTitle:@"确定" withDelegate:self withType:6];
        }
    }
    [self performSelector:@selector(delayShowFinger) withObject:self afterDelay:0.4];
}

- (void)delayShowFinger
{
    [self createFingerTouch];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
