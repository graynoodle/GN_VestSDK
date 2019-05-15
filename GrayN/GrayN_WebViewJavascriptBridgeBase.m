//
//  GrayN_WebViewJavascriptBridgeBase.m
//
//  Created by @LokiMeyburg on 10/15/14.
//  Copyright (c) 2014 @LokiMeyburg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GrayN_WebViewJavascriptBridgeBase.h"
#import "GrayN_WebViewJavascriptBridge_JS.h"
#import "GrayN_WebViewController.h"
#import "GrayNbaseSDK.h"
@implementation GrayN_WebViewJavascriptBridgeBase
{
    id _webViewDelegate;
    long _uniqueId;
}

static bool logging = false;
static int logMaxLength = 500;

+ (void)GrayNenableLogging { logging = true; }
+ (void)GrayNsetLogMaxLength:(int)length { logMaxLength = length; }

-(id)init
{
    self = [super init];
    self.messageHandlers = [NSMutableDictionary dictionary];
    self.startupMessageQueue = [NSMutableArray array];
    self.responseCallbacks = [NSMutableDictionary dictionary];
    _uniqueId = 0;
    return(self);
}

- (void)dealloc
{
    self.startupMessageQueue = nil;
    self.responseCallbacks = nil;
    self.messageHandlers = nil;
    [super dealloc];
}

- (void)reset
{
    self.startupMessageQueue = [NSMutableArray array];
    self.responseCallbacks = [NSMutableDictionary dictionary];
    _uniqueId = 0;
}

- (void)sendData:(id)data responseCallback:(WVJBResponseCallback)responseCallback handlerName:(NSString*)handlerName
{
    NSMutableDictionary* message = [NSMutableDictionary dictionary];
    
    if (data) {
        message[@"data"] = data;
    }
    
    if (responseCallback) {
        NSString* callbackId = [NSString stringWithFormat:@"objc_cb_%ld", ++_uniqueId];
        self.responseCallbacks[callbackId] = [responseCallback copy];
        message[@"callbackId"] = callbackId;
    }
    
    if (handlerName) {
        message[@"handlerName"] = handlerName;
    }
    
    [self _queueMessage:message];
}

- (void)flushMessageQueue:(NSString *)messageQueueString
{
    if (messageQueueString == nil || messageQueueString.length == 0) {
        //NSLog(@"GrayN_WebViewJavascriptBridge: WARNING: ObjC got nil while fetching the message queue JSON from webview. This can happen if the GrayN_WebViewJavascriptBridge JS is not currently present in the webview, e.g if the webview just loaded a new page.");
        return;
    }
    
    id messages = [self _deserializeMessageJSON:messageQueueString];
    for (WVJBMessage* message in messages) {
        if (![message isKindOfClass:[WVJBMessage class]]) {
            //NSLog(@"GrayN_WebViewJavascriptBridge: WARNING: Invalid %@ received: %@", [message class], message);
            continue;
        }
        [self _log:@"RCVD" json:message];
        
        NSString* responseId = message[@"responseId"];
        if (responseId) {
            WVJBResponseCallback responseCallback = _responseCallbacks[responseId];
            responseCallback(message[@"responseData"]);
            [self.responseCallbacks removeObjectForKey:responseId];
        } else {
            WVJBResponseCallback responseCallback = NULL;
            NSString* callbackId = message[@"callbackId"];
            if (callbackId) {
                responseCallback = ^(id responseData) {
                    if (responseData == nil) {
                        responseData = [NSNull null];
                    }
                    
                    WVJBMessage* msg = @{ @"responseId":callbackId, @"responseData":responseData };
                    [self _queueMessage:msg];
                };
            } else {
                responseCallback = ^(id ignoreResponseData) {
                    // Do nothing
                };
            }
            
            WVJBHandler handler = self.messageHandlers[message[@"handlerName"]];
            
            if (!handler) {
                //NSLog(@"WVJBNoHandlerException, No handler for message from JS: %@", message);
                continue;
            }
            
            handler(message[@"data"], responseCallback);
        }
    }
}

- (void)injectJavascriptFile
{
    NSString *js = WebViewJavascriptBridge_js();
    
    //    NSString* jsPath = [[NSBundle mainBundle] pathForResource:@"WebViewJavascriptBridge" ofType:@"js"];
    //    NSString* js = [NSString stringWithContentsOfFile:jsPath encoding:NSUTF8StringEncoding error:nil];
    //    //NSLog(@"%@",js);
    [self _evaluateJavascript:js];
    if (self.startupMessageQueue) {
        NSArray* queue = [[[NSArray alloc] initWithArray:self.startupMessageQueue] autorelease];
        self.startupMessageQueue = nil;
        for (id queuedMessage in queue) {
            [self _dispatchMessage:queuedMessage];
        }
    }
    //NSLog(@"WebViewJavascriptBridge.js Load finish");
    [[GrayN_WebViewController GrayN_Share] GrayN_WVC_InitJSBridge];
}

- (BOOL)isCorrectProcotocolScheme:(NSURL*)url
{
    if([[url scheme] isEqualToString:kCustomProtocolScheme]){
        return YES;
    } else if ([[url scheme] isEqualToString:kOPCustomProtocolScheme]) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)isQueueMessageURL:(NSURL*)url
{
    if([[url host] isEqualToString:kQueueHasMessage])
    {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)isBridgeLoadedURL:(NSURL*)url
{
    return ([[url scheme] isEqualToString:kCustomProtocolScheme] && [[url host] isEqualToString:kBridgeLoaded]) ||
    ([[url scheme] isEqualToString:kOPCustomProtocolScheme] && [[url host] isEqualToString:kBridgeLoaded]);
}

- (void)logUnkownMessage:(NSURL*)url
{
    //NSLog(@"WebViewJavascriptBridge: WARNING: Received unknown WebViewJavascriptBridge command %@://%@", kCustomProtocolScheme, [url path]);
}

- (NSString *)webViewJavascriptCheckCommand
{
    return @"typeof WebViewJavascriptBridge == \'object\';";
}

- (NSString *)webViewJavascriptFetchQueyCommand
{
    return @"WebViewJavascriptBridge._fetchQueue();";
}

// Private
// -------------------------------------------
- (void) _evaluateJavascript:(NSString *)javascriptCommand
{
    [self.delegate _evaluateJavascript:javascriptCommand];
}

- (void)_queueMessage:(WVJBMessage*)message
{
    if (self.startupMessageQueue) {
        [self.startupMessageQueue addObject:message];
    } else {
        [self _dispatchMessage:message];
    }
}

- (void)_dispatchMessage:(WVJBMessage*)message
{
    NSString *messageJSON = [self _serializeMessage:message pretty:NO];
    [self _log:@"SEND" json:messageJSON];
//    NSLog(@"messageJSON=%@", messageJSON);

//    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
//    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
//    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\'" withString:@"\\\'"];
//    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
//    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\r" withString:@"\\r"];
//    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\f" withString:@"\\f"];
//    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\u2028" withString:@"\\u2028"];
//    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\u2029" withString:@"\\u2029"];
//    NSLog(@"messageJSON=%@", messageJSON);
    
    messageJSON = [GrayNbaseSDK GrayNencodeBase64:messageJSON];

    NSString* javascriptCommand = [NSString stringWithFormat:@"WebViewJavascriptBridge._handleMessageFromObjC('%@');", messageJSON];
    

    if ([[NSThread currentThread] isMainThread]) {
        [self _evaluateJavascript:javascriptCommand];
        
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self _evaluateJavascript:javascriptCommand];
        });
    }
}

- (NSString *)_serializeMessage:(id)message pretty:(BOOL)pretty
{
    return [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:message options:(NSJSONWritingOptions)(pretty ? NSJSONWritingPrettyPrinted : 0) error:nil] encoding:NSUTF8StringEncoding];
}

- (NSArray*)_deserializeMessageJSON:(NSString *)messageJSON
{
    NSString *decodestr = messageJSON;
    decodestr = [GrayNbaseSDK GrayNdecodeBase64:decodestr];
//    NSLog(@"decodestr=%@", decodestr);
    return [NSJSONSerialization JSONObjectWithData:[decodestr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
}

- (void)_log:(NSString *)action json:(id)json
{
    if (!logging) { return; }
    if (![json isKindOfClass:[NSString class]]) {
        json = [self _serializeMessage:json pretty:YES];
    }
    if ([json length] > logMaxLength) {
        //NSLog(@"WVJB %@: %@ [...]", action, [json substringToIndex:logMaxLength]);
    } else {
        //NSLog(@"WVJB %@: %@", action, json);
    }
}

@end
