//
//  NIDropDown.h
//  NIDropDown
//
//  Created by Bijesh N on 12/28/12.
//  Copyright (c) 2012 Nitor Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NIDropDown;
@protocol NIDropDownDelegate
- (void)niDropDownDelegateMethod: (NSString* ) type;
@end 

@interface NIDropDown : UIView <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) id <NIDropDownDelegate> delegate;

-(void)hideDropDown:(UIButton *)b;
- (id)initWithShowDropDownBtn:(UIButton *)b andHeight:(CGFloat *)height andArray:(NSArray *)arr;

@property(nonatomic,strong) NSMutableArray * saveArr;
@end
