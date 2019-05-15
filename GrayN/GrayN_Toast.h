//
//  OPBaseToastHud.h
//  Login
//
//  Created by 韩征 on 14-3-7.
//  Copyright (c) 2014年 韩征. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GrayN_Toast : UIView

{
    NSTimer *p_GrayN_Toast_Timer;
}

@property (retain, nonatomic) UILabel *m_GrayN_Toast_Label;
@property (assign, nonatomic) BOOL m_GrayN_Toast_IsClose;
@property (assign, nonatomic) BOOL m_GrayN_Toast_IsProcessing;

- (void)GrayN_Toast_ShowWithMsg:(NSString *)msg;

@end
