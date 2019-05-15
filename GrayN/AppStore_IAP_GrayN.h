#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>  
#import <StoreKit/StoreKit.h>
#import "GrayN_Store_ProductInfo.h"

/*16*/
// 请求商品信息
#define GrayN_SKProductRequest "SKProductRequest"
// 请求商品信息成功
#define GrayN_SKProductResponseSuccess "SKProductResponseSuccess"
// 请求的商品信息无效
#define GrayN_SKProductResponseProductIdInvalid "SKProductResponseProductIdInvalid"
// 请求的商品信息在当前地区不支持付费
#define GrayN_SKProductResponseLocaleInvalid "SKProductResponseLocaleInvalid"
// 用户强退游戏
#define GrayN_SKUserKillGame "SKUserKillGame"
// 请求计费
#define GrayN_SKPaymentRequest "SKPaymentRequest"

// 重新获得成功通知
#define GrayN_SKRegainSuccessNotification    "SKRegainSuccessNotification"
// 本地数据库补单成功
#define GrayN_SKReuploadReceiptSuccess    "SKReuploadReceiptSuccess"
/*16*/
//#define IAPDEBUG
//#define APPLOGDEBUG

#define TEMPIAP
// 购买响应，购买请求已添加到appstore
#define GrayN_SKPurchasing                      "SKPurchasing"
// 非正常购买响应
#define GrayN_SKPurchasingNoSSID                "SKPurchasingNoSSID"
// 购买成功
#define GrayN_SKSuccess                         "SKSuccess"
// 正常购买成功，且没有订单号
#define GrayN_SKSuccessNormalButNoSSID            "SKSuccessNormalButNoSSID"
// 非正常购买成功，且没有订单号
#define GrayN_SKSuccessUnNormalAndNoSSID        "SKSuccessUnNormalAndNoSSID"
// 非正常购买及购买成功，且没有订单号
#define GrayN_SKPurchasingAndSuccessUnNormalAndNoSSID "SKPurchasingAndSuccessUnNormalAndNoSSID"

#define GrayN_SKRestore                         "SKRestore"
#define GrayN_SKRestoreNoSSID                   "SKRestoreNoSSID"

// 未知错误，请重试
#define GrayN_SKErrorUnknown                    "SKErrorUnknown"
// 当前Apple ID无法购买商品，请联系Apple客服
#define GrayN_SKErrorClientInvalid                "SKErrorClientInvalid"
// 用户取消购买
#define GrayN_SKErrorPaymentCancelled            "SKErrorPaymentCancelled"
// 商品ID无效
#define GrayN_SKErrorPaymentInvalid                "SKErrorPaymentInvalid"
// 此设备无法购买商品，请在[通用]-[访问权限]-[APP内购买]中开启
#define GrayN_SKErrorPaymentNotAllowed            "SKErrorPaymentNotAllowed"
// 当前商品配置未生效
#define GrayN_SKErrorStoreProductNotAvailable    "SKErrorStoreProductNotAvailable"
// 返回信息超时，请等待3-5分钟，查询是否充值成功
#define GrayN_SKErrorNSURLErrorDomain            "SKErrorNSURLErrorDomain"
// 特殊错误，请重试         （非苹果提示错误）
#define GrayN_SKErrorOther                      "SKErrorOther"
// 货币信息异常 被刷
#define GrayN_SKErrorMoney                      "OPSKErrorMoney"
// 货币码不实时
#define GrayN_SKErrorGetCurrency                "OPSKErrorGetCurrency"

#define GrayN_SKCheckRestore                    "OPSKCheckRestore"                      //查看是否有为处理的订单



@interface AppStore_IAP_GrayN : NSObject <SKProductsRequestDelegate,SKPaymentTransactionObserver>
{
    //当启动游戏，就弹出计费界面，这种情况需要特殊处理，如果没有正确记录用户之前的订单号就有可能出问题，不能通过查找本地数据查找（没有登录连用户唯一号都获取不到），这种情况只能交由客服处理
    bool p_GrayN_IsSpecial;
    bool p_GrayN_IsFirstBuy;
/*16*/
    SKProductsRequest *p_GrayN_ProductRequest;

    NSString *p_GrayN_IAP_ProdcutId;
    NSString *p_GrayN_IAP_SSID;
    NSArray  *p_GrayN_IAP_CountryCode;
    NSArray  *p_GrayN_IAP_CurrencyCode;
    NSString *p_GrayN_IAP_Note;
    
    
    BOOL p_GrayN_IAP_IsPaying;
    BOOL p_GrayN_IAP_IsNotifyResult;

/*16*/
}

@property (nonatomic, retain) NSString *m_GrayN_IAP_ChargeCountryCode;      //计费国家代码
@property (nonatomic, retain) GrayN_Store_ProductInfo *m_GrayN_IAP_StoreProductInfo;
@property (nonatomic, retain) NSString *m_GrayN_IAP_ChargeCurrencyCode;        //计费货币代码


// 检测是否可购买
- (BOOL)GrayN_IAP_CanMakePayments;

// 请求获取商品信息
- (void)GrayN_IAP_RequestProductInfo:(const char*)propId
           withCountryCode:(const char*)countryCode
          withCurrencyCode:(const char*)currencyCode
                  withNote:(const char*)note;


@end
