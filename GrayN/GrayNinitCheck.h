//
//  GrayNinitCheck.h
//
//  Created by op-mac1 on 14-6-18.
//  Copyright (c) 2014年 op-mac1. All rights reserved.
//

#import "GrayN_Thread_GrayN.h"
#import "GrayNasyn_CallBack.h"
//#import "OPParam.h"

GrayN_NameSpace_Start

class GrayNinitCheck : public GrayN_Thread_GrayN
{
public:
    GrayNinitCheck();
    ~GrayNinitCheck();
    
public:
    inline static GrayNinitCheck &GetInstance()
    {
        static GrayNinitCheck GrayNinitCheck;
        return GrayNinitCheck;
    }
    
public:
    void GrayN_CheckInitStatus();
    
public:
    void GrayNrun(void* p);
    
private:
    static void GrayN_NotifyRegisterLogin(void* args);
    static void GrayN_NotifyLoginFail(void* args);
    
private:
    GrayNasyn_CallBack* p_GrayN_InitAsyn_CallBack;
};

GrayN_NameSpace_End

