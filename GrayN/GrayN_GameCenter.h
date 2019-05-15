//
//  GameCenter.h
//
//  Created by JackYin on 6/12/16.
//  Copyright © 2016年 op-mac1. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, GrayN_GCLoginState) {
    GrayN_GCLogin_Success,
    GrayN_GCLogin_Fail,
    GrayN_GCLogin_Cancel
};

typedef void (^GrayN_GCLoginHandler)(GrayN_GCLoginState bindState,NSDictionary *dic);

@interface GrayN_GameCenter : NSObject

@property (nonatomic,copy) GrayN_GCLoginHandler m_GrayN_GC_LoginHandler;

+ (id)GrayN_share;
- (void)GrayN_GC_LoginWithHandler:(GrayN_GCLoginHandler) handler;
- (void)GrayN_GC_CallbackUserName:(NSString *)userName CUT:(NSString *)currentUserType status:(bool)status;

@end
