//
//  GrayN_LoadingUI.h
//
//  Created by gamebean on 13-1-18.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import  <objc/objc.h>

#import "GrayNconfig.h"
GrayN_NameSpace_Start

class GrayN_LoadingUI
{
public:
    GrayN_LoadingUI();
    ~GrayN_LoadingUI();
public:
    static GrayN_LoadingUI& GetInstance(){
        static GrayN_LoadingUI ui;
        return ui;
    }

    void GrayN_ResetKeyWindow();
    
    void GrayN_SetUserInteractionEnabled(bool enable);
    void GrayN_ShowWait(const char* tip);
    void GrayN_ShowWaitMainThread(const char* tip);

    void GrayN_CloseWait();
    void GrayN_CloseWaitMainThread();

    void GrayN_ChangeWait(const char* tip);
    void GrayN_ShowMsgBox(const char* title, const char* body, int tag, int btnCnt);
    
    void GrayN_ShowGameWait(const char *tip);
    void GrayN_CloseGameWait();
    
    void GrayN_SetLoaingUIEnabled(bool enable);
    
    id p_GrayN_LoadingInstance;
    
    void* p_GrayN_LoadingView;
    void* p_GrayN_GameLoadingView;
    void* p_GrayN_GameView;
    void* p_GrayN_GameViewController;

    
private:
    bool p_GrayN_LoadingEnabled;
};

GrayN_NameSpace_End

