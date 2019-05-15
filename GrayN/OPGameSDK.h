//
//  OPGameSDK.h
//
//  Created by lolo2513 on 16-08-04.
//
//

#import  <objc/objc.h>
#import <iostream>

using namespace std;

enum OPGameType
{
    kGameRegister=0,
    kGameLogin,
    kGameRoleUpgrade, // 角色升级
    kUpdateRoleName,
    kUpdateRoleVipLevel,
    kGameCreateRole,
    kGameSelectServer,
    kGameEnterGame,
    kGameExitGame
};

enum OPScreenOrientation
{
    OPOrientationLandscapeRight = 1,
    OPOrientationLandscapeLeft,
    OPOrientationPortrait,
    OPOrientationPortraitUpsideDown,
};

class PurchaseListener
{
public:
    // 返回购买结果
    virtual void OnPurchaseResult(bool result, const char* jsonStr){}
    // 返回礼包码兑换结果
    virtual void OnGamecodeResult(bool result, const char* jsonStr){}
};
class OPGameInfo
{
public:
    OPGameInfo(){
        mGame_RoleName = "-";
        mGame_RoleId = "-";
        mGame_ServerId = "-";
        mGame_ServerName = "-";
        mGame_RoleLevel= "-";
        mGame_RoleVipLevel = "-";
        mGame_OriginalRoleName = "-";
        mGame_OriginalRoleLevel = "-";
        mGame_OriginalRoleVipLevel = "-";
    }
    ~OPGameInfo(){}
    
    std::string mGame_RoleName;             //游戏角色名称(必填)
    std::string mGame_RoleId;               //游戏角色id(必填)
    std::string mGame_ServerId;             //游戏服务id（必填）
    std::string mGame_ServerName;           //游戏服名称（必填）
    std::string mGame_RoleLevel;            //游戏角色等级（可选）
    std::string mGame_RoleVipLevel;         //游戏角色vip等级（可选）
    std::string mGame_OriginalRoleName;     //游戏原始角色名称（可选）
    std::string mGame_OriginalRoleLevel;    //游戏原始角色等级（可选）
    std::string mGame_OriginalRoleVipLevel; //游戏原始角色vip等级（可选）
};

class OPPurchaseParam
{
public:
    OPPurchaseParam(){
        mPrice = "";
        mCurrencyType = "";
        mPropName = "";
        mPropId = "";
        mPropDescribe = "";
        mPropNum = "";
        mDeleverUrl = "";
        mExtendParams = "";
        mGameRoleLevel = "";
        mGameRoleVipLevel = "";
    }
    
    ~OPPurchaseParam(){}
    
    std::string mPrice;                     //道具价格(必填)，例如，100代表1元，以分为最小单位
    std::string mCurrencyType;              //货币类型(必填)，例如，1：人民币
    std::string mPropName;                  //商品名称(必填)
    std::string mPropId;                    //商品id(必填)
    std::string mPropDescribe;              //商品描述（可选）
    std::string mPropNum;                   //商品数量(必填)
    std::string mDeleverUrl;                //发货地址（可选）
    std::string mExtendParams;              //自定义参数（可选）
    std::string mGameRoleLevel;            //游戏角色等级（可选）
    std::string mGameRoleVipLevel;         //游戏角色vip等级（可选）
};

namespace ourpalmpay {
    class OPGameSDK
    {
    private:
        OPGameSDK();
        ~OPGameSDK();
        
    public:
        inline static OPGameSDK& GetInstance()
        {
            static OPGameSDK opGameSDK;
            return opGameSDK;
        }
        
    public:
        
        // 获取可用接口信息
        const char*  GetEnableInterface();
        
        // 初始化（含自动调用更新接口）
        void Init(void* controller);
        void InitCallBack(void (* pf)(bool result,const char* jsonStr));
        void CallBackInit(bool result,const char* jsonStr) { (* pfuncInit)(result,jsonStr); }
        
        // 注册登录
        void RegisterLogin();
        void RegisterLoginCallBack(void (* pf)(bool result,const char* jsonStr));
        void CallBackLogin(bool result,const char* jsonStr) { (* pfuncLogin)(result,jsonStr); }
        
        
        // 登录状态
        bool IsLogin();
        
        // 获取用户Id
        string GetUserId();
        // 获取token
        string GetTokenId();
        // 获取sdk版本号
        string GetSDKVersion();
        
        // 设置游戏角色信息
        void SetGameLoginInfo(OPGameInfo opGameInfo,OPGameType opGameType);
        
        // 注销
        void LogOut();
        void RegisterLogoutCallBack(void (* pf)(bool result,const char* jsonStr));
        void CallBackLogout(bool result,const char* jsonStr) { (* pfuncLogout)(result,jsonStr); }
        
        // 发送日志
        void SendLog(const char* logID, const char* logKey ,const char* logValJson);
        // 设置特殊属性map
        void SetSpecKey(const char* specKeyJson);
        
        // 计费（异步方式）
        void SetListener(PurchaseListener* listener);
        
        // 购买
        void Purchase(OPPurchaseParam params);
        
        // 进入平台中心
        void EnterPlatform();
        // 用户反馈
        void UserFeedback();
        
        void CodeScanner();
        
        
        // 启动接口
        bool ApplicationDidFinishLaunchingWithOptions(void *application,void *launchOptions);
        
        // 界面适配接口
        bool ApplicationSupportedInterfaceOrientationsForWindow();
        unsigned int ApplicationSupportedInterfaceOrientationsForWindow(void *application,void *window);
        bool ShouldAutoRotate();
        void ApplicationWillEnterForeground(id application);
        
        // 礼包码接口
        void ExchangeGameCode(const char *gameCode,const char *deliverUrl,const char *extendParams);
        
        // SDK信息
        const char*  GetChannelInfo();
        
        //切换账号
        void SwitchAccount();
        
        bool HandleOpenURL(void* url);
        void HandleOpenURL(void* url, void* application);
        bool HandleOpenURL(void* application,void* url,void* sourceApplication,void* annotation);

        //业务id
        string GetServiceId();
        //推广渠道id
        string GetChannelId();
        //推广渠道Name
        string GetChannelName();
        //机型组id
        string GetDeviceGroupId();
        //地区id
        string GetLocaleId();
        
        //扩展接口
        void ChannelSpreads(const char* FuncName,void* func = NULL,...);
        
        //打开带导航栏的webview
        void OpenWebviewWithNavbar(string url);
        //第三方统计
        void LogEvent(const char* ourpalm_event_key, const char* event_paras = NULL);

    private:
        void (* pfuncInit)(bool result,const char * jsonStr);
        void (* pfuncLogin)(bool result,const char * jsonStr);
        void (* pfuncLogout)(bool result,const char * jsonStr);

    };
}

