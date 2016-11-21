//
//  ShareManager.m
//  StockMaster
//
//  Created by dalikeji on 15/2/9.
//  Copyright (c) 2015年 Rebloom. All rights reserved.
//

#import "ShareManager.h"

@implementation ShareManager

+ (ShareManager *)defaultShareManager
{
    static ShareManager * defaultShareManager = nil;
    if (!defaultShareManager)
    {
        defaultShareManager = [[ShareManager alloc] init];
    }
    
    return defaultShareManager;
}

#pragma mark  根据类型分享到QQ空间（QQ好友）
//正常分享，拼uid上传
- (void)sendTencentWithType:(NSInteger)type WithUid:(NSString *)uid
{
    NSString *utf8String = [NSString stringWithFormat:
                            @"http://www.aizhangzhang.com/?uid=%@", uid];
    NSString *title = @"涨涨送5000元炒股，盈利归你";
    NSString *description = @"最任性、最烧钱的年度互联网创业新锐--“涨涨”，送钱不谈感情！";
    NSString *previewImageUrl = @"http://pic.aizhangzhang.com/ios_icon.png";
    QQApiNewsObject *newsObj = [QQApiNewsObject
                                objectWithURL:[NSURL URLWithString:utf8String]
                                title:title
                                description:description
                                previewImageURL:[NSURL URLWithString:previewImageUrl]];
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObj];
    
    QQApiSendResultCode sent ;
    if (type == SHARETOQQ)
    {
        //将内容分享到qq
        sent = [QQApiInterface sendReq:req];
    }
    else if (type == SHARETOQZONE)
    {
        //将内容分享到qq空间
        sent = [QQApiInterface SendReqToQZone:req];
    }
}

//提现分享
- (void)sendTencentWithUrl:(NSURL*)share_url WithDesc:(NSString*)share_desc WithType:(NSInteger)type
{
    NSString *title = share_desc;
    NSString *description = @"最任性、最烧钱的年度互联网创业新锐--“涨涨”，送钱不谈感情！";
    NSString *previewImageUrl = @"http://pic.aizhangzhang.com/ios_icon.png";
    QQApiNewsObject *newsObj = [QQApiNewsObject
                                objectWithURL:share_url
                                title:title
                                description:description
                                previewImageURL:[NSURL URLWithString:previewImageUrl]];
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObj];
    
    QQApiSendResultCode sent ;
    if (type == SHARETOQQ)
    {
        //将内容分享到qq
        sent = [QQApiInterface sendReq:req];
    }
    else if (type == SHARETOQZONE)
    {
        //将内容分享到qq空间
        sent = [QQApiInterface SendReqToQZone:req];
    }
}

#pragma mark 根据类型分享到微信朋友圈（微信好友）
//正常分享，拼uid上传
- (void)sendWXWithType:(int)type WithUid:(NSString *)uid
{
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = @"涨涨送5000元炒股，盈利归你";
    message.description = @"最任性、最烧钱的年度互联网创业新锐--“涨涨”，送钱不谈感情！";
    [message setThumbImage:[UIImage imageNamed:@"icon"]];
    
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = [NSString stringWithFormat:@"http://www.aizhangzhang.com/?uid=%@", uid];
    
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = type;
    
    [WXApi sendReq:req];
}

//提现分享
- (void)sendWXWithUrl:(NSURL*)share_url WithDesc:(NSString*)share_desc WithType:(int)type
{
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = share_desc;
    message.description = @"最任性、最烧钱的年度互联网创业新锐--“涨涨”，送钱不谈感情！";
    [message setThumbImage:[UIImage imageNamed:@"icon"]];
    
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = [NSString stringWithFormat:@"%@",share_url];
    
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = type;
    
    [WXApi sendReq:req];
}

////微博分享
//- (void)sendSina
//{
//    AppDelegate *myDelegate =(AppDelegate*)[[UIApplication sharedApplication] delegate];
//    
//    WBAuthorizeRequest *authRequest = [WBAuthorizeRequest request];
//    authRequest.redirectURI = kSinaRedirectURI;
//    authRequest.scope = @"all";
//    
////    NSLog(@"token===%@",myDelegate.wbtoken);
//    
//    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:[self messageToShare] authInfo:authRequest access_token:myDelegate.wbtoken];
//    request.userInfo = @{@"ShareMessageFrom": @"InvitationCodeViewController",
//                         @"Other_Info_1": [NSNumber numberWithInt:123],
//                         @"Other_Info_2": @[@"obj1", @"obj2"],
//                         @"Other_Info_3": @{@"key1": @"obj1", @"key2": @"obj2"}};
//    [WeiboSDK sendRequest:request];
//}

- (WBMessageObject *)messageToShare
{
    WBImageObject *image = [WBImageObject object];
    image.imageData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Icon" ofType:@"png"]];
    
    WBMessageObject *message = [WBMessageObject message];
    message.text = NSLocalizedString(@"涨涨免费炒股，大赚真钱", nil);
    message.imageObject = image;
    
    return message;
}
@end
