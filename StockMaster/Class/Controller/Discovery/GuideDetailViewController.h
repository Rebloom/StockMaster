//
//  GuideDetailViewController.h
//  StockMaster
//
//  Created by Rebloom on 14-8-5.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "BasicViewController.h"

#define GuideMessage @"人人股神用互联网免费模式颠覆传统证券行业，让股民免费做股票投资，在不承担任何风险的情况下安全博取高收益"
#define FeatureMsg1  @"全球第一个也是唯一一款炒股不会赔钱的应用"
#define FeatureMsg2  @"全球第一个不花钱就炒股、并能保障盈利收益的炒股应用"
#define FeatureMsg3  @"全球第一个专职保护散户、对抗庄家的炒股应用" 
#define StockMsg1    @"不需要本金投入也能正常炒股，亏损不用负责，盈利正常提走"
#define StockMsg2    @"1、专业的团队，管理团队由金融和互联网八年以上经验人员组成\n2、风投资金支持，在未立项目就获取香港XX投资公司注巨资"
#define StockMsg3    @"所有提现执行T+1兑付，最晚24小内让资金兑付到个人银行卡上"

#define HopeMsg1     @"开创安全博取高收益的理财新模式"
#define HopeMsg2     @"打造股民本金不会亏损的服务平台"
#define HopeMsg3     @"免费的证券投资机会\n股民本金100%安全的商业模式\n对证券行业文化的颠覆"

typedef enum PageType
{
    PageType1 = 1,
    PageType2,
    PageType3,
    PageType4
}_PageType;

@interface GuideDetailViewController : BasicViewController

@property (nonatomic, assign) NSInteger pageType;

@end
