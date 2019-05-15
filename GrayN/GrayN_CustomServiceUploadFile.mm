//
//  GrayN_CustomServiceUploadFile.m
//
//  Created by op-mac1 on 15-4-10.
//  Copyright (c) 2015年 op-mac1. All rights reserved.
//

#import "GrayN_CustomServiceUploadFile.h"
#import "GrayNbaseSDK.h"
#import "GrayNcustomService_Control.h"
#import "GrayNcustomServiceConfig.h"

//#define DEBUG_UPLOAD

@interface GrayN_CustomServiceUploadFile ()
{
    int p_GrayN_UploadFileRequestCount;
}

@property (nonatomic,copy) NSMutableURLRequest *p_GrayN_UploadFileRequest;
@property (nonatomic,copy) NSString *p_GrayN_UploadFileName;
@property (nonatomic,assign) NSUInteger p_GrayN_UploadFileLength;
@property (nonatomic,copy) NSString *p_GrayN_UploadLocalUrl;

@end

@implementation GrayN_CustomServiceUploadFile

@synthesize p_GrayN_UploadFileRequest;
@synthesize p_GrayN_UploadFileName;
@synthesize m_GrayN_UploadFile_HeaderDic;
@synthesize p_GrayN_UploadFileLength;
@synthesize p_GrayN_UploadLocalUrl;

// 拼接字符串
static NSString *p_GrayN_BoundaryString = @"--";   // 分隔字符串
static NSString *p_GrayN_RandomIdString;           // 本次上传标示字符串
static NSString *p_GrayN_UploadId;              // 上传(php)脚本中，接收文件字段

- (instancetype)init
{
    self = [super init];
    if (self) {
        p_GrayN_RandomIdString = @"itcast";
        p_GrayN_UploadId = @"uploadFile";
        p_GrayN_UploadFileRequestCount = 0;
    }
    return self;
}

-(void) dealloc
{
    [p_GrayN_UploadFileRequest release];
    [p_GrayN_UploadFileName release];
    [m_GrayN_UploadFile_HeaderDic release];
    [super dealloc];
}

#pragma mark - 上传文件
-(void) GrayN_UploadFileWithUrl:(NSURL *)url fileName:(NSString*)fileName zipImageData:(NSData *)data
{
    self.p_GrayN_UploadFileName = fileName;
    
    // 1> 数据体
    NSString *topStr = [self topStringWithMimeType:@"image/png" uploadFile:fileName];
    NSString *bottomStr = [self bottomString];
    
    NSMutableData *dataM = [NSMutableData data];
    [dataM appendData:[topStr dataUsingEncoding:NSUTF8StringEncoding]];
    [dataM appendData:data];
    [dataM appendData:[bottomStr dataUsingEncoding:NSUTF8StringEncoding]];
    
    [topStr release];
    [bottomStr release];
    
    // 1. Request
    self.p_GrayN_UploadFileRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0f];
    
    // dataM出了作用域就会被释放,因此不用copy
    p_GrayN_UploadFileRequest.HTTPBody = dataM;
    
    // 2> 设置Request的头属性
    p_GrayN_UploadFileRequest.HTTPMethod = @"POST";
    
    // 3> 设置Content-Length
    NSString *strLength = [NSString stringWithFormat:@"%ld", (long)dataM.length];
    [p_GrayN_UploadFileRequest setValue:strLength forHTTPHeaderField:@"Content-Length"];
    
    // 4> 设置Content-Type
    NSString *strContentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", p_GrayN_RandomIdString];
    [p_GrayN_UploadFileRequest setValue:strContentType forHTTPHeaderField:@"Content-Type"];
    
    //设置自定义头信息
    if (m_GrayN_UploadFile_HeaderDic) {
        for (id key in m_GrayN_UploadFile_HeaderDic.allKeys) {
            NSString *value = [m_GrayN_UploadFile_HeaderDic objectForKey:key];
            [p_GrayN_UploadFileRequest setValue:value forHTTPHeaderField:key];
            
        }
    }
    
    // 3> 连接服务器发送请求
    [self uploadFile];
}

#pragma mark - private API

- (NSString *)topStringWithMimeType:(NSString *)mimeType uploadFile:(NSString *)uploadFile
{
    NSMutableString *strM = [NSMutableString string];
    
    [strM appendFormat:@"%@%@\r\n", p_GrayN_BoundaryString, p_GrayN_RandomIdString];
    [strM appendFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", p_GrayN_UploadId, uploadFile];
    [strM appendFormat:@"Content-Type: %@\r\n\r\n", @"application/octet-stream"];
    
#ifdef DEBUG_UPLOAD
    NSLog(@"%@", strM);
#endif
    return [strM copy];
}

- (NSString *)bottomString
{
    NSMutableString *strM = [NSMutableString string];
    
    [strM appendFormat:@"%@%@\r\n", p_GrayN_BoundaryString, p_GrayN_RandomIdString];
    [strM appendString:@"Content-Disposition: multipart/form-data; name=\"submit\"\r\n\r\n"];
    [strM appendString:@"Submit\r\n"];
    [strM appendFormat:@"%@%@--\r\n", p_GrayN_BoundaryString, p_GrayN_RandomIdString];
    
#ifdef DEBUG_UPLOAD
    NSLog(@"%@", strM);
#endif
    return [strM copy];
}

-(void) uploadFile
{
    p_GrayN_UploadFileRequestCount++;
    if (p_GrayN_UploadFileRequestCount > 3) {
        return;
    }
    NSOperationQueue * queue = [[[NSOperationQueue alloc] init] autorelease];
    [NSURLConnection sendAsynchronousRequest:p_GrayN_UploadFileRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        if ([data length] > 0 && connectionError == nil) {
            __autoreleasing NSError* err = nil;
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&err];
            if (err!=nil) {
                NSLog(@"OPGameSDK OPLOG:UploadFile Error = %@", dic);
                [self uploadFile];
            }else{
                NSString *status = [dic objectForKey:@"status"];
                NSString *reset = [dic objectForKey:@"reset"];
                if (status && reset && [status integerValue] == 0 && [reset integerValue] == 1000) {
                    NSLog(@"OPGameSDK OPLOG:UploadFile Success=%@（%d）",self.p_GrayN_UploadFileName,p_GrayN_UploadFileRequestCount);
                }else{
                    NSLog(@"OPGameSDK OPLOG:UploadFile Error = %@", dic);
                    [self uploadFile];
                }
            }
        }else if ([data length] == 0 && connectionError == nil){
            NSLog(@"OPGameSDK OPLOG:UploadFile Error = Nothing was downloaded.");
            [self uploadFile];
        }else if (connectionError != nil){
            NSLog(@"OPGameSDK OPLOG:UploadFile Error = %@",connectionError);
            [self uploadFile];
        }
        
    }];
}
-(void) GrayN_UploadFileWithUrl:(NSString *)url fileName:(NSString *)fileName fileLength:(NSUInteger)fileLength zipImageData:(NSData *)data localURL:(NSString *)localUrl
{
    self.p_GrayN_UploadFileName = fileName;
    self.p_GrayN_UploadFileLength = fileLength;
    self.p_GrayN_UploadLocalUrl = localUrl;
    // 1> 数据体
    
    NSMutableString *body = [[NSMutableString alloc] init];
    // encryptKey
    NSString *encryptKey = [NSString stringWithFormat:@"%@%lu", fileName, (unsigned long)fileLength];
    encryptKey = [GrayNbaseSDK GrayNencodeDES:encryptKey];
    body = [self setParamsKey:@"jsonStr" value:[NSString stringWithFormat:@"{\"encryptKey\":\"%@\"}", encryptKey] body:body];
    
    NSString *topStr = [self topStringWithMimeType:@"image/png" uploadFile:fileName];
    [body appendString:topStr];
    
    NSMutableData *dataM = [NSMutableData data];
    [dataM appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    [dataM appendData:data];
    
    NSString *bottomStr = [self bottomStringNew];
    [dataM appendData:[bottomStr dataUsingEncoding:NSUTF8StringEncoding]];
    
    [topStr release];
    [bottomStr release];
    
    NSString *encodedString=[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *uploadUrl = [NSURL URLWithString:encodedString];
    
    // 1. Request
    self.p_GrayN_UploadFileRequest = [NSMutableURLRequest requestWithURL:uploadUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0f];
    // dataM出了作用域就会被释放,因此不用copy
    p_GrayN_UploadFileRequest.HTTPBody = dataM;
    
    // 2> 设置Request的头属性
    p_GrayN_UploadFileRequest.HTTPMethod = @"POST";
    
    // 3> 设置Content-Length
    NSString *strLength = [NSString stringWithFormat:@"%ld", (long)dataM.length];
    [p_GrayN_UploadFileRequest setValue:strLength forHTTPHeaderField:@"Content-Length"];
    
    // 4> 设置Content-Type
    NSString *strContentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", p_GrayN_RandomIdString];
    [p_GrayN_UploadFileRequest setValue:strContentType forHTTPHeaderField:@"Content-Type"];
    
    //设置自定义头信息
    if (m_GrayN_UploadFile_HeaderDic) {
        for (id key in m_GrayN_UploadFile_HeaderDic.allKeys) {
            NSString *value = [m_GrayN_UploadFile_HeaderDic objectForKey:key];
            [p_GrayN_UploadFileRequest setValue:value forHTTPHeaderField:key];
        }
    }
    [GrayNbaseSDK GrayNshow_Wait];

    // 3> 连接服务器发送请求
    [self uploadFileNew];
}

- (NSMutableString*)setParamsKey:(NSString*)key value:(NSString*)value body:(NSMutableString*)body{
    
    NSString *TWITTERFON_FORM_BOUNDARY = p_GrayN_RandomIdString;
    //分界线 --p_GrayN_RandomIdString
    NSString *MPboundary=[[NSString alloc]initWithFormat:@"--%@",TWITTERFON_FORM_BOUNDARY];
    //添加分界线，换行
    [body appendFormat:@"%@\r\n",MPboundary];
    //添加字段名称，换2行
    [body appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",key];
    //添加字段的值
    [body appendFormat:@"%@\r\n",value];
    
    return body;
}
- (NSString *)bottomStringNew
{
    NSMutableString *strM = [NSMutableString string];
    
    [strM appendFormat:@"\r\n%@%@%@\r\n", p_GrayN_BoundaryString, p_GrayN_RandomIdString, p_GrayN_BoundaryString];
    //    [strM appendString:@"Content-Disposition: multipart/form-data; name=\"submit\"\r\n\r\n"];
    //    [strM appendString:@"Submit\r\n"];
    //    [strM appendFormat:@"%@%@--\r\n", p_GrayN_BoundaryString, p_GrayN_RandomIdString];
    
#ifdef DEBUG_UPLOAD
    NSLog(@"%@", strM);
#endif
    return [strM copy];
}

-(void) uploadFileNew
{
    p_GrayN_UploadFileRequestCount++;
    if (p_GrayN_UploadFileRequestCount > 3) {
        return;
    }
    NSOperationQueue * queue = [[[NSOperationQueue alloc] init] autorelease];
    [NSURLConnection sendAsynchronousRequest:p_GrayN_UploadFileRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        [GrayNbaseSDK GrayNclose_Wait];

        if ([data length] > 0 && connectionError == nil) {
            __autoreleasing NSError* err = nil;
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&err];
            if (err!=nil) {
                NSLog(@"OPGameSDK OPLOG:UploadFile Error = %@", dic);
                [self uploadFile];
            }else{
                NSString *status = [dic objectForKey:@"status"];
                NSString *reset = [dic objectForKey:@"reset"];
                NSString *imgUrl = [dic objectForKey:@"imgUrl"];
                
                if (status && reset && [status integerValue] == 0 && [reset integerValue] == 1000
                    && imgUrl) {
                    NSLog(@"OPGameSDK OPLOG:UploadFile Success=%@（%d）",self.p_GrayN_UploadFileName,p_GrayN_UploadFileRequestCount);
                    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    NSLog(@"uploadResult========%@", jsonString);
                    
                    NSMutableDictionary *resultDic = [[[NSMutableDictionary alloc] init] autorelease];
                    [resultDic setObject:status forKey:@"status"];
                    [resultDic setObject:dic forKey:@"data"];
                    [resultDic setObject:self.p_GrayN_UploadLocalUrl forKey:@"localurl"];
                    
                    [[GrayNcustomService_Control GrayNshare] GrayNcustomServiceNotifyUploadSuccessWithData:resultDic];
                }else{
                    NSLog(@"OPGameSDK OPLOG:UploadFile Error = %@", dic);
                    [self uploadFileNew];
                }
            }
        }else if ([data length] == 0 && connectionError == nil){
            NSLog(@"OPGameSDK OPLOG:UploadFile Error = Nothing was downloaded.");
            [self uploadFileNew];
        }else if (connectionError != nil){
            NSLog(@"OPGameSDK OPLOG:UploadFile Error = %@",connectionError);
            [self uploadFileNew];
        }
        
    }];
}

@end
