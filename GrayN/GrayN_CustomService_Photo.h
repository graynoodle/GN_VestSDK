//
//  GrayN_CustomService_Photo.h
//  FeedbackDemo
//
//  Created by op-mac1 on 15-4-1.
//  Copyright (c) 2015年 op-mac1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/ALAssetsLibrary.h>
#import <AssetsLibrary/ALAssetsGroup.h>
#import <AssetsLibrary/ALAssetRepresentation.h>

#ifdef PHOTOKIT_8_0
#import <ImageIO/ImageIO.h>
#endif

#import "GrayN_ELCImagePickerHeader.h"
#import "GrayNcustomService_ImageData.h"

typedef void (^GrayN_CustomService_PhotoHandler)(NSMutableArray * imagesArray);

@interface GrayN_CustomService_Photo : NSObject<ELCImagePickerControllerDelegate>

@property (nonatomic, strong) ALAssetsLibrary *m_GrayN_CustomService_PhotoLibrary;

- (void)GrayN_CustomService_ResetData;
- (void)GrayN_CustomService_PickPictureMaxImageNum:(int)maxNum withHandler:(GrayN_CustomService_PhotoHandler) handler;
- (void)GrayN_CustomService_DeletePicture:(NSString*)filePath;

@end
