//
//  MineCenterViewController.m
//  StockMaster
//
//  Created by Rebloom on 14-7-24.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "MineCenterViewController.h"
#import "SetNicknameViewController.h"
#import "RegisterViewController.h"
#import "NSString+UIColor.h"
#import "UIImage+UIColor.h"


@interface MineCenterViewController ()
{
    UserInfoEntity *userInfo;
}

@end

@implementation MineCenterViewController
@synthesize type;

- (void)dealloc
{
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
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
    
    userInfo = [[UserInfoCoreDataStorage sharedInstance] getCurrentUserInfo];
    uploadImage = [UIImage imageNamed:@"icon_user_default"];
    beginImage = [UIImage imageNamed:@"icon_user_default"];
    
    [headerView backButton];
    [headerView createLine];
    [headerView loadComponentsWithTitle:@"个人信息"];
    headerView.backgroundColor = kFontColorA;
    [headerView setStatusBarColor: kFontColorA];
    
    [self createUI];
    
    if (self.type)
    {
        [self takePhoto];
    }
}
- (void)createUI
{
    mineCenterTable = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(headerView.frame), screenWidth, screenHeight)];
    mineCenterTable.backgroundColor = KSelectNewColor;
    mineCenterTable.dataSource = self;
    mineCenterTable.delegate = self;
    mineCenterTable.separatorStyle = NO;
    [self.view addSubview:mineCenterTable];
    
    UIView *footView = [[UIView alloc] init];
    footView.frame = CGRectMake(0, 0, screenWidth, 150);
    footView.backgroundColor = [UIColor clearColor];
    
    UIImageView *iconView = [[UIImageView alloc] init];
    iconView.frame = CGRectMake(screenWidth/2 - 15 , 26, 30, 23);
    iconView.image = [UIImage imageNamed:@"zhangzhang"];
    [footView addSubview:iconView];
    
    UILabel *ideaLabel = [[UILabel alloc] init];
    ideaLabel.frame = CGRectMake(0, CGRectGetMaxY(iconView.frame)+10, screenWidth, 14);
    ideaLabel.text = @"免费炒股,大赚真钱";
    ideaLabel.textAlignment = NSTextAlignmentCenter;
    ideaLabel.font = NormalFontWithSize(12);
    ideaLabel.textColor = KFontNewColorC;
    ideaLabel.backgroundColor = [UIColor clearColor];
    [footView addSubview:ideaLabel];
    mineCenterTable.tableFooterView = footView;
    
    [mineCenterTable reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    if (userInfo != nil)
    {
        nameLabel.text = [self handleNickname:userInfo.nickname];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        return 110;
    }
    else
        return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (nil == userInfo) {
        return nil;
    }
    
    UITableViewCell * mineCell = [[UITableViewCell alloc] init];
    mineCell.selectionStyle = UITableViewCellSelectionStyleNone;
    mineCell.backgroundColor = kFontColorA;
    mineCell.selectedBackgroundView = [[UIView alloc] initWithFrame:mineCell.frame];
    mineCell.selectedBackgroundView.backgroundColor = KSelectNewColor;
    if (indexPath.row == 2)
    {
        mineCell.selectedBackgroundView.backgroundColor = kFontColorA;
        
        UILabel * lineLb2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 59.5, screenWidth, 0.5)];
        lineLb2.backgroundColor = KLineNewBGColor2;
        [mineCell addSubview:lineLb2];
    }
    
    UILabel * lineLb = [[UILabel alloc] init];
    if(indexPath.row == 0){
        lineLb.frame = CGRectMake(0, 109.5, screenWidth, 0.5);
        lineLb.backgroundColor = KColorHeader;
    }
    else
    {
        lineLb.frame = CGRectMake(0, 59.0, screenWidth, 0.5);
        lineLb.backgroundColor = KLineNewBGColor1;
    }
    [mineCell addSubview:lineLb];
    
    tipLabel = [[UILabel alloc] init];
    tipLabel.frame = CGRectMake(screenWidth-170, 0, 100, 110);
    tipLabel.textColor = [UIColor orangeColor];
    tipLabel.text = @"换头像,赚本金";
    tipLabel.textAlignment = NSTextAlignmentLeft;
    tipLabel.font = NormalFontWithSize(12);
    [mineCell addSubview:tipLabel];
    tipLabel.hidden = YES;
    
    NSArray * leftArr = @[@"头像",@"昵称",@"账号"];
    if (indexPath.row < leftArr.count)
    {
        UILabel * leftLabel = [[UILabel alloc] init] ;
        if (indexPath.row == 0) {
            leftLabel.frame = CGRectMake(20, 0, 100, 110);
        }
        else if (indexPath>0)
        {
            leftLabel.frame = CGRectMake(20, 0, 100, 60);
        }
        leftLabel.backgroundColor = [UIColor clearColor];
        leftLabel.textColor = kTitleColorA;
        leftLabel.font = NormalFontWithSize(15);
        leftLabel.text = [leftArr objectAtIndex:indexPath.row];
        [mineCell addSubview:leftLabel];
        
        if (indexPath.row == 0)
        {
            if (!headView)
            {
                headView = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth-90, 20, 70, 70)];
                headView.layer.cornerRadius = 35;
                headView.layer.masksToBounds = YES;
            }
            // 去掉头像url后面的参数，因为参数为随机变动时间
            NSArray *urlArray = [userInfo.head componentsSeparatedByString:@"?"];
            NSString *headUrl = urlArray.firstObject;
            [headView sd_setImageWithURL:[NSURL URLWithString:headUrl]
                           placeholderImage:uploadImage
                                    options:SDWebImageRefreshCached
                                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                      if (nil == error) {
                                          uploadImage = image;
                                          beginImage = image;
                                          [[[SDWebImageManager sharedManager] imageCache] storeImage:uploadImage forKey:headUrl];
                                          
                                      }
                                      
                                      // 用是否缓存网络图片来判断是不修改过头像，临时的办法
                                      if ([[SDWebImageManager sharedManager] cachedImageExistsForURL:[NSURL URLWithString:headUrl]]) {
                                          tipLabel.hidden = YES;
                                      }
                                      else {
                                          tipLabel.hidden = NO;
                                      }
                                  }];
            
            [mineCell addSubview:headView];
        }
        
        NSString * nickName = [self handleNickname:userInfo.nickname];
        if (indexPath.row == 1 || indexPath.row == 2)
        {
            UILabel * rightLabel = [[UILabel alloc] init];;
            rightLabel.backgroundColor = [UIColor clearColor];
            rightLabel.textAlignment = NSTextAlignmentRight;
            rightLabel.numberOfLines = 2;
            rightLabel.font = NormalFontWithSize(12);
            rightLabel.textColor = KFontNewColorB;
            if (indexPath.row == 1) {
                nameLabel = rightLabel;
                nameLabel.text = nickName;
                nameLabel.frame = CGRectMake(screenWidth-211, 0, 170, 60);
                UIImageView * jiantouView = [[UIImageView alloc] init];
                jiantouView.frame = CGRectMake(screenWidth-31, 20, 11, 20);
                jiantouView.image = [UIImage imageNamed:@"jiantou-you"];
                [mineCell addSubview:jiantouView];
            }
            else if (indexPath.row == 2)
            {
                mobelLabel = rightLabel;
                mobelLabel.text =[Utility departString:userInfo.mobile withType:4] ;
                mobelLabel.frame = CGRectMake(screenWidth-220, 0, 200, 60);
            }
            [mineCell addSubview:rightLabel];
        }
    }
    return mineCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            // 选择头像
            [self takePhoto];
        }
        else if (indexPath.row == 1)
        {
            // 修改昵称
            SetNicknameViewController * SNVC = [[SetNicknameViewController alloc] init];
            SNVC.type = 3;
            SNVC.nameStr = userInfo.nickname;
            [self pushToViewController:SNVC];
        }
    }
    else if (indexPath.section == 1)
    {
        if (indexPath.row == 0)
        {
            RegisterViewController * RVC = [[RegisterViewController alloc] init];
            RVC.type = 1;
            [self pushToViewController:RVC];
        }
        // 去绑定的相关页面
    }
}

- (void)takePhoto
{
    if (!mainView)
    {
        mainView = [[UIView alloc] init];
    }
    mainView.frame = CGRectMake(0, 0, screenWidth, screenHeight);
    mainView.hidden = NO;
    mainView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:mainView];
    
    UIView * topView = [[UIView alloc] init];
    topView.frame = CGRectMake(0, 0, screenWidth, screenHeight);
    topView.alpha = 0.5;
    topView.backgroundColor = @"#000000".color;
    [mainView addSubview:topView];
    
    UIButton * hideBtn = [[UIButton alloc] init];
    hideBtn.frame = topView.frame;
    hideBtn.backgroundColor = [UIColor clearColor];
    [hideBtn addTarget:self action:@selector(cancelBtnClicked:) forControlEvents:UIControlEventTouchUpInside
     ];
    [mainView addSubview:hideBtn];
    
    if (!feetView)
    {
        feetView = [[UIImageView alloc] init];
    }
    feetView.hidden = NO;
    feetView.backgroundColor = [UIColor whiteColor];
    feetView.userInteractionEnabled = YES;
    feetView.frame = CGRectMake(0, screenHeight - 202, screenWidth, 202);
    [self.view addSubview:feetView];
    [self.view bringSubviewToFront:feetView];
    
    UIButton * picBtn = [[UIButton alloc] init];
    picBtn.frame = CGRectMake(20, 20, screenWidth-40, 44);
    picBtn.tag = 1001;
    picBtn.tintColor = kFontColorA;
    picBtn.layer.cornerRadius = 5;
    picBtn.layer.masksToBounds = YES;
    picBtn.titleLabel.font = NormalFontWithSize(16);
    [picBtn setTitle:@"拍照" forState:UIControlStateNormal];
    [picBtn setBackgroundImage:[KFontNewColorD image] forState:UIControlStateNormal];
    [picBtn setBackgroundImage:[KBtnSelectNewColorA image ] forState:UIControlStateSelected];
    [picBtn setBackgroundImage:[KBtnSelectNewColorA image] forState:UIControlStateHighlighted];
    [picBtn addTarget:self action:@selector(picBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [feetView addSubview:picBtn];
    
    UIButton * photoBtn = [[UIButton alloc] init];
    photoBtn.frame = CGRectMake(20, CGRectGetMaxY(picBtn.frame)+10, screenWidth-40, 44);
    photoBtn.tag = 1002;
    photoBtn.tintColor = kFontColorA;
    photoBtn.layer.cornerRadius = 5;
    photoBtn.layer.masksToBounds = YES;
    photoBtn.titleLabel.font = NormalFontWithSize(16);
    [photoBtn setTitle:@"从相册选择" forState:UIControlStateNormal];
    [photoBtn setBackgroundImage:[KFontNewColorD image] forState:UIControlStateNormal];
    [photoBtn setBackgroundImage:[KBtnSelectNewColorA image ] forState:UIControlStateSelected];
    [photoBtn setBackgroundImage:[KBtnSelectNewColorA image] forState:UIControlStateHighlighted];
    [photoBtn addTarget:self action:@selector(picBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [feetView addSubview:photoBtn];
    
    UIButton * cancelBtn = [[UIButton alloc] init];
    cancelBtn.frame = CGRectMake(20, CGRectGetMaxY(photoBtn.frame)+10, screenWidth-40, 44);
    cancelBtn.layer.cornerRadius = 5;
    cancelBtn.layer.masksToBounds = YES;
    cancelBtn.titleLabel.font = NormalFontWithSize(16);
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:KFontNewColorA forState:UIControlStateNormal];
    [cancelBtn setBackgroundImage:[KSelectNewColor1 image] forState:UIControlStateNormal];
    [cancelBtn setBackgroundImage:[KSelectNewColor2 image ] forState:UIControlStateSelected];
    [cancelBtn setBackgroundImage:[KSelectNewColor2 image] forState:UIControlStateHighlighted];
    [cancelBtn addTarget:self action:@selector(cancelBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [feetView addSubview:cancelBtn];
    
    CATransition *animation = [CATransition animation];
    
    [animation setDuration:0.5];
    
    [animation setType: kCATransitionMoveIn];
    
    [animation setSubtype: kCATransitionFromTop];
    
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
    
    [feetView.layer addAnimation:animation forKey:nil];
}

// 点击取消按钮
- (void)cancelBtnClicked:(UIButton*)sender
{
    [UIView beginAnimations:@"Animation" context:nil];
    [UIView setAnimationDuration:0.4];
    feetView.frame = CGRectMake(0, screenHeight, screenWidth, 202);
    [UIView commitAnimations];
    [self performSelector:@selector(handleTimer) withObject:self afterDelay:0.4];
}

-(void)handleTimer
{
    mainView.hidden = YES;
    feetView.hidden = YES;
    feetView.frame = CGRectMake(0, screenHeight - 202, screenWidth, 202);
    [self clearSubview];
}

- (NSString *)handleNickname:(NSString *)nickname
{
    if (nickname.length == 0) {
        return nickname;
    }
    
    NSString *result = nickname;
    if ([Utility lenghtWithString:nickname] > 14)
    {
        for (int i = 0; i < nickname.length; i++)
        {
            NSString * apartStr = [nickname substringToIndex:i];
            // 汉字字符集
            NSString * pattern  = @"[\u4e00-\u9fa5]";
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
            // 计算中文字符的个数
            NSInteger numMatch = [regex numberOfMatchesInString:apartStr options:NSMatchingReportProgress range:NSMakeRange(0, apartStr.length)];
            if (apartStr.length+numMatch == 14)
            {
                result = [NSString stringWithFormat:@"%@...",apartStr];
                break;
            }
        }
    }
    return result;
}

// 清除视图块子视图
-(void)clearSubview
{
    if (mainView)
    {
        for (UIView * view in mainView.subviews)
        {
            [view removeFromSuperview];
        }
    }
    if (feetView)
    {
        for (UIView * view in feetView.subviews)
        {
            feetView.backgroundColor = [UIColor clearColor];
            [view removeFromSuperview];
        }
    }
}


-(void)picBtnClicked:(UIButton *)sender
{
    [self performSelector:@selector(handleTimer) withObject:self afterDelay:0.4];
    
    NSUInteger sourceType = 0;
    
    // 判断是否支持相机
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        if (sender.tag == 1001)
        {
            sourceType = UIImagePickerControllerSourceTypeCamera;
        }
        else if (sender.tag == 1002)
        {
            sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
    }
    else
    {
        if (sender.tag == 1001)
        {
            sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        }
        else if (sender.tag == 1002)
        {
            sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        }
    }
    
    // 跳转到相机或相册页面
    imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    imagePicker.sourceType = sourceType;
    [self presentViewController:imagePicker animated:YES completion:^{}];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    mainView.hidden =YES;
    feetView.hidden =YES;
    [picker dismissViewControllerAnimated:YES completion:^{}];
    
    // 上传头像立即显示所选图片
    uploadImage = [info objectForKey:UIImagePickerControllerEditedImage];
    headView.image = uploadImage;
    
    //[mineCenterTable reloadData];
    
    NSData *_data = UIImageJPEGRepresentation(uploadImage, .2f);
    
    NSString *_encodedImageStr = [_data base64Encoding];

    NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:_encodedImageStr forKey:@"user_head_images"];
    [paramDic setObject:@"head" forKey:@"location"];
    [GFRequestManager connectWithDelegate:self action:Submit_upload_user_head param:paramDic];
}

- (void)requestUserInfo
{
    NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
    [GFRequestManager connectWithDelegate:self action:Get_user_info param:paramDic];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    [super requestFinished:request];
    
    ASIFormDataRequest * formDataRequest = (ASIFormDataRequest *)request;
    if([formDataRequest.action isEqualToString:Submit_upload_user_head])
    {
        NSString * imageUrl = [[requestInfo objectForKey:@"data"] objectForKey:@"photo_path"];
        NSMutableDictionary *headDict = [NSMutableDictionary dictionary];
        headDict[@"head"] = imageUrl;
        headDict[@"uid"] = userInfo.uid;
        [[UserInfoCoreDataStorage sharedInstance] saveLoginUserInfo:headDict];
        userInfo = [[UserInfoCoreDataStorage sharedInstance] getCurrentUserInfo];
        
        // 上传头像成功将原来图片修改成上传图片
        beginImage = uploadImage;
        NSArray *urlArray = [imageUrl componentsSeparatedByString:@"?"];
        imageUrl = urlArray.firstObject;
        [[[SDWebImageManager sharedManager] imageCache] storeImage:uploadImage forKey:imageUrl];
        // 上传头像成功隐藏提示标签
        tipLabel.hidden = YES;
    }
    else if ([formDataRequest.action isEqualToString:Get_user_info])
    {
        NSMutableDictionary *userDict = [[requestInfo objectForKey:@"data"] mutableCopy];
        userDict[@"uid"] = userInfo.uid;
        [[UserInfoCoreDataStorage sharedInstance] saveLoginUserInfo:userDict];
        userInfo = [[UserInfoCoreDataStorage sharedInstance] getCurrentUserInfo];
        [mineCenterTable reloadData];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [super requestFailed:request];
    
    ASIFormDataRequest * formDataRequest = (ASIFormDataRequest *)request;
    if([formDataRequest.action isEqualToString:Submit_upload_user_head])
    {
        // 上传头像失败恢复原头像
        headView.image = beginImage;
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^{
        mainView.hidden = YES;
        feetView.hidden = YES;
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
