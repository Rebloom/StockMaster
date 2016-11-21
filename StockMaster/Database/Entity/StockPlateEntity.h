//
//  StockPlateEntity.h
//  StockMaster
//
//  Created by Johnny on 15/5/24.
//  Copyright (c) 2015年 aizhangzhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "BasicManagedObject.h"

@class PlateInfoEntity, StockInfoEntity;

@interface StockPlateEntity : BasicManagedObject

// 更新时间，用于排序
@property (nonatomic, retain) NSDate * updateTime;
@property (nonatomic, retain) PlateInfoEntity *plateInfo;
@property (nonatomic, retain) StockInfoEntity *stockInfo;

@end
