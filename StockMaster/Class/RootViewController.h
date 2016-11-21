//
//  RootViewController.h
//  StockMaster
//
//  Created by Rebloom on 14-7-21.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BasicViewController.h"
#import "GFRequestManager.h"
#import "GFStaticData.h"
#import "CHNAlertView.h"
#import "UserInfoCoreDataStorage.h"

@interface RootViewController : BasicViewController <ASIHTTPRequestDelegate,CHNAlertViewDelegate>
{
    NSString * versionURL;
}
@end
