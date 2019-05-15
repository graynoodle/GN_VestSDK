//
//  GrayN_Hud.h
//  Login
//
//  Created by 韩征 on 14-3-10.
//  Copyright (c) 2014年 韩征. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GrayN_Hud : UIView
{
    UIActivityIndicatorView *p_GrayN_Hud_ActivityIndex;
    NSTimer *p_GrayN_Hud_Timer;
    BOOL p_GrayN_Hud_IsRunning;
    int p_GrayN_Hud_Long;
    int p_GrayN_Hud_Status;
}
@property (copy, nonatomic) NSString *m_GrayN_Hud_UserName;
@property (copy, nonatomic) void (^m_GrayN_Hud_Callback)();

- (void)GrayN_Hud_ShowWithTag:(int)tag;
- (void)GrayN_Hud_Close;
@end
