//
//  UserAssetEntity.h
//  StockMaster
//
//  Created by Johnny on 15/6/1.
//  Copyright (c) 2015年 aizhangzhang. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "BasicManagedObject.h"

// 用户资产
@interface UserAssetEntity : BasicManagedObject

// 用户uid
@property (nonatomic, retain) NSString * uid;
// 总资产
@property (nonatomic, retain) NSString * totalAsset;
// 初始本金
@property (nonatomic, retain) NSString * initbaseMoney;
// 可用资金
@property (nonatomic, retain) NSString * usableMoney;
// 持仓盈利金额
@property (nonatomic, retain) NSString * profitMoney;
// 持仓市值
@property (nonatomic, retain) NSString * positionMoney;
// 可提现金额
@property (nonatomic, retain) NSString * withdrawMoney;

@end
