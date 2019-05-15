
#import "GrayNinitCheck.h"
#import "GrayNSDK.h"
#import "GrayN_Offical.h"
#import "GrayNinit.h"

GrayNusing_NameSpace;
GrayNinitCheck::GrayNinitCheck()
{
    p_GrayN_InitAsyn_CallBack = new GrayNasyn_CallBack();
}

GrayNinitCheck::~GrayNinitCheck()
{
    if (p_GrayN_InitAsyn_CallBack) {
        delete p_GrayN_InitAsyn_CallBack;
        p_GrayN_InitAsyn_CallBack = NULL;
    }
}

void GrayNinitCheck::GrayN_CheckInitStatus()
{
    if (GrayNSDK::m_GrayN_SDK_InitStatus < 0) {
        //初始化完全失败，则重新初始化
        GrayNSDK::m_GrayN_SDK_InitStatus = -2;
    }
    GrayNstart();
}

void GrayNinitCheck::GrayNrun(void* p)
{
    int count = 0;
    while (true) {
//        cout<<"flag===== "<<count<<endl;
        if (GrayNSDK::m_GrayN_SDK_InitStatus == 0) {
            GrayNcommon::GrayN_ConsoleLog("正在初始化！");
            sleep(2);
        } else if (GrayNSDK::m_GrayN_SDK_InitStatus == 1) {
            GrayNcommon::GrayN_ConsoleLog("初始化完成，并且不更新！");

            p_GrayN_InitAsyn_CallBack->GrayNstartAsyn_CallBack(GrayNinitCheck::GrayN_NotifyRegisterLogin, NULL);
            return;
        } else if (GrayNSDK::m_GrayN_SDK_InitStatus == 2) {
            GrayNcommon::GrayN_ConsoleLog("初始化完成，但更新失败！");

            p_GrayN_InitAsyn_CallBack->GrayNstartAsyn_CallBack(GrayNinitCheck::GrayN_NotifyRegisterLogin, NULL);
            return;
        } else if (GrayNSDK::m_GrayN_SDK_InitStatus == 3) {
            GrayNcommon::GrayN_ConsoleLog("初始化失败，但读取默认配置文件成功！");

            p_GrayN_InitAsyn_CallBack->GrayNstartAsyn_CallBack(GrayNinitCheck::GrayN_NotifyRegisterLogin, NULL);
            return;
        } else if (GrayNSDK::m_GrayN_SDK_InitStatus == 4) {
            GrayNcommon::GrayN_ConsoleLog("初始化完成，并且要更新！");

            //　初始化成功，界面的显示在OPInit中调用
            return;
        } else if (GrayNSDK::m_GrayN_SDK_InitStatus == 5) {
            //　初始化成功，界面的显示在OPInit中调用
            return;
        } else if (GrayNSDK::m_GrayN_SDK_InitStatus == -1) {
            GrayNcommon::GrayN_ConsoleLog("初始化失败，且读取默认配置文件也失败！");

            if (count < 0) {
                //这个处理主要是为了防止刚调用登录就碰到初始化失败，默认会在内部重新初始化一下
                GrayNSDK::m_GrayN_SDK_InitStatus = -2;
                continue;
            }
            p_GrayN_InitAsyn_CallBack->GrayNstartAsyn_CallBack(GrayNinitCheck::GrayN_NotifyLoginFail, NULL);
            return;
        } else if (GrayNSDK::m_GrayN_SDK_InitStatus == -2) {
            //当初始化失败后，通过登录回调通知失败，再次点击登录时，会重新初始化
            GrayNSDK::m_GrayN_SDK_InitStatus = 0;
            GrayN_SDK_Init::GetInstance().GrayN_GetInitInfo();
            sleep(5);
        }
        count++;
    }
}

void GrayNinitCheck::GrayN_NotifyLoginFail(void* args)
{
    GrayNSDK::m_GrayN_SDK_InitStatus = -2;   //易忽略
    GrayNSDK::GrayN_SDK_CallBackLogin(false, GrayN_JSON_NOTINIT_ERROR);
}

void GrayNinitCheck::GrayN_NotifyRegisterLogin(void* args)
{
    OPGameSDK::GetInstance().RegisterLogin();
}
