//
//  GrayN_ELCImagePickerController.h
//  ELCImagePickerDemo
//
//  Created by ELC on 9/9/10.
//  Copyright 2010 ELC Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GrayN_ELCAssetSelectionDelegate.h"

@class GrayN_ELCImagePickerController;

@protocol ELCImagePickerControllerDelegate <UINavigationControllerDelegate>

/**
 * Called with the picker the images were selected from, as well as an array of dictionary's
 * containing keys for ALAssetPropertyLocation, ALAssetPropertyType, 
 * UIImagePickerControllerOriginalImage, and UIImagePickerControllerReferenceURL.
 * @param picker
 * @param info An NSArray containing dictionary's with the key UIImagePickerControllerOriginalImage, which is a rotated, and sized for the screen 'default representation' of the image selected. If you want to get the original image, use the UIImagePickerControllerReferenceURL key.
 */
- (void)elcImagePickerController:(GrayN_ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info;

/**
 * Called when image selection was cancelled, by tapping the 'Cancel' BarButtonItem.
 */
- (void)elcImagePickerControllerDidCancel:(GrayN_ELCImagePickerController *)picker;


- (void)elcImagePickerControllerWithImageArray:(NSArray*)imageArray;

@end

@interface GrayN_ELCImagePickerController : UINavigationController <GrayN_ELCAssetSelectionDelegate>

@property (nonatomic, strong) NSString *alertTitle;
@property (nonatomic, strong) NSString *alertMsg;
@property (nonatomic, strong) NSString *alertBtnTtile;
@property (nonatomic, assign) UIInterfaceOrientation initOrientation;

@property (nonatomic, strong) id<ELCImagePickerControllerDelegate> imagePickerDelegate;
@property (nonatomic, assign) NSInteger maximumImagesCount;
@property (nonatomic, assign) BOOL onOrder;
/**
 * An array indicating the media types to be accessed by the media picker controller.
 * Same usage as for UIImagePickerController.
 */
@property (nonatomic, strong) NSArray *mediaTypes;

/**
 * YES if the picker should return a UIImage along with other meta info (this is the default),
 * NO if the picker should return the assetURL and other meta info, but no actual UIImage.
 */
@property (nonatomic, assign) BOOL returnsImage;

/**
 * YES if the picker should return the original image,
 * or NO for an image suitable for displaying full screen on the device.
 * Does nothing if `returnsImage` is NO.
 */
@property (nonatomic, assign) BOOL returnsOriginalImage;

@property (nonatomic, strong) UITableView *tableview;

- (id)initImagePicker;
- (void)cancelImagePicker;

@end

