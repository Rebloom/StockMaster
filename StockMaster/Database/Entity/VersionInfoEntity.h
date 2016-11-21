//
//  VersionInfoEntity.h
//  StockMaster
//
//  Created by Johnny on 15/4/10.
//  Copyright (c) 2015年 aizhangzhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "BasicManagedObject.h"

@interface VersionInfoEntity : BasicManagedObject

@property (nonatomic, retain) NSString * stockInfoVersion;

@end
