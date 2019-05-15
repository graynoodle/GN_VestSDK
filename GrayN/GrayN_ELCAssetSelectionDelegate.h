//
//  GrayN_ELCAssetSelectionDelegate.h
//  ELCImagePickerDemo
//
//  Created by JN on 9/6/12.
//  Copyright (c) 2012 ELC Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GrayN_ELCAsset;

@protocol GrayN_ELCAssetSelectionDelegate <NSObject>

- (void)selectedAssets:(NSArray *)assets;
#ifdef PHOTOKIT_8_0
- (void)selectedPHAssets:(NSArray *)assets;
#endif
- (BOOL)shouldSelectAsset:(GrayN_ELCAsset *)asset previousCount:(NSUInteger)previousCount;
- (BOOL)shouldDeselectAsset:(GrayN_ELCAsset *)asset previousCount:(NSUInteger)previousCount;

@end
