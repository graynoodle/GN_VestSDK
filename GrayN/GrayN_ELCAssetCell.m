//
//  AssetCell.m
//
//  Created by ELC on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import "GrayN_ELCAssetCell.h"
#import "GrayN_ELCAsset.h"
#import "GrayN_ELCConsole.h"
#import "GrayN_ELCOverlayImageView.h"

#ifdef PHOTOKIT_8_0
static PHImageManager *imageManager;
#endif

@interface GrayN_ELCAssetCell ()

@property (nonatomic, strong) NSArray *rowAssets;
@property (nonatomic, strong) NSMutableArray *imageViewArray;
@property (nonatomic, strong) NSMutableArray *overlayViewArray;

@end

@implementation GrayN_ELCAssetCell

//Using auto synthesizers

//-(void) dealloc
//{
//    [self.rowAssets release];
//    [self.imageViewArray release];
//    [self.overlayViewArray release];
//    [super dealloc];
//}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
	if (self) {
#ifdef PHOTOKIT_8_0
        if (imageManager == nil) {
            imageManager = [[PHCachingImageManager alloc] init];
        }
#endif
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellTapped:)];
        [self addGestureRecognizer:tapRecognizer];
        
        NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithCapacity:4];
        self.imageViewArray = mutableArray;
        
        NSMutableArray *overlayArray = [[NSMutableArray alloc] initWithCapacity:4];
        self.overlayViewArray = overlayArray;
        
        self.alignmentLeft = NO;
	}
	return self;
}

#ifdef PHOTOKIT_8_0
- (void)setAssets:(NSArray *)assets
{
    self.rowAssets = assets;
	for (UIImageView *view in _imageViewArray) {
        [view removeFromSuperview];
	}
    for (GrayN_ELCOverlayImageView *view in _overlayViewArray) {
        [view removeFromSuperview];
	}
    //set up a pointer here so we don't keep calling [UIImage imageNamed:] if creating overlays
    UIImage *overlayImage = nil;
    for (int i = 0; i < [_rowAssets count]; ++i) {

        GrayN_ELCAsset *asset = [_rowAssets objectAtIndex:i];

        if ([[UIDevice currentDevice].systemVersion floatValue] < 8.0f) {
        //if (floor(NSFoundationVersionNumber) < NSFoundationVersionNumber_iOS_8_0) {
            if (i < [_imageViewArray count]) {
                UIImageView *imageView = [_imageViewArray objectAtIndex:i];
                imageView.image = [UIImage imageWithCGImage:asset.asset.thumbnail];
            } else {
                UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithCGImage:asset.asset.thumbnail]];
                [_imageViewArray addObject:imageView];
            }
        }else{
            // Request an image for the asset from the PHCachingImageManager.
            [imageManager requestImageForAsset:asset.assetPH
                                    targetSize:PHImageManagerMaximumSize
                                   contentMode:PHImageContentModeAspectFill
                                       options:nil
                                 resultHandler:^(UIImage *result, NSDictionary *info) {
                                     if ([self.rowAssets containsObject:asset]) {
                                         
                                     }
                                 }];
            if (i < [_imageViewArray count]) {
                UIImageView *imageView = [_imageViewArray objectAtIndex:i];
                imageView.image = asset.image;
            } else {
                UIImageView *imageView = [[UIImageView alloc] initWithImage:asset.image];
                [_imageViewArray addObject:imageView];
            }
        }
        
        if (i < [_overlayViewArray count]) {
            GrayN_ELCOverlayImageView *overlayView = [_overlayViewArray objectAtIndex:i];
            overlayView.hidden = asset.selected ? NO : YES;
            overlayView.labIndex.text = [NSString stringWithFormat:@"%d", asset.index + 1];
        } else {
            if (overlayImage == nil) {
                NSString *fbPath = @"OurSDK_res.bundle/images/customOK.png";
                NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
                NSString *path = [resourcePath stringByAppendingPathComponent:fbPath];
                overlayImage = [UIImage imageWithContentsOfFile:path];
                //overlayImage = [UIImage imageNamed:@"Overlay.png"];
            }
            GrayN_ELCOverlayImageView *overlayView = [[GrayN_ELCOverlayImageView alloc] initWithImage:overlayImage];
            [_overlayViewArray addObject:overlayView];
            overlayView.hidden = asset.selected ? NO : YES;
            overlayView.labIndex.text = [NSString stringWithFormat:@"%d", asset.index + 1];
        }
    }
}
#else
- (void)setAssets:(NSArray *)assets
{
    self.rowAssets = assets;
    for (UIImageView *view in _imageViewArray) {
        [view removeFromSuperview];
    }
    for (GrayN_ELCOverlayImageView *view in _overlayViewArray) {
        [view removeFromSuperview];
    }
    //set up a pointer here so we don't keep calling [UIImage imageNamed:] if creating overlays
    UIImage *overlayImage = nil;
    for (int i = 0; i < [_rowAssets count]; ++i) {
        
        GrayN_ELCAsset *asset = [_rowAssets objectAtIndex:i];
        
        if (i < [_imageViewArray count]) {
            UIImageView *imageView = [_imageViewArray objectAtIndex:i];
            imageView.image = [UIImage imageWithCGImage:asset.asset.thumbnail];
        } else {
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithCGImage:asset.asset.thumbnail]];
            [_imageViewArray addObject:imageView];
        }
        
        if (i < [_overlayViewArray count]) {
            GrayN_ELCOverlayImageView *overlayView = [_overlayViewArray objectAtIndex:i];
            overlayView.hidden = asset.selected ? NO : YES;
            overlayView.labIndex.text = [NSString stringWithFormat:@"%d", asset.index + 1];
        } else {
            if (overlayImage == nil) {
                NSString *fbPath = @"OurSDK_res.bundle/images/customOK.png";
                NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
                NSString *path = [resourcePath stringByAppendingPathComponent:fbPath];
                overlayImage = [UIImage imageWithContentsOfFile:path];
                //overlayImage = [UIImage imageNamed:@"Overlay.png"];
            }
            GrayN_ELCOverlayImageView *overlayView = [[GrayN_ELCOverlayImageView alloc] initWithImage:overlayImage];
            [_overlayViewArray addObject:overlayView];
            overlayView.hidden = asset.selected ? NO : YES;
            overlayView.labIndex.text = [NSString stringWithFormat:@"%d", asset.index + 1];
        }
    }
}
#endif

- (void)cellTapped:(UITapGestureRecognizer *)tapRecognizer
{
    CGPoint point = [tapRecognizer locationInView:self];
    int c = (int32_t)self.rowAssets.count;
    CGFloat totalWidth = c * 75 + (c - 1) * 4;
    CGFloat startX;
    
    if (self.alignmentLeft) {
        startX = 4;
    }else {
        startX = (self.bounds.size.width - totalWidth) / 2;
    }
    
	CGRect frame = CGRectMake(startX, 2, 75, 75);
	
	for (int i = 0; i < [_rowAssets count]; ++i) {
        if (CGRectContainsPoint(frame, point)) {
            GrayN_ELCAsset *asset = [_rowAssets objectAtIndex:i];
            asset.selected = !asset.selected;
            GrayN_ELCOverlayImageView *overlayView = [_overlayViewArray objectAtIndex:i];
            overlayView.hidden = !asset.selected;
            if (asset.selected) {
                asset.index = [[GrayN_ELCConsole mainConsole] numOfSelectedElements];
                [overlayView setIndex:asset.index+1];
                [[GrayN_ELCConsole mainConsole] addIndex:asset.index];
            }
            else
            {
                int lastElement = [[GrayN_ELCConsole mainConsole] numOfSelectedElements] - 1;
                [[GrayN_ELCConsole mainConsole] removeIndex:lastElement];
            }
            break;
        }
        frame.origin.x = frame.origin.x + frame.size.width + 4;
    }
}

- (void)layoutSubviews
{
    int c = (int32_t)self.rowAssets.count;
    CGFloat totalWidth = c * 75 + (c - 1) * 4;
    CGFloat startX;
    
    if (self.alignmentLeft) {
        startX = 4;
    }else {
        startX = (self.bounds.size.width - totalWidth) / 2;
    }
    
	CGRect frame = CGRectMake(startX, 2, 75, 75);
	
	for (int i = 0; i < [_rowAssets count]; ++i) {
        GrayN_ELCAsset *asset = [_rowAssets objectAtIndex:i];
        
		UIImageView *imageView = [_imageViewArray objectAtIndex:i];
		[imageView setFrame:frame];
		[self addSubview:imageView];
        
        GrayN_ELCOverlayImageView *overlayView = [_overlayViewArray objectAtIndex:i];
        [overlayView setHidden:!asset.selected];
        [overlayView setFrame:frame];
        [self addSubview:overlayView];
		
		frame.origin.x = frame.origin.x + frame.size.width + 4;
	}
}


@end
