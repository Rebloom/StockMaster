//
//  BuySearchViewController.m
//  StockMaster
//
//  Created by Rebloom on 15/1/31.
//  Copyright (c) 2015年 Rebloom. All rights reserved.
//

#import "BuySearchViewController.h"

#import "NSString+UIColor.h"
#import "UIImage+UIColor.h"
#import "SellCell.h"
#import "ChineseInclude.h"
#import "RoyaDialView.h"

#define CELLHIGHT  20
#define CELLLY   40

@implementation BuySearchViewController

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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:kTagHideTabbarNoti object:nil];
    [stockTableview reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [headerView backButton];
    [headerView loadComponentsWithTitle:@"买入"];
    headerView.backgroundColor = kFontColorA;
    [headerView setStatusBarColor: kFontColorA];
    
    self.view.backgroundColor = KSelectNewColor;
    [self createUI];
    
    isPinyin = NO;
    searchArr = [[NSMutableArray alloc] initWithCapacity:10];
    
    //添加手势，用于回收textfield键盘
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    [self.view addGestureRecognizer:tapGr];
    
    [self createTabelView];
}

- (void)createUI
{
    if (!searchTv)
    {
        searchTv = [[GFTextField alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(headerView.frame), screenWidth, 45)];
        searchTv.placeholder = @"请输入股票代码、首字母、汉字";
        searchTv.placeHolderColor = 1;
        searchTv.layer.cornerRadius = 5;
        searchTv.layer.masksToBounds = YES;
        searchTv.userInteractionEnabled = YES;
        searchTv.backgroundColor = kFontColorA;
        searchTv.delegate = self;
        searchTv.font = NormalFontWithSize(14);
        searchTv.textColor = kTitleColorA;
        searchTv.clearButtonMode = UITextFieldViewModeWhileEditing;
        
        //关闭系统自动联想和首字母大写
        [searchTv setAutocorrectionType:UITextAutocorrectionTypeNo];
        [searchTv setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        [self.view addSubview:searchTv];
        
        UIImageView * shadowImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(headerView.frame)-1, screenWidth, 1)];
        shadowImage.image = [UIImage imageNamed:@"xiayinying"];
        [self.view addSubview:shadowImage];
    }
    [searchTv becomeFirstResponder];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFieldDidChange:)name:UITextFieldTextDidChangeNotification object:searchTv];
    
    [self showSystemInput];
}

- (void)createTabelView
{
    if (!stockTableview)
    {
        stockTableview = [[UITableView alloc] init];
    }
    stockTableview.frame = CGRectMake(0, CGRectGetMaxY(searchTv.frame), screenWidth, screenHeight-CGRectGetHeight(headerView.frame)-45);
    stockTableview.delegate = self;
    stockTableview.dataSource = self;
    stockTableview.separatorStyle = NO;
    stockTableview.backgroundColor = kBackgroundColor;
    [self.view addSubview:stockTableview];
}

- (void)onDialViewClickedIndex:(NSInteger)key
{
    switch (key)
    {
        case TAG_KEY_UNDO:
            if (searchTv.text.length)
            {
                searchTv.text = [searchTv.text stringByReplacingCharactersInRange:NSMakeRange(searchTv.text.length-1, 1) withString:@""];
            }
            break;
            
        case TAG_KEY_ABC:
            [self showSystemInput];
            break;
            
        case TAG_KEY_000:
            searchTv.text = [searchTv.text stringByAppendingString:@"000"];
            break;
            
        case TAG_KEY_002:
            searchTv.text = [searchTv.text stringByAppendingString:@"002"];
            break;
            
        default:
            searchTv.text = [searchTv.text stringByAppendingString:[NSString stringWithFormat:@"%d", (int)key]];
            break;
    }
    
    if (searchArr.count && searchTv.text.length == 0)
    {
        if (isNumberPad)
        {
            [searchArr removeAllObjects];
        }
        [stockTableview reloadData];
    }
    
    [self performSelector:@selector(detachedThread:) withObject:searchTv.text afterDelay:.3];
}

- (void)detachedThread:(NSString *)searchStr
{
    if (searchStr.length)
    {
        searchArr = [[NSMutableArray arrayWithArray:[[StockInfoCoreDataStorage sharedInstance] searchStockInfo:searchStr]] mutableCopy];
        [stockTableview reloadData];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (searchArr.count)
    {
        return 1;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return searchArr.count;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectZero];
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
                
                str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@",desc1,text]];
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
        
        if ([[StockInfoCoreDataStorage sharedInstance] isSelectStockWithCode:stockInfo.code exchange:stockInfo.exchange])
        {
            cell2.imageView.image = [UIImage imageNamed:@"buystock_disable"];
            cell2.rightBtn.selected = YES;
        }
        else
        {
            cell2.imageView.image = [UIImage imageNamed:@"buystock_normal"];
            cell2.rightBtn.selected = NO;
        }
    }
    
    else if (indexPath.row == searchArr.count && indexPath.row != 0)
    {
        cell2.backgroundColor = kFontColorA;
    }
    
    return cell2;
}

- (void)requestStockSelected:(StockInfoEntity *)stockInfo
{
    NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:stockInfo.code forKey:@"stock_code"];
    [paramDic setObject:stockInfo.exchange forKey:@"stock_exchange"];
    
    if ([[StockInfoCoreDataStorage sharedInstance] isSelectStockWithCode:stockInfo.code exchange:stockInfo.exchange])
    {
        [GFRequestManager connectWithDelegate:self action:Delete_stock_watchlist param:paramDic];
    }
    else
    {
        [GFRequestManager connectWithDelegate:self action:Submit_stock_watchlist param:paramDic];
    }
}

- (void)cellSelectedBtn:(UIButton *)btn withSection:(NSInteger)section
{
    selectedSection = section;
    selectedIndex = btn.tag;

    if (btn.tag < searchArr.count)
    {
        StockInfoEntity * stockInfo = [searchArr objectAtIndex:btn.tag];
        [self requestStockSelected:stockInfo];
    }
}

- (void)cellChooseAtIndex:(NSInteger)index WithSection:(NSInteger)section
{
    if (index < searchArr.count)
    {
        StockInfoEntity * stockInfo = [searchArr objectAtIndex:index];
        BuyStockViewController * BSVC = [[BuyStockViewController alloc] init];
        BSVC.stockInfo = stockInfo;
        [self pushToViewController:BSVC];
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    [super requestFinished:request];
    
    ASIFormDataRequest * formdataRequest = (ASIFormDataRequest *)request;

    if ([formdataRequest.action isEqualToString:Submit_stock_watchlist])
    {
        if (searchArr.count > selectedIndex)
        {
            StockInfoEntity * stockInfo = [searchArr objectAtIndex:selectedIndex];
            [[StockInfoCoreDataStorage sharedInstance] addSelectStockWithCode:stockInfo.code exchange:stockInfo.exchange];
            [[TKAlertCenter defaultCenter] postAlertWithMessage:@"加入自选成功" withType:ALERTTYPEERROR];
        }
    }
    else if ([formdataRequest.action isEqualToString:Delete_stock_watchlist])
    {
        if (searchArr.count > selectedIndex)
        {
            StockInfoEntity * stockInfo = [searchArr objectAtIndex:selectedIndex];
            [[StockInfoCoreDataStorage sharedInstance] delSelectStockWithCode:stockInfo.code exchange:stockInfo.exchange];
            [[TKAlertCenter defaultCenter] postAlertWithMessage:@"删除自选成功" withType:ALERTTYPEERROR];
        }
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
        [self showNumberPad];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (!string.length)
    {
        if (searchArr.count && searchTv.text.length == 1)
        {
            [searchArr removeAllObjects];
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
        return NO;
    }
    
    if ([searchTv.text isEqualToString:@""]) {
        [searchArr removeAllObjects];
    }
    
    if (string.length)
    {
        searchTv.placeholder = @"";
    }
    else
    {
        searchTv.placeholder = @"请输入股票代码、首字母、汉字";
    }
    
    return YES;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [searchTv resignFirstResponder];
    stockTableview.frame = CGRectMake(0, CGRectGetMaxY(searchTv.frame), screenWidth, screenHeight-CGRectGetHeight(headerView.frame)-45);
}

- (void)textFieldDidChange:(NSNotification *)noti
{
    GFTextField * field = [noti object];
    NSString * searchString = [field.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (searchString.length)
    {
        [self performSelector:@selector(detachedThread:) withObject:searchString afterDelay:.1];
    }
}

- (void)viewTapped:(UITapGestureRecognizer*)tapGr
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

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
    [searchArr removeAllObjects];
    [stockTableview reloadData];
    searchTv.text = @"";
}

- (void)showNumberPad
{
    isNumberPad = YES;
    stockTableview.frame = CGRectMake(0, CGRectGetMaxY(searchTv.frame), screenWidth, screenHeight-CGRectGetHeight(headerView.frame)-45);
    [stockTableview reloadData];
}

- (void)showSystemInput
{
    isNumberPad = NO;
    stockTableview.frame = CGRectMake(0, CGRectGetMaxY(searchTv.frame), screenWidth, screenHeight-CGRectGetHeight(headerView.frame)-CGRectGetHeight(searchTv.inputView.frame)+80);
    searchTv.inputView = nil;
    searchTv.keyboardType = UIKeyboardTypeNamePhonePad;
    [searchTv resignFirstResponder];
    [searchTv becomeFirstResponder];
    [stockTableview reloadData];
}

- (void)hideTextView
{
    stockTableview.frame = CGRectMake(0, CGRectGetMaxY(searchTv.frame), screenWidth, screenHeight-CGRectGetHeight(headerView.frame)-45);
    [searchTv resignFirstResponder];
    [stockTableview reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [searchTv resignFirstResponder];
    stockTableview.frame = CGRectMake(0, CGRectGetMaxY(searchTv.frame), screenWidth, screenHeight-CGRectGetHeight(headerView.frame)-45);
    [super viewWillDisappear:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
