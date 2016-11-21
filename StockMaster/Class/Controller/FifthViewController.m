//
//  FifthViewController.m
//  StockMaster
//
//  Created by Rebloom on 14/11/4.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "FifthViewController.h"
#import "BuyHistoryViewController.h"
#import "DrawCashHistoryViewController.h"
#import "CardViewController.h"
#import "MineCenterViewController.h"
#import "MoreViewController.h"
#import "MineDetailViewController.h"
#import "EarnHistoryViewController.h"
#import "ReBirthViewController.h"
#import "MessageBoxViewController.h"
#import "UIImage+UIColor.h"
#import <Accelerate/Accelerate.h>
#import "PropBagViewController.h"
#import "ChatViewController.h"
#import "EMIMHelper.h"

@interface FifthViewController ()
{
    UserInfoEntity *userInfo;
}

@end


@implementation FifthViewController

-(void)dealloc
{
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    if (![[UserInfoCoreDataStorage sharedInstance] isCurrentUserLogin])
    {
        LoginViewController * SLVC = [[LoginViewController alloc] init];
        SLVC.flag = 1;
        SLVC.selectType = 5;
        [self pushToViewController:SLVC];
    }
    else
    {
        [self reloadTopView];
        [self requestUserHistory];
        [self requestFeqQuestionData];

        
        // 诸葛统计（查看我的页）
        [[Zhuge sharedInstance] track:@"查看我的页" properties:nil];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (![[UserInfoCoreDataStorage sharedInstance] isCurrentUserLogin])
    {
        LoginViewController * SLVC = [[LoginViewController alloc] init];
        SLVC.flag = 1;
        SLVC.selectType = 5;
        [self pushToViewController:SLVC];
    }
    else
    {
        userInfo = [[UserInfoCoreDataStorage sharedInstance] getCurrentUserInfo];
        
        [headerView loadComponentsWithTitle:@"我的"];
        [headerView createLine];
        headerView.backgroundColor = kFontColorA;
        headerView.alpha = 0;
        
        statusBarView.backgroundColor = [UIColor clearColor];
        
        [self.view bringSubviewToFront:headView];
        self.view.backgroundColor = KSelectNewColor;
        self.edgesForExtendedLayout = UIRectEdgeNone;
        
        faqQuestionArr = [[NSArray alloc] init];
        
        [self createTableView];
        [self createTopView];
        [self createFootView];
    }
}

-(void)requestUserHistory
{
    NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
    [GFRequestManager connectWithDelegate:self action:Get_user_performance param:paramDic];
}

-(void)requestFailed:(ASIHTTPRequest *)request
{
    [super requestFailed:request];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (void)requestFeqQuestionData
{
    NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
    [GFRequestManager connectWithDelegate:self action:Get_faq_list param:paramDic];
}

-(void)requestFinished:(ASIHTTPRequest *)request
{
    [super requestFinished:request];
    
    ASIFormDataRequest * formDataRequest = (ASIFormDataRequest *)request;
    if ([formDataRequest.action isEqualToString:Get_user_performance])
    {
        if (pushDic.allKeys.count>0)
        {
            [pushDic removeAllObjects];
        }
        
        pushDic = [[requestInfo objectForKey:@"data"] mutableCopy];
        
        titleArr = [[NSMutableArray alloc] initWithCapacity:5];
        [titleArr addObject:@"消息盒子"];
        [titleArr addObject:@"交割单"];
        [titleArr addObject:@"赚钱记录"];
        
        if ([GFStaticData getObjectForKey:kTagAppStoreClose])
        {
            [titleArr addObject:@"提现记录"];
            [titleArr addObject:@"银行卡管理"];
            
        }
        [titleArr addObject:@"道具卡包"];
        [titleArr addObject:@"帮助中心"];
        [titleArr addObject:@"联系客服"];
        [titleArr addObject:@"设置"];
        
        imageArr = [[NSMutableArray alloc] initWithCapacity:5];
        [imageArr addObject:[UIImage imageNamed:@"icon_xiaoxi"]];
        [imageArr addObject:[UIImage imageNamed:@"icon_jiaogedan"]];
        [imageArr addObject:[UIImage imageNamed:@"icon_zhuanqian"]];
        if ([GFStaticData getObjectForKey:kTagAppStoreClose])
        {
            [imageArr addObject:[UIImage imageNamed:@"icon_withdraw_history"]];
            [imageArr addObject:[UIImage imageNamed:@"icon_manage_card"]];
        }
        //卡包道具的图片
        [imageArr addObject:[UIImage imageNamed:@"icon_prop_card"]];
        //帮助中心图片
        [imageArr addObject:[UIImage imageNamed:@"icon_help"]];
        [imageArr addObject:[UIImage imageNamed:@"icon_kefu"]];
        [imageArr addObject:[UIImage imageNamed:@"icon_settings"]];
        
        [[UserInfoCoreDataStorage sharedInstance] saveLoginUserInfo:pushDic];
        userInfo = [[UserInfoCoreDataStorage sharedInstance] getCurrentUserInfo];
        
        [self reloadTopView];
    }
    else if ([formDataRequest.action isEqualToString:Get_faq_list])
    {
        NSArray * tempArr = [[[requestInfo objectForKey:@"data"] objectForKey:@"list"] copy];
        NSMutableArray * infoArr = [[NSMutableArray alloc] initWithCapacity:10];
        for (int i =0 ; i<tempArr.count; i++)
        {
            NSDictionary * dict = [tempArr objectAtIndex:i];
            NSString * question_text = [dict objectForKey:@"question_text"];
            [infoArr addObject:question_text];
        }
        faqQuestionArr = [infoArr copy];
        [GFStaticData saveObject:faqQuestionArr forKey:KTagQuestion];
    }
    [infoTableView reloadData];
}

-(void)reloadTopView
{
    if (nil == userInfo) {
        return;
    }
    
    // 头像背景
    __block UIImageView *tempTop = topView;
    __block FifthViewController *blockSelf = self;
    // 去掉头像url后面的参数，因为参数为随机变动时间
    NSArray *urlArray = [userInfo.head componentsSeparatedByString:@"?"];
    NSString *headUrl = urlArray.firstObject;
    [topView sd_setImageWithURL:[NSURL URLWithString:headUrl]
               placeholderImage:nil
                        options:SDWebImageRefreshCached
                      completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                          UIImage *headImage = nil;
                          if (nil == error) {
                              headImage = image;
                          }
                          else {
                              headImage = [UIImage imageNamed:@"icon_user_default"];
                          }
                          
                          CGRect rect = CGRectMake(0, 50, screenWidth, 150);
                          CGImageRef imageRef = CGImageCreateWithImageInRect([headImage CGImage], rect);
                          UIImage * imageBg = [UIImage imageWithCGImage:imageRef];
                          CGImageRelease(imageRef);
                          tempTop.image = [blockSelf blurryImage:imageBg withBlurLevel:0.2];
                      }];

    // 头像
    [imgView sd_setImageWithURL:[NSURL URLWithString:headUrl]
            placeholderImage:[UIImage imageNamed:@"icon_user_default"]
                     options:SDWebImageRefreshCached];
    nameLabel.text = userInfo.nickname;
    phoneLabel.text = [Utility departString:userInfo.mobile withType:4];
}

//头部（含毛玻璃效果）
- (void)createTopView
{
    if (!topView)
    {
        topView = [[UIImageView alloc] init];
    }
    topView.userInteractionEnabled = YES;
    CGRect rect1 = CGRectMake(0, 50, screenWidth, 150);
    CGImageRef tempImage = CGImageCreateWithImageInRect([[UIImage imageNamed:@"icon_user_default"] CGImage], rect1);
    UIImage * image2 = [UIImage imageWithCGImage:tempImage];
    topView.image = [self blurryImage:image2 withBlurLevel:0.2];
    CGImageRelease(tempImage);
    
    topView.frame = CGRectMake(0, 0, screenWidth, HeaderViewHeight);
    
    UIView * view  = [[UIView alloc] init];
    view.backgroundColor = [UIColor blackColor];
    view.frame = CGRectMake(0, 0, screenWidth, HeaderViewHeight);
    view.alpha = 0.5;
    [topView addSubview:view];
    
    UIButton * mineBtn = [[UIButton alloc] initWithFrame:CGRectMake((screenWidth - 80)/2,35 , 80, 80)];
    [mineBtn addTarget:self action:@selector(mineBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    imgView = [[UIImageView alloc] init];
    imgView.image =[UIImage imageNamed:@"icon_user_default"];
    imgView.frame = CGRectMake(0, 0, 80, 80);
    imgView.layer.cornerRadius = 40;
    imgView.tag = 1002;
    imgView.layer.masksToBounds = YES;
    [mineBtn addSubview:imgView];
    
    [topView addSubview:mineBtn];
    [topView bringSubviewToFront:imgView];
    
    UIButton * myBtn = [[UIButton alloc] initWithFrame:CGRectMake(50,CGRectGetMaxY(mineBtn.frame) , 220, 60)];
    myBtn.backgroundColor = [UIColor clearColor];
    [myBtn addTarget:self action:@selector(mineBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:myBtn];
    
    if (!nameLabel)
    {
        nameLabel = [[UILabel alloc] init];
    }
    nameLabel.frame = CGRectMake(0, 130, screenWidth, 17);
    nameLabel.text = @"";
    nameLabel.textColor = kFontColorA;
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.font = NormalFontWithSize(15);
    [topView addSubview:nameLabel];
    
    if (!phoneLabel)
    {
        phoneLabel = [[UILabel alloc] init];
    }
    phoneLabel.frame = CGRectMake(0, CGRectGetMaxY(nameLabel.frame)+5 , screenWidth, 15);
    phoneLabel.textAlignment = NSTextAlignmentCenter;
    phoneLabel.textColor = kFontColorA;
    phoneLabel.font = NormalFontWithSize(12);
    [topView addSubview:phoneLabel];
    
    infoTableView.tableHeaderView = topView;
}

- (void)createTableView
{
    infoTableView = [[UITableView alloc] init];
    infoTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    infoTableView.delegate = self;
    infoTableView.dataSource = self;
    infoTableView.delaysContentTouches = YES;
    infoTableView.backgroundColor = kBackgroundColor;
    infoTableView.frame = CGRectMake(0, 0, screenWidth, screenHeight);
    [self.view addSubview:infoTableView];
}

- (void)createFootView
{
    footView = [[UIView alloc] init];
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
    
    infoTableView.tableFooterView = footView;
    
}

-(void)mineBtnOnClick:(UIButton*)sender
{
    MineCenterViewController * MCVC = [[MineCenterViewController alloc] init];
    [self pushToViewController:MCVC];
}

- (void)btnOnClick:(UIButton *)sender
{
    MineDetailViewController * MDVC = [[MineDetailViewController alloc] init];
    MDVC.infoDic = pushDic;
    [self pushToViewController:MDVC];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return titleArr.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell * mineCell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 60)];
    mineCell.backgroundColor = kFontColorA;
    
    UIImageView  *  imageView = [[UIImageView alloc] init] ;
    imageView.backgroundColor =[UIColor clearColor];
    imageView.image = [imageArr objectAtIndex:indexPath.row];
    imageView.frame = CGRectMake(15, 15, 30, 30);
    [mineCell addSubview:imageView];
    
    UILabel * title = [[UILabel alloc] init ];
    title.frame=CGRectMake(CGRectGetMaxX(imageView.frame)+17, 0, 100, 60);
    title.backgroundColor = [UIColor clearColor];
    title.textColor = KFontNewColorA;
    title.font = NormalFontWithSize(15);
    title.text = [titleArr objectAtIndex:indexPath.row];
    [mineCell addSubview:title];
    
    NSString * miaoStr = @"";
    NSString * jiaogeStr = @"";
    NSString * jiangliStr = @"";
    NSString * tixianStr = @"";
    NSString * yinhangStr = @"";
    NSString * kefuStr = @"";
    NSString * versionStr = [NSString stringWithFormat:@"版本：v%@", kAppVersion];
    NSString * cardNumberStr = @"";
    if([[pushDic allKeys] count]>0)
    {
        miaoStr = [NSString stringWithFormat:@"%@",[[pushDic objectForKey:@"tips_msgbox"] description]];
        jiaogeStr = [NSString stringWithFormat:@"%@",[[pushDic objectForKey:@"transaction_record_count"] description]];
        jiangliStr = [NSString stringWithFormat:@"%@",[[pushDic objectForKey:@"make_money_sum"]description]];
        tixianStr = [NSString stringWithFormat:@"%@",[[pushDic objectForKey:@"withdraw_sum"] description]] ;
        yinhangStr = [NSString stringWithFormat:@"%@",[[pushDic objectForKey:@"bank_card_count"] description]] ;
        cardNumberStr = [NSString stringWithFormat:@"%@",[[pushDic objectForKey:@"card_num"] description]];
    }
    NSArray * dataArr = @[miaoStr,jiaogeStr,jiangliStr,tixianStr,yinhangStr,cardNumberStr,@"点我进行帮助",kefuStr,versionStr];
    
    if ([GFStaticData getObjectForKey:kTagAppStoreClose])
    {
        //
    }
    else
    {
        dataArr = @[@"",jiaogeStr,jiangliStr,@"",@"",@""];
    }
    
    UILabel * rightLb = [[UILabel alloc] init];
    rightLb.textAlignment = NSTextAlignmentRight;
    rightLb.backgroundColor = [UIColor clearColor];
    rightLb.frame = CGRectMake(screenWidth - 170, 0, 150, 60);
    rightLb.textColor = KFontNewColorB;
    if (indexPath.row < dataArr.count)
    {
        rightLb.text =[dataArr objectAtIndex:indexPath.row];
    }
    rightLb.font = NormalFontWithSize(13);
    [mineCell addSubview:rightLb];
    
    if (indexPath.row < dataArr.count)
    {
        UILabel * lineLb = [[UILabel alloc] initWithFrame:CGRectMake(0, 59.5, screenWidth, 0.5)];
        lineLb.backgroundColor = KColorHeader;
        [mineCell addSubview:lineLb];
    }
    
    if (indexPath.row == dataArr.count)
    {
        UILabel * lineLb2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 60.5, screenWidth, 0.5)];
        lineLb2.backgroundColor = KLineNewBGColor1;
        [mineCell addSubview:lineLb2];
        
        UILabel * lineLb3 = [[UILabel alloc] initWithFrame:CGRectMake(0, 61, screenWidth, 0.5)];
        lineLb3.backgroundColor = KLineNewBGColor2;
        [mineCell addSubview:lineLb3];
    }
    
    UIView * backColorview = [[UIView alloc] init];
    backColorview .backgroundColor = KSelectNewColor;
    mineCell.selectedBackgroundView = backColorview;
    
    return mineCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    if (indexPath.row == 0)
    {
        MessageBoxViewController * MBVC = [[MessageBoxViewController alloc] init];
        [self pushToViewController:MBVC];
    }
    else if (indexPath.row == 1)
    {
        BuyHistoryViewController * BHVC = [[BuyHistoryViewController alloc] init];
        [self pushToViewController:BHVC];
    }
    else if (indexPath.row == 2)
    {
        EarnHistoryViewController * EHVC = [[EarnHistoryViewController alloc] init];
        [self pushToViewController:EHVC];
    }
    else if (indexPath.row == 3)
    {
        if ([GFStaticData getObjectForKey:kTagAppStoreClose])
        {
            DrawCashHistoryViewController * WDCV = [[DrawCashHistoryViewController alloc] init];
            [self pushToViewController:WDCV];
        }
        else
        {
            //卡包道具
            PropBagViewController * PBVC = [[PropBagViewController alloc] init];
            [self pushToViewController:PBVC];
        }
    }
    else if (indexPath.row == 4)
    {
        if ([GFStaticData getObjectForKey:kTagAppStoreClose])
        {
            CardViewController * FDVC = [[CardViewController alloc] init];
            FDVC.deliverType = 1;
            [self pushToViewController:FDVC];
        }
        else
        {
            [self jumpHelpViewController];
        }
    }
    else if (indexPath.row == 5)
    {
        if ([GFStaticData getObjectForKey:kTagAppStoreClose])
        {
            //卡包道具
            PropBagViewController * PBVC = [[PropBagViewController alloc] init];
            [self pushToViewController:PBVC];
        }
        else
        {
            MoreViewController * MVC = [[MoreViewController alloc] init];
            [self pushToViewController:MVC];
        }
    }
    else if (indexPath.row == 6)
    {
        //帮助中心
        [self  jumpHelpViewController];
    }
    else if (indexPath.row == 7)
    {
        [[EMIMHelper defaultHelper] loginEasemobSDK];
//        NSString *cname = @"zhangzhangkefu";
        NSString * cname = @"800";
        ChatViewController *chatController = [[ChatViewController alloc] initWithChatter:cname isGroup:NO];
        [self.navigationController pushViewController:chatController animated:YES];
    }
    else if (indexPath.row == 8)
    {
        MoreViewController * MVC = [[MoreViewController alloc] init];
        [self pushToViewController:MVC];
    }
    
    [infoTableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.f;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y < 30)
    {
        headerView.alpha = 0;
        [self.view bringSubviewToFront:infoTableView];
        
    }
    else if (scrollView.contentOffset.y > 150)
    {
        headerView.alpha = 1;
        [self.view bringSubviewToFront:headerView];
        [self.view sendSubviewToBack:infoTableView];
    }
    else
    {
        headerView.alpha = (scrollView.contentOffset.y/120);
        [self.view sendSubviewToBack:infoTableView];
    }
}

- (void)jumpHelpViewController
{
    GFWebViewController * GWVC = [[GFWebViewController alloc] init];
    GWVC.title = @"帮助中心";
    GWVC.pageType = WebViewTypePush;
    GWVC.flag = 0;
    GWVC.requestUrl = [NSURL URLWithString:[NSString stringWithFormat:HelpCenterUrl, kAppVersion]];
    [self.navigationController pushViewController:GWVC animated:YES];
}

//加模糊效果，image是图片，blur是模糊度
- (UIImage *)blurryImage:(UIImage *)image withBlurLevel:(CGFloat)blur
{
    //模糊度,
    if ((blur < 0.1f) || (blur > 2.0f)) {
        blur = 0.5f;
    }
    
    //boxSize必须大于0
    int boxSize = (int)(blur * 100);
    boxSize -= (boxSize % 2) + 1;
    
    //图像处理
    CGImageRef img = image.CGImage;
    //需要引入#import <Accelerate/Accelerate.h>
    /*
     This document describes the Accelerate Framework, which contains C APIs for vector and matrix math, digital signal processing, large number handling, and image processing.
     本文档介绍了Accelerate Framework，其中包含C语言应用程序接口（API）的向量和矩阵数学，数字信号处理，大量处理和图像处理。
     */
    
    //图像缓存,输入缓存，输出缓存
    vImage_Buffer inBuffer, outBuffer;
    vImage_Error error;
    //像素缓存
    void *pixelBuffer;
    
    //数据源提供者，Defines an opaque type that supplies Quartz with data.
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    // provider’s data.
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    
    //宽，高，字节/行，data
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    
    //像数缓存，字节行*图片高
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    
    // 第三个中间的缓存区,抗锯齿的效果
    void *pixelBuffer2 = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    vImage_Buffer outBuffer2;
    outBuffer2.data = pixelBuffer2;
    outBuffer2.width = CGImageGetWidth(img);
    outBuffer2.height = CGImageGetHeight(img);
    outBuffer2.rowBytes = CGImageGetBytesPerRow(img);
    
    //Convolves a region of interest within an ARGB8888 source image by an implicit M x N kernel that has the effect of a box filter.
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer2, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    error = vImageBoxConvolve_ARGB8888(&outBuffer2, &inBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    
    
    if (error) {
        NSLog(@"error from convolution %ld", error);
    }
    
    //    NSLog(@"字节组成部分：%zu",CGImageGetBitsPerComponent(img));
    //颜色空间DeviceRGB
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    //用图片创建上下文,CGImageGetBitsPerComponent(img),7,8
    CGContextRef ctx = CGBitmapContextCreate(
                                             outBuffer.data,
                                             outBuffer.width,
                                             outBuffer.height,
                                             8,
                                             outBuffer.rowBytes,
                                             colorSpace,
                                             CGImageGetBitmapInfo(image.CGImage));
    
    //根据上下文，处理过的图片，重新组件
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    
    //clean up
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    
    free(pixelBuffer);
    free(pixelBuffer2);
    CFRelease(inBitmapData);
    
    //CGColorSpaceRelease(colorSpace);
    CGImageRelease(imageRef);
    
    return returnImage;
}

-(void)buttonClickedAtIndex:(NSInteger)index
{
    return;
}


@end
