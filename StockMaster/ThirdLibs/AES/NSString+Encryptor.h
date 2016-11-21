//
//  NSString+Encryptor.h
//  StockMaster
//
//  Created by Rebloom on 15/4/2.
//  Copyright (c) 2015年 Rebloom. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GTMBase64.h"

@interface NSString (Encryptor)

- (NSString *) sha1_base64;
- (NSString *) md5_base64;
- (NSString *) base64;

@end
