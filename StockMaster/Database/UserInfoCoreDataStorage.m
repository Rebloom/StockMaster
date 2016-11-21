//
//  UserInfoCoreDataStorage.m
//  StockMaster
//
//  Created by Johnny on 15/4/7.
//  Copyright (c) 2015年 aizhangzhang. All rights reserved.
//

#import "UserInfoCoreDataStorage.h"
#import "GFStaticData.h"

@implementation UserInfoCoreDataStorage

static UserInfoCoreDataStorage *sharedInstance;

#define GET_DICT_STRING_VALUE(dict, key, param) \
    if ([dict objectForKey:key] != nil) { \
        param = [dict objectForKey:key]; \
    } \

#define GET_DICT_INTEGER_VALUE(dict, key, param) \
    if ([dict objectForKey:key] != nil) { \
        param = [[dict objectForKey:key] integerValue]; \
    } \

#define GET_DICT_DOUBLE_VALUE(dict, key, param) \
    if ([dict objectForKey:key] != nil) { \
        param = [[dict objectForKey:key] doubleValue]; \
} \


+ (UserInfoCoreDataStorage *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[UserInfoCoreDataStorage alloc] initWithDatabaseFilename:nil storeOptions:nil];
    });
    
    return sharedInstance;
}

#pragma mark - Setup
- (NSString *)persistentStoreDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *result = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:result]) {
        [fileManager createDirectoryAtPath:result withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return result;
}

- (void)commonInit
{
    [super commonInit];
    
    // This method is invoked by all public init methods of the superclass
    autoRemovePreviousDatabaseFile = NO;
    autoRecreateDatabaseFile = YES;
}

#pragma mark - Utilities
- (NSArray *)fetchRequest:(NSEntityDescription *)entity
                predicate:(NSPredicate *)predicate
                  context:(NSManagedObjectContext *)moc
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    return [moc executeFetchRequest:fetchRequest error:nil];
}

- (NSArray *)fetchRequest:(NSEntityDescription *)entity
                predicate:(NSPredicate *)predicate
                     sort:(NSArray *)sort
                  context:(NSManagedObjectContext *)moc
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:sort];
    return [moc executeFetchRequest:fetchRequest error:nil];
}

- (NSInteger)countRequest:(NSEntityDescription *)entity
                predicate:(NSPredicate *)predicate
                  context:(NSManagedObjectContext *)moc
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    return [moc countForFetchRequest:fetchRequest error:nil];
}

- (NSFetchedResultsController *)registerFetchedResultsController:(NSEntityDescription *)entity
                                                       predicate:(NSPredicate *)predicate
                                                  sortDescriptor:(NSArray *)sortDescriptor
                                                      controller:(id<NSFetchedResultsControllerDelegate>)controller
{
    NSManagedObjectContext *moc = self.mainThreadManagedObjectContext;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:sortDescriptor];
    [fetchRequest setFetchBatchSize:20];
    
    NSFetchedResultsController *fetchedResultsController = nil;
    fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                   managedObjectContext:moc
                                                                     sectionNameKeyPath:nil
                                                                              cacheName:nil];
    fetchedResultsController.delegate = controller;
    return fetchedResultsController;
}

#pragma mark - Public API
#pragma mark - 用户数据
- (void)saveLoginUserInfo:(NSDictionary *)dict
{
    if (nil == dict) {
        return;
    }
    
    [self executeBlock:^(NSManagedObjectContext *moc) {
        [self _saveUserInfo:dict context:moc];
    }];
}

- (UserInfoEntity *)getCurrentUserInfo
{
    __block UserInfoEntity *userInfo = nil;
    [self executeBlock:^(NSManagedObjectContext *moc) {
        userInfo = [self _getCurrentUserInfo:moc];
        if (nil == userInfo) {
            NSString *uid = [GFStaticData getObjectForKey:@"uid"];
            if (uid != nil) {
                userInfo = [UserInfoEntity insertInManagedObjectContext:moc];
                userInfo.uid = uid;
                userInfo.mobile = [GFStaticData getObjectForKey:@"mobile"];
                userInfo.nickname = [GFStaticData getObjectForKey:@"nickname"];
                userInfo.token = [GFStaticData getObjectForKey:@"token"];
                userInfo.head = [GFStaticData getObjectForKey:@"head"];
                userInfo.signature = [GFStaticData getObjectForKey:@"signature"];
                userInfo.updateTime = [NSDate date];
            }
        }
        
        if (nil == userInfo.uid) {
            userInfo.uid = @"";
        }
        if (nil == userInfo.nickname) {
            userInfo.nickname = @"";
        }
        if (nil == userInfo.mobile) {
            userInfo.mobile = @"";
        }
        if (nil == userInfo.head) {
            userInfo.head = @"";
        }
        if (nil == userInfo.signature) {
            userInfo.signature = @"";
        }
        if (nil == userInfo.token) {
            userInfo.token = @"";
        }
    }];
    return userInfo;
}

- (void)currentUserLogout
{
    [self executeBlock:^(NSManagedObjectContext *moc) {
        UserInfoEntity *userInfo = [self _getCurrentUserInfo:moc];
        if (userInfo != nil) {
            userInfo.token = @"";
        }
    }];
}

- (BOOL)isCurrentUserLogin
{
    BOOL isLogin = NO;
    UserInfoEntity *userInfo = [self getCurrentUserInfo];
    if (userInfo != nil && userInfo.token.length > 0) {
        isLogin = YES;
    }
    return isLogin;
}

- (BOOL)isFirstUserLogin
{
    BOOL isFirst = NO;
    UserInfoEntity *userInfo = [self getCurrentUserInfo];
    if (nil == userInfo) {
        isFirst = YES;
    }
    return isFirst;
}

#pragma mark - 用户资产
- (UserAssetEntity *)saveUserAsset:(NSDictionary *)dict
{
    UserInfoEntity *userInfo = [self getCurrentUserInfo];
    __block UserAssetEntity *userAsset = nil;
    [self executeBlock:^(NSManagedObjectContext *moc) {
        if (userInfo != nil) {
            userAsset = [self _saveUserAsset:dict uid:userInfo.uid context:moc];
        }
    }];
    return userAsset;
}

- (UserAssetEntity *)getUserAsset
{
    UserInfoEntity *userInfo = [self getCurrentUserInfo];
    __block UserAssetEntity *userAsset = nil;
    [self executeBlock:^(NSManagedObjectContext *moc) {
        if (userInfo != nil) {
            userAsset = [self _getUserAsset:userInfo.uid context:moc];
        }
    }];
    return userAsset;
}


#pragma mark - 任务数据
- (void)saveTaskInfo:(NSArray *)taskArray
{
    [self executeBlock:^(NSManagedObjectContext *moc) {
        [self _clearTaskInfo:moc];
        for (NSDictionary *taskInfo in taskArray) {
            [self _saveTaskInfo:taskInfo context:moc];
        }
    }];
}

- (NSArray *)getTaskInfo
{
    __block NSArray *result = nil;
    [self executeBlock:^(NSManagedObjectContext *moc) {
        NSEntityDescription *entity = [TaskInfoEntity entityInManagedObjectContext:moc];
        NSSortDescriptor *timeDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"updateTime" ascending:YES];
        NSArray *sortDescriptor = @[timeDescriptor];
        result = [self fetchRequest:entity predicate:nil sort:sortDescriptor context:moc];
    }];
    return result;
}

- (NSFetchedResultsController *)registerTaskInfoController:(id<NSFetchedResultsControllerDelegate>)controller
{
    return nil;
}

#pragma mark - 道具卡片
- (NSArray *)savePropCard:(NSArray *)cardArray
{
    __block NSMutableArray *resultArray = [NSMutableArray array];
    [self executeBlock:^(NSManagedObjectContext *moc) {
        [self _clearPropCard:moc];
        for (NSDictionary *cardDict in cardArray) {
            PropCardEntity *propCard = [self _savePropCard:cardDict context:moc];
            [resultArray addObject:propCard];
        }
    }];
    
    return resultArray;
}

- (NSArray *)getPropCard
{
    __block NSArray *result = nil;
    [self executeBlock:^(NSManagedObjectContext *moc) {
        NSEntityDescription *entity = [PropCardEntity entityInManagedObjectContext:moc];
        UserInfoEntity *userInfo = [[UserInfoCoreDataStorage sharedInstance] getCurrentUserInfo];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid == %@", userInfo.uid];
        NSSortDescriptor *timeDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"updateTime" ascending:YES];
        NSArray *sortDescriptor = @[timeDescriptor];
        result = [self fetchRequest:entity predicate:predicate sort:sortDescriptor context:moc];
    }];
    return result;
}

#pragma mark - 设置数据
- (void)saveSettingInfoWithKey:(NSString *)key value:(id)value
{
    if (nil == key) {
        NSParameterAssert(key);
        return;
    }
    
    UserInfoEntity *userInfo = [self getCurrentUserInfo];
    [self executeBlock:^(NSManagedObjectContext *moc) {
        SettingInfoEntity *setting = [self _getSettingInfo:key context:moc];
        if (nil == setting) {
            setting = [SettingInfoEntity insertInManagedObjectContext:moc];
        }
        
        // 将数据转成NSData进行保存
        NSMutableData *data = [NSMutableData data];
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
        [archiver encodeObject:value forKey:@""];
        [archiver finishEncoding];
        
        NSString *uid = @""; // uid为空时为全局变量
        if (userInfo != nil) {
            uid = userInfo.uid;
        }
        setting.uid = uid;
        setting.key = key;
        setting.type = NSStringFromClass([value class]);
        setting.data = data;
    }];
}

- (id)getSettingInfoWithKey:(NSString *)key
{
    __block id value = nil;
    [self executeBlock:^(NSManagedObjectContext *moc) {
        SettingInfoEntity *setting = [self _getSettingInfo:key context:moc];
        if (setting != nil) {
            NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:setting.data];
            value = [unarchiver decodeObjectForKey:@""];
            [unarchiver finishDecoding];
        }
    }];
    return value;
}

- (NSString *)getSettingTypeWithKey:(NSString *)key
{
    __block NSString *type = nil;
    [self executeBlock:^(NSManagedObjectContext *moc) {
        SettingInfoEntity *setting = [self _getSettingInfo:key context:moc];
        if (setting != nil) {
            type = setting.type;
        }
    }];
    return type;
}

#pragma mark - Protocol Private API
- (void)_saveUserInfo:(NSDictionary *)dict context:(NSManagedObjectContext *)moc
{
    NSString *uid = [dict objectForKey:@"uid"];
    if (nil == uid) {
        return;
    }
    
    UserInfoEntity *userInfo = [self _getUserInfo:uid context:moc];
    UserInfoEntity *lastUserInfo = [self getCurrentUserInfo];
    if (nil == userInfo) {
        userInfo = [UserInfoEntity insertInManagedObjectContext:moc];
    }

    // 解析赋值，不为nil则赋值
    GET_DICT_STRING_VALUE(dict, @"uid", userInfo.uid)
    GET_DICT_STRING_VALUE(dict, @"head", userInfo.head)
    GET_DICT_STRING_VALUE(dict, @"mobile", userInfo.mobile)
    GET_DICT_STRING_VALUE(dict, @"nickname", userInfo.nickname)
    GET_DICT_STRING_VALUE(dict, @"signature", userInfo.signature)
    GET_DICT_STRING_VALUE(dict, @"token", userInfo.token)
    userInfo.updateTime = [NSDate date];
    
    if (nil == userInfo.uid) {
        userInfo.uid = @"";
    }
    if (nil == userInfo.nickname) {
        userInfo.nickname = @"";
    }
    if (nil == userInfo.mobile) {
        userInfo.mobile = @"";
    }
    if (nil == userInfo.head) {
        userInfo.head = @"";
    }
    if (nil == userInfo.signature) {
        userInfo.signature = @"";
    }
    if (nil == userInfo.token) {
        userInfo.token = @"";
    }
    
    // 修改本地时间导致的错误进行纠正
    if ([userInfo.updateTime compare:lastUserInfo.updateTime] == NSOrderedAscending) {
        userInfo.updateTime = [lastUserInfo.updateTime dateByAddingTimeInterval:1];
    }
}

- (UserAssetEntity *)_saveUserAsset:(NSDictionary *)dict uid:(NSString *)uid context:(NSManagedObjectContext *)moc
{
    if (nil == dict) {
        return nil;
    }
    
    UserAssetEntity *userAsset = [self _getUserAsset:uid context:moc];
    if (nil == userAsset) {
        userAsset = [UserAssetEntity insertInManagedObjectContext:moc];
        userAsset.uid = uid;
    }
    
    // 解析赋值，不为nil则赋值
    GET_DICT_STRING_VALUE(dict, @"total_assets", userAsset.totalAsset)
    GET_DICT_STRING_VALUE(dict, @"base_money", userAsset.initbaseMoney)
    GET_DICT_STRING_VALUE(dict, @"init_base_money", userAsset.initbaseMoney)
    GET_DICT_STRING_VALUE(dict, @"usable_money", userAsset.usableMoney)
    GET_DICT_STRING_VALUE(dict, @"profit_money", userAsset.profitMoney)
    GET_DICT_STRING_VALUE(dict, @"position_money", userAsset.positionMoney)
    GET_DICT_STRING_VALUE(dict, @"withdraw_money", userAsset.withdrawMoney)
    GET_DICT_STRING_VALUE(dict, @"usable_withdraw_money", userAsset.withdrawMoney)
    
    return userAsset;
}

- (UserInfoEntity *)_getUserInfo:(NSString *)uid context:(NSManagedObjectContext *)moc
{
    NSEntityDescription *entity = [UserInfoEntity entityInManagedObjectContext:moc];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid == %@", uid];
    NSArray *result = [self fetchRequest:entity predicate:predicate context:moc];
    return result.firstObject;
}

- (UserInfoEntity *)_getCurrentUserInfo:(NSManagedObjectContext *)moc
{
    NSEntityDescription *entity = [UserInfoEntity entityInManagedObjectContext:moc];
    NSSortDescriptor *timeDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"updateTime" ascending:NO];
    NSArray *sortDescriptor = @[timeDescriptor];
    NSArray *result = [self fetchRequest:entity predicate:nil sort:sortDescriptor context:moc];
    return result.firstObject;
}

- (UserAssetEntity *)_getUserAsset:(NSString *)uid context:(NSManagedObjectContext *)moc
{
    NSEntityDescription *entity = [UserAssetEntity entityInManagedObjectContext:moc];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid == %@", uid];
    NSArray *result = [self fetchRequest:entity predicate:predicate context:moc];
    return result.firstObject;
}

- (void)_saveTaskInfo:(NSDictionary *)dict context:(NSManagedObjectContext *)moc
{
    NSString *taskID = [dict objectForKey:@"task_id"];
    if (nil == taskID) {
        return;
    }
    
    TaskInfoEntity *taskInfo = [self _getTaskInfo:taskID context:moc];
    if (nil == taskInfo) {
        taskInfo = [TaskInfoEntity insertInManagedObjectContext:moc];
    }
    
    // 解析赋值，不为nil则赋值
    GET_DICT_STRING_VALUE(dict, @"task_id", taskInfo.taskID)
    GET_DICT_STRING_VALUE(dict, @"log_id", taskInfo.logID)
    GET_DICT_STRING_VALUE(dict, @"task_name", taskInfo.name)
    GET_DICT_STRING_VALUE(dict, @"task_description", taskInfo.describe)
    GET_DICT_STRING_VALUE(dict, @"reward_money", taskInfo.money)
    GET_DICT_STRING_VALUE(dict, @"button_text", taskInfo.buttonText)
    GET_DICT_INTEGER_VALUE(dict, @"task_status", taskInfo.status)
    GET_DICT_STRING_VALUE(dict, @"task_icon_url", taskInfo.taskIcon)
    GET_DICT_STRING_VALUE(dict, @"task_h5_title", taskInfo.h5Title)
    GET_DICT_STRING_VALUE(dict, @"url_h5", taskInfo.h5Url)
    GET_DICT_STRING_VALUE(dict, @"url_h5_task", taskInfo.h5Task)

    taskInfo.updateTime = [NSDate date];
}

- (TaskInfoEntity *)_getTaskInfo:(NSString *)taskID context:(NSManagedObjectContext *)moc
{
    NSEntityDescription *entity = [TaskInfoEntity entityInManagedObjectContext:moc];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"taskID == %@", taskID];
    NSArray *result = [self fetchRequest:entity predicate:predicate context:moc];
    return result.firstObject;
}

- (void)_clearTaskInfo:(NSManagedObjectContext *)moc
{
    NSEntityDescription *entity = [TaskInfoEntity entityInManagedObjectContext:moc];
    NSArray *result = [self fetchRequest:entity predicate:nil context:moc];
    for (TaskInfoEntity *taskInfo in result) {
        [moc deleteObject:taskInfo];
    }
}

- (PropCardEntity *)_savePropCard:(NSDictionary *)dict context:(NSManagedObjectContext *)moc
{
    NSString *cardID = [dict objectForKey:@"card_id"];
    if (nil == cardID) {
        return nil;
    }
    
    PropCardEntity *propCard = [self _getPropCard:cardID context:moc];
    if (nil == propCard) {
        propCard = [PropCardEntity insertInManagedObjectContext:moc];
    }
    
    UserInfoEntity *userInfo = [[UserInfoCoreDataStorage sharedInstance] getCurrentUserInfo];
    propCard.uid = userInfo.uid;
    
    // 解析赋值，不为nil则赋值
    GET_DICT_STRING_VALUE(dict, @"card_id", propCard.cardID)
    GET_DICT_STRING_VALUE(dict, @"card_name", propCard.name)
    GET_DICT_STRING_VALUE(dict, @"card_num", propCard.num)
    GET_DICT_STRING_VALUE(dict, @"img", propCard.image)
    GET_DICT_STRING_VALUE(dict, @"desc", propCard.desc)
    GET_DICT_INTEGER_VALUE(dict, @"status", propCard.status)
    GET_DICT_STRING_VALUE(dict, @"button_desc", propCard.buttonDesc)
    GET_DICT_INTEGER_VALUE(dict, @"if_duration", propCard.isDuration)
    GET_DICT_STRING_VALUE(dict, @"expire_time", propCard.expireTime)
    GET_DICT_INTEGER_VALUE(dict, @"if_system_give", propCard.isSystemGive)
    GET_DICT_STRING_VALUE(dict, @"system_give_desc", propCard.systemGiveDesc)
    GET_DICT_STRING_VALUE(dict, @"buy_desc", propCard.buyDesc)
    GET_DICT_STRING_VALUE(dict, @"old_price", propCard.oldPrice)
    GET_DICT_STRING_VALUE(dict, @"new_price", propCard.currentPrice)

    propCard.updateTime = [NSDate date];
    
    return propCard;
}

- (PropCardEntity *)_getPropCard:(NSString *)cardID context:(NSManagedObjectContext *)moc
{
    NSEntityDescription *entity = [PropCardEntity entityInManagedObjectContext:moc];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"cardID == %@", cardID];
    NSArray *result = [self fetchRequest:entity predicate:predicate context:moc];
    return result.firstObject;
}

- (void)_clearPropCard:(NSManagedObjectContext *)moc
{
    NSEntityDescription *entity = [PropCardEntity entityInManagedObjectContext:moc];
    NSArray *result = [self fetchRequest:entity predicate:nil context:moc];
    for (PropCardEntity *propCard in result) {
        [moc deleteObject:propCard];
    }
}

- (SettingInfoEntity *)_getSettingInfo:(NSString *)key context:(NSManagedObjectContext *)moc
{
    NSEntityDescription *entity = [SettingInfoEntity entityInManagedObjectContext:moc];
    UserInfoEntity *userInfo = [self _getCurrentUserInfo:moc];
    // uid为空时为全局变量
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"key == %@ AND (uid == %@ OR uid == '')", key, userInfo.uid];
    NSArray *result = [self fetchRequest:entity predicate:predicate context:moc];
    return result.firstObject;
}

@end
