//
//  DownloadCell.m
//  StockMaster
//
//  Created by 孤星之殇 on 15/6/8.
//  Copyright (c) 2015年 aizhangzhang. All rights reserved.
//

#import "DownloadCell.h"
#import "NSString+UIColor.h"
#import "CHNMacro.h"

@implementation DownloadCell
@synthesize nameLabel;
@synthesize descLabel;
@synthesize verImageView;
@synthesize henImageView;
@synthesize urlImageView;
@synthesize awardImageView;
@synthesize photoImageView;
@synthesize awardBtn;
@synthesize awardTipLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createCell];
    }
    return self;
}

- (void)createCell
{
    photoImageView = [[UIImageView alloc] init];
    photoImageView.frame = CGRectMake(15, 15, 60, 60);
    photoImageView.layer.masksToBounds = YES;
    photoImageView.layer.cornerRadius = 10;
    photoImageView.layer.borderWidth = 0.2;
    [self addSubview:photoImageView];
    
    nameLabel = [[UILabel alloc] init];
    nameLabel.textAlignment = NSTextAlignmentLeft;
    nameLabel.textColor = KFontNewColorA;
    nameLabel.font = NormalFontWithSize(15);
    nameLabel.frame = CGRectMake(CGRectGetMaxX(photoImageView.frame)+10, CGRectGetMinY(photoImageView.frame), 134, 20);
    [self addSubview:nameLabel];
    
    descLabel = [[UILabel alloc] init];
    descLabel.textAlignment = NSTextAlignmentLeft;
    descLabel.numberOfLines = 2;
    descLabel.textColor = KFontNewColorB;
    descLabel.font = NormalFontWithSize(13);
    descLabel.frame = CGRectMake(CGRectGetMinX(nameLabel.frame), CGRectGetMaxY(nameLabel.frame)+5, screenWidth - CGRectGetMinX(nameLabel.frame)-70, 30);
    [self addSubview:descLabel];
    
    verImageView = [[UIImageView alloc] init];
    verImageView.frame = CGRectMake(screenWidth - 64, 15, 0.5, 60);
    verImageView.image = [UIImage imageNamed:@"shangyinying"];
    verImageView.backgroundColor = KFontNewColorM;
    [self addSubview:verImageView];
    
    henImageView = [[UIImageView alloc] init];
    henImageView.backgroundColor = KFontNewColorM;
    [self addSubview:henImageView];
    
    urlImageView = [[UIImageView alloc] init];
    urlImageView.frame = CGRectMake(0, 0, screenWidth, 150);
    [self addSubview:urlImageView];
    
    awardBtn = [[UIButton alloc] init];
    awardBtn.backgroundColor = [UIColor clearColor];
    awardBtn.frame = CGRectMake(screenWidth - 65, 0, 65, 90);
    [awardBtn addTarget:self action:@selector(awardBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:awardBtn];
    
    awardImageView = [[UIImageView alloc] init];
    awardImageView.frame = CGRectMake(39.5/2, 25, 25.5, 25.5);
    [awardBtn addSubview:awardImageView];
    
    awardTipLabel = [[UILabel alloc] init];
    awardTipLabel.frame = CGRectMake(0, CGRectGetMaxY(awardImageView.frame) +5, 65, 15);
    awardTipLabel.textColor = kRedColor;
    awardTipLabel.textAlignment = NSTextAlignmentCenter;
    awardTipLabel.font = NormalFontWithSize(11);
    [awardBtn addSubview:awardTipLabel];
    
}

- (void)awardBtnOnClick:(UIButton*)sender
{
    if ([self.delegate respondsToSelector:@selector(jumpToAppStore:)])
    {
        [self.delegate jumpToAppStore:sender.tag];
    }
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
