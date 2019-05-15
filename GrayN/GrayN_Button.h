//
//  OPButton.h
//
//  Created by 韩征 on 14-12-19.
//  Copyright (c) 2014年 op-mac1. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GrayN_Button : UIView

@property (nonatomic, retain) UIButton *m_GrayN_Button;
@property (nonatomic, retain) UIButton *m_GrayN_ImageBtn;

- (void)GrayNsetButtonTitle:(NSString *)title titleColor:(UIColor *)color fontName:(NSString *)fontName fontSize:(float)size forState:(UIControlState)state;
- (void)GrayNsetButtonCornerRadius:(float)radius;
- (void)GrayNsetButtonImage:(NSString *)imageString state:(UIControlState)state;
- (void)GrayNsetDisplayButtonImage:(NSString *)imageString frame:(CGRect)frame;
- (void)GrayNsetButtonWithFrontImage:(NSString *)imageString imageFrame:(CGRect)frame
;
- (void)GrayNsetButtonNoFrame;

- (void)GrayNaddCheckBoxFrame:(CGRect)frame boxLeft:(BOOL)orient interval:(float)interval title:(NSString *)title titleColor:(UIColor *)color fontName:(NSString *)name fontSize:(float)size imageName:(NSString *)imageName;
@end
