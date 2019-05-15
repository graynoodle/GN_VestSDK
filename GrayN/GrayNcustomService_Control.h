//
//  GrayNcustomService_Control.h
//  FeedbackDemo
//
//  Created by op-mac1 on 15-4-1.
//  Copyright (c) 2015年 op-mac1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//#define DEBUG_MEMORY

typedef void (^GrayNcustomService_ResponseCallback)(id responseData);

@class GrayNcustomService_ImageData;
@interface GrayNcustomService_Control : NSObject

@property (nonatomic,assign) bool m_GrayNcustomService_IsPortrait;
@property (nonatomic,retain) NSArray *m_GrayNcustomService_ImageArray;
@property (nonatomic,retain) NSDictionary *m_GrayNcustomService_LangDic;

+ (id)GrayNshare;
- (NSString*)GrayNgetLanString:(NSString*)key;

// 上传图片
- (void)GrayNcustomServiceUploadPicWithPicArray:(NSArray*)tImageArray;
- (void)GrayNcustomServiceSdkUploadImg:(NSString *)url withLimitSize:(NSString *)size handler:(GrayNcustomService_ResponseCallback)handler;
- (void)GrayNcustomServiceNotifyUploadSuccessWithData:(NSDictionary *)data;

@end
