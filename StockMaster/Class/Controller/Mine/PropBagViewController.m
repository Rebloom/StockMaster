//
//  PropBagViewController.m
//  StockMaster
//
//  Created by 孤星之殇 on 15/6/30.
//  Copyright (c) 2015年 aizhangzhang. All rights reserved.
//

#import "PropBagViewController.h"
#import "PropView.h"
#import "EmotionRankViewController.h"
@interface PropBagViewController ()

@end

@implementation PropBagViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = KSelectNewColor;

    infoArr = [[UserInfoCoreDataStorage sharedInstance] getPropCard];
    
    [headerView loadComponentsWithTitle:@"道具卡包"];
    [headerView backButton];
    [headerView createLine];
    
    [self createTableView];
    [self createFooterView];
    
    [self requestCardList];
}

- (void)createTableView
{
    infoTableView = [[UITableView alloc] init];
    infoTableView.frame = CGRectMake(0, CGRectGetMaxY(headerView.frame), screenWidth, screenHeight-CGRectGetMaxY(headerView.frame));
    infoTableView.delegate = self;
    infoTableView.dataSource = self;
    infoTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    infoTableView.backgroundColor = kBackgroundColor;
    [self.view addSubview:infoTableView];
}

- (void)createFooterView
{
    UIView * view = [[UIView alloc] init];
    view.frame = CGRectMake(0, 0, screenWidth, 150);
    view.backgroundColor = [UIColor clearColor];
    infoTableView.tableFooterView = view;
    
    UIImageView * iconImgView = [[UIImageView alloc] init];
    iconImgView.frame = CGRectMake(screenWidth/2-15, 52, 30, 23);
    iconImgView.image = [UIImage imageNamed:@"zhangzhang"];
    [view addSubview:iconImgView];
    
    UILabel * ideaLabel = [[UILabel alloc] init];
    ideaLabel.frame = CGRectMake(0,CGRectGetMaxY(iconImgView.frame)+10, screenWidth, 12);
    ideaLabel.text = @"免费炒股，大赚真钱";
    ideaLabel.textAlignment = NSTextAlignmentCenter;
    ideaLabel.textColor = KFontNewColorC;
    ideaLabel.font = NormalFontWithSize(12);
    [view addSubview:ideaLabel];
}

//获取道具列表
- (void)requestCardList
{
    NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];

    [GFRequestManager connectWithDelegate:self action:Get_card_list param:paramDic];
}

//获取卡片详情
- (void)requestCardInfo:(NSString *)card_id
{
    NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:card_id forKey:@"card_id"];
    [GFRequestManager connectWithDelegate:self action:Get_card_info param:paramDic];
}

//请求购买道具卡信息
- (void)requestCardBuyInfo:(NSString *)card_id withNum:(NSString *)num
{
    NSMutableDictionary * param = [NSMutableDictionary dictionary];
    [param setObject:card_id forKey:@"card_id"];
    [param setObject:num forKey:@"buy_num"];
    [GFRequestManager connectWithDelegate:self action:Get_card_buy_info param:param];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    [super requestFinished:request];
    
    ASIFormDataRequest * formdataRequest = (ASIFormDataRequest *)request;
    
    if ([formdataRequest.action isEqualToString:Get_card_list])
    {
        NSMutableArray * tempArr = [[requestInfo objectForKey:@"data"] objectForKey:@"list"];
        
        descStr = [[requestInfo objectForKey:@"data"] objectForKey:@"usable_buy_money"];
        infoArr = [[[UserInfoCoreDataStorage sharedInstance] savePropCard:tempArr] mutableCopy];
    }
    else if ([formdataRequest.action isEqualToString:Get_card_info])
    {
        [self propCardInfo:[requestInfo objectForKey:@"data"]];
    }
    else if ([formdataRequest.action isEqualToString:Submit_use_card])
    {
        [[TKAlertCenter defaultCenter] postAlertWithMessage:@"使用成功" withType:ALERTTYPEERROR];
        [self requestCardList];
        if ([selectedCardID isEqualToString:@"2"])
        {
            [self requestReceive_90_card];
        }
    }
    else if ([formdataRequest.action isEqualToString:Get_card_buy_info])
    {
        [self propCardBuyInfo:[requestInfo objectForKey:@"data"]];
    }
    else if ([formdataRequest.action isEqualToString:Submit_buy_card])
    {
        [self buyCardFinished:[requestInfo objectForKey:@"data"]];
    }
    else if ([formdataRequest.action isEqualToString:Submit_receive_90_card])
    {
        [self requestCardList];
        
        NSDictionary * dict = [requestInfo objectForKey:@"data"];
        if ([[dict objectForKey:@"add_card_num"] integerValue] != 0)
        {
            [self propCardInfo:dict];
        }
    }
    [infoTableView reloadData];
}

- (void)propCardInfo:(NSDictionary *)dic
{
    NSInteger type;
    propFlag = [CHECKDATA(@"status") integerValue];
    if (propFlag == 1 || propFlag == 10)
    {
        type = 1;
    }
    else
    {
        type = 2;
    }

    prop =  [[PropView defaultShareView] initViewWithName:CHECKDATA(@"card_name") WithDescription:CHECKDATA(@"desc") WithType:type Delegate:self WithImageURL:CHECKDATA(@"img") WithDirect:[CHECKDATA(@"link_to") integerValue]?@"查看感情度":@""  WithPrompt:CHECKDATA(@"button_desc") isBuy:NO cardPrice:@"" usable:@"" ExpireTime:CHECKDATA(@"expire_time")];
    prop.delegate = self;
    [prop showView];
}

- (void)propCardBuyInfo:(NSDictionary *)dic
{
    if (prop.isShow)
    {
        int numValue;
        if (prop.isAdd)
        {
            numValue = [prop.numLabel.text intValue]+1;
        }
        else
        {
            numValue = [prop.numLabel.text intValue]-1;
        }
        prop.numLabel.text = [NSString stringWithFormat:@"%d",numValue];
        [prop.buyBtn setTitle:CHECKDATA(@"button_buy") forState:UIControlStateNormal];
    }
    else
    {
        prop =  [[PropView defaultShareView] initViewWithName:CHECKDATA(@"card_name") WithDescription:CHECKDATA(@"desc") WithType:1 Delegate:self WithImageURL:CHECKDATA(@"img") WithDirect:@"" WithPrompt:CHECKDATA(@"button_buy")  isBuy:YES cardPrice:CHECKDATA(@"button_buy") usable:descStr ExpireTime:@""];
        prop.delegate = self;
        [prop showView];
    }
}

- (void)buyCardFinished:(NSDictionary *)dic
{
    [[TKAlertCenter defaultCenter] postAlertWithMessage:CHECKDATA(@"prompt1") withType:ALERTTYPEERROR];
    [prop hideView];
    [self requestCardList];
}

- (void)cardToUse:(NSInteger)index
{
    [prop hideView];
    if (propFlag == 1)
    {
        [self requestUseCard:selectedCardID];
    }
}

- (void)addBtnClicked:(id)sender
{
    prop.leftImage.enabled = YES;
    UIButton * btn = (UIButton *)sender;
    int numValue = [prop.numLabel.text intValue];
    
    [self requestCardBuyInfo:[NSString stringWithFormat:@"%ld",btn.tag] withNum:[NSString stringWithFormat:@"%d",numValue+1]];
}

- (void)minusBtnClicked:(id)sender
{
    prop.leftImage.enabled = YES;
    if ([prop.numLabel.text integerValue] > 1)
    {
        UIButton * btn = (UIButton *)sender;
        int numValue = [prop.numLabel.text intValue]-1;
        
        if (numValue == 1)
        {
            prop.leftImage.enabled = NO;
        }
        
        [self requestCardBuyInfo:[NSString stringWithFormat:@"%ld",btn.tag] withNum:[NSString stringWithFormat:@"%d",numValue]];
    }
    else
    {
        prop.leftImage.enabled = NO;
    }
}

- (void)buyBtnClicked:(id)sender
{
    if (selectedCardID)
    {
        NSMutableDictionary * param = [NSMutableDictionary dictionary];
        [param setObject:selectedCardID forKey:@"card_id"];
        [param setObject:prop.numLabel.text forKey:@"buy_num"];
        [GFRequestManager connectWithDelegate:self action:Submit_buy_card param:param];
    }
}

- (void)requestUseCard:(NSString*)card_id
{
    NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:card_id forKey:@"card_id"];
    [paramDic setObject:@"1" forKey:@"card_num"];
    [GFRequestManager connectWithDelegate:self action:Submit_use_card param:paramDic];
}

- (void)requestReceive_90_card
{
    NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
    [GFRequestManager connectWithDelegate:self action:Submit_receive_90_card param:paramDic];
}

- (void)directToDo:(NSInteger)index
{
    [prop hideView];
    EmotionRankViewController * ERVC = [[EmotionRankViewController alloc] init];
    [self pushToViewController:ERVC];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return infoArr.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 30)];
    view.backgroundColor = [UIColor whiteColor];
    
    UILabel * desc = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, screenWidth-15, 15)];
    desc.backgroundColor = [UIColor clearColor];
    desc.font = NormalFontWithSize(15);
    desc.textColor = @"#494949".color;
    desc.text = descStr;
    [desc sizeToFit];
    [view addSubview:desc];
    
    UIImageView * image = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(desc.frame)+10, 13, 19, 19)];
    image.image = [UIImage imageNamed:@"icon_wenhao1"];
    [view addSubview:image];
    
    UIButton * askImage = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(desc.frame), 0, 45, 45)];
    [askImage addTarget:self action:@selector(askImageClicked:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:askImage];

    return view;
}

- (void)askImageClicked:(id)sender
{
     [[CHNAlertView defaultAlertView] showContent:@"购买道具消耗盈利，本金无法购买\n 总资产 = 本金 + 盈利" cancelTitle:nil sureTitle:@"确定" withDelegate:self withType:6];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellID = @"propCard";
    PropBagCell * cell = [tableView  dequeueReusableCellWithIdentifier:cellID];
    if (nil == cell)
    {
        cell = [[PropBagCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.useBtn.tag = indexPath.row;
    cell.buyBtn.tag = indexPath.row;
    cell.delegate = self;
    
    PropCardEntity * propCard = [infoArr objectAtIndex:indexPath.row];
    
    if (propCard)
    {
        cell.nameLabel.text = propCard.name;
        cell.desLabel.text = propCard.desc;
        cell.numberLabel.text = [NSString stringWithFormat:@"x%@",propCard.num];
        cell.useLabel.text = propCard.buttonDesc;
        [cell.nameLabel sizeToFit];
        cell.timeupLabel.frame = CGRectMake(CGRectGetMaxX(cell.nameLabel.frame)+11, CGRectGetMinY(cell.propImageView.frame), 120, 16);
        cell.timeupLabel.text = propCard.isDuration?propCard.expireTime:@"";
        
        if (propCard.num.length > 1)
        {
            cell.numberLabel.frame = CGRectMake(60, 15, 25, 15);
        }
        
        //调整描述行间距
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:propCard.desc];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineSpacing:5];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [propCard.desc length])];
        
        cell.desLabel.attributedText = attributedString;
        
        CGSize size = CGSizeMake(screenWidth - 170, CGFLOAT_MAX);
        CGSize labelSize = [cell.desLabel sizeThatFits:size];
        cell.desLabel.frame = CGRectMake(CGRectGetMinX(cell.nameLabel.frame), CGRectGetMaxY(cell.nameLabel.frame)+10, screenWidth -165, labelSize.height);
        
        [cell.propImageView sd_setImageWithURL:[NSURL URLWithString:propCard.image]
                   placeholderImage:[UIImage imageNamed:@"task_default"]
                            options:SDWebImageRefreshCached];
        if (propCard.status == 1)
        {
            cell.useLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.2];
            cell.useBtn.enabled = YES;
        }
        else if (propCard.status == 2 || propCard.status == 3)
        {
            cell.useLabel.backgroundColor = @"#8a8a8a".color;
            cell.useBtn.enabled = NO;
        }
        
        if (propCard.isSystemGive == 1)
        {
            cell.buyBtn.enabled = NO;
            cell.currentPrice.textColor = @"#b8b8b8".color;
            cell.currentPrice.text = propCard.systemGiveDesc;
            
            cell.originPrice.hidden = YES;
            cell.originPriceLine.hidden = YES;
        }
        else
        {
            cell.buyBtn.enabled = YES;
            cell.currentPrice.textColor = @"#6790c2".color;
            cell.currentPrice.text = [NSString stringWithFormat:@"%@%@",propCard.currentPrice,propCard.buyDesc];
            
            cell.originPrice.hidden = NO;
            cell.originPriceLine.hidden = NO;
            cell.originPrice.textColor = @"#6790c2".color;
            cell.originPrice.text = propCard.oldPrice;
            [cell.originPrice sizeToFit];
            cell.originPriceLine.frame = CGRectMake(cell.originPrice.frame.origin.x, cell.originPrice.center.y, cell.originPrice.frame.size.width, 1);
            cell.originPriceLine.backgroundColor = @"#6790c2".color;
        }
        
        if (labelSize.height > 35)
        {
            NSInteger count = labelSize.height/35;
            cell.lineLabel.frame = CGRectMake(0, 89.5+(count+1)*10, screenWidth, 0.5);
            cell.frame = CGRectMake(0, 0, screenWidth, 90+(count+1)*10);
        }
    }
    
    return cell;
}

- (void)propCardFunction:(NSInteger)tag
{
    PropCardEntity * propCard = [infoArr objectAtIndex:tag];
    selectedCardID = propCard.cardID;
    [self requestCardInfo:selectedCardID];
}

- (void)buyCardFunction:(NSInteger)tag
{
    PropCardEntity * propCard = [infoArr objectAtIndex:tag];
    selectedCardID = propCard.cardID;
    [self requestCardBuyInfo:selectedCardID withNum:@"1"];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
