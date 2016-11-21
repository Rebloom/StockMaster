//
//  InvitationCodeViewController.m
//  StockMaster
//
//  Created by dalikeji on 15/1/28.
//  Copyright (c) 2015年 Rebloom. All rights reserved.
//

#import "InvitationCodeViewController.h"
#import "UIImage+QRCodeGenerator.h"
#import "ShareView.h"
#import "ShareManager.h"

@interface InvitationCodeViewController ()

@end

@implementation InvitationCodeViewController

- (void)dealloc
{
}

- (void)viewWillAppear:(BOOL)animated
{
    if (mainView)
    {
        mainView.hidden =YES;
    }
    
    [super viewWillAppear:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = KSelectNewColor;
    
    [headerView loadComponentsWithTitle:@"我的邀请码"];
    [headerView backButton];
    [headerView createLine];
    headerView.backgroundColor = kFontColorA;
    [headerView setStatusBarColor:kFontColorA];
    
    UIButton * inviteBtn = [[UIButton alloc] init];
    inviteBtn.frame = CGRectMake(screenWidth-80, 20, 70, 44);
    inviteBtn.titleLabel.font = NormalFontWithSize(14);
    inviteBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 30, 0, 0);
    [inviteBtn setTitle:@"分享" forState:UIControlStateNormal];
    [inviteBtn setTitleColor:KFontNewColorA forState:UIControlStateNormal];
    [inviteBtn addTarget:self action:@selector(inviteBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:inviteBtn];
    
    [self requestInvitationCode];
}

- (void)requestInvitationCode
{
    NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
    [GFRequestManager connectWithDelegate:self action:Get_invitation_code param:paramDic];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    [super requestFinished:request];
    
    ASIFormDataRequest * formDataRequest = (ASIFormDataRequest *)request;
    if ([formDataRequest.action isEqualToString:Get_invitation_code])
    {
        NSString * invitation_code = [[requestInfo objectForKey:@"data"] objectForKey:@"invitation_code"];
        NSString * url = [[[requestInfo objectForKey:@"data"] objectForKey:@"url"] description];
        [self createQRcode:invitation_code WithURL:url];
    }
}

-(void)requestFailed:(ASIHTTPRequest *)request
{
    [super requestFailed:request];
}

//生成二维码
- (void)createQRcode:(NSString *)invitation_code WithURL:(NSString*)url
{
    UIImageView * QRcodeImg = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth/4,CGRectGetMaxY(headerView.frame)+40, screenWidth/2, screenWidth/2)];
    QRcodeImg.image = [UIImage mdQRCodeGenerator:url size:QRcodeImg.bounds.size.width];
    QRcodeImg.backgroundColor = kFontColorA;
    [self.view addSubview: QRcodeImg];
    
    UILabel * inviteCodeLabel =  [[UILabel alloc] init];
    inviteCodeLabel.text = invitation_code;
    inviteCodeLabel.textColor = KFontNewColorA;
    inviteCodeLabel.textAlignment = NSTextAlignmentCenter;
    inviteCodeLabel.backgroundColor = kFontColorA;
    inviteCodeLabel.font = BoldFontWithSize(15);
    inviteCodeLabel.frame = CGRectMake(CGRectGetMinX(QRcodeImg.frame), CGRectGetMaxY(QRcodeImg.frame) +5, screenWidth/2, 40);
    [self.view addSubview:inviteCodeLabel];
    
    UILabel * tipLabel = [[UILabel alloc] init];
    tipLabel.text = @"邀请二维码和邀请码已生成";
    tipLabel.numberOfLines = 0;
    tipLabel.textColor = KFontNewColorA;
    tipLabel.backgroundColor = [UIColor clearColor];
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.font = NormalFontWithSize(15);
    tipLabel.frame = CGRectMake(0, CGRectGetMaxY(inviteCodeLabel.frame)+30, screenWidth, 20);
    [self.view addSubview:tipLabel];
    
    UILabel * lightTipLabel = [[UILabel alloc] init];
    lightTipLabel.text = @"可以扫描二维码或者分享给好友！";
    lightTipLabel.numberOfLines = 0;
    lightTipLabel.textColor = KFontNewColorB;
    lightTipLabel.backgroundColor = [UIColor clearColor];
    lightTipLabel.textAlignment = NSTextAlignmentCenter;
    lightTipLabel.font = NormalFontWithSize(12);
    lightTipLabel.frame = CGRectMake(0, CGRectGetMaxY(tipLabel.frame), screenWidth, 20);
    [self.view addSubview:lightTipLabel];
}

//点击邀请
- (void)inviteBtnOnClick:(UIButton *)sender
{
    [self createActionSheet];
}

// 初始化自定义actionSheet
- (void)createActionSheet
{
    ShareView *shareView = [[ShareView defaultShareView] initViewWtihNumber:4 Delegate:self WithViewController:self];
    [shareView showView];
}

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
