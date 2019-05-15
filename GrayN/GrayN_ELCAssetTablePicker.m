//
//  GrayN_ELCAssetTablePicker.m
//
//  Created by ELC on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import "GrayN_ELCAssetTablePicker.h"
#import "GrayN_ELCAssetCell.h"
#import "GrayN_ELCAsset.h"
#import "GrayN_ELCConsole.h"

#import "GrayNcustomServiceConfig.h"
#import "GrayNcustomService_Control.h"

//#define PHOTODEBUG

#ifdef PHOTOKIT_8_0
@import Photos;
#endif

@interface GrayN_ELCAssetTablePicker ()

@property (nonatomic, assign) int columns;
@property (nonatomic, assign) NSUInteger max;
@property (nonatomic, assign) int count;
@property (nonatomic, strong) NSMutableArray *requestIDArray;

@end

@implementation GrayN_ELCAssetTablePicker

//Using auto synthesizers

- (id)init
{
    self = [super init];
    if (self) {
        //Sets a reasonable default bigger then 0 for columns
        //So that we don't have a divide by 0 scenario
        self.columns = 4;
    }
    return self;
}

- (void)viewDidLoad
{
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
	[self.tableView setAllowsSelection:NO];

    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    self.elcAssets = tempArray;
	
    if (self.immediateReturn) {
        
    } else {
        UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(doneAction:)];
        [self.navigationItem setRightBarButtonItem:doneButtonItem];
        [self.navigationItem setTitle:self.title];
    }

#ifdef PHOTOKIT_8_0
    if ([[UIDevice currentDevice].systemVersion floatValue] < 8.0f) {
    //if (floor(NSFoundationVersionNumber) < NSFoundationVersionNumber_iOS_8_0) {
        
    }else{
        if (self.imageManager == nil) {
            self.imageManager = [[PHCachingImageManager alloc] init];
        }
    }
#endif
    
    if (self.waitView == nil) {
        self.waitView=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
        self.waitView.layer.cornerRadius = 5.0;
        float max = MAX(self.view.center.x, self.view.center.y);
        float min = MIN(self.view.center.x, self.view.center.y);
        if ([[GrayNcustomService_Control GrayNshare] m_GrayNcustomService_IsPortrait]) {
            self.waitView.center = CGPointMake(min, max);
        }else{
            self.waitView.center = CGPointMake(max, min);
        }
        //NSLog(@"self.waitView.center=%@",NSStringFromCGPoint(self.waitView.center));
        [self.waitView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        [self.waitView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [self.waitView setBackgroundColor:[UIColor lightGrayColor]];
        [self.view addSubview:self.waitView];
        //[self.waitView startAnimating];
    }
	//[self performSelectorInBackground:@selector(preparePhotos) withObject:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
#ifdef PHOTODEBUG
    NSLog(@"GrayN_ELCAssetTablePicker viewWillAppear");
#endif
    [super viewWillAppear:animated];
    self.columns = self.view.bounds.size.width / 80;
    [self.waitView startAnimating];
    [self.view setUserInteractionEnabled:NO];
    [self.navigationItem.rightBarButtonItem setTitle:self.cancelTitle];
    [self performSelectorInBackground:@selector(preparePhotos) withObject:nil];
//    if (floor(NSFoundationVersionNumber) < NSFoundationVersionNumber_iOS_8_0) {
//        // Register for notifications when the photo library has changed
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(assetsChanged:)
//                                                     name:ALAssetsLibraryChangedNotification
//                                                   object:nil];
//    }else{
//        [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
//    }
}

- (void)viewWillDisappear:(BOOL)animated
{
#ifdef PHOTODEBUG
    NSLog(@"GrayN_ELCAssetTablePicker viewWillDisappear");
#endif
    [super viewWillDisappear:animated];
    [[GrayN_ELCConsole mainConsole] removeAllIndex];
    [self.elcAssets removeAllObjects];
    [self.tableView reloadData];
//    if (floor(NSFoundationVersionNumber) < NSFoundationVersionNumber_iOS_8_0) {
//        [[NSNotificationCenter defaultCenter] removeObserver:self name:ALAssetsLibraryChangedNotification object:nil];
//    }else{
//        [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
//    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    self.columns = self.view.bounds.size.width / 80;
    [self.tableView reloadData];
}

//-(void)assetsChanged:(NSNotification *)notification
//{
//    NSDictionary *userInfo = notification.userInfo;
//#ifdef DEBUG
//    NSLog(@"assetsChanged=%@",userInfo);
//#endif
//    NSSet *updateAssets = userInfo[ALAssetLibraryUpdatedAssetsKey];
//    if (updateAssets.count>0) {
//        [self preparePhotos];
//    }
//}
//
//- (void)photoLibraryDidChange:(PHChange *)changeInstance
//{
//    
//}

#ifdef PHOTOKIT_8_0
- (void)preparePhotos
{
    @autoreleasepool {
        
        if ([[UIDevice currentDevice].systemVersion floatValue] < 8.0f) {
        //if (floor(NSFoundationVersionNumber) < NSFoundationVersionNumber_iOS_8_0) {
            
        }else{
            // Create a PHFetchResult object for each section in the table view.
            PHFetchOptions *allPhotosOptions = [[PHFetchOptions alloc] init];
            allPhotosOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
            self.assetsFetchResults = [PHAsset fetchAssetsWithOptions:allPhotosOptions];
        }
        
        [self.elcAssets removeAllObjects];
        if ([[UIDevice currentDevice].systemVersion floatValue] < 8.0f) {
        //if (floor(NSFoundationVersionNumber) < NSFoundationVersionNumber_iOS_8_0) {
            [self.assetGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                
#ifdef PHOTODEBUG
                NSLog(@"GrayN_ELCAssetTablePicker preparePhotos result=%@,",result);
#endif
                if (result == nil) {
                    return;
                }
                
                GrayN_ELCAsset *elcAsset = [[GrayN_ELCAsset alloc] initWithAsset:result];
                [elcAsset setParent:self];
                
                BOOL isAssetFiltered = NO;
                if (self.assetPickerFilterDelegate &&
                    [self.assetPickerFilterDelegate respondsToSelector:@selector(assetTablePicker:isAssetFilteredOut:)])
                {
                    isAssetFiltered = [self.assetPickerFilterDelegate assetTablePicker:self isAssetFilteredOut:(GrayN_ELCAsset*)elcAsset];
                }
                
                if (!isAssetFiltered) {
                    [self.elcAssets addObject:elcAsset];
                }
                
            }];
            [self showPhotoView];
        }else{
            self.max = self.assetsFetchResults.count;
            self.count = 0;
            self.requestIDArray = [[NSMutableArray alloc] init];
            for (int i=0; i<self.assetsFetchResults.count; i++) {
                PHAsset *asset = self.assetsFetchResults[i];
#ifdef PHOTODEBUG
                NSLog(@"%@",asset);
#endif
                [self.imageManager requestImageForAsset:asset
                                             targetSize:CGSizeMake(75, 75)
                                            contentMode:PHImageContentModeAspectFill
                                                options:nil
                                          resultHandler:^(UIImage *result, NSDictionary *info) {
                                              NSString *PHImageResultRequestIDKey = [info objectForKey:@"PHImageResultRequestIDKey"];
                                              if ([self.requestIDArray containsObject:PHImageResultRequestIDKey]) {
                                                  return;
                                              }else{
                                                  [self.requestIDArray addObject:PHImageResultRequestIDKey];
                                              }
#ifdef PHOTODEBUG
                                              NSLog(@"result=%@,info=%@",result,info);
#endif
                                              GrayN_ELCAsset *elcAsset = [[GrayN_ELCAsset alloc] initWithPHAsset:asset];
                                              [elcAsset setImage:result];
                                              [elcAsset setParent:self];
                                              
                                              BOOL isAssetFiltered = NO;
                                              if (self.assetPickerFilterDelegate &&
                                                  [self.assetPickerFilterDelegate respondsToSelector:@selector(assetTablePicker:isAssetFilteredOut:)])
                                              {
                                                  isAssetFiltered = [self.assetPickerFilterDelegate assetTablePicker:self isAssetFilteredOut:(GrayN_ELCAsset*)elcAsset];
                                              }
                                              
                                              if (!isAssetFiltered) {
                                                  [self.elcAssets addObject:elcAsset];
                                              }
                                              self.count++;
                                              if (self.count == self.max) {
                                                  [self showPhotoView];
                                              }
                                          }];
            }
        }
    }
}
#else
- (void)preparePhotos
{
    @autoreleasepool {
        
        [self.elcAssets removeAllObjects];
        [self.assetGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            
#ifdef PHOTODEBUG
            NSLog(@"GrayN_ELCAssetTablePicker preparePhotos result=%@,",result);
#endif
            if (result == nil) {
                return;
            }
            
            GrayN_ELCAsset *elcAsset = [[GrayN_ELCAsset alloc] initWithAsset:result];
            [elcAsset setParent:self];
            
            BOOL isAssetFiltered = NO;
            if (self.assetPickerFilterDelegate &&
                [self.assetPickerFilterDelegate respondsToSelector:@selector(assetTablePicker:isAssetFilteredOut:)])
            {
                isAssetFiltered = [self.assetPickerFilterDelegate assetTablePicker:self isAssetFilteredOut:(GrayN_ELCAsset*)elcAsset];
            }
            
            if (!isAssetFiltered) {
                [self.elcAssets addObject:elcAsset];
            }
            [elcAsset release];
        }];
        [self showPhotoView];
        }
}
#endif

-(void) showPhotoView
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
#ifdef DEBUG_MEMORY
        [GrayNcustomService_Control curUsedMemory];
#endif
        [self.waitView stopAnimating];
        [self.view setUserInteractionEnabled:YES];
        
        [self.tableView reloadData];
        // scroll to bottom
        long section = [self numberOfSectionsInTableView:self.tableView] - 1;
        long row = [self tableView:self.tableView numberOfRowsInSection:section] - 1;
        if (section >= 0 && row >= 0) {
            NSIndexPath *ip = [NSIndexPath indexPathForRow:row
                                                 inSection:section];
            [self.tableView scrollToRowAtIndexPath:ip
                                  atScrollPosition:UITableViewScrollPositionBottom
                                          animated:NO];
        }
        
        //[self.navigationItem setTitle:self.title];
        //[self.navigationItem setTitle:self.singleSelection ? NSLocalizedString(@"Pick Photo", nil) : NSLocalizedString(@"Pick Photos", nil)];
    });
}


- (void)doneAction:(id)sender
{
	NSMutableArray *selectedAssetsImages = [[NSMutableArray alloc] init];
    
	for (GrayN_ELCAsset *elcAsset in self.elcAssets) {
		if ([elcAsset selected]) {
            [elcAsset setSelectedStatus:NO];
			[selectedAssetsImages addObject:elcAsset];
		}
	}
    if ([[GrayN_ELCConsole mainConsole] onOrder]) {
        [selectedAssetsImages sortUsingSelector:@selector(compareWithIndex:)];
    }
    
#ifdef PHOTOKIT_8_0
    if ([[UIDevice currentDevice].systemVersion floatValue] < 8.0f) {
    //if (floor(NSFoundationVersionNumber) < NSFoundationVersionNumber_iOS_8_0) {
        [self.parent selectedAssets:selectedAssetsImages];
    }else{
        [self.parent selectedPHAssets:selectedAssetsImages];
    }
#else
    [self.parent selectedAssets:selectedAssetsImages];
#endif
    [selectedAssetsImages release];
}


- (BOOL)shouldSelectAsset:(GrayN_ELCAsset *)asset
{
    NSUInteger selectionCount = 0;
    for (GrayN_ELCAsset *elcAsset in self.elcAssets) {
        if (elcAsset.selected) selectionCount++;
    }
    BOOL shouldSelect = YES;
    if ([self.parent respondsToSelector:@selector(shouldSelectAsset:previousCount:)]) {
        shouldSelect = [self.parent shouldSelectAsset:asset previousCount:selectionCount];
    }
    return shouldSelect;
}

- (void)assetSelected:(GrayN_ELCAsset *)asset
{
    int numOfSelectedElements = [[GrayN_ELCConsole mainConsole] numOfSelectedElements];
    if (!self.singleSelection && numOfSelectedElements==0) {
        [self.navigationItem.rightBarButtonItem setTitle:self.sureTitle];
    }
    if (self.singleSelection) {
//        for (GrayN_ELCAsset *elcAsset in self.elcAssets) {
//            if (asset != elcAsset) {
//                elcAsset.selected = NO;
//            }
//        }
        [asset setSelectedStatus:NO];
    }
    if (self.immediateReturn) {

        NSArray *singleAssetArray = @[asset];
        
#ifdef PHOTOKIT_8_0
        if ([[UIDevice currentDevice].systemVersion floatValue] < 8.0f) {
        //if (floor(NSFoundationVersionNumber) < NSFoundationVersionNumber_iOS_8_0) {
            [(NSObject *)self.parent performSelector:@selector(selectedAssets:) withObject:singleAssetArray afterDelay:0];
        }else{
            [(NSObject *)self.parent performSelector:@selector(selectedPHAssets:) withObject:singleAssetArray afterDelay:0];
        }
        //[self.tableView reloadData];
#else
        [(NSObject *)self.parent performSelector:@selector(selectedAssets:) withObject:singleAssetArray afterDelay:0];
#endif
    }
}

- (BOOL)shouldDeselectAsset:(GrayN_ELCAsset *)asset
{
    if (self.immediateReturn){
        return NO;
    }
    return YES;
}

- (void)assetDeselected:(GrayN_ELCAsset *)asset
{
    int numOfSelectedElements = [[GrayN_ELCConsole mainConsole] numOfSelectedElements];
    if (!self.singleSelection && numOfSelectedElements==1) {
        [self.navigationItem.rightBarButtonItem setTitle:self.cancelTitle];
    }
    if (self.singleSelection) {
        for (GrayN_ELCAsset *elcAsset in self.elcAssets) {
            if (asset != elcAsset) {
                elcAsset.selected = NO;
            }
        }
    }

    if (self.immediateReturn) {
        NSArray *singleAssetArray = @[asset.asset];
        [(NSObject *)self.parent performSelector:@selector(selectedAssets:) withObject:singleAssetArray afterDelay:0];
    }
    
    //int numOfSelectedElements = [[GrayN_ELCConsole mainConsole] numOfSelectedElements];
    if (asset.index < numOfSelectedElements - 1) {
        NSMutableArray *arrayOfCellsToReload = [[NSMutableArray alloc] initWithCapacity:1];
        
        for (int i = 0; i < [self.elcAssets count]; i++) {
            GrayN_ELCAsset *assetInArray = [self.elcAssets objectAtIndex:i];
            if (assetInArray.selected && (assetInArray.index > asset.index)) {
                assetInArray.index -= 1;
                
                int row = i / self.columns;
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
                BOOL indexExistsInArray = NO;
                for (NSIndexPath *indexInArray in arrayOfCellsToReload) {
                    if (indexInArray.row == indexPath.row) {
                        indexExistsInArray = YES;
                        break;
                    }
                }
                if (!indexExistsInArray) {
                    [arrayOfCellsToReload addObject:indexPath];
                }
            }
        }
        [self.tableView reloadRowsAtIndexPaths:arrayOfCellsToReload withRowAnimation:UITableViewRowAnimationNone];
        [arrayOfCellsToReload release];
    }
}

#pragma mark UITableViewDataSource Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.columns <= 0) { //Sometimes called before we know how many columns we have
        self.columns = 4;
    }
    NSInteger numRows = ceil([self.elcAssets count] / (float)self.columns);
    return numRows;
}

- (NSArray *)assetsForIndexPath:(NSIndexPath *)path
{
    long index = path.row * self.columns;
    long length = MIN(self.columns, [self.elcAssets count] - index);
    return [self.elcAssets subarrayWithRange:NSMakeRange(index, length)];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    static NSString *CellIdentifier = @"Cell";
        
    GrayN_ELCAssetCell *cell = (GrayN_ELCAssetCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {		        
        cell = [[GrayN_ELCAssetCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    [cell setAssets:[self assetsForIndexPath:indexPath]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 79;
}

- (int)totalSelectedAssets
{
    int count = 0;
    
    for (GrayN_ELCAsset *asset in self.elcAssets) {
		if (asset.selected) {
            count++;	
		}
	}
    
    return count;
}


@end
