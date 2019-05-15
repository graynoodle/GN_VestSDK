//
//  GrayN_Timer_GrayN.cpp
//
//  Created by op-mac1 on 14-1-14.
//  Copyright (c) 2014年 op-mac1. All rights reserved.
//

#import "GrayN_Timer_GrayN.h"
#import "GrayNcommon.h"

GrayNusing_NameSpace;

GrayN_Timer_GrayN::GrayN_Timer_GrayN()
{
    m_GrayN_timerListener = NULL;
    m_GrayN_IsStopTimer = false;
    m_GrayN_WaitTime = 0;
}

GrayN_Timer_GrayN::~GrayN_Timer_GrayN()
{
    
}

void GrayN_Timer_GrayN::GrayN_StartTimer(unsigned int waitTime,GrayN_TimerObserver* observer)
{
    m_GrayN_WaitTime = waitTime;
    m_GrayN_timerListener = observer;
    GrayNstart();
}

void GrayN_Timer_GrayN::GrayNrun(void* p)
{
    GrayN_Timer_GrayN* timer = (GrayN_Timer_GrayN*)p;
    if (timer->m_GrayN_timerListener == NULL) {
        GrayNcommon::GrayN_DebugLog("GrayN_Timer_GrayN::SetListener(): Not Set.");
        return;
    }
    while (true) {
        sleep(timer->m_GrayN_WaitTime);
        if (timer->m_GrayN_IsStopTimer) {
            break;
        }
        timer->m_GrayN_timerListener->GrayN_TimeUp();
    }
    if (timer) {
        GrayNcommon::GrayN_DebugLog("opTimer: release.");
        delete timer;
        timer = NULL;
    }
}

void GrayN_Timer_GrayN::GrayN_StopTimer()
{
    m_GrayN_IsStopTimer = true;
    //this->stop();     //使用该句会再sleep的时候将线程停止，但是会出现内存泄露
}

unsigned int GrayN_Timer_GrayN::GrayN_GetCurrentTime()
{
    return m_GrayN_WaitTime;
}
