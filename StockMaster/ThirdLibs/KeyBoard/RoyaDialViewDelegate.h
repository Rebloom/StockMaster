//
//  RoyaDialViewDelegate.h
//  Test
//
//  Created by royasoft on 12-12-6.
//  Copyright (c) 2012年 royasoft. All rights reserved.
//

#import <Foundation/Foundation.h>
@class RoyaDialView;
@protocol RoyaDialViewDelegate <NSObject>
@required
- (void)onDialViewClickedIndex:(NSInteger)key;
@optional
-(void)onDialView:(RoyaDialView*) view makePhoneCall:(NSString *) phoneNum;
-(void)onDialView:(RoyaDialView*) view dialNumber:(NSString *)phoneNum withKey:(NSInteger)key;
@end
