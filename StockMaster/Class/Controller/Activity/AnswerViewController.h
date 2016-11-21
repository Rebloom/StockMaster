//
//  AnswerViewController.h
//  StockMaster
//
//  Created by Rebloom on 14/11/17.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "BasicViewController.h"

@interface AnswerViewController : BasicViewController <CHNAlertViewDelegate>
{
    UILabel * question;
    UIButton * btn1;
    UIButton * btn2;
    UILabel * answer1;
    UILabel * answer2;
    
    UIButton * resultBtn;
    
    UITableView * infoTable;
    
    NSMutableArray * infoArr;
    NSDictionary * infoDic;
    
    NSInteger answerId;
    
    UIImageView * answerImage;
    UIImageView * AImage;
    UIImageView * BImage;
    
    UIImageView * resultImage;
    UIView * centerLine;
    UILabel * guessResultLabel;
    UILabel * guessResultDescLabel;
    
    UILabel * sectionLabel;
}

@end
