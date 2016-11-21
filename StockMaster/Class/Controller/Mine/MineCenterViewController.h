//
//  MineCenterViewController.h
//  StockMaster
//
//  Created by Rebloom on 14-7-24.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "BasicViewController.h"

#import "UIImageView+WebCache.h"
#import "SDWebImageManager.h"

#import "LoginViewController.h"

@interface MineCenterViewController : BasicViewController <UIImagePickerControllerDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,SDWebImageManagerDelegate>
{
    UITableView * mineCenterTable;
    UIImageView * headView;
    UILabel *tipLabel;
    UILabel *nameLabel;
    UILabel *mobelLabel;
    UIImagePickerController * imagePicker;
    UIView * mainView;
    UIImageView * feetView;
    UIImage *uploadImage; // 上传图
    UIImage *beginImage; // 初始图
}

@property (nonatomic, assign) NSInteger type;

@end
