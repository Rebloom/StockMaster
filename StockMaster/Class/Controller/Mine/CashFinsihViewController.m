//
//  CashFinsihViewController.m
//  StockMaster
//
//  Created by dalikeji on 14-10-9.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "CashFinsihViewController.h"
#import "NSString+UIColor.h"
#import "UIImage+UIColor.h"
#import "Utility.h"
@interface CashFinsihViewController ()

@end

@implementation CashFinsihViewController
@synthesize card_no;
@synthesize withdraw_money;
@synthesize account_date;
@synthesize dict;

- (void)dealloc
{
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.view.backgroundColor = kBackgroundColor;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [headerView loadComponentsWithTitle:@"提现"];
    [self createUI];
}

// 设置即更新
- (void)setDict:(NSDictionary *)_dict
{
    dict = _dict;
    [self updateDic];
}

// 更新
-(void)updateDic
{
    NSArray * arr = [[dict objectForKey:@"account_date"] componentsSeparatedByString:@","];
    aboutLb.text = [NSString stringWithFormat:@"%@\n%@",[arr objectAtIndex:0],[arr objectAtIndex:1]];
    if (arr.count > 1)
    {
        aboutLb.text = [NSString stringWithFormat:@"%@\n%@",[arr objectAtIndex:0],[arr objectAtIndex:1]];
    }
    contentLb.text = [NSString stringWithFormat:@"提现申请成功\n提现 %.2f元到\n %@",[[dict objectForKey:@"withdraw_money"] floatValue],[Utility departString:[dict objectForKey:@"bank_account"] withType:3]];
}

// 初始化布局
- (void)createUI
{
    UIView * bgView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(headerView.frame), screenWidth, 195)];
    bgView.userInteractionEnabled = YES;
    bgView.backgroundColor = kFontColorA;
    [self.view addSubview:bgView];
    
    UIImageView * firstView = [[UIImageView alloc] initWithFrame:CGRectMake(60, 39, 23, 100)];
    firstView.image = [UIImage imageNamed:@"icon_txcg.png"];
    [bgView addSubview:firstView];
    
    contentLb = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(firstView.frame)+16, 20, 250, 90)];
    contentLb.numberOfLines = 0;
    contentLb.textAlignment = NSTextAlignmentLeft;
    contentLb.textColor = KFontColorE;
    contentLb.font = NormalFontWithSize(14);
    [bgView addSubview:contentLb];
    
    secondView = [[UIImageView alloc] initWithFrame:CGRectMake(60, 139, 23, 25)];
    secondView.image = [UIImage imageNamed:@"icon_txcg2.png"];
    [bgView addSubview:secondView];
    
    aboutLb = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(firstView.frame)+16,CGRectGetMinY(secondView.frame)-5, 250, 45)];
    aboutLb.numberOfLines = 0;
    aboutLb.textAlignment = NSTextAlignmentLeft;
    aboutLb.textColor = kFontColorD;
    aboutLb.font = NormalFontWithSize(14);
    [bgView addSubview:aboutLb];
    
    UIButton * finishBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(bgView.frame)+20, screenWidth-40, 44)];
    finishBtn.backgroundColor = kBtnBgColor;
    finishBtn.layer.cornerRadius = 5;
    finishBtn.layer.masksToBounds = YES;
    [finishBtn setTitle:@"完 成" forState:UIControlStateNormal];
    [finishBtn addTarget:self action:@selector(finishBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [finishBtn setBackgroundImage:[@"#b6494b".color  image]  forState:UIControlStateHighlighted];
    finishBtn.titleLabel.font = NormalFontWithSize(17);
    [self.view addSubview:finishBtn];
}

// 点击体现结束按钮
- (void)finishBtnClicked:(UIButton*)sender
{
    if (self.navigationController && self.navigationController.viewControllers.count>1) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
