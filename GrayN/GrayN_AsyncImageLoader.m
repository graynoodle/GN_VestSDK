//
//  GrayN_AsyncImageLoader.m
//
//  Created by JackYin on 16/10/15.
//  Copyright (c) 2015年 op-mac1. All rights reserved.
//

#import "GrayN_AsyncImageLoader.h"

static NSMutableDictionary *downloadDic;    //存储下载的任务，防止重复下载

@implementation GrayN_AsyncImageLoader

+(id)GrayN_shareLoader{
    static GrayN_AsyncImageLoader *sharedImageLoader = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedImageLoader = [[self alloc] init];
        downloadDic = [[NSMutableDictionary alloc] init];
    });
    
    return sharedImageLoader;
}

- (void)GrayN_DownloadImageWithUrl:(NSURL *)url imageName:(NSString*)fileName complete:(GrayN_ImageDownloadedBlock)completeBlock{
    
    // 内存和文件中都没有再从网络下载
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //防止重复下载
        if ([downloadDic objectForKey:fileName]) {
#ifdef DEBUG
            NSLog(@"图片已加载到下载队列！");
#endif
            return;
        }
        //存储下载任务
        [downloadDic setObject:url forKey:fileName];
        
        NSError * error;
        NSData *imgData = [NSData dataWithContentsOfURL:url options:NSDataReadingMappedIfSafe error:&error];
        NSString *path = [NSString stringWithString:fileName];
        UIImage *image = [UIImage imageWithData:imgData];
        
        if (image) {
            if([imgData writeToFile:path atomically:YES]){
#ifdef DEBUG
                NSLog(@"图片下载成功：%@",path);
#endif
            }else{
                [downloadDic removeObjectForKey:path];
            }
        }else{
            NSLog(@"error when download:%@",[url absoluteString]);
            [downloadDic removeObjectForKey:path];
        }
        
        if (completeBlock) {
            completeBlock(image,error,url);
        }
    });
}

@end
