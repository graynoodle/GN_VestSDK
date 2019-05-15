//
//  GrayN_QRCodeConfirm.m
//  Login
//
//  Created by 韩征 on 14-3-10.
//  Copyright (c) 2014年 韩征. All rights reserved.
//

#import "GrayN_QRCodeConfirm.h"
#import "GrayN_BaseControl.h"
#import "GrayNconfig.h"
#import "GrayN_Button.h"
#import "GrayN_Tools.h"
#import "GrayNcommon.h"
#import "GrayN_UserCenter.h"

GrayNusing_NameSpace;

#define GrayN_QR_TitleFontSize     30*GrayNscreen_Ratio
#define GrayN_QR_RestrictLength    40
@interface GrayN_QRCodeConfirm()
{
    UIView      *p_GrayN_QR_Line;
    
    UIView *p_GrayN_QR_ContentView;
    GrayN_Button *p_GrayN_QR_Confirm;
    GrayN_Button *p_GrayN_QR_Cancel;
    UILabel     *p_GrayN_QR_UserName;
    UILabel     *p_GrayN_QR_LabelTitle;
}
@end

@implementation GrayN_QRCodeConfirm


/* RVC点击事件响应 */
- (void)btnClick:(UIButton *)btn
{
    if (btn.tag == 1) {
        // 取消
        [[GrayN_BaseControl GrayN_Share] GrayNcloseQRCodeView];
    } else {
        // 确认
        GrayN_LoadingUI::GetInstance().GrayN_ShowWaitMainThread(GrayNcommon::GrayNcommonGetLocalLang(GrayN_WaitingString));
        GrayN_UserCenter::GetInstance().GrayN_UserCenter_QRScannerConfirm_GrayN();
    }
}

-(void)dealloc
{
    GrayNreleaseSafe(p_GrayN_QR_LabelTitle);
    GrayNreleaseSafe(p_GrayN_QR_UserName);
    GrayNreleaseSafe(p_GrayN_QR_Line);

    [super dealloc];
}

- (void)GrayN_QR_SetCornerRadius:(float)radius
{
    [self.layer setCornerRadius:radius];
    [p_GrayN_QR_ContentView.layer setCornerRadius:radius];
    
    [p_GrayN_QR_LabelTitle.layer setCornerRadius:radius];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = GrayNhudBackgroundColor;
        p_GrayN_QR_ContentView = [[UIView alloc] initWithFrame:CGRectMake(1, 1, frame.size.width-2, frame.size.height-2)];
        p_GrayN_QR_ContentView.backgroundColor = GrayNwhiteColor;
        [self addSubview:p_GrayN_QR_ContentView];
        
        [self GrayN_QR_SetCornerRadius:5.8f];
        [self setClipsToBounds:YES];
        
        // 登录确认
        GrayN_Button *loginConfirm = [[GrayN_Button alloc] initWithFrame:CGRectMake(0, 0, 429*GrayNscreen_Ratio, 70*GrayNscreen_Ratio)];
        loginConfirm.center = CGPointMake(self.center.x, 66*GrayNscreen_Ratio);
        loginConfirm.backgroundColor = GrayNclearColor;
        loginConfirm.m_GrayN_Button.backgroundColor = GrayN_QR_BlueColor;
        [loginConfirm.m_GrayN_Button setUserInteractionEnabled:NO];
        [loginConfirm GrayNsetButtonTitle:GrayNgetResBundleStr(GrayN_LoginConfirm) titleColor:GrayNwhiteColor fontName:GrayNgetResBundleStr(GrayN_FONT_UI) fontSize:GrayN_QR_TitleFontSize forState:UIControlStateNormal];
        [p_GrayN_QR_ContentView addSubview:loginConfirm];
        
        // 分割线
        p_GrayN_QR_Line = [[[UIView alloc] init] autorelease];
        p_GrayN_QR_Line.frame = CGRectMake(0, 0, 361*GrayNscreen_Ratio, 1);
        p_GrayN_QR_Line.center = CGPointMake(self.center.x, self.center.y*0.8);
        p_GrayN_QR_Line.backgroundColor = GrayNhudLineColor;
        [p_GrayN_QR_ContentView addSubview:p_GrayN_QR_Line];
        
        // 账号
        p_GrayN_QR_UserName = [[UILabel alloc] init];
        p_GrayN_QR_UserName.backgroundColor = GrayNclearColor;
        
        p_GrayN_QR_UserName.textAlignment = NSTextAlignmentLeft;
        
        p_GrayN_QR_UserName.font = [UIFont fontWithName:GrayNgetResBundleStr(GrayN_FONT_UI) size:GrayN_QR_TitleFontSize];
        p_GrayN_QR_UserName.frame = CGRectMake(0, 0, 361*GrayNscreen_Ratio, 50*GrayNscreen_Ratio);
        p_GrayN_QR_UserName.center = CGPointMake(self.center.x, self.center.y*0.65);
  
        p_GrayN_QR_UserName.backgroundColor = GrayNclearColor;
        
        [p_GrayN_QR_ContentView addSubview:p_GrayN_QR_UserName];
    
        
        // 提示语
        p_GrayN_QR_LabelTitle = [[UILabel alloc] init];
        p_GrayN_QR_LabelTitle.font = [UIFont fontWithName:GrayNgetResBundleStr(GrayN_FONT_UI) size:GrayN_QR_TitleFontSize*0.8];
        p_GrayN_QR_LabelTitle.frame = CGRectMake(0, 0, 340*GrayNscreen_Ratio, 120*GrayNscreen_Ratio);
        p_GrayN_QR_LabelTitle.center = CGPointMake(self.center.x, self.center.y*1.2);
        p_GrayN_QR_LabelTitle.numberOfLines = 0;
        p_GrayN_QR_LabelTitle.lineBreakMode = NSLineBreakByCharWrapping;
        p_GrayN_QR_LabelTitle.textColor = GrayN_QR_GrayColor;
        p_GrayN_QR_LabelTitle.textAlignment = NSTextAlignmentLeft;
        p_GrayN_QR_LabelTitle.backgroundColor = GrayNclearColor;
        p_GrayN_QR_LabelTitle.text = GrayNgetResBundleStr(GrayN_LoginHint);
        
        [p_GrayN_QR_ContentView addSubview:p_GrayN_QR_LabelTitle];
        
        // 确认
        p_GrayN_QR_Confirm = [[GrayN_Button alloc] initWithFrame:CGRectMake(0, 0, 170*GrayNscreen_Ratio, 60*GrayNscreen_Ratio)];
        p_GrayN_QR_Confirm.center = CGPointMake(self.center.x*1.45, 420*GrayNscreen_Ratio);
        p_GrayN_QR_Confirm.backgroundColor = GrayNclearColor;
        p_GrayN_QR_Confirm.m_GrayN_Button.backgroundColor = GrayN_QR_BlueColor;
        p_GrayN_QR_Confirm.m_GrayN_Button.tag = 2;
        [p_GrayN_QR_Confirm.m_GrayN_Button addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];

        [p_GrayN_QR_Confirm GrayNsetButtonTitle:GrayNgetResBundleStr(GrayN_QR_Sure) titleColor:GrayNwhiteColor fontName:GrayNgetResBundleStr(GrayN_FONT_UI) fontSize:GrayN_QR_TitleFontSize forState:UIControlStateNormal];
        [p_GrayN_QR_ContentView addSubview:p_GrayN_QR_Confirm];
        
        
        p_GrayN_QR_Cancel = [[GrayN_Button alloc] initWithFrame:CGRectMake(0, 0, 170*GrayNscreen_Ratio, 60*GrayNscreen_Ratio)];
        p_GrayN_QR_Cancel.center = CGPointMake(self.center.x*0.55, 420*GrayNscreen_Ratio);
        p_GrayN_QR_Cancel.backgroundColor = GrayNclearColor;
        p_GrayN_QR_Cancel.m_GrayN_Button.backgroundColor = GrayN_QR_GrayColor;
        p_GrayN_QR_Cancel.m_GrayN_Button.tag = 1;
        [p_GrayN_QR_Cancel.m_GrayN_Button addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];

        [p_GrayN_QR_Cancel GrayNsetButtonTitle:GrayNgetResBundleStr(GrayN_CANCEL) titleColor:GrayNwhiteColor fontName:GrayNgetResBundleStr(GrayN_FONT_UI) fontSize:GrayN_QR_TitleFontSize forState:UIControlStateNormal];
        [p_GrayN_QR_ContentView addSubview:p_GrayN_QR_Cancel];
        
        [self setHidden:YES];
    }
    return self;
}

- (void)GrayNshowQRCodeCofirm
{

    NSString *opAccountTitle = [NSString stringWithUTF8String:GrayNcommon::m_GrayN_Game_UserName.c_str()];
    NSString *loginType = [NSString stringWithUTF8String:GrayNcommon::m_GrayN_LoginType.c_str()];
    GrayNcommon::GrayN_ConsoleLog(@"GrayNshowQRCodeCofirm loginType=%@", loginType);
    if ([loginType rangeOfString:@"speedy"].location != NSNotFound) {
        opAccountTitle = [NSString stringWithFormat:@"%@",GrayNgetResBundleStr(GrayN_GUEST_NAME)];
    }
    if ([loginType rangeOfString:@"phone"].location != NSNotFound) {
        opAccountTitle = [NSString stringWithUTF8String:GrayNcommon::m_GrayN_Game_PhoneNum.c_str()];
    }
    
    // 限制显示用户名长度，控制为30位以内
    if (opAccountTitle.length >= GrayN_QR_RestrictLength) {
        opAccountTitle = [NSString stringWithFormat:@"%@...",[opAccountTitle substringToIndex:GrayNrestrict_Length-3]];
    }
    
    NSString *opAccountName = [NSString stringWithFormat:@"%@:%@",GrayNgetResBundleStr(GrayN_AccountDisplay),opAccountTitle];
    
    NSMutableAttributedString *attributedName =
    [[[NSMutableAttributedString alloc] initWithString:opAccountName] autorelease];
    
    [attributedName addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:GrayNgetResBundleStr(GrayN_FONT_DESCRIPTION) size:GrayN_QR_TitleFontSize], NSFontAttributeName, GrayN_QR_GrayColor, NSForegroundColorAttributeName, nil] range:NSMakeRange(0,opAccountName.length-opAccountTitle.length)];
    
    [attributedName addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:GrayN_QR_TitleFontSize], NSFontAttributeName, GrayN_QR_BlueColor, NSForegroundColorAttributeName, nil] range:NSMakeRange(opAccountName.length-opAccountTitle.length, opAccountTitle.length)];
    
    // 掌趣账号：
    p_GrayN_QR_UserName.attributedText = attributedName;
    
    [self setHidden:NO];
}
@end
