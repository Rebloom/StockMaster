//
//  UserInfoEntity.h
//  StockMaster
//
//  Created by Johnny on 15/4/23.
//  Copyright (c) 2015年 aizhangzhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "BasicManagedObject.h"

@interface UserInfoEntity : BasicManagedObject

@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) NSString * head;
@property (nonatomic, retain) NSString * mobile;
@property (nonatomic, retain) NSString * nickname;
@property (nonatomic, retain) NSString * signature;
@property (nonatomic, retain) NSString * token;
@property (nonatomic, retain) NSDate * updateTime;

@end
