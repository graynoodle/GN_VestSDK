
#import <iostream>
using namespace std;

#import "GrayNconfig.h"
GrayN_NameSpace_Start
    
class GrayN_Thread_GrayN {
public:
    GrayN_Thread_GrayN();
    virtual ~GrayN_Thread_GrayN();
public:
    virtual void    GrayNrun(void* p){}
    virtual void    GrayNfinished(){cout<<"GrayN_Thread_GrayN::GrayNfinished"<<endl;}
    
    void            GrayNstart();
    void            GrayNstop();
    int             GrayN_GetPriority();
    void            GrayN_SetPriority(int p_GrayN_Priority);
    void            GrayN_Thread_OpenSwitch();
public:
    static  void    GrayN_Sleep(int time);
    static  void    GrayNyield();
    static  int     GrayN_GetMaxPriority();
    static  int     GrayN_GetMinPriority();
private:
    static void* GrayN_ThreadEntery(void* p);

    pthread_t    p_GrayN_ThreadId;
    int         p_GrayN_Priority;
    bool        p_GrayN_Switch;
};

GrayN_NameSpace_End


