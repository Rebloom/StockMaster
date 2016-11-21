//
//  GuessStockViewController.m
//  StockMaster
//
//  Created by Rebloom on 14/11/15.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "GuessStockViewController.h"

@interface GuessStockViewController ()

@end

@implementation GuessStockViewController

- (void)dealloc
{
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = KSelectNewColor;
    
    headerView.backgroundColor = kFontColorA;
    [headerView backButton];
    [headerView loadComponentsWithTitle:@"猜大盘"];
    
    [headerView createLine];
    
    //用来放用户历史涨跌记录
    infoArr = [[NSMutableArray alloc] initWithCapacity:10];
    
    //用来装猜大盘记录
    infoDic = [[NSDictionary alloc] init];
    
    infoTable = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(headerView.frame), screenWidth, screenHeight-CGRectGetHeight(headerView.frame))];
    infoTable.backgroundColor = KSelectNewColor;
    infoTable.dataSource = self;
    infoTable.delegate = self;
    infoTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:infoTable];
    [self createFootView];
    
    [self getGuessStockStatus];
    [self getGuessStockList];
}

//创建底部视图
- (void)createFootView
{
    UIView * view = [[UIView alloc] init];
    view.frame = CGRectMake(0, 0, screenWidth, 150);
    view.backgroundColor = [UIColor clearColor];
    infoTable.tableFooterView = view;
    
    UIImageView * iconImgView = [[UIImageView alloc] init];
    iconImgView.frame = CGRectMake(screenWidth/2-15, 52, 30, 23);
    iconImgView.image = [UIImage imageNamed:@"zhangzhang"];
    [view addSubview:iconImgView];
    
    UILabel * ideaLabel = [[UILabel alloc] init];
    ideaLabel.frame = CGRectMake(0,CGRectGetMaxY(iconImgView.frame)+10, screenWidth, 12);
    ideaLabel.text = @"免费炒股，大赚真钱";
    ideaLabel.textAlignment = NSTextAlignmentCenter;
    ideaLabel.textColor = KFontNewColorC;
    ideaLabel.font = NormalFontWithSize(12);
    [view addSubview:ideaLabel];
}


- (void)buttonClicked:(id)sender
{
    [self back];
}

//获取用户当前猜大盘状态
- (void)getGuessStockStatus
{
    NSMutableDictionary * param = [NSMutableDictionary dictionary];
    [GFRequestManager connectWithDelegate:self action:Get_guess_grail_status param:param];
}

//获取用户猜涨跌历史记录
- (void)getGuessStockList
{
    NSMutableDictionary * param = [NSMutableDictionary dictionary];
    [GFRequestManager connectWithDelegate:self action:Get_guess_grail_log param:param];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    [super requestFinished:request];
    
    
    ASIFormDataRequest * formdataRequest = (ASIFormDataRequest *)request;
    if ([formdataRequest.action isEqualToString:Get_guess_grail_status])
    {
        infoDic = [[requestInfo objectForKey:@"data"] mutableCopy];
    }
    else if ([formdataRequest.action isEqualToString:Get_guess_grail_log])
    {
        infoArr = [[requestInfo objectForKey:@"data"] mutableCopy];
    }
    else if ([formdataRequest.action isEqualToString:Submit_guess_grail])
    {
        infoDic = [[requestInfo objectForKey:@"data"] mutableCopy];
    }
    else if ([formdataRequest.action isEqualToString:Submit_user_award])
    {
        NSDictionary * dic = [requestInfo objectForKey:@"data"];
        [[CHNAlertView defaultAlertView] initWithAwardText:CHECKDATA(@"award_money") desc1:CHECKDATA(@"prompt1") desc2:CHECKDATA(@"prompt2") buttonDesc:@"知道了，退下~" delegate:self];
        [self getGuessStockList];
        [self getGuessStockStatus];
    }
    
    [infoTable reloadData];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
    {
        return 1;
    }
    return infoArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 0;
    }
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return 200;
    }
    return 60;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * tableHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 60)];
    tableHeader.backgroundColor = kFontColorA;
    UIImageView * timeImage = [[UIImageView alloc] initWithFrame:CGRectMake(20, 17, 22, 22)];
    timeImage.image = [UIImage imageNamed:@"clock"];
    [tableHeader addSubview:timeImage];
    
    UILabel * recentLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(timeImage.frame)+5, 0, screenWidth-20, 60)];
    recentLabel.backgroundColor = [UIColor clearColor];
    recentLabel.textColor = [UIColor blackColor];
    recentLabel.font = NormalFontWithSize(12);
    recentLabel.text = @"近10日猜涨跌记录";
    [tableHeader addSubview:recentLabel];
    
    return tableHeader;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 60)];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.section == 0)
    {
        cell.frame = CGRectMake(0, 0, screenWidth, 200);
        NSInteger guessStatus = [[infoDic objectForKey:@"grail_status"] integerValue];
        NSInteger guessResult = [[infoDic objectForKey:@"guess_result"] integerValue];
        
        if (!guessIcon)
        {
            guessIcon = [[UIImageView alloc] initWithFrame:CGRectMake(20, 37, 22, 22)];
            guessIcon.image = [UIImage imageNamed:@"zhuanqian"];
        }
        [cell addSubview:guessIcon];
        
        if (!desc1Label)
        {
            desc1Label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(guessIcon.frame)+5, 40, screenWidth-40, 16)];
            desc1Label.backgroundColor = [UIColor clearColor];
            desc1Label.textColor = KFontNewColorA;
            desc1Label.font = NormalFontWithSize(16);
        }
        [cell addSubview:desc1Label];
        
        desc1Label.text = [infoDic objectForKey:@"guess_grail_text"];
        
        UIButton * upBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(guessIcon.frame), CGRectGetMaxY(desc1Label.frame)+25, 85, 75)];
        [upBtn setBackgroundImage:[UIImage imageNamed:@"zhang_qian"] forState:UIControlStateNormal];
        [upBtn setBackgroundImage:[UIImage imageNamed:@"zhang_shen"] forState:UIControlStateHighlighted];
        [upBtn setBackgroundImage:[UIImage imageNamed:@"zhang_hui"] forState:UIControlStateDisabled];
        upBtn.tag = 2;
        [upBtn addTarget:self action:@selector(headerGuessBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:upBtn];
        
        UIButton * downBtn = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth-128, CGRectGetMaxY(desc1Label.frame)+25, 85, 75)];
        [downBtn setBackgroundImage:[UIImage imageNamed:@"die_qian"] forState:UIControlStateNormal];
        [downBtn setBackgroundImage:[UIImage imageNamed:@"die_shen"] forState:UIControlStateHighlighted];
        [downBtn setBackgroundImage:[UIImage imageNamed:@"die_hui"] forState:UIControlStateDisabled];
        downBtn.tag = 1;
        [downBtn addTarget:self action:@selector(headerGuessBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:downBtn];
        
        UILabel * upGuess = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(upBtn.frame), CGRectGetMaxY(upBtn.frame)+10, 85, 16)];
        upGuess.textAlignment = NSTextAlignmentCenter;
        upGuess.backgroundColor = [UIColor clearColor];
        upGuess.textColor = kRedColor;
        upGuess.font = NormalFontWithSize(16);
        upGuess.text = @"点击看涨";
        [cell addSubview:upGuess];
        
        UILabel * downGuess = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(downBtn.frame), CGRectGetMaxY(downBtn.frame)+10, 85, 16)];
        downGuess.textAlignment = NSTextAlignmentCenter;
        downGuess.backgroundColor = [UIColor clearColor];
        downGuess.textColor = kGreenColor;
        downGuess.font = NormalFontWithSize(16);
        downGuess.text = @"点击看跌";
        [cell addSubview:downGuess];
        
        if (!guessResultImage)
        {
            guessResultImage = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(guessIcon.frame), CGRectGetMaxY(desc1Label.frame)+25, 85, 75)];
            guessResultImage.image = [UIImage imageNamed:@"zhang_qian"];
        }
        [cell addSubview:guessResultImage];
        
        if (!centerLine)
        {
            centerLine = [[UIView alloc] initWithFrame:CGRectMake(160, CGRectGetMaxY(desc1Label.frame)+5, .5, 120)];
            centerLine.backgroundColor = KColorHeader;
        }
        [cell addSubview:centerLine];
        
        if (guessStatus ==  GuessOne || guessStatus == GuessTwo)
        {
            centerLine.hidden = YES;
        }
        else if (guessStatus == GuessThree || guessStatus == GuessFour)
        {
            centerLine.hidden = NO;
        }
        
        centerLine.hidden = YES;
        
        if (!guessResultLabel)
        {
            guessResultLabel = [[UILabel alloc] initWithFrame:CGRectMake(200, 100, 100, 20)];
            guessResultLabel.backgroundColor = [UIColor clearColor];
            guessResultLabel.textColor = kGreenColor;
            guessResultLabel.font = NormalFontWithSize(20);
        }
        [cell addSubview:guessResultLabel];
        
        if (!guessResultDescLabel)
        {
            guessResultDescLabel = [[UILabel alloc] initWithFrame:CGRectMake(200, CGRectGetMaxY(guessResultLabel.frame)+10, 120, 20)];
            guessResultDescLabel.backgroundColor = [UIColor clearColor];
            guessResultDescLabel.textColor = KFontNewColorB;
            guessResultDescLabel.font = NormalFontWithSize(13);
        }
        [cell addSubview:guessResultDescLabel];
        
        if (!topRewardBtn)
        {
            topRewardBtn = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth/2+10, 100, 100, 60)];
            [topRewardBtn addTarget:self action:@selector(awardBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
        topRewardBtn.enabled = NO;
        [cell addSubview:topRewardBtn];
        
        if (guessStatus == GuessThree)
        {
            upBtn.hidden = YES;
            downBtn.hidden = YES;
            upGuess.hidden = YES;
            downGuess.hidden = YES;
            
            guessResultImage.hidden = NO;
            guessResultLabel.hidden = NO;
            guessResultDescLabel.hidden = NO;
        }
        else
        {
            upBtn.hidden = NO;
            downBtn.hidden = NO;
            upGuess.hidden = NO;
            downGuess.hidden = NO;
            
            guessResultImage.hidden = YES;
            guessResultLabel.hidden = YES;
            guessResultDescLabel.hidden = YES;
        }
        
        if (guessStatus == GuessOne)
        {
            upBtn.enabled = YES;
            downGuess.enabled = YES;
            
            if (guessResult == 1)
            {
                downGuess.text = @"已猜跌";
                upGuess.textColor = KFontNewColorE;
                upBtn.enabled = NO;
            }
            else if (guessResult == 2)
            {
                upGuess.text = @"已猜涨";
                downGuess.textColor = KFontNewColorE;
                downBtn.enabled = NO;
            }
        }
        else if (guessStatus == GuessTwo)
        {
            upBtn.enabled = YES;
            downGuess.enabled = YES;
            
            if (guessResult == 1)
            {
                downGuess.text = @"已猜跌";
                upGuess.textColor = KFontNewColorE;
                upBtn.enabled = NO;
            }
            else if (guessResult == 2)
            {
                upGuess.text = @"已猜涨";
                downGuess.textColor = KFontNewColorE;
                downBtn.enabled = NO;
            }
        }
        else if (guessStatus == GuessFour)
        {
            upBtn.enabled = NO;
            upGuess.textColor = KFontNewColorE;
            downBtn.enabled = NO;
            downGuess.textColor = KFontNewColorE;
        }
        else if (guessStatus == GuessThree)
        {
            if (guessResult == 1)
            {
                guessResultImage.image = [UIImage imageNamed:@"die_qian"];
            }
            else if (guessResult == 2)
            {
                guessResultImage.image = [UIImage imageNamed:@"zhang_qian"];
            }
            
            NSInteger isAward = [[infoDic objectForKey:@"is_award"] integerValue];
            if (isAward)
            {
                guessResultLabel.textColor = KFontNewColorB;
                guessResultLabel.text = @"已领";
                topRewardBtn.enabled = NO;
            }
            else
            {
                guessResultLabel.textColor = kGreenColor;
                guessResultLabel.text = @"领奖";
                topRewardBtn.enabled = YES;
            }
            guessResultDescLabel.text = [[infoDic objectForKey:@"make_money"] description];
        }
        UIImageView * imageView = [[UIImageView alloc] init];
        imageView.frame = CGRectMake(0, 199, screenWidth, 1);
        imageView.image = [UIImage imageNamed:@"shadow_first"];
        [cell addSubview:imageView];
    }
    else
    {
        NSDictionary * dic = [infoArr objectAtIndex:indexPath.row];
        
        UILabel * dateLable = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, 100, 60)];
        dateLable.backgroundColor = [UIColor clearColor];
        dateLable.textColor = KFontNewColorA;
        dateLable.font = NormalFontWithSize(15);
        dateLable.text = [[dic objectForKey:@"date"] description];
        [cell addSubview:dateLable];
        
        UILabel * guessStatus = [[UILabel alloc] initWithFrame:CGRectMake(120, 0, 100, 60)];
        guessStatus.backgroundColor = [UIColor clearColor];
        guessStatus.textColor = [UIColor blackColor];
        guessStatus.font = NormalFontWithSize(12);
        guessStatus.text = [[dic objectForKey:@"is_true"] description];
        [cell addSubview:guessStatus];
        
        NSInteger isReward = [[dic objectForKey:@"is_award"] integerValue];
        
        UIButton * rewardBtn = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth-100, 5, 80, 50)];
        rewardBtn.titleLabel.font = NormalFontWithSize(15);
        [rewardBtn addTarget:self action:@selector(rewardBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        if (isReward)
        {
            rewardBtn.enabled = NO;
            [rewardBtn setTitle:@"已领" forState:UIControlStateNormal];
            [rewardBtn setTitleColor:KFontNewColorB forState:UIControlStateNormal];
        }
        else
        {
            rewardBtn.enabled = YES;
            [rewardBtn setTitle:@"领奖" forState:UIControlStateNormal];
            [rewardBtn setTitleColor:kGreenColor forState:UIControlStateNormal];
        }
        
        rewardBtn.tag = indexPath.row;
        [cell addSubview:rewardBtn];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//提交用户领奖信息
- (void)awardBtnClicked:(id)sender
{
    NSMutableDictionary * param = [NSMutableDictionary dictionary];
    [param setObject:[[infoDic objectForKey:@"task_id"] description] forKey:@"task_id"];
    [param setObject:[[infoDic objectForKey:@"log_id"] description] forKey:@"log_id"];
    [GFRequestManager connectWithDelegate:self action:Submit_user_award param:param];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    CGFloat sectionHeaderHeight = 80;
    
    if (scrollView.contentOffset.y <= sectionHeaderHeight && scrollView.contentOffset.y >= 0)
    {
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    }
    else if (scrollView.contentOffset.y >= sectionHeaderHeight)
    {
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
}

//提交用户猜大盘结果
- (void)headerGuessBtnClicked:(id)sender
{
    NSInteger guessStatus = [[infoDic objectForKey:@"grail_status"] integerValue];
    if (guessStatus == 2)
    {
        return;
    }
    UIButton * btn = (UIButton *)sender;
    NSMutableDictionary * param = [NSMutableDictionary dictionary];
    NSString * guessValue = [NSString stringWithFormat:@"%d", (int)btn.tag];
    [param setObject:guessValue forKey:@"guess_grail_value"];
    [GFRequestManager connectWithDelegate:self action:Submit_guess_grail param:param];
}

//用户领奖
- (void)rewardBtnClicked:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    if (btn.tag < infoArr.count)
    {
        NSDictionary * dic = [infoArr objectAtIndex:btn.tag];
        NSMutableDictionary * param = [NSMutableDictionary dictionary];
        [param setObject:[[dic objectForKey:@"task_id"] description] forKey:@"task_id"];
        [param setObject:[[dic objectForKey:@"log_id"] description] forKey:@"log_id"];
        [GFRequestManager connectWithDelegate:self action:Submit_user_award param:param];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
