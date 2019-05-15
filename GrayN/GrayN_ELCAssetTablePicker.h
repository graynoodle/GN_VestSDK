//
//  GrayN_ELCAssetTablePicker.h
//
//  Created by ELC on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#ifdef PHOTOKIT_8_0
#import <Photos/Photos.h>
#endif
#import "GrayN_ELCAsset.h"
#import "GrayN_ELCAssetSelectionDelegate.h"
#import "GrayN_ELCAssetPickerFilterDelegate.h"

#ifdef PHOTOKIT_8_0
@interface GrayN_ELCAssetTablePicker : UITableViewController <ELCAssetDelegate,PHPhotoLibraryChangeObserver>
#else
@interface GrayN_ELCAssetTablePicker : UITableViewController <ELCAssetDelegate>
#endif

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *sureTitle;
@property (nonatomic, strong) NSString *cancelTitle;

@property (nonatomic, strong) UIActivityIndicatorView *waitView;

@property (nonatomic, strong) id <GrayN_ELCAssetSelectionDelegate> parent;
@property (nonatomic, strong) ALAssetsGroup *assetGroup;
#ifdef PHOTOKIT_8_0
@property (nonatomic, strong) PHCachingImageManager *imageManager;
@property (nonatomic, strong) PHFetchResult *assetsFetchResults;
#endif
@property (nonatomic, strong) NSMutableArray *elcAssets;
@property (nonatomic, strong) IBOutlet UILabel *selectedAssetsLabel;
@property (nonatomic, assign) BOOL singleSelection;
@property (nonatomic, assign) BOOL immediateReturn;

// optional, can be used to filter the assets displayed
@property(nonatomic, strong) id<GrayN_ELCAssetPickerFilterDelegate> assetPickerFilterDelegate;

- (int)totalSelectedAssets;
- (void)preparePhotos;

- (void)doneAction:(id)sender;

@end
