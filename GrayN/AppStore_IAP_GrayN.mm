
#import "AppStore_IAP_GrayN.h"
#import "GrayN_Store_IAP.h"
#import "GrayNjson_cpp.h"

#import "GrayN_LoadingUI.h"
#import "GrayNasyn_CallBack.h"
#import "GrayN_TempleQueue.h"
#import "GrayNconfig.h"
#import "AppLog_GrayN.h"
#import "GrayN_GTMBase64.h"
#import "GrayN_AppPurchase.h"
#import "GrayNbaseSDK.h"
#import "GrayN_SynAppReceipt.h"
#import "GrayNchannelSDK.h"

GrayNusing_NameSpace;

static std::string p_GrayN_IAP_DesReceipt;
static std::string p_GrayN_IAP_AppleReturnProductId;            //苹果后台配置的道具id
static ByteArrayOutputStream p_GrayN_IAP_bos;



@implementation AppStore_IAP_GrayN

@synthesize m_GrayN_IAP_ChargeCountryCode;
@synthesize m_GrayN_IAP_StoreProductInfo;
@synthesize m_GrayN_IAP_ChargeCurrencyCode;

#pragma mark - 0.初始化
- (void)dealloc
{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
    GrayNreleaseSafe(m_GrayN_IAP_ChargeCountryCode);
    GrayNreleaseSafe(m_GrayN_IAP_StoreProductInfo);
    GrayNreleaseSafe(m_GrayN_IAP_ChargeCurrencyCode);
    GrayNreleaseSafe(p_GrayN_IAP_CountryCode);
    GrayNreleaseSafe(p_GrayN_IAP_CurrencyCode);
    GrayNreleaseSafe(p_GrayN_IAP_Note);
      
    [super dealloc];
}
- (id)init
{
    if ((self = [super init])) {
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(userKillGame)
                                                     name:UIApplicationWillTerminateNotification
                                                   object:nil];
        p_GrayN_IsSpecial = false;
        p_GrayN_IsFirstBuy = true;
        p_GrayN_IAP_IsNotifyResult = false;
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        self.m_GrayN_IAP_ChargeCountryCode = [userDefaults objectForKey:@"countryCode"];
        self.m_GrayN_IAP_ChargeCurrencyCode = [userDefaults objectForKey:@"currencyCode"];
        if (self.m_GrayN_IAP_ChargeCountryCode == nil) {
            self.m_GrayN_IAP_ChargeCountryCode = @"-";
        }
        if (self.m_GrayN_IAP_ChargeCurrencyCode == nil) {
            self.m_GrayN_IAP_ChargeCurrencyCode = @"-";
        }
        p_GrayN_IAP_SSID = [userDefaults objectForKey:@"lastSSID"];
        p_GrayN_IAP_ProdcutId = [userDefaults objectForKey:@"lastProductId"];
        if (p_GrayN_IAP_SSID == nil) {
            p_GrayN_IAP_SSID = @"-";
        }
        if (p_GrayN_IAP_ProdcutId == nil) {
            p_GrayN_IAP_ProdcutId = @"-";
        }
        
    }
    return self;
}
- (BOOL)GrayN_IAP_CanMakePayments
{
    return [SKPaymentQueue canMakePayments];
}
#pragma mark - 1.获取商品信息
- (void)GrayN_IAP_RequestProductInfo:(const char*)propId
           withCountryCode:(const char*)countryCode
          withCurrencyCode:(const char*)currencyCode
                  withNote:(const char*)note
{
    p_GrayN_IsSpecial = false;
    p_GrayN_IAP_IsNotifyResult = YES;
    NSString *countryCodeStr = [NSString stringWithUTF8String:countryCode];
    p_GrayN_IAP_CountryCode = [[countryCodeStr componentsSeparatedByString:@","] retain];
    
    NSString *currencyCodeStr = [NSString stringWithUTF8String:currencyCode];
    p_GrayN_IAP_CurrencyCode = [[currencyCodeStr componentsSeparatedByString:@","] retain];
    
    p_GrayN_IAP_Note = [[NSString stringWithUTF8String:note] retain];
    p_GrayN_IAP_ProdcutId = [[NSString stringWithUTF8String:propId] retain];
    
    p_GrayN_IAP_SSID = [[NSString stringWithUTF8String:[GrayNbaseSDK GrayNget_SSID]] retain];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:p_GrayN_IAP_SSID forKey:@"lastSSID"];
    [userDefaults setValue:p_GrayN_IAP_ProdcutId forKey:@"lastProductId"];
    [userDefaults synchronize];
    
    // 发起购买
    [self requestProductInfo];
}
- (void)requestProductInfo
{
    // Create a set for your product identifier
    NSSet *productSet = [NSSet setWithObject:p_GrayN_IAP_ProdcutId];
    // Create a product request object and initialize it with the above set
    p_GrayN_ProductRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productSet];
    p_GrayN_ProductRequest.delegate = self;
    // Send the request to the App Store
    [p_GrayN_ProductRequest start];
    
    AppLog_GrayN* log = new AppLog_GrayN();
    log->CreateRequestAppLog_GrayN([p_GrayN_IAP_SSID UTF8String], [p_GrayN_IAP_ProdcutId UTF8String], GrayN_SKProductRequest);
    p_GrayN_IAP_IsPaying = YES;
}
#pragma mark - 2.获取商品信息返回
-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    if ([GrayNbaseSDK GrayNgetChargeLogSwitch]) {
        AppLog_GrayN* log = new AppLog_GrayN();
        log->CreateResponseAppLog_GrayN([p_GrayN_IAP_SSID UTF8String], [p_GrayN_IAP_ProdcutId UTF8String], GrayN_SKProductResponseSuccess)
        ;
        [GrayNbaseSDK GrayN_Console_Log:@"SKProductResponseSuccess..."];
    }
    string errDesc;
    if ([response.products count] > 0) {
        SKProduct *product = (SKProduct *)[response.products objectAtIndex:0];
        
        NSLocale *locale = product.priceLocale;
        NSString *countryCode = [locale objectForKey:NSLocaleCountryCode];
        NSString *currencyCode = [locale objectForKey:NSLocaleCurrencyCode];
        
        [GrayNbaseSDK GrayN_Debug_Log:@"SKProduct.localizedDescription:%@\nSKProduct.localizedTitle:%@\nSKProduct.price:%@\n国家地区代码(countryCode):%@\n货币代码(currencyCode):%@", product.localizedDescription, product.localizedTitle, product.price, countryCode, currencyCode];
        
        string productId = [product.productIdentifier UTF8String];
        string ssid = [GrayNbaseSDK GrayNget_SSID];
        
        //验证地区
        NSUInteger countryCodeCount = p_GrayN_IAP_CountryCode.count;
        NSUInteger cyCodeCount = p_GrayN_IAP_CurrencyCode.count;
        if (countryCodeCount == cyCodeCount) {
            //国家和货币必须数量相同
            if ([p_GrayN_IAP_CountryCode containsObject:@""]) {
                //国家不受限制，且货币必定为空字符串
            } else {
                //判断地区是否支持
                NSInteger index = [p_GrayN_IAP_CountryCode indexOfObject:countryCode];
                if (index == NSNotFound) {
                    errDesc = [p_GrayN_IAP_Note UTF8String];
                    GrayN_LoadingUI::GetInstance().GrayN_CloseGameWait();
                    [self notifyResult:false desc:errDesc.c_str()];
                    return;
                }
                //判断货币是否支持
                NSString *cyCode = [p_GrayN_IAP_CurrencyCode objectAtIndex:index];
                if (![cyCode isEqualToString:currencyCode]) {
                    errDesc = [p_GrayN_IAP_Note UTF8String];
                    GrayN_LoadingUI::GetInstance().GrayN_CloseGameWait();
                    [self notifyResult:false desc:errDesc.c_str()];
                    return;
                }
            }
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                GrayN_LoadingUI::GetInstance().GrayN_CloseGameWait();
                GrayN_LoadingUI::GetInstance().GrayN_ShowGameWait([GrayNbaseSDK GrayNgetLocalLang:GrayN_StoreBuy]);
                
                if (p_GrayN_IsFirstBuy) {
                    p_GrayN_IsFirstBuy = false;
                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                    [userDefaults setValue:countryCode forKey:@"countryCode"];
                    [userDefaults setValue:currencyCode forKey:@"currencyCode"];
                    [userDefaults synchronize];
                }
                self.m_GrayN_IAP_ChargeCountryCode = countryCode;
                self.m_GrayN_IAP_ChargeCurrencyCode = currencyCode;
                
                //1、使用一个队列与SKPaymentQueue同步，为了解决多个请求未响应的问题，当有响应的时候可以从队列中取订单号
                GrayN_AppRequest_GrayN* appRequest = new GrayN_AppRequest_GrayN();
                appRequest->m_GrayN_AppRequest_SSID = ssid;
                appRequest->m_GrayN_AppRequest_ProductId = productId;
                //appRequest->goodId = Purchase::GetInstance().goodid;
                appRequest->m_GrayN_AppRequest_StartTime = [[GrayNbaseSDK GrayNgetCurrentMil_TimeString] UTF8String];
                appRequest->m_GrayN_AppRequest_CountryCode = [countryCode UTF8String];
                appRequest->m_GrayN_AppRequest_CurrencyCode = [currencyCode UTF8String];
                GrayN_TempleQueue<GrayN_AppRequest_GrayN>::GetInstance().push(appRequest);
                
                //2、创建日志并发送请求日志
                if ([GrayNbaseSDK GrayNgetChargeLogSwitch]) {
                    AppLog_GrayN* log = new AppLog_GrayN();
                    log->CreateRequestAppLog_GrayN(appRequest->m_GrayN_AppRequest_SSID.c_str(), productId.c_str(), GrayN_SKPaymentRequest);
                }
                // The product is available, let's submit a payment request to the queue
                SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:product];
                payment.applicationUsername = p_GrayN_IAP_SSID;
#ifdef TEMPIAP
                //3、将请求插入临时数据库，为的是记录每一次请求的订单号，有种情况是用户一进入游戏，就弹出购买界面，但是此时没有订单号，所以需要从Temp数据库中查最近的订单号
                string userId = [GrayNbaseSDK GrayNgetGame_UserId];
                GrayN_Store_IAP::GetInstance().GrayN_Store_IAP_InsertTempData(ssid, userId, productId);
                sleep(1);
#endif
                
                //再次获取国家码和货币码
                self.m_GrayN_IAP_StoreProductInfo = [[GrayN_Store_ProductInfo alloc] init];
                NSString *applePropId = [NSString stringWithUTF8String:productId.c_str()];
                [self.m_GrayN_IAP_StoreProductInfo GrayN_GetProductInfo:applePropId];
                
                [[SKPaymentQueue defaultQueue] addPayment:payment];
            });
            return;
        } else {
            //该地区不支持付费操作
            errDesc = [p_GrayN_IAP_Note UTF8String];
            if ([GrayNbaseSDK GrayNgetChargeLogSwitch]) {
                AppLog_GrayN* log = new AppLog_GrayN();
                log->CreateResponseAppLog_GrayN([p_GrayN_IAP_SSID UTF8String], productId.c_str(), GrayN_SKProductResponseLocaleInvalid);
            }
        }
    } else {
        [GrayNbaseSDK GrayN_Console_Log:@"无效商品列表：%@",response.invalidProductIdentifiers];
        errDesc = [GrayNbaseSDK GrayNgetLocalLang:GrayN_StoreProductInvalid];
        if ([GrayNbaseSDK GrayNgetChargeLogSwitch]) {
            AppLog_GrayN* log = new AppLog_GrayN();
            log->CreateResponseAppLog_GrayN([p_GrayN_IAP_SSID UTF8String], [p_GrayN_IAP_ProdcutId UTF8String], GrayN_SKProductResponseProductIdInvalid);
        }
    }
    GrayN_LoadingUI::GetInstance().GrayN_CloseGameWait();
    // 无法连接到appstore
    [self notifyResult:false desc:errDesc.c_str()];
    p_GrayN_IAP_IsPaying = NO;
    
}
- (void)requestDidFinish:(SKRequest *)request
{
    
}
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    // 无法连接到appstore
    NSLog(@"request:didFailWithError:%@",error);
    [self notifyResult:false desc:[GrayNbaseSDK GrayNgetLocalLang:GrayN_StoreGetProductInfoFail]];
}

- (void)notifyResult:(bool)result desc:(const char*)resultDesc
{
    if (p_GrayN_IAP_IsNotifyResult == false) {
        return;
    }
    GrayN_LoadingUI::GetInstance().GrayN_CloseGameWait();
    GrayN_LoadingUI::GetInstance().GrayN_ShowMsgBox([GrayNbaseSDK GrayNgetLocalLang:GrayN_Title], resultDesc, 0, 1);
    int errorCode = GrayN_Charge_SUCCESS_ERROR;
    if (!result) {
        errorCode = GrayN_Charge_FAILED_ERROR;
    }
    GrayN_Store_IAP::GetInstance().GrayN_Store_IAP_PayResult(result, errorCode);
}
#pragma mark - 3.交易返回
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    //    GrayN_TempleQueue<GrayN_AppRequest_GrayN>::GetInstance().pop();
    
    int count = 0;
    int purchasingCount = 0;
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchasing:
                purchasingCount++;
                break;
            case SKPaymentTransactionStatePurchased:
                count++;
                break;
            case SKPaymentTransactionStateFailed:
                count++;
                break;
            case SKPaymentTransactionStateRestored:
                // 未处理
                break;
            case SKPaymentTransactionStateDeferred:
                // 未处理
                break;
            default:
                break;
        }
    }
    
    NSLog(@"transactions count======%lu",(unsigned long)transactions.count);
    NSLog(@"purchasingCount======%d",purchasingCount);
    NSLog(@"count======%d",count);
    
    
    GrayN_Store_IAP::GrayN_Store_IAP_Listener* listener = GrayN_Store_IAP::GetInstance().GrayN_Store_IAP_GetListener();
    
    if (count>0&&listener != NULL) {
        p_GrayN_IAP_bos.Clear();
        p_GrayN_IAP_bos.WriteInt(count);
    }
    
    string uniqueUserId = [GrayNbaseSDK GrayNgetGame_UserId];
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchasing: {
                NSString *product = transaction.payment.productIdentifier;
                [GrayNbaseSDK GrayN_Console_Log:@"<SKPaymentTransactionStatePurchasing> productId:%@ applicationUsername:%@", product, transaction.payment.applicationUsername];
                
                if(listener!= NULL && GrayN_TempleQueue<GrayN_AppRequest_GrayN>::GetInstance().size() > 0)
                {
                    //创建日志并发送响应日志
                    GrayN_AppRequest_GrayN* appRequest = GrayN_TempleQueue<GrayN_AppRequest_GrayN>::GetInstance().front_element();
                    AppLog_GrayN* log = new AppLog_GrayN();
                    log->CreateResponseAppLog_GrayN(appRequest->m_GrayN_AppRequest_SSID.c_str(), [product UTF8String], GrayN_SKPurchasing);
                } else {
                    // 存在这种情况，但是没有订单号
                    p_GrayN_IsSpecial = true;
                    
                    // 在异常情况下，同样获取国家码和货币码，这个反应的是支付时的国家码和货币码
                    self.m_GrayN_IAP_StoreProductInfo = [[GrayN_Store_ProductInfo alloc] init];
                    [self.m_GrayN_IAP_StoreProductInfo GrayN_GetProductInfo:product];
                    // 创建日志并发送响应日志
                    AppLog_GrayN* log = new AppLog_GrayN();
                    log->CreateResponseAppLog_GrayN([p_GrayN_IAP_SSID UTF8String], [product UTF8String], GrayN_SKPurchasingNoSSID);
                }
                break;
            }
            case SKPaymentTransactionStatePurchased:
            {
                p_GrayN_IAP_IsPaying = NO;
                [GrayNbaseSDK GrayN_Console_Log:@"<SKPaymentTransactionStatePurchased> productId:%@ applicationUsername:%@", transaction.payment.productIdentifier, transaction.payment.applicationUsername];
                
                if(listener!=NULL && GrayN_TempleQueue<GrayN_AppRequest_GrayN>::GetInstance().size() > 0) {
                    [self completeTransaction:transaction type:0];
                } else {
                    if (!p_GrayN_IsSpecial) {
                        // 在异常情况下，同样获取国家码和货币码，这个反应的是支付时的国家码和货币码
                        NSString *product = transaction.payment.productIdentifier;
                        self.m_GrayN_IAP_StoreProductInfo = [[GrayN_Store_ProductInfo alloc] init];
                        [self.m_GrayN_IAP_StoreProductInfo GrayN_GetProductInfo:product];
                    }
                    [self completeTransaction:transaction type:1];
                }
                break;
            }
            case SKPaymentTransactionStateFailed:
                p_GrayN_IAP_IsPaying = NO;
                [GrayNbaseSDK GrayN_Console_Log:@"<SKPaymentTransactionStateFailed> productId:%@ applicationUsername:%@", transaction.payment.productIdentifier, transaction.payment.applicationUsername];
                
                [self failedTransaction:transaction];
                
                return;
            case SKPaymentTransactionStateRestored:
                p_GrayN_IAP_IsPaying = NO;
                [GrayNbaseSDK GrayN_Console_Log:@"<SKPaymentTransactionStateRestored> productId:%@ applicationUsername:%@", transaction.payment.productIdentifier, transaction.payment.applicationUsername];
                
                if (listener!=NULL)
                    GrayN_LoadingUI::GetInstance().GrayN_CloseGameWait();
                [self restoreTransaction:transaction];
                break;
            default:
                break;
        }
    }
    
    [GrayNbaseSDK GrayN_Debug_Log:@"transactions finish......"];
    [GrayNbaseSDK GrayN_Debug_Log:@"**************end***************"];
    
    // 成功时发送验证
    if(listener!=NULL && count>0 && GrayN_TempleQueue<GrayN_AppRequest_GrayN>::GetInstance().size() > 0)
    {
        //#ifdef TEMPIAP
        //        if (requestCount >= 5) {
        //            //GrayN_Store_IAP::GetInstance().GrayN_Store_IAP_DealLeakedData("com.xiyouxiangmopian.6", "", "");
        //            //删除临时表的数据，尽量减少数据
        //#ifdef IAPDEBUG
        //            XCLOG("===========清除临时表数据表========");
        //#endif
        //            GrayN_Store_IAP::GetInstance().GrayN_Store_IAP_RemoveAllTempData();
        //            requestCount = 0;
        //        }
        //#endif
        GrayN_InputStream is(p_GrayN_IAP_bos.Data(),p_GrayN_IAP_bos.Length());
        listener->GrayN_AppPurchaseOnIAP(true, &is);
    }
}
- (void)paymentSuccessWithAppRequest:(GrayN_AppRequest_GrayN*)appRequest productId:(NSString *)product transaction:(SKPaymentTransaction *)transaction
{
    string uniqueUserId = [GrayNbaseSDK GrayNgetGame_UserId];
    
    //存储数据库
    [GrayNbaseSDK GrayN_Debug_Log:@"===========记录订单:%@", BeNSString(appRequest->m_GrayN_AppRequest_SSID.c_str())];
    
    //订单号新增地区编码，如：订单号|CN，（取消）
    string ssid = appRequest->m_GrayN_AppRequest_SSID;
    NSString *specialCode=nil;  //国家码|货币码
    NSString *tCountryCode;
    NSString *tCurrencyCode;
    NSMutableString *tCode = nil;
    bool isOk = false;
    if (self.m_GrayN_IAP_StoreProductInfo.m_GrayNstatusCode == 1) {
        NSLog(@"OPGameSDK OPLOG:获取信息成功。。。");
        tCountryCode = self.m_GrayN_IAP_StoreProductInfo.m_GrayNcountryCode;
        tCurrencyCode = self.m_GrayN_IAP_StoreProductInfo.m_GrayNcurrencyCode;
        isOk = true;
        //非常重要，使用最新的地区码和货币码
        appRequest->m_GrayN_AppRequest_CountryCode = [tCountryCode UTF8String];
        appRequest->m_GrayN_AppRequest_CurrencyCode = [tCurrencyCode UTF8String];
    } else {
        NSLog(@"OPGameSDK OPLOG:获取信息失败。。。");
        tCountryCode = @"-";
        tCurrencyCode = @"-";
        //非常重要，获取失败使用“-”
        appRequest->m_GrayN_AppRequest_CountryCode = "-";
        appRequest->m_GrayN_AppRequest_CurrencyCode = "-";
        
        AppLog_GrayN* log = new AppLog_GrayN();
        log->CreateResponseAppLog_GrayN(ssid.c_str(), [product UTF8String], GrayN_SKErrorGetCurrency);
    }
    if (tCountryCode && tCurrencyCode) {
        if (![tCountryCode isEqualToString:self.m_GrayN_IAP_ChargeCountryCode] && isOk) {
            //可能被刷外币了
            [GrayNbaseSDK GrayN_Debug_Log:@"货币异常订单号：%@", BeNSString(ssid.c_str())];
            AppLog_GrayN* log = new AppLog_GrayN();
            log->CreateResponseAppLog_GrayN(ssid.c_str(), [product UTF8String], GrayN_SKErrorMoney);
        }
        tCode = [[NSMutableString alloc] init];
        [tCode appendString:tCountryCode];
        [tCode appendString:@"|"];
        [tCode appendString:tCurrencyCode];
    }
    if (tCode) {
        specialCode = [NSString stringWithString:tCode];
        [tCode release];
    }
    
    // 加密
    [self generateOPDesReceipt:transaction withCode:specialCode];
    GrayN_Store_IAP::GetInstance().GrayN_Store_IAP_InsertData(ssid,uniqueUserId,p_GrayN_IAP_DesReceipt);
    
#ifdef IAPDEBUG
    cout<<"GrayN_TempleQueue<GrayN_AppRequest_GrayN>::GetInstance().size()===="<<GrayN_TempleQueue<GrayN_AppRequest_GrayN>::GetInstance().size()<<endl;
#endif
    
    //不能在这里pop，因为后面还有用到
    //GrayN_TempleQueue<GrayN_AppRequest_GrayN>::GetInstance().pop();
#ifdef TEMPIAP
    //删除购买表中的记录
    //2016-9-22 修改为在收据发送成功后再删除购买记录
    //GrayN_Store_IAP::GetInstance().GrayN_Store_IAP_RemoveTempData(ssid);
#endif
    
    //创建日志并发送响应日志
    AppLog_GrayN* log = new AppLog_GrayN();
    log->CreateResponseAppLog_GrayN(ssid.c_str(), [product UTF8String], GrayN_SKSuccess);
    
}
- (void)completeTransaction:(SKPaymentTransaction *)transaction type:(int) tType
{
    NSString *product = transaction.payment.productIdentifier;
    [GrayNbaseSDK GrayN_Debug_Log:@"响应商品ID===========%@",product];
    
    if (tType == 0) {
        
        //使用队列中的ssid，这个是正确的
        GrayN_AppRequest_GrayN* appRequest = GrayN_TempleQueue<GrayN_AppRequest_GrayN>::GetInstance().front_element();
        if (appRequest == NULL) {
            [GrayNbaseSDK GrayN_Debug_Log:@"appRequest is null"];
            
            //创建日志并发送响应日志
            AppLog_GrayN* log = new AppLog_GrayN();
            log->CreateResponseAppLog_GrayN([p_GrayN_IAP_SSID UTF8String], [product UTF8String], GrayN_SKSuccessNormalButNoSSID);
        } else {
            [self paymentSuccessWithAppRequest:appRequest productId:product transaction:transaction];
        }
    } else {
        /*苹果有返回订单号 直接按照苹果订单走*/
        if (![transaction.payment.applicationUsername isEqualToString:@""] && transaction.payment.applicationUsername != nil) {
            [GrayNbaseSDK GrayN_Debug_Log:@"===========苹果有返回订单号的漏单！！！========"];
            
            GrayN_AppRequest_GrayN* appRequest = new GrayN_AppRequest_GrayN();
            appRequest->m_GrayN_AppRequest_SSID = [transaction.payment.applicationUsername UTF8String];
            appRequest->m_GrayN_AppRequest_ProductId = [product UTF8String];
            appRequest->m_GrayN_AppRequest_StartTime = [[GrayNbaseSDK GrayNgetCurrentMil_TimeString] UTF8String];
            appRequest->m_GrayN_AppRequest_CountryCode = [self.m_GrayN_IAP_ChargeCountryCode UTF8String];
            appRequest->m_GrayN_AppRequest_CurrencyCode = [self.m_GrayN_IAP_ChargeCurrencyCode UTF8String];
            GrayN_TempleQueue<GrayN_AppRequest_GrayN>::GetInstance().push(appRequest);
            if ([GrayNbaseSDK GrayNgetChargeLogSwitch]) {
                AppLog_GrayN* log = new AppLog_GrayN();
                log->CreateResponseAppLog_GrayN(appRequest->m_GrayN_AppRequest_SSID.c_str(), [product UTF8String], GrayN_SKRegainSuccessNotification);
            }
            
            [self paymentSuccessWithAppRequest:appRequest productId:product transaction:transaction];
            
            
            [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
            
            return;
        }
        
        
        NSString *specialCode = @"";  //国家码|货币码
        NSString *tCountryCode;
        NSString *tCurrencyCode;
        NSMutableString *tCode = nil;
        if (self.m_GrayN_IAP_StoreProductInfo) {
            if(self.m_GrayN_IAP_StoreProductInfo.m_GrayNstatusCode == 1){
                NSLog(@"OPGameSDK OPLOG:异常状况，获取信息成功。。。");
                tCountryCode = self.m_GrayN_IAP_StoreProductInfo.m_GrayNcountryCode;
                tCurrencyCode = self.m_GrayN_IAP_StoreProductInfo.m_GrayNcurrencyCode;
            } else {
                NSLog(@"OPGameSDK OPLOG:异常状况，获取信息失败。。。");
                tCountryCode = @"-";
                tCurrencyCode = @"-";
            }
            tCode = [[NSMutableString alloc] init];
            [tCode appendString:tCountryCode];
            [tCode appendString:@"|"];
            [tCode appendString:tCurrencyCode];
        }
        if (tCode) {
            specialCode = [NSString stringWithString:tCode];
            [tCode release];
        }
        if (p_GrayN_IsSpecial) {
            //这种情况交由客服处理，没办法。。。没有订单号，也不能从本地TEMP数据库中获取，如果订单号搞错，就更麻烦了。。。
            //IOS7 中用applicationName来保存订单号可以解决这个问题，暂时先不处理，等后续再处理
            [GrayNbaseSDK GrayN_Debug_Log:@"=========无订单号的漏单！！！========"];
            
#ifdef TEMPIAP
            //订单号
            [self generateOPDesReceipt:transaction withCode:specialCode];
            string userID = [GrayNbaseSDK GrayNgetGame_UserId];
            
            // 处理漏单，先从购买表中找到订单号，然后再插入到成功订单表中，对于此种漏单处理，暂时不将地区加入
            GrayN_Store_IAP::GetInstance().GrayN_Store_IAP_DealLeakedData([product UTF8String], userID, p_GrayN_IAP_DesReceipt);
#endif
            //创建日志并发送请求日志
            AppLog_GrayN* log = new AppLog_GrayN();
            log->CreateResponseAppLog_GrayN(NULL, [product UTF8String], GrayN_SKPurchasingAndSuccessUnNormalAndNoSSID);
            [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
            return;
        }
        [GrayNbaseSDK GrayN_Debug_Log:@"===========有漏单需要处理！！！========"];
        
#ifdef TEMPIAP
        //此种情况为，当用户点击购买后，未收到购买成功的回调（例如程序崩溃了），用户再次进入游戏时，会收到购买成功的通知，这时就需要从临时数据库中获取最近的订单号，然后将此保存到数据库中，让同步线程（SynchronousOrder）去处理
        //订单号
        [self generateOPDesReceipt:transaction withCode:specialCode];
        string userID = [GrayNbaseSDK GrayNgetGame_UserId];
        
        //处理漏单，先从购买表中找到订单号，然后再插入到成功订单表中，对于此种漏单处理，暂时不将地区加入
        GrayN_Store_IAP::GetInstance().GrayN_Store_IAP_DealLeakedData([product UTF8String], userID, p_GrayN_IAP_DesReceipt);
#endif
        
        //创建日志并发送请求日志
        AppLog_GrayN* log = new AppLog_GrayN();
        log->CreateResponseAppLog_GrayN(NULL, [product UTF8String], GrayN_SKSuccessUnNormalAndNoSSID);
    }
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    //道具id
    NSString *product = transaction.payment.productIdentifier;
    if (product == nil || [product isEqualToString:@""]) {
        product = @"-";
    }
    string errorStr;
    
    NSString *domain = @"SKErrorDomain";
    if([transaction.error.domain isEqualToString:domain]){
        //诊断失败的原因
        if (transaction.error.code == SKErrorPaymentCancelled)
        {
            errorStr = GrayN_SKErrorPaymentCancelled;
            [GrayNbaseSDK GrayN_Debug_Log:@"user cancelled the request."];
        }else if (transaction.error.code == SKErrorUnknown)
        {
            errorStr = GrayN_SKErrorUnknown;
            [GrayNbaseSDK GrayN_Debug_Log:@"SKErrorUnknown,Indicates that an unknown or unexpected error occurred."];
        }else if(transaction.error.code == SKErrorClientInvalid)
        {
            errorStr = GrayN_SKErrorClientInvalid;
            [GrayNbaseSDK GrayN_Debug_Log:@"SKErrorClientInvalid,Indicates that the client is not allowed to perform the attempted action."];
        }else if(transaction.error.code == SKErrorPaymentInvalid)
        {
            errorStr = GrayN_SKErrorPaymentInvalid;
            [GrayNbaseSDK GrayN_Debug_Log:@"SKErrorPaymentInvalid,Indicates that one of the payment parameters was not recognized by the Apple App Store."];
        }else if(transaction.error.code == SKErrorPaymentNotAllowed)
        {
            errorStr = GrayN_SKErrorPaymentNotAllowed;
            [GrayNbaseSDK GrayN_Debug_Log:@"SKErrorPaymentNotAllowed,Indicates that the user is not allowed to authorize payments."];
        }else if(transaction.error.code == SKErrorStoreProductNotAvailable)
        {
            errorStr = GrayN_SKErrorStoreProductNotAvailable;
            [GrayNbaseSDK GrayN_Debug_Log:@"SKErrorStoreProductNotAvailable,Indicates that the requested product is not available in the store."];
        }
    }else if ([transaction.error.domain isEqualToString:@"NSURLErrorDomain"]) {
        errorStr = GrayN_SKErrorNSURLErrorDomain;
        NSLog(@"OPGameSDK LOG:购买链接超时!!!");
    }else{
        errorStr = GrayN_SKErrorOther;
        //其他错误
        NSLog(@"OPGameSDK LOG:其他错误————%@",transaction.error.domain);
    }
    
    [GrayNbaseSDK GrayN_Debug_Log:@"GrayN_TempleQueue<GrayN_AppRequest_GrayN>::GetInstance().size()=%d",GrayN_TempleQueue<GrayN_AppRequest_GrayN>::GetInstance().size()];
    
    // 创建日志并发送请求日志
    GrayN_AppRequest_GrayN* appRequest = GrayN_TempleQueue<GrayN_AppRequest_GrayN>::GetInstance().front_element();
    if (appRequest) {
        string ssid = appRequest->m_GrayN_AppRequest_SSID;
        AppLog_GrayN* log = new AppLog_GrayN();
        log->CreateResponseAppLog_GrayN(ssid.c_str(), [product UTF8String], errorStr.c_str());
    } else {
        AppLog_GrayN* log = new AppLog_GrayN();
        log->CreateResponseAppLog_GrayN(NULL, [product UTF8String], errorStr.c_str());
    }
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
    [self notifyResult:false desc:[GrayNbaseSDK GrayNgetLocalLang:errorStr.c_str()]];
    
    GrayN_TempleQueue<GrayN_AppRequest_GrayN>::GetInstance().pop();
}

//记录交易
- (void)recordTransaction:(NSString *)product
{
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    NSLog(@"OPGameSDK LOG:checkRestore-Finished=%lu",(unsigned long)queue.transactions.count);
    if (queue.transactions.count > 0) {
        for (SKPaymentTransaction *transaction in queue.transactions)
        {
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            continue;
            
            if (transaction.transactionState == SKPaymentTransactionStatePurchased) {
                [GrayNbaseSDK GrayN_Debug_Log:@"restore=transactionDate=%@",transaction.transactionDate];
                [GrayNbaseSDK GrayN_Debug_Log:@"restore=transactionState=%ld",(long)transaction.transactionState];
                [GrayNbaseSDK GrayN_Debug_Log:@"restore=transactionDate=%@",transaction.payment.productIdentifier];
                [GrayNbaseSDK GrayN_Debug_Log:@"restore=transactionIdentifier=%@",transaction.transactionIdentifier];
                NSString *product = transaction.transactionIdentifier;
                if (product) {
                    //存储收据
                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                    NSString *countryCode = [userDefaults objectForKey:@"countryCode"];
                    NSString *currencyCode = [userDefaults objectForKey:@"currencyCode"];
                    if (countryCode == nil) {
                        countryCode = @"-";
                    }
                    if (currencyCode == nil) {
                        currencyCode = @"-";
                    }
                    string tCountryCode = [countryCode UTF8String];
                    string tCurrencyCode = [currencyCode UTF8String];
                    NSString *specialCode = [NSString stringWithFormat:@"%@|%@",countryCode,currencyCode];
                    [self generateOPDesReceipt:transaction withCode:specialCode];
                    //处理漏单
                    GrayN_Store_IAP::GetInstance().GrayN_Store_IAP_DealLeakedData([product UTF8String], "", p_GrayN_IAP_DesReceipt);
                    
                    //发送日志
                    AppLog_GrayN* log = new AppLog_GrayN();
                    log->CreateRestoreAppLog_GrayN([p_GrayN_IAP_SSID UTF8String], [product UTF8String],GrayN_SKCheckRestore);
                }
                
                //处理事务
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            }
        }
    }
    
    //    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //    [userDefaults setBool:NO forKey:@"RESTORE"];
    //    [userDefaults synchronize];
    //
    //    if (restoreType == OP_ChargeRestore) {
    //漏单已处理，发起新的支付
    //        [self requestProductInfo];
    //    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    NSLog(@"OPGameSDK LOG:checkRestore-Failed=%@",error);
    //    if (restoreType == OP_ChargeRestore) {
    //        [self failNotification];
    //    }
}
//- (void)failNotification
//{
//    GrayN_LoadingUI::GetInstance().GrayN_CloseGameWait();
//    //不用给游戏传递消息，SDK提示购买失败！
//    GrayN_LoadingUI::GetInstance().GrayN_ShowMsgBox([GrayNbaseSDK GrayNgetLocalLang:GrayN_Title], [GrayNbaseSDK GrayNgetLocalLang:GrayN_ChargeFail], 0, 1);
//
////    GrayN_AppRequest_GrayN* appRequest = GrayN_TempleQueue<GrayN_AppRequest_GrayN>::GetInstance().front_element();
//
//    GrayN_Store_IAP::GetInstance().GrayN_Store_IAP_PayResult(false, GrayN_Charge_FAILED_ERROR);
//    GrayN_TempleQueue<GrayN_AppRequest_GrayN>::GetInstance().pop();
//}
- (void)userKillGame
{
    if ([GrayNbaseSDK GrayNgetChargeLogSwitch]) {
        NSLog(@"userKillGame");
        if (p_GrayN_IAP_IsPaying) {
            AppLog_GrayN* log = new AppLog_GrayN();
            log->CreateResponseAppLog_GrayN([p_GrayN_IAP_SSID UTF8String], [p_GrayN_IAP_ProdcutId UTF8String], GrayN_SKUserKillGame);
        }
    }
}
- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    NSString *product = transaction.payment.productIdentifier;
    //非消耗性商品已经购买过，这时我们要按交易成功来处理
    GrayN_AppRequest_GrayN* appRequest = GrayN_TempleQueue<GrayN_AppRequest_GrayN>::GetInstance().front_element();
    if (appRequest) {
        AppLog_GrayN* log = new AppLog_GrayN();
        log->CreateResponseAppLog_GrayN(appRequest->m_GrayN_AppRequest_SSID.c_str(), [product UTF8String], GrayN_SKRestore);
        GrayN_TempleQueue<GrayN_AppRequest_GrayN>::GetInstance().pop();
    } else {
        AppLog_GrayN* log = new AppLog_GrayN();
        log->CreateResponseAppLog_GrayN(NULL, [product UTF8String], GrayN_SKRestoreNoSSID);
    }
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}


- (void)generateOPDesReceipt:(SKPaymentTransaction *) transaction withCode:(NSString *) code
{
    p_GrayN_IAP_bos.WriteInt(0);            //此处的0只是一个标识，不要误解
    //苹果定单号
    NSString *transactionIdentifier=transaction.transactionIdentifier;
    const char* cid=[transactionIdentifier UTF8String];
    p_GrayN_IAP_bos.WriteShort(transactionIdentifier.length);
    p_GrayN_IAP_bos.Write((char*)cid, (int)transactionIdentifier.length);
    //道具id
    NSString *product = transaction.payment.productIdentifier;
    p_GrayN_IAP_AppleReturnProductId.clear();
    p_GrayN_IAP_AppleReturnProductId = [product UTF8String];
    p_GrayN_IAP_bos.WriteShort(product.length);
    p_GrayN_IAP_bos.Write((char*)p_GrayN_IAP_AppleReturnProductId.c_str(), (int)product.length);
    //收据
    NSData *receipt=transaction.transactionReceipt;
    p_GrayN_IAP_bos.WriteShort(receipt.length);
    p_GrayN_IAP_bos.Write((char*)receipt.bytes, (int)receipt.length);
    
    //新的收据方式，下次升级
    //    NSData *receiptData;
    //    if ([[UIDevice currentDevice].systemVersion floatValue] > 6.9f) {
    //        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[[NSBundle mainBundle] appStoreReceiptURL]];//苹果推荐
    //        NSError *error = nil;
    //        receiptData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:nil error:&error];
    //    }
    //    else {
    //        receiptData = transaction.transactionReceipt;
    //    }
    //    NSString* receiptDataStr = [[NSString alloc] initWithData:receiptData encoding:NSUTF8StringEncoding];
    
    GrayN_InputStream is(p_GrayN_IAP_bos.Data(),p_GrayN_IAP_bos.Length());
    //    int num = is.ReadInt();    //这里不可缺少
    string info = "";
    GrayN_CONSTANT_Utf8 appleOrderId;//苹果订单号
    GrayN_CONSTANT_Utf8 productId;
    GrayN_CONSTANT_Utf8 receiptStr;
    //    int res = is.ReadInt();     //这里不可缺少
    appleOrderId.Read(is);
    productId.Read(is);
    receiptStr.Read(is);
    info.append("{\"receipt\":\"");
    
    //更换base64编码方式
    NSString* encoded = [[NSString alloc] initWithData:[GrayN_GTMBase64_GrayN encodeData:receipt] encoding:NSUTF8StringEncoding];
    string baseEncode = [encoded UTF8String];
    [encoded release];
    
    info.append(baseEncode.c_str());
    info.append("\",");
    info.append("\"appleOid\":\"");
    info.append(appleOrderId.Data());
    info.append("\"},");
    int idx = (int)info.find_last_of(",");
    if(idx >= 0){
        info.replace(idx, 1, "");
    }
    
    //保存数据库的收据格式变化
    //旧的是      收据
    //2015.8.27  国家码|货币码##收据
    string receiptInfo;
    if (code) {
        receiptInfo.append([code UTF8String]);
        receiptInfo.append("##");
    }else{
        receiptInfo.append("##");
    }
    receiptInfo.append(info);
    
    //将苹果返回的单据加密保存
    p_GrayN_IAP_DesReceipt.clear();
    string secretKey = GrayN_SynAppReceipt::GetInstance().m_GrayN_StoreKey;
    p_GrayN_IAP_DesReceipt = [[GrayNbaseSDK GrayNencodeDES:receiptInfo.c_str() andKey:secretKey.c_str()] UTF8String];
    
}

@end
