#import "GrayN_Thread_GrayN.h"
#import "GrayNcommon.h"

GrayNusing_NameSpace;

void* GrayN_Thread_GrayN::GrayN_ThreadEntery(void* p) {
    try
    {
        GrayN_Thread_GrayN* thread = (GrayN_Thread_GrayN*) p;
        bool p_GrayN_Switch = thread->p_GrayN_Switch;
        thread->GrayNrun(p);
        if (p_GrayN_Switch) {
            thread->GrayNfinished();
        }
    }
//        catch(Game::ExceptionBase& exe)
//        {
//            printf("%s",exe.what());
//        }
    catch (...) {
    }
    return 0;
}

GrayN_Thread_GrayN::GrayN_Thread_GrayN()
{
    p_GrayN_Switch = false;
    this->GrayN_SetPriority((GrayN_GetMinPriority()+GrayN_GetMaxPriority())/2);
}
GrayN_Thread_GrayN::~GrayN_Thread_GrayN()
{
#ifdef HTTPDEBUG
    XCLOG("GrayN_Thread_GrayN::~GrayN_Thread_GrayN()");
#endif
}
void GrayN_Thread_GrayN::GrayNstart() {
#ifdef HTTPDEBUG
    XCLOG("GrayN_Thread_GrayN::GrayNstart()");
#endif

    sched_param schedParam;
    pthread_attr_t attr;
    pthread_attr_init(&attr);
    schedParam.sched_priority=GrayN_GetPriority();
    pthread_attr_setschedparam(&attr,&schedParam);
    int err = pthread_create(&p_GrayN_ThreadId, &attr, GrayN_ThreadEntery, this);
    if (err!=0) {
        cout<<"pthread_create err=: %s"<<strerror(err)<<endl;
    }
    pthread_detach(p_GrayN_ThreadId);
//    size_t stack_size=0;
//    err = pthread_attr_getstacksize(&attr, &stack_size);
//    if (err!=0) {
//        cout<<"pthread_attr_getstacksize err=: %s"<<strerror(err)<<endl;
//    }else{
//        cout<<"pthread_attr_getstacksize="<<stack_size<<endl;
//    }
    pthread_attr_destroy(&attr);
}
void GrayN_Thread_GrayN::GrayNstop()
{
    pthread_cancel(p_GrayN_ThreadId);
}
void GrayN_Thread_GrayN::GrayN_Sleep(int time)
{
    usleep(time*1000);
}
int GrayN_Thread_GrayN::GrayN_GetPriority()
{
    return p_GrayN_Priority;
}

void GrayN_Thread_GrayN::GrayN_Thread_OpenSwitch()
{
    p_GrayN_Switch = true;
}
void GrayN_Thread_GrayN::GrayN_SetPriority(int p)
{
    int min=GrayN_GetMinPriority();
    int max=GrayN_GetMaxPriority();
    if(p<min)
    {
        p=min;
    }else if(p>max)
    {
        p=max;
    }
    this->p_GrayN_Priority=p;
}
void GrayN_Thread_GrayN::GrayNyield()
{
    sched_yield();
}
int GrayN_Thread_GrayN::GrayN_GetMaxPriority()
{
    return sched_get_priority_max(SCHED_RR);
}
int GrayN_Thread_GrayN::GrayN_GetMinPriority()
{
    return sched_get_priority_min(SCHED_RR);
}
