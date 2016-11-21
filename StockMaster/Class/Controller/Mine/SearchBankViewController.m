//
//  SearchBankViewController.m
//  StockMaster
//
//  Created by Rebloom on 15/5/6.
//  Copyright (c) 2015年 aizhangzhang. All rights reserved.
//

#import "SearchBankViewController.h"

@implementation SearchBankViewController

@synthesize searchType;

@synthesize delegate;
@synthesize bankID;

- (void)dealloc
{
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    infoArr = [[NSMutableArray alloc] initWithCapacity:10];
    searchArr = [[NSMutableArray alloc] initWithCapacity:10];
    
    if (searchType == 1)
    {
        [headerView loadComponentsWithTitle:@"选择银行卡"];
        [self requestBankList];
    }
    else if (searchType == 2)
    {
        [headerView loadComponentsWithTitle:@"选择支行"];
        [self requestProvinceList];
    }
    [headerView backButton];
    [headerView createLine];
    
    infoTable = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(headerView.frame), screenWidth, screenHeight-CGRectGetHeight(headerView.frame))];
    infoTable.backgroundColor = kBackgroundColor;
    infoTable.delegate = self;
    infoTable.dataSource = self;
    infoTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    infoTable.showsVerticalScrollIndicator = NO;
    [self.view addSubview:infoTable];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    [super requestFinished:request];
    
    if ([requestInfo objectForKey:@"data"])
    {
        [infoArr removeAllObjects];
        NSDictionary * back = [requestInfo objectForKey:@"data"];
        
        ASIFormDataRequest * formDataRequest = (ASIFormDataRequest *)request;
        if ([formDataRequest.action isEqualToString:Get_bank_list])
        {
            searchStatus = 1;
        }
        else if ([formDataRequest.action isEqualToString:Get_bank_province_list])
        {
            searchStatus = 2;
        }
        else if ([formDataRequest.action isEqualToString:Get_bank_city_list])
        {
            searchStatus = 3;
        }
        else if ([formDataRequest.action isEqualToString:Get_bank_branch_list])
        {
            searchStatus = 4;
            for (UIView * view in headerView.subviews)
            {
                [view removeFromSuperview];
            }
//            GFTextField * searchField = [[GFTextField alloc] init ];
//            searchField.placeHolderColor = 1;
//            searchField.frame = CGRectMake(50, 28, screenWidth-70, 30);
//            searchField.layer.cornerRadius = 5;
//            searchField.placeholder = @"检索支行";
//            searchField.layer.masksToBounds = YES;
//            searchField.userInteractionEnabled = YES;
//            searchField.backgroundColor = kFontColorA;
//            searchField.delegate = self;
//            searchField.font = NormalFontWithSize(14);
//            searchField.textColor = kTitleColorA;
//            searchField.clearButtonMode = UITextFieldViewModeWhileEditing;
//            //关闭系统自动联想和首字母大写
//            [searchField setAutocorrectionType:UITextAutocorrectionTypeNo];
//            [searchField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
//            [headerView addSubview:searchField];
            
            UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width
                                                                                   , 44)];
            searchBar.placeholder = @"搜索";
            
            // 添加 searchbar 到 headerview
            infoTable.frame = CGRectMake(0, beginX, screenWidth, screenHeight-beginX);
            infoTable.tableHeaderView = searchBar;
            
            // 用 searchbar 初始化 SearchDisplayController
            // 并把 searchDisplayController 和当前 controller 关联起来
            searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
            
            // searchResultsDataSource 就是 UITableViewDataSource
            searchDisplayController.searchResultsDataSource = self;
            // searchResultsDelegate 就是 UITableViewDelegate
            searchDisplayController.searchResultsDelegate = self;
        }
        infoArr = [[back objectForKey:@"list"] mutableCopy];
        if (searchStatus == 4)
        {
            [self transInfoArrToSearchArr];
        }
        [infoTable reloadData];
    }
}

- (void)transInfoArrToSearchArr
{
    [searchArr removeAllObjects];
    for (NSDictionary * dic in infoArr)
    {
        [searchArr addObject:[dic objectForKey:@"branch_bank_name"]];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [super requestFailed:request];
}

- (void)requestBankList
{
    NSMutableDictionary * param = [NSMutableDictionary dictionary];
    [GFRequestManager connectWithDelegate:self action:Get_bank_list param:param];
}

- (void)requestProvinceList
{
    NSMutableDictionary * param = [NSMutableDictionary dictionary];
    [param setObject:bankID forKey:@"bank_id"];
    [GFRequestManager connectWithDelegate:self action:Get_bank_province_list param:param];
}

- (void)requestCityList
{
    NSMutableDictionary * param = [NSMutableDictionary dictionary];
    [param setObject:bankID forKey:@"bank_id"];
    [param setObject:province forKey:@"province"];
    [GFRequestManager connectWithDelegate:self action:Get_bank_city_list param:param];
}

- (void)requestBranchList
{
    NSMutableDictionary * param = [NSMutableDictionary dictionary];
    [param setObject:bankID forKey:@"bank_id"];
    [param setObject:province forKey:@"province"];
    [param setObject:city forKey:@"city"];
    [GFRequestManager connectWithDelegate:self action:Get_bank_branch_list param:param];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == infoTable)
    {
        return infoArr.count;
    }
    else
    {
        // 谓词搜索
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"self contains [cd] %@",searchDisplayController.searchBar.text];
        return [[NSArray alloc] initWithArray:[searchArr filteredArrayUsingPredicate:predicate]].count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, 320, 45)];

    if (tableView != infoTable)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self contains [cd] %@",searchDisplayController.searchBar.text];
        NSArray * filterData =  [[NSArray alloc] initWithArray:[searchArr filteredArrayUsingPredicate:predicate]];
        
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 320, 45)];
        label.backgroundColor = [UIColor clearColor];
        label.font = NormalFontWithSize(15);
        label.textColor = KFontNewColorA;
        label.text = [filterData objectAtIndex:indexPath.row];
        
        [cell addSubview:label];
        
        return cell;
    }
    
    NSDictionary * dic = [infoArr objectAtIndex:indexPath.row];
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 320, 45)];
    label.backgroundColor = [UIColor clearColor];
    label.font = NormalFontWithSize(15);
    label.textColor = KFontNewColorA;
    
    if (searchStatus == 1)
    {
        label.text = [dic objectForKey:@"bank_name"];
    }
    else if (searchStatus == 2)
    {
        label.text = [dic objectForKey:@"province"];
    }
    else if (searchStatus == 3)
    {
        label.text = [dic objectForKey:@"city"];
    }
    else if (searchStatus == 4)
    {
        label.text = [dic objectForKey:@"branch_bank_name"];
    }
    [cell addSubview:label];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary * dic = [infoArr objectAtIndex:indexPath.row];
    if (searchStatus == 1)
    {
        if ([self.delegate respondsToSelector:@selector(didChooseBank:)])
        {
            [self.delegate didChooseBank:dic];
            [self back];
        }
    }
    else if (searchStatus == 2)
    {
        province = [dic objectForKey:@"province"];
        [self requestCityList];
    }
    else if (searchStatus == 3)
    {
        city = [dic objectForKey:@"city"];
        [self requestBranchList];
    }
    else if (searchStatus == 4)
    {
        if ([self.delegate respondsToSelector:@selector(didChooseBranchBank:)])
        {
            if (tableView == infoTable)
            {
                [self.delegate didChooseBranchBank:dic];
                [self back];
            }
            else
            {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self contains [cd] %@",searchDisplayController.searchBar.text];
                NSArray * filterData =  [[NSArray alloc] initWithArray:[searchArr filteredArrayUsingPredicate:predicate]];
                for (NSDictionary * dic in infoArr)
                {
                    if ([[dic objectForKey:@"branch_bank_name"] isEqualToString:[filterData objectAtIndex:indexPath.row]])
                    {
                        [self.delegate didChooseBranchBank:dic];
                        [self back];
                    }
                }
            }
        }
    }
}

@end
