
#import "GrayNasyn_CallBack.h"
#import <UIKit/UIKit.h>
@interface GrayNasyn_CallBack_oc : NSObject
{
    GrayNasyn_CallBack_Function GrayNmCallBack_Function;
    void* GrayNmArgs;
}
- (void)GrayNasyn_CallBack_oc;
- (void)GrayNstartAsyn_CallBack_oc:(GrayNasyn_CallBack_Function)GrayNfun Arg:(void*)GrayNarg;
@end


@implementation GrayNasyn_CallBack_oc

- (void)GrayNasyn_CallBack_oc
{
    GrayNmCallBack_Function(GrayNmArgs);
}
- (void)GrayNstartAsyn_CallBack_oc:(GrayNasyn_CallBack_Function)GrayNfun Arg:(void*)GrayNarg
{
    GrayNmCallBack_Function = GrayNfun;
    GrayNmArgs = GrayNarg;
    [self performSelectorOnMainThread:@selector(GrayNasyn_CallBack_oc) withObject:nil waitUntilDone:NO];
}
@end


GrayN_NameSpace_Start
GrayNasyn_CallBack::GrayNasyn_CallBack()
{
    GrayNasyn_CallBackInstance = [[GrayNasyn_CallBack_oc alloc] init];
}

GrayNasyn_CallBack::~GrayNasyn_CallBack()
{
    [(id)GrayNasyn_CallBackInstance release];
}

void GrayNasyn_CallBack::GrayNstartAsyn_CallBack(GrayNasyn_CallBack_Function GrayNfunction, void* GrayNargs)
{
    [((id)GrayNasyn_CallBackInstance) GrayNstartAsyn_CallBack_oc:GrayNfunction Arg:GrayNargs];
}

GrayN_NameSpace_End
