//
//  GrayN_Store_ProductInfo.h
//  OurpalmSDK
//
//  Created by JackYin on 15-8-26.
//  Copyright (c) 2015年 op-mac1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@interface GrayN_Store_ProductInfo : NSObject <SKProductsRequestDelegate>

@property (assign) int m_GrayNstatusCode;
@property (nonatomic,retain) NSString *m_GrayNcountryCode;
@property (nonatomic,retain) NSString *m_GrayNcurrencyCode;

- (void)GrayN_GetProductInfo:(NSString*)GrayNapplePropId;

@end
