//
//  GrayN_AsyncImageLoader.h
//
//  Created by JackYin on 16/10/15.
//  Copyright (c) 2015年 op-mac1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^GrayN_ImageDownloadedBlock)(UIImage *image, NSError *error, NSURL *imageURL);

@interface GrayN_AsyncImageLoader : NSObject

+ (id)GrayN_shareLoader;

- (void)GrayN_DownloadImageWithUrl:(NSURL *)url imageName:(NSString*)fileName complete:(GrayN_ImageDownloadedBlock)completeBlock;

@end
