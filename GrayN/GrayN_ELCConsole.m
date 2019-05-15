//
//  GrayN_ELCConsole.m
//  ELCImagePickerDemo
//
//  Created by Seamus on 14-7-11.
//  Copyright (c) 2014年 ELC Technologies. All rights reserved.
//

#import "GrayN_ELCConsole.h"

static GrayN_ELCConsole *_mainconsole;

@implementation GrayN_ELCConsole
+ (GrayN_ELCConsole *)mainConsole
{
    if (!_mainconsole) {
        _mainconsole = [[GrayN_ELCConsole alloc] init];
    }
    return _mainconsole;
}

- (id)init
{
    self = [super init];
    if (self) {
        myIndex = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    myIndex = nil;
    _mainconsole = nil;
}

- (void)addIndex:(int)index
{
    if (![myIndex containsObject:@(index)]) {
        [myIndex addObject:@(index)];
    }
}

- (void)removeIndex:(int)index
{
    [myIndex removeObject:@(index)];
}

- (void)removeAllIndex
{
    [myIndex removeAllObjects];
}

- (int)currIndex
{
    [myIndex sortUsingSelector:@selector(compare:)];
    
    for (int i = 0; i < [myIndex count]; i++) {
        int c = [[myIndex objectAtIndex:i] intValue];
        if (c != i) {
            return i;
        }
    }
    return (int)[myIndex count];
}

- (int)numOfSelectedElements {
    
    return [myIndex count];
}

@end
