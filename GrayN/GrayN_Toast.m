//
//  OPBaseToastHud.m
//  Login
//
//  Created by 韩征 on 14-3-7.
//  Copyright (c) 2014年 韩征. All rights reserved.
//

#import "GrayN_Toast.h"
#import "GrayN_BaseControl.h"
#import "GrayNconfig.h"

#define GrayN_Toast_Time 2

@implementation GrayN_Toast

@synthesize m_GrayN_Toast_Label = _m_GrayN_Toast_Label;
@synthesize m_GrayN_Toast_IsClose = _m_GrayN_Toast_IsClose;
@synthesize m_GrayN_Toast_IsProcessing = _m_GrayN_Toast_IsProcessing;

-(void)dealloc
{
    [super dealloc];
    GrayNreleaseSafe(_m_GrayN_Toast_Label);
}

- (void)GrayNsetToastBounds:(CGRect)bounds
{
    self.bounds = bounds;
    _m_GrayN_Toast_Label.frame = CGRectMake(0, 0, bounds.size.width, bounds.size.height);
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code
        _m_GrayN_Toast_Label = [[UILabel alloc] init];
        _m_GrayN_Toast_Label.frame = CGRectZero;
        _m_GrayN_Toast_Label.font = [UIFont fontWithName:GrayNgetResBundleStr(GrayN_FONT_UI) size:20*GrayNscreen_Ratio];
        _m_GrayN_Toast_Label.textColor = GrayNwhiteColor;
        _m_GrayN_Toast_Label.textAlignment = NSTextAlignmentCenter;
        _m_GrayN_Toast_Label.backgroundColor = GrayNclearColor;
        [self addSubview:_m_GrayN_Toast_Label];
        
        self.backgroundColor = GrayNtoastBackgroundColor;
        [self.layer setCornerRadius:5.8f];
        [self setClipsToBounds:YES];
        [self setHidden:YES];
    }
    return self;
}

- (void)GrayN_Toast_ShowWithMsg:(NSString *)msg
{
//    NSLog(@"GrayN_Toast_ShowWithMsg:%@", msg);
    CGFloat constrainedSize = msg.length*20*GrayNscreen_Ratio;
    CGSize textSize = [msg sizeWithFont:_m_GrayN_Toast_Label.font
                      constrainedToSize:CGSizeMake(constrainedSize, 30*GrayNscreen_Ratio)
                          lineBreakMode:NSLineBreakByWordWrapping];
    [self GrayNsetToastBounds: CGRectMake(0, 0, (textSize.width+GrayNtoast_Edge_Width), 40*GrayNscreen_Ratio)];
    _m_GrayN_Toast_Label.text = msg;

    [self setHidden:NO];
    if (!_m_GrayN_Toast_IsProcessing) {
        [self GrayNstartToast];
        _m_GrayN_Toast_IsProcessing = YES;
    }
}

- (void)GrayNstartToast
{
    p_GrayN_Toast_Timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(GrayNcloseToast) userInfo:nil repeats:YES];
    [p_GrayN_Toast_Timer fire];
}

- (void)GrayNdealTimer
{
    if (p_GrayN_Toast_Timer != nil) {
        [p_GrayN_Toast_Timer invalidate];
        p_GrayN_Toast_Timer = nil;
    }
}

- (void)GrayNcloseToast
{
    static int time = GrayN_Toast_Time;

    if (time == -1) {
        /*5.1.1*/
        _m_GrayN_Toast_IsProcessing = NO;

//        [self setHidden:YES];
        if (_m_GrayN_Toast_IsClose) {
            [[GrayN_BaseControl GrayN_Share] GrayN_CloseSDK_Window];
        }
        [self removeFromSuperview];
        [self GrayNdealTimer];
        time = GrayN_Toast_Time;
    }
    time--;
}

@end
