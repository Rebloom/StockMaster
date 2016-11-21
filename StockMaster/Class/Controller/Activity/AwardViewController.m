//
//  AwardViewController.m
//  StockMaster
//
//  Created by dalikeji on 15/1/28.
//  Copyright (c) 2015年 Rebloom. All rights reserved.
//

#import "AwardViewController.h"
#import "CameraViewController.h"

@interface AwardViewController ()

@end

@implementation AwardViewController
@synthesize AVSession;
@synthesize previewLayer;

- (void)dealloc
{
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    if ([GFStaticData getObjectForKey:KTagInvitationCode])
    {
        NSString * invitation_code = [[GFStaticData getObjectForKey:KTagInvitationCode] copy];
        
        if ([invitation_code isEqualToString:@"110"])
        {
            [[CHNAlertView defaultAlertView] showContent:@"不是涨涨的二维码" cancelTitle:nil sureTitle:nil withDelegate:self withType:6];
        }
        else
        {
            [[CHNAlertView defaultAlertView] showContent:@"矮油~可以领奖啦!快往下看" cancelTitle:nil sureTitle:nil withDelegate:self withType:6];
            awardTF.text = [[GFStaticData getObjectForKey:KTagInvitationCode] copy];
        }
    }
}

- (void)buttonClickedAtIndex:(NSInteger)index
{
    if ([GFStaticData getObjectForKey:KTagInvitationCode])
    {
        [GFStaticData saveObject:nil forKey:KTagInvitationCode];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    if ([GFStaticData getObjectForKey:KTagInvitationCode])
    {
        [GFStaticData saveObject:nil forKey:KTagInvitationCode];
    }
    [super viewWillDisappear:YES];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = KSelectNewColor;
    
    [headerView loadComponentsWithTitle:@"领奖中心"];
    [headerView backButton];
    [headerView createLine];
    headerView.backgroundColor = kFontColorA;
    [headerView setStatusBarColor:kFontColorA];
    [self.view bringSubviewToFront:headerView];
    
    if (!mainView)
    {
        mainView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(headerView.frame), screenWidth, screenHeight - 65)];
    }
    mainView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:mainView];
    
    UITapGestureRecognizer * viewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    viewTap.cancelsTouchesInView = NO;
    viewTap.delegate = self;
    [self.view addGestureRecognizer:viewTap];
    
    [self createUI];
}

- (void)createUI
{
    if (!captureLabel)
    {
        captureLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, screenWidth, 100)];
    }
    captureLabel.numberOfLines = 0;
    [mainView addSubview:captureLabel];
    
    UIImageView * awardImg = [[UIImageView alloc] init];
    awardImg.image = [UIImage imageNamed:@"bj_shuangfei"];
    awardImg.frame = CGRectMake((screenWidth - 217)/2, 105, 217, 217);
    [mainView addSubview:awardImg];
    
    UIButton * cameraBtn = [[UIButton alloc] init];
    cameraBtn.backgroundColor = KSelectNewColor;
    cameraBtn.frame = CGRectMake(0, CGRectGetHeight(mainView.frame) - 48, 70, 48);
    [cameraBtn addTarget:self action:@selector(cameraBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
    [mainView addSubview:cameraBtn];
    
    UIImageView * cameraImage = [[UIImageView alloc] init];
    cameraImage.image = [UIImage imageNamed:@"icon_erweima"];
    cameraImage.frame = CGRectMake(20.5,12, 29, 24);
    [cameraBtn addSubview:cameraImage];
    
    
    
    for (int i = 0; i<2; i++)
    {
        UILabel * lineLabel = [[UILabel alloc] init];
        lineLabel.backgroundColor = KFontNewColorJ;
        if(i == 0 )
        {
            lineLabel.frame = CGRectMake(0, CGRectGetMinY(cameraBtn.frame)-0.5, screenWidth, 0.5);
        }
        else if (i == 1)
        {
            lineLabel.frame = CGRectMake(0, CGRectGetMaxY(cameraBtn.frame)-0.5, screenWidth, 0.5);
        }
        [mainView addSubview:lineLabel];
    }
    
    UILabel * lineLabel = [[UILabel alloc] init];
    lineLabel.backgroundColor = KFontNewColorJ;
    lineLabel.frame = CGRectMake(0, CGRectGetMinY(cameraBtn.frame)-0.5, screenWidth, 0.5);
    [mainView addSubview:lineLabel];
    
    UILabel * shuLabel = [[UILabel alloc] init];
    shuLabel.backgroundColor = KFontNewColorJ;
    shuLabel.frame = CGRectMake(70, CGRectGetMinY(cameraBtn.frame)-0.5, 0.5, 48);
    [mainView addSubview:shuLabel];
    
    awardBtn = [[UIButton alloc] init];
    awardBtn.tag = 100;
    awardBtn.enabled = YES;
    awardBtn.frame = CGRectMake(screenWidth - 70, CGRectGetMinY(cameraBtn.frame), 70, 48);
    awardBtn.titleLabel.font = NormalFontWithSize(18);
    [awardBtn setTitle:@"领奖" forState:UIControlStateNormal];
    [awardBtn setBackgroundColor:kRedColor];
    [awardBtn setTitleColor:kFontColorA forState:UIControlStateNormal];
    [awardBtn setBackgroundImage:KBtnSelectNewColorA.image forState:UIControlStateHighlighted];
    [awardBtn setBackgroundImage:KBtnSelectNewColorA.image forState:UIControlStateSelected];
    [awardBtn addTarget:self action:@selector(awardBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
    [mainView addSubview:awardBtn];
    [mainView bringSubviewToFront:awardBtn];
    
    if (!awardTF)
    {
        awardTF = [[GFTextField alloc] init];
    }
    awardTF.frame = CGRectMake(CGRectGetMaxX(cameraBtn.frame) , CGRectGetMinY(cameraBtn.frame), CGRectGetMinX(awardBtn.frame) - CGRectGetMaxX(cameraBtn.frame), 48);
    awardTF.delegate = self;
    awardTF.placeholder = @"请输入邀请码或兑换码";
    awardTF.placeHolderColor = 1;
    awardTF.borderStyle = UITextBorderStyleNone;
    awardTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    awardTF.textColor = KFontNewColorA;
    awardTF.font = NormalFontWithSize(15);
    [mainView addSubview:awardTF];
}

- (void)cameraBtnOnClick:(UIButton *)sender
{
    CameraViewController * CVC = [[CameraViewController alloc] init];
    [self pushToViewController:CVC];
}

- (void)awardBtnOnClick:(UIButton *)sender
{
    [self requestAward];
}

- (void)requestAward
{
    NSMutableDictionary * parDic = [NSMutableDictionary dictionary];
    [parDic setObject:awardTF.text forKey:@"code"];
    [GFRequestManager connectWithDelegate:self action:Get_reward_by_code param:parDic];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    [super requestFinished:request];
    
    ASIFormDataRequest * formDataRequest = (ASIFormDataRequest *)request;
    
    if ([formDataRequest.action isEqualToString:Get_reward_by_code])
    {
        NSDictionary * dic = [requestInfo objectForKey:@"data"];
        NSInteger status = [[dic objectForKey:@"status"] integerValue];
        if (status == 1)
        {
            [[CHNAlertView defaultAlertView] initWithAwardText:CHECKDATA(@"money") desc1:CHECKDATA(@"prompt1") desc2:CHECKDATA(@"prompt2") buttonDesc:@"知道了，退下~" delegate:self];
            awardTF.text = @"";
        }
    }
}

-(void)requestFailed:(ASIHTTPRequest *)request
{
    [super requestFailed:request];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    NSString * touchObject = NSStringFromClass([touch.view class]);
    
    if ([touchObject isEqualToString:@"UIView"])
    {
        if (touch.view.tag == 111)
        {
            //点击领取 直接领取
            [self requestAward];
            return NO;
        }
    }
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self.view bringSubviewToFront:headerView];
    mainView.frame = CGRectMake(0, -200, screenWidth, screenHeight - 65 -200);
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [self.view bringSubviewToFront:headerView];
    mainView.frame = CGRectMake(0, 65, screenWidth, screenHeight - 65);
    
    return YES;
}

// 点击页面，输入框失去焦点
- (void)viewTapped:(UITapGestureRecognizer*)ges
{
    if([awardTF isFirstResponder])
    {
        [awardTF resignFirstResponder];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
