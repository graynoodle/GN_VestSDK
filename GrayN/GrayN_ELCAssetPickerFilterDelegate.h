//
// GrayN_ELCAssetPickerFilterDelegate.h

@class GrayN_ELCAsset;
@class GrayN_ELCAssetTablePicker;

@protocol GrayN_ELCAssetPickerFilterDelegate<NSObject>

// respond YES/NO to filter out (not show the asset)
-(BOOL)assetTablePicker:(GrayN_ELCAssetTablePicker *)picker isAssetFilteredOut:(GrayN_ELCAsset *)elcAsset;

@end
