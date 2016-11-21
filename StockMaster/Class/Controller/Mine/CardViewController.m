//
//  CardViewController.m
//  StockMaster
//
//  Created by dalikeji on 14-10-9.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//
#import "CardViewController.h"
#import "ManageCardViewController.h"
#import "AddCardViewController.h"
#import "WithDrawCashViewController.h"
#import "UIImageView+WebCache.h"
#import "ManageCardViewController.h"
#import "EarnMoneyViewController.h"

@interface CardViewController ()

@end

@implementation CardViewController

@synthesize deliverType;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.view.backgroundColor = kBackgroundColor;
    }
    return self;
}

- (void)dealloc
{
}

// 请求银行卡列表
- (void)requestCardList
{
    NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
    if (deliverType == 2)
    {
        //正常的银行卡
        [paramDic setObject:@"1" forKey:@"filter_type"];
    }
    else
    {
        //所有银行卡（包括无效的）
        [paramDic setObject:@"0" forKey:@"filter_type"];
    }
    [GFRequestManager connectWithDelegate:self action:Get_user_bank_card param:paramDic];
}

// 删除银行卡请求
- (void)requestDeleteCard:(NSString*)card_id
{
    NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:card_id forKey:@"card_id"];
    [GFRequestManager connectWithDelegate:self action:Delete_user_bank_card param:paramDic];
}

// 请求成功的回调
-(void)requestFinished:(ASIHTTPRequest *)request
{
    [super requestFinished:request];
    
    // 没绑定过身份证号 err_code = 10053   老版  539
    if ([[[requestInfo objectForKey:@"err_code"] description]isEqualToString:@"10053"])
    {
        AddCardViewController * ACVC = [[AddCardViewController alloc] init];
        ACVC.isFirst = YES;
        [GFStaticData saveObject:@"2" forKey:KTagCardBack];
        ACVC.modelType = 1; //进行添加
        [self pushToViewController:ACVC];
    }
    else
    {
        if (manageArr.count>0)
        {
            [manageArr removeAllObjects];
        }
        ASIFormDataRequest * formDataRequest = (ASIFormDataRequest *)request;
        if ([formDataRequest.action isEqualToString:Get_user_bank_card])
        {
            NSMutableArray * mArr = [requestInfo objectForKey:@"data"];
            manageArr = [mArr mutableCopy];
        }
        else if ([formDataRequest.action isEqualToString:Delete_user_bank_card])
        {
            [self requestCardList];
        }
        else if ([formDataRequest.action isEqualToString:Get_bank_bind_info])
        {
            AddCardViewController * ACVC = [[AddCardViewController alloc] init];
            
            ACVC.transInfo = [requestInfo objectForKey:@"data"];
            [GFStaticData saveObject:[requestInfo objectForKey:@"data"] forKey:kTagBindBankCardDefaultInfo];
            if ([[requestInfo objectForKey:@"data"] objectForKey:@"idcard"])
            {
                ACVC.isFirst = NO;
            }
            else
            {
                ACVC.isFirst = YES;
            }
            ACVC.modelType = 1; //进行添加
            [GFStaticData saveObject:@"2" forKey:KTagCardBack];
            [self pushToViewController:ACVC];
        }
    }
    [cardTableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = KSelectNewColor;
    manageArr = [[NSMutableArray alloc] initWithCapacity:10];
    [headerView loadComponentsWithTitle:@"银行卡"];
    [headerView backButton];
    [headerView createLine];
    headerView.backgroundColor = kFontColorA;
    [headerView setStatusBarColor: kFontColorA];
    
    [self createUI];
}

// 初始化页面布局
- (void)createUI
{
    cardTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(headerView.frame), screenWidth, screenHeight-65) style:UITableViewStylePlain];
    cardTableView.backgroundColor = [UIColor clearColor];
    cardTableView.delegate = self;
    cardTableView.dataSource =self;
    cardTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:cardTableView];
    
    UIView * topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 60)];
    topView.backgroundColor = [UIColor clearColor];
    topView.userInteractionEnabled = YES;
    cardTableView.tableHeaderView = topView;
    
    
    UIButton * addBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 59)];
    [addBtn setBackgroundImage:[kFontColorA image] forState:UIControlStateNormal];
    [addBtn setBackgroundImage:[KFontNewColorB image] forState:UIControlStateHighlighted];
    [addBtn setBackgroundImage:[KFontNewColorB image] forState:UIControlStateSelected];
    [addBtn addTarget:self action:@selector(addBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:addBtn];
    
    UIImageView * iconView = [[UIImageView alloc]init];
    iconView.frame = CGRectMake(20, 18.5, 22.5, 22.5);
    iconView.image = [UIImage imageNamed:@"tianjia.png"];
    [addBtn addSubview:iconView];
    
    UILabel * tipLabel = [[UILabel alloc] init];
    tipLabel.textAlignment = NSTextAlignmentLeft;
    tipLabel.text = @"添加银行卡";
    tipLabel.font = NormalFontWithSize(15);
    tipLabel.textColor = KFontNewColorA;
    tipLabel.backgroundColor = [UIColor clearColor];
    tipLabel.frame = CGRectMake(CGRectGetMaxX(iconView.frame)+20, 0, 100, 59);
    [addBtn addSubview:tipLabel];
    
    
    UILabel * lineLb3 = [[UILabel alloc] initWithFrame:CGRectMake(0, 59, screenWidth, 0.5)];
    lineLb3.backgroundColor = KLineNewBGColor1;
    [topView addSubview:lineLb3];
    
    UILabel * lineLb4 = [[UILabel alloc] initWithFrame:CGRectMake(0, 59.5, screenWidth, 0.5)];
    lineLb4.backgroundColor = KLineNewBGColor2;
    [topView addSubview:lineLb4];
    
    UIView * footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 0.1)];
    cardTableView.tableFooterView = footView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return manageArr.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellIDT = @"CardListCell";
    CardListCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIDT];
    if (!cell)
    {
        cell = [[CardListCell alloc] init];
    }
    
    if (manageArr.count > indexPath.row)
    {
        NSDictionary * dic = [manageArr objectAtIndex:indexPath.row];
        
        cell.card_number.text = [Utility departString:[[dic objectForKey:@"bank_account"] description] withType:2];
        NSString * name = [[dic objectForKey:@"bank_name"] description];
        cell.bank_name.text = name;
        CGSize invalidX = [name sizeWithFont:NormalFontWithSize(15) constrainedToSize:CGSizeMake(130, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
        if ([[dic objectForKey:@"bank_card_check_status"] integerValue] == 0)
        {
            NSString * result = [[dic objectForKey:@"bank_card_check_result"]description];
            if (result)
            {
                cell.invalid.frame = CGRectMake(invalidX.width+20, 0, 150, 90);
                cell.invalid.text = [NSString stringWithFormat:@"%@",[[dic objectForKey:@"bank_card_check_result"]description]];
            }
        }
        
        cell.frame = CGRectMake(0, 0, screenWidth, 90);
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    if (self.deliverType == 1)
    {
        ManageCardViewController * MCVC = [[ManageCardViewController alloc] init];
        MCVC.deliverDic = [[manageArr objectAtIndex:indexPath.row] mutableCopy];
        [self pushToViewController:MCVC];
    }
    else if (self.deliverType == 2)
    {
        if ([self.delegate respondsToSelector:@selector(sendInfo:)])
        {
            [self.delegate sendInfo:[manageArr objectAtIndex:indexPath.row]];
        }
        
        for(BasicViewController * bvc in self.navigationController.viewControllers)
        {
            if ([bvc isKindOfClass:[WithDrawCashViewController class]])
            {
                [self.navigationController popToViewController:bvc animated:YES];
            }
            if ([bvc isKindOfClass:[EarnMoneyViewController class]])
            {
                [self.navigationController popToViewController:bvc animated:YES];
            }
        }
    }
}

#pragma mark 左划删除
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSString * card_id = [[manageArr objectAtIndex:indexPath.row] objectForKey:@"card_id"];
        [self requestDeleteCard:card_id];
        
        [manageArr removeObjectAtIndex:indexPath.row];
        [cardTableView reloadData];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [[CHNAlertView defaultAlertView] dismiss];
    [self requestCardList];
    if (cardTableView)
    {
        [cardTableView reloadData];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90.f;
}

// 请求银行卡信息
-(void)requestBankinfo
{
    NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
    [GFRequestManager connectWithDelegate:self action:Get_bank_bind_info param:paramDic];
}

// 去添加银行卡页面，根据请求返回值不同显示不同UI
-(void)addBtnOnClick:(UIButton*)sender
{
    [self requestBankinfo];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

