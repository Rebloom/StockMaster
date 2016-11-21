//
//  GuideDetailViewController.m
//  StockMaster
//
//  Created by Rebloom on 14-8-5.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "GuideDetailViewController.h"

@interface GuideDetailViewController ()

@end

@implementation GuideDetailViewController

@synthesize pageType;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor =kBackgroundColor;
    if (pageType == PageType1)
    {
        [headerView loadComponentsWithTitle:@"什么是人人股神"];
        
        UILabel * msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(headerView.frame)+15, 290, 50)];
        msgLabel.numberOfLines = 3;
        msgLabel.backgroundColor = [UIColor clearColor];
        msgLabel.font = NormalFontWithSize(14);
        msgLabel.textColor = [UIColor blackColor];
        msgLabel.text = GuideMessage;
        [self.view addSubview:msgLabel];
        [msgLabel release];
    }
    else if (pageType == PageType2)
    {
        [headerView loadComponentsWithTitle:@"人人股神有什么特点"];
        
        for (int i = 0; i < 3; i++)
        {
            UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(headerView.frame)+15+i*80, 290, 20)];
            titleLabel.numberOfLines = 4;
            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.font = BoldFontWithSize(15);
            titleLabel.textColor = [UIColor blackColor];
            [self.view addSubview:titleLabel];
            [titleLabel release];
            
            UILabel * msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(headerView.frame)+35+i*80, 290, 50)];
            msgLabel.numberOfLines = 4;
            msgLabel.backgroundColor = [UIColor clearColor];
            msgLabel.font = NormalFontWithSize(12);
            msgLabel.textColor = [UIColor blackColor];
            [self.view addSubview:msgLabel];
            [msgLabel release];
            
            if (i == 0)
            {
                titleLabel.text = @"特色一：";
                msgLabel.text = FeatureMsg1;
            }
            else if (i == 1)
            {
                titleLabel.text = @"特色二：";
                msgLabel.text = FeatureMsg2;
            }
            else
            {
                titleLabel.text = @"特色三：";
                msgLabel.text = FeatureMsg3;
            }
        }
    }
    else if (pageType == PageType3)
    {
        [headerView loadComponentsWithTitle:@"为什么选择人人股神"];
        
        for (int i = 0; i < 3; i++)
        {
            UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(headerView.frame)+15+i*80, 290, 20)];
            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.font = BoldFontWithSize(15);
            titleLabel.textColor = [UIColor blackColor];
            [self.view addSubview:titleLabel];
            [titleLabel release];
            
            UILabel * msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(headerView.frame)+35+i*80, 290, 50)];
            msgLabel.numberOfLines = 4;
            msgLabel.backgroundColor = [UIColor clearColor];
            msgLabel.font = NormalFontWithSize(12);
            msgLabel.textColor = [UIColor blackColor];
            [self.view addSubview:msgLabel];
            [msgLabel release];
            
            if (i == 0)
            {
                titleLabel.text = @"免费炒股：";
                msgLabel.text = StockMsg1;
            }
            else if (i == 1)
            {
                titleLabel.text = @"值得信赖：";
                msgLabel.text = StockMsg2;
            }
            else
            {
                titleLabel.text = @"及时兑付：";
                msgLabel.text = StockMsg3;
            }
        }
    }
    else
    {
        [headerView loadComponentsWithTitle:@"人人股神愿景"];
        
        for (int i = 0; i < 3; i++)
        {
            UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(headerView.frame)+15+i*80, 290, 20)];
            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.font = BoldFontWithSize(15);
            titleLabel.textColor = [UIColor blackColor];
            [self.view addSubview:titleLabel];
            [titleLabel release];
            
            UILabel * msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(headerView.frame)+35+i*80, 290, 50)];
            msgLabel.numberOfLines = 4;
            msgLabel.backgroundColor = [UIColor clearColor];
            msgLabel.font = NormalFontWithSize(12);
            msgLabel.textColor = [UIColor blackColor];
            [self.view addSubview:msgLabel];
            [msgLabel release];
            
            if (i == 0)
            {
                titleLabel.text = @"使命：";
                msgLabel.text = HopeMsg1;
            }
            else if (i == 1)
            {
                titleLabel.text = @"愿景：";
                msgLabel.text = HopeMsg2;
            }
            else
            {
                titleLabel.text = @"核心价值：";
                msgLabel.text = HopeMsg3;
            }
        }
    }
    [headerView backButton];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
