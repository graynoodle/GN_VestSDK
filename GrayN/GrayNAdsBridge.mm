#import "GrayNAdsBridge.h"
#import <Foundation/Foundation.h>

GrayNusing_NameSpace;
#define Class_OPAdsSDK @"OPAdsSDK"
#define API_OPAdsSDKCheckInit @"checkInit"
#define API_OPAdsSDKSendLogByDictionary @"sendLogByDictionary:"

@interface AdsBridge : NSObject
{
    id _OPAdsBridge;
}

- (void)checkInit;

@end

static AdsBridge *_shareInstance = nil;
@implementation AdsBridge

- (void)dealloc
{
    [super dealloc];
}
+ (id)shareInstance
{
    if (_shareInstance == nil) {
        _shareInstance = [[AdsBridge alloc] init];
    }
    return _shareInstance;
}
- (id)init
{
    self = [super init];
    if (self) {
        _OPAdsBridge = [NSClassFromString(Class_OPAdsSDK) shareInstance];
    }
    return self;
}

- (void)checkInit
{
    if (_OPAdsBridge) {
        SEL sel = NSSelectorFromString(API_OPAdsSDKCheckInit);
        if([_OPAdsBridge respondsToSelector:sel]) {
            [_OPAdsBridge performSelector:sel withObject:nil];
        } else {
            NSLog(@"OPGameSDK:未添加OPAdsSDK.a");
        }
    }
}

- (void)logEventByKey:(const char *)ourpalm_event_key andValue:(const char *)event_paras
{
    if (_OPAdsBridge) {
        SEL sel = NSSelectorFromString(API_OPAdsSDKSendLogByDictionary);
        if([_OPAdsBridge respondsToSelector:sel]) {
            NSString *opEventKey = [[[NSString alloc] initWithUTF8String:ourpalm_event_key] autorelease];
            NSString *opEventParas = [[[NSString alloc] initWithUTF8String:event_paras] autorelease];

            NSDictionary *dic = [[[NSDictionary alloc] initWithObjectsAndKeys:
                                  opEventKey, @"eventKey",
                                  opEventParas, @"eventParas", nil] autorelease];
            [_OPAdsBridge performSelector:sel withObject:dic];
        } else {
            NSLog(@"OPGameSDK:未添加OPAdsSDK.a");
        }
    }
    
}
@end

namespace ourpalmpay
{
    OPAdsBridge::OPAdsBridge()
    {
        [AdsBridge shareInstance];
    }
    
    OPAdsBridge::~OPAdsBridge()
    {
    }
    
    void OPAdsBridge::logEvent(const char* ourpalm_event_key, const char* event_paras)
    {
        [[AdsBridge shareInstance] logEventByKey:ourpalm_event_key andValue:event_paras];
    }
    
    void OPAdsBridge::checkInit()
    {
        [[AdsBridge shareInstance] checkInit];
    }
}

