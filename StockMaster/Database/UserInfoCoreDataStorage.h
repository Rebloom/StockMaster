//
//  UserInfoCoreDataStorage.h
//  StockMaster
//
//  Created by Johnny on 15/4/7.
//  Copyright (c) 2015年 aizhangzhang. All rights reserved.
//

#import "BasicCoreDataStorage.h"
#import "UserInfoEntity.h"
#import "UserAssetEntity.h"
#import "TaskInfoEntity.h"
#import "PropCardEntity.h"
#import "SettingInfoEntity.h"

@interface UserInfoCoreDataStorage : BasicCoreDataStorage

+ (UserInfoCoreDataStorage *)sharedInstance;

#pragma mark - 用户数据
- (void)saveLoginUserInfo:(NSDictionary *)dict;
- (UserInfoEntity *)getCurrentUserInfo;
- (void)currentUserLogout;
- (BOOL)isCurrentUserLogin;
- (BOOL)isFirstUserLogin;

#pragma mark - 用户资产
- (UserAssetEntity *)saveUserAsset:(NSDictionary *)dict;
- (UserAssetEntity *)getUserAsset;

#pragma mark - 任务数据
- (void)saveTaskInfo:(NSArray *)taskArray;
- (NSArray *)getTaskInfo;
- (NSFetchedResultsController *)registerTaskInfoController:(id<NSFetchedResultsControllerDelegate>)controller;

#pragma mark - 道具卡片
- (NSArray *)savePropCard:(NSArray *)cardArray;
- (NSArray *)getPropCard;

#pragma mark - 设置数据
/**
 * 保存设置数据，参数传入key和value，
 * value必须为NSObject的对象，如NSString、NSDictionary、NSArray
 **/
- (void)saveSettingInfoWithKey:(NSString *)key value:(id)value;
/**
 * 通过key得到设置数据，返回值为NSObject的对象，如NSString、NSDictionary、NSArray
 **/
- (id)getSettingInfoWithKey:(NSString *)key;
/**
 * 通过key得到设置数据变量类型，可以通过NSClassFromString得到Class对象
 **/
- (NSString *)getSettingTypeWithKey:(NSString *)key;

@end
