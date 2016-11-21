//
//  SettingInfoEntity.h
//  StockMaster
//
//  Created by Johnny on 15/4/17.
//  Copyright (c) 2015年 aizhangzhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "BasicManagedObject.h"

@interface SettingInfoEntity : BasicManagedObject

@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) NSString * key;
@property (nonatomic, retain) NSData * data;
@property (nonatomic, retain) NSString *type;

@end
