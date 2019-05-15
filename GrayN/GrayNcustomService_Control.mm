
//
//  GrayNcustomService_Control.m
//  FeedbackDemo
//
//  Created by op-mac1 on 15-4-1.
//  Copyright (c) 2015年 op-mac1. All rights reserved.
//

#import "GrayNcustomService_Control.h"

#import "GrayNcustomService_ImageData.h"
#import "GrayN_GzipUtility.h"
#import "GrayN_CustomServiceUploadFile.h"
#import "GrayN_BaseControl.h"
#import "GrayNcustomServiceConfig.h"

#import "GrayN_CustomService_Photo.h"

static GrayNcustomService_Control * p_GrayNcustomServiceShare;

@interface GrayNcustomService_Control ()
{
    GrayN_CustomService_Photo *p_GrayNcustomService_Photo;
    NSString *p_GrayNcustomService_UploadURL;
    NSString *p_GrayNcustomService_LimitSize;
    void (^p_GrayNcustomService_UploadImgCallback)(id responseData);

}
@end

@implementation GrayNcustomService_Control
@synthesize m_GrayNcustomService_IsPortrait;
@synthesize m_GrayNcustomService_ImageArray;
@synthesize m_GrayNcustomService_LangDic;


+ (id)GrayNshare
{
    @synchronized ([GrayNcustomService_Control class]) {
        if (p_GrayNcustomServiceShare == nil) {
            p_GrayNcustomServiceShare = [[GrayNcustomService_Control alloc] init];
            
            if (p_GrayNcustomServiceShare.m_GrayNcustomService_LangDic == nil) {
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    NSString* tmp = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDevelopmentRegion"];
                    NSString* curLanguage;
                    if (tmp == nil) {
                        curLanguage = @"zh_CN";
                    }else{
                        curLanguage = tmp;
                    }
                    NSString* langFileName = [NSString stringWithFormat:@"OurSDK_res.bundle/Language/Ourpalm_%@.plist",curLanguage];
                    NSString *plistPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:langFileName];
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    if(![fileManager fileExistsAtPath:plistPath]){
                        plistPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"OurSDK_res.bundle/Language/Ourpalm_zh_CN.plist"];
                    }
                    p_GrayNcustomServiceShare.m_GrayNcustomService_LangDic = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
                });
            }
            
            UIInterfaceOrientation orientation = [GrayN_BaseControl GrayN_Base_WindowInitOrientation];
            if (UIInterfaceOrientationIsPortrait(orientation)) {
                p_GrayNcustomServiceShare.m_GrayNcustomService_IsPortrait = true;
            }else{
                p_GrayNcustomServiceShare.m_GrayNcustomService_IsPortrait = false;
            }
        }
    }
    return p_GrayNcustomServiceShare;
}

- (void)GrayNcustomServiceSdkUploadImg:(NSString *)url withLimitSize:(NSString *)size handler:(GrayNcustomService_ResponseCallback)handler
{
    if (p_GrayNcustomService_Photo == nil) {
        p_GrayNcustomService_Photo = [[GrayN_CustomService_Photo alloc] init];
    }
    p_GrayNcustomService_UploadURL = [url copy];
    p_GrayNcustomService_LimitSize = [size copy];
    [p_GrayNcustomService_UploadImgCallback release];
    p_GrayNcustomService_UploadImgCallback = [handler copy];
    
    UIWindow *baseWindow = [[GrayN_BaseControl GrayN_Share] GrayN_GetSDK_Window];
    baseWindow.windowLevel = UIWindowLevelNormal;
    
    [p_GrayNcustomService_Photo GrayN_CustomService_PickPictureMaxImageNum:1 withHandler:^(NSMutableArray *imagesArray) {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
            UIWindow *baseWindow = [[GrayN_BaseControl GrayN_Share] GrayN_GetSDK_Window];
            baseWindow.windowLevel = UIWindowLevelAlert;
        }
        if (imagesArray != nil) {
            [[GrayNcustomService_Control GrayNshare] GrayNcustomServiceUploadPicWithPicArray:imagesArray];
        }
    }];
}
- (void)GrayNcustomServiceNotifyUploadSuccessWithData:(NSDictionary *)data
{
    p_GrayNcustomService_UploadImgCallback(data);
}
/* sdk单独上传图片 */
-(void) GrayNcustomServiceUploadPicWithPicArray:(NSArray*) tImageArray
{
    self.m_GrayNcustomService_ImageArray = tImageArray;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, (unsigned long) NULL), ^(void){
        //上传图片
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        for (int i=0; i<m_GrayNcustomService_ImageArray.count; i++) {
            GrayNcustomService_ImageData *imageData = [m_GrayNcustomService_ImageArray objectAtIndex:i];
            [[GrayNcustomService_Control GrayNshare] upLoadPicPath:imageData];
        }

        [m_GrayNcustomService_ImageArray release];
        m_GrayNcustomService_ImageArray = nil;
        [pool release];
    });
}
-(void) upLoadPicPath:(GrayNcustomService_ImageData*) imageData
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *srcPath = [NSString stringWithFormat:@"%@/%@",imageData.m_GrayNcustomService_ImagePath,imageData.m_GrayNcustomService_ImageName];
    if ([fileManager fileExistsAtPath:srcPath]) {
#ifdef DEBUG
        NSLog(@"srcPath=%@",srcPath);
#endif
        NSString *upLoadFilePath = [NSString stringWithFormat:@"%@/%@",imageData.m_GrayNcustomService_ImagePath,imageData.m_GrayNcustomService_ImageName];
#ifdef DEBUG
        NSLog(@"开始上传图片=%@",upLoadFilePath);
#endif

        //压缩图片
        UIImage* image = [UIImage imageWithContentsOfFile:upLoadFilePath];
        NSData *data;
        if (UIImagePNGRepresentation(image) == nil) {
            data = UIImageJPEGRepresentation(image, 1.0);
        } else {
            data = UIImagePNGRepresentation(image);
        }
        
        NSData *gzipData = [GrayN_GzipUtility GrayN_GzipData:data];
        NSUInteger dataLength = gzipData.length;
        
        // iOS系统获取文件的大小比linux少75个bytes
        NSLog(@"file Size%llu",[[fileManager attributesOfItemAtPath:upLoadFilePath error:nil] fileSize]);
        NSLog(@"gzip Size%ld",(unsigned long)dataLength);
        NSLog(@"original Size%ld",(unsigned long)data.length);
        NSLog(@"limit size %0.1f",[p_GrayNcustomService_LimitSize floatValue]*1024);

        
        NSString *imageName = imageData.m_GrayNcustomService_ImageName;
        
        GrayN_CustomServiceUploadFile *upload = [[[GrayN_CustomServiceUploadFile alloc] init] autorelease];

        NSString *urlString = p_GrayNcustomService_UploadURL;
        NSLog(@"%@", urlString);
        [upload GrayN_UploadFileWithUrl:urlString fileName:imageName fileLength:dataLength zipImageData:gzipData localURL:srcPath];
    }
    [pool release];
}
- (NSString*)GrayNgetLanString:(NSString*)key
{
    return [m_GrayNcustomService_LangDic objectForKey:key];
}

- (void)dealloc
{
    [p_GrayNcustomService_Photo release];
    p_GrayNcustomService_Photo = nil;
    [super dealloc];
}


@end
