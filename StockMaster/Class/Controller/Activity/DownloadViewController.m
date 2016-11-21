//
//  DownloadViewController.m
//  StockMaster
//
//  Created by 孤星之殇 on 15/6/8.
//  Copyright (c) 2015年 aizhangzhang. All rights reserved.
//

#import "DownloadViewController.h"
#import "GFWebViewController.h"

@interface DownloadViewController ()

@end

@implementation DownloadViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [headerView loadComponentsWithTitle:@"应用下载"];
    [headerView createLine];
    [headerView backButton];
    
    self.view.backgroundColor = KSelectNewColor;
    
    mArr = [[NSMutableArray alloc] initWithCapacity:10];
    
    isJump = YES;
    
    [self createTableView];
    [self createHeadView];
    [self createFootView];
    
    [self requestData];
}

- (void)createTableView
{
    infoTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(headerView.frame), screenWidth, screenHeight-CGRectGetHeight(headerView.frame)) style:UITableViewStylePlain];
    infoTableView.delaysContentTouches = YES;
    infoTableView.backgroundColor = kBackgroundColor;
    infoTableView.delegate = self;
    infoTableView.dataSource = self;
    infoTableView.showsVerticalScrollIndicator = NO;
    infoTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:infoTableView];
}

- (void)createHeadView
{
    headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 35)];
    headView.backgroundColor = kRedColor;
    infoTableView.tableHeaderView = headView;
    
    downLoadLabel = [[UILabel alloc] init];
    downLoadLabel.frame = CGRectMake(0, 0, screenWidth, CGRectGetHeight(headView.frame));
    downLoadLabel.backgroundColor = [UIColor clearColor];
    downLoadLabel.textAlignment = NSTextAlignmentCenter;
    downLoadLabel.textColor = kFontColorA;
    downLoadLabel.text = @"今日有奖下载数量：-/-";
    downLoadLabel.font = NormalFontWithSize(13);
    [headView addSubview:downLoadLabel];
}

- (void)createFootView
{
    footView = [[UIView alloc] init];
    footView.frame = CGRectMake(0, 0, screenWidth, 150);
    footView.backgroundColor = [UIColor clearColor];
    
    UIImageView * imageView = [[UIImageView alloc] init];
    imageView . frame = CGRectMake(screenWidth/2 - 15 , 26, 30, 23);
    imageView.image = [UIImage imageNamed:@"zhangzhang"];
    [footView addSubview:imageView];
    
    UILabel * tipLabel = [[UILabel alloc] init];
    tipLabel.frame = CGRectMake(0, CGRectGetMaxY(imageView.frame)+10, screenWidth, 14);
    tipLabel.text = @"免费炒股,大赚真钱";
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.font = NormalFontWithSize(12);
    tipLabel.textColor = KFontNewColorC;
    tipLabel.backgroundColor = [UIColor clearColor];
    [footView addSubview:tipLabel];
    
    infoTableView.tableFooterView = footView;
}

- (void)requestData
{
    NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
    [GFRequestManager connectWithDelegate:self action:Get_app_download_list param:paramDic];
}

- (void)requestSubmitData:(NSString*)app_id
{
    NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:app_id forKey:@"app_id"];
    [GFRequestManager connectWithDelegate:self action:Submit_app_download_task param:paramDic];
}

- (void)requestAwardData:(NSString*)app_id
{
    NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:app_id forKey:@"app_id"];
    [GFRequestManager connectWithDelegate:self action:Submit_user_app_award param:paramDic];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    [super requestFinished:request];
    
    ASIFormDataRequest * formdataRequest = (ASIFormDataRequest *)request;
    if ([formdataRequest.action isEqualToString:Get_app_download_list])
    {
       NSDictionary * dict = [requestInfo objectForKey:@"data"];
        
        downLoadLabel.text = [NSString stringWithFormat:@"今日有奖下载数量：%@/%@",[dict objectForKey:@"user_app_count"] ,[dict objectForKey:@"app_count"]];
        mArr = [dict objectForKey:@"list"];
    }
    else if ([formdataRequest.action isEqualToString:Submit_app_download_task])
    {
        [self requestData];
    }
    else if ([formdataRequest.action isEqualToString:Submit_user_app_award])
    {
        NSDictionary * dic = [requestInfo objectForKey:@"data"];
        [[CHNAlertView defaultAlertView] initWithAwardText:CHECKDATA(@"award_money") desc1:CHECKDATA(@"prompt1") desc2:CHECKDATA(@"prompt2") buttonDesc:@"知道了，退下~" delegate:self];
        [self requestData];
    }
    
    [infoTableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return mArr.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellID = @"cellID";
    DownloadCell  * cell = [tableView dequeueReusableCellWithIdentifier:CellID];
    if (nil == cell)
    {
        cell = [[DownloadCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellID];
    }
    cell.backgroundColor = kFontColorA;
    cell.delegate = self;
    
    if (mArr.count > 0)
    {
        NSDictionary * dict = [mArr objectAtIndex:indexPath.row];
        
        NSInteger temp = [[dict objectForKey:@"type"] integerValue];

        if (temp == 2)
        {
            cell.nameLabel.hidden = YES;
            cell.descLabel.hidden = YES;
            cell.photoImageView.hidden = YES;
            cell.awardImageView.hidden = YES;
            cell.verImageView.hidden = YES;
            cell.awardBtn.hidden = YES;
            cell.awardTipLabel.hidden = YES;
            
            cell.urlImageView.hidden = NO;
            
            cell.henImageView.frame = CGRectMake(0, 149.5, screenWidth, 0.5);
            
            BOOL  isClick = [[dict objectForKey:@"is_click"] boolValue];
            if (isClick)
            {
                cell.userInteractionEnabled = YES;
            }
            else
            {
                cell.userInteractionEnabled = NO;
            }
            [cell.urlImageView sd_setImageWithURL:[NSURL URLWithString:[dict objectForKey:@"ad_img_url"]] placeholderImage:[UIImage imageNamed:@"yunyingtu"]];
        }
        else if(temp == 1)
        {
            int task_status = [[dict objectForKey:@"task_status"] intValue];
            
            if (task_status == 4)
            {
                task_status = 3;//状态为4时是安卓的状态，在iOS效果和3一样，所以设成3，方便图片设置
            }
            
            
            cell.nameLabel.hidden = NO;
            cell.descLabel.hidden = NO;
            cell.photoImageView.hidden = NO;
            cell.awardImageView.hidden = NO;
            cell.verImageView.hidden = NO;
            cell.awardBtn.hidden = NO;
            cell.awardTipLabel.hidden = NO;
            
            cell.urlImageView.hidden = YES;
            
            cell.henImageView.frame = CGRectMake(0, 89.5, screenWidth, 0.5);
            
            cell.awardBtn.tag = indexPath.row;
            
            cell.nameLabel.text = [[dict objectForKey:@"app_name"] description];
            cell.descLabel.text = [[dict objectForKey:@"app_description"] description];
                        placeholderImage:[UIImage imageNamed:@"icon_user_default"];
            cell.awardTipLabel.text = [[dict objectForKey:@"button_text"] description];
            cell.awardImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"award_%d", task_status]];

            [cell.photoImageView sd_setImageWithURL:[NSURL URLWithString:[dict objectForKey:@"app_icon_url"]] placeholderImage:[UIImage imageNamed:@"appIcon"]];
            
            if (task_status == 3)
            {
                cell.awardTipLabel.textColor = KBlueColor;
            }
            else
            {
                cell.awardTipLabel.textColor = kRedColor;
            }
            
           
        }
    }
    
    return cell;
}

- (void)jumpToAppStore:(NSInteger)tag
{
    NSDictionary * dict = [mArr objectAtIndex:tag];

    NSInteger task_status = [[dict objectForKey:@"task_status"] integerValue];
    
    if (task_status == 2)
    {
        isJump = NO;
    }
    else
    {
        isJump = YES;
    }
    
    if (isJump)
    {
//        NSURL * task_url = [NSURL URLWithString:@"http://um0.cn/4qqhQz"];
        NSURL * task_url = [NSURL URLWithString:[dict objectForKey:@"app_ios_package_url"]];
        [[UIApplication sharedApplication] openURL:task_url];
        
        [self requestSubmitData:[[dict objectForKey:@"app_id"] description]];
    }
    else
    {
        [self requestAwardData:[[dict objectForKey:@"app_id"] description]];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView  deselectRowAtIndexPath:indexPath animated:NO];
    
    if (mArr.count > 0)
    {
        NSDictionary * dict = [mArr objectAtIndex:indexPath.row];
        NSInteger temp = [[dict objectForKey:@"type"] integerValue];
        
        if ( temp == 2)
        {
            GFWebViewController * GWVC = [[GFWebViewController alloc] init];
            GWVC.title = [[dict objectForKey:@"ad_title"] description];
            GWVC.pageType = WebViewTypePresent;
            GWVC.flag = 0;
            GWVC.requestUrl = [NSURL URLWithString:[[dict objectForKey:@"ad_link_url"] description]];
            [self presentViewController:GWVC animated:YES completion:nil];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger temp = 1;
    
    if (mArr.count > 0)
    {
        temp = [[[mArr objectAtIndex:indexPath.row] objectForKey:@"type"] integerValue];
    }
    if ( temp == 2)
    {
        return 150;
    }
    
    return 90;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
