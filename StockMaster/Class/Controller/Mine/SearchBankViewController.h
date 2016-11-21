//
//  SearchBankViewController.h
//  StockMaster
//
//  Created by Rebloom on 15/5/6.
//  Copyright (c) 2015年 aizhangzhang. All rights reserved.
//

#import "BasicViewController.h"

#import "GFTextField.h"

@protocol SearchBankVCDelegate <NSObject>

- (void)didChooseBank:(NSDictionary *)bankInfo;

- (void)didChooseBranchBank:(NSDictionary *)branchBankInfo;

@end

@interface SearchBankViewController : BasicViewController <UITextFieldDelegate,UISearchDisplayDelegate>
{
    UITableView * infoTable;
    
    NSMutableArray * infoArr;
    
    NSMutableArray * searchArr;
    
    NSString * bankID;
    NSString * province;
    NSString * city;
    
    NSInteger searchStatus;
    
    UISearchDisplayController * searchDisplayController;
}

@property (nonatomic, assign) NSInteger searchType;
@property (nonatomic, copy) NSString * bankID;
@property (nonatomic, weak) id <SearchBankVCDelegate> delegate;

@end
