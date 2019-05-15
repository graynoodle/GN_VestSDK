//
//  GrayN_Store_ProductInfo.m
//  OurpalmSDK
//
//  Created by JackYin on 15-8-26.
//  Copyright (c) 2015年 op-mac1. All rights reserved.
//

#import "GrayN_Store_ProductInfo.h"

@implementation GrayN_Store_ProductInfo

@synthesize m_GrayNstatusCode;
@synthesize m_GrayNcountryCode;
@synthesize m_GrayNcurrencyCode;

- (void)dealloc
{
    [m_GrayNcountryCode release];
    [m_GrayNcurrencyCode release];
    [super dealloc];
}

- (void)GrayN_GetProductInfo:(NSString*)GrayNapplePropId
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //sleep(20);
        // Create a set for your product identifier
        NSSet *productSet = [NSSet setWithObject:GrayNapplePropId];
        // Create a product request object and initialize it with the above set
        SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:productSet];
        request.delegate = self;
        m_GrayNstatusCode = 0;
        // Send the request to the App Store
        [request start];
    });
}

//SKProductsRequestDelegate
-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    if ([response.products count] > 0)
    {
        SKProduct *product = (SKProduct *)[response.products objectAtIndex:0];
        NSLocale *locale = product.priceLocale;
        self.m_GrayNcountryCode = [locale objectForKey:NSLocaleCountryCode];
        self.m_GrayNcurrencyCode = [locale objectForKey:NSLocaleCurrencyCode];
        NSLog(@"OPGameSDK OPLOG:!!!!!!!!!!");
        m_GrayNstatusCode = 1;
    }else{
        NSLog(@"无效商品列表：%@",response.invalidProductIdentifiers);
        m_GrayNstatusCode = 2;
    }
}

- (void)requestDidFinish:(SKRequest *)request
{
    
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    m_GrayNstatusCode = 3;
    //无法连接到appstore
    NSLog(@"request:didFailWithError:%@",error);
}

@end
