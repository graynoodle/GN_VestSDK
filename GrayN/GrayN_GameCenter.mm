
#import "GrayN_GameCenter.h"
#import <GameKit/GameKit.h>
#import "GrayN_LoadingUI.h"
#import "GrayNconfig.h"
#import "GrayNcommon.h"
#import "GrayN_BaseControl.h"
#import "GrayN_UserCenter.h"

GrayNusing_NameSpace;

static GrayN_GameCenter *p_GrayN_GC_share;

@interface GrayN_GameCenter ()<UIAlertViewDelegate>
{
    NSMutableDictionary *p_GrayN_GC_Dic;
    bool p_GrayN_GC_InitStatus;
}

@end

@implementation GrayN_GameCenter

@synthesize m_GrayN_GC_LoginHandler;

+ (id)GrayN_share
{
    @synchronized ([GrayN_GameCenter class]) {
        if (p_GrayN_GC_share == nil) {
            p_GrayN_GC_share = [[GrayN_GameCenter alloc] init];
        }
    }
    return p_GrayN_GC_share;
}

- (void)GrayN_GC_LoginWithHandler:(GrayN_GCLoginHandler)handler
{
    GrayN_LoadingUI::GetInstance().GrayN_ShowWaitMainThread(GrayNcommon::GrayNcommonGetLocalLang(GrayN_WaitingString));

    self.m_GrayN_GC_LoginHandler = handler;
    [self GrayNauthenticateLocalPlayer];
}

- (void)GrayNauthenticateLocalPlayer
{
    GKLocalPlayer *player = [GKLocalPlayer localPlayer];
    if (p_GrayN_GC_InitStatus) {
        if (player.isAuthenticated) {
            GrayNcommon::GrayN_DebugLog(@"player.isAuthenticated");
            [self GrayNcheckLocalPlayer:nil];
            return;
        } else {
            GrayNcommon::GrayN_DebugLog(@"player.isNotAuthenticated");
            GrayN_LoadingUI::GetInstance().GrayN_CloseWaitMainThread();
                        
            bool result = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"gamecenter:"]];
            if (!result) {
                NSString *message = [NSString stringWithUTF8String:GrayNcommon::GrayNcommonGetLocalLang(GrayN_OPGC_Alert)];
                NSString *sure = [NSString stringWithUTF8String:GrayNcommon::GrayNcommonGetLocalLang(GrayN_Sure)];
                UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:nil
                                                                     message:message //@"即将为您跳转到\“设置\”-\“GameCenter\”"
                                                                    delegate:self
                                                           cancelButtonTitle:sure   //确定
                                                           otherButtonTitles:nil] autorelease];
                [alertView show];
            }
        }
        return;
    }
    // ios 6.0 and above 此方法只能调用一次，并且每次前后台切换都会有回调
    [player setAuthenticateHandler:(^(UIViewController* viewcontroller, NSError *error) {
        GrayNcommon::GrayN_DebugLog(@"GC viewcontroller=%@,error=%@",viewcontroller,error);

        if (!error && viewcontroller) {
            if (!p_GrayN_GC_InitStatus) {
                GrayNcommon::GrayN_DebugLog(@"GC p_GrayN_GC_InitStatus=false");
                UIWindow *opWindow = [[GrayN_BaseControl GrayN_Share] GrayN_GetSDK_Window];
                [opWindow.rootViewController presentViewController:viewcontroller animated:YES completion:nil];
            } else {
                GrayNcommon::GrayN_DebugLog(@"GC p_GrayN_GC_InitStatus=true");
                [self GrayNcheckLocalPlayer:nil];
            }
        } else {
            GrayNcommon::GrayN_DebugLog(@"GC (!error && viewcontroller) = false");
            [self GrayNcheckLocalPlayer:error];
        }
        p_GrayN_GC_InitStatus = true;
        GrayN_LoadingUI::GetInstance().GrayN_CloseWaitMainThread();

    })];
    
}
- (void)GrayN_GC_CallbackUserName:(NSString *)userName CUT:(NSString *)currentUserType status:(bool)status
{
    if (!status) {
        //GameCenter登录失败
        [p_GrayN_GC_Dic setObject:@"GameCenter Login Failed" forKey:@"desc"];
        self.m_GrayN_GC_LoginHandler(GrayN_GCLogin_Fail, p_GrayN_GC_Dic);
    } else {
        [p_GrayN_GC_Dic setObject:currentUserType forKey:@"currentUserType"];
        [p_GrayN_GC_Dic setObject:userName forKey:@"userName"];
        
        self.m_GrayN_GC_LoginHandler(GrayN_GCLogin_Success, p_GrayN_GC_Dic);
    }
    
    [p_GrayN_GC_Dic release];
    self.m_GrayN_GC_LoginHandler = nil;
}
- (void)GrayNcheckLocalPlayer:(NSError*) error
{
    GKLocalPlayer *player = [GKLocalPlayer localPlayer];
    
    if (player.isAuthenticated) {
        /* Perform additional tasks for the authenticated player here */
        GrayNcommon::GrayN_DebugLog(@"GC 成功player.alias=%@,player.playerID=%@,player.displayName=%@",player.alias,player.playerID,player.displayName);


        NSString* alias = [GKLocalPlayer localPlayer].alias;
        NSString* playerID = [GKLocalPlayer localPlayer].playerID;
        
        if (m_GrayN_GC_LoginHandler == nil) {
            GrayNcommon::GrayN_DebugLog(@"gamecenter login...");
            return;
        }
        p_GrayN_GC_Dic = [[NSMutableDictionary alloc] init];
        if (alias) {
            [p_GrayN_GC_Dic setObject:alias forKey:@"alias"];
        }else{
            //有些设备即使用户设置了昵称也可能会出现这种情况，用户还原设备就可以解决
            [p_GrayN_GC_Dic setObject:@"" forKey:@"alias"];
        }
        [p_GrayN_GC_Dic setObject:playerID forKey:@"playerID"];
        [p_GrayN_GC_Dic setObject:@"0" forKey:@"status"];
        [p_GrayN_GC_Dic setObject:@"1" forKey:@"reset"];
        
        GrayN_UserCenter::GetInstance().GrayN_UserCenter_GCLoginVerify_GrayN([playerID UTF8String], [alias UTF8String]);
        
        
    } else {
        /* Perform additional tasks for the non-authenticated player here */
        GrayNcommon::GrayN_DebugLog(@"gamecenter login fail  %@",error);
        if (m_GrayN_GC_LoginHandler == nil) {
            return;
        }
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:@"1" forKey:@"status"];
        [dic setObject:@"0" forKey:@"reset"];
        if (error) {
            if (error.code == 2) {
                //用户已取消或停用所请求的操作。
                [dic setObject:@"The requested operation has been cancelled." forKey:@"desc"];
                self.m_GrayN_GC_LoginHandler(GrayN_GCLogin_Cancel,dic);
            } else {
                NSString *desc = [NSString stringWithFormat:@"GameCenter Login Failed!(%ld)",(long)error.code];
                [dic setObject:desc forKey:@"desc"];
                self.m_GrayN_GC_LoginHandler(GrayN_GCLogin_Fail,dic);

            }
        }else{
            //GameCenter登录失败
            [dic setObject:@"GameCenter Login Failed" forKey:@"desc"];
            self.m_GrayN_GC_LoginHandler(GrayN_GCLogin_Fail,dic);

        }
        
        [dic release];
        self.m_GrayN_GC_LoginHandler = nil;
    }
}


@end
