//
//  GrayNcustomService_ImageData.m
//
//  Created by op-mac1 on 15-4-9.
//  Copyright (c) 2015年 op-mac1. All rights reserved.
//

#import "GrayNcustomService_ImageData.h"

@implementation GrayNcustomService_ImageData

@synthesize m_GrayNcustomService_ImageName;
@synthesize m_GrayNcustomService_ImagePath;

- (void)dealloc
{
    [m_GrayNcustomService_ImageName release];
    [m_GrayNcustomService_ImagePath release];
    [super dealloc];
}

@end
