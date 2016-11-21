//
//  PlateInfoEntity.h
//  StockMaster
//
//  Created by Johnny on 15/4/10.
//  Copyright (c) 2015年 aizhangzhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "BasicManagedObject.h"

@interface PlateInfoEntity : BasicManagedObject

// 板块代码
@property (nonatomic, retain) NSString * code;
// 板块名称
@property (nonatomic, retain) NSString * name;
// 包含的股票数量
@property (nonatomic, retain) NSString * stockNum;
// 涨跌幅
@property (nonatomic, retain) NSString * updownRange;
// 更新时间，用于排序
@property (nonatomic, retain) NSDate *updateTime;

@end
