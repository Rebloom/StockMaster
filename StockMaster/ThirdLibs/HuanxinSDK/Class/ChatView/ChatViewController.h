//
//  ChatViewController.h
//  StockMaster
//
//  Created by 孤星之殇 on 15/7/30.
//  Copyright (c) 2015年 aizhangzhang. All rights reserved.
//

#import "BasicViewController.h"

@interface ChatViewController : BasicViewController

@property (nonatomic, strong) NSString *chatter;
@property (nonatomic, strong) NSDictionary *commodityInfo;

- (instancetype)initWithChatter:(NSString *)chatter
                        isGroup:(BOOL)isGroup;

- (void)reloadData;

- (void)sendCommodityMessageWithImage:(UIImage *)image ext:(NSDictionary *)ext;

@end