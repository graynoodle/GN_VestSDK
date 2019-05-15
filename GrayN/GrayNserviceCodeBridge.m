#import "GrayNserviceCodeBridge.h"

static NSString *p_GrayNcurSDKVersion;
static NSString *p_GrayNdeviceIDFA;
static NSString *p_GrayNloginIDFA;

@implementation GrayNserviceCodeBridge

+ (void)GrayNsetSDKVersion:(NSString*)GrayNsdkVersion
{
    p_GrayNcurSDKVersion = [GrayNsdkVersion copy];
}
+ (NSString*)GrayNgetSDKVerison
{
    return p_GrayNcurSDKVersion;
}
+ (void)GrayNsetDeviceIDFA:(NSString*)GrayNidfa
{
    p_GrayNdeviceIDFA = [GrayNidfa copy];
}
+ (NSString*)GrayNgetDeviceIDFA
{
    return p_GrayNdeviceIDFA;
}
+ (void)GrayNsetLoginIDFA:(NSString*)GrayNidfa
{
    p_GrayNloginIDFA = [GrayNidfa copy];
}
+ (NSString*)GrayNgetLoginIDFA
{
    return p_GrayNloginIDFA;
}
+ (bool)GrayNupdateServiceCode
{
    Class bridge = NSClassFromString(@"OPCommonKit");
    if (bridge) {
        SEL sel = NSSelectorFromString(@"getGameKitVerison");
        if([bridge respondsToSelector:sel]) {
            return false;
        }
        return true;
    }
    return false;
}

@end
