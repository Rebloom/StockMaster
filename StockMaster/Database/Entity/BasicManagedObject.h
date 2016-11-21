//
//  BasicManagedObject.h
//  StockMaster
//
//  Created by Johnny on 15-1-7.
//  Copyright (c) 2015年 aizhangzhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface BasicManagedObject : NSManagedObject

+ (NSString *)entityName;
+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc;
+ (NSEntityDescription *)entityInManagedObjectContext:(NSManagedObjectContext *)moc;

@end
