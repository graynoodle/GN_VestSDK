
#import <Foundation/Foundation.h>
#import "GrayN_DebugView.h"
#import "GrayNcommon.h"
#import "GrayN_BaseControl.h"



GrayNusing_NameSpace;


@interface GrayN_DebugView ()

@end

@implementation GrayN_DebugView
{
    UIButton *p_GrayN_DebugView_CloseBtn;
}
@synthesize m_GrayN_DebugTextView = _m_GrayN_DebugTextView;


- (instancetype)init
{
    self = [super init];
    if (self) {
        p_GrayN_DebugView_CloseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [p_GrayN_DebugView_CloseBtn setTitle:@"X" forState:UIControlStateNormal];
        [p_GrayN_DebugView_CloseBtn setTitleColor:GrayNblackColor forState:UIControlStateNormal];
        p_GrayN_DebugView_CloseBtn.frame = CGRectMake(0, 0, 30, 30);
        [p_GrayN_DebugView_CloseBtn addTarget:self action:@selector(closeTextView) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:p_GrayN_DebugView_CloseBtn];
        _m_GrayN_DebugTextView = [[UITextView alloc] init];
        _m_GrayN_DebugTextView.scrollEnabled = YES;
        _m_GrayN_DebugTextView.editable = NO;
        _m_GrayN_DebugTextView.backgroundColor = GrayNwhiteColor;
        _m_GrayN_DebugTextView.alpha = 0.8;
        
        self.userInteractionEnabled = YES;
        self.backgroundColor = GrayNwhiteColor;
        self.alpha = _m_GrayN_DebugTextView.alpha;
        [self addSubview:_m_GrayN_DebugTextView];
        
        UIButton *clearBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [clearBtn setTitle:@"Clear" forState:UIControlStateNormal];
        [clearBtn setTitleColor:GrayNblackColor forState:UIControlStateNormal];
        clearBtn.frame = CGRectMake(p_GrayN_DebugView_CloseBtn.frame.origin.x+p_GrayN_DebugView_CloseBtn.frame.size.width+10, 0, 50, 30);
        [clearBtn addTarget:self action:@selector(clearText) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:clearBtn];
        
        UIButton *copyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [copyBtn setTitle:@"Copy" forState:UIControlStateNormal];
        [copyBtn setTitleColor:GrayNblackColor forState:UIControlStateNormal];

        copyBtn.frame = CGRectMake(clearBtn.frame.origin.x+clearBtn.frame.size.width+10, 0, 50, 30);
        [copyBtn addTarget:self action:@selector(copyText) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:copyBtn];
    }
    return self;
}
- (void)GrayN_DebugView_SetFrame:(CGRect)rect
{
    self.frame = rect;
    _m_GrayN_DebugTextView.frame = CGRectMake(0, 30, rect.size.width, rect.size.height-30);
}
- (void)closeTextView
{
    [self removeFromSuperview];
}
- (void)clearText
{
    _m_GrayN_DebugTextView.text = @"";
}
- (void)copyText
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = _m_GrayN_DebugTextView.text;
    UIAlertView*alert = [[[UIAlertView alloc]initWithTitle:nil
                                                   message:@"复制成功"
                                                  delegate:nil
                                         cancelButtonTitle:nil
                                         otherButtonTitles:@"确定",nil] autorelease];
    [alert show];
    
}
@end
