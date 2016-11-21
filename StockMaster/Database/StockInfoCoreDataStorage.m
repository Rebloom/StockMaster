//
//  StockInfoCoreDataStorage.m
//  StockMaster
//
//  Created by Johnny on 15/4/7.
//  Copyright (c) 2015年 aizhangzhang. All rights reserved.
//

#import "StockInfoCoreDataStorage.h"
#import "UserInfoCoreDataStorage.h"

@implementation StockInfoCoreDataStorage

static StockInfoCoreDataStorage *sharedInstance;

#define GET_DICT_STRING_VALUE(dict, key, param) \
    if ([dict objectForKey:key] != nil) { \
        param = [[dict objectForKey:key] description]; \
    } \

#define GET_DICT_INTEGER_VALUE(dict, key, param) \
    if ([dict objectForKey:key] != nil) { \
        param = [[dict objectForKey:key] integerValue]; \
    } \

#define GET_DICT_DOUBLE_VALUE(dict, key, param) \
    if ([dict objectForKey:key] != nil) { \
        param = [[dict objectForKey:key] doubleValue]; \
} \

+ (StockInfoCoreDataStorage *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[StockInfoCoreDataStorage alloc] initWithDatabaseFilename:nil storeOptions:nil];
    });
    
    return sharedInstance;
}

#pragma mark - Setup
- (NSString *)persistentStoreDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *result = (paths.count > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    
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
    
    [self initDatabase];
}

- (void)initDatabase
{
    NSString *dirPath = [self persistentStoreDirectory];
    NSString *storePath = [dirPath stringByAppendingPathComponent:@"StockInfo.db"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:storePath]) {
        NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
        NSString *defaultPath = [bundlePath stringByAppendingPathComponent:@"StockInfo.db"];
        NSError *error = nil;
        BOOL success = [fileManager copyItemAtPath:defaultPath toPath:storePath error:&error];
        if (!success) {
            NSLog(@"error = %@", error);
        }
    }
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
#pragma mark - 股票数据
- (void)saveStockInfo:(NSArray *)stockArray
{
    if (stockArray.count == 0) {
        return;
    }
    
    [self scheduleBlock:^(NSManagedObjectContext *moc) {
        // 得到上次保存更新时间戳
        NSString *lastTime = @"0";
        VersionInfoEntity *versionInfo = [self _getVersionInfo:moc];
        if (versionInfo != nil) {
            lastTime = versionInfo.stockInfoVersion;
        }
        
        for (NSDictionary *stockDict in stockArray) {
            [self _saveStockInfo:stockDict context:moc];
            // 得到最新更新时间戳
            NSString *updateTime = [stockDict valueForKey:@"update_time"];
            if ([updateTime doubleValue] > [lastTime doubleValue]) {
                lastTime = updateTime;
            }
        }
        // 保存股票信息版本（或叫更新时间戳）
        [self _saveStockInfoUpdateTime:lastTime context:moc];
    }];
}

- (StockInfoEntity *)getStockInfoWithCode:(NSString *)code exchange:(NSString *)exchange
{
    if (nil == code || nil == exchange) {
        NSParameterAssert(code);
        NSParameterAssert(exchange);
        return nil;
    }
    
    __block StockInfoEntity *stockInfo = nil;
    [self executeBlock:^(NSManagedObjectContext *moc) {
        stockInfo = [self _getStockInfoWithCode:code exchange:exchange context:moc];
    }];
    return stockInfo;
}

- (NSArray *)searchStockInfo:(NSString *)search
{
    __block NSArray *stockArray = [[NSMutableArray alloc] init];
    if (search.length == 0) {
        return stockArray;
    }
    [self executeBlock:^(NSManagedObjectContext *moc) {
        NSEntityDescription *entity = [StockInfoEntity entityInManagedObjectContext:moc];
        NSString *match = [NSString stringWithFormat:@"%@*", search];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"delisted != 1 AND (code LIKE[cd] %@ OR name LIKE[cd] %@ OR jianpin LIKE[cd] %@)", match, match, match];
        NSSortDescriptor *codeDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"code" ascending:YES];
        NSArray *sortDescriptor = @[codeDescriptor];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setPredicate:predicate];
        [fetchRequest setSortDescriptors:sortDescriptor];
        [fetchRequest setFetchLimit:20]; // 设置最大返回条数
        stockArray = [moc executeFetchRequest:fetchRequest error:nil];
    }];
    return stockArray;
}

- (void)saveHotStock:(NSArray *)stockArray
{
    [self executeBlock:^(NSManagedObjectContext *moc) {
        [self _clearHotStock:moc];
        for (NSDictionary *stockDict in stockArray) {
            [self _saveHotStock:stockDict context:moc];
        }
    }];
}

- (NSArray *)getHotStock
{
    __block NSArray *result = nil;
    [self executeBlock:^(NSManagedObjectContext *moc) {
        NSEntityDescription *entity = [HotStockEntity entityInManagedObjectContext:moc];
        NSSortDescriptor *timeDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"updateTime" ascending:YES];
        NSArray *sortDescriptor = @[timeDescriptor];
        result = [self fetchRequest:entity predicate:nil sort:sortDescriptor context:moc];
    }];
    return result;
}

- (NSFetchedResultsController *)registerHotStockController:(id<NSFetchedResultsControllerDelegate>)controller
{
    NSManagedObjectContext *moc = self.mainThreadManagedObjectContext;
    NSFetchedResultsController *fetchedResultsController = nil;
    NSEntityDescription *entity = [HotStockEntity entityInManagedObjectContext:moc];
    NSSortDescriptor *timeDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"updateTime" ascending:YES];
    NSArray *sortDescriptor = @[timeDescriptor];
    fetchedResultsController = [self registerFetchedResultsController:entity
                                                            predicate:nil
                                                       sortDescriptor:sortDescriptor
                                                           controller:controller];
    return fetchedResultsController;
}

#pragma mark -
- (void)saveHoldStockWithLong:(NSArray *)longArray andShort:(NSArray *)shortArray
{
    [self executeBlock:^(NSManagedObjectContext *moc) {
        [self _clearHoldStock:moc];
        
        for (NSDictionary *stockDict in longArray) {
            [self _saveHoldStock:stockDict type:StockHoldTypeLong context:moc];
        }
        
        for (NSDictionary *stockDict in shortArray) {
            [self _saveHoldStock:stockDict type:StockHoldTypeShort context:moc];
        }
    }];
}

- (NSArray *)getHoldStockWithType:(StockHoldType)type
{
    __block NSArray *result = nil;
    [self executeBlock:^(NSManagedObjectContext *moc) {
        NSEntityDescription *entity = [HoldStockEntity entityInManagedObjectContext:moc];
        UserInfoEntity *userInfo = [[UserInfoCoreDataStorage sharedInstance] getCurrentUserInfo];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid == %@ AND holdType = %d",
                                  userInfo.uid, type];
        NSSortDescriptor *timeDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"updateTime" ascending:YES];
        NSArray *sortDescriptor = @[timeDescriptor];
        result = [self fetchRequest:entity predicate:predicate sort:sortDescriptor context:moc];
    }];
    return result;
}

- (NSFetchedResultsController *)registerHoldStockController:(id<NSFetchedResultsControllerDelegate>)controller
{
    NSFetchedResultsController *fetchedResultsController = nil;
    NSManagedObjectContext *moc = self.mainThreadManagedObjectContext;
    NSEntityDescription *entity = [HoldStockEntity entityInManagedObjectContext:moc];
    NSSortDescriptor *timeDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"updateTime" ascending:YES];
    NSArray *sortDescriptor = @[timeDescriptor];
    fetchedResultsController = [self registerFetchedResultsController:entity
                                                            predicate:nil
                                                       sortDescriptor:sortDescriptor
                                                           controller:controller];
    return fetchedResultsController;
}

#pragma mark -
- (void)saveSelectStock:(NSArray *)stockArray
{
    [self executeBlock:^(NSManagedObjectContext *moc) {
        [self _clearSelectStock:moc];
        for (NSDictionary *stockDict in stockArray) {
            [self _saveSelectStock:stockDict context:moc];
        }
    }];
}

- (void)addSelectStockWithCode:(NSString *)code exchange:(NSString *)exchange
{
    if (nil == code || nil == exchange) {
        NSParameterAssert(code);
        NSParameterAssert(exchange);
        return;
    }
    
    [self executeBlock:^(NSManagedObjectContext *moc) {
        SelectStockEntity *selectStock = [self _getSelectStockWithCode:code exchange:exchange context:moc];
        if (selectStock != nil) {
            return;
        }
        
        StockInfoEntity *stockInfo = [self _getStockInfoWithCode:code exchange:exchange context:moc];
        if (nil == stockInfo) {
            return;
        }
        selectStock = [SelectStockEntity insertInManagedObjectContext:moc];
        UserInfoEntity *userInfo = [[UserInfoCoreDataStorage sharedInstance] getCurrentUserInfo];
        selectStock.uid = userInfo.uid;
        selectStock.stockInfo = stockInfo;
        selectStock.createTime = [[NSDate date] timeIntervalSinceNow];
    }];
}

- (void)delSelectStockWithCode:(NSString *)code exchange:(NSString *)exchange
{
    if (nil == code || nil == exchange) {
        NSParameterAssert(code);
        NSParameterAssert(exchange);
        return;
    }
    
    [self executeBlock:^(NSManagedObjectContext *moc) {
        SelectStockEntity *selectStock = [self _getSelectStockWithCode:code exchange:exchange context:moc];
        if (selectStock != nil) {
            [moc deleteObject:selectStock];
        }
    }];
}

- (NSArray *)getSelectStock
{
    __block NSArray *result = nil;
    [self executeBlock:^(NSManagedObjectContext *moc) {
        NSEntityDescription *entity = [SelectStockEntity entityInManagedObjectContext:moc];
        UserInfoEntity *userInfo = [[UserInfoCoreDataStorage sharedInstance] getCurrentUserInfo];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid == %@", userInfo.uid];
        NSSortDescriptor *timeDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"createTime" ascending:NO];
        NSArray *sortDescriptor = @[timeDescriptor];
        result = [self fetchRequest:entity predicate:predicate sort:sortDescriptor context:moc];
    }];
    return result;
}

- (BOOL)isSelectStockWithCode:(NSString *)code exchange:(NSString *)exchange
{
    if (nil == code || nil == exchange) {
        NSParameterAssert(code);
        NSParameterAssert(exchange);
        return NO;
    }
    
    __block BOOL result = NO;
    [self executeBlock:^(NSManagedObjectContext *moc) {
        SelectStockEntity *selectStock = [self _getSelectStockWithCode:code exchange:exchange context:moc];
        if (selectStock != nil) {
            result = YES;
        }
    }];
    return result;
}

- (NSFetchedResultsController *)registerSelectStockController:(id<NSFetchedResultsControllerDelegate>)controller
{
    NSFetchedResultsController *fetchedResultsController = nil;
    NSManagedObjectContext *moc = self.mainThreadManagedObjectContext;
    NSEntityDescription *entity = [SelectStockEntity entityInManagedObjectContext:moc];
    NSSortDescriptor *timeDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"createTime" ascending:NO];
    NSArray *sortDescriptor = @[timeDescriptor];
    fetchedResultsController = [self registerFetchedResultsController:entity
                                                            predicate:nil
                                                       sortDescriptor:sortDescriptor
                                                           controller:controller];
    return fetchedResultsController;
}

#pragma mark -
- (RealtimeDataEntity *)saveStockRealtimeData:(NSDictionary *)dataDict
{
    if (dataDict == nil) {
        return nil;
    }
    
    __block RealtimeDataEntity *realtimeData = nil;
    [self executeBlock:^(NSManagedObjectContext *moc) {
        realtimeData = [self _saveStockRealtimeData:dataDict context:moc];
    }];
    return realtimeData;
}

- (RealtimeDataEntity *)getStockRealtimeDataWithCode:(NSString *)code exchange:(NSString *)exchange
{
    if (nil == code || nil == exchange) {
        NSParameterAssert(code);
        NSParameterAssert(exchange);
        return nil;
    }
    
    __block RealtimeDataEntity *realtimeData = nil;
    [self executeBlock:^(NSManagedObjectContext *moc) {
        realtimeData = [self _getStockRealtimeDataWithCode:code exchange:exchange context:moc];
    }];
    
    return realtimeData;
}

- (void)addStockRealtimeDataSelectedWithCode:(NSString *)code exchange:(NSString *)exchange
{
    if (nil == code || nil == exchange) {
        NSParameterAssert(code);
        NSParameterAssert(exchange);
    }
    
    [self executeBlock:^(NSManagedObjectContext *moc) {
        RealtimeDataEntity *realtimeData = [self _getStockRealtimeDataWithCode:code exchange:exchange context:moc];
        if (realtimeData != nil) {
            realtimeData.isSelected = 1;
        }
    }];
}

- (void)delStockRealtimeDataSelectedWithCode:(NSString *)code exchange:(NSString *)exchange
{
    if (nil == code || nil == exchange) {
        NSParameterAssert(code);
        NSParameterAssert(exchange);
    }
    
    [self executeBlock:^(NSManagedObjectContext *moc) {
        RealtimeDataEntity *realtimeData = [self _getStockRealtimeDataWithCode:code exchange:exchange context:moc];
        if (realtimeData != nil) {
            realtimeData.isSelected = 0;
        }
    }];
}

#pragma mark -
- (StockGradeEntity *)saveStockGrade:(NSDictionary *)gradeDict
{
    if (gradeDict == nil) {
        return nil;
    }
    
    __block StockGradeEntity *stockGrade = nil;
    [self executeBlock:^(NSManagedObjectContext *moc) {
        stockGrade = [self _saveStockGrade:gradeDict context:moc];
    }];
    return stockGrade;
}

- (StockGradeEntity *)getStockGradeWithCode:(NSString *)code exchange:(NSString *)exchange;
{
    if (nil == code || nil == exchange) {
        NSParameterAssert(code);
        NSParameterAssert(exchange);
        return nil;
    }
    
    __block StockGradeEntity *stockGrade = nil;
    [self executeBlock:^(NSManagedObjectContext *moc) {
        stockGrade = [self _getStockGradeWithCode:code exchange:exchange context:moc];
    }];
    return stockGrade;
}

#pragma mark -
- (NSArray *)saveStockMinuteLine:(NSArray *)lineArray code:(NSString *)code exchange:(NSString *)exchange
{
    if (nil == code || nil == exchange) {
        NSParameterAssert(code);
        NSParameterAssert(exchange);
        return nil;
    }
    
    __block NSMutableArray *resultArray = [NSMutableArray array];
    [self executeBlock:^(NSManagedObjectContext *moc) {
        [self _clearStockMinuteLineWithCode:code exchange:exchange context:moc];
        for (NSDictionary *minDict in lineArray) {
            MinuteLineEntity *minuteLine = [self _saveStockMinuteLine:minDict code:code exchange:exchange context:moc];
            [resultArray addObject:minuteLine];
        }
    }];
    
    return resultArray;
}

- (NSArray *)getStockMinuteLineWithCode:(NSString *)code exchange:(NSString *)exchange
{
    if (nil == code || nil == exchange) {
        NSParameterAssert(code);
        NSParameterAssert(exchange);
        return nil;
    }
    
    __block NSArray *resultArray = nil;
    [self executeBlock:^(NSManagedObjectContext *moc) {
        resultArray = [self _getStockMinuteLineWithCode:code exchange:exchange context:moc];
    }];
    
    return resultArray;
}

#pragma mark -
- (void)saveIndexQuotation:(NSArray *)indexArray
{
    if (indexArray.count == 0) {
        return;
    }
    
    [self executeBlock:^(NSManagedObjectContext *moc) {
        for (NSDictionary *indexDict in indexArray) {
            [self _saveIndexQuotation:indexDict context:moc];
        }
    }];
}

- (NSArray *)getIndexQuotation
{
    __block NSArray *result = nil;
    [self executeBlock:^(NSManagedObjectContext *moc) {
        NSEntityDescription *entity = [IndexQuotationEntity entityInManagedObjectContext:moc];
        NSSortDescriptor *timeDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"updateTime" ascending:YES];
        NSArray *sortDescriptor = @[timeDescriptor];
        result = [self fetchRequest:entity predicate:nil sort:sortDescriptor context:moc];
    }];
    return result;
}

- (void)addSearchHistoryWithCode:(NSString *)code exchange:(NSString *)exchange;
{
    if (nil == code || nil == exchange) {
        NSParameterAssert(code);
        NSParameterAssert(exchange);
        return;
    }
    
    [self executeBlock:^(NSManagedObjectContext *moc) {
        SearchHistoryEntity *searchHistory = [self _getSearchHistoryWithCode:code exchange:exchange context:moc];
        if (nil == searchHistory) {
            searchHistory = [SearchHistoryEntity insertInManagedObjectContext:moc];
            StockInfoEntity *stockInfo = [self _getStockInfoWithCode:code exchange:exchange context:moc];
            searchHistory.stockInfo = stockInfo;
        }
        searchHistory.updateTime = [NSDate date];
    }];
}

- (NSArray *)getSearchHistory
{
    __block NSArray *result = nil;
    [self executeBlock:^(NSManagedObjectContext *moc) {
        result = [self _getSearchHistory:moc];
    }];
    return result;
}

- (void)clearSearchHistory
{
    [self scheduleBlock:^(NSManagedObjectContext *moc) {
        NSArray *result = [self _getSearchHistory:moc];
        for (SearchHistoryEntity *searchHistory in result) {
            [moc deleteObject:searchHistory];
        }
    }];
}

#pragma mark - 板块数据
- (void)savePlateInfo:(NSArray *)plateArray
{
    if (plateArray.count == 0) {
        return;
    }
    
    [self executeBlock:^(NSManagedObjectContext *moc) {
        for (NSDictionary *plateDict in plateArray) {
            [self _savePlateInfo:plateDict context:moc];
        }
    }];
}

- (NSArray *)getPlateInfo
{
    __block NSArray *result = nil;
    [self executeBlock:^(NSManagedObjectContext *moc) {
        NSEntityDescription *entity = [PlateInfoEntity entityInManagedObjectContext:moc];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        NSSortDescriptor *timeDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"updateTime" ascending:YES];
        NSArray *sortDescriptor = @[timeDescriptor];
        [fetchRequest setSortDescriptors:sortDescriptor];
        result = [moc executeFetchRequest:fetchRequest error:nil];
    }];
    return result;
}

- (void)saveHotPlate:(NSArray *)plateArray
{
    [self executeBlock:^(NSManagedObjectContext *moc) {
        [self _clearHotPlate:moc];
        for (NSDictionary *plateDict in plateArray) {
            [self _saveHotPlate:plateDict context:moc];
        }
    }];
}

- (NSArray *)getHotPlate
{
    __block NSArray *result = nil;
    [self executeBlock:^(NSManagedObjectContext *moc) {
        NSEntityDescription *entity = [HotPlateEntity entityInManagedObjectContext:moc];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        NSSortDescriptor *timeDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"updateTime" ascending:YES];
        NSArray *sortDescriptor = @[timeDescriptor];
        [fetchRequest setSortDescriptors:sortDescriptor];
        result = [moc executeFetchRequest:fetchRequest error:nil];
    }];
    return result;
}

- (void)saveStockPlate:(NSArray *)plateArray code:(NSString *)code exchange:(NSString *)exchange
{
    if (nil == code || nil == exchange) {
        NSParameterAssert(code);
        NSParameterAssert(exchange);
        return;
    }
    
    [self executeBlock:^(NSManagedObjectContext *moc) {
        [self _clearStockPlateWithCode:code exchange:exchange context:moc];
        for (NSDictionary *plateDict in plateArray) {
            [self _saveStockPlate:plateDict code:code exchange:exchange context:moc];
        }
    }];
}

- (NSArray *)getStockPlateWithCode:(NSString *)code exchange:(NSString *)exchange
{
    if (nil == code || nil == exchange) {
        NSParameterAssert(code);
        NSParameterAssert(exchange);
        return nil;
    }
    
    __block NSArray *result = nil;
    [self executeBlock:^(NSManagedObjectContext *moc) {
        result = [self _getStockPlateWithCode:code exchange:exchange context:moc];
    }];
    return result;
}

#pragma mark - 数据更新版本（时间戳）
- (void)saveStockInfoUpdateTime:(NSString *)time
{
    
}

- (NSString *)getStockInfoUpdateTime
{
    __block NSString *updateTime = @"0";
    [self executeBlock:^(NSManagedObjectContext *moc) {
        VersionInfoEntity *versionInfo = [self _getVersionInfo:moc];
        if (versionInfo != nil) {
            updateTime = versionInfo.stockInfoVersion;
        }
    }];
    return updateTime;
}

#pragma mark - Protocol Private API
- (void)_saveStockInfo:(NSDictionary *)dict context:(NSManagedObjectContext *)moc
{
    if (nil == dict) {
        return;
    }
    
    NSString *code = [dict objectForKey:@"stock_code"];
    NSString *exchange = [dict objectForKey:@"stock_exchange"];
    if (nil == code || nil == exchange) {
        return;
    }
    
    StockInfoEntity *stockInfo = [self _getStockInfoWithCode:code exchange:exchange context:moc];
    if (nil == stockInfo) {
        stockInfo = [StockInfoEntity insertInManagedObjectContext:moc];
    }
    
    // 解析赋值，不为nil则赋值
    GET_DICT_STRING_VALUE(dict, @"stock_code", stockInfo.code)
    GET_DICT_STRING_VALUE(dict, @"stock_exchange", stockInfo.exchange)
    GET_DICT_STRING_VALUE(dict, @"stock_name", stockInfo.name)
    GET_DICT_STRING_VALUE(dict, @"stock_pinyin", stockInfo.pinyin)
    GET_DICT_STRING_VALUE(dict, @"stock_jianpin", stockInfo.jianpin)
    GET_DICT_INTEGER_VALUE(dict, @"stock_type", stockInfo.type)
    GET_DICT_INTEGER_VALUE(dict, @"is_delisted", stockInfo.delisted)
    GET_DICT_DOUBLE_VALUE(dict, @"listing_date", stockInfo.listingDate)
    GET_DICT_DOUBLE_VALUE(dict, @"update_time", stockInfo.updateTime)
}

- (StockInfoEntity *)_getStockInfoWithCode:(NSString *)code
                                  exchange:(NSString *)exchange
                                   context:(NSManagedObjectContext *)moc
{
    NSEntityDescription *entity = [StockInfoEntity entityInManagedObjectContext:moc];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"code == %@ AND exchange == %@", code, exchange];
    NSArray *result = [self fetchRequest:entity predicate:predicate context:moc];
    return result.firstObject;
}

- (StockInfoEntity *)_getStockInfoWithName:(NSString *)name context:(NSManagedObjectContext *)moc
{
    NSEntityDescription *entity = [StockInfoEntity entityInManagedObjectContext:moc];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", name];
    NSArray *result = [self fetchRequest:entity predicate:predicate context:moc];
    return result.firstObject;
}

- (void)_saveHotStock:(NSDictionary *)dict context:(NSManagedObjectContext *)moc
{
    if (nil == dict) {
        return;
    }
    
    NSString *code = [dict objectForKey:@"stock_code"];
    NSString *exchange = [dict objectForKey:@"stock_exchange"];
    if (nil == code || nil == exchange) {
        return;
    }
    
    [self _saveStockInfo:dict context:moc];
    HotStockEntity *hotStock = [self _getHotStockWithCode:code exchange:exchange context:moc];
    if (nil == hotStock) {
        hotStock = [HotStockEntity insertInManagedObjectContext:moc];
        StockInfoEntity *stockInfo = [self _getStockInfoWithCode:code exchange:exchange context:moc];
        hotStock.stockInfo = stockInfo;
    }
    
    // 解析赋值
    GET_DICT_STRING_VALUE(dict, @"recommended_reason1", hotStock.reason1)
    GET_DICT_STRING_VALUE(dict, @"recommended_reason2", hotStock.reason2)
    GET_DICT_INTEGER_VALUE(dict, @"button_status", hotStock.buttonStatus)
    hotStock.updateTime = [NSDate date];
}

- (HotStockEntity *)_getHotStockWithCode:(NSString *)code exchange:(NSString *)exchange context:(NSManagedObjectContext *)moc
{
    NSEntityDescription *entity = [HotStockEntity entityInManagedObjectContext:moc];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"stockInfo.code == %@ AND stockInfo.exchange == %@", code, exchange];
    NSArray *result = [self fetchRequest:entity predicate:predicate context:moc];
    return result.firstObject;
}

- (void)_clearHotStock:(NSManagedObjectContext *)moc
{
    NSEntityDescription *entity = [HotStockEntity entityInManagedObjectContext:moc];
    NSArray *result = [self fetchRequest:entity predicate:nil context:moc];
    for (HotStockEntity *hotStock in result) {
        [moc deleteObject:hotStock];
    }
}

- (void)_saveHoldStock:(NSDictionary *)dict type:(StockHoldType)type context:(NSManagedObjectContext *)moc
{
    if (nil == dict) {
        return;
    }
    
    NSString *code = [dict objectForKey:@"stock_code"];
    NSString *exchange = [dict objectForKey:@"stock_exchange"];
    if (nil == code || nil == exchange) {
        return;
    }
    
    [self _saveStockInfo:dict context:moc];
    HoldStockEntity *holdStock = [self _getHoldStockWithCode:code exchange:exchange type:type context:moc];
    if (nil == holdStock) {
        holdStock = [HoldStockEntity insertInManagedObjectContext:moc];
        StockInfoEntity *stockInfo = [self _getStockInfoWithCode:code exchange:exchange context:moc];
        holdStock.stockInfo = stockInfo;
    }
    
    // 解析赋值
    GET_DICT_STRING_VALUE(dict, @"uid", holdStock.uid)
    GET_DICT_INTEGER_VALUE(dict, @"stock_status", holdStock.status)
    GET_DICT_STRING_VALUE(dict, @"trade_price", holdStock.tradePrice)
    GET_DICT_STRING_VALUE(dict, @"buy_amount", holdStock.buyAmount)
    GET_DICT_STRING_VALUE(dict, @"sellable_amount", holdStock.sellableAmount)
    GET_DICT_STRING_VALUE(dict, @"profit_rate", holdStock.profitRate)
    GET_DICT_STRING_VALUE(dict, @"profit_money", holdStock.profitMoney)
    GET_DICT_STRING_VALUE(dict, @"current_price", holdStock.currentPrice)
    GET_DICT_INTEGER_VALUE(dict, @"is_buyable", holdStock.isBuyable)
    GET_DICT_INTEGER_VALUE(dict, @"is_sellable", holdStock.isSellable)
    GET_DICT_STRING_VALUE(dict, @"buy_message", holdStock.buyMessage)
    GET_DICT_STRING_VALUE(dict, @"sell_message", holdStock.sellMessage)
    holdStock.holdType = type;
    holdStock.updateTime = [NSDate date];
    
    if (holdStock.uid == nil) {
        UserInfoEntity *userInfo = [[UserInfoCoreDataStorage sharedInstance] getCurrentUserInfo];
        holdStock.uid = userInfo.uid;
    }
}

- (HoldStockEntity *)_getHoldStockWithCode:(NSString *)code
                                  exchange:(NSString *)exchange
                                  type:(StockHoldType)type
                                   context:(NSManagedObjectContext *)moc
{
    NSEntityDescription *entity = [HoldStockEntity entityInManagedObjectContext:moc];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"stockInfo.code == %@ AND stockInfo.exchange == %@ AND holdType == %d",
                              code, exchange, type];
    NSArray *result = [self fetchRequest:entity predicate:predicate context:moc];
    return result.firstObject;
}

- (void)_clearHoldStock:(NSManagedObjectContext *)moc
{
    NSEntityDescription *entity = [HoldStockEntity entityInManagedObjectContext:moc];
    NSArray *result = [self fetchRequest:entity predicate:nil context:moc];
    for (HoldStockEntity *hotStock in result) {
        [moc deleteObject:hotStock];
    }
}

- (void)_saveSelectStock:(NSDictionary *)dict context:(NSManagedObjectContext *)moc
{
    if (nil == dict) {
        return;
    }
    
    NSString *code = [dict objectForKey:@"stock_code"];
    NSString *exchange = [dict objectForKey:@"stock_exchange"];
    if (nil == code || nil == exchange) {
        return;
    }
    
    [self _saveStockInfo:dict context:moc];
    SelectStockEntity *selectStock = [self _getSelectStockWithCode:code exchange:exchange context:moc];
    if (nil == selectStock) {
        selectStock = [SelectStockEntity insertInManagedObjectContext:moc];
        StockInfoEntity *stockInfo = [self _getStockInfoWithCode:code exchange:exchange context:moc];
        selectStock.stockInfo = stockInfo;
    }
    
    // 解析赋值
    GET_DICT_STRING_VALUE(dict, @"uid", selectStock.uid)
    GET_DICT_STRING_VALUE(dict, @"current_price", selectStock.currentPrice)
    GET_DICT_STRING_VALUE(dict, @"profit_rate", selectStock.profitRate)
    GET_DICT_STRING_VALUE(dict, @"profit_amount", selectStock.profitAmount)
    GET_DICT_INTEGER_VALUE(dict, @"is_portfolio", selectStock.isPortfolio)
    GET_DICT_INTEGER_VALUE(dict, @"is_buyable", selectStock.isBuyable)
    GET_DICT_INTEGER_VALUE(dict, @"stock_status", selectStock.status)
    GET_DICT_STRING_VALUE(dict, @"buy_message", selectStock.buyMessage)
    GET_DICT_DOUBLE_VALUE(dict, @"create_time", selectStock.createTime)
    GET_DICT_DOUBLE_VALUE(dict, @"update_time", selectStock.updateTime)
}

- (SelectStockEntity *)_getSelectStockWithCode:(NSString *)code exchange:(NSString *)exchange context:(NSManagedObjectContext *)moc
{
    NSEntityDescription *entity = [SelectStockEntity entityInManagedObjectContext:moc];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"stockInfo.code == %@ AND stockInfo.exchange == %@", code, exchange];
    NSArray *result = [self fetchRequest:entity predicate:predicate context:moc];
    return result.firstObject;
}

- (void)_clearSelectStock:(NSManagedObjectContext *)moc
{
    NSEntityDescription *entity = [SelectStockEntity entityInManagedObjectContext:moc];
    NSArray *result = [self fetchRequest:entity predicate:nil context:moc];
    for (SelectStockEntity *hotStock in result) {
        [moc deleteObject:hotStock];
    }
}

- (RealtimeDataEntity *)_saveStockRealtimeData:(NSDictionary *)dict context:(NSManagedObjectContext *)moc
{
    if (nil == dict) {
        return nil;
    }
    
    NSString *code = [dict objectForKey:@"stock_code"];
    NSString *exchange = [dict objectForKey:@"stock_exchange"];
    if (nil == code || nil == exchange) {
        return nil;
    }
    
    [self _saveStockInfo:dict context:moc];
    RealtimeDataEntity *realtimeData = [self _getStockRealtimeDataWithCode:code exchange:exchange context:moc];
    if (nil == realtimeData) {
        realtimeData = [RealtimeDataEntity insertInManagedObjectContext:moc];
        StockInfoEntity *stockInfo = [self _getStockInfoWithCode:code exchange:exchange context:moc];
        realtimeData.stockInfo = stockInfo;
    }

    // 解析赋值
    GET_DICT_STRING_VALUE(dict, @"current_price", realtimeData.currentPrice)
    GET_DICT_STRING_VALUE(dict, @"yestod_end_price", realtimeData.yesterdayEndPrice)
    GET_DICT_STRING_VALUE(dict, @"today_open", realtimeData.todayOpen)
    GET_DICT_STRING_VALUE(dict, @"today_max", realtimeData.todayMax)
    GET_DICT_STRING_VALUE(dict, @"today_min", realtimeData.todayMin)
    GET_DICT_STRING_VALUE(dict, @"swing", realtimeData.swingRange)
    GET_DICT_STRING_VALUE(dict, @"trade_volume", realtimeData.tradeVolume)
    GET_DICT_STRING_VALUE(dict, @"trade_amount", realtimeData.tradeAmount)
    GET_DICT_STRING_VALUE(dict, @"stock_turnover", realtimeData.stockTurnover)
    GET_DICT_STRING_VALUE(dict, @"price_earning_ratio", realtimeData.priceEarningRatio)
    GET_DICT_STRING_VALUE(dict, @"circulate_market_value", realtimeData.circulateMarketValue)
    GET_DICT_STRING_VALUE(dict, @"date_time", realtimeData.dateTime)
    GET_DICT_STRING_VALUE(dict, @"updown_price", realtimeData.updownPrice)
    GET_DICT_STRING_VALUE(dict, @"updown_range", realtimeData.updownRange)
    GET_DICT_STRING_VALUE(dict, @"updown", realtimeData.updown)
    GET_DICT_INTEGER_VALUE(dict, @"stock_status", realtimeData.stockStatus)
    GET_DICT_INTEGER_VALUE(dict, @"updown_status", realtimeData.updownStatus)
    GET_DICT_INTEGER_VALUE(dict, @"market_status", realtimeData.marketStatus)
    GET_DICT_INTEGER_VALUE(dict, @"is_holdings", realtimeData.isHoldings)
    GET_DICT_INTEGER_VALUE(dict, @"buy_status", realtimeData.buyStatus)
    GET_DICT_STRING_VALUE(dict, @"buy_message", realtimeData.buyMessage)
    GET_DICT_INTEGER_VALUE(dict, @"sell_status", realtimeData.sellStatus)
    GET_DICT_STRING_VALUE(dict, @"sell_message", realtimeData.sellMessage)
    GET_DICT_STRING_VALUE(dict, @"user_trade_amount", realtimeData.userTradeAmount)
    GET_DICT_STRING_VALUE(dict, @"user_trade_price", realtimeData.userTradePrice)
    GET_DICT_STRING_VALUE(dict, @"user_profit_money", realtimeData.userProfitMoney)
    GET_DICT_STRING_VALUE(dict, @"user_profit_rate", realtimeData.userProfitRate)
    GET_DICT_STRING_VALUE(dict, @"price_compare", realtimeData.priceCompare)
    GET_DICT_INTEGER_VALUE(dict, @"is_optional", realtimeData.isSelected)
    GET_DICT_INTEGER_VALUE(dict, @"is_set_push_remind", realtimeData.isSetRemind)
    GET_DICT_INTEGER_VALUE(dict, @"is_tradable", realtimeData.isTradable)
    GET_DICT_STRING_VALUE(dict, @"stock_feeling", realtimeData.stockFeeling)
    GET_DICT_STRING_VALUE(dict, @"stock_feeling_add", realtimeData.stockFeelingAdd)
    // 做空新增
    GET_DICT_INTEGER_VALUE(dict, @"short_is_holdings", realtimeData.shortIsHoldings)
    GET_DICT_INTEGER_VALUE(dict, @"short_buy_status", realtimeData.shortBuyStatus)
    GET_DICT_STRING_VALUE(dict, @"short_buy_message", realtimeData.shortBuyMessage)
    GET_DICT_INTEGER_VALUE(dict, @"short_sell_status", realtimeData.shortSellStatus)
    GET_DICT_STRING_VALUE(dict, @"short_sell_message", realtimeData.shortSellMessage)
    GET_DICT_STRING_VALUE(dict, @"short_user_trade_amount", realtimeData.shortUserTradeAmount)
    GET_DICT_STRING_VALUE(dict, @"short_user_trade_price", realtimeData.shortUserTradePrice)
    GET_DICT_STRING_VALUE(dict, @"short_user_profit_money", realtimeData.shortUserProfitMoney)
    GET_DICT_STRING_VALUE(dict, @"short_user_profit_rate", realtimeData.shortUserProfitRate)
    GET_DICT_STRING_VALUE(dict, @"making_short_rate", realtimeData.makingShortRate)
    GET_DICT_STRING_VALUE(dict, @"making_long_rate", realtimeData.makingLongRate)
    GET_DICT_STRING_VALUE(dict, @"short_long_text", realtimeData.shortLongText)
    GET_DICT_INTEGER_VALUE(dict, @"short_card_status", realtimeData.shortCardStatus)
    
    return realtimeData;
}

- (RealtimeDataEntity *)_getStockRealtimeDataWithCode:(NSString *)code exchange:(NSString *)exchange context:(NSManagedObjectContext *)moc
{
    NSEntityDescription *entity = [RealtimeDataEntity entityInManagedObjectContext:moc];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"stockInfo.code == %@ AND stockInfo.exchange == %@", code, exchange];
    NSArray *result = [self fetchRequest:entity predicate:predicate context:moc];
    return result.firstObject;
}

- (StockGradeEntity *)_saveStockGrade:(NSDictionary *)dict context:(NSManagedObjectContext *)moc
{
    if (nil == dict) {
        return nil;
    }
    
    NSString *code = [dict objectForKey:@"stock_code"];
    NSString *exchange = [dict objectForKey:@"stock_exchange"];
    if (nil == code || nil == exchange) {
        return nil;
    }
    
    [self _saveStockInfo:dict context:moc];
    StockGradeEntity *stockGrade = [self _getStockGradeWithCode:code exchange:exchange context:moc];
    if (nil == stockGrade) {
        stockGrade = [StockGradeEntity insertInManagedObjectContext:moc];
        StockInfoEntity *stockInfo = [self _getStockInfoWithCode:code exchange:exchange context:moc];
        stockGrade.stockInfo = stockInfo;
    }
    
    // 解析赋值
    GET_DICT_STRING_VALUE(dict, @"stock_grade", stockGrade.grade)
    GET_DICT_STRING_VALUE(dict, @"stock_zd", stockGrade.quality)
    GET_DICT_STRING_VALUE(dict, @"stock_zs", stockGrade.tendency)
    GET_DICT_STRING_VALUE(dict, @"suggest", stockGrade.suggest)

    return stockGrade;
}

- (StockGradeEntity *)_getStockGradeWithCode:(NSString *)code exchange:(NSString *)exchange context:(NSManagedObjectContext *)moc
{
    NSEntityDescription *entity = [StockGradeEntity entityInManagedObjectContext:moc];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"stockInfo.code == %@ AND stockInfo.exchange == %@", code, exchange];
    NSArray *result = [self fetchRequest:entity predicate:predicate context:moc];
    return result.firstObject;
}

- (MinuteLineEntity *)_saveStockMinuteLine:(NSDictionary *)dict
                                      code:(NSString *)code
                                  exchange:(NSString *)exchange
                                   context:(NSManagedObjectContext *)moc
{
    StockInfoEntity *stockInfo = [self _getStockInfoWithCode:code exchange:exchange context:moc];
    if (nil == stockInfo) {
        return nil;
    }
    MinuteLineEntity *minuteLine = [MinuteLineEntity insertInManagedObjectContext:moc];
    minuteLine.stockInfo = stockInfo;
    // 解析赋值
    GET_DICT_STRING_VALUE(dict, @"time", minuteLine.time)
    GET_DICT_STRING_VALUE(dict, @"price", minuteLine.price)
    GET_DICT_STRING_VALUE(dict, @"updown_range", minuteLine.updownRange)
    GET_DICT_STRING_VALUE(dict, @"volume", minuteLine.volume)
    GET_DICT_STRING_VALUE(dict, @"avg_price", minuteLine.avgPrice)
    GET_DICT_STRING_VALUE(dict, @"all_volume", minuteLine.allVolume)
    GET_DICT_STRING_VALUE(dict, @"updown", minuteLine.updown)
    
    return minuteLine;
}

- (NSArray *)_getStockMinuteLineWithCode:(NSString *)code exchange:(NSString *)exchange context:(NSManagedObjectContext *)moc
{
    NSEntityDescription *entity = [MinuteLineEntity entityInManagedObjectContext:moc];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"stockInfo.code == %@ AND stockInfo.exchange == %@", code, exchange];
    NSSortDescriptor *timeDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"time" ascending:YES];
    NSArray *sortDescriptor = @[timeDescriptor];
    return [self fetchRequest:entity predicate:predicate sort:sortDescriptor context:moc];
}

- (void)_clearStockMinuteLineWithCode:(NSString *)code exchange:(NSString *)exchange context:(NSManagedObjectContext *)moc
{
    NSArray *result = [self _getStockMinuteLineWithCode:code exchange:exchange context:moc];
    for (MinuteLineEntity *minuteLine in result) {
        [moc deleteObject:minuteLine];
    }
}

- (void)_saveIndexQuotation:(NSDictionary *)dict context:(NSManagedObjectContext *)moc
{
    if (nil == dict) {
        return;
    }
    
    NSString *code = [dict objectForKey:@"stock_code"];
    if (nil == code) {
        return;
    }
    
    IndexQuotationEntity *indexQuotation = [self _getIndexQuotation:code context:moc];
    if (nil == indexQuotation) {
        indexQuotation = [IndexQuotationEntity insertInManagedObjectContext:moc];
    }
    
    // 解析赋值
    GET_DICT_STRING_VALUE(dict, @"stock_code", indexQuotation.code)
    GET_DICT_STRING_VALUE(dict, @"stock_name", indexQuotation.name)
    GET_DICT_STRING_VALUE(dict, @"stock_exchange", indexQuotation.exchange)
    GET_DICT_STRING_VALUE(dict, @"current_price", indexQuotation.currentPrice)
    GET_DICT_STRING_VALUE(dict, @"updown", indexQuotation.updown)
    GET_DICT_STRING_VALUE(dict, @"updown_price", indexQuotation.updownPrice)
    GET_DICT_STRING_VALUE(dict, @"updown_range", indexQuotation.updownRange)
    indexQuotation.updateTime = [NSDate date];
}

- (IndexQuotationEntity *)_getIndexQuotation:(NSString *)code context:(NSManagedObjectContext *)moc
{
    NSEntityDescription *entity = [IndexQuotationEntity entityInManagedObjectContext:moc];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"code == %@", code];
    NSArray *result = [self fetchRequest:entity predicate:predicate context:moc];
    return result.firstObject;
}

- (void)_clearIndexQuotation:(NSManagedObjectContext *)moc
{
    NSEntityDescription *entity = [IndexQuotationEntity entityInManagedObjectContext:moc];
    NSArray *result = [self fetchRequest:entity predicate:nil context:moc];
    for (IndexQuotationEntity *indexQuotation in result) {
        [moc deleteObject:indexQuotation];
    }
}

- (SearchHistoryEntity *)_getSearchHistoryWithCode:(NSString *)code
                                          exchange:(NSString *)exchange
                                           context:(NSManagedObjectContext *)moc
{
    NSEntityDescription *entity = [SearchHistoryEntity entityInManagedObjectContext:moc];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"stockInfo.code == %@ AND stockInfo.exchange == %@", code, exchange];
    NSArray *result = [self fetchRequest:entity predicate:predicate context:moc];
    return result.firstObject;
}

- (NSArray *)_getSearchHistory:(NSManagedObjectContext *)moc
{
    NSEntityDescription *entity = [SearchHistoryEntity entityInManagedObjectContext:moc];
    NSSortDescriptor *timeDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"updateTime" ascending:NO];
    NSArray *sortDescriptor = @[timeDescriptor];
    return [self fetchRequest:entity predicate:nil sort:sortDescriptor context:moc];
}


- (void)_savePlateInfo:(NSDictionary *)dict context:(NSManagedObjectContext *)moc
{
    if (nil == dict) {
        return;
    }
    
    NSString *code = [dict objectForKey:@"plate_code"];
    if (nil == code) {
        return;
    }
    
    PlateInfoEntity *plateInfo = [self _getPlateInfo:code context:moc];
    if (nil == plateInfo) {
        plateInfo = [PlateInfoEntity insertInManagedObjectContext:moc];
    }
    
    // 解析赋值，不为nil则赋值
    GET_DICT_STRING_VALUE(dict, @"plate_code", plateInfo.code)
    GET_DICT_STRING_VALUE(dict, @"plate_name", plateInfo.name)
    GET_DICT_STRING_VALUE(dict, @"stock_num", plateInfo.stockNum)
    GET_DICT_STRING_VALUE(dict, @"updown_range", plateInfo.updownRange)
    plateInfo.updateTime = [NSDate date];
}

- (PlateInfoEntity *)_getPlateInfo:(NSString *)code context:(NSManagedObjectContext *)moc
{
    NSEntityDescription *entity = [PlateInfoEntity entityInManagedObjectContext:moc];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"code == %@", code];
    NSArray *result = [self fetchRequest:entity predicate:predicate context:moc];
    return result.firstObject;
}

- (void)_saveHotPlate:(NSDictionary *)dict context:(NSManagedObjectContext *)moc
{
    if (nil == dict) {
        return;
    }
    
    NSString *code = [dict objectForKey:@"plate_code"];
    if (nil == code) {
        return;
    }
    
    [self _savePlateInfo:dict context:moc];
    HotPlateEntity *hotPlate = [self _getHotPlate:code context:moc];
    if (nil == hotPlate) {
        hotPlate = [HotPlateEntity insertInManagedObjectContext:moc];
        PlateInfoEntity *plateInfo = [self _getPlateInfo:code context:moc];
        hotPlate.plateInfo = plateInfo;
    }
    hotPlate.updateTime = [NSDate date];
}

- (HotPlateEntity *)_getHotPlate:(NSString *)code context:(NSManagedObjectContext *)moc
{
    NSEntityDescription *entity = [HotPlateEntity entityInManagedObjectContext:moc];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"plateInfo.code == %@", code];
    NSArray *result = [self fetchRequest:entity predicate:predicate context:moc];
    return result.firstObject;
}

- (void)_clearHotPlate:(NSManagedObjectContext *)moc
{
    NSEntityDescription *entity = [HotPlateEntity entityInManagedObjectContext:moc];
    NSArray *result = [self fetchRequest:entity predicate:nil context:moc];
    for (HotPlateEntity *hotPlate in result) {
        [moc deleteObject:hotPlate];
    }
}

- (void)_saveStockPlate:(NSDictionary *)dict
                   code:(NSString *)code
               exchange:(NSString *)exchange
                context:(NSManagedObjectContext *)moc
{
    if (nil == dict) {
        return;
    }
    
    NSString *plateCode = [dict objectForKey:@"plate_code"];
    if (nil == plateCode) {
        return;
    }
    
    StockInfoEntity *stockInfo = [self _getStockInfoWithCode:code exchange:exchange context:moc];
    if (nil == stockInfo) {
        return;
    }

    [self _savePlateInfo:dict context:moc];
    StockPlateEntity *stockPlate = [StockPlateEntity insertInManagedObjectContext:moc];
    PlateInfoEntity *plateInfo = [self _getPlateInfo:plateCode context:moc];
    stockPlate.plateInfo = plateInfo;
    stockPlate.stockInfo = stockInfo;
    stockPlate.updateTime = [NSDate date];
}

- (NSArray *)_getStockPlateWithCode:(NSString *)code
                           exchange:(NSString *)exchange
                            context:(NSManagedObjectContext *)moc
{
    NSEntityDescription *entity = [StockPlateEntity entityInManagedObjectContext:moc];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"stockInfo.code == %@ AND stockInfo.exchange == %@", code, exchange];
    
    NSSortDescriptor *timeDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"updateTime" ascending:YES];
    NSArray *sortDescriptor = @[timeDescriptor];
    return [self fetchRequest:entity predicate:predicate sort:sortDescriptor context:moc];
}

- (void)_clearStockPlateWithCode:(NSString *)code
                        exchange:(NSString *)exchange
                         context:(NSManagedObjectContext *)moc
{
    NSArray *result = [self _getStockPlateWithCode:code exchange:exchange context:moc];
    for (StockPlateEntity *stockPlate in result) {
        [moc deleteObject:stockPlate];
    }
}

- (void)_saveStockInfoUpdateTime:(NSString *)time context:(NSManagedObjectContext *)moc
{
    VersionInfoEntity *versionInfo = [self _getVersionInfo:moc];
    if (nil == versionInfo) {
        versionInfo = [VersionInfoEntity insertInManagedObjectContext:moc];
        versionInfo.stockInfoVersion = @"0";
    }
    versionInfo.stockInfoVersion = time;
}

- (VersionInfoEntity *)_getVersionInfo:(NSManagedObjectContext *)moc
{
    NSEntityDescription *entity = [VersionInfoEntity entityInManagedObjectContext:moc];
    NSArray *result = [self fetchRequest:entity predicate:nil context:moc];
    return result.firstObject;
}

@end
