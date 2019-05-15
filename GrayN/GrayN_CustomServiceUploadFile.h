//
//  GrayN_CustomServiceUploadFile.h
//
//  Created by op-mac1 on 15-4-10.
//  Copyright (c) 2015年 op-mac1. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GrayN_CustomServiceUploadFile : NSObject

@property (nonatomic,retain) NSDictionary* m_GrayN_UploadFile_HeaderDic;

- (void)GrayN_UploadFileWithUrl:(NSURL *)url fileName:(NSString*)fileName zipImageData:(NSData *)data;
//-(void) GrayN_UploadFileWithUrl:(NSURL *)url fileName:(NSString*)fileName jsonStr:(NSString*)jsonStr data:(NSData *)data;
- (void)GrayN_UploadFileWithUrl:(NSString *)url fileName:(NSString *)fileName fileLength:(NSUInteger)fileLength zipImageData:(NSData *)data localURL:(NSString *)localUrl;

@end
