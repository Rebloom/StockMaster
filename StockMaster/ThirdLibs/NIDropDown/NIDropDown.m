//
//  NIDropDown.m
//  NIDropDown
//
//  Created by Bijesh N on 12/28/12.
//  Copyright (c) 2012 Nitor Infotech. All rights reserved.
//

#import "NIDropDown.h"
#import "QuartzCore/QuartzCore.h"
#import "NSString+UIColor.h"
#import "CHNMacro.h"

@interface NIDropDown ()

@property(nonatomic, strong) UITableView *table;
@property(nonatomic, strong) UIButton *btnSender;
@property(nonatomic, strong) NSArray *list;

@end

@implementation NIDropDown

@synthesize table;
@synthesize btnSender;
@synthesize list;
@synthesize delegate;
@synthesize saveArr;

-(void)dealloc
{
}

- (id)initWithShowDropDownBtn:(UIButton *)b andHeight:(CGFloat *)height andArray:(NSArray *)arr
{
    btnSender = b;
    
    self=[super init];
    if (self) {
        CGRect btn = b.frame;
        
        self.frame = CGRectMake(0, btn.origin.y+btn.size.height, screenWidth, 0);
        self.list = [NSArray arrayWithArray:arr];
        
        table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 0)];
        table.delegate = self;
        table.dataSource = self;
        table.backgroundColor = KColorHeader;
        table.scrollEnabled = NO;
        table.separatorStyle = UITableViewCellAccessoryNone;

        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        self.frame = CGRectMake(0, btn.origin.y+btn.size.height+0.5, screenWidth, 172);
        table.frame = CGRectMake(0, 0, screenWidth, 172);
        [UIView commitAnimations];
        
        [b.superview addSubview:self];
        [self addSubview:table];
        
        self.backgroundColor = KColorHeader;
        saveArr = [NSMutableArray array];
    }
    return self;
}

-(void)hideDropDown:(UIButton *)b {
    CGRect btn = b.frame;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    self.frame = CGRectMake(0, btn.origin.y+btn.size.height, screenWidth, 0);
    table.frame = CGRectMake(0, 0, screenWidth, 0);
    [UIView commitAnimations];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}   


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    cell.alpha = 0.8;
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    if (list.count != 0)
    {
        cell.textLabel.text =[list objectAtIndex:indexPath.row];
    }
    else
    {
        cell.textLabel.text = @"行业板块";
    }
    cell.textLabel.font = NormalFontWithSize(15);
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.textColor = KFontNewColorA;
    
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 43)];
    view.backgroundColor = KSelectNewColor3;
    cell.selectedBackgroundView = view;
    
    UILabel * lineLabel  = [[UILabel alloc] init];
    lineLabel.backgroundColor = KLineNewBGColor3;
    lineLabel.frame = CGRectMake(0, 42.5, screenWidth, 0.5);
    [cell addSubview:lineLabel];
    
    cell.backgroundColor = KColorHeader;
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self hideDropDown:btnSender];
    
    UITableViewCell *c = [tableView cellForRowAtIndexPath:indexPath];
    NSString * str = [NSString stringWithFormat:@"%d", (int)indexPath.row];
    
    [btnSender setTitle:c.textLabel.text forState:UIControlStateNormal];
    btnSender.titleLabel.font=NormalFontWithSize(17);
    //文字在button上的偏移量(偏上、偏左、偏下、偏右)
    [btnSender setTitleEdgeInsets:UIEdgeInsetsMake(0.0, -30.0, 0.0,0.0)];
    [btnSender setTitleColor:KFontNewColorA forState:UIControlStateNormal];
    
    [self myDelegate:str];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 43;
}

- (void) myDelegate:(NSString*)type
{
    [self.delegate niDropDownDelegateMethod:type];
}

@end
