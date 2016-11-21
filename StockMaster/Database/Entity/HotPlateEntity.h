//
//  HotPlateEntity.h
//  StockMaster
//
//  Created by Johnny on 15/4/10.
//  Copyright (c) 2015年 aizhangzhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "BasicManagedObject.h"

@class PlateInfoEntity;

@interface HotPlateEntity : BasicManagedObject

// 更新时间，用于排序
@property (nonatomic, retain) NSDate *updateTime;
@property (nonatomic, retain) PlateInfoEntity *plateInfo;

@end
