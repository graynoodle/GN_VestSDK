//
//  Asset.m
//
//  Created by ELC on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import "GrayN_ELCAsset.h"
#import "GrayN_ELCAssetTablePicker.h"

@implementation GrayN_ELCAsset

//Using auto synthesizers
- (NSString *)description
{
    return [NSString stringWithFormat:@"GrayN_ELCAsset index:%d",self.index];
}

- (id)initWithAsset:(ALAsset*)asset
{
	self = [super init];
	if (self) {
		self.asset = asset;
        _selected = NO;
    }
	return self;	
}

#ifdef PHOTOKIT_8_0
- (id)initWithPHAsset:(PHAsset *)asset
{
    self = [super init];
    if (self) {
        self.assetPH = asset;
        _selected = NO;
    }
    return self;
}
#endif

- (void)toggleSelection
{
    self.selected = !self.selected;
}

- (void)setSelected:(BOOL)selected
{
    if (selected) {
        if ([_parent respondsToSelector:@selector(shouldSelectAsset:)]) {
            if (![_parent shouldSelectAsset:self]) {
                return;
            }
        }
    } else {
        if ([_parent respondsToSelector:@selector(shouldDeselectAsset:)]) {
            if (![_parent shouldDeselectAsset:self]) {
                return;
            }
        }
    }
    _selected = selected;
    if (selected) {
        if (_parent != nil && [_parent respondsToSelector:@selector(assetSelected:)]) {
            [_parent assetSelected:self];
        }
    } else {
        if (_parent != nil && [_parent respondsToSelector:@selector(assetDeselected:)]) {
            [_parent assetDeselected:self];
        }
    }
}

-(void) setSelectedStatus:(BOOL) status
{
    _selected = status;
}

- (NSComparisonResult)compareWithIndex:(GrayN_ELCAsset *)_ass
{
    if (self.index > _ass.index) {
        return NSOrderedDescending;
    }
    else if (self.index < _ass.index)
    {
        return NSOrderedAscending;
    }
    return NSOrderedSame;
}

@end

