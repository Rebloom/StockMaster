//
//  ShareManager.h
//  StockMaster
//
//  Created by dalikeji on 15/2/9.
//  Copyright (c) 2015年 Rebloom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXApi.h"
#import "WeiboSDK.h"

#import <TencentOpenAPI/QQApiInterfaceObject.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>

typedef enum SHAREQQ
{
    SHARETOQQ = 0,
    SHARETOQZONE ,
}_SHAREQQ;

@interface ShareManager : NSObject 

+ (ShareManager *)defaultShareManager;

- (void)sendTencentWithType:(NSInteger)type WithUid:(NSString *)uid;
- (void)sendTencentWithUrl:(NSURL*)share_url WithDesc:(NSString*)share_desc WithType:(NSInteger)type;

- (void)sendWXWithType:(int)type WithUid:(NSString *)uid;
- (void)sendWXWithUrl:(NSURL*)share_url WithDesc:(NSString*)share_desc WithType:(int)type;
//- (void)sendSina;


@end
