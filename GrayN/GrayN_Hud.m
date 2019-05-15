//
//  GrayN_Hud.m
//  Login
//
//  Created by 韩征 on 14-3-10.
//  Copyright (c) 2014年 韩征. All rights reserved.
//

#import "GrayN_Hud.h"
#import "GrayN_BaseControl.h"
#import "GrayNconfig.h"
#import "GrayN_Button.h"

#define GrayN_Hud_LoadingTime         1
#define GrayN_Hud_NameFontSize        18*GrayNscreen_Ratio
@interface GrayN_Hud()
{
    GrayN_Button    *p_GrayN_Hud_SwitchBtn;
    UILabel     *p_GrayN_Hud_UserName;
    UILabel     *p_GrayN_Hud_LabelTitle;
    UIView      *p_GrayN_Hud_Line_1;
    UIView      *p_GrayN_Hud_Line_2;
    UIImageView *p_GrayN_Hud_bg;
}
@end

@implementation GrayN_Hud

@synthesize m_GrayN_Hud_UserName = _m_GrayN_Hud_UserName;
@synthesize m_GrayN_Hud_Callback = _m_GrayN_Hud_Callback;

/* RVC点击事件响应 */
- (void)btnClick:(UIButton *)btn
{
    if (btn.tag == 1) {
        //切换账号
        [[GrayN_BaseControl GrayN_Share] GrayNcloseHud];
        
        [[GrayN_BaseControl GrayN_Share] GrayNswitch_Account];
    }
}

-(void)dealloc
{
    GrayNreleaseSafe(p_GrayN_Hud_ActivityIndex);
    GrayNreleaseSafe(p_GrayN_Hud_LabelTitle);
    GrayNreleaseSafe(_m_GrayN_Hud_UserName);
    GrayNreleaseSafe(p_GrayN_Hud_SwitchBtn);
    GrayNreleaseSafe(p_GrayN_Hud_UserName);
    GrayNreleaseSafe(p_GrayN_Hud_Line_1);
    GrayNreleaseSafe(p_GrayN_Hud_Line_2);
    GrayNreleaseSafe(p_GrayN_Hud_bg);
    GrayNreleaseSafe(_m_GrayN_Hud_Callback);

    [super dealloc];
}

- (void)GrayNsetCornerRadius:(float)radius
{
    [self.layer setCornerRadius:radius];
    [p_GrayN_Hud_LabelTitle.layer setCornerRadius:radius];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = GrayNhudBackgroundColor;
        self.alpha = 0.95;
        [self GrayNsetCornerRadius:5.8f];
        [self setClipsToBounds:YES];
        
        // 分割线
        p_GrayN_Hud_Line_1 = [[[UIView alloc] init] autorelease];
        p_GrayN_Hud_Line_1.frame = CGRectMake(0, self.frame.size.height-34*GrayNscreen_Ratio, self.frame.size.width, 0.5);
        p_GrayN_Hud_Line_1.backgroundColor = GrayNhudLineColor;
        [self addSubview:p_GrayN_Hud_Line_1];
        p_GrayN_Hud_Line_2 = [[[UIView alloc] init] autorelease];
        p_GrayN_Hud_Line_2.frame = CGRectMake(0, p_GrayN_Hud_Line_1.frame.origin.y+0.5, self.frame.size.width, 0.5);
        p_GrayN_Hud_Line_2.backgroundColor = GrayNwhiteColor;
        [self addSubview:p_GrayN_Hud_Line_2];
        
        // 标题
        p_GrayN_Hud_LabelTitle = [[UILabel alloc] init];
        p_GrayN_Hud_LabelTitle.font = [UIFont fontWithName:GrayNgetResBundleStr(GrayN_FONT_UI) size:GrayNtitle_Font_Size];
        p_GrayN_Hud_LabelTitle.frame = CGRectZero;
        p_GrayN_Hud_LabelTitle.textColor = GrayNblackColor;
        p_GrayN_Hud_LabelTitle.textAlignment = NSTextAlignmentCenter;
        p_GrayN_Hud_LabelTitle.backgroundColor = GrayNclearColor;

        [self addSubview:p_GrayN_Hud_LabelTitle];
        [self setHidden:YES];
        [self setClipsToBounds:YES];
        
        p_GrayN_Hud_ActivityIndex = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        p_GrayN_Hud_ActivityIndex.color = GrayNblackColor;
        [p_GrayN_Hud_ActivityIndex startAnimating];
        
        // 切换账号
        p_GrayN_Hud_SwitchBtn = [[GrayN_Button alloc] initWithFrame:CGRectMake(0, 0, 162*GrayNscreen_Ratio, 44*GrayNscreen_Ratio)];
        p_GrayN_Hud_SwitchBtn.center = CGPointMake(self.center.x, p_GrayN_Hud_Line_1.center.y);
        p_GrayN_Hud_SwitchBtn.backgroundColor = GrayNclearColor;
        p_GrayN_Hud_SwitchBtn.m_GrayN_Button.backgroundColor = GrayNclearColor;
        p_GrayN_Hud_SwitchBtn.m_GrayN_Button.tag = 1;
        [p_GrayN_Hud_SwitchBtn GrayNsetButtonImage:@"OurSDK_res.bundle/images/switch_on.png" state:UIControlStateNormal];
//        [p_GrayN_Hud_SwitchBtn GrayNsetButtonImage:@"OurSDK_res.bundle/images/switch_on.png" state:UIControlStateHighlighted];

        [p_GrayN_Hud_SwitchBtn GrayNsetButtonTitle:GrayNgetResBundleStr(GrayN_SWITCH_ACCOUNT_TITLE) titleColor:GrayNblackColor fontName:GrayNgetResBundleStr(GrayN_FONT_UI) fontSize:16*GrayNscreen_Ratio forState:UIControlStateNormal];
        [p_GrayN_Hud_SwitchBtn.m_GrayN_Button addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [p_GrayN_Hud_SwitchBtn GrayNsetButtonWithFrontImage:@"" imageFrame:CGRectMake(0, 0, 18*GrayNscreen_Ratio, 18*GrayNscreen_Ratio)];
        
        p_GrayN_Hud_UserName = [[UILabel alloc] init];
        p_GrayN_Hud_UserName.backgroundColor = GrayNclearColor;
        
        [self addSubview:p_GrayN_Hud_ActivityIndex];
        [self addSubview:p_GrayN_Hud_UserName];
        [self addSubview:p_GrayN_Hud_SwitchBtn];
    }
    return self;
}

- (void)GrayN_Hud_ShowWithTag:(int)tag
{
    p_GrayN_Hud_Status = tag;
    NSString *msg = @"";
    if (tag == GrayN_INIT) {
        msg = GrayNgetResBundleStr(GrayN_InitString);
    } else if (tag == GrayN_LOGINNING || tag == GrayN_QUICK_LOGINNING) {
        msg = GrayNgetResBundleStr(GrayN_LOGINNING_STR);
    } else if (tag == GrayN_REGISTERING) {
        msg = GrayNgetResBundleStr(GrayN_REGISTERING_STR);
    } else if (tag == GrayN_BINDPHONE){
        msg = GrayNgetResBundleStr(GrayN_BINDPHONE_STR);
    } else if (tag == GrayN_VERIFING) {
        msg = GrayNgetResBundleStr(GrayN_VERIFING_STR);
    }
    
//    self.bounds = CGRectMake(0, 0, 441*GrayNscreen_Ratio, 111*GrayNscreen_Ratio);
    p_GrayN_Hud_LabelTitle.text = msg;
    p_GrayN_Hud_LabelTitle.frame = CGRectMake(0, 0, msg.length*GrayNtitle_Font_Size, GrayNtitle_Font_Size);
    p_GrayN_Hud_LabelTitle.center = CGPointMake(self.frame.size.width*0.5, self.frame.size.height*0.5);

    if (tag == GrayN_LOGINNING || tag == GrayN_QUICK_LOGINNING) {
        NSString *opAccountTitle = @"";
        if (tag != GrayN_QUICK_LOGINNING) {
            opAccountTitle = _m_GrayN_Hud_UserName;
        } else {
            opAccountTitle = GrayNgetResBundleStr(GrayN_GUEST_NAME);
        }
        
        // 限制显示用户名长度，控制为30位以内
        if (opAccountTitle.length >= GrayNrestrict_Length) {
            opAccountTitle = [NSString stringWithFormat:@"%@...",[opAccountTitle substringToIndex:GrayNrestrict_Length-3]];
        }
        
        NSString *opAccountName = [NSString stringWithFormat:@"%@%@",GrayNgetResBundleStr(GrayN_ACCOUNT),opAccountTitle];
        
        NSMutableAttributedString *attributedName =
        [[[NSMutableAttributedString alloc] initWithString:opAccountName] autorelease];
        
        [attributedName addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:GrayNgetResBundleStr(GrayN_FONT_DESCRIPTION) size:GrayNtitle_Font_Size], NSFontAttributeName, GrayNblackColor, NSForegroundColorAttributeName, nil] range:NSMakeRange(0,opAccountName.length-opAccountTitle.length)];

        [attributedName addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:GrayNtitle_Font_Size], NSFontAttributeName, GrayNorangeColor, NSForegroundColorAttributeName, nil] range:NSMakeRange(opAccountName.length-opAccountTitle.length, opAccountTitle.length)];
        
        // 掌趣账号：
        p_GrayN_Hud_UserName.attributedText = attributedName;
        p_GrayN_Hud_UserName.textAlignment = NSTextAlignmentLeft;
        p_GrayN_Hud_UserName.frame = CGRectMake(p_GrayN_Hud_LabelTitle.frame.origin.x, GrayNtitle_Font_Size, self.frame.size.width-(12+114)*GrayNscreen_Ratio-GrayNtitle_Font_Size, GrayNtitle_Font_Size+2);
//        p_GrayN_Hud_UserName.font = [UIFont boldSystemFontOfSize:GrayNtitle_Font_Size];
        // 进度条时间
        p_GrayN_Hud_Long = GrayN_Hud_LoadingTime;
        p_GrayN_Hud_Timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(GrayNtimeUp) userInfo:nil repeats:YES];
        [p_GrayN_Hud_Timer fire];
        p_GrayN_Hud_IsRunning = YES;
        
        [p_GrayN_Hud_UserName setHidden:NO];
        [p_GrayN_Hud_SwitchBtn setHidden:NO];
    } else if (tag == GrayN_INIT) {
        self.bounds = CGRectMake(0, 0, 441*GrayNscreen_Ratio, 111*GrayNscreen_Ratio-p_GrayN_Hud_Line_2.frame.origin.y);
        p_GrayN_Hud_LabelTitle.center = CGPointMake(self.frame.size.width*0.5, self.frame.size.height*0.5);
        [p_GrayN_Hud_Line_1 setHidden:YES];
        [p_GrayN_Hud_Line_2 setHidden:YES];
        [p_GrayN_Hud_UserName setHidden:YES];
        [p_GrayN_Hud_SwitchBtn setHidden:YES];
    } else {
        NSString *opAccountTitle = _m_GrayN_Hud_UserName;
        NSString *opAccountName = [NSString stringWithFormat:@"%@%@",GrayNgetResBundleStr(GrayN_ACCOUNT),opAccountTitle];
        
        NSMutableAttributedString *attributedName =
        [[[NSMutableAttributedString alloc] initWithString:opAccountName] autorelease];
        
        [attributedName addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:GrayNgetResBundleStr(GrayN_FONT_DESCRIPTION) size:GrayNtitle_Font_Size], NSFontAttributeName, GrayNblackColor, NSForegroundColorAttributeName, nil] range:NSMakeRange(0,opAccountName.length-opAccountTitle.length)];
        
        [attributedName addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:GrayNgetResBundleStr(GrayN_FONT_DESCRIPTION) size:GrayNtitle_Font_Size], NSFontAttributeName, GrayNwhiteColor, NSForegroundColorAttributeName, nil] range:NSMakeRange(opAccountName.length-opAccountTitle.length, opAccountTitle.length)];
        
        // 掌趣账号：
        p_GrayN_Hud_UserName.attributedText = attributedName;
        p_GrayN_Hud_UserName.textAlignment = NSTextAlignmentCenter;
        p_GrayN_Hud_UserName.frame = CGRectMake(0, 0, self.frame.size.width, GrayNtitle_Font_Size+2);
        p_GrayN_Hud_UserName.center = CGPointMake(self.frame.size.width*0.5, p_GrayN_Hud_SwitchBtn.center.y);
        
        [p_GrayN_Hud_UserName setHidden:NO];
        [p_GrayN_Hud_SwitchBtn setHidden:YES];
    }
    // 背景图的frame
//    p_GrayN_Hud_bg.frame = self.bounds;
    p_GrayN_Hud_ActivityIndex.center = CGPointMake(p_GrayN_Hud_LabelTitle.frame.origin.x-50*GrayNscreen_Ratio, p_GrayN_Hud_LabelTitle.frame.origin.y-(p_GrayN_Hud_LabelTitle.frame.origin.y-(p_GrayN_Hud_UserName.frame.origin.y+p_GrayN_Hud_UserName.frame.size.height))*0.5);

    [self setHidden:NO];
}

- (void)GrayN_Hud_Close
{
    if (p_GrayN_Hud_IsRunning) {
        [self GrayNdealTimer];
        p_GrayN_Hud_IsRunning = NO;
    }
    [self setHidden:YES];
    [p_GrayN_Hud_Line_1 setHidden:NO];
    [p_GrayN_Hud_Line_2 setHidden:NO];
}

- (void)GrayNdealTimer
{
    if (p_GrayN_Hud_Timer != nil) {
        [p_GrayN_Hud_Timer invalidate];
        p_GrayN_Hud_Timer = nil;
    }
}

- (void)GrayNtimeUp
{
    if (p_GrayN_Hud_Long == -1) {
        [self GrayNdealTimer];
        if (p_GrayN_Hud_Status == GrayN_LOGINNING) {
            _m_GrayN_Hud_Callback(NO);
        } else if (p_GrayN_Hud_Status == GrayN_QUICK_LOGINNING) {
            _m_GrayN_Hud_Callback(YES);
        }
        [[GrayN_BaseControl GrayN_Share] GrayNcloseHud];
        p_GrayN_Hud_Long = GrayN_Hud_LoadingTime;
        p_GrayN_Hud_IsRunning = NO;
    }
    p_GrayN_Hud_Long--;
}

@end
