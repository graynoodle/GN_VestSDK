//
//  OPButton.m
//
//  Created by 韩征 on 14-12-19.
//  Copyright (c) 2014年 op-mac1. All rights reserved.
//

#import "GrayN_Button.h"
#import "GrayNconfig.h"

#define BtnCornerRadius 7.0f

@implementation GrayN_Button
@synthesize m_GrayN_Button = _m_GrayN_Button;
@synthesize m_GrayN_ImageBtn = _m_GrayN_ImageBtn;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self.layer setCornerRadius:BtnCornerRadius];
        self.backgroundColor = GrayNclearColor;
        _m_GrayN_Button.backgroundColor = GrayNclearColor;
        _m_GrayN_Button = [UIButton buttonWithType:UIButtonTypeCustom];
        _m_GrayN_Button.frame = CGRectMake(GrayNmarginLine, GrayNmarginLine, frame.size.width-2*GrayNmarginLine, frame.size.height-2*GrayNmarginLine);
        [_m_GrayN_Button.layer setCornerRadius:BtnCornerRadius];
        [_m_GrayN_Button setShowsTouchWhenHighlighted:YES];
        [self setUserInteractionEnabled:YES];
        [self addSubview:_m_GrayN_Button];
    }
    return self;
}

/* 按钮属性设置 */
- (void)GrayNsetButtonTitle:(NSString *)title titleColor:(UIColor *)color fontName:(NSString *)fontName fontSize:(float)size forState:(UIControlState)state
{
    [_m_GrayN_Button setTitle:title forState:state];
    [_m_GrayN_Button setTitleColor:color forState:state];
    _m_GrayN_Button.titleLabel.font = [UIFont fontWithName:fontName size:size];
}

/* 设置按钮圆角 */
- (void)GrayNsetButtonCornerRadius:(float)radius
{
    [self.layer setCornerRadius:radius];
    [_m_GrayN_Button.layer setCornerRadius:radius];
}

/* 設置按鈕圖片 */
- (void)GrayNsetButtonImage:(NSString *)imageString state:(UIControlState)state
{
    [self GrayNsetButtonCornerRadius:0];
    [_m_GrayN_Button setShowsTouchWhenHighlighted:NO];
    
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:imageString];
    UIImage *backImage = [UIImage imageWithContentsOfFile:path];
    [_m_GrayN_Button setBackgroundImage:backImage forState:state];
}

/* 設置顯示圖片 */
- (void)GrayNsetDisplayButtonImage:(NSString *)imageString frame:(CGRect)frame
{
    [self GrayNsetButtonCornerRadius:0];
    
    UIImageView *topView = [[[UIImageView alloc] initWithFrame:frame] autorelease];
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:imageString];
    topView.image = [UIImage imageWithContentsOfFile:path];
    topView.center = CGPointMake(self.frame.size.width*0.5, self.frame.size.height*0.5);
    [self addSubview:topView];
}

/* 設置有圖片在前的按鈕 */
- (void)GrayNsetButtonWithFrontImage:(NSString *)imageString imageFrame:(CGRect)frame
{
    [self GrayNsetButtonCornerRadius:0];
    
    UIImageView *topView = [[[UIImageView alloc] initWithFrame:frame] autorelease];
    topView.backgroundColor = GrayNclearColor;
    if (![imageString isEqualToString:@""]) {
        NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:imageString];
        topView.image = [UIImage imageWithContentsOfFile:path];
    }
    
    topView.center = CGPointMake(self.frame.size.height/2, self.frame.size.height/2);
    [self addSubview:topView];
    //    [self setButtonAppendFrame:CGRectMake(0, 0, self.frame.size.height, 0)];
    //    _m_GrayN_Button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [_m_GrayN_Button setTitleEdgeInsets:UIEdgeInsetsMake(0, frame.size.width, 0, 0)];
}

- (void)setButtonAppendFrame:(CGRect)frame
{
    _m_GrayN_Button.frame = CGRectMake(_m_GrayN_Button.frame.origin.x, _m_GrayN_Button.frame.origin.y, _m_GrayN_Button.frame.size.width+frame.size.width-4, _m_GrayN_Button.frame.size.height+frame.size.height);
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width+frame.size.width, self.frame.size.height+frame.size.height);
}

- (void)GrayNsetButtonNoFrame
{
    _m_GrayN_Button.frame = self.bounds;
}

- (void)GrayNaddCheckBoxFrame:(CGRect)frame boxLeft:(BOOL)orient interval:(float)interval title:(NSString *)title titleColor:(UIColor *)color fontName:(NSString *)name fontSize:(float)size imageName:(NSString *)imageName
{
    [_m_GrayN_Button setShowsTouchWhenHighlighted:NO];
    
    // 标题
    UILabel *title_label = [[[UILabel alloc] init] autorelease];
    title_label.text = title;
    title_label.font = [UIFont fontWithName:name size:size];
    CGFloat constrainedSize = title_label.text.length*size;
    CGSize textSize = [title_label.text sizeWithFont:title_label.font
                                   constrainedToSize:CGSizeMake(constrainedSize, size)
                                       lineBreakMode:NSLineBreakByWordWrapping];
    title_label.textColor = color;
    title_label.backgroundColor = GrayNclearColor;
    // 是否有图片
    if ([imageName isEqualToString:@""]) {
        title_label.frame = CGRectMake(0, (frame.size.height-size)*0.5, textSize.width, size);
        self.frame = CGRectMake(frame.origin.x, frame.origin.y, title_label.frame.size.width, frame.size.height);
    } else {
        // 框
        _m_GrayN_ImageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _m_GrayN_ImageBtn.frame = CGRectMake(0, 0, size, size);
        _m_GrayN_ImageBtn.backgroundColor = GrayNclearColor;
        [_m_GrayN_ImageBtn setUserInteractionEnabled:NO];
        NSString *pathOn = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:imageName];
        [_m_GrayN_ImageBtn setBackgroundImage:[UIImage imageWithContentsOfFile:pathOn] forState:UIControlStateNormal];
        if (orient) {
            _m_GrayN_ImageBtn.center = CGPointMake(_m_GrayN_ImageBtn.frame.size.width*0.5, frame.size.height*0.5);
            title_label.frame = CGRectMake(_m_GrayN_ImageBtn.frame.size.width+interval, _m_GrayN_ImageBtn.frame.origin.y, textSize.width, size);
        } else {
            title_label.frame = CGRectMake(0, _m_GrayN_ImageBtn.frame.origin.y, textSize.width, size);
            _m_GrayN_ImageBtn.center = CGPointMake(title_label.frame.size.width+_m_GrayN_ImageBtn.frame.size.width+interval*0.5, self.center.y);
        }
        self.frame = CGRectMake(frame.origin.x, frame.origin.y, _m_GrayN_ImageBtn.frame.size.width+title_label.frame.size.width+interval, frame.size.height);
        [self addSubview:_m_GrayN_ImageBtn];
    }
    
    _m_GrayN_Button.frame = CGRectMake(GrayNmarginLine, GrayNmarginLine, self.frame.size.width-2*GrayNmarginLine, self.frame.size.height-2*GrayNmarginLine);
    [self addSubview:title_label];
}
@end




