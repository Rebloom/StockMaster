//
//  NoticeSettingViewController.m
//  StockMaster
//
//  Created by Rebloom on 15/3/16.
//  Copyright (c) 2015年 Rebloom. All rights reserved.
//

#import "NoticeSettingViewController.h"

@implementation NoticeSettingViewController

@synthesize stockInfo;

- (void)dealloc
{
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [headerView loadComponentsWithTitle:@"提醒设置"];
    [headerView backButton];
    
    self.view.backgroundColor = @"#f5f5f5".color;
    
    pickContainer = [[UIView alloc] initWithFrame:CGRectMake(0, screenHeight, screenWidth, 200)];
    [self.view addSubview:pickContainer];
    
    barView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 45)];
    [pickContainer addSubview:barView];
    
    UIButton * cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 45)];
    [cancelBtn addTarget:self action:@selector(cancelBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    cancelBtn.titleLabel.font = NormalFontWithSize(15);
    [cancelBtn setTitleColor:@"#494949".color forState:UIControlStateNormal];
    [cancelBtn setTitle:@"关闭" forState:UIControlStateNormal];
    [barView addSubview:cancelBtn];
    
    UIButton * sureBtn = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth-60, 0, 60, 45)];
    [sureBtn addTarget:self action:@selector(sureBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    sureBtn.titleLabel.font = NormalFontWithSize(15);
    [sureBtn setTitleColor:@"#494949".color forState:UIControlStateNormal];
    [sureBtn setTitle:@"确定" forState:UIControlStateNormal];
    [barView addSubview:sureBtn];
    
    pickView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 45, screenWidth, 155)];
    pickView.delegate = self;
    pickView.dataSource = self;
    [pickContainer addSubview:pickView];
    
    switchView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(headerView.frame), screenWidth, 120)];
    switchView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:switchView];
    
    stockName = [[UILabel alloc] initWithFrame:CGRectMake(20, 22.5, 100, 15)];
    stockName.backgroundColor = [UIColor clearColor];
    stockName.textColor = @"#494949".color;
    stockName.font = NormalFontWithSize(15);
    stockName.text = stockInfo.name;
    [stockName sizeToFit];
    [switchView addSubview:stockName];
    
    stockID = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(stockName.frame)+30 , 23.5, 100, 13)];
    stockID.backgroundColor = [UIColor clearColor];
    stockID.textColor = @"#929292".color;
    stockID.font = NormalFontWithSize(13);
    stockID.text = stockInfo.code;
    [stockID sizeToFit];
    [switchView addSubview:stockID];
    
    currentPrice = [[UILabel alloc] initWithFrame:CGRectMake(140, 23.5, 100, 13)];
    currentPrice.textAlignment = NSTextAlignmentRight;
    currentPrice.backgroundColor = [UIColor clearColor];
    currentPrice.textColor = @"#929292".color;
    currentPrice.font = NormalFontWithSize(13);
    [switchView addSubview:currentPrice];
    
    UIView * line1 = [[UIView alloc] initWithFrame:CGRectMake(0, 59.5, screenWidth, .5)];
    line1.backgroundColor = KColorHeader;
    [switchView addSubview:line1];
    
    updownRange = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth -80 , 23.5, 60, 13)];
    updownRange.textAlignment = NSTextAlignmentRight;
    updownRange.backgroundColor = [UIColor clearColor];
    updownRange.textColor = @"#929292".color;
    updownRange.font = NormalFontWithSize(13);
    [switchView addSubview:updownRange];
    
    switchLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 80, 100, 20)];
    switchLabel.backgroundColor = [UIColor clearColor];
    switchLabel.textColor = @"#494949".color;
    switchLabel.font = NormalFontWithSize(15);
    switchLabel.text = @"提醒开关";
    [switchView addSubview:switchLabel];
    
    stockSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(screenWidth-65, 80, 10, 10)];
    [stockSwitch addTarget:self action:@selector(onSwitchClicked:) forControlEvents:UIControlEventTouchUpInside];
    [switchView addSubview:stockSwitch];
    
    UIView * line2 = [[UIView alloc] initWithFrame:CGRectMake(0, 119.5, screenWidth, .5)];
    line2.backgroundColor = KColorHeader;
    [switchView addSubview:line2];
    
    rangeView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(switchView.frame), screenWidth, 120)];
    rangeView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:rangeView];
    rangeView.hidden = YES;
    
    UIButton * upBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [upBtn setBackgroundImage:[[UIColor whiteColor] image] forState:UIControlStateNormal];
    [upBtn setBackgroundImage:[kLineBgColor4 image] forState:UIControlStateHighlighted];
    upBtn.frame = CGRectMake(0, 0, screenWidth, 60);
    [upBtn addTarget:self action:@selector(upBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [rangeView addSubview:upBtn];
    
    UIButton * downBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [downBtn setBackgroundImage:[[UIColor whiteColor] image] forState:UIControlStateNormal];
    [downBtn setBackgroundImage:[kLineBgColor4 image] forState:UIControlStateHighlighted];
    downBtn.frame = CGRectMake(0, 60, screenWidth, 60);
    [downBtn addTarget:self action:@selector(downBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [rangeView addSubview:downBtn];
    
    upRangeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 100, 20)];
    upRangeLabel.backgroundColor = [UIColor clearColor];
    upRangeLabel.textColor = @"#494949".color;
    upRangeLabel.font = NormalFontWithSize(15);
    upRangeLabel.text = @"日涨幅";
    [rangeView addSubview:upRangeLabel];
    
    upPrice = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth-120, 20, 100, 20)];
    upPrice.textAlignment = NSTextAlignmentRight;
    upPrice.backgroundColor = [UIColor clearColor];
    upPrice.textColor = @"#929292".color;
    upPrice.font = NormalFontWithSize(13);
    [rangeView addSubview:upPrice];
    
    upRange = [[UILabel alloc] initWithFrame:CGRectMake(100, 20, 140, 20)];
    upRange.textAlignment = NSTextAlignmentRight;
    upRange.backgroundColor = [UIColor clearColor];
    upRange.textColor = @"#929292".color;
    upRange.font = NormalFontWithSize(13);
    [rangeView addSubview:upRange];
    
    UIView * line3 = [[UIView alloc] initWithFrame:CGRectMake(0, 59.5, screenWidth, .5)];
    line3.backgroundColor = KColorHeader;
    [rangeView addSubview:line3];
    
    downRangeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 80, 100, 20)];
    downRangeLabel.backgroundColor = [UIColor clearColor];
    downRangeLabel.textColor = @"#494949".color;
    downRangeLabel.font = NormalFontWithSize(15);
    downRangeLabel.text = @"日跌幅";
    [rangeView addSubview:downRangeLabel];
    
    downPrice = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth-120, 80, 100, 20)];
    downPrice.textAlignment = NSTextAlignmentRight;
    downPrice.backgroundColor = [UIColor clearColor];
    downPrice.textColor = @"#929292".color;
    downPrice.font = NormalFontWithSize(13);
    [rangeView addSubview:downPrice];
    
    downRange = [[UILabel alloc] initWithFrame:CGRectMake(100, 80, 140, 20)];
    downRange.textAlignment = NSTextAlignmentRight;
    downRange.backgroundColor = [UIColor clearColor];
    downRange.textColor = @"#929292".color;
    downRange.font = NormalFontWithSize(13);
    [rangeView addSubview:downRange];
    
    UIView * line4 = [[UIView alloc] initWithFrame:CGRectMake(0, 119.5, screenWidth, .5)];
    line4.backgroundColor = KColorHeader;
    [rangeView addSubview:line4];
    
    tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(rangeView.frame)+25, screenWidth, 12)];
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.backgroundColor = [UIColor clearColor];
    tipLabel.textColor = @"#929292".color;
    tipLabel.font = NormalFontWithSize(12);
    tipLabel.text = @"个别情况下，可能会出现延迟的情况，敬请注意";
    [self.view addSubview:tipLabel];
    
    upArr = [[NSMutableArray alloc] initWithCapacity:10];
    downArr = [[NSMutableArray alloc] initWithCapacity:10];
    
    [self requestNoticeInfo];
}

- (void)requestNoticeInfo
{
    NSMutableDictionary * param = [NSMutableDictionary dictionary];
    [param setObject:stockInfo.code forKey:@"stock_code"];
    [param setObject:stockInfo.exchange forKey:@"stock_exchange"];
    [GFRequestManager connectWithDelegate:self action:Get_stock_push_set_info param:param];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    [super requestFinished:request];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    ASIFormDataRequest * formDataRequest = (ASIFormDataRequest *)request;
    if ([formDataRequest.action isEqualToString:Get_stock_push_set_info])
    {
        [self reloadSwitchStatus:[requestInfo objectForKey:@"data"]];
    }
    else if ([formDataRequest.action isEqualToString:Submit_stock_push_set_info])
    {
        [[TKAlertCenter defaultCenter] postAlertWithMessage:@"设置成功" withType:ALERTTYPESUCCESS];
    }
}

- (void)reloadSwitchStatus:(NSDictionary *)dic
{
    if ([[dic objectForKey:@"is_open_remind"] integerValue] == 1)
    {
        isOn = YES;
        stockSwitch.on = YES;
        rangeView.hidden = NO;
    }
    else
    {
        stockSwitch.on = NO;
        rangeView.hidden = YES;
        tipLabel.hidden = YES;
    }
    
    currentPrice.text = [dic objectForKey:@"current_price"];
    updownRange.text = [dic objectForKey:@"updown_range"];
    
    if ([[dic objectForKey:@"daily_rise"] componentsSeparatedByString:@"0"].count > 1)
    {
        upPrice.text = @"点击设置提醒";
        upRange.text = @"";
    }
    else
    {
        upRange.text = [dic objectForKey:@"daily_rise"];
        upPrice.text = [dic objectForKey:@"daily_rise_price"];
    }
    
    if([[dic objectForKey:@"daily_decline"] componentsSeparatedByString:@"0"].count > 1)
    {
        downPrice.text = @"点击设置提醒";
        downRange.text = @"";
    }
    else
    {
        downRange.text = [dic objectForKey:@"daily_decline"];
        downPrice.text = [dic objectForKey:@"daily_decline_price"];
    }
    
    if (upArr.count)
    {
        [upArr removeAllObjects];
    }
    if (downArr.count)
    {
        [downArr removeAllObjects];
    }
    
    upArr = [[dic objectForKey:@"rise_range_select"] mutableCopy];
    downArr = [[dic objectForKey:@"decline_range_select"] mutableCopy];
    
    [pickView reloadAllComponents];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [super requestFailed:request];
}

#pragma pickView delegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return 200;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (upArr.count || downArr.count)
    {
        return upArr.count+1;
    }
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (row == 0)
    {
        return @"不提醒";
    }
    
    NSString * title = @"";
    NSDictionary * dic = [NSDictionary dictionary];
    if (isUp)
    {
        dic = [upArr objectAtIndex:row-1];
    }
    else
    {
        dic = [downArr objectAtIndex:row-1];
    }
    
    NSString * range = [dic objectForKey:@"range"];
    NSString * price = [dic objectForKey:@"price"];
    title = [range stringByAppendingString:[NSString stringWithFormat:@"    %@",price]];
    
    return title;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    selectedIndex = row;
    
    if (row == 0)
    {
        if (isUp)
        {
            upPrice.text = @"点击设置提醒";
            upRange.text = @"";
        }
        else
        {
            downPrice.text = @"点击设置提醒";
            downRange.text = @"";
        }
        return;
    }
    
    if (isUp)
    {
        NSDictionary * dic = [upArr objectAtIndex:row-1];
        upRange.text = [dic objectForKey:@"range"];
        upPrice.text = [dic objectForKey:@"price"];
        upKey = [dic objectForKey:@"key"];
    }
    else
    {
        NSDictionary * dic = [downArr objectAtIndex:row-1];
        downRange.text = [dic objectForKey:@"range"];
        downPrice.text = [dic objectForKey:@"price"];
        downKey = [dic objectForKey:@"key"];
    }
}

- (void)onSwitchClicked:(id)sender
{
    UISwitch * s = (UISwitch *)sender;
    rangeView.hidden = !s.on;
    if (rangeView.hidden)
    {
        [self hidePickerView];
    }
    isOn = s.on;
    if (!isOn)
    {
        [self postNoticeInfo];
    }
    else
    {
        upPrice.text = @"点击设置提醒";
        upRange.text = @"";
        downPrice.text = @"点击设置提醒";
        downRange.text = @"";
    }
}

- (void)postNoticeInfo
{
    NSMutableDictionary * param = [NSMutableDictionary dictionary];
    [param setObject:stockInfo.code forKey:@"stock_code"];
    [param setObject:stockInfo.exchange forKey:@"stock_exchange"];
    
    if (isOn)
    {
        [param setObject:@"1" forKey:@"is_open_remind"];
    }
    else
    {
        [param setObject:@"2" forKey:@"is_open_remind"];
    }
    
    if (isUp)
    {
        if (upKey)
        {
            [param setObject:upKey forKey:@"daily_rise"];
        }
    }
    else
    {
        if (downKey)
        {
            [param setObject:downKey forKey:@"daily_decline"];
        }
    }
    
    [GFRequestManager connectWithDelegate:self action:Submit_stock_push_set_info param:param];
}

- (void)sureBtnClicked:(id)sender
{
    [self postNoticeInfo];
    [self hidePickerView];
}

- (void)cancelBtnClicked:(id)sender
{
    [self hidePickerView];
}

- (void)upBtnClicked:(id)sender
{
    isUp = YES;
    [pickView reloadAllComponents];
    [self showPickerView];
}

- (void)downBtnClicked:(id)sender
{
    isUp = NO;
    [pickView reloadAllComponents];
    [self showPickerView];
}

- (void)showPickerView
{
    if (selectedIndex > 0)
    {
        if (isUp)
        {
            NSDictionary * dic = [upArr objectAtIndex:selectedIndex-1];
            upRange.text = [dic objectForKey:@"range"];
            upPrice.text = [dic objectForKey:@"price"];
            upKey = [dic objectForKey:@"key"];
        }
        else
        {
            NSDictionary * dic = [downArr objectAtIndex:selectedIndex-1];
            downRange.text = [dic objectForKey:@"range"];
            downPrice.text = [dic objectForKey:@"price"];
            downKey = [dic objectForKey:@"key"];
        }
    }
    
    [self.view bringSubviewToFront:pickContainer];
    [UIView beginAnimations:@"Animation" context:nil];
    [UIView setAnimationDuration:.3];
    pickContainer.frame = CGRectMake(0, screenHeight-pickContainer.frame.size.height, screenWidth, pickContainer.frame.size.height);
    [UIView commitAnimations];
}

- (void)hidePickerView
{
    [self.view bringSubviewToFront:pickContainer];
    [UIView beginAnimations:@"Animation" context:nil];
    [UIView setAnimationDuration:.3];
    pickContainer.frame = CGRectMake(0, screenHeight, screenWidth, pickContainer.frame.size.height);
    [UIView commitAnimations];
}

@end
