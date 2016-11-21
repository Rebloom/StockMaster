
//
//  FeedbackViewController.m
//  StockMaster
//
//  Created by Rebloom on 14-7-31.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "FeedbackViewController.h"
#import "NSString+UIColor.h"
#import "UIImage+UIColor.h"
@interface FeedbackViewController ()

@end

@implementation FeedbackViewController

- (void)dealloc
{
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor =KSelectNewColor;
    
    [headerView loadComponentsWithTitle:@"意见反馈"];
    [headerView backButton];
    [headerView createLine];
    headerView.backgroundColor = kFontColorA;
    [headerView setStatusBarColor: kFontColorA];
    
    type = 0;
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    [self.view addGestureRecognizer:tap];
    [self createUI];
}

-(void)createUI
{
    NSArray * leftArr = @[@"客服热线",@"客服QQ",@"客服微信"];
    NSArray * rightArr = @[@"4006665666",@"4006665666",@"涨涨免费炒股"];
    
    if (!scrollView)
    {
        scrollView = [[UIScrollView alloc] init];
    }
    scrollView.frame = CGRectMake(0, CGRectGetMaxY(headerView.frame), screenWidth, screenHeight);
    scrollView.delegate = self;
    scrollView.contentSize = CGSizeMake(screenWidth, 630);
    scrollView. backgroundColor = KSelectNewColor;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:scrollView];
    
    
    UIImageView * firstView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0 , screenWidth, 180+168)];
    firstView.backgroundColor = kFontColorA;
    firstView.userInteractionEnabled = YES;
    [scrollView addSubview:firstView];
    
    for (int i = 0; i < leftArr.count; i++)
    {
        UILabel *leftLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, i*60, 100, 59.5)];
        leftLabel.text = [leftArr objectAtIndex:i];
        leftLabel.textAlignment = NSTextAlignmentLeft;
        leftLabel.font = NormalFontWithSize(15);
        leftLabel.textColor = KFontNewColorA;
        [firstView  addSubview:leftLabel];
        
        UILabel * rightLabel = [[UILabel alloc] init ];
        if (i == 0)
        {
            rightLabel.frame = CGRectMake(screenWidth -220, i*60, 150, 59.5);
        }
        else
        {
            rightLabel.frame = CGRectMake(screenWidth - 170, i*60, 150, 59.5);
        }
        rightLabel.text= [rightArr objectAtIndex:i];
        rightLabel.textAlignment = NSTextAlignmentRight;
        rightLabel.font = NormalFontWithSize(13);
        rightLabel.textColor = KFontNewColorB;
        [firstView  addSubview:rightLabel];
        
        UILabel * lineLb1 = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(leftLabel.frame), screenWidth, 0.5)];
        lineLb1.backgroundColor = KLineNewBGColor1;
        [firstView addSubview:lineLb1];
    }
    
    
    UIButton * callBtn = [[UIButton alloc] init];
    callBtn.frame =CGRectMake(screenWidth - 60,0, 60, 60);
    [callBtn setBackgroundImage:[KSelectNewColor image] forState:UIControlStateNormal];
    [callBtn setBackgroundImage:[KColorHeader image] forState:UIControlStateHighlighted];
    [callBtn setBackgroundImage:[KColorHeader image] forState:UIControlStateSelected];
    [callBtn addTarget:self action:@selector(callOnClick:) forControlEvents:UIControlEventTouchUpInside] ;
    [firstView addSubview:callBtn];
    [firstView bringSubviewToFront:callBtn];
    
    UIImageView * iconView = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth - 43, 16.5, 26, 27)];
    iconView.image = [UIImage imageNamed:@"dianhua"];
    [scrollView addSubview:iconView];
    
    inputView = [[UITextView alloc] initWithFrame:CGRectMake(10, 200, screenWidth - 20, 147)];
    inputView.delegate = self;
    inputView.backgroundColor = [UIColor clearColor];
    inputView.keyboardType = UIKeyboardTypeDefault;
    inputView.font = NormalFontWithSize(15);
    inputView.textColor = kTitleColorA;
    [scrollView addSubview:inputView];
    
    UILabel * lineLb3 = [[UILabel alloc] initWithFrame:CGRectMake(0, 347, screenWidth, 0.5)];
    lineLb3.backgroundColor = KLineNewBGColor1;
    [scrollView addSubview:lineLb3];
    
    UILabel * lineLb4 = [[UILabel alloc] initWithFrame:CGRectMake(0, 347.5, screenWidth, 0.5)];
    lineLb4.backgroundColor = KLineNewBGColor2;
    [scrollView addSubview:lineLb4];
    
    if (!placeholderLb)
    {
        placeholderLb = [[UILabel alloc]init];
    }
    placeholderLb.text = @"输入您的反馈和建议,我们会努力改进";
    placeholderLb.numberOfLines=0;
    placeholderLb.font = NormalFontWithSize(15);
    placeholderLb.textColor = [UIColor lightGrayColor];
    placeholderLb.textAlignment=NSTextAlignmentLeft;
    placeholderLb.frame = CGRectMake(20, 200, screenWidth - 32, 30);
    placeholderLb.backgroundColor = [UIColor clearColor];
    [scrollView addSubview:placeholderLb];
    
    UIButton * senderBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(inputView.frame)+20, screenWidth - 40, 44)];
    senderBtn.tintColor = kFontColorA;
    senderBtn.layer.cornerRadius = 5;
    senderBtn.layer.masksToBounds = YES;
    senderBtn.tag = 100;
    senderBtn.titleLabel.font = NormalFontWithSize(16);
    [senderBtn setTitle:@"发 送" forState:UIControlStateNormal];
    senderBtn.enabled = NO;
    [senderBtn setBackgroundColor:KColorHeader];
    [senderBtn setTintColor:KFontNewColorB];
    [senderBtn addTarget:self action:@selector(submitBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:senderBtn];
    
    UIImageView * iconImgView = [[UIImageView alloc] init];
    iconImgView.frame = CGRectMake(screenWidth/2-15, CGRectGetMaxY(senderBtn.frame) +52, 30, 23);
    iconImgView.image = [UIImage imageNamed:@"zhangzhang"];
    [scrollView addSubview:iconImgView];
    
    UILabel * ideaLabel = [[UILabel alloc] init];
    ideaLabel.frame = CGRectMake(0,CGRectGetMaxY(iconImgView.frame)+10, screenWidth, 12);
    ideaLabel.text = @"免费炒股，大赚真钱";
    ideaLabel.textAlignment = NSTextAlignmentCenter;
    ideaLabel.textColor = KFontNewColorC;
    ideaLabel.font = NormalFontWithSize(12);
    [scrollView addSubview:ideaLabel];
}

-(void)callOnClick:(UIButton*)sender
{
    [[CHNAlertView defaultAlertView] showContent:@"400-666-5666" cancelTitle:@"取消" sureTitle:@"呼叫" withDelegate:self withType:1];
    type = 1;
}

- (void)buttonClickedAtIndex:(NSInteger)index
{
    if (type == 1)
    {
        if (index == 1)
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel://4006665666"]];
        }
    }
    else if (type ==2)
    {
        [self performSelector:@selector(afterDelayMethod) withObject:nil afterDelay:0.2];
    }
    
    return;
}

- (void)viewTapped:(id)sender
{
    if ([inputView isFirstResponder])
    {
        [inputView resignFirstResponder];
    }
}

- (void)submitBtnClicked:(id)sender
{
    if ([inputView isFirstResponder])
    {
        [inputView resignFirstResponder];
    }
    if (inputView.text.length)
    {
        NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
        [paramDic setObject:inputView.text forKey:@"content"];
        [GFRequestManager connectWithDelegate:self action:Submit_feedback param:paramDic];
    }
    else
    {
        [[CHNAlertView defaultAlertView] showContent:@"请填写评论内容" cancelTitle:nil sureTitle:@"确定" withDelegate:self withType:6];
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    [super requestFinished:request];
    
    ASIFormDataRequest * formDataRequest = (ASIFormDataRequest *)request;
    if([formDataRequest.action isEqualToString:Submit_feedback])
    {
        [[CHNAlertView defaultAlertView] showContent:@"意见反馈成功,感谢您宝贵的意见" cancelTitle:nil sureTitle:@"确定" withDelegate:self withType:6];
        type = 2;
    }
}

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [self.view bringSubviewToFront:headerView];
    scrollView.frame = CGRectMake(0, -120, screenWidth, [UIScreen mainScreen].bounds.size.height-120);
    return YES;
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    [self.view bringSubviewToFront:headerView];
    scrollView.frame = CGRectMake(0, 64, screenWidth, [UIScreen mainScreen].bounds.size.height);
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (inputView.text.length==0)
    {
        placeholderLb.frame=CGRectMake(20, 200, 288, 30);
        [scrollView addSubview:placeholderLb];
    }
    else
    {
        if (inputView.text.length<1)
        {
            placeholderLb.frame = CGRectMake(20, 200, 288, 30);
            [scrollView addSubview:placeholderLb];
        }
        else
        {
            placeholderLb.frame = CGRectMake(0, 0, 0, 0);
            [scrollView addSubview:placeholderLb];
        }
    }
    
    UIButton * btn = (UIButton*)[self.view viewWithTag:100];
    
    if (textView == inputView)
    {
        NSInteger i = inputView.text.length;
        if ([inputView.text  isEqualToString:@""] && i>0)
        {
            i = i -1;
        }
        if (i >0)
        {
            btn.enabled = YES;
            [btn setBackgroundColor:kRedColor];
            [btn setTitleColor:kFontColorA forState:UIControlStateNormal];
            [btn setBackgroundImage:KBtnSelectNewColorA.image forState:UIControlStateHighlighted];
            [btn setBackgroundImage:KBtnSelectNewColorA.image forState:UIControlStateSelected];
            [btn addTarget:self action:@selector(submitBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
        else
        {
            btn.enabled = NO;
            [btn setBackgroundColor:KColorHeader];
            [btn setTintColor:KFontNewColorB];
        }
    }
}

#pragma mark ---TextView 收键盘
//判断UITextView 的placeholder
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    if (inputView.text.length==0){//textview长度为0
        if ([text isEqualToString:@""]) {//判断是否为删除键
            
            placeholderLb.frame=CGRectMake(20, 200, 288, 30);
            [scrollView addSubview:placeholderLb];
        }else{
            placeholderLb.frame=CGRectMake(0, 0, 0, 0);
            [scrollView addSubview:placeholderLb];
        }
    }else{//textview长度不为0
        if (inputView.text.length==1){//textview长度为1时候
            if ([text isEqualToString:@""]) {//判断是否为删除键
                placeholderLb.frame=CGRectMake(20, 200, 288, 30);
                [scrollView addSubview:placeholderLb];
            }else{//不是删除
                placeholderLb.frame=CGRectMake(0, 0, 0, 0);
                [scrollView addSubview:placeholderLb];
            }
        }else{//长度不为1时候
            placeholderLb.frame=CGRectMake(0, 0, 0, 0);
            [scrollView addSubview:placeholderLb];
        }
    }
    
    
    UIButton * btn = (UIButton*)[self.view viewWithTag:100];
    
    if (textView == inputView)
    {
        NSInteger i = inputView.text.length;
        if ([text isEqualToString:@""] && i>0)
        {
            i = i -1;
        }
        if (i >0)
        {
            btn.enabled = YES;
            [btn setBackgroundColor:kRedColor];
            [btn setTitleColor:kFontColorA forState:UIControlStateNormal];
            [btn setBackgroundImage:KBtnSelectNewColorA.image forState:UIControlStateHighlighted];
            [btn setBackgroundImage:KBtnSelectNewColorA.image forState:UIControlStateSelected];
            [btn addTarget:self action:@selector(submitBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
        else
        {
            btn.enabled = NO;
            [btn setBackgroundColor:KColorHeader];
            [btn setTintColor:KFontNewColorB];
        }
    }
    
    
    
    return YES;
    
}


- (void)afterDelayMethod
{
    [self back];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

