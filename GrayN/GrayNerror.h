//
//  OPError.h
//
//  Created by op-mac1 on 14-1-24.
//  Copyright (c) 2014年 op-mac1. All rights reserved.
//

#define GrayN_LogoutJson_Logout "{\"Type\":\"Logout\"}"
#define GrayN_LogoutJson_SwitchAccount "{\"Type\":\"SwitchAccount\"}"

//网络失败问题
#define GrayN_JSON_TIMEOUT_ERROR "{\"desc\":\"连接超时!\",\"reset\":\"101\",\"status\":\"1\"}"
#define GrayN_JSON_NETWORK_ERROR "{\"desc\":\"网络异常，请检查网络!\",\"reset\":\"102\",\"status\":\"1\"}"
#define GrayN_JSON_NETDATA_ERROR "{\"desc\":\"网络数据异常!\",\"reset\":\"103\",\"status\":\"1\"}"

//初始化失败问题
#define GrayN_Init_PARAM_ERROR "104"
#define GrayN_JSON_INITPARAM_ERROR "{\"desc\":\"SDK初始化参数错误!\",\"reset\":\"104\",\"status\":\"1\"}"
#define GrayN_Init_PLIST_ERROR "105"
#define GrayN_JSON_INITPLIST_ERROR "{\"desc\":\"SDK——Plist读取失败!\",\"reset\":\"105\",\"status\":\"1\"}"
#define GrayN_Init_CFG_ERROR "106"
#define GrayN_JSON_INITCFG_ERROR "{\"desc\":\"SDK——ourpalm.cfg读取失败!\",\"reset\":\"106\",\"status\":\"1\"}"

//登录失败问题
#define GrayN_JSON_NOTINIT_ERROR "{\"desc\":\"SDK未初始化成功!\",\"reset\":\"107\",\"status\":\"1\"}"

//购买失败问题
#define GrayN_Charge_TIMEOUT_ERROR 101
#define GrayN_Charge_TIMEOUT_ERRORDESC "下单失败，网络连接超时！"
#define GrayN_Charge_NETWORK_ERROR 102
#define GrayN_Charge_NETWORK_ERRORDESC "下单失败，网络异常！"
#define GrayN_Charge_NETDATA_ERROR 103
#define GrayN_Charge_NETDATA_ERRORDESC "下单失败，网络数据异常！"
#define GrayN_Charge_USERCANCEL_ERROR 119    //用户取消支付
#define GrayN_Charge_USERCANCEL_ERRORDESC "用户取消支付"
#define GrayN_Charge_FAILED_ERROR 120     //第三方SDK明确返回支付失败
#define GrayN_Charge_FAILED_ERRORDESC "支付失败"
#define GrayN_Charge_LOGIN_STATUS_ERROR 122
#define GrayN_Charge_LOGIN_STATUS_ERRORDESC "登录状态有问题"
#define GrayN_Charge_BILL_ILLEGAL_ERROR 123
#define GrayN_Charge_BILL_ILLEGAL_ERRORDESC "订单不合法"
#define GrayN_Charge_SUCCESS_ERROR 200     //支付成功：第三方SDK明确返回支付成功，例如，支付宝web支付，当展示的是支付成功界面，就可以返回支付成功
#define GrayN_Charge_SUCCESS_ERRORDESC "支付成功"
#define GrayN_Charge_ORDERSUCCESS_ERROR 201     //下单成功：当用户跳入支付宝页面，在无法获知支付成功的情况下，用户如果关闭支付界面，就返回下单成功
#define GrayN_Charge_ORDERSUCCESS_ERRORDESC "下单成功"

//礼包码
#define GrayN_GameCode_TIMEOUT_ERROR 101
#define GrayN_GameCode_TIMEOUT_ERRORDESC "礼包码获取失败，网络连接超时！"
#define GrayN_GameCode_NETWORK_ERROR 102
#define GrayN_GameCode_NETWORK_ERRORDESC "礼包码获取失败，网络异常！"
#define GrayN_GameCode_NETDATA_ERROR 103
#define GrayN_GameCode_NETDATA_ERRORDESC "礼包码获取失败，网络数据异常！"
#define GrayN_GameCode_SUCCESS_ERROR 200     //支付成功：第三方SDK明确返回支付成功，例如，支付宝web支付，当展示的是支付成功界面，就可以返回支付成功
#define GrayN_GameCode_SUCCESS_ERRORDESC "礼包码获取成功"


#define GrayN_NONEERROR 0

#define GrayN_INIT 1           // 正在初始化
#define GrayN_REGISTERING 2       // 正在努力注册
#define GrayN_LOGINNING 3          // 正在努力登录
#define GrayN_BINDPHONE 4
#define GrayN_QUICK_LOGINNING 5  // 快速登录
#define GrayN_VERIFING 6 // 验证中

#define GrayN_ERROR_HTTP_TIMEOUT 101
#define GrayN_ERROR_HTTP_OPENERROR 102

//计费
#define GrayN_BILL_INFO_ERROR_RESET "202"         //具体解析chargeinfo时，解析出错

//************ 错误日志标识 *********
#define GrayN_USER_DES_LOGERROR "USER_DES_LOGERROR"
#define GrayN_USER_JSON_LOGERROR "USER_JSON_LOGERROR"

#define GrayN_CHARGE_DES_LOGERROR "CHARGE_DES_LOGERROR"
#define GrayN_CHARGE_JSON_LOGERROR "CHARGE_JSON_LOGERROR"


//特殊错误
#define GrayN_LOGIN_LOGINTYPENULL_ERROR "{\"desc\":\"登录类型为空!\",\"reset\":\"300\",\"status\":\"1\"}"

