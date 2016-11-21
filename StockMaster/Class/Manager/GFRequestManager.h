//
//  GFRequestManager.h
//  StockMaster
//
//  Created by Rebloom on 14-8-7.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ASIFormDataRequest.h"
#import "Reachability.h"

#import "Secret.h"
#import "Utility.h"
#import "JSONKit.h"
#import "GFStaticData.h"
#import "RequestQueue.h"
#import "MBProgressHUD.h"

//随机昵称
#define Get_rand_nickname                   @"get_rand_nickname"
// 获取注册验证码接口
#define Get_user_register_sms_code          @"get_user_register_sms_code"
// 验证获得的验证码接口
#define Submit_check_sms_code               @"submit_check_sms_code"
// 提交注册接口
#define Submit_user_register                @"submit_user_register"
// 重设密码接口
#define Submit_new_password                 @"submit_new_password"
// 登录接口
#define Submit_user_login                   @"submit_user_login"
// 更新用户信息接口
#define Update_user_info                    @"update_user_info"
// 获取交割单列表接口
#define Get_transaction_record_list         @"get_transaction_record_list"
// 获取用户提现接口
#define Get_withdraw_deposit_list           @"get_withdraw_deposit_list"
// 提现验证码接口
#define Get_sms_code                        @"get_sms_code"
// 用户提交反馈内容接口
#define Submit_feedback                     @"submit_feedback"
// 上传用户头像接口
#define Submit_upload_user_head             @"submit_upload_user_head"
// 总盈利榜用户列表
#define Get_total_profit_rank               @"get_total_profit_rank"
//日盈利榜
#define Get_daily_profit_rank               @"get_daily_profit_rank"
//日悲情榜
#define Get_daily_pathos_rank               @"get_daily_pathos_rank"
// 月盈利榜用户列表
#define Get_thirty_profit_rank              @"get_thirty_profit_rank"
// 周盈利榜用户列表
#define Get_seven_profit_rank               @"get_seven_profit_rank"
// 准确率榜用户排行列表
#define Get_accuracy_rank                   @"get_accuracy_rank"
//逆袭榜
#define Get_counterattack_rank              @"get_counterattack_rank"
//获取用户主页
#define Get_user_home                       @"get_user_home"

//获取某只股票的评级信息
#define Get_stock_grade                     @"get_stock_grade"
//获取股票所属板块中涨幅最大的
#define Get_stock_hot_plate                 @"get_stock_hot_plate"
//获取股票详情页前N条新闻
#define Get_stock_news_top                  @"get_stock_news_top"
//获取股票新闻列表
#define Get_stock_news_list                 @"get_stock_news_list"
//获取用户信息
#define Get_user_info                       @"get_user_info"

//获取股票实时数据接口
#define Get_realtime_data                   @"get_realtime_data"
//获取指定股票的k线
#define Get_k_line                          @"get_k_line_data"
//获取股票历史数据的接口
#define Get_time_share                      @"get_time_share"
//指数行情数据
#define Get_stock_index_quotation           @"get_stock_index_quotation"
//获取找回密码接口
#define Get_retrieve_password_sms_code      @"get_retrieve_password_sms_code"
//获取股票数据
#define Get_stock_data                      @"get_stock_data"
//版本更新
#define Get_versions                        @"get_versions"
//账户财务信息查询
#define Get_withdraw_home                   @"get_withdraw_home"
//用户提取邀请任务现金
#define Get_invitation_withdraw	            @"get_invitation_withdraw"
//邀请任务提交订单
#define Submit_invitation_withdraw          @"submit_invitation_withdraw"
//添加银行卡
#define Submit_bank_card                    @"submit_bank_card"
//读取用户绑定银行卡列表
#define Get_user_bank_card                  @"get_user_bank_card"
//删除银行卡
#define Delete_user_bank_card               @"delete_user_bank_card"
//访问提现规则静态URL
#define Get_rule                            @"get_rule"
//提交提现订单
#define Submit_withdraw_order               @"submit_withdraw_order"
//摇一摇
#define Get_shake_shake                     @"get_shake_shake"
//可提现金额能买什么商品
#define Get_user_buy_goods                  @"get_user_buy_goods"
//获取财物基本信息
#define Get_user_performance                @"get_user_performance"
// 获取用户财务信息
#define Get_user_history_assets             @"get_user_history_assets"
//赚钱明细
#define Get_user_make_money                 @"get_user_make_money"
//获取用户绑定信息
#define Get_bank_bind_info                  @"get_bank_bind_info"
//退出登录
#define Submit_user_logout                  @"submit_user_logout"
//获取提现前十名
#define Get_top_withdraw_money              @"get_top_withdraw_money"
//获取热门股票
#define Get_hot_stock                       @"get_hot_stock"
//获取赚钱首页信息
#define Get_make_money                      @"get_make_money"
//获取用户当前猜大盘状态
#define Get_guess_grail_status              @"get_guess_grail_status"
//获取用户猜涨跌历史记录
#define Get_guess_grail_log                 @"get_guess_grail_log"
//获取用户当天答题状态
#define Get_answer_status                   @"get_answer_status"
//获取用户答题历史记录
#define Get_user_answer_count_award         @"get_answer_total_award"
//提交用户猜大盘的接口
#define Submit_guess_grail                  @"submit_guess_grail"
//提交用户答题数据
#define Submit_user_answer                  @"submit_user_answer"
//用户领奖
#define Submit_user_award                   @"submit_user_award"
//用户提交答题的领奖
#define Submit_user_answer_total_award      @"submit_user_answer_total_award"
//获取复活状态接口
#define Get_resurrection_status             @"get_resurrection_status"
//提交->用户复活
#define Submit_resurrection                 @"submit_resurrection"
//首页新手任务接口
#define Get_home_task_status                @"get_home_task_status"
//提交完成新手任务接口
#define Complete_guide_task                 @"submit_guide_task"
//发现首页热门板块
#define Get_index_hot_plate                 @"get_index_hot_plate"
//发现首页雷达数据列表
#define Get_stock_radar_list                @"get_stock_radar_list"
//获取板块列表
#define Get_plate_list                      @"get_plate_list"
//获取板块详情
#define Get_plate_stock_list                @"get_plate_stock_list"
//获取热门股票搜索
#define Get_hot_stock_search                @"get_hot_stock_search"
//排行榜首页
#define Get_rank_list_home                  @"get_rank_list_home"
//获取用户持仓股票列表数据
#define Get_portfolio_home                  @"get_portfolio_home"
//获取用户自选股票列表数据
#define Get_stock_watchlist                 @"get_stock_watchlist"
//用户添加自选
#define Submit_stock_watchlist              @"submit_stock_watchlist"
//用户删除自选
#define Delete_stock_watchlist              @"delete_stock_watchlist"
//获取可买股票信息
#define Get_buyable_stock_info              @"get_buyable_stock_info"
//获取做空股票可买入信息
#define Get_short_buyable_stock_info        @"get_short_buyable_stock_info"
//买入股票接口
#define Submit_buy_stock_order              @"submit_buy_stock_order"
// 提交做空买入订单
#define Submit_short_buy_stock_order        @"submit_short_buy_stock_order"
//获取可卖股票信息
#define Get_sellable_stock_info             @"get_sellable_stock_info"
//获取做空股票可卖出信息
#define Get_short_sellable_stock_info       @"get_short_sellable_stock_info"
//卖出股票接口
#define Submit_sell_stock_order             @"submit_sell_stock_order"
//提交做空卖出订单
#define Submit_short_sell_stock_order       @"submit_short_sell_stock_order"
//获取卖出股票列表
#define Get_sellable_stock_list             @"get_sellable_stock_list"
//

//获取A股排行
#define Get_stock_rank_list                 @"get_stock_rank_list"
//获取用户邀请码
#define Get_invitation_code                 @"get_invitation_code"
//获取邀请任务信息
#define Get_invitation_task                 @"get_invitation_task"
//获取邀请的好友个数
#define Get_invitation_friends_num          @"get_invitation_friends_num"
//获取好友赚钱信息
#define Get_invitation_friends_money        @"get_invitation_friends_money"
//领取奖励
#define Get_invitation_reward               @"get_invitation_reward"
//领取奖励-被邀请
#define Get_reward_by_code                  @"get_reward_by_code"
//环信聊天常见问题
#define Get_faq_list                        @"get_faq_list"
// 获取赠送股票接口
#define Submit_receive_gift_stock           @"submit_receive_gift_stock"
// 获取个股推送设置
#define Get_stock_push_set_info             @"get_stock_push_set_info"
// 提交个股推送信息
#define Submit_stock_push_set_info          @"submit_stock_push_set_info"
// 获取消息列表
#define Get_user_push_message_list          @"get_user_push_message_list"
// 删除消息
#define Submit_delete_user_push_message     @"submit_delete_user_push_message"
// 获取股票推送设置信息
#define Get_user_push_set_info              @"get_user_push_set_info"
// 绑定用户clientID用来推送
#define Submit_user_app_push_bind           @"submit_user_app_push_bind"
// 开市提醒接口
#define Submit_user_push_set_info           @"submit_user_push_set_info"
// 获取配置信息接口
#define Get_settings                        @"get_settings"
// 获取顶部提示信息
#define Get_top_notice                      @"get_top_notice"

// 获取银行列表
#define Get_bank_list                       @"get_bank_list"
// 获取银行省份列表
#define Get_bank_province_list              @"get_bank_province_list"
// 获取银行城市列表
#define Get_bank_city_list                  @"get_bank_city_list"
// 获取银行支行列表
#define Get_bank_branch_list                @"get_bank_branch_list"
//获取单只股票感情度历史和奖励信息
#define Get_stock_feeling_v2                @"get_stock_feeling_v2"
//感情度领取奖励
#define Submit_stock_feeling_reward         @"submit_stock_feeling_reward"
//获取感情度列表
#define Get_stock_feeling_list              @"get_stock_feeling_list"
//领取卡包页面
#define Show_card_info_feeling              @"show_card_info_feeling"
//领取卡包
#define Submit_card_feeling_reward          @"submit_card_feeling_reward"
//使用道具卡
#define Submit_use_card                     @"submit_use_card"
//免费领取百分之90复活卡
#define Submit_receive_90_card              @"submit_receive_90_card"

// 微信登录接口
#define Submit_user_weixin_login            @"submit_user_weixin_login"
// 获取首页股票
#define Get_index_stock                     @"get_index_stock"
// 首页获取感情度可领奖个数
#define Get_stock_feeling_reward_num        @"get_stock_feeling_reward_num"
// 首页领取红包
#define Submit_index_red_package_reward     @"submit_index_red_package_reward"
//商店应用下载
#define Get_app_download_list               @"get_app_download_list"
//提交下载商店任务
#define Submit_app_download_task            @"submit_app_download_task"
//应用下载提交领奖
#define Submit_user_app_award               @"submit_user_app_award"
//获取道具卡信息
#define Get_card_info                       @"get_card_info"
//获取道具卡可买信息
#define Get_card_buy_info                   @"get_card_buy_info"
//提交购买道具卡
#define Submit_buy_card                     @"submit_buy_card"
//获取道具卡列表
#define Get_card_list                       @"get_card_list"

@interface GFRequestManager : ASIFormDataRequest <ASIHTTPRequestDelegate,ASIProgressDelegate>

+ (GFRequestManager *)shareManager;

+ (GFRequestManager *)instance;

+ (BOOL)connectWithDelegate:(id)delegate action:(NSString *)action param:(NSDictionary *)param;

+ (BOOL)connectWithDelegate:(id)delegate action:(NSString *)action param:(NSDictionary *)param priority:(NSInteger)priority;

+ (BOOL)uploadImageWithDelegate:(id)delegate action:(NSString *)action imageParam:(NSDictionary *)imageParam;

@end
