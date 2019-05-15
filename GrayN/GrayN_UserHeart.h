//
//  OPUserCenterHeart.h
//
//  Created by op-mac1 on 14-3-4.
//  Copyright (c) 2014年 op-mac1. All rights reserved.
//

#import <iostream>
#import "GrayNcommon.h"
#import "GrayNconfig.h"
#import "GrayNasyn_CallBack.h"
#import "GrayN_Timer_GrayN.h"
/*5.1.2*/
#import "GrayN_Https_GrayN.h"
/*5.1.2*/
GrayNusing_NameSpace;
GrayN_NameSpace_Start

class p_GrayN_UserHeart_Observer
{

};

class GrayN_UserHeart : public GrayN_Http_GrayN::GrayN_HttpListener,public GrayN_TimerObserver
{
public:
    GrayN_UserHeart();
    ~GrayN_UserHeart();
public:
    inline static GrayN_UserHeart& GetInstance(){
        static GrayN_UserHeart GrayNuserHeart;
        return GrayNuserHeart;
    }
public:
    enum GrayN_UserHeart_HttpType
    {
        GrayN_UserHeart_Get_Heart_Info,     //心跳
    };
    
    
private:
    int p_GrayN_UserHeart_HttpType;
    GrayN_Https_GrayN* p_GrayN_UserHeart_Https;

    string p_GrayN_UserHeart_HttpBuffer;     //接收的数据缓存
    GrayN_UserHeart* p_GrayN_UserHeartObject;
    static p_GrayN_UserHeart_Observer* p_GrayN_UserHeartObserver;
    bool p_GrayN_UserHeart_IsStop;
    GrayN_Timer_GrayN* p_GrayN_UserHeart_Timer;            //心跳

public:
    static int m_GrayN_UserHeart_BeatingTime;         //心跳时间
    static std::string m_GrayN_UserHeart_Url;   //用户中心接口,心跳接口

    
public:
    static void GrayN_UserHeart_SetListener(p_GrayN_UserHeart_Observer* observer);
    
    //心跳
    void GrayN_UserHeart_HeartBeating();
    //停止心跳
    void GrayN_UserHeart_StopHeartBeat();
    //心跳
    void GrayN_UserHeart_RunHeartBeating(string type);
    
private:

    //心跳解析
    void GrayN_UserHeart_ParseHeartbeating();
    //心跳(时间到)
    virtual void GrayN_TimeUp();
    
public:
    virtual void GrayN_On_HttpError(GrayN_Http_GrayN* client, GrayN_HttpErrorCode code);
    virtual void GrayN_On_HttpEvent(GrayN_Http_GrayN* client, GrayN_HttpEventCode code);
    virtual void GrayN_On_HttpResponse(GrayN_Http_GrayN* client,int code,int context_length,int startPos,int endPos,int totalContext,const char* data);
    virtual void GrayN_On_Http_Data(GrayN_Http_GrayN* client,const char* data,int count);
    
};

GrayN_NameSpace_End


