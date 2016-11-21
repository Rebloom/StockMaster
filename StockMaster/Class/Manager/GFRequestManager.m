//
//  GFRequestManager.m
//  StockMaster
//
//  Created by Rebloom on 14-8-7.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "GFRequestManager.h"
#import "CHNMacro.h"
#import "UserInfoCoreDataStorage.h"

static GFRequestManager * gfRequestManager = nil;

@implementation GFRequestManager


+ (GFRequestManager *)instance
{
    return [GFRequestManager shareManager];
}

+ (GFRequestManager *)shareManager
{
    if (gfRequestManager == nil)
    {
        gfRequestManager = [[self alloc] init];
    }
    return gfRequestManager;
}

+ (BOOL)connectWithDelegate:(id)delegate action:(NSString *)action param:(NSDictionary *)param priority:(NSInteger)priority
{
    NSMutableDictionary * postDic = [NSMutableDictionary dictionary];
    NSMutableDictionary * headerDic = [NSMutableDictionary dictionary];
    UserInfoEntity *userInfo = [[UserInfoCoreDataStorage sharedInstance] getCurrentUserInfo];
    if (userInfo != nil)
    {
        [headerDic setObject:userInfo.token forKey:@"token"];
    }
    else
    {
        [headerDic setObject:@"" forKey:@"token"];
    }
    [headerDic setObject:[Utility getDeviceID] forKey:@"device_id"];
    [headerDic setObject:[NSString stringWithFormat:@"%@_%@",[Utility getDeviceType],[Utility getDeviceSystemVersion]] forKey:@"client_type"];
    [headerDic setObject:kTagChannelID forKey:@"channel_no"];
    [headerDic setObject:GFVersion forKey:@"version"];
    [headerDic setObject:@"2" forKey:@"push_id"];
    
    [postDic setObject:headerDic forKey:@"header"];
    [postDic setObject:action forKey:@"action"];
    if (param == nil)
    {
        [postDic setObject:@"" forKey:@"data"];
    }
    else
    {
        [postDic setObject:param forKey:@"data"];
    }
    
    // 包装的请求Json
    if ([NSJSONSerialization isValidJSONObject:postDic])
    {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:postDic options:NSJSONWritingPrettyPrinted error: &error];
        NSMutableData *tempJsonData = [NSMutableData dataWithData:jsonData];
        
        NSURL *url = [NSURL URLWithString:HostAddress];
        
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        [request addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
        [request addRequestHeader:@"Accept" value:@"application/json"];
        [request setRequestMethod:@"POST"];
        [request setPostBody:tempJsonData];
        request.delegate = delegate;
        request.action = action;
        request.priority = priority;
        [request startAsynchronous];
        [[RequestQueue instance].requestList addObject:request];
    }
    return YES;
}

+ (BOOL)connectWithDelegate:(id)delegate action:(NSString *)action param:(NSMutableDictionary *)param
{
    if ([delegate isKindOfClass:[UIViewController class]])
    {
        if ([action isEqualToString:Get_stock_watchlist] ||
            [action isEqualToString:Get_portfolio_home] ||
            [action isEqualToString:Get_buyable_stock_info] ||
            [action isEqualToString:Get_sellable_stock_info] ||
            [action isEqualToString:Get_stock_index_quotation] ||
            [action isEqualToString:Get_index_hot_plate] ||
            [action isEqualToString:Get_stock_rank_list] ||
            [action isEqualToString:Get_plate_list] ||
            [action isEqualToString:Get_realtime_data]||
            [action isEqualToString:Get_user_performance]||
            [action isEqualToString:Get_home_task_status]||
            [action isEqualToString:Get_hot_stock]||
            [action isEqualToString:Get_total_profit_rank]||
            [action isEqualToString:Get_make_money]||
            [action isEqualToString:Get_stock_data]||
            [action isEqualToString:Submit_user_app_push_bind] ||
            [action isEqualToString:Get_index_stock] ||
            [action isEqualToString:Get_user_history_assets] ||
            [action isEqualToString:Get_stock_feeling_reward_num] ||
            [action isEqualToString:Submit_stock_watchlist] ||
            [action isEqualToString:Delete_stock_watchlist] ||
            [action isEqualToString:Get_card_list])
        {
            // 6秒刷新的请求不显示loading
        }
        else if ([action isEqualToString:Submit_use_card])
        {
            UIViewController * vc = (UIViewController *)delegate;
            [MBProgressHUD showHUDAddedTo:vc.view animated:YES withTitle:@"使用中"];
        }
        else if ([action isEqualToString:Submit_buy_card])
        {
            UIViewController * vc = (UIViewController *)delegate;
            [MBProgressHUD showHUDAddedTo:vc.view animated:YES withTitle:@"购买中"];
        }
        else
        {
            UIViewController * vc = (UIViewController *)delegate;
            [MBProgressHUD showHUDAddedTo:vc.view animated:YES];
        }
    }
    
    NSMutableDictionary * postDic = [NSMutableDictionary dictionary];
    NSMutableDictionary * headerDic = [NSMutableDictionary dictionary];
    
    [headerDic setObject:kTagChannelID forKey:@"channel_no"];
    [headerDic setObject:[NSString stringWithFormat:@"%@_%@",[Utility getDeviceType],[Utility getDeviceSystemVersion]] forKey:@"client_type"];
    [headerDic setObject:[Utility getDeviceID] forKey:@"device_id"];
    [headerDic setObject:@"2" forKey:@"push_id"];
    
    UserInfoEntity *userInfo = [[UserInfoCoreDataStorage sharedInstance] getCurrentUserInfo];
    if (userInfo != nil)
    {
        [headerDic setObject:userInfo.token forKey:@"token"];
    }
    else
    {
        [headerDic setObject:@"" forKey:@"token"];
    }
    [headerDic setObject:GFVersion forKey:@"version"];
    
    if (userInfo != nil)
    {
        [param setObject:userInfo.uid forKey:@"uid"];
    }
    else
    {
        [param setObject:@"0"  forKey:@"uid"];
    }
    
    if ([kTagPackageID integerValue])
    {
        [param setObject:kTagPackageID forKey:@"package_id"];
    }
    else
    {
        [param setObject:@"0" forKey:@"package_id"];
    }
    
    [postDic setObject:action forKey:@"action"];
    
    if (param == nil)
    {
        NSMutableDictionary * p = [NSMutableDictionary dictionary];
        [p setObject:@"0" forKey:@"uid"];
        [postDic setObject:p forKey:@"data"];
    }
    else
    {
        [postDic setObject:param forKey:@"data"];
    }
    
    [postDic setObject:headerDic forKey:@"header"];
    [headerDic setObject:[Utility dictionaryDataToSignString:postDic] forKey:@"sign"];
    [postDic setObject:headerDic forKey:@"header"];
    // 包装的请求Json
    if ([NSJSONSerialization isValidJSONObject:postDic])
    {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:postDic options:NSJSONWritingPrettyPrinted error: &error];
        
        NSString * jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSString * encryptorString = [Secret AES128Encrypt:jsonString];
        
        NSData* postData = [[encryptorString stringByReversed] dataUsingEncoding:NSUTF8StringEncoding];
        NSMutableData * mPostData = [NSMutableData dataWithData:postData];
        
        NSURL *url = [NSURL URLWithString:HostAddress];
        
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        [request addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
        [request addRequestHeader:@"Accept" value:@"application/json"];
        [request setRequestMethod:@"POST"];
        [request setPostBody:mPostData];
        [request setCachePolicy:ASIDoNotReadFromCacheCachePolicy];
        request.delegate = delegate;
        request.action = action;
        [request startAsynchronous];
        [[RequestQueue instance].requestList addObject:request];
    }
    return YES;
}

+ (BOOL)uploadImageWithDelegate:(id)delegate action:(NSString *)action imageParam:(NSDictionary *)imageParam
{
    NSURL *url = [NSURL URLWithString:HostAddress];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    [request setRequestMethod:@"POST"];
    NSString * photoPath = [imageParam objectForKey:@"photoPath"];
    [request addFile:photoPath forKey:@"photo.jpeg"];
    return YES;
}

@end
