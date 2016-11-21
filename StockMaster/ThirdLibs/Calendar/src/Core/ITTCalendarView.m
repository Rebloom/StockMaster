//
//  ITTCalendarView.m
//  ZHJCalendar
//
//  Created by huajian zhou on 12-4-12.
//  Copyright (c) 2012年 itotemstudio. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ITTCalendarView.h"
#import "ITTCalMonth.h"
#import "ITTCalDay.h"
#import "ITTCalendarViewHeaderView.h"

#define MARGIN_LEFT                              5
#define MARGIN_TOP                               9
#define PADDING_VERTICAL                         5
#define PADDING_HORIZONTAL                       3

@interface ITTCalendarView()
{
    NSTimeInterval          _swipeTimeInterval;
    NSTimeInterval          _begintimeInterval;
}

@property (retain, nonatomic) ITTCalMonth *calMonth;
@property (retain, nonatomic) IBOutlet UIView *weekHintView;
@property (retain, nonatomic) IBOutlet UIView *headerView;
@property (retain, nonatomic) IBOutlet UIView *footerView;
@property (retain, nonatomic) IBOutlet ITTCalendarScrollView *gridScrollView;

- (void)initParameters;
- (void)removeGridViewAtRow:(NSUInteger) row column:(NSUInteger)column;
- (void)addGridViewAtRow:(ITTCalendarGridView*)gridView row:(NSUInteger) row column:(NSUInteger)column;
- (void)layoutGridCells;
- (void)recyleAllGridViews;
- (void)resetSelectedIndicesMatrix;
- (void)resetFoucsMatrix;
- (void)updateSelectedGridViewState;

- (void)setSelectedAtRow:(NSUInteger)row column:(NSUInteger)column selected:(BOOL)selected;
- (BOOL)isSelectedAtRow:(NSUInteger)row column:(NSUInteger)column;
- (BOOL)isGridViewSelectedEnableAtRow:(NSUInteger)row column:(NSUInteger)column;

- (ITTCalendarGridView*)getGridViewAtRow:(NSUInteger) row column:(NSUInteger)column;

- (NSUInteger)getRows;
- (NSUInteger)getMonthDayAtRow:(NSUInteger)row column:(NSUInteger)column;

- (NSString*)findMonthDescription;
- (NSArray*)findWeekTitles;

- (ITTCalendarViewHeaderView*)findHeaderView;
- (ITTCalendarViewFooterView*)findFooterview;

- (ITTCalendarGridView*)gridViewAtRow:(NSUInteger)row column:(NSUInteger)column calDay:(ITTCalDay*)calDay;
- (ITTCalendarGridView*)disableGridViewAtRow:(NSUInteger)row column:(NSUInteger)column calDay:(ITTCalDay*)calDay;
- (CGRect)getFrameForRow:(NSUInteger)row column:(NSUInteger)column;

@end

@implementation ITTCalendarView

@synthesize appear;
@synthesize selectedDateArray;
@synthesize selectedDate;
@synthesize selectedPeriod = _selectedPeriod;
@synthesize calMonth = _calMonth;
@synthesize weekHintView = _weekHintView;
@synthesize selectedDay = _selectedDay;
@synthesize date = _date;
@synthesize minimumDate = _minimumDate;
@synthesize maximumDate = _maximumDate;
@synthesize delegate = _delegate;
@synthesize dataSource = _dataSource;
@synthesize headerView = _headerView;
@synthesize footerView = _footerView;
@synthesize gridScrollView = _gridScrollView;
@synthesize gridSize;


#pragma mark - private methods
- (void)initParameters
{
    _gridSize = CGSizeMake(39, 31);    
    _date = [[NSDate date] retain];    
    _calMonth = [[ITTCalMonth alloc] initWithDate:_date];            
    _selectedDay = [[_calMonth firstDay] retain];
    _gridViewsArray = [[NSMutableArray alloc] init];  
    _monthGridViewsArray = [[NSMutableArray alloc] init];  
    _recyledGridSetDic = [[NSMutableDictionary alloc] init];
    _selectedDayDic = [[NSMutableDictionary alloc] init];
    _selectedGridViewIndicesDic = [[NSMutableDictionary alloc] init];
    
    NSUInteger n = 6;
    for (NSUInteger index = 0; index < n; index++) {
        NSMutableArray *rows = [[NSMutableArray alloc] init];
        [_gridViewsArray addObject:rows];
        [rows release];
    }    
}

- (void)setDate:(NSDate *)date
{
    if (_date) {
        [_date release];
        _date = nil;        
    }
    _date = [date retain];    
    ITTCalMonth *cm = [[ITTCalMonth alloc] initWithDate:_date];
    self.calMonth = cm;
    [cm release];
}

- (void)setMaximumDate:(NSDate *)maximumDate
{
    if (_maximumDate) {
        [_maximumDate release];
        _maximumDate = nil;
    }
    _maximumDate = [maximumDate retain];
    if (_maximumDay) {
        [_maximumDay release];
        _maximumDay = nil;
    }    
    _maximumDay = [[ITTCalDay alloc] initWithDate:_maximumDate];
    
    _firstLayout = TRUE;    
    [self recyleAllGridViews];  
    [self setNeedsLayout];
}

- (void)setCalMonth:(ITTCalMonth *)calMonth
{
    [self recyleAllGridViews];      
    if (_calMonth) {
        [_calMonth release];
        _calMonth = nil;
    }
    _calMonth = [calMonth retain];
    [_selectedDay release];
    _selectedDay = nil;    
    if (_date) {
        _selectedDay = [[ITTCalDay alloc] initWithDate:_date];
    }
    else {
        _selectedDay = [[_calMonth firstDay] retain];
    }
    _firstLayout = TRUE;    
    [self setNeedsLayout];
}

- (NSUInteger)getRows
{
    NSUInteger offsetRow = [[_calMonth firstDay] getWeekDay] - 1;
    NSUInteger row = (offsetRow + _calMonth.days - 1)/NUMBER_OF_DAYS_IN_WEEK;
    return row + 1;    
}

- (NSUInteger) getMonthDayAtRow:(NSUInteger)row column:(NSUInteger)column
{
    NSUInteger offsetRow = [[_calMonth firstDay] getWeekDay] - 1;
    NSUInteger day = (row * NUMBER_OF_DAYS_IN_WEEK + 1 - offsetRow) + column;
    return day;
}

- (BOOL)isValidGridViewIndex:(GridIndex)index
{
    BOOL valid = TRUE;
    if (index.column < 0||
        index.row < 0||
        index.column >= NUMBER_OF_DAYS_IN_WEEK||
        index.row >= [self getRows]) {
        valid = FALSE;
    }
    return valid;
}

- (GridIndex)getGridViewIndex:(ITTCalendarScrollView*)calendarScrollView touches:(NSSet*)touches
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:calendarScrollView];
    GridIndex index;
    NSInteger row = (location.y - MARGIN_TOP + PADDING_VERTICAL)/(PADDING_VERTICAL + _gridSize.height);
    NSInteger column = (location.x - MARGIN_LEFT + PADDING_HORIZONTAL)/(PADDING_HORIZONTAL + _gridSize.width);
    index.row = row;
    index.column = column;
    return index;
}

- (NSString*)findMonthDescription
{
    NSString *title = nil;
    if (_dataSource && [_dataSource respondsToSelector:@selector(calendarView:titleForMonth:)]) {
        title = [_dataSource calendarView:self titleForMonth:_calMonth];
    }
    if (!title||![title length]) {        
        title = [NSString stringWithFormat:@"%d年%d月", (int)[_calMonth getYear], (int)[_calMonth getMonth]];
    }
    return title;
}

- (NSArray*)findWeekTitles
{
    NSArray *titles = nil; 
    if (_dataSource && [_dataSource respondsToSelector:@selector(weekTitlesForCalendarView:)]) {
        titles = [_dataSource weekTitlesForCalendarView:self];
    }
    if (!titles||![titles count]) {
        titles = [NSArray arrayWithObjects:@"日", @"一", @"二", @"三", @"四", @"五", @"六", nil];
    }
    return titles;
}

- (void)recyleAllGridViews
{
    /*
     * recyled all grid views
     */    
    NSMutableSet *recyledGridSet;
    for (NSMutableArray *rowGridViewsArray in _gridViewsArray) {
        for (ITTCalendarGridView *gridView in rowGridViewsArray) {
            recyledGridSet = [_recyledGridSetDic objectForKey:gridView.identifier];
            if (!recyledGridSet) {    
                recyledGridSet = [[NSMutableSet alloc] init];
                [_recyledGridSetDic setObject:recyledGridSet forKey:gridView.identifier];
                [recyledGridSet release];
            }
            gridView.selected = FALSE;
            [gridView removeFromSuperview];
            [recyledGridSet addObject:gridView];
        }     
        [rowGridViewsArray removeAllObjects];
    }
    [_monthGridViewsArray removeAllObjects];
}

- (ITTCalendarGridView*)getGridViewAtRow:(NSUInteger) row column:(NSUInteger)column
{
    ITTCalendarGridView *gridView = nil;
    NSMutableArray *rowGridViewsArray = [_gridViewsArray objectAtIndex:row];
    gridView = [rowGridViewsArray objectAtIndex:column];
    return gridView;
}

- (void)setSelectedAtRow:(NSUInteger)row column:(NSUInteger)column selected:(BOOL)selected
{
    NSString *key = [NSString stringWithFormat:@"%d%d", (int)row, (int)column];
    _selectedGridViewIndicesDic[key] = [NSString stringWithFormat:@"%d", selected];
}

- (BOOL)isSelectedAtRow:(NSUInteger)row column:(NSUInteger)column
{
    NSString *key = [NSString stringWithFormat:@"%d%d", (int)row, (int)column];
    NSString *selectedString = _selectedGridViewIndicesDic[key];
    BOOL selected = FALSE;
    if (selectedString) {
        selected = [selectedString boolValue];
    }
    return selected;
}

- (BOOL)isGridViewSelectedEnableAtRow:(NSUInteger)row column:(NSUInteger)column
{
    BOOL selectedEnable = TRUE;    
    NSUInteger day = [self getMonthDayAtRow:row column:column];
    if (day < 1 || day > _calMonth.days) {
        selectedEnable = FALSE;
    }
    else {
        ITTCalDay *calDay = [_calMonth calDayAtDay:day];
        if([self isEarlyerMinimumDay:calDay] || [self isAfterMaximumDay:calDay])
        {
            selectedEnable = FALSE;
        }        
    }
    return selectedEnable;
}

- (void)resetSelectedIndicesMatrix
{
    [_selectedGridViewIndicesDic removeAllObjects];
}

- (void)resetFoucsMatrix
{
    NSInteger n = 6;
    for (NSInteger row = 0; row < n; row++) {
    }    
}

- (NSString*) getSelectedDayKey:(NSInteger)row column:(NSInteger)column
{
    NSUInteger day = [self getMonthDayAtRow:row column:column];
    ITTCalDay *cday = [_calMonth calDayAtDay:day];
    return [NSString stringWithFormat:@"%04d%02d%02d", (int)[cday getYear], (int)[cday getMonth], (int)[cday getDay]];
}

- (NSString*) getSelectedDayKey:(ITTCalDay *)calDay
{
    return [NSString stringWithFormat:@"%04d%02d%02d", (int)[calDay getYear], (int)[calDay getMonth], (int)[calDay getDay]];
}

- (BOOL) isHistorySelectedDay:(ITTCalDay *)calDay
{
    NSString *key = [self getSelectedDayKey:calDay];
    return ([_selectedDayDic objectForKey:key] != nil);
}
/*
 * update grid state
 */
- (void)updateSelectedGridViewState
{
    ITTCalendarGridView *gridView = nil;
    NSInteger rows = [self getRows];
    for (NSInteger row = 0; row < rows; row++) {
        for (NSInteger column = 0; column < NUMBER_OF_DAYS_IN_WEEK; column++) {
            gridView = [self getGridViewAtRow:row column:column];
            //^异或符号a^b=(!a)&b+a&(!b)
            BOOL selected = [self isSelectedAtRow:row column:column];
            if (gridView.selected ^ selected) {
                gridView.selected = selected;
                NSUInteger day = [self getMonthDayAtRow:row column:column];
                if (day >0 && day <= 31) {
                    NSString *key = [self getSelectedDayKey:row column:column];
                    if (selected)
                    {
                        [_selectedDayDic setObject:@"1" forKey:key];
                    }
                    else
                    {
                        [_selectedDayDic removeObjectForKey:key];
                    }                    
                }
            }
        }
    }
}

- (BOOL)isEarlyerMinimumDay:(ITTCalDay*)calDay
{
    BOOL early = FALSE;
    if (_minimumDate) {        
        if (NSOrderedAscending == [calDay compare:_minimumDay]) {
            early = TRUE;
        }
    }
    return early;
}

- (BOOL)isAfterMaximumDay:(ITTCalDay*)calDay
{
    BOOL after = FALSE;
    if (_maximumDate) {        
        if (NSOrderedDescending == [calDay compare:_maximumDay]) {
            after = TRUE;
        }
    }
    return after;
    
}

- (void)removeGridViewAtRow:(NSUInteger) row column:(NSUInteger)column
{
    NSMutableArray *rowGridViewsArray = [_gridViewsArray objectAtIndex:row];
    if (column < [rowGridViewsArray count]) {
        [rowGridViewsArray removeObjectAtIndex:column];        
    }
}

- (void)addGridViewAtRow:(ITTCalendarGridView*)gridView row:(NSUInteger) row 
                   column:(NSUInteger)column
{
    NSMutableArray *rowGridViewsArray = [_gridViewsArray objectAtIndex:row];
    NSInteger count = [rowGridViewsArray count];
    if (column > count||column < count) {
        if (column > count) {
            NSInteger offsetCount = column - count + 1;
            for (NSInteger offset = 0; offset < offsetCount; offset++) {
                [rowGridViewsArray addObject:[NSNull null]];
            }            
        }
        [rowGridViewsArray replaceObjectAtIndex:column withObject:gridView];        
    }    
    else if (column == count) {        
        [rowGridViewsArray insertObject:gridView atIndex:column];
    }
}

- (void)layoutGridCells
{
    BOOL hasSelectedDay = FALSE;    
    NSInteger count;
    NSInteger row = 0;
    NSInteger column = 0;
    CGFloat maxHeight = 0;
    CGFloat maxWidth = 0;    
    CGRect frame;
    ITTCalDay *calDay;
    ITTCalendarGridView *gridView = nil;
    /*
     * layout grid view before selected month on calendar view
     */
    calDay = [_calMonth firstDay];
    if ([calDay getWeekDay] > 1) {
        count = [calDay getWeekDay];
        ITTCalMonth *previousMonth = [_calMonth previousMonth];
        row = 0;
        for (NSInteger day = previousMonth.days; count > 0 && day >= 1; day--) {
            calDay = [previousMonth calDayAtDay:day];
            column = [calDay getWeekDay] - 1;                        
            gridView = [self disableGridViewAtRow:row column:column calDay:calDay];
            gridView.delegate = self;
            gridView.calDay = calDay;
            gridView.row = row;
            gridView.column = column;            
            frame = [self getFrameForRow:row column:column];        
            gridView.frame = frame;
            [gridView setNeedsLayout];
            [self.gridScrollView addSubview:gridView];   
            [self addGridViewAtRow:gridView row:row column:column];
            count--;
        }
    }    
    NSUInteger offsetRow = [[_calMonth firstDay] getWeekDay] - 1;
    for (NSInteger day = 1; day <= _calMonth.days; day++) {
        calDay = [_calMonth calDayAtDay:day];
        row = (offsetRow + day - 1)/NUMBER_OF_DAYS_IN_WEEK;
        column = [calDay getWeekDay] - 1;
        gridView = [self gridViewAtRow:row column:column calDay:calDay];
        gridView.delegate = self;
        gridView.calDay = calDay;
        gridView.row = row;
        gridView.column = column;
        gridView.selectedEanable = YES;
        if ([self isHistorySelectedDay:calDay]) {
            hasSelectedDay = TRUE;
            gridView.selected = TRUE;
            [self setSelectedAtRow:row column:column selected:TRUE];
        }
        frame = [self getFrameForRow:row column:column];        
        gridView.frame = frame;
        [gridView setNeedsLayout];
        [self.gridScrollView addSubview:gridView];   
        [_monthGridViewsArray addObject:gridView];
        [self addGridViewAtRow:gridView row:row column:column];
        if (CGRectGetMaxX(frame) > maxWidth) {
            maxWidth = CGRectGetMaxX(frame);
        }
        if (CGRectGetMaxY(frame) > maxHeight) {
            maxHeight = CGRectGetMaxY(frame);
        }        
    }
    if (!hasSelectedDay) {
    }
    self.gridScrollView.contentSize = CGSizeMake(maxWidth, maxHeight + 5);        
    /*
     * layout grid view after selected month on calendar view
     */
    calDay = [_calMonth lastDay];
    if ([calDay getWeekDay] < NUMBER_OF_DAYS_IN_WEEK) {
        NSUInteger days = NUMBER_OF_DAYS_IN_WEEK - [calDay getWeekDay];
        ITTCalMonth *previousMonth = [_calMonth nextMonth];
        for (NSInteger day = 1; day <= days; day++) {
            calDay = [previousMonth calDayAtDay:day];
            column = [calDay getWeekDay] - 1;                        
            gridView = [self disableGridViewAtRow:row column:column calDay:calDay];
            gridView.delegate = self;
            gridView.calDay = calDay;
            gridView.row = row;
            gridView.column = column;
            frame = [self getFrameForRow:row column:column];        
            gridView.frame = frame;
            [gridView setNeedsLayout];
            [self.gridScrollView addSubview:gridView];   
            [self addGridViewAtRow:gridView row:row column:column];
        }
    }
}

- (CGRect)getFrameForRow:(NSUInteger)row column:(NSUInteger)column
{
    CGFloat x = MARGIN_LEFT + (column - 1)*PADDING_HORIZONTAL + column*_gridSize.width;
    CGFloat y = MARGIN_TOP + (row - 1)*PADDING_VERTICAL + row*_gridSize.height;
    CGRect frame = CGRectMake(x, y, _gridSize.width, _gridSize.height);
    return frame;
}

- (ITTCalendarViewHeaderView*)findHeaderView
{
    ITTCalendarViewHeaderView *headerView = nil;
    if (_dataSource && [_dataSource respondsToSelector:@selector(headerViewForCalendarView:)]) {
        headerView = [_dataSource headerViewForCalendarView:self];
    }
    return headerView;
}

- (ITTCalendarViewFooterView*)findFooterview
{
    ITTCalendarViewFooterView *footerView = nil;
    if (_dataSource && [_dataSource respondsToSelector:@selector(footerViewForCalendarView:)]) {
        footerView = [_dataSource footerViewForCalendarView:self];
    }
    return footerView;    
}

- (ITTCalendarGridView*)gridViewAtRow:(NSUInteger)row column:(NSUInteger)column calDay:(ITTCalDay*)calDay
{
    ITTCalendarGridView *gridView = nil;
    if (_dataSource && [_dataSource respondsToSelector:@selector(calendarView:calendarGridViewForRow:column:calDay:)]) {
        gridView = [_dataSource calendarView:self calendarGridViewForRow:row column:column calDay:calDay];
    }
    return gridView;
}

- (ITTCalendarGridView*)disableGridViewAtRow:(NSUInteger)row column:(NSUInteger)column calDay:(ITTCalDay*)calDay
{
    ITTCalendarGridView *gridView = nil;
    if (_dataSource && [_dataSource respondsToSelector:@selector(calendarView:calendarDisableGridViewForRow:column:calDay:)]) {
        gridView = [_dataSource calendarView:self calendarDisableGridViewForRow:row column:column calDay:calDay];
    }
    return gridView;    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (BOOL) appear
{
    return (self.alpha > 0);
}

- (void)animationChangeMonth:(BOOL)next
{
//    CATransition *animation = [CATransition animation];
//    animation.type = kCATransitionPush;
//    if (next)
//    {
//        animation.subtype = kCATransitionFromLeft;
//        [self.gridScrollView.layer addAnimation:animation forKey:@"NextMonth"];        
//    }
//    else
//    {
//        animation.subtype = kCATransitionFromRight;
//        [self.gridScrollView.layer addAnimation:animation forKey:@"PreviousMonth"];                
//    }
    UIViewAnimationTransition options;
    if (next){
        options = UIViewAnimationTransitionCurlUp;          
    }
    else {      
        options = UIViewAnimationTransitionCurlDown;        
    }
    _calendarHeaderView.nextMonthButton.enabled = FALSE;
    _calendarHeaderView.previousMonthButton.enabled = FALSE;    
    [UIView animateWithDuration:0.3 animations:^{
        [UIView setAnimationTransition:options forView:self.gridScrollView cache:TRUE]; 
        if (next) {
            self.calMonth = [_calMonth nextMonth];
        }
        else {
            self.calMonth = [_calMonth previousMonth];                 
        }
    } completion:^(BOOL finished)
     {
         if (finished) 
         {
             _calendarHeaderView.nextMonthButton.enabled = TRUE;
             _calendarHeaderView.previousMonthButton.enabled = TRUE;                
         }
     }];
}

- (void)layoutSubviews
{
    if (_firstLayout) {
        [self layoutGridCells];    
        /*
         * layout header view
         */
        if (!_calendarHeaderView)
        {
            ITTCalendarViewHeaderView *calendarHeaderView = [self findHeaderView];
            if (calendarHeaderView) {
                if (_calendarHeaderView) {
                    [_calendarHeaderView removeFromSuperview];
                }
                CGRect frame = calendarHeaderView.bounds;
                frame.origin.x = (CGRectGetWidth(self.headerView.bounds) - CGRectGetWidth(frame))/2;
                frame.origin.y = (CGRectGetHeight(self.headerView.bounds) - CGRectGetHeight(frame))/2;        
                calendarHeaderView.delegate = self;
                calendarHeaderView.frame = frame;
                _calendarHeaderView = calendarHeaderView;
                [self.headerView addSubview:_calendarHeaderView];    
            }               
        }     
        /*
         * layout footer view
         */
        if (!_calendarFooterView) {
            ITTCalendarViewFooterView *calendarFooterView = [self findFooterview];
            if (calendarFooterView) {
                if (_calendarFooterView) {
                    [_calendarFooterView removeFromSuperview];
                }
                CGRect frame = calendarFooterView.bounds;
                frame.origin.x = (CGRectGetWidth(self.footerView.bounds) - CGRectGetWidth(frame))/2;
                frame.origin.y = (CGRectGetHeight(self.footerView.bounds) - CGRectGetHeight(frame))/2;        
                calendarFooterView.delegate = self;
                calendarFooterView.frame = frame;
                _calendarFooterView = calendarFooterView;
                [self.footerView addSubview:_calendarFooterView];    
            }        
            else {
                CGRect frame = self.frame;
                frame.size.height = CALENDAR_VIEW_HEIGHT_WITHOUT_FOOTER_VIEW;
                self.frame = frame;
            }
        }               
        /*
         * layout week hint labels
         */
        for (UIView *subview in self.weekHintView.subviews) {
            /*
             * subview is not background imageview
             */
            if (![subview isKindOfClass:[UIImageView class]]) {
                [subview removeFromSuperview];
            }
        }
        CGFloat totalWidth = self.gridScrollView.contentSize.width;
        CGFloat width = totalWidth/NUMBER_OF_DAYS_IN_WEEK;
        CGFloat marginX = 0;
        NSArray *titles = [self findWeekTitles];
        for (NSInteger i = 0; i < NUMBER_OF_DAYS_IN_WEEK; i++) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(marginX, 0, width, CGRectGetHeight(self.weekHintView.bounds))];
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = [UIColor whiteColor];
            label.font = [UIFont systemFontOfSize:14];
            label.text = [titles objectAtIndex:i];
            label.backgroundColor = [UIColor clearColor];
            label.adjustsFontSizeToFitWidth = TRUE;
            [self.weekHintView addSubview:label];
            [label release];
            marginX += width;            
        }
        _firstLayout = FALSE;
    }
    _calendarHeaderView.title = [self findMonthDescription];            
}

- (void)swipe:(UISwipeGestureRecognizer*)gesture
{
    if (fabs(_swipeTimeInterval - NSTimeIntervalSince1970) > 1.0) {
        if (_swipeTimeInterval < 2.0) {
            if (UISwipeGestureRecognizerDirectionLeft == gesture.direction) {
                [self nextMonth];
            }
            else {
                [self previousMonth];
            }            
        }
    }
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.alpha = 0.0;
    self.multipleTouchEnabled = TRUE;
    self.gridScrollView.calendarDelegate = self;    
    _firstLayout = TRUE;
    _selectedPeriod = PeriodTypeAllDay;
    _minimumDate = [[NSDate date] retain];
    _minimumDay = [[ITTCalDay alloc] initWithDate:_minimumDate];    
    _previousSelectedIndex.row = NSNotFound;
    _previousSelectedIndex.column = NSNotFound;
    [self initParameters];      
    /*
     * add left and right swipe gesture 
     */
    UISwipeGestureRecognizer *leftSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    leftSwipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    [self addGestureRecognizer:leftSwipeGesture];
    [leftSwipeGesture release];
    
    UISwipeGestureRecognizer *rightSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    rightSwipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [self addGestureRecognizer:rightSwipeGesture];
    [rightSwipeGesture release];     
}

- (void)dealloc 
{
    [_selectedGridViewIndicesDic release];
    _selectedGridViewIndicesDic = nil;
    [_selectedDayDic release];
    _selectedDayDic = nil;
    [_minimumDate release];
    _minimumDate = nil;
    _delegate = nil;
    [_dataSource release];
    _dataSource = nil;
    _calendarHeaderView = nil;
    [_selectedDay release];
    _selectedDay = nil;    
    [_recyledGridSetDic release];
    _recyledGridSetDic = nil;    
    [_gridViewsArray release];
    _gridViewsArray = nil;
    [_monthGridViewsArray release];
    _monthGridViewsArray = nil;        
    [_headerView release];
    _headerView = nil;
    [_footerView release];
    _footerView = nil;    
    [_gridScrollView release];
    _gridScrollView = nil;
    [_weekHintView release];
    [_minimumDay release];
    _minimumDay = nil;    
    [_maximumDate release];
    _maximumDate = nil;
    [_maximumDay release];
    _maximumDay = nil;
    [super dealloc];
}

#pragma mark - public methods
+ (id)viewFromNib
{
    return [[[[[NSBundle mainBundle] loadNibNamed:@"ITTCalendarView" owner:self options:nil] objectAtIndex:0] retain] autorelease];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (ITTCalendarGridView*)dequeueCalendarGridViewWithIdentifier:(NSString*)identifier
{
    ITTCalendarGridView *gridView = nil;
    NSMutableSet *recyledGridSet = [_recyledGridSetDic objectForKey:identifier];
    if (recyledGridSet) {
        gridView = [recyledGridSet anyObject];
        if (gridView) {
            [[gridView retain] autorelease];
            [recyledGridSet removeObject:gridView];
        }
    }
    return gridView;
}

- (NSDate*)selectedDate
{
    return _selectedDay.date;
}

- (NSArray*) selectedDateArray
{
    NSUInteger rows = [self getRows];
    NSMutableArray *selectedDates = [NSMutableArray array];
    for (NSUInteger row = 0; row < rows; row++) {
        for (NSUInteger column = 0; column < NUMBER_OF_DAYS_IN_WEEK; column++) {
            if ([self isSelectedAtRow:row column:column]) {
                NSUInteger day = [self getMonthDayAtRow:row column:column];
                ITTCalDay *calDay = [_calMonth calDayAtDay:day];
                [selectedDates addObject:calDay.date];
            }
        }
    }
    return selectedDates;
}

- (void)hide
{
    [UIView animateWithDuration:0.4 animations:^{
        self.alpha = 0.0;
        _parentView.alpha = 0.0;
    }];
}

- (void)addToView:(UIView *)view
{
    if (!_parentView) {
        _parentView = [[UIView alloc] initWithFrame:view.bounds];
        _parentView.alpha = 0.0;
        _parentView.backgroundColor = [UIColor whiteColor];
        [view addSubview:_parentView];
    }
    else {
        if (_parentView.superview == view) {
        }
        else {
            _parentView.alpha = 0.0;
            [_parentView removeFromSuperview];
            _parentView.frame = view.bounds;
            [view addSubview:_parentView];
        }
    }
    if (!self.superview) {
        [view addSubview:self];
    }
    else {
    }
}

- (void)showInView:(UIView*)view
{
    if (!_parentView) {
        _parentView = [[UIView alloc] initWithFrame:view.bounds];
        _parentView.alpha = 0.0;
        _parentView.backgroundColor = [UIColor whiteColor];
        [view addSubview:_parentView];
    }
    else {
        if (_parentView.superview == view) {
        }
        else {
            _parentView.alpha = 0.0;
            [_parentView removeFromSuperview];
            _parentView.frame = view.bounds;
            [view addSubview:_parentView];
        }
    }
    if (!self.superview) {
        [view addSubview:self];
    }
    else {
    }
    [UIView animateWithDuration:0.4 animations:^{
        self.alpha = 1.0;
        _parentView.alpha = 0.6;
    }];
}

- (void)nextMonth
{
    [self resetSelectedIndicesMatrix];
    [self animationChangeMonth:TRUE];
}

- (void)previousMonth
{
    [self resetSelectedIndicesMatrix];
    [self animationChangeMonth:FALSE];
}

#pragma mark - ITTCalendarViewHeaderViewDelegate
- (void)calendarViewHeaderViewNextMonth:(ITTCalendarViewHeaderView*)calendarHeaderView
{
    [self nextMonth];
}

- (void)calendarViewHeaderViewPreviousMonth:(ITTCalendarViewHeaderView*)calendarHeaderView
{
    [self previousMonth];
}

- (void)calendarViewHeaderViewDidCancel:(ITTCalendarViewHeaderView*)calendarHeaderView
{
    [self hide];
}

- (void)calendarViewHeaderViewDidSelection:(ITTCalendarViewHeaderView*)calendarHeaderView
{
    if (_delegate && [_delegate respondsToSelector:@selector(calendarViewDidSelectDay:calDay:)]) {
        [_delegate calendarViewDidSelectDay:self calDay:self.selectedDay];
    } 
    [self hide];    
}

#pragma mark - CalendarViewFooterViewDelegate
- (void)calendarViewFooterViewDidSelectPeriod:(ITTCalendarViewFooterView*)footerView periodType:(PeriodType)type
{
    self.selectedPeriod = type;
    if (_delegate && [_delegate respondsToSelector:@selector(calendarViewDidSelectPeriodType:periodType:)]) {
        [_delegate calendarViewDidSelectPeriodType:self periodType:type];
    }
}

#pragma mark - CalendarGridViewDelegate
- (void)ittCalendarGridViewDidSelectGrid:(ITTCalendarGridView*)gridView
{
}

- (void)show
{
    [UIView animateWithDuration:0.4 animations:^{
        self.alpha = 1.0;
    }];
}

#pragma mark - ITTCalendarScrollViewDelegate
- (void)calendarSrollViewTouchesBegan:(ITTCalendarScrollView*)calendarScrollView touches:(NSSet *)touches withEvent:(UIEvent *)event
{
    _moved = FALSE;
    _swipeTimeInterval = NSTimeIntervalSince1970;
    _begintimeInterval = [[touches anyObject] timestamp];
}

- (void)calendarSrollViewTouchesMoved:(ITTCalendarScrollView*)calendarScrollView touches:(NSSet *)touches withEvent:(UIEvent *)event
{
    _moved = TRUE;
    GridIndex index = [self getGridViewIndex:calendarScrollView touches:touches];
    if ([self isValidGridViewIndex:index]) {
        if (0)
        {
            BOOL selectedEnable = FALSE;
            /*
             * the grid is on unselected state
             */
            BOOL selected = [self isSelectedAtRow:index.row column:index.column] ;
            if (!selected) {
                [self resetFoucsMatrix];
                selectedEnable = !selected;
                //selectedEnable = (selectedEnable & [self isGridViewSelectedEnableAtRow:index.row column:index.column]);
                [self setSelectedAtRow:index.row column:index.column selected:selectedEnable];
            }
        }
        _previousSelectedIndex = index;
        [self updateSelectedGridViewState];
    }
}

- (void)calendarSrollViewTouchesCancelled:(ITTCalendarScrollView*)calendarScrollView touches:(NSSet *)touches withEvent:(UIEvent *)event
{
    _swipeTimeInterval = fabs([[touches anyObject] timestamp] - _begintimeInterval);
}

- (void)calendarSrollViewTouchesEnded:(ITTCalendarScrollView*)calendarScrollView touches:(NSSet *)touches withEvent:(UIEvent *)event
{
    GridIndex index = [self getGridViewIndex:calendarScrollView touches:touches];
    if ([self isValidGridViewIndex:index]) {
        BOOL selectedEnable = TRUE;
        if (!_moved) {
            /*
             * deselect the grid view
             */
            [self resetSelectedIndicesMatrix];
            [self setSelectedAtRow:index.row column:index.column selected:selectedEnable];
        }
        [self updateSelectedGridViewState];
        NSInteger day = [self getMonthDayAtRow:index.row column:index.column];
        if (day >= 1 && day <= _calMonth.days) {
            [_selectedDay release];
            _selectedDay = nil;
            _selectedDay = [[_calMonth calDayAtDay:day] retain];
        }
    }
    _swipeTimeInterval = fabs([[touches anyObject] timestamp] - _begintimeInterval);
}
@end
