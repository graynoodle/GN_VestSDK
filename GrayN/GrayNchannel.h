//
//  GrayNchannel.h
//
//  Created by op-mac1 on 13-12-31.
//  Copyright (c) 2013年 op-mac1. All rights reserved.
//

#import <iostream>
#import "GrayNconfig.h"
#import "GrayNjson_cpp.h"
#import "OPGameSDK.h"

GrayN_NameSpace_Start

class GrayNchannel {
    
public:
    GrayNchannel();
    ~GrayNchannel();
    
public:
    inline static GrayNchannel& GetInstance(){
        static GrayNchannel GrayN_channel;
        return GrayN_channel;
    }
    
public:
    virtual const char* GrayN_GetEnable_Interface();
    
    //初始化SDK版本号
    void GrayN_PreInit();
    //初始化
    virtual void GrayN_ChannelInit();
    //初始化化完成第三方渠道要做的其他操作，主要指后台程序，例如appstore的同步订单
    virtual void GrayN_ChannelInitOver();
    
    //登录
    virtual void GrayN_ChannelLogin();
    virtual void GrayN_SetLoginStatus(bool status);
    virtual bool GrayN_ChannelIsLogin();
    virtual void GrayN_ChannelCustomService();
    //登出
    virtual void GrayN_ChannelLogout();
    virtual void GrayN_ChannelSetGameLoginInfo(OPGameInfo opParam,OPGameType opGameType);
    
    virtual bool GrayN_ChannelApplicationDidFinishLaunchingWithOptions(void *application,void *launchOptions);
    
    virtual bool GrayN_ChannelApplicationSupportedInterfaceOrientationsForWindow();
    
    virtual unsigned int GrayN_ChannelApplicationSupportedInterfaceOrientationsForWindow(void *application,void *window);
    virtual bool GrayN_ChannelShouldAutoRotate();
    virtual void GrayN_ChannelApplicationWillEnterForeground(id application);
    

    //进入
    virtual void GrayN_ChannelEnterPlatform();

    
    //在游戏暂停或者从后台恢复的时候显示暂停页
    virtual void GrayN_ChannelShowPausePage();
    
    //切换账号
    virtual void GrayN_ChannelSwitchAccount();
    /*5.2.0*/
    virtual void GrayN_ChannelCheckHandleOpenURL(void* url);
    /*5.2.0*/

    virtual bool GrayN_ChannelHandleOpenUrl(void* url);
    virtual void GrayN_ChannelHandleOpenUrl(void* url, void* application);
    virtual bool GrayN_ChannelHandleOpenUrl(void* application,void* url,void* sourceApplication,void* annotation);

public:

    //解析渠道具体验证
    virtual void GrayN_ChannelParseChargeInfo(GrayN_JSON::Value chargeInfoJson);
    //解析渠道具体验证
    virtual void GrayN_ChannelParseChargeInfo(int chargeType,GrayN_JSON::Value chargeInfoJson);
    
private:
    bool p_GrayN_ChannelLoginStatus;
    bool p_GrayN_IsOfficialCharge;
    
public:
    std::string p_GrayN_FuctionDes;            //渠道接口功能描述
    bool m_GrayN_IsLogining;
};

GrayN_NameSpace_End

