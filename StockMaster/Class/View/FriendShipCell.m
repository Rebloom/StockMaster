//
//  FriendShipCell.m
//  StockMaster
//
//  Created by dalikeji on 15/2/27.
//  Copyright (c) 2015年 Rebloom. All rights reserved.
//

#import "FriendShipCell.h"
#import "NSString+UIColor.h"
#import "CHNMacro.h"
@implementation FriendShipCell
@synthesize photoImg;
@synthesize moneyLabel;
@synthesize nameLabel;
@synthesize lineLable;
@synthesize rankImageView;
@synthesize rankLabel;

- (void)dealloc
{
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self createCell];
    }
    return self;
}

- (void)createCell
{
    lineLable = [[UILabel alloc] init];
    lineLable.frame = CGRectMake(15, 79.5, screenWidth - 30, 0.5);
    lineLable.backgroundColor = KLineNewBGColor6;
    [self addSubview:lineLable];
    
    photoImg = [[UIImageView alloc] init];
    photoImg.frame = CGRectMake(20, 15, 50, 50);
    photoImg.layer.cornerRadius = 25;
    photoImg.layer.masksToBounds = YES;
    [self addSubview:photoImg];
    
    rankImageView = [[UIImageView alloc] init];
    rankImageView.frame = CGRectMake(15, 31.5, 16, 17);
    [self addSubview:rankImageView];
    
    rankLabel = [[UILabel alloc] init];
    rankLabel.frame = CGRectMake(0, 0, 16, 17);
    rankLabel.backgroundColor = [UIColor clearColor];
    rankLabel.font = BoldFontWithSize(11);
    rankLabel.textColor = kFontColorA;
    rankLabel.textAlignment = NSTextAlignmentCenter;
    [rankImageView addSubview:rankLabel];
    
    nameLabel = [[UILabel alloc] init];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.textAlignment = NSTextAlignmentLeft;
    nameLabel.textColor = KFontNewColorA;
    nameLabel.font = NormalFontWithSize(15);
    nameLabel.frame = CGRectMake(CGRectGetMaxX(photoImg.frame)+10, 25, screenWidth/2-10, 15);
    [self addSubview:nameLabel];
    
    moneyLabel = [[UILabel alloc] init];
    moneyLabel.backgroundColor=  [UIColor clearColor];
    moneyLabel.textAlignment = NSTextAlignmentLeft;
    moneyLabel.textColor = KFontNewColorB;
    moneyLabel.font = NormalFontWithSize(13);
    moneyLabel.frame = CGRectMake(CGRectGetMaxX(photoImg.frame)+10, CGRectGetMaxY(nameLabel.frame)+10, 200, 15);
    [self addSubview:moneyLabel];
    
    UIImageView * rightView = [[UIImageView alloc] initWithFrame:CGRectMake((screenWidth - 15 -11), 30.5, 11, 19)];
    rightView.image = [UIImage imageNamed:@"home_right"];
    [self addSubview:rightView];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
