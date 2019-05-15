//
//  GrayN_Timer_GrayN.h
//
//  Created by op-mac1 on 14-1-14.
//  Copyright (c) 2014年 op-mac1. All rights reserved.
//

#import <iostream>
#import "GrayNconfig.h"
#import "GrayN_Thread_GrayN.h"
GrayN_NameSpace_Start

class GrayN_TimerObserver
{
public:
    //时间到
    virtual void GrayN_TimeUp(){};
};

class GrayN_Timer_GrayN : public GrayN_Thread_GrayN
{
public:
     GrayN_Timer_GrayN();
    ~GrayN_Timer_GrayN();
    
public:
//使用举例
//注意：对象在调用StopTimer()后会自行销毁，无需外部销毁
//    if (mOpTimer) {
//        if (waitTime == mOpTimer->m_GrayN_WaitTime) {
//            return;
//        }
//        mOpTimer->GrayN_StopTimer();
//    }
//    mOpTimer = new GrayN_Timer_GrayN();
//    mOpTimer->GrayN_StartTimer();
    
    //启动
    //waitTime  等待时间：单位（s）
    void GrayN_StartTimer(unsigned int waitTime,GrayN_TimerObserver* observer);
    //停止
    void GrayN_StopTimer();
    //获取当前等待时间
    unsigned int GrayN_GetCurrentTime();
    unsigned int m_GrayN_WaitTime;         //等待时间
    
private:
    void GrayNrun(void* p);
    
private:
    bool m_GrayN_IsStopTimer;                   //是否停止
//    unsigned int m_GrayN_WaitTime;         //等待时间
    GrayN_TimerObserver* m_GrayN_timerListener;
};

GrayN_NameSpace_End

