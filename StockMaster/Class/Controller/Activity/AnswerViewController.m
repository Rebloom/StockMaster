//
//  AnswerViewController.m
//  StockMaster
//
//  Created by Rebloom on 14/11/17.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "AnswerViewController.h"

@interface AnswerViewController ()

@end

@implementation AnswerViewController

- (void)dealloc
{
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    headerView.backgroundColor = kFontColorA;
    [headerView backButton];
    [headerView loadComponentsWithTitle:@"每日一题"];
    
    [headerView createLine];
    
    infoArr = [[NSMutableArray alloc] initWithCapacity:10];
    infoDic = [[NSDictionary alloc] init];
    
    infoTable = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(headerView.frame), screenWidth, screenHeight-CGRectGetHeight(headerView.frame))];
    infoTable.dataSource = self;
    infoTable.backgroundColor = KSelectNewColor;
    infoTable.delegate = self;
    infoTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:infoTable];
    
    [self createFootView];
    [self requestQuestion];
    [self requestQuestionHistory];
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

//获取用户当天答题状态
- (void)requestQuestion
{
    NSMutableDictionary * param = [NSMutableDictionary dictionary];
    [GFRequestManager connectWithDelegate:self action:Get_answer_status param:param];
}

//获取用户答题历史记录
- (void)requestQuestionHistory
{
    NSMutableDictionary * param = [NSMutableDictionary dictionary];
    [GFRequestManager connectWithDelegate:self action:Get_user_answer_count_award param:param];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    [super requestFinished:request];
    
    ASIFormDataRequest * formDataRequest = (ASIFormDataRequest *)request;
    if ([formDataRequest.action isEqualToString:Get_answer_status])
    {
        infoDic = [[requestInfo objectForKey:@"data"] mutableCopy];
    }
    else if ([formDataRequest.action isEqualToString:Get_user_answer_count_award])
    {
        NSDictionary * dic = [requestInfo objectForKey:@"data"];
        sectionLabel.text = [NSString stringWithFormat:@"累积奖励:(%@)",[[dic objectForKey:@"total_answer"] description]];
        infoArr = [[dic objectForKey:@"total_award_list"] mutableCopy];
    }
    else if ([formDataRequest.action isEqualToString:Submit_user_answer])
    {
        infoDic = [[requestInfo objectForKey:@"data"] mutableCopy];
        [self requestQuestionHistory];
    }
    else if ([formDataRequest.action isEqualToString:Submit_user_answer_total_award])
    {
        NSDictionary * dic = [requestInfo objectForKey:@"data"];
        [[CHNAlertView defaultAlertView] initWithAwardText:CHECKDATA(@"award_money") desc1:CHECKDATA(@"prompt1") desc2:CHECKDATA(@"prompt2") buttonDesc:@"知道了，退下~" delegate:self];
        [self requestQuestionHistory];
    }
    else if ([formDataRequest.action isEqualToString:Submit_user_award])
    {
        NSDictionary * dic = [requestInfo objectForKey:@"data"];
        [[CHNAlertView defaultAlertView] initWithAwardText:CHECKDATA(@"award_money") desc1:CHECKDATA(@"prompt1") desc2:CHECKDATA(@"prompt2") buttonDesc:@"知道了，退下~" delegate:self];
        [self requestQuestion];
    }
    
    [infoTable reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
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
    
    if (!sectionLabel)
    {
        sectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(timeImage.frame)+5, 0, screenWidth-20, 60)];
    }
    sectionLabel.backgroundColor = [UIColor clearColor];
    sectionLabel.textColor = KFontNewColorA;
    sectionLabel.font = NormalFontWithSize(16);
    [tableHeader addSubview:sectionLabel];
    
    return tableHeader;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 60)];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.section == 0)
    {
        answerId = [[infoDic objectForKey:@"question_id"] integerValue];
        NSInteger isAnswerd = [[infoDic objectForKey:@"is_answer"] integerValue];
        NSInteger isAward = [[infoDic objectForKey:@"is_award"] integerValue];
        NSInteger isTure = [[infoDic objectForKey:@"is_true"] integerValue];
        
        if (!answerImage)
        {
            answerImage = [[UIImageView alloc] initWithFrame:CGRectMake(20, 45, 22, 22)];
            answerImage.image = [UIImage imageNamed:@"zhuanqian"];
        }
        [cell addSubview:answerImage];
        
        if (!question)
        {
            question = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(answerImage.frame)+5, 40, screenWidth-60, 40)];
            question.numberOfLines = 0;
            question.backgroundColor = [UIColor clearColor];
            question.textColor = [UIColor blackColor];
            question.font = NormalFontWithSize(16);
        }
        [cell addSubview:question];
        
        if (!btn1)
        {
            btn1 = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(question.frame)+15, screenWidth/2, 105)];
            btn1.tag = 1;
            [btn1 setBackgroundImage:[KSelectNewColor image] forState:UIControlStateHighlighted];
            [btn1 addTarget:self action:@selector(answerBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
        [cell addSubview:btn1];
        
        if (!btn2)
        {
            btn2 = [[UIButton alloc] initWithFrame:CGRectMake(160, CGRectGetMaxY(question.frame)+15, screenWidth/2, 105)];
            btn2.tag = 2;
            [btn2 setBackgroundImage:[KSelectNewColor image] forState:UIControlStateHighlighted];
            [btn2 addTarget:self action:@selector(answerBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
        [cell addSubview:btn2];
        
        if (!AImage)
        {
            AImage = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(answerImage.frame), CGRectGetMaxY(question.frame)+35, 14, 14.5)];
            AImage.image = [UIImage imageNamed:@"aa"];
        }
        [cell addSubview:AImage];
        
        if (!BImage)
        {
            BImage = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth/2+10, CGRectGetMaxY(question.frame)+35, 14, 14.5)];
            BImage.image = [UIImage imageNamed:@"bb"];
        }
        [cell addSubview:BImage];
        
        if (!answer1)
        {
            answer1 = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(answerImage.frame), CGRectGetMaxY(AImage.frame)+10, 100, 40)];
            answer1.numberOfLines = 2;
            answer1.backgroundColor = [UIColor clearColor];
            answer1.textColor = KFontNewColorB;
            answer1.font = NormalFontWithSize(13);
        }
        [cell addSubview:answer1];
        
        if (!answer2)
        {
            answer2 = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth/2+10, CGRectGetMaxY(BImage.frame)+10, 100, 40)];
            answer2.numberOfLines = 2;
            answer2.backgroundColor = [UIColor clearColor];
            answer2.textColor = KFontNewColorB;
            answer2.font = NormalFontWithSize(13);
        }
        [cell addSubview:answer2];
        
        if (!resultImage)
        {
            resultImage = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(answerImage.frame), CGRectGetMaxY(question.frame)+15, 75, 75)];
        }
        [cell addSubview:resultImage];
        
        if (!centerLine)
        {
            centerLine = [[UIView alloc] initWithFrame:CGRectMake(screenWidth/2, CGRectGetMaxY(question.frame)+5, .5, 100)];
            centerLine.backgroundColor = KColorHeader;
        }
        [cell addSubview:centerLine];
        centerLine.hidden = YES;
        
        if (!guessResultLabel)
        {
            guessResultLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth-120, 100, 100, 20)];
            guessResultLabel.backgroundColor = [UIColor clearColor];
            guessResultLabel.textColor = kGreenColor;
            guessResultLabel.font = NormalFontWithSize(20);
        }
        [cell addSubview:guessResultLabel];
        
        if (!guessResultDescLabel)
        {
            guessResultDescLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth-120, CGRectGetMaxY(guessResultLabel.frame)+10, 120, 20)];
            guessResultDescLabel.backgroundColor = [UIColor clearColor];
            guessResultDescLabel.textColor = KFontNewColorB;
            guessResultDescLabel.font = NormalFontWithSize(13);
        }
        [cell addSubview:guessResultDescLabel];
        
        if (!resultBtn)
        {
            resultBtn = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth/2+10, 100, 100, 60)];
            [resultBtn addTarget:self action:@selector(topAwardBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
        [cell addSubview:resultBtn];
        
        if (isAnswerd)
        {
            AImage.hidden = YES;
            BImage.hidden = YES;
            btn1.hidden = YES;
            btn2.hidden = YES;
            answer1.hidden = YES;
            answer2.hidden = YES;
            resultBtn.enabled = YES;
            centerLine.hidden = NO;
            
            question.text = [infoDic objectForKey:@"answer_title"];
            question.numberOfLines = 2;
            [question sizeThatFits:CGSizeMake(260, 40)];
            
            guessResultDescLabel.text = [infoDic objectForKey:@"answer_text"];
            
            if (isAward)
            {
                guessResultLabel.textColor = KFontNewColorB;
                guessResultLabel.text = @"已领";
                resultBtn.enabled = NO;
                resultImage.image = [UIImage imageNamed:@"dui"];
            }
            else
            {
                if (isTure)
                {
                    guessResultLabel.textColor = kGreenColor;
                    guessResultLabel.text = @"领奖";
                    resultBtn.enabled = YES;
                    resultImage.image = [UIImage imageNamed:@"dui"];
                }
                else
                {
                    guessResultLabel.textColor = KFontNewColorB;
                    guessResultLabel.text = @"答错";
                    resultBtn.enabled = NO;
                    resultImage.image = [UIImage imageNamed:@"cuo"];
                }
            }
        }
        else
        {
            AImage.hidden = NO;
            BImage.hidden = NO;
            btn1.hidden = NO;
            btn2.hidden = NO;
            answer1.hidden = NO;
            answer2.hidden = NO;
            resultBtn.enabled = NO;
            centerLine.hidden = YES;
            
            question.text = [[infoDic objectForKey:@"question"] description];
            answer1.text = [[infoDic objectForKey:@"answer1"] description];
            answer2.text = [[infoDic objectForKey:@"answer2"] description];
            question.numberOfLines = 2;
            [question sizeThatFits:CGSizeMake(260, 40)];
        }
        UIImageView * imageView = [[UIImageView alloc] init];
        imageView.frame = CGRectMake(0, 199, screenWidth, 1);
        imageView.image = [UIImage imageNamed:@"shadow_first"];
        [cell addSubview:imageView];
    }
    else
    {
        NSDictionary * dic = [infoArr objectAtIndex:indexPath.row];
        
        UILabel * dateLable = [[UILabel alloc] initWithFrame:CGRectMake(40, 22, 200, 16)];
        dateLable.backgroundColor = [UIColor clearColor];
        dateLable.textColor = KFontNewColorA;
        dateLable.font = NormalFontWithSize(16);
        dateLable.text = [[dic objectForKey:@"award_money"] description];
        [cell addSubview:dateLable];
        [dateLable sizeToFit];
        
        NSInteger isAward = [[dic objectForKey:@"is_award"] integerValue];
        
        UIButton * rewardBtn = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth-100, 5, 80, 50)];
        rewardBtn.titleLabel.textAlignment = NSTextAlignmentRight;
        rewardBtn.layer.cornerRadius = 4;
        rewardBtn.layer.masksToBounds = YES;
        rewardBtn.titleLabel.font = NormalFontWithSize(15);
        [rewardBtn addTarget:self action:@selector(awardBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        if (isAward == 0)
        {
            rewardBtn.enabled = YES;
            [rewardBtn setTitle:@"领奖" forState:UIControlStateNormal];
            [rewardBtn setTitleColor:kGreenColor forState:UIControlStateNormal];
        }
        else if (isAward == 1)
        {
            rewardBtn.enabled = NO;
            [rewardBtn setTitle:@"已领" forState:UIControlStateNormal];
            [rewardBtn setTitleColor:KFontNewColorB forState:UIControlStateNormal];
        }
        else if (isAward == 2)
        {
            rewardBtn.enabled = NO;
            [rewardBtn setTitle:@"未达成" forState:UIControlStateNormal];
            [rewardBtn setTitleColor:KFontNewColorB forState:UIControlStateNormal];
        }
        
        rewardBtn.tag = indexPath.row;
        [cell addSubview:rewardBtn];
    }
    return cell;
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

//提交用户答题数据
- (void)answerBtnClicked:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    NSString * answerValue = [NSString stringWithFormat:@"%d", (int)btn.tag];
    if (btn.tag == 1 || btn.tag == 2)
    {
        NSMutableDictionary * param = [NSMutableDictionary dictionary];
        [param setObject:answerValue forKey:@"answer_value"];
        [param setObject:[NSString stringWithFormat:@"%d", (int)answerId] forKey:@"question_id"];
        [GFRequestManager connectWithDelegate:self action:Submit_user_answer param:param];
    }
}

//用户领奖
- (void)topAwardBtnClicked:(id)sender
{
    NSMutableDictionary * param = [NSMutableDictionary dictionary];
    [param setObject:[[infoDic objectForKey:@"task_id"] description] forKey:@"task_id"];
    [param setObject:[[infoDic objectForKey:@"log_id"] description] forKey:@"log_id"];
    [GFRequestManager connectWithDelegate:self action:Submit_user_award param:param];
}

//用户提交答题的领奖
- (void)awardBtnClicked:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    if (btn.tag < infoArr.count)
    {
        NSDictionary * dic = [infoArr objectAtIndex:btn.tag];
        NSMutableDictionary * param = [NSMutableDictionary dictionary];
        [param setObject:[[dic objectForKey:@"log_id"] description] forKey:@"log_id"];
        [GFRequestManager connectWithDelegate:self action:Submit_user_answer_total_award param:param];
    }
}

- (void)buttonClicked:(id)sender
{
    [self back];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
