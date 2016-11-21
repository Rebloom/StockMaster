//
//  ReBirthViewController.m
//  StockMaster
//
//  Created by Rebloom on 14/11/25.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "ReBirthViewController.h"

@interface ReBirthViewController ()

@end

@implementation ReBirthViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(WXShareFinished:) name:kTagWXShareFinished object:nil];
    self.view.backgroundColor = KSelectNewColor;
    
    [headerView loadComponentsWithTitle:@"复活"];
    [headerView backButton];
    
    [headerView createLine];
    
    UIView * topView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(headerView.frame), screenWidth, 271)];
    topView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:topView];
    
    descLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, screenWidth, 16)];
    descLabel.textAlignment = NSTextAlignmentCenter;
    descLabel.backgroundColor = [UIColor clearColor];
    descLabel.textColor = KFontNewColorA;
    descLabel.font = NormalFontWithSize(16);
    [topView addSubview:descLabel];
    
    totalView = [[UIView alloc] initWithFrame:CGRectMake(screenWidth/2-50, CGRectGetMaxY(descLabel.frame)+25, 100, 150)];
    totalView.backgroundColor = @"#fceeee".color;
    totalView.layer.cornerRadius = 5;
    totalView.layer.masksToBounds = YES;
    [topView addSubview:totalView];
    
    presentView = [[UIView alloc] initWithFrame:CGRectMake(screenWidth/2-50, CGRectGetMaxY(totalView.frame), 100, 1)];
    presentView.backgroundColor = @"#eda5a2".color;
    presentView.layer.cornerRadius = 5;
    presentView.layer.masksToBounds = YES;
    [topView addSubview:presentView];
    
    presentMoney = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth/2-50, CGRectGetMinY(presentView.frame)+10, 100, 13)];
    presentMoney.textAlignment = NSTextAlignmentCenter;
    presentMoney.backgroundColor = [UIColor clearColor];
    presentMoney.textColor = kRedColor;
    presentMoney.font = NormalFontWithSize(13);
    [topView addSubview:presentMoney];
    
    UIView * line1 = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(topView.frame), screenWidth, .5)];
    line1.backgroundColor = @"#e3e3e3".color;
    [self.view addSubview:line1];
    
    UIView * line2 = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(line1.frame), screenWidth, .5)];
    line2.backgroundColor = @"#eeeeee".color;
    [self.view addSubview:line2];
    
    recoverBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(topView.frame)+21, screenWidth-40, 45)];
    recoverBtn.layer.cornerRadius = 5;
    recoverBtn.layer.masksToBounds = YES;
    recoverBtn.titleLabel.font = NormalFontWithSize(16);
    [recoverBtn addTarget:self action:@selector(recoverBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [recoverBtn setBackgroundImage:[KColorHeader image] forState:UIControlStateNormal];
    [recoverBtn setBackgroundImage:[@"#cccccc".color image] forState:UIControlStateHighlighted];
    recoverBtn.enabled = NO;
    [self.view addSubview:recoverBtn];
    
    getOutImage = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth/2-75, CGRectGetMaxY(descLabel.frame)+25, 150, 143)];
    getOutImage.image = [UIImage imageNamed:@"gun"];
    [topView addSubview:getOutImage];
    getOutImage.hidden = YES;
    
    UILabel * bottomDesc = [[UILabel alloc] initWithFrame:CGRectMake(0, screenHeight-66, screenWidth, 12)];
    bottomDesc.backgroundColor = [UIColor clearColor];
    bottomDesc.textColor = KFontNewColorC;
    bottomDesc.font = NormalFontWithSize(12);
    bottomDesc.text = @"免费炒股 大赚真钱";
    bottomDesc.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:bottomDesc];
    
    UIImageView * bottomImage = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth/2-15, CGRectGetMinY(bottomDesc.frame)-33, 30, 23)];
    bottomImage.image = [UIImage imageNamed:@"zhangzhang"];
    [self.view addSubview:bottomImage];
    
    [self requestRebirthStatus];
}

//弹窗点击事件
- (void)buttonClickedAtIndex:(NSInteger)index
{
    if (canRequest && index == 1)
    {
        WXMediaMessage *message = [WXMediaMessage message];
        message.title = @"涨涨-免费炒股，大赚真钱";
        message.description = @"下载地址：http://www.aizhangzhang.com/";
        [message setThumbImage:[UIImage imageNamed:@"icon"]];
        
        WXWebpageObject *ext = [WXWebpageObject object];
        ext.webpageUrl = [NSString stringWithFormat:@"%@",@"http://www.aizhangzhang.com/"];
        
        message.mediaObject = ext;
        
        SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
        req.bText = NO;
        req.message = message;
        req.scene = WXSceneTimeline;
        
        [WXApi sendReq:req];
    }
    return;
}

//复活按钮点击事件
- (void)recoverBtnClicked:(id)sender
{
    if ([WXApi isWXAppInstalled])
    {
        [[CHNAlertView defaultAlertView] showContent:@"使用复活功能，需要分享到朋友圈，成功后系统会将你的持仓清空。" cancelTitle:@"取消" sureTitle:@"确认" withDelegate:self withType:5];
    }
    else
    {
        [[CHNAlertView defaultAlertView] showContent:@"还没有安装微信哟~" cancelTitle:nil sureTitle:@"确定" withDelegate:self withType:6];
    }
}

//获取复活状态
- (void)requestRebirthStatus
{
    NSMutableDictionary * param = [NSMutableDictionary dictionary];
    [param setObject:@"2" forKey:@"refrence_position"];
    [GFRequestManager connectWithDelegate:self action:Get_resurrection_status param:param];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    [super requestFinished:request];
    
    ASIFormDataRequest * formdataRequest = (ASIFormDataRequest *)request;
    if ([formdataRequest.action isEqual:Get_resurrection_status])
    {
        [self reloadStatus:[requestInfo objectForKey:@"data"]];
    }
    else if ([formdataRequest.action isEqual:Submit_resurrection])
    {
        canRequest = NO;
        NSDictionary * dic = [requestInfo objectForKey:@"data"];
        
        [[TKAlertCenter defaultCenter] postAlertWithMessage:[[dic objectForKey:@"resurrection_prompt"] description] withType:ALERTTYPEERROR];
        presentView.frame = CGRectMake(screenWidth/2-50, totalView.frame.origin.y, 100, totalView.frame.size.height);
        [self performSelector:@selector(upTo90) withObject:nil afterDelay:1];
    }
}

//复活动画
- (void)upTo90
{
    [UIView beginAnimations:@"Animation" context:nil];
    [UIView setAnimationDuration:.5];
    presentView.frame = CGRectMake(screenWidth/2-50, totalView.frame.origin.y, 100, totalView.frame.size.height);
    presentMoney.frame = CGRectMake(screenWidth/2-50, CGRectGetMinY(presentView.frame)+10, 100, 13);
    [UIView commitAnimations];
    
    [self performSelector:@selector(back) withObject:nil afterDelay:1.5];
}

//微信分享成功
- (void)WXShareFinished:(NSNotification *)noti
{
    BaseResp * resp = (BaseResp *)[noti object];
    NSLog(@"resp.Code is %d",resp.errCode);
    if (resp.errCode == 0)
    {
        // 提交分享成功接口,同时改变界面
        NSMutableDictionary * param = [NSMutableDictionary dictionary];
        [GFRequestManager connectWithDelegate:self action:Submit_resurrection param:param];
        
        // 诸葛统计（用户复活）
        [[Zhuge sharedInstance] track:@"用户复活" properties:nil];
    }
    else
    {
        // 提示分享失败，不作其它处理
        [[CHNAlertView defaultAlertView] showContent:@"分享失败，重试一下?" cancelTitle:nil sureTitle:@"确定" withDelegate:self withType:6];
    }
}

//加载复活状态
- (void)reloadStatus:(NSDictionary *)dic
{
    descLabel.text = [[dic objectForKey:@"resurrection_text"] description];
    [getOutImage sd_setImageWithURL:[NSURL URLWithString:CHECKDATA(@"pic")] placeholderImage:[UIImage imageNamed:@"gun"] options:SDWebImageRefreshCached];
    if ([[dic objectForKey:@"is_useable"] integerValue] == 1)
    {
        canRequest = YES;
        float currentMoney = [[dic objectForKey:@"current_assets"] floatValue];
        float recoverMoney = [[dic objectForKey:@"resurrection_assets"] floatValue];
        
        presentMoney.text = [NSString stringWithFormat:@"本金%.2f",currentMoney];
        
        recoverBtn.enabled = YES;
        [recoverBtn setBackgroundImage:[kRedColor image] forState:UIControlStateNormal];
        [recoverBtn setBackgroundImage:[KBtnSelectNewColorA image] forState:UIControlStateHighlighted];
        [recoverBtn setTitle:CHECKDATA(@"tips_button") forState:UIControlStateNormal];
        [recoverBtn setTitleColor:kFontColorA forState:UIControlStateNormal];
        
        CGFloat presentHeight = currentMoney/(recoverMoney*.9)*140;
        
        [UIView beginAnimations:@"Animation" context:nil];
        [UIView setAnimationDuration:1.5];
        presentView.frame = CGRectMake(screenWidth/2-50, CGRectGetMaxY(totalView.frame)-presentHeight, 100, presentHeight);
        presentMoney.frame = CGRectMake(screenWidth/2-50, CGRectGetMinY(presentView.frame)+10, 100, 13);
        [UIView commitAnimations];
    }
    else  if([[dic objectForKey:@"is_useable"] integerValue] == 0)
    {
        [recoverBtn setTitle:@"赔钱超过10%，才能复活噢~！" forState:UIControlStateNormal];
        [recoverBtn setTitleColor:KFontNewColorB forState:UIControlStateNormal];
        recoverBtn.enabled = NO;
        canRequest = NO;
        [self showGetOut];
    }
}

//未达到复活标准  button样式
- (void)showGetOut
{
    presentMoney.hidden = YES;
    presentView.hidden = YES;
    totalView.hidden = YES;
    [recoverBtn setBackgroundImage:[KColorHeader image] forState:UIControlStateNormal];
    [recoverBtn setBackgroundImage:[@"#cccccc".color image] forState:UIControlStateHighlighted];
    
    getOutImage.hidden = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
