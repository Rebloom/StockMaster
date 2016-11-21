//
//  MessageBoxViewController.m
//  StockMaster
//
//  Created by Rebloom on 15/3/13.
//  Copyright (c) 2015年 Rebloom. All rights reserved.
//

#import "MessageBoxViewController.h"

@implementation MessageBoxViewController


- (void)dealloc
{
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [headerView loadComponentsWithTitle:@"消息盒子"];
    [headerView backButton];
    [headerView createLine];
    
    self.view.backgroundColor = KSelectNewColor;
    
    UIButton * searchButton = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth-60, beginX, 60, 45)];
    searchButton.tag = 3;
    [searchButton addTarget:self action:@selector(headerBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:searchButton];
    
    UIImageView * backImage = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth-36, beginX+13, 18, 18)];
    backImage.image = [UIImage imageNamed:@"icon_shezhi1"];
    [headerView addSubview:backImage];
    
    needLoadMore = YES;
    
    infoArr = [[NSMutableArray alloc] initWithCapacity:10];
    
    infoTable = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(headerView.frame), screenWidth, screenHeight-CGRectGetHeight(headerView.frame))];
    infoTable.dataSource = self;
    infoTable.delegate = self;
    infoTable.backgroundColor = kBackgroundColor;
    infoTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:infoTable];
}

- (void)headerBtnClicked:(id)sender
{
    NoticeViewController * NVC = [[NoticeViewController alloc] init];
    [self pushToViewController:NVC];
}

- (void)getMessageList
{
    isFirstLoad = YES;
    NSMutableDictionary * param = [NSMutableDictionary dictionary];
    if (infoArr.count)
    {
        [param setObject:[[[infoArr lastObject] objectForKey:@"push_id"] description] forKey:@"start_id"];
    }
    else
    {
        [param setObject:@"0" forKey:@"start_id"];
    }
    [GFRequestManager connectWithDelegate:self action:Get_user_push_message_list param:param];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    [super requestFinished:request];
    
    ASIFormDataRequest * formDataRequest = (ASIFormDataRequest *)request;
    if ([formDataRequest.action isEqualToString:Get_user_push_message_list])
    {
        NSArray * temp = [requestInfo objectForKey:@"data"];
        if (temp.count)
        {
            if (infoArr.count)
            {
                [infoArr addObjectsFromArray:temp];
            }
            else
            {
                infoArr = [temp mutableCopy];
            }
        }
        else
        {
            needLoadMore = NO;
        }
        [infoTable reloadData];
    }
    else if ([formDataRequest.action isEqualToString:Submit_delete_user_push_message])
    {
        if (clearAll)
        {
            [infoArr removeAllObjects];
        }
        else
        {
            if (removedIndex < infoArr.count)
            {
                [infoArr removeObjectAtIndex:removedIndex];
            }
        }
        [infoTable reloadData];
        
        [[TKAlertCenter defaultCenter] postAlertWithMessage:@"删除成功" withType:ALERTTYPESUCCESS];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return infoArr.count+1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (infoArr.count == indexPath.row)
    {
        if (infoArr.count)
        {
            return 156;
        }
        return infoTable.frame.size.height;
    }
    
    NSDictionary * dic = [infoArr objectAtIndex:indexPath.row];
    NSString * content = [[dic objectForKey:@"message_contents"] description];
    
    CGSize pageSize = [content sizeWithFont:NormalFontWithSize(12)
                          constrainedToSize:CGSizeMake(screenWidth-40,CGFLOAT_MAX)
                              lineBreakMode:NSLineBreakByWordWrapping];
    return 20+15+8+pageSize.height+20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (infoArr.count == 0 && isFirstLoad)
    {
        UITableViewCell * cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, screenWidth, infoTable.frame.size.height)];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor= [UIColor clearColor];

        UILabel * messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, screenWidth, infoTable.frame.size.height)];
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.backgroundColor = [UIColor clearColor];
        messageLabel.textColor = @"#929292".color;
        messageLabel.font = NormalFontWithSize(13);
        [cell addSubview:messageLabel];
        messageLabel.text = @"暂时没有新消息";
        
        return cell;
    }
    
    float cellHeight = 0;
    if (indexPath.row == infoArr.count)
    {
        cellHeight = 156;
    }
    else
    {
        NSDictionary * dic = [infoArr objectAtIndex:indexPath.row];
        NSString * contentText = [[dic objectForKey:@"message_contents"] description];
        
        CGSize pageSize = [contentText sizeWithFont:NormalFontWithSize(12)
                                  constrainedToSize:CGSizeMake(screenWidth-40,CGFLOAT_MAX)
                                      lineBreakMode:NSLineBreakByWordWrapping];
        cellHeight = 20+15+8+pageSize.height+20;
    }
    
    
    UITableViewCell * cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, screenWidth, cellHeight)];

    if (indexPath.row == infoArr.count)
    {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (needLoadMore)
        {
            cell.backgroundColor= [UIColor clearColor];

            UILabel * messageLabel = [[UILabel alloc] initWithFrame:cell.frame];
            messageLabel.textAlignment = NSTextAlignmentCenter;
            messageLabel.backgroundColor = [UIColor clearColor];
            messageLabel.textColor = @"#929292".color;
            messageLabel.font = NormalFontWithSize(13);
            [cell addSubview:messageLabel];
            messageLabel.text = @"加载中...";
            [self getMessageList];
        }
        else
        {
            cell.backgroundColor= [UIColor clearColor];
            
            UIView * footView = [[UIView alloc] init];
            footView.frame = CGRectMake(0, 0, screenWidth, 156);
            footView.backgroundColor = [UIColor clearColor];
            
            UILabel * ideaLabel = [[UILabel alloc] init];
            ideaLabel.frame = CGRectMake(0,footView.frame.size.height-90, screenWidth, 12);
            ideaLabel.text = @"免费炒股，大赚真钱";
            ideaLabel.textAlignment = NSTextAlignmentCenter;
            ideaLabel.textColor = KFontNewColorC;
            ideaLabel.font = NormalFontWithSize(12);
            [footView addSubview:ideaLabel];
            
            UIImageView * iconImgView = [[UIImageView alloc] init];
            iconImgView.frame = CGRectMake(screenWidth/2-15, CGRectGetMinY(ideaLabel.frame) - 33, 30, 23);
            iconImgView.image = [UIImage imageNamed:@"zhangzhang"];
            [footView addSubview:iconImgView];
            
            [cell addSubview:footView];
        }
        
        return cell;
    }
    
    NSDictionary * dic = [infoArr objectAtIndex:indexPath.row];
    
    UIScrollView * cellScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, cellHeight)];
    cellScroll.userInteractionEnabled = YES;
    cellScroll.delegate = self;
    cellScroll.contentSize = CGSizeMake(screenWidth+124, cell.frame.size.height);
    cellScroll.showsHorizontalScrollIndicator = NO;
    cellScroll.showsVerticalScrollIndicator = NO;
    [cell addSubview:cellScroll];
    
    UIButton * contentBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, screenWidth, cellHeight)];
    contentBtn.tag = indexPath.row;
    [contentBtn addTarget:self action:@selector(contentBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cellScroll addSubview:contentBtn];
    
    UILabel * title = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 200, 15)];
    title.backgroundColor = [UIColor clearColor];
    title.textColor = @"#929292".color;
    title.font = NormalFontWithSize(15);
    title.text = [dic objectForKey:@"message_title"];
    if ([[dic objectForKey:@"type"] integerValue] == 1)
    {
        title.frame = CGRectMake(28, 20, 200, 15);
        title.textColor = @"#df5d57".color;
    }
    
    [cellScroll addSubview:title];
    
    NSString * contentText = [[dic objectForKey:@"message_contents"] description];
    
    CGSize pageSize = [contentText sizeWithFont:NormalFontWithSize(12)
                              constrainedToSize:CGSizeMake(screenWidth-40,CGFLOAT_MAX)
                                  lineBreakMode:NSLineBreakByWordWrapping];
    
    UILabel * contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(title.frame)+8, screenWidth-40, pageSize.height)];
    contentLabel.numberOfLines = 0;
    contentLabel.backgroundColor = [UIColor clearColor];
    contentLabel.textColor = @"#929292".color;
    contentLabel.font = NormalFontWithSize(12);
    contentLabel.text = [dic objectForKey:@"message_contents"];
    [cellScroll addSubview:contentLabel];
    
    UILabel * timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth-220, 22.5, 200, 10)];
    timeLabel.textAlignment = NSTextAlignmentRight;
    timeLabel.backgroundColor = [UIColor clearColor];
    timeLabel.textColor = @"#929292".color;
    timeLabel.font = NormalFontWithSize(10);
    timeLabel.text = [dic objectForKey:@"push_date"];
    [cellScroll addSubview:timeLabel];
    
    UIButton * clearBtn = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth, 0, 62, cellHeight)];
    [clearBtn addTarget:self action:@selector(clearBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [clearBtn setTitle:@"清空" forState:UIControlStateNormal];
    clearBtn.titleLabel.textColor = [UIColor whiteColor];
    clearBtn.titleLabel.font = NormalFontWithSize(15);
    clearBtn.backgroundColor = kGreenColor;
    [cellScroll addSubview:clearBtn];
    
    UIButton * deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(clearBtn.frame), 0, 62, cellHeight)];
    deleteBtn.tag = indexPath.row;
    [deleteBtn addTarget:self action:@selector(deleteBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
    deleteBtn.titleLabel.textColor = [UIColor whiteColor];
    deleteBtn.titleLabel.font = NormalFontWithSize(15);
    deleteBtn.backgroundColor = kRedColor;
    [cellScroll addSubview:deleteBtn];
    
    UIView * line = [[UIView alloc] initWithFrame:CGRectMake(0, cellHeight-.5, screenWidth, .5)];
    line.backgroundColor = KColorHeader;
    [cell addSubview:line];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self cellBack];
}

- (void)cellBack
{
    for (int i = 0; i < infoArr.count; i++)
    {
        UITableViewCell * cell = [infoTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        
        for (UIView * subView in cell.subviews)
        {
            if ([subView isKindOfClass:[UIScrollView class]])
            {
                UIScrollView * scrollView = (UIScrollView *)subView;
                [scrollView scrollRectToVisible:CGRectMake(0, 0, screenWidth, 75) animated:YES];
            }
        }
    }
}

- (void)contentBtnClicked:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    if (btn.tag < infoArr.count)
    {
        NSDictionary * dic = [infoArr objectAtIndex:btn.tag];
        
        if ([[dic objectForKey:@"stock_code"] description].length)
        {
            StockDetailViewController * SDVC = [[StockDetailViewController alloc] init];
            StockInfoEntity * stockInfo = [[StockInfoCoreDataStorage sharedInstance] getStockInfoWithCode:[[dic objectForKey:@"stock_code"] description] exchange:[[dic objectForKey:@"stock_exchange"] description]];
            SDVC.stockInfo = stockInfo;
            [self pushToViewController:SDVC];
        }
    }
}

- (void)clearBtnClicked:(id)sender
{
    clearAll = YES;
    NSMutableDictionary * param = [NSMutableDictionary dictionary];
    [param setObject:@"2" forKey:@"action"];
    [GFRequestManager connectWithDelegate:self action:Submit_delete_user_push_message param:param];
}

- (void)deleteBtnClicked:(id)sender
{
    clearAll = NO;
    UIButton * btn = (UIButton *)sender;
    NSMutableDictionary * param = [NSMutableDictionary dictionary];
    [param setObject:@"1" forKey:@"action"];
    [param setObject:[[infoArr objectAtIndex:btn.tag] objectForKey:@"push_id"] forKey:@"push_id"];
    [GFRequestManager connectWithDelegate:self action:Submit_delete_user_push_message param:param];
    
    removedIndex = btn.tag;
}


@end
