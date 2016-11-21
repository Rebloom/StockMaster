//
//  SearchViewController.m
//  StockMaster
//
//  Created by dalikeji on 14-9-3.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "SearchViewController.h"
#import "NSString+UIColor.h"
#import "UIImage+UIColor.h"
#import "SellCell.h"
#import "StockDetailViewController.h"
#import "StockLineViewController.h"
#import "ChineseInclude.h"

@interface SearchViewController ()

@end

@implementation SearchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
}

- (void)clearSearchArr
{
    [searchArr removeAllObjects];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:kTagHideTabbarNoti object:nil];
    searchArr = [[NSMutableArray arrayWithArray:[[StockInfoCoreDataStorage sharedInstance] getSearchHistory]] mutableCopy];
    if (searchArr.count)
    {
        sectionFlag = 0 ;
    }
    else
    {
        sectionFlag = 1;
    }
    [stockTableview reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [headerView backButton];
    [headerView createLine];
    headerView.backgroundColor = kFontColorA;
    [headerView setStatusBarColor: kFontColorA];
    
    self.view.backgroundColor = KSelectNewColor;
    [self createUI];
    
    searchArr = [[NSMutableArray alloc] initWithCapacity:10];
    
    selectStockArr = [[[StockInfoCoreDataStorage sharedInstance] getSelectStock] mutableCopy];
    
    isPinyin = NO;
    
    //添加手势，用于回收textfield键盘
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    [self.view addGestureRecognizer:tapGr];
    
    [self createTabelView];
    
    [self requestSelect];
    [self requestHotSearch];
}

-(void)createUI
{
    if (!searchTv)
    {
        searchTv = [[GFTextField alloc] init ];
        searchTv.placeHolderColor = 1;
        searchTv.frame = CGRectMake(50, 28, screenWidth-70, 30);
        searchTv.layer.cornerRadius = 5;
        searchTv.placeholder = @"请输入股票代码/首字母/汉字";
        searchTv.layer.masksToBounds = YES;
        searchTv.userInteractionEnabled = YES;
        searchTv.backgroundColor = kFontColorA;
        searchTv.delegate = self;
        searchTv.layer.cornerRadius = 3;
        searchTv.layer.borderWidth = 0.3;
        searchTv.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        searchTv.font = NormalFontWithSize(14);
        searchTv.textColor = kTitleColorA;
        searchTv.clearButtonMode = UITextFieldViewModeWhileEditing;
        //关闭系统自动联想和首字母大写
        [searchTv setAutocorrectionType:UITextAutocorrectionTypeNo];
        [searchTv setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        [headerView addSubview:searchTv];
    }
    [searchTv becomeFirstResponder ];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFieldDidChange:)name:UITextFieldTextDidChangeNotification object:searchTv];
    
    [self showSystemInput];
    
    if (!royaDialView)
    {
        royaDialView = [[RoyaDialView alloc]init];
    }
    royaDialView.frame =  CGRectMake(0, ([[UIScreen mainScreen] bounds].size.height -210-20), screenWidth, 265);
}

-(void)createTabelView
{
    if (!stockTableview)
    {
        stockTableview = [[UITableView alloc]init ];
    }
    stockTableview.frame = CGRectMake(0, CGRectGetMaxY(headerView.frame), screenWidth, screenHeight-CGRectGetHeight(headerView.frame));
    stockTableview.delegate = self;
    stockTableview.dataSource = self;
    stockTableview.separatorStyle = NO;
    stockTableview.backgroundColor = kBackgroundColor;
    [self.view addSubview:stockTableview];
}

- (void)detachedThread:(NSString *)searchStr
{
    if (searchStr.length)
    {
        searchArr = [[NSMutableArray arrayWithArray: [[StockInfoCoreDataStorage sharedInstance] searchStockInfo:searchStr]] mutableCopy];
        sectionFlag = 2;
        [stockTableview reloadData];
    }
}

#define CELLHIGHT  20
#define CELLLY   40

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(sectionFlag == 0)
    {
        if (indexPath.section == 0)
        {
            if (indexPath.row == searchArr.count && searchArr.count!=0)
            {
                return 20.f;
            }
        }
        else if (indexPath.section == 1)
        {
            if (indexPath.row == hotArr.count && hotArr.count!=0)
            {
                return 20.f;
            }
        }
    }
    else if (sectionFlag == 1)
    {
        if (indexPath.section == 0)
        {
            if (indexPath.row == hotArr.count && hotArr.count!=0)
            {
                return 20.f;
            }
        }
    }
    else if (sectionFlag == 2)
    {
        if (indexPath.row == searchArr.count && searchArr.count!=0)
        {
            return 20.f;
        }
    }
    return 65.f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (sectionFlag == 2)
    {
        return 0;
    }
    return 52.f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(sectionFlag == 0)
    {
        return 2;
    }
    else if (sectionFlag == 1||sectionFlag == 2)
    {
        return 1;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if(sectionFlag == 0)
    {
        if (section == 0)
        {
            indexSection = 0;
            return searchArr.count+1;
        }
        else if (section == 1)
        {
            indexSection = 1;
            return hotArr.count ;
        }
    }
    else if (sectionFlag == 1)
    {
        if (section == 0)
        {
            indexSection = 0;
            return hotArr.count ;
        }
    }
    else if (sectionFlag == 2)
    {
        indexSection = 0;
        return searchArr.count;
    }
    return 0;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * view = [[UIView alloc ]initWithFrame:CGRectMake(0, 0, screenWidth, 52)];
    view.backgroundColor = KSelectNewColor;
    view.userInteractionEnabled = YES;
    
    if (sectionFlag == 0)
    {
        if (section == 0)
        {
            for (int i = 0; i<2; i++) {
                UILabel * label = [[UILabel alloc] init];
                if (i == 0)
                {
                    label.frame = CGRectMake(20, 0, 100, 52);
                    label.textAlignment = NSTextAlignmentLeft;
                    label.text = @"历史记录";
                    label.textColor = KFontNewColorA;
                }
                else if (i == 1)
                {
                    label.frame = CGRectMake(screenWidth-120, 0, 100, 52);
                    label.textAlignment = NSTextAlignmentRight;
                    label.text = @"删除历史";
                    label.textColor = kGreenColor;
                }
                label.font = NormalFontWithSize(15);
                label.backgroundColor = [UIColor clearColor];
                [view addSubview:label];
            }
            
            UIButton * deleteBtn = [[UIButton alloc] init];
            deleteBtn.frame = CGRectMake(screenWidth-70, 0, screenWidth, 52);
            deleteBtn.tag = 1234;
            [deleteBtn setBackgroundColor:[UIColor clearColor]];
            [deleteBtn addTarget:self action:@selector(deleteBtnOnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [view addSubview:deleteBtn];
        }
        else if(section == 1)
        {
            UILabel * label = [[UILabel alloc] init];
            label.frame = CGRectMake(20, 0, 100, 52);
            label.textAlignment = NSTextAlignmentLeft;
            label.text = @"热门搜索";
            label.textColor = KFontNewColorA;
            label.font = NormalFontWithSize(15);
            label.backgroundColor = [UIColor clearColor];
            [view addSubview:label];
        }
    }
    else if (sectionFlag == 1)
    {
        UILabel * label = [[UILabel alloc] init];
        label.frame = CGRectMake(20, 0, 100, 52);
        label.textAlignment = NSTextAlignmentLeft;
        label.text = @"热门搜索";
        label.textColor = KFontNewColorA;
        label.font = NormalFontWithSize(15);
        label.backgroundColor = [UIColor clearColor];
        [view addSubview:label];
    }
    else if (sectionFlag == 2)
    {
        view.frame = CGRectZero;
    }
    return view;
}

-(void)deleteBtnOnClicked:(UIButton*)sender
{
    if (searchArr.count>0)
    {
        [self clearSearchArr];
        [[StockInfoCoreDataStorage sharedInstance] clearSearchHistory];
    }
    sectionFlag = 1;
    [stockTableview reloadData];
}

#pragma mark UITableViewCell

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellStock = @"cellStock";
    static NSString * SearchStockCell = @"SEARCHCELL";
    
    SellCell * cell2 = [tableView dequeueReusableCellWithIdentifier:cellStock];
    if (cell2 == nil)
    {
        cell2 = [[SellCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellStock];
    }
    cell2.stockID.backgroundColor = kFontColorA;
    cell2.stockName.backgroundColor = kFontColorA;
    cell2.stockID.frame = CGRectZero;
    cell2.stockName.frame = CGRectZero;
    if (sectionFlag == 0)
    {
        if (indexPath.section == 0)
        {
            if (indexPath.row < searchArr.count)
            {
                cell2.backgroundColor = kFontColorA;
                cell2.delegate = self;
                cell2.stockID.frame = CGRectMake(15, CELLLY, 100, CELLHIGHT);
                cell2.stockName.frame = CGRectMake(CGRectGetMaxX(cell2.stockID.frame),CELLLY, 100, CELLHIGHT);
                
                cell2.tag = indexPath.section+1;
                cell2.rightBtnTag = indexPath.row;
                cell2.leftBtn.tag = indexPath.row;
                
                SearchHistoryEntity * searchHistory = [searchArr objectAtIndex:indexPath.row];
                cell2.stockName.text = searchHistory.stockInfo.name;
                cell2.stockID.text = searchHistory.stockInfo.code;
                cell2.rightBtn.hidden = NO;
                
                cell2.imageView.frame = CGRectMake(26, 38, 23, 23);
                cell2.imageView.image = [UIImage imageNamed:@"buystock_normal"];
                cell2.rightBtn.selected = NO;
                
                if ([[StockInfoCoreDataStorage sharedInstance] isSelectStockWithCode:searchHistory.stockInfo.code exchange:searchHistory.stockInfo.exchange])
                {
                    cell2.imageView.image = [UIImage imageNamed:@"buystock_disable"];
                    cell2.rightBtn.selected = YES;
                }
            }
            else if (indexPath.row == searchArr.count && indexPath.row != 0)
            {
                cell2.backgroundColor = kFontColorA;
            }
        }
        else if (indexPath.section == 1)
        {
            if (indexPath.row < hotArr.count)
            {
                cell2.backgroundColor = kFontColorA;
                cell2.delegate = self;
                cell2.stockID.frame = CGRectMake(15, CELLLY, 100, CELLHIGHT);
                cell2.stockName.frame = CGRectMake(CGRectGetMaxX(cell2.stockID.frame),CELLLY, 100, CELLHIGHT);
                
                cell2.tag = indexPath.section+1;
                cell2.rightBtnTag = indexPath.row;
                cell2.leftBtn.tag = indexPath.row;
                
                StockInfoEntity * stockInfo = [hotArr objectAtIndex:indexPath.row];
                cell2.stockName.text = stockInfo.name;
                cell2.stockID.text = stockInfo.code;
                cell2.rightBtn.hidden = NO;
                
                cell2.imageView.frame = CGRectMake(26, 38, 23, 23);
                cell2.imageView.image = [UIImage imageNamed:@"buystock_normal"];
                cell2.rightBtn.selected = NO;
                
                if ([[StockInfoCoreDataStorage sharedInstance] isSelectStockWithCode:stockInfo.code exchange:stockInfo.exchange])
                {
                    cell2.imageView.image = [UIImage imageNamed:@"buystock_disable"];
                    cell2.rightBtn.selected = YES;
                }
            }
            else if (indexPath.row == hotArr.count && indexPath.row != 0)
            {
                cell2.backgroundColor = kFontColorA;
            }
        }
    }
    else if (sectionFlag == 1)
    {
        if (indexPath.row < hotArr.count)
        {
            cell2.backgroundColor = kFontColorA;
            cell2.delegate = self;
            cell2.stockID.frame = CGRectMake(15, CELLLY, 100, CELLHIGHT);
            cell2.stockName.frame = CGRectMake(CGRectGetMaxX(cell2.stockID.frame),CELLLY, 100, CELLHIGHT);
            
            cell2.tag = indexPath.section+1;
            cell2.rightBtnTag = indexPath.row;
            cell2.leftBtn.tag = indexPath.row;
            
            StockInfoEntity * stockInfo = [hotArr objectAtIndex:indexPath.row];
            cell2.stockName.text = stockInfo.name;
            cell2.stockID.text = stockInfo.code;
            cell2.rightBtn.hidden = NO;
            
            cell2.imageView.frame = CGRectMake(26, 38, 23, 23);
            cell2.imageView.image = [UIImage imageNamed:@"buystock_normal"];
            cell2.rightBtn.selected = NO;
            
            if ([[StockInfoCoreDataStorage sharedInstance] isSelectStockWithCode:stockInfo.code exchange:stockInfo.exchange])
            {
                cell2.imageView.image = [UIImage imageNamed:@"buystock_disable"];
                cell2.rightBtn.selected = YES;
            }
        }
        else if (indexPath.row == hotArr.count && indexPath.row != 0)
        {
            cell2.backgroundColor = kFontColorA;
        }
    }
    else if (sectionFlag == 2)
    {
        cell2 = [tableView dequeueReusableCellWithIdentifier:SearchStockCell];
        if (!cell2)
        {
            cell2 = [[SellCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SearchStockCell];
        }
        cell2.stockID.backgroundColor = kFontColorA;
        cell2.stockName.backgroundColor = kFontColorA;
        cell2.stockID.frame = CGRectZero;
        cell2.stockName.frame = CGRectZero;
        
        if (indexPath.row < searchArr.count)
        {
            cell2.backgroundColor = kFontColorA;
            cell2.delegate = self;
            cell2.stockID.frame = CGRectMake(15, CELLLY, 100, CELLHIGHT);
            cell2.stockName.frame = CGRectMake(CGRectGetMaxX(cell2.stockID.frame),CELLLY, 100, CELLHIGHT);
            
            cell2.tag = indexPath.section+1;
            cell2.rightBtnTag = indexPath.row;
            cell2.leftBtn.tag = indexPath.row;
            
            StockInfoEntity * stockInfo = [searchArr objectAtIndex:indexPath.row];
            cell2.stockName.text = stockInfo.name;
            cell2.stockID.text = stockInfo.code;
            cell2.rightBtn.hidden = NO;
            
            if (searchTv.text.length > 0 && ![ChineseInclude isIncludeChineseInString:searchTv.text])
            {
                NSString * desc1 = @"";
                NSString * text = @"";
                if ([Utility isPureInt:searchTv.text])
                {
                    //数字搜索
                    desc1 = searchTv.text;
                    text = [stockInfo.code substringFromIndex:searchTv.text.length];
                }
                else
                {
                    //拼音搜索
                    if (searchTv.text.length <= stockInfo.name.length)
                    {
                        desc1 = [stockInfo.name substringToIndex:searchTv.text.length];
                        text = [stockInfo.name substringFromIndex:searchTv.text.length];
                    }
                }
                NSMutableAttributedString * str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@",desc1,text]];
                
                [str addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0,desc1.length)];
                
                [str addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(desc1.length,text.length)];
                
                [str addAttribute:NSFontAttributeName value:NormalFontWithSize(15) range:NSMakeRange(0,desc1.length)];
                
                [str addAttribute:NSFontAttributeName value:NormalFontWithSize(15) range:NSMakeRange(desc1.length,text.length)];
                
                if ([Utility isPureInt:searchTv.text])
                {
                    cell2.stockID.attributedText = str;
                    cell2.stockName.text = stockInfo.name;
                }
                else
                {
                    cell2.stockName.attributedText = str;
                    cell2.stockID.text = stockInfo.code;
                }
            }
            else if (searchTv.text.length>0&&[ChineseInclude isIncludeChineseInString:searchTv.text])
            {
                NSString * desc1 = @"";
                NSString * text = @"";
                NSString * desc2 = @"";
                
                NSString *string1 = stockInfo.name;
                NSString *string2 = searchTv.text;
                NSRange range = [string1 rangeOfString:string2];
                NSInteger location = range.location;
                
                NSMutableAttributedString *str =  nil;
                
                if (location == 0)
                {
                    desc1 = [stockInfo.name substringToIndex:searchTv.text.length];
                    text = [stockInfo.name substringFromIndex:searchTv.text.length];
                    
                    str =  [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@",desc1,text]];
                    [str addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0,desc1.length)];
                    [str addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(desc1.length,text.length)];
                    [str addAttribute:NSFontAttributeName value:NormalFontWithSize(15) range:NSMakeRange(0,desc1.length)];
                    [str addAttribute:NSFontAttributeName value:NormalFontWithSize(15) range:NSMakeRange(desc1.length,text.length)];
                    
                }
                else
                {
                    desc1 = [stockInfo.name substringToIndex:location];
                    text = searchTv.text;
                    desc2 = [stockInfo.name substringFromIndex:location+text.length];
                    
                    str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@%@",desc1,text,desc2]];
                    [str addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0,location)];
                    [str addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(location,searchTv.text.length)];
                    [str addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(location+searchTv.text.length,desc2.length)];
                    
                    [str addAttribute:NSFontAttributeName value:NormalFontWithSize(15) range:NSMakeRange(0,desc1.length)];
                    [str addAttribute:NSFontAttributeName value:NormalFontWithSize(15) range:NSMakeRange(desc1.length,text.length)];
                    [str addAttribute:NSFontAttributeName value:NormalFontWithSize(15) range:NSMakeRange(desc1.length+text.length,desc2.length)];
                }
                cell2.stockName.attributedText = str;
                cell2.stockID.text = stockInfo.code;
                
            }
            else if (searchTv.text.length == 0)
            {
                [stockTableview reloadData];
            }
            
            cell2.imageView.frame = CGRectMake(26, 38, 23, 23);
            cell2.imageView.image = [UIImage imageNamed:@"buystock_normal"];
            cell2.rightBtn.selected = NO;
            
            if ([[StockInfoCoreDataStorage sharedInstance] isSelectStockWithCode:stockInfo.code exchange:stockInfo.exchange])
            {
                cell2.imageView.image = [UIImage imageNamed:@"buystock_disable"];
                cell2.rightBtn.selected = YES;
            }
        }
        else if (indexPath.row == searchArr.count && indexPath.row != 0)
        {
            cell2.backgroundColor = kFontColorA;
        }
    }
    return cell2;
}

- (void)requestStockSelected:(StockInfoEntity *)stockInfo Status:(NSInteger)type
{
    NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:stockInfo.code forKey:@"stock_code"];
    [paramDic setObject:stockInfo.exchange forKey:@"stock_exchange"];
    if (type == 1)
    {
        [GFRequestManager connectWithDelegate:self action:Submit_stock_watchlist param:paramDic];
    }
    else if(type == 0)
    {
        [GFRequestManager connectWithDelegate:self action:Delete_stock_watchlist param:paramDic];
    }
}

- (void)cellSelectedBtn:(UIButton *)btn withSection:(NSInteger)section
{
    selectedSection = section;
    selectedIndex = btn.tag;
    
    if (sectionFlag == 0)
    {
        if (section == 1)
        {
            if (btn.tag < searchArr.count)
            {
                SearchHistoryEntity * searchHistory = [searchArr objectAtIndex:btn.tag];
                [self requestStockSelected:searchHistory.stockInfo Status:![[StockInfoCoreDataStorage sharedInstance] isSelectStockWithCode:searchHistory.stockInfo.code exchange:searchHistory.stockInfo.exchange]];
            }
        }
        else if (section == 2)
        {
            if (btn.tag < hotArr.count)
            {
                StockInfoEntity * stockInfo = [hotArr objectAtIndex:btn.tag];
                [self requestStockSelected:stockInfo Status:![[StockInfoCoreDataStorage sharedInstance] isSelectStockWithCode:stockInfo.code exchange:stockInfo.exchange]];
            }
        }
    }
    else if (sectionFlag == 1)
    {
        if (btn.tag < hotArr.count)
        {
            StockInfoEntity * stockInfo = [hotArr objectAtIndex:btn.tag];
            [self requestStockSelected:stockInfo Status:![[StockInfoCoreDataStorage sharedInstance] isSelectStockWithCode:stockInfo.code exchange:stockInfo.exchange]];
        }
    }
    else if (sectionFlag == 2)
    {
        if (btn.tag < searchArr.count)
        {
            StockInfoEntity * stockInfo = [searchArr objectAtIndex:btn.tag];
            [self requestStockSelected:stockInfo Status:![[StockInfoCoreDataStorage sharedInstance] isSelectStockWithCode:stockInfo.code exchange:stockInfo.exchange]];
        }
    }
}

- (void)cellChooseAtIndex:(NSInteger)index WithSection:(NSInteger)section
{
    if (sectionFlag == 0)
    {
        if (section == 1)
        {
            index = index - 0;
            if (index < searchArr.count)
            {
                SearchHistoryEntity * searchHistory = [searchArr objectAtIndex:index];
                [[StockInfoCoreDataStorage sharedInstance] addSearchHistoryWithCode:searchHistory.stockInfo.code exchange:searchHistory.stockInfo.exchange];
                
                StockDetailViewController * SDVC = [[StockDetailViewController alloc] init];
                SDVC.stockInfo = searchHistory.stockInfo;
                [self pushToViewController:SDVC];
            }
        }
        else if (section == 2)
        {
            index = index;
            if (index < hotArr.count)
            {
                StockInfoEntity * stockInfo = [hotArr objectAtIndex:index];
                [[StockInfoCoreDataStorage sharedInstance] addSearchHistoryWithCode:stockInfo.code exchange:stockInfo.exchange];
                
                StockDetailViewController * SDVC = [[StockDetailViewController alloc] init];
                SDVC.stockInfo = stockInfo;
                [self pushToViewController:SDVC];
            }
        }
    }
    if (sectionFlag == 1)
    {
        if (index < hotArr.count)
        {
            StockInfoEntity * stockInfo = [hotArr objectAtIndex:index];
            [[StockInfoCoreDataStorage sharedInstance] addSearchHistoryWithCode:stockInfo.code exchange:stockInfo.exchange];
            
            StockDetailViewController * SDVC = [[StockDetailViewController alloc] init];
            SDVC.stockInfo = stockInfo;
            [self pushToViewController:SDVC];
        }
    }
    if (sectionFlag == 2)
    {
        if (index < searchArr.count)
        {
            StockInfoEntity * stockInfo = [searchArr objectAtIndex:index];
            [[StockInfoCoreDataStorage sharedInstance] addSearchHistoryWithCode:stockInfo.code exchange:stockInfo.exchange];
            
            StockDetailViewController * SDVC = [[StockDetailViewController alloc] init];
            SDVC.stockInfo = stockInfo;
            [self pushToViewController:SDVC];
        }
    }
    
}

- (void)requestSelect
{
    NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
    [GFRequestManager connectWithDelegate:self action:Get_stock_watchlist param:paramDic];
}

-(void)requestHotSearch
{
    NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:@"5" forKey:@"size"];
    [GFRequestManager connectWithDelegate:self action:Get_hot_stock_search param:paramDic];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    [super requestFinished:request];
    
    ASIFormDataRequest * formdataRequest = (ASIFormDataRequest *)request;
    if ([formdataRequest.action isEqualToString:Get_stock_watchlist])
    {
        NSArray * selectArr = [requestInfo objectForKey:@"data"];
        [[StockInfoCoreDataStorage sharedInstance] saveSelectStock:selectArr];
    }
    else if ([formdataRequest.action isEqualToString:Submit_stock_watchlist])
    {
        if (sectionFlag == 0)
        {
            if (selectedSection == 1)
            {
                if (searchArr.count > selectedIndex)
                {
                    SearchHistoryEntity * searchHistory = [searchArr objectAtIndex:selectedIndex];
                    
                    [[StockInfoCoreDataStorage sharedInstance] addSelectStockWithCode:searchHistory.stockInfo.code exchange:searchHistory.stockInfo.exchange];
                    [[TKAlertCenter defaultCenter] postAlertWithMessage:@"加入自选成功" withType:ALERTTYPEERROR];
                    [stockTableview reloadData];
                }
            }
            else if (selectedSection == 2)
            {
                if (hotArr.count > selectedIndex)
                {
                    StockInfoEntity * stockInfo = [hotArr objectAtIndex:selectedIndex];
                    
                    [[StockInfoCoreDataStorage sharedInstance] addSelectStockWithCode:stockInfo.code exchange:stockInfo.exchange];
                    [[TKAlertCenter defaultCenter] postAlertWithMessage:@"加入自选成功" withType:ALERTTYPEERROR];
                    [stockTableview reloadData];
                }
            }
            
        }
        else if (sectionFlag == 1)
        {
            if (hotArr.count > selectedIndex)
            {
                StockInfoEntity * stockInfo = [hotArr objectAtIndex:selectedIndex];
                
                [[StockInfoCoreDataStorage sharedInstance] addSelectStockWithCode:stockInfo.code exchange:stockInfo.exchange];
                [[TKAlertCenter defaultCenter] postAlertWithMessage:@"加入自选成功" withType:ALERTTYPEERROR];
                [stockTableview reloadData];
            }
        }
        else if (sectionFlag == 2)
        {
            if (searchArr.count > selectedIndex)
            {
                StockInfoEntity * stockInfo = [searchArr objectAtIndex:selectedIndex];
                
                [[StockInfoCoreDataStorage sharedInstance] addSelectStockWithCode:stockInfo.code exchange:stockInfo.exchange];
                [[TKAlertCenter defaultCenter] postAlertWithMessage:@"加入自选成功" withType:ALERTTYPEERROR];
                [stockTableview reloadData];
            }
        }
    }
    else if ([formdataRequest.action isEqualToString:Delete_stock_watchlist])
    {
        if (sectionFlag == 0)
        {
            if (selectedSection == 1)
            {
                if (searchArr.count > selectedIndex)
                {
                    SearchHistoryEntity * searchHistory = [searchArr objectAtIndex:selectedIndex];
                    [[StockInfoCoreDataStorage sharedInstance] delSelectStockWithCode:searchHistory.stockInfo.code exchange:searchHistory.stockInfo.exchange];
                    [[TKAlertCenter defaultCenter] postAlertWithMessage:@"删除自选成功" withType:ALERTTYPEERROR];
                    [stockTableview reloadData];
                }
            }
            else if (selectedSection == 2)
            {
                if (hotArr.count > selectedIndex)
                {
                    StockInfoEntity * stockInfo = [hotArr objectAtIndex:selectedIndex];
                    [[StockInfoCoreDataStorage sharedInstance] delSelectStockWithCode:stockInfo.code exchange:stockInfo.exchange];
                    [[TKAlertCenter defaultCenter] postAlertWithMessage:@"删除自选成功" withType:ALERTTYPEERROR];
                    [stockTableview reloadData];
                }
            }
        }
        else if (sectionFlag == 1)
        {
            if (hotArr.count > selectedIndex)
            {
                StockInfoEntity * stockInfo = [hotArr objectAtIndex:selectedIndex];
                [[StockInfoCoreDataStorage sharedInstance] delSelectStockWithCode:stockInfo.code exchange:stockInfo.exchange];
                [[TKAlertCenter defaultCenter] postAlertWithMessage:@"删除自选成功" withType:ALERTTYPEERROR];
                [stockTableview reloadData];
            }
        }
        else if (sectionFlag == 2)
        {
            if (searchArr.count > selectedIndex)
            {
                StockInfoEntity * stockInfo = [searchArr objectAtIndex:selectedIndex];
                [[StockInfoCoreDataStorage sharedInstance] delSelectStockWithCode:stockInfo.code exchange:stockInfo.exchange];
                [[TKAlertCenter defaultCenter] postAlertWithMessage:@"删除自选成功" withType:ALERTTYPEERROR];
            [stockTableview reloadData];
            }
        }
    }
    else if ([formdataRequest.action isEqualToString:Get_hot_stock_search])
    {
        NSMutableArray * arr = [requestInfo objectForKey:@"data"];
        NSMutableArray * infoArray = [[NSMutableArray alloc] init];
        for (int i = 0; i<arr.count; i++)
        {
            StockInfoEntity * stockInfo = [[StockInfoCoreDataStorage sharedInstance] getStockInfoWithCode:[[arr objectAtIndex:i] objectForKey:@"stock_code"] exchange:[[arr objectAtIndex:i] objectForKey:@"stock_exchange"]];
            [infoArray addObject:stockInfo];
        }
        
        hotArr = [infoArray copy];
    }
    [self performSelector:@selector(delayLoadTableView) withObject:nil afterDelay:.1];
}

- (void)delayLoadTableView
{
    [stockTableview reloadData];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (isNumberPad)
    {
        [self showSystemInput];
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if (searchArr.count)
    {
        return;
    }
    else
    {
        [self reloadSearchType];
    }
}

- (void)reloadSearchType
{
    searchArr = [[NSMutableArray arrayWithArray:[[StockInfoCoreDataStorage sharedInstance] getSearchHistory]] mutableCopy];
    if (searchArr.count)
    {
        sectionFlag = 0 ;
    }
    else
    {
        sectionFlag = 1;
    }
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (!string.length)
    {
        if (searchArr.count && searchTv.text.length == 1)
        {
            [self clearSearchArr];
            [self reloadSearchType];
            [stockTableview reloadData];
        }
        if (searchTv.text)
        {
            NSString * str = @"";
            if (searchTv.text.length > 1)
            {
                str = [searchTv.text substringToIndex:searchTv.text.length-1];
            }
        }
        return YES; 
    }
    
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        searchTv.inputView = royaDialView;
        [self clearSearchArr];
        [self reloadSearchType];
        [stockTableview reloadData];
        return NO;
    }
    
    if (string.length)
    {
        searchTv.placeholder = @"";
    }
    else
    {
        searchTv.placeholder = @"请输入要查询股票的代码";
    }
    
    return YES;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [searchTv resignFirstResponder];
    stockTableview.frame = CGRectMake(0, CGRectGetMaxY(headerView.frame), screenWidth, screenHeight-CGRectGetHeight(headerView.frame));
}

- (void)textFieldDidChange:(NSNotification *)noti
{
    GFTextField * field = [noti object];
    NSString * searchString = [field.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (searchString.length)
    {
        [self performSelector:@selector(detachedThread:) withObject:searchString afterDelay:.1];
    }
    else
    {
        [self clearSearchArr];
        [self reloadSearchType];
        [stockTableview reloadData];
    }
}

-(void)viewTapped:(UITapGestureRecognizer*)tapGr
{
    [self hideTextView];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField==searchTv)
    {
        [searchTv resignFirstResponder];
    }
    return YES;
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
    [self clearSearchArr];
    [stockTableview reloadData];
    searchTv.text = @"";
}

- (void)showSystemInput
{
    isNumberPad = NO;
    stockTableview.frame = CGRectMake(0, CGRectGetMaxY(headerView.frame), screenWidth, screenHeight-CGRectGetHeight(headerView.frame)-CGRectGetHeight(searchTv.inputView.frame)+80);
    searchTv.inputView = nil;
    searchTv.keyboardType = UIKeyboardTypeNamePhonePad;
    [searchTv resignFirstResponder];
    [searchTv becomeFirstResponder];
    searchArr = [[NSMutableArray arrayWithArray:[[StockInfoCoreDataStorage sharedInstance] getSearchHistory]] mutableCopy];
    [stockTableview reloadData];
    
}

- (void)hideTextView
{
    stockTableview.frame = CGRectMake(0, CGRectGetMaxY(headerView.frame), screenWidth, screenHeight-CGRectGetHeight(headerView.frame));
    [searchTv resignFirstResponder];
    [stockTableview reloadData];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [searchTv resignFirstResponder];
    stockTableview.frame = CGRectMake(0, CGRectGetMaxY(headerView.frame), screenWidth, screenHeight-CGRectGetHeight(headerView.frame));
    [super viewWillDisappear:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
