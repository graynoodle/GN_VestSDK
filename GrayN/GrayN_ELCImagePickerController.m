//
//  GrayN_ELCImagePickerController.m
//  ELCImagePickerDemo
//
//  Created by ELC on 9/9/10.
//  Copyright 2010 ELC Technologies. All rights reserved.
//

#import "GrayN_ELCImagePickerController.h"
#import "GrayN_ELCAsset.h"
#import "GrayN_ELCAssetCell.h"
#import "GrayN_ELCAssetTablePicker.h"
#import <CoreLocation/CoreLocation.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "GrayN_ELCConsole.h"

@implementation GrayN_ELCImagePickerController

//Using auto synthesizers

- (id)initWithRootViewController:(UIViewController *)rootViewController
{
    
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        self.maximumImagesCount = 4;
        self.returnsImage = YES;
    }
    return self;
}

- (void)cancelImagePicker
{
    if ([_imagePickerDelegate respondsToSelector:@selector(elcImagePickerControllerDidCancel:)]) {
        [_imagePickerDelegate performSelector:@selector(elcImagePickerControllerDidCancel:) withObject:self];
    }
}

- (BOOL)shouldSelectAsset:(GrayN_ELCAsset *)asset previousCount:(NSUInteger)previousCount
{
    BOOL shouldSelect = previousCount < self.maximumImagesCount;
    if (!shouldSelect) {
        //        NSString *title = [NSString stringWithFormat:NSLocalizedString(@"Only %d photos please!", nil), self.maximumImagesCount];
        //        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"You can only send %d photos at a time.", nil), self.maximumImagesCount];
        NSString *title = self.alertTitle;
        NSString *message = self.alertMsg;
        [[[UIAlertView alloc] initWithTitle:title
                                    message:message
                                   delegate:nil
                          cancelButtonTitle:nil
                          otherButtonTitles:self.alertBtnTtile, nil] show];
    }
    return shouldSelect;
}

- (BOOL)shouldDeselectAsset:(GrayN_ELCAsset *)asset previousCount:(NSUInteger)previousCount;
{
    return YES;
}

- (void)selectedAssets:(NSArray *)assets
{
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    
    for(GrayN_ELCAsset *elcasset in assets) {
        ALAsset *asset = elcasset.asset;
        id obj = [asset valueForProperty:ALAssetPropertyType];
        if (!obj) {
            continue;
        }
        NSMutableDictionary *workingDictionary = [[NSMutableDictionary alloc] init];
        
        CLLocation* wgs84Location = [asset valueForProperty:ALAssetPropertyLocation];
        if (wgs84Location) {
            [workingDictionary setObject:wgs84Location forKey:ALAssetPropertyLocation];
        }
        
        [workingDictionary setObject:obj forKey:UIImagePickerControllerMediaType];
        
        //This method returns nil for assets from a shared photo stream that are not yet available locally. If the asset becomes available in the future, an ALAssetsLibraryChangedNotification notification is posted.
        ALAssetRepresentation *assetRep = [asset defaultRepresentation];
        
        if(assetRep != nil) {
            if (_returnsImage) {
                CGImageRef imgRef = nil;
                //defaultRepresentation returns image as it appears in photo picker, rotated and sized,
                //so use UIImageOrientationUp when creating our image below.
                UIImageOrientation orientation = UIImageOrientationUp;
                
                if (_returnsOriginalImage) {
                    imgRef = [assetRep fullResolutionImage];
                    orientation = [assetRep orientation];
                } else {
                    imgRef = [assetRep fullScreenImage];
                }
                if (imgRef == nil) {
                    //由于有些照片是从iCloud同步到本地，但原图没有下载到本地，所以无法找到原图
                    continue;
                }
                UIImage *img = [UIImage imageWithCGImage:imgRef
                                                   scale:1.0f
                                             orientation:orientation];
                [workingDictionary setObject:img forKey:UIImagePickerControllerOriginalImage];
            }
            
            [workingDictionary setObject:[[asset valueForProperty:ALAssetPropertyURLs] valueForKey:[[[asset valueForProperty:ALAssetPropertyURLs] allKeys] objectAtIndex:0]] forKey:UIImagePickerControllerReferenceURL];
            
            [returnArray addObject:workingDictionary];
        }
        [workingDictionary release]; //内存泄露
    }
    if (_imagePickerDelegate != nil && [_imagePickerDelegate respondsToSelector:@selector(elcImagePickerController:didFinishPickingMediaWithInfo:)]) {
        [_imagePickerDelegate performSelector:@selector(elcImagePickerController:didFinishPickingMediaWithInfo:) withObject:self withObject:returnArray];
    } else {
        [self popToRootViewControllerAnimated:NO];
    }
    [returnArray release];  //内存泄露
}

#ifdef PHOTOKIT_8_0
- (void)selectedPHAssets:(NSArray *)assets
{
    if (assets == nil || assets.count == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (_imagePickerDelegate != nil && [_imagePickerDelegate respondsToSelector:@selector(elcImagePickerControllerWithImageArray:)]) {
                [_imagePickerDelegate performSelector:@selector(elcImagePickerControllerWithImageArray:) withObject:nil];
            } else {
                [self popToRootViewControllerAnimated:NO];
            }
            [self.tableview reloadData];
        });
    }
    __block NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    __block NSMutableArray *requestIDArray = [[NSMutableArray alloc] init];
    __block int count = 0;
    __block int max = assets.count;
    for(GrayN_ELCAsset *elcasset in assets) {
        PHAsset *asset = elcasset.assetPH;
        
        [[PHImageManager defaultManager] requestImageForAsset:asset
                                                   targetSize:PHImageManagerMaximumSize
                                                  contentMode:PHImageContentModeAspectFill
                                                      options:nil
                                                resultHandler:^(UIImage *result, NSDictionary *info) {
                                                    NSString *PHImageResultRequestIDKey = [info objectForKey:@"PHImageResultRequestIDKey"];
                                                    if ([requestIDArray containsObject:PHImageResultRequestIDKey]) {
                                                        return;
                                                    }else{
                                                        [requestIDArray addObject:PHImageResultRequestIDKey];
                                                        [returnArray addObject:result];
                                                    }
                                                    count++;
                                                    if (count == max) {
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            //dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                            if (_imagePickerDelegate != nil && [_imagePickerDelegate respondsToSelector:@selector(elcImagePickerControllerWithImageArray:)]) {
                                                                [_imagePickerDelegate performSelector:@selector(elcImagePickerControllerWithImageArray:) withObject:returnArray];
                                                            } else {
                                                                [self popToRootViewControllerAnimated:NO];
                                                            }
                                                            [returnArray release];
                                                            [requestIDArray release];
                                                            [self.tableview reloadData];
                                                        });
                                                    }
                                                }];
    }
}
#endif

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
    } else {
        return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
    }
}

-(NSUInteger)supportedInterfaceOrientations{
    if (UIInterfaceOrientationIsLandscape(_initOrientation)) {
        return UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
    }
    return UIInterfaceOrientationPortrait | UIInterfaceOrientationPortraitUpsideDown;
}

- (BOOL)onOrder
{
    return [[GrayN_ELCConsole mainConsole] onOrder];
}

- (void)setOnOrder:(BOOL)onOrder
{
    [[GrayN_ELCConsole mainConsole] setOnOrder:onOrder];
}

@end
