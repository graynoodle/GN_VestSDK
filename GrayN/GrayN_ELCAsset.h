//
//  Asset.h
//
//  Created by ELC on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#ifdef PHOTOKIT_8_0
#import <Photos/Photos.h>
#endif

@class GrayN_ELCAsset;

@protocol ELCAssetDelegate <NSObject>

@optional
- (void)assetSelected:(GrayN_ELCAsset *)asset;
- (BOOL)shouldSelectAsset:(GrayN_ELCAsset *)asset;
- (void)assetDeselected:(GrayN_ELCAsset *)asset;
- (BOOL)shouldDeselectAsset:(GrayN_ELCAsset *)asset;
@end


@interface GrayN_ELCAsset : NSObject

@property (nonatomic, strong) ALAsset *asset;
#ifdef PHOTOKIT_8_0
@property (nonatomic, strong) PHAsset *assetPH;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *assetPHIdentifier;
#endif
@property (nonatomic, strong) id<ELCAssetDelegate> parent;
@property (nonatomic, assign) BOOL selected;
@property (nonatomic,assign) int index;

- (id)initWithAsset:(ALAsset *)asset;
#ifdef PHOTOKIT_8_0
- (id)initWithPHAsset:(PHAsset *)asset;
#endif
- (NSComparisonResult)compareWithIndex:(GrayN_ELCAsset *)_ass;
-(void) setSelectedStatus:(BOOL) status;
@end
