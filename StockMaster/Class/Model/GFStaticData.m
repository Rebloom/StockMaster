//
//  GFStaticData.m
//  StockMaster
//
//  Created by Rebloom on 14-8-11.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "GFStaticData.h"
#import "UserInfoCoreDataStorage.h"

@implementation GFStaticData

static GFStaticData * gfStaticData = nil;

+ (GFStaticData *)defaultDataCenter
{
    if (!gfStaticData)
    {
        gfStaticData = [[GFStaticData alloc] init];
    }
    return gfStaticData;
}

+ (BOOL)saveObject:(id)object forKey:(NSString *)key
{
    if (!object && key)
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    }
    else if (key)
    {
        [[NSUserDefaults standardUserDefaults] setObject:object forKey:key];
    }
    else
    {
        assert(object);
    }
    return [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (id)getObjectForKey:(NSString *)key
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:key])
    {
        return [[NSUserDefaults standardUserDefaults] objectForKey:key];
    }
    else
    {
        return nil;
    }
}

// 做一些数据的保存相关方法（区分用户的）
+ (BOOL)saveObject:(id)data forKey:(NSString *)key forUser:(NSString *)user
{
    if ([key length] == 0 || [user length] == 0 || data == nil)
    {
        return NO;
    }
    
    // 判断当前文件夹是否存在
    NSFileManager *fileManger = [NSFileManager defaultManager];
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *dirPath = [path stringByAppendingPathComponent:[Utility md5:user]];
    if (![fileManger fileExistsAtPath:dirPath])
    {
        [fileManger createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    // 保存的文件路径
    NSString *filePath = [dirPath stringByAppendingFormat:@"/%@.plist",[Utility md5:key]];

    // 返回保存结果
    return [NSKeyedArchiver archiveRootObject:data toFile:filePath];
}

// 获取一些数据的相关方法（区分用户的）
+ (id)getObjectForKey:(NSString*)key forUser:(NSString*)user
{
    if ([key length] == 0 || [user length] == 0)
    {
        return nil;
    }
    
    // 判断当前文件夹是否存在
    NSFileManager *fileManger = [NSFileManager defaultManager];
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *dirPath = [path stringByAppendingPathComponent:[Utility md5:user]];
    // 对应的保存文件路径
    NSString *filePath = [dirPath stringByAppendingFormat:@"/%@.plist",[Utility md5:key]];
    
    if (![fileManger fileExistsAtPath:filePath])
    {
        if ([[NSBundle mainBundle] pathForResource:@"stocklist" ofType:@"plist"] && [key isEqualToString:kTagStockList])
        {
            NSString *documentDir = [[NSBundle mainBundle] pathForResource:@"stocklist" ofType:@"plist"];
            [GFStaticData saveObject:[NSKeyedUnarchiver unarchiveObjectWithFile:documentDir] forKey:kTagStockList forUser:kTagStockList];
            return [NSKeyedUnarchiver unarchiveObjectWithFile:documentDir];
        }
        return nil;
    }
    return [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
}

@end
