//
//  GrayN_Https_GrayN.cpp
//
//  Created by JackYin on 29/3/16.
//  Copyright © 2016年 op-mac1. All rights reserved.
//
#ifdef OPLogSDK_BaseTools
#else
#import "GrayN_Https_GrayN.h"

#import "GrayNcommon.h"
#import "GrayN_UrlEncode_GrayN.h"

#import <Foundation/Foundation.h>
#import "GrayN_AFHTTPRequestOperationManager.h"

GrayNusing_NameSpace;

static dispatch_queue_t reqDeleteQueue = dispatch_queue_create("reqDeleteQueue", NULL);
static dispatch_queue_t reqQueue = dispatch_queue_create("reqQueue", NULL);
string GrayN_Https_GrayN::m_GrayN_HeadDate = "";

@interface OPOCHttps : NSObject

@property (nonatomic,retain) GrayN_AFHTTPRequestOperationManager *manager;
@property (nonatomic,copy) NSString *responseData;

//+(id) shareInstance;

@end

@implementation OPOCHttps

@synthesize manager;
@synthesize responseData;

- (id)init
{
    self = [super init];
    if (self) {
        self.manager = [GrayN_AFHTTPRequestOperationManager manager];
#ifdef DEBUG
        //self.manager.securityPolicy.allowInvalidCertificates = YES;  //如果不验证证书安全charles可以看到内部数据
#endif
        self.manager.responseSerializer = [GrayN_AFHTTPResponseSerializer serializer];
        self.manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
        
        //        self.manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [self.manager.requestSerializer setTimeoutInterval:30];
        self.manager.completionQueue = reqQueue;
        
    }
    return self;
}

- (void)dealloc
{
    [manager release];
    [responseData release];
    [super dealloc];
}

@end

int GrayN_Https_GrayN::p_GrayN_CurrentRequestId = 0;

GrayN_Https_GrayN::GrayN_Https_GrayN()
{
    p_GrayN_AFNetworking = [[OPOCHttps alloc] init];
    p_GrayN_RequestId = 0;
}

GrayN_Https_GrayN::~GrayN_Https_GrayN()
{
    if (p_GrayN_AFNetworking != nil) {
        [p_GrayN_AFNetworking release];
        p_GrayN_AFNetworking = nil;
    }
}

void GrayN_Https_GrayN::GrayN_Https_Post(string url, string body)
{
    
    NSURL *urlStr = [NSURL URLWithString:[NSString stringWithUTF8String:url.c_str()]];
    NSMutableURLRequest *request =
    [[NSMutableURLRequest alloc] initWithURL:urlStr];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Contsetent-Type"];
    [request setAllHTTPHeaderFields:(NSDictionary *)GrayNcommon::GrayNgetHttpsHeader()];

    if (body.c_str() == nil) {
        body = "";
    }
    NSData *postBody = [[[NSString stringWithUTF8String:body.c_str()] dataUsingEncoding:NSUTF8StringEncoding] retain];

    [request setHTTPBody:postBody];
    
    p_GrayN_SelfObject = this;
    GrayN_AFHTTPRequestOperationManager *manager = [p_GrayN_AFNetworking manager];
    [manager.requestSerializer setHTTPHeaderByDictionary:(NSDictionary *)GrayNcommon::GrayNgetHttpsHeader()];
    
//    GrayNcommon::GrayN_DebugLog(@"**********urlStr=%@",urlStr);
    GrayNcommon::GrayN_DebugLog(@"opHttpsHeader\n%@",manager.requestSerializer.HTTPRequestHeaders);
    [urlStr release];
//    GrayNcommon::GrayN_DebugLog(@"postBody=%@",postBody);
    [postBody release];

    NSOperation *operation =
    [manager HTTPRequestOperationWithRequest:request
                                     success:^(GrayN_AFHTTPRequestOperation *operation, id responseObject) {
                                         // 成功后的处理
                                         if (p_GrayN_RequestId != 0 && p_GrayN_RequestId != p_GrayN_CurrentRequestId) {
                                             dispatch_async(reqDeleteQueue, ^{
                                                 GrayNcommon::GrayN_DebugLog(@"取消任务mRequestId=%d",p_GrayN_RequestId);
                                                 usleep(1000);
                                                 if (p_GrayN_SelfObject) {
                                                     delete p_GrayN_SelfObject;
                                                     p_GrayN_SelfObject = NULL;
                                                 }
                                             });
                                             return;
                                         }
//                                         GrayNcommon::GrayN_DebugLog(@"完成任务mRequestId=%d,isMainThread=%hhd",p_GrayN_RequestId,[NSThread isMainThread]);
                                         p_GrayN_HttpCode = (int)operation.response.statusCode;
#ifdef HTTPHEADER
                                         NSDictionary *respHeaderDic = operation.response.allHeaderFields;
                                         NSString *date = [respHeaderDic objectForKey:@"Date"];
                                         if (date) {
                                             m_GrayN_HeadDate = [date UTF8String];
                                         }
                                         //#ifdef DEBUG
                                         //        NSLog(@"ResponseHeader=%@",operation.response.allHeaderFields);
                                         //#endif
#endif
                                         NSString *result = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//                                         NSLog(@"%@", result);
                                         if (result) {
                                             string desData = [result UTF8String];
                                             [result release];
                                             p_GrayN_HttpsListener->GrayN_On_Http_Data(NULL, desData.c_str(), (int)desData.length());
                                             p_GrayN_HttpsListener->GrayN_On_HttpEvent(NULL, GrayN_Http_GrayN::GrayN_HttpListener::k_GrayN_COMPLETE);
                                         } else {
                                             p_GrayN_HttpsListener->GrayN_On_HttpError(NULL, GrayN_Http_GrayN::GrayN_HttpListener::k_GrayN_OPEN_ERROR);
                                         }
                                         
                                     }
                                     failure:^(GrayN_AFHTTPRequestOperation *operation, NSError *error) {
                                         // 失败后的处理
                                         if (p_GrayN_RequestId != 0 && p_GrayN_RequestId != p_GrayN_CurrentRequestId) {
                                             dispatch_async(reqDeleteQueue, ^{
                                                 if (p_GrayN_SelfObject) {
                                                     delete p_GrayN_SelfObject;
                                                     p_GrayN_SelfObject = NULL;
                                                 }
                                                 usleep(1000);
                                             });
                                             return;
                                         }
                                         GrayNcommon::GrayN_ConsoleLog(@"%@", error);
                                         p_GrayN_HttpCode = (int)operation.response.statusCode;
                                         if (error) {
                                             if (error.localizedDescription) {
                                                 p_GrayN_SocketError.clear();
                                                 string desc = [error.localizedDescription UTF8String];
                                                 GrayN_UrlEncode_GrayN::GrayN_Url_Encode(desc, p_GrayN_SocketError);
                                             }
                                         }
                                         
                                         p_GrayN_HttpsListener->GrayN_On_HttpError(NULL, GrayN_Http_GrayN::GrayN_HttpListener::k_GrayN_OPEN_ERROR);
                                     }];
    [manager.operationQueue addOperation:operation];
//    [postBody release];
}
const char* GrayN_Https_GrayN::GrayN_Http_Get_SocketError()
{
    return p_GrayN_SocketError.c_str();
}

int GrayN_Https_GrayN::GrayN_Http_Get_HttpCode()
{
    return p_GrayN_HttpCode;
}

void GrayN_Https_GrayN::GrayN_Thread_OpenSwitch()
{
    //无用
}
void GrayN_Https_GrayN::GrayNstop()
{
    //无用
}
#endif
