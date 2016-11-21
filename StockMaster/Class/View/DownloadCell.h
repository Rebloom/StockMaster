//
//  DownloadCell.h
//  StockMaster
//
//  Created by 孤星之殇 on 15/6/8.
//  Copyright (c) 2015年 aizhangzhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DownloadToAward <NSObject>

- (void)jumpToAppStore:(NSInteger)tag;

@end

@interface DownloadCell : UITableViewCell
{
    UILabel * nameLabel;
    UILabel * descLabel;
    
    UIImageView * verImageView;
    UIImageView * henImageView;
    UIImageView * urlImageView;
    UIImageView * awardImageView;
    UIImageView * photoImageView;
    
    UIButton * awardBtn;
    
    UILabel * awardTipLabel;
}
@property (nonatomic, strong)UILabel * nameLabel;
@property (nonatomic, strong)UILabel * descLabel;
@property (nonatomic, strong)UIImageView * verImageView;
@property (nonatomic, strong)UIImageView * henImageView;
@property (nonatomic, strong)UIImageView * urlImageView;
@property (nonatomic, strong)UIImageView * awardImageView;
@property (nonatomic, strong)UIImageView * photoImageView;
@property (nonatomic, strong)UIButton * awardBtn;
@property (nonatomic, strong)UILabel * awardTipLabel;
@property (nonatomic, weak)id<DownloadToAward>delegate;
@end
