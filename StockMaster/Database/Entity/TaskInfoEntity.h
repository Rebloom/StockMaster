//
//  TaskInfoEntity.h
//  StockMaster
//
//  Created by Johnny on 15/4/17.
//  Copyright (c) 2015年 aizhangzhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "BasicManagedObject.h"

@interface TaskInfoEntity : BasicManagedObject

// 用户uid
@property (nonatomic, retain) NSString * uid;
// 任务id
@property (nonatomic, retain) NSString * taskID;
// 完成任务记录id
@property (nonatomic, retain) NSString * logID;
// 任务名称
@property (nonatomic, retain) NSString * name;
// 任务描述
@property (nonatomic, retain) NSString * describe;
// 任务金额
@property (nonatomic, retain) NSString * money;
// 按钮文案
@property (nonatomic, retain) NSString * buttonText;
// 任务状态
@property (nonatomic, assign) int16_t status;
// 任务图标
@property (nonatomic, retain) NSString *taskIcon;
// 跳转链接
@property (nonatomic, retain) NSString *h5Url;
// 跳转标题
@property (nonatomic, retain) NSString *h5Title;
// 跳转任务
@property (nonatomic, retain) NSString *h5Task;
// 更新时间，用于排序
@property (nonatomic, retain) NSDate *updateTime;

@end
