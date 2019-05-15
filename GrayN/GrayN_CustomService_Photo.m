//
//  GrayN_CustomService_Photo.m
//  FeedbackDemo
//
//  Created by op-mac1 on 15-4-1.
//  Copyright (c) 2015年 op-mac1. All rights reserved.
//

#import "GrayN_CustomService_Photo.h"
#import "GrayN_BaseControl.h"

#import "GrayNcustomServiceConfig.h"
#import "GrayNcustomService_Control.h"

#import <MobileCoreServices/UTCoreTypes.h>

//#ifdef PHOTO_DEBUG

@interface GrayN_CustomService_Photo ()
{
    unsigned long long m_GrayN_CustomService_PhotoFileSize;        //文件大小，以M为单位
    int m_GrayN_CustomService_PhotoMaxImageNum;
}

@property (nonatomic,copy) GrayN_ELCImagePickerController *m_GrayN_CustomService_PhotoElcPicker;
@property (nonatomic,copy) GrayN_CustomService_PhotoHandler m_GrayN_CustomService_PhotoHandler;

@end

@implementation GrayN_CustomService_Photo

@synthesize m_GrayN_CustomService_PhotoElcPicker;
@synthesize m_GrayN_CustomService_PhotoLibrary=_m_GrayN_CustomService_PhotoLibrary;
@synthesize m_GrayN_CustomService_PhotoHandler;

- (id)init
{
    self = [super init];  // Call a designated initializer here.
    if (self != nil) {
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)GrayN_CustomService_ResetData
{
    m_GrayN_CustomService_PhotoFileSize = 0;
}

- (void)GrayN_CustomService_PickPictureMaxImageNum:(int)maxNum withHandler:(GrayN_CustomService_PhotoHandler) handler
{
    m_GrayN_CustomService_PhotoMaxImageNum = maxNum;
    [self GrayN_InitImagePickerController];
    self.m_GrayN_CustomService_PhotoHandler = handler;
}

- (void)GrayN_InitImagePickerController
{
    if (self.m_GrayN_CustomService_PhotoLibrary == nil) {
        self.m_GrayN_CustomService_PhotoLibrary = [[ALAssetsLibrary alloc] init];
    }
    NSMutableArray *groups = [NSMutableArray array];
    [_m_GrayN_CustomService_PhotoLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            [groups addObject:group];
        } else {
            // this is the end
            [self GrayN_DisplayPickerForGroup:[groups objectAtIndex:0]];
        }
    } failureBlock:^(NSError *error) {
        UIAlertView * alert = [[[UIAlertView alloc] initWithTitle:GrayNcustomServiceGetString(GrayNcustomService_Title) message:[NSString stringWithFormat:@"%@ - %@", [error localizedDescription], GrayNcustomServiceGetString(GrayNcustomService_Suggestion)] delegate:nil cancelButtonTitle:GrayNcustomServiceGetString(GrayNcustomService_Sure) otherButtonTitles:nil] autorelease];
        [alert show];
        
        NSLog(@"A problem occured %@", [error description]);
        // an error here means that the asset groups were inaccessable.
        // Maybe the user or system preferences refused access.
    }];
    m_GrayN_CustomService_PhotoFileSize = 0;
}

- (void)GrayN_DisplayPickerForGroup:(ALAssetsGroup *)group
{
    if (m_GrayN_CustomService_PhotoElcPicker == nil) {
        GrayN_ELCAssetTablePicker *tablePicker = [[GrayN_ELCAssetTablePicker alloc] initWithStyle:UITableViewStylePlain];
        tablePicker.singleSelection = NO;
        tablePicker.immediateReturn = NO;
        tablePicker.title = GrayNcustomServiceGetString(GrayNcustomService_UploadPic);
        tablePicker.sureTitle = GrayNcustomServiceGetString(GrayNcustomService_Sure);
        tablePicker.cancelTitle = GrayNcustomServiceGetString(GrayNcustomService_Cancel);
        
        m_GrayN_CustomService_PhotoElcPicker = [[GrayN_ELCImagePickerController alloc] initWithRootViewController:tablePicker];
        m_GrayN_CustomService_PhotoElcPicker.initOrientation = [GrayN_BaseControl GrayN_Base_WindowInitOrientation];
        
        m_GrayN_CustomService_PhotoElcPicker.imagePickerDelegate = self;
        m_GrayN_CustomService_PhotoElcPicker.returnsOriginalImage = YES; //Only return the fullScreenImage, not the fullResolutionImage
        m_GrayN_CustomService_PhotoElcPicker.returnsImage = YES; //Return UIimage if YES. If NO, only return asset location information
        m_GrayN_CustomService_PhotoElcPicker.onOrder = NO; //For single image selection, do not display and return order of selected images
        m_GrayN_CustomService_PhotoElcPicker.alertTitle = GrayNcustomServiceGetString(GrayNcustomService_UploadPic);
        m_GrayN_CustomService_PhotoElcPicker.alertMsg = GrayNcustomServiceGetString(GrayNcustomService_PicAlertNumError);
        m_GrayN_CustomService_PhotoElcPicker.alertBtnTtile = GrayNcustomServiceGetString(GrayNcustomService_Sure);
        tablePicker.parent = m_GrayN_CustomService_PhotoElcPicker;
        m_GrayN_CustomService_PhotoElcPicker.tableview = tablePicker.tableView;
        
        // Move me
        tablePicker.assetGroup = group;
        [tablePicker.assetGroup setAssetsFilter:[ALAssetsFilter allAssets]];
    }
    m_GrayN_CustomService_PhotoElcPicker.maximumImagesCount = m_GrayN_CustomService_PhotoMaxImageNum;
    if (m_GrayN_CustomService_PhotoMaxImageNum == 1) {
        GrayN_ELCAssetTablePicker *tablePicker = (GrayN_ELCAssetTablePicker *)m_GrayN_CustomService_PhotoElcPicker.topViewController;
        tablePicker.singleSelection = YES;
        tablePicker.immediateReturn = YES;
    }else{
        GrayN_ELCAssetTablePicker *tablePicker = (GrayN_ELCAssetTablePicker *)m_GrayN_CustomService_PhotoElcPicker.topViewController;
        tablePicker.singleSelection = NO;
        tablePicker.immediateReturn = NO;
    }
    UIViewController *rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    [rootViewController presentViewController:m_GrayN_CustomService_PhotoElcPicker animated:YES completion:nil];
}

#pragma mark ELCImagePickerControllerDelegate Methods

- (void)elcImagePickerControllerWithImageArray:(NSArray*)imageArray
{
    UIViewController *rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    [rootViewController dismissViewControllerAnimated:YES completion:nil];
    
    NSMutableArray *tmpArray = [[NSMutableArray alloc] initWithCapacity:1];
    for (int i=0; i<imageArray.count; i++) {
        UIImage *image = [imageArray objectAtIndex:i];
        [self GrayN_SaveDataInArray:tmpArray withImage:image];
    }
#ifdef DEBUG_MEMORY
    [GrayNcustomService_Control curUsedMemory];
#endif
    if (m_GrayN_CustomService_PhotoFileSize > 5) {
        [imageArray release];
        [self GrayN_PhotoShowAlertMsg:1];
        self.m_GrayN_CustomService_PhotoHandler(nil);
        //[self performSelector:@selector(releaseData) withObject:nil afterDelay:1];
        return;
    }
    NSInteger count = [tmpArray count];
    if (count) {
        self.m_GrayN_CustomService_PhotoHandler(tmpArray);
    }else{
        self.m_GrayN_CustomService_PhotoHandler(nil);
    }
    [tmpArray release];

}

- (void)elcImagePickerController:(GrayN_ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info
{
    UIViewController *rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    [rootViewController dismissViewControllerAnimated:YES completion:nil];
    
    NSMutableArray *imageArray = [[NSMutableArray alloc] initWithCapacity:1];
    for (NSDictionary *dict in info) {
        if ([dict objectForKey:UIImagePickerControllerMediaType] == ALAssetTypePhoto){
            if ([dict objectForKey:UIImagePickerControllerOriginalImage]){
                UIImage* image=[dict objectForKey:UIImagePickerControllerOriginalImage];
                [self GrayN_SaveDataInArray:imageArray withImage:image];
            } else {
                NSLog(@"UIImagePickerControllerReferenceURL = %@", dict);
            }
        } else if ([dict objectForKey:UIImagePickerControllerMediaType] == ALAssetTypeVideo){
            if ([dict objectForKey:UIImagePickerControllerOriginalImage]){
                UIImage* image=[dict objectForKey:UIImagePickerControllerOriginalImage];
                [self GrayN_SaveDataInArray:imageArray withImage:image];
            } else {
                NSLog(@"UIImagePickerControllerReferenceURL = %@", dict);
            }
        } else {
            NSLog(@"Uknown asset type");
        }
    }
#ifdef DEBUG_MEMORY
    [GrayNcustomService_Control curUsedMemory];
#endif
    if (m_GrayN_CustomService_PhotoFileSize > 5) {
        [imageArray release];
        [self GrayN_PhotoShowAlertMsg:1];
        self.m_GrayN_CustomService_PhotoHandler(nil);
        //[self performSelector:@selector(releaseData) withObject:nil afterDelay:1];
        return;
    }
    NSInteger count = [imageArray count];
    if (count) {
        self.m_GrayN_CustomService_PhotoHandler(imageArray);
    }else{
        self.m_GrayN_CustomService_PhotoHandler(nil);
    }
    [imageArray release];
    //[self performSelector:@selector(releaseData) withObject:nil afterDelay:1];
}

-(void) releaseData
{
    [m_GrayN_CustomService_PhotoElcPicker release];
    m_GrayN_CustomService_PhotoElcPicker = nil;
}

- (void)elcImagePickerControllerDidCancel:(GrayN_ELCImagePickerController *)picker
{
    UIViewController *rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    [rootViewController dismissViewControllerAnimated:YES completion:nil];
}


- (void)GrayN_SaveDataInArray:(NSMutableArray*) array withImage:(UIImage*) image
{
    //1>**********压缩图片尺寸
    CGSize newSize;
    float minWidth = 0;
    float minHeight = 0;
#ifdef PHOTO_DEBUG
    NSLog(@"image.srcSize=%@",NSStringFromCGSize(image.size));
#endif
    if (image.size.width < image.size.height) {
#ifdef PHOTO_DEBUG
        NSLog(@"竖屏图片");
#endif
        minWidth = MIN(320, image.size.width);
        minHeight = MIN(480, image.size.height);
    }else{
#ifdef PHOTO_DEBUG
        NSLog(@"横屏图片");
#endif
        minWidth = MIN(480, image.size.width);
        minHeight = MIN(320, image.size.height);
    }
    newSize = CGSizeMake(minWidth, minHeight);
#ifdef PHOTO_DEBUG
    NSLog(@"image.newSize=%@",NSStringFromCGSize(newSize));
#endif
    UIImage* newImage = nil;
    if (image.size.width == newSize.width && image.size.height == newSize.height) {
        newImage = image;//尺寸相同就不需要尺寸压缩了
    }else{
        newImage = [self GrayN_PhotoImageWithImageSimple:image scaledToSize:newSize];
    }
    //2>**********如果是jpg图片，缩减图片质量
    NSData *data;
    if (UIImagePNGRepresentation(newImage) == nil)
    {
        data = UIImageJPEGRepresentation(newImage, 1.0);
    }
    else
    {
        //png图片
        data = UIImagePNGRepresentation(newImage);
    }
    
    //图片保存的路径
    //这里将图片放在沙盒的documents文件夹中
    NSArray *path=NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES);
    NSString *docDir=[path objectAtIndex:0];
    NSString *dirPath=[docDir stringByAppendingPathComponent:@"tmpImage"];
    NSString *imageDirPath = [docDir stringByAppendingPathComponent:@"OPAsynImage"];
    
    //文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //把刚刚图片转换的data对象拷贝至沙盒中 并保存为image.png
    [fileManager createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
    [fileManager createDirectoryAtPath:imageDirPath withIntermediateDirectories:YES attributes:nil error:nil];
    UInt64 recordTime = [[NSDate date] timeIntervalSince1970]*1000; //获取当前时间，毫秒级
    NSString *fileName = [NSString stringWithFormat:@"%llu.png",recordTime];
    NSString *filePath = [dirPath stringByAppendingFormat:@"/%@",fileName];
    //NSLog(@"filePath=%@",filePath);
    [fileManager createFileAtPath:filePath contents:data attributes:nil];
    
    //计算文件大小
    if ([fileManager fileExistsAtPath:filePath]){
        unsigned long long tmpFileSize = [[fileManager attributesOfItemAtPath:filePath error:nil] fileSize];
        tmpFileSize = tmpFileSize/1024.0;
#ifdef PHOTO_DEBUG
        NSLog(@"fileName=%@,tmpFileSize=%lluKB",fileName,tmpFileSize);
#endif
        tmpFileSize = tmpFileSize/1024.0+m_GrayN_CustomService_PhotoFileSize;
        m_GrayN_CustomService_PhotoFileSize = tmpFileSize;
#ifdef PHOTO_DEBUG
        NSLog(@"filesize=%lluM",m_GrayN_CustomService_PhotoFileSize);
#endif
        GrayNcustomService_ImageData *imageData = [[GrayNcustomService_ImageData alloc] init];
        imageData.m_GrayNcustomService_ImagePath = dirPath;
        imageData.m_GrayNcustomService_ImageName = fileName;
        [array addObject:imageData];
//        self.m_GrayN_CustomService_PhotoHandler(imageData);
        [imageData release];
    }
}

- (void)GrayN_CustomService_DeletePicture:(NSString*)filePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]){
        unsigned long long tmpFileSize = [[fileManager attributesOfItemAtPath:filePath error:nil] fileSize];
        m_GrayN_CustomService_PhotoFileSize -= tmpFileSize/1024.0/1024.0;
        NSError *err;
        //NSLog(@"fileName=%@,tmpFileSize=%lluKB",filePath,tmpFileSize);
        [fileManager removeItemAtPath:filePath error:&err];
    }
}

- (void)GrayN_PhotoShowAlertMsg:(int) tag
{
    NSString *message = nil;
    if (tag == 0) {
        message = GrayNcustomServiceGetString(GrayNcustomService_PicAlertNumError);
    }else{
        message = GrayNcustomServiceGetString(GrayNcustomService_PicAlertLargeError);//图片大小不能超过5M
    }
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:GrayNcustomServiceGetString(GrayNcustomService_Title) message:message
                                                    delegate:nil
                                           cancelButtonTitle:nil
                                           otherButtonTitles:GrayNcustomServiceGetString(GrayNcustomService_Sure),nil];
    [alert show];
    [alert release];
}

//*****************************图片压缩*********************************
//压缩图片质量
-(UIImage *)GrayN_PhotoReduceImage:(UIImage *)image percent:(float)percent
{
    NSData *imageData = UIImageJPEGRepresentation(image, percent);
    UIImage *newImage = [UIImage imageWithData:imageData];
    return newImage;
}

//压缩图片尺寸
-(UIImage*)GrayN_PhotoImageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize
{
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // End the context
    UIGraphicsEndImageContext();
    // Return the new image.
    return newImage;
}

#ifdef SDK_NEWIMAGE
static size_t getAssetBytesCallback(void *info, void *buffer, off_t position, size_t count) {
    ALAssetRepresentation *rep = (__bridge id)info;
    
    NSError *error = nil;
    size_t countRead = [rep getBytes:(uint8_t *)buffer fromOffset:position length:count error:&error];
    
    if (countRead == 0 && error) {
        // We have no way of passing this info back to the caller, so we log it, at least.
        NSLog(@"thumbnailForAsset:maxPixelSize: got an error reading an asset: %@", error);
    }
    
    return countRead;
}

static void releaseAssetCallback(void *info) {
    // The info here is an ALAssetRepresentation which we CFRetain in thumbnailForAsset:maxPixelSize:.
    // This release balances that retain.
    CFRelease(info);
}

// Returns a UIImage for the given asset, with size length at most the passed size.
// The resulting UIImage will be already rotated to UIImageOrientationUp, so its CGImageRef
// can be used directly without additional rotation handling.
// This is done synchronously, so you should call this method on a background queue/thread.
- (UIImage *)thumbnailForAsset:(ALAsset *)asset maxPixelSize:(NSUInteger)size {
    NSParameterAssert(asset != nil);
    NSParameterAssert(size > 0);
    
    ALAssetRepresentation *rep = [asset defaultRepresentation];
    
    CGDataProviderDirectCallbacks callbacks = {
        .version = 0,
        .getBytePointer = NULL,
        .releaseBytePointer = NULL,
        .getBytesAtPosition = getAssetBytesCallback,
        .releaseInfo = releaseAssetCallback,
    };
    
    CGDataProviderRef provider = CGDataProviderCreateDirect((void *)CFBridgingRetain(rep), [rep size], &callbacks);
    CGImageSourceRef source = CGImageSourceCreateWithDataProvider(provider, NULL);
    
    CGImageRef imageRef = CGImageSourceCreateThumbnailAtIndex(source, 0, (__bridge CFDictionaryRef) @{
                                                                                                      (NSString *)kCGImageSourceCreateThumbnailFromImageAlways : @YES,
                                                                                                      (NSString *)kCGImageSourceThumbnailMaxPixelSize : [NSNumber numberWithInt:size],
                                                                                                      (NSString *)kCGImageSourceCreateThumbnailWithTransform : @YES,
                                                                                                      });
    CFRelease(source);
    CFRelease(provider);
    
    if (!imageRef) {
        return nil;
    }
    
    UIImage *toReturn = [UIImage imageWithCGImage:imageRef];
    
    CFRelease(imageRef);
    
    return toReturn;
}
#endif

@end
