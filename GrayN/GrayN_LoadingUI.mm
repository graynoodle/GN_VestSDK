//
//  GrayN_LoadingUI.cpp
//
//  Created by gamebean on 13-1-18.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <iostream>

#import <UIKit/UIKit.h>

#import "GrayNcommon_oc.h"
#import "GrayNlogCenter.h"
#import "GrayN_LoadingUI.h"
#import "GrayN_BaseControl.h"
#import "GrayN_ProgressHud.h"
#import "GrayNSDK.h"

using namespace std;
GrayNusing_NameSpace;

float uiscaler = 0.5;
@interface GrayN_LoadingController : UIView<UIAlertViewDelegate>
{
    NSInteger m_GrayN_MsgTag;
}
- (void)GrayNshowUI:(UIView*)view :(UIView*)toshow;
- (void)GrayNcancelUI:(UIView*)view;
- (void)GrayNcancelAll;

- (void)GrayNsetMsgTag:(NSInteger)tag;
- (void)GrayNalertView:(UIAlertView *)GrayNalertView clickedButtonAtIndex:(NSInteger)buttonIndex;


@property(assign) NSInteger m_GrayN_MsgTag;
@end

@implementation GrayN_LoadingController

@synthesize m_GrayN_MsgTag;

-(id)init
{
    self = [super init];
    
    NSString* deviceName=[[UIDevice currentDevice] model];
    if([deviceName hasPrefix:@"iPad"]) {
        uiscaler=1;
    } else if([deviceName hasPrefix:@"iPhone"]) {
        uiscaler=0.5;
    } else if([deviceName hasPrefix:@"iPod"]) {
        uiscaler=0.5;
    }
    return self;
}

- (void)GrayNshowUI:(UIView *)v :(UIView*)toshow
{
    [v addSubview:toshow];
}

- (void)GrayNcancelUI:(UIView *)view
{
    //    self.view=nil;
}

- (void)GrayNcancelAll
{
    
}

- (void)viewDidLoad
{
    //	[UIApplication sharedApplication].statusBarHidden = YES;
    
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

#pragma mark -
- (void)GrayNsetMsgTag:(NSInteger)tag
{
    self.m_GrayN_MsgTag = tag;
}

- (void)GrayNalertView:(UIAlertView *)GrayNalertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0) {
        [self cancelPressed:(int)m_GrayN_MsgTag];
    } else if(buttonIndex == 1) {
        [self okPressed:(int)m_GrayN_MsgTag];
    }
}

- (void)okPressed:(int)nTag
{
    if (nTag == 100) {
        
    }
}

- (void)cancelPressed:(int)nTag
{
    if (nTag == 100) {
        
        NSArray *subviews = ((UIView*)GrayN_LoadingUI::GetInstance().p_GrayN_GameView).subviews;
        for(int i  = 0; i < [subviews count]; i ++){
            UIView* v = [subviews objectAtIndex:i];
            if(v != nil){
                [v removeFromSuperview];
            }
        }
    }
    if (nTag == 9999) {
        //退出程序
        GrayNlogCenter::GetInstance().m_GrayN_LogIsQuitGame = true;
        abort();
    }
}
@end

GrayN_NameSpace_Start
GrayN_LoadingUI::GrayN_LoadingUI()
{
    dispatch_async(dispatch_get_main_queue(), ^{
        p_GrayN_LoadingInstance = [[GrayN_LoadingController alloc] init];
        p_GrayN_LoadingEnabled = false;
        
    });
    
}

GrayN_LoadingUI::~GrayN_LoadingUI()
{
    [p_GrayN_LoadingInstance release];
    [(UIView*)p_GrayN_LoadingView release];
}

bool p_GrayN_Showing = false;
bool p_GrayN_GameShowing = false;

void GrayN_LoadingUI::GrayN_SetUserInteractionEnabled(bool enable)
{
    UIViewController *uvc = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    if(uvc == nil){
        cout<<"未设置rootController！"<<endl;
        return;
    }
    
    if (uvc.view == nil) {
        cout<<"rootController的view设置有问题！"<<endl;
        return;
    }
    if (enable) {
        [uvc.view setUserInteractionEnabled:YES];
    }else{
        [uvc.view setUserInteractionEnabled:NO];
    }
}

void GrayN_LoadingUI::GrayN_SetLoaingUIEnabled(bool enable)
{
    p_GrayN_LoadingEnabled = enable;
}
void GrayN_LoadingUI::GrayN_ShowWaitMainThread(const char* tip)
{
    GrayNcommon::GrayN_ConsoleLog("OPShowWaitMainThread");

    string msg = tip;
    dispatch_async(dispatch_get_main_queue(), ^{
        GrayN_ShowWait(msg.c_str());
    });
}
void GrayN_LoadingUI::GrayN_ShowWait(const char *tip)
{
    if(!p_GrayN_Showing) {
        //        if (!GrayNcommon::m_GrayN_ShowLoading) {
        //            return;
        //        }
        p_GrayN_Showing = true;
        
        UIViewController *uvc = [UIApplication sharedApplication].keyWindow.rootViewController;
        
        if(uvc == nil){
            string msg = tip;
            if (msg == "") {
                return;
            }
            cout<<"未设置rootController！"<<endl;
            return;
        }
        
        if (uvc.view == nil) {
            cout<<"rootController的view设置有问题！"<<endl;
            return;
        }
        
        if (p_GrayN_LoadingView == nil) {
            //tmpView是为了避免与Cocos2dx中的opengl发生冲突
            CGRect rect = [GrayNcommon_oc screen_GrayN_Rect];
            
            UIInterfaceOrientation ori = [UIApplication sharedApplication].statusBarOrientation;
            if (ori == UIInterfaceOrientationLandscapeLeft || ori == UIInterfaceOrientationLandscapeRight) {
                // 横屏
                p_GrayN_LoadingView = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, rect.size.height, rect.size.width)];
            } else {
                p_GrayN_LoadingView = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
            }
            
            [(UIView*)p_GrayN_LoadingView setBackgroundColor:[UIColor clearColor]];
            //[uvc.view addSubview:(UIView*)p_GrayN_LoadingView];
        }
        
        //此处这样处理是因为两个window，需要把tmp都要加在对应的uvc，这样才能显示出loading
        [(UIView*)p_GrayN_LoadingView removeFromSuperview];
        [uvc.view addSubview:(UIView*)p_GrayN_LoadingView];
        
        [uvc.view bringSubviewToFront:(UIView*)p_GrayN_LoadingView];        //非常重要
        [(UIView*)p_GrayN_LoadingView setHidden:NO];
        
        p_GrayN_GameViewController = uvc;
        
        GrayN_ProgressHud_oc* hud = [GrayN_ProgressHud_oc GrayN_ShowProgressHudAddedTo:(UIView*)p_GrayN_LoadingView animated:NO];
        hud.tag = 1000;
        
        if (p_GrayN_LoadingEnabled) {
            //[uvc.view setUserInteractionEnabled:YES];
            [(UIView*)p_GrayN_LoadingView setUserInteractionEnabled:NO];
        } else {
            //[uvc.view setUserInteractionEnabled:NO];
            [(UIView*)p_GrayN_LoadingView setUserInteractionEnabled:YES];
        }
        
        p_GrayN_GameView = uvc.view;
        
        if(tip!=NULL)
        {
            hud.m_GrayNlabelText = [NSString stringWithUTF8String:tip];
        }
        if (!GrayNcommon::m_GrayN_ShowLoading || [hud.m_GrayNlabelText isEqualToString:@""]) {
            hud.hidden = YES;
        }
    }
}
void GrayN_LoadingUI::GrayN_CloseWaitMainThread()
{
    dispatch_async(dispatch_get_main_queue(), ^{
        GrayN_CloseWait();
    });
}
void GrayN_LoadingUI::GrayN_ChangeWait(const char* tip)
{
    if (tip) {
        GrayN_ProgressHud_oc* hud = (GrayN_ProgressHud_oc*)[((UIView*)p_GrayN_LoadingView) viewWithTag:1000];
        hud.m_GrayNlabelText = [NSString stringWithUTF8String:tip];
        //            GrayN_ProgressHud_oc* hud = [GrayN_ProgressHud_oc GrayN_ShowProgressHudAddedTo:(UIView*)p_GrayN_LoadingView animated:NO];
        //            hud.labelText = [NSString stringWithUTF8String:tip];
    }
}

void GrayN_LoadingUI::GrayN_CloseWait()
{
    dispatch_async(dispatch_get_main_queue(), ^{
        GrayNcommon::GrayN_ConsoleLog("OPCloseWait");
        if(!p_GrayN_Showing){
            return;
        }
        UIViewController *uvc = [UIApplication sharedApplication].keyWindow.rootViewController;
        
        if (uvc == nil){
            cout<<"未设置rootController！"<<endl;
            return;
        }
        
        if (uvc.view == nil) {
            cout<<"rootController的view设置有问题！"<<endl;
            return;
        }
        
        [((UIView*) p_GrayN_LoadingView) setHidden:YES];
        
        [GrayN_ProgressHud_oc GrayN_HideProgressHudForView:(UIView*)p_GrayN_LoadingView animated:NO];
        p_GrayN_Showing=false;
        
        [((UIView*) p_GrayN_LoadingView) setUserInteractionEnabled:YES];
        //[uvc.view setUserInteractionEnabled:YES];
    });
    
}

void GrayN_LoadingUI::GrayN_ShowMsgBox(const char* title, const char* body, int tag, int btnCnt)
{
    NSString* tl = [NSString stringWithUTF8String:title];
    NSString* bd = [NSString stringWithUTF8String:body];
    NSString* sure = [NSString stringWithUTF8String:GrayNcommon::GrayNcommonGetLocalLang(GrayN_Sure)];
    [p_GrayN_LoadingInstance GrayNsetMsgTag:tag];
    if (btnCnt == 1) {
        UIAlertView*alert = [[UIAlertView alloc] initWithTitle:tl
                                                       message:bd
                                                      delegate:p_GrayN_LoadingInstance
                                             cancelButtonTitle:nil
                                             otherButtonTitles:sure,nil];
        [alert show];
        [alert release];
    } else {
        NSString* cancel = [NSString stringWithUTF8String:GrayNcommon::GrayNcommonGetLocalLang(GrayN_CANCEL)];
        UIAlertView*alert = [[UIAlertView alloc] initWithTitle:tl
                                                       message:bd
                                                      delegate:p_GrayN_LoadingInstance
                                             cancelButtonTitle:cancel
                                             otherButtonTitles:sure,nil];
        [alert show];
        [alert release];
    }
}

void GrayN_LoadingUI::GrayN_ShowGameWait(const char *tip)
{
    if(!p_GrayN_GameShowing)
    {
        p_GrayN_GameShowing=true;
        
        UIViewController *uvc = (UIViewController*)GrayNcommon::m_GrayN_RootViewController;
        if(uvc == nil){
            cout<<"游戏未设置rootController！"<<endl;
            return;
        }
        
        if (uvc.view == nil) {
            cout<<"游戏rootController的view设置有问题！"<<endl;
            return;
        }
        
        if (p_GrayN_GameLoadingView == nil) {
            //tmpView是为了避免与Cocos2dx中的opengl发生冲突
            CGRect rect = [GrayNcommon_oc screen_GrayN_Rect];
            
            UIInterfaceOrientation ori = [UIApplication sharedApplication].statusBarOrientation;
            if (ori == UIInterfaceOrientationLandscapeLeft || ori == UIInterfaceOrientationLandscapeRight) {
                // 横屏
                p_GrayN_GameLoadingView = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, rect.size.height, rect.size.width)];
            } else {
                p_GrayN_GameLoadingView = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
            }
            
            [(UIView*)p_GrayN_GameLoadingView setBackgroundColor:[UIColor clearColor]];
            //[uvc.view addSubview:(UIView*)p_GrayN_LoadingView];
        }
        
        //此处这样处理是因为两个window，需要把tmp都要加在对应的uvc，这样才能显示出loading
        [(UIView*)p_GrayN_GameLoadingView removeFromSuperview];
        [uvc.view addSubview:(UIView*)p_GrayN_GameLoadingView];
        
        [uvc.view bringSubviewToFront:(UIView*)p_GrayN_GameLoadingView];        //非常重要
        [(UIView*)p_GrayN_GameLoadingView setHidden:NO];
        
        p_GrayN_GameViewController = uvc;
        
        GrayN_ProgressHud_oc* hud = [GrayN_ProgressHud_oc GrayN_ShowProgressHudAddedTo:(UIView*)p_GrayN_GameLoadingView animated:NO];
        
        [uvc.view setUserInteractionEnabled:NO];
        
        if(tip!=NULL)
        {
            hud.m_GrayNlabelText = [NSString stringWithUTF8String:tip];
        }
    }
}

void GrayN_LoadingUI::GrayN_CloseGameWait()
{
    if(!p_GrayN_GameShowing){
        return;
    }
    
    UIViewController *uvc = (UIViewController*)GrayNcommon::m_GrayN_RootViewController;
    
    if(uvc == nil){
        cout<<"游戏未设置rootController！"<<endl;
        return;
    }
    
    if (uvc.view == nil) {
        cout<<"游戏rootController的view设置有问题！"<<endl;
        return;
    }
    
    [((UIView*) p_GrayN_GameLoadingView) setHidden:YES];
    
    [GrayN_ProgressHud_oc GrayN_HideProgressHudForView:(UIView*)p_GrayN_GameLoadingView animated:NO];
    p_GrayN_GameShowing=false;
    
    [uvc.view setUserInteractionEnabled:YES];
}

void GrayN_LoadingUI::GrayN_ResetKeyWindow()
{
    UIWindow *curKeyWindow = [UIApplication sharedApplication].keyWindow;
    UIWindow *gameWindow = [[GrayN_BaseControl GrayN_Share] GrayN_GetGame_Window];
    if (curKeyWindow != gameWindow) {
        NSLog(@"OPGameSDK OPLOG:reset key window!");
        [gameWindow makeKeyAndVisible];
    }
}

GrayN_NameSpace_End

