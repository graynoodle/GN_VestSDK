//
//  GrayN_Https_GrayN.h
//
//  Created by JackYin on 29/3/16.
//  Copyright © 2016年 op-mac1. All rights reserved.
//
#ifdef OPLogSDK_BaseTools
#else
#ifndef OPHttps_h
#define OPHttps_h

#import <stdio.h>
#import <iostream>
#import  <objc/objc.h>

#import "GrayNconfig.h"
#import "GrayN_Http_GrayN.h"

#define HTTPHEADER

using namespace std;

GrayN_NameSpace_Start
class GrayN_Https_GrayN
{
public:
     GrayN_Https_GrayN();
    ~GrayN_Https_GrayN();
public:
    inline static GrayN_Https_GrayN& GetInstance(){
        static GrayN_Https_GrayN pur;
        return pur;
    }
    
public:
    void GrayN_Http_Set_Listener(GrayN_Http_GrayN::GrayN_HttpListener* listener){this->p_GrayN_HttpsListener=listener;}
    
    // 纯文本传输
    void GrayN_Https_Post(string url, string body);
    
    const char* GrayN_Http_Get_SocketError();
    int  GrayN_Http_Get_HttpCode();
    void GrayN_Thread_OpenSwitch();
    void GrayNstop();
#ifdef HTTPHEADER
    //该接口只是为了获取时间，和HTTP.h保持一致
//    string GetHttpHeader();
    static std::string m_GrayN_HeadDate;
#endif

private:
    string  p_GrayN_SocketError;
    int     p_GrayN_HttpCode;
    id      p_GrayN_AFNetworking;
    GrayN_Http_GrayN::GrayN_HttpListener* p_GrayN_HttpsListener;
    int     p_GrayN_RequestId;
    static int p_GrayN_CurrentRequestId;
    
    GrayN_Https_GrayN *p_GrayN_SelfObject;
};
GrayN_NameSpace_End
#endif /* OPHttps_hpp */
#endif
