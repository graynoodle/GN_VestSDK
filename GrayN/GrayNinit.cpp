//#import "GrayN_SDK_Init.h"

#import "OPGameSDK.h"
#import "GrayNlogCenter.h"
#import "GrayN_UserHeart.h"
#import "GrayN_ErrorLog_GrayN.h"
#import "GrayNpayCenter.h"
#import "GrayNchannel.h"
#import "GrayN_Base64_GrayN.h"
#import "GrayN_Offical.h"
#import "GrayNconfig.h"
#import "GrayN_Des_GrayN.h"
#import "GrayNchannel.h"
#import "GrayNSDK.h"
#import "GrayN_LoadingUI.h"
#import "GrayNcommon.h"
#import <dispatch/dispatch.h>
#import "GrayNinit.h"
GrayNusing_NameSpace;

GrayN_SDK_Init::GrayN_SDK_Init()
{
//    p_GrayN_Init_Https = new GrayN_Http_GrayN();
    p_GrayN_Init_Https = new GrayN_Https_GrayN();

    p_GrayN_Init_Https->GrayN_Http_Set_Listener(this);
    p_GrayN_InitIsInUse = false;
    p_GrayN_InitIsInitFinished = false;
    p_GrayN_InitIsInit = false;
    p_GrayN_Init_DecodeData = "";
    p_GrayN_IsClickLogin = false;
}

GrayN_SDK_Init::~GrayN_SDK_Init()
{
    if (p_GrayN_Init_Https) {
        delete p_GrayN_Init_Https;
        p_GrayN_Init_Https = NULL;
    }
}

void GrayN_SDK_Init::GrayNrun(void *p)
{
    //获取网络类型
    GrayNcommon::GrayNcheckNetworkType();
    
    //p_GrayN_InitError
    //1     初始化成功，并不更新
    //2     初始化成功，但需要更新
    //-1    初始化失败，3次后读取默认的配置文件
    //-2    初始化成功，但更新失败
    p_GrayN_InitRequestCount++;
    if (p_GrayN_InitError == 1) {
        //初始化成功，并不更新
        //cout<<"初始化成功，并且不更新..."<<endl;
        GrayNSDK::m_GrayN_SDK_InitStatus = 1;
        p_GrayN_InitIsInUse = false;
        return;
    } else if (p_GrayN_InitError == 2) {
        //初始化成功，且需要更新
        //cout<<"初始化成功，且需要更新..."<<endl;
        GrayNSDK::m_GrayN_SDK_InitStatus = 4;
        p_GrayN_InitIsInUse = false;

        return;
    }
    if (p_GrayN_InitRequestCount > 3) {
        // 初始化3次就显示loading
        GrayNcommon::m_GrayN_ShowLoading = true;
        if (p_GrayN_InitError == -1) {
            p_GrayN_InitIsInUse = false;
            // 初始化失败，读取默认配置文件也失败
            // cout<<"初始化失败，读取默认配置文件也失败..."<<endl;
            GrayNSDK::m_GrayN_SDK_InitStatus = -1;
            // 注意这里，只有初始化完全失败的时候再设置为false，初始化成功就没有必要再初始化
            return;
        } else if (p_GrayN_InitError == -2) {
            // 初始化成功，但更新失败
            GrayNcommon::GrayN_ConsoleLog("初始化成功，但更新失败...");
            GrayNSDK::m_GrayN_SDK_InitStatus = 2;
            return;
        }
    }
    
    if (p_GrayN_InitRequestCount > 1) {
        // 2014-10-29  根据反馈的日志进行优化，第二次请求开始先等待2s
        sleep(2);
    }
    
    if (p_GrayN_Init_HttpType == k_GrayN_Init) {
        GrayN_InitConnectNetwork(k_GrayN_Init, GrayNcommon::m_GrayN_SDK_Init_Url.c_str(), p_GrayN_InitBody);
        GrayN_LoadingUI::GetInstance().GrayN_ShowWaitMainThread(GrayNcommon::GrayNcommonGetLocalLang(GrayN_InitString));
    } else if (p_GrayN_Init_HttpType == k_GrayN_Update) {
        GrayN_InitConnectNetwork(k_GrayN_Update, GrayNSDK::m_GrayN_SDK_UserCenterEntryUrl.c_str(), p_GrayN_UpdateBody);
    }
}
#pragma mark- Init
string GrayN_SDK_Init::GrayN_CreateInitInfo()
{
    GrayN_JSON::Value common;
    common["service"] = GrayN_JSON::Value(GrayNinitInterface);
    common["pCode"] = GrayN_JSON::Value(GrayNcommon::m_GrayN_P_Code);
    common["netSourceInfo"] = GrayN_JSON::Value(GrayNcommon::GrayNgetNetSourceInfo());
    common["netSource"] = GrayN_JSON::Value("1");
//    common["version"] = GrayN_JSON::Value("2.0");

    // 1：自有用户
    // 2：其它渠道用户
    common["userType"] = GrayN_JSON::Value("1");
    // 5.1.4 添加apkMd5
    common["apkMd5"] = GrayN_JSON::Value("");

    //初始化
    GrayN_JSON::FastWriter fast_writer;
    string tmp = fast_writer.write(common);
    p_GrayN_Init_DecodeData = tmp;
    string encryptStr = "";
    GrayN_Des_GrayN::GrayN_DesEncrypt(tmp, encryptStr);
    return encryptStr;
}
#pragma mark- GrayN_GetInitInfo
void GrayN_SDK_Init::GrayN_GetInitInfo()
{
    if (p_GrayN_InitIsInUse) {
        GrayNcommon::GrayN_ConsoleLog("内部初始化中...");
        return;
    }
    if (!p_GrayN_InitIsInit) {
        p_GrayN_InitIsInit = true;
        p_GrayN_InitBody = GrayN_CreateInitInfo();
    }
    
    p_GrayN_InitError = 0;
    p_GrayN_InitRequestCount = 0;
    p_GrayN_Init_HttpType = k_GrayN_Init;
    p_GrayN_InitIsInUse = true;
    GrayNstart();
}


bool GrayN_SDK_Init::GrayN_ParseInitInfo()
{
    GrayN_JSON::Value     json_object;
    if (!GrayN_ParseInitDesData(json_object)) {
        GrayNcommon::GrayN_ConsoleLog("登录初始化数据无法解析...");
        p_GrayN_InitErrorType = GrayN_USER_DES_LOGERROR;
        p_GrayN_InitError = -1;
        GrayN_SendErrorLog();
        return false;
    }
    
    if (json_object["errorCode"].empty()) {
        GrayNcommon::GrayN_ConsoleLog("登录初始化数据不完整...");

        p_GrayN_InitErrorType = GrayN_USER_JSON_LOGERROR;
        p_GrayN_InitError = -1;
        GrayN_SendErrorLog();
        return false;
    }
    GrayN_JSON::FastWriter parseWriter;
    string parseInfo = parseWriter.write(json_object);
    GrayNSDK::m_GrayN_SDK_InitJson = parseInfo;
    
    bool status = atoi(json_object["status"].asString().c_str());
    if (status)
    {
        GrayN_JSON::Value data = json_object["data"];
        // 会话ID
        GrayNcommon::m_GrayN_SessionId = data["sessionId"].asString();
        //        cout<<"sessionId"<<endl;
        //        cout<<GrayNSDK::m_GrayN_SessionId<<endl;
        GrayN_JSON::Value initInfo = data["initInfo"];
        if (initInfo["ucenterEntryUrl"].empty() ||
            initInfo["ucenterCoreUrl"].empty() ||
            initInfo["ucenterHeartbeatUrl"].empty() ||
            initInfo["heartBeatInterval"].empty()||
            initInfo["bcenterUrl"].empty() ||
            initInfo["statisUrl"].empty() ||
            initInfo["sdkPageRouteInfos"].empty() ||
            initInfo["sdkPageUrl"].empty())
        {
            GrayNcommon::GrayN_ConsoleLog("初始化数据不完整，可能是服务器未配置...");
            // 发送错误日志
            p_GrayN_InitErrorType = GrayN_USER_JSON_LOGERROR;
            p_GrayN_InitError = -1;
            GrayN_SendErrorLog();
            return false;
        }
        string sdkPageUrl = initInfo["sdkPageUrl"].asString();
        GrayNSDK::m_GrayN_SDK_PageUrl = sdkPageUrl;
        GrayNcommon::GrayNstringReplace(sdkPageUrl, "http://", "https://");

        string sdkPageRouteInfos = initInfo["sdkPageRouteInfos"].asString();
        string delims = "|"; //定义分割数组，可以定义多个分隔符，如" ,./r"等
        vector<string> splitStrs; //把分割后的字符串存在vector里面
        GrayNcommon::GrayNsplitString(sdkPageUrl, sdkPageRouteInfos,delims, splitStrs); //调用自定义的分割函数
        //        //显示分割后的字符串数组(用vector存储)
        //        vector<string>::iterator iter;
        //        for (iter = splitStrs.begin(); iter != splitStrs.end(); ++iter) {
        //            cout<< *iter << endl;
        //        }
        // 登录界面路由
        GrayNSDK::m_GrayN_SDK_LoginUrl.clear();
        GrayNSDK::m_GrayN_SDK_LoginUrl.append(splitStrs.at(0));
        // 切换账号路由 // 切换账户UI页
        GrayNSDK::m_GrayN_SDK_ChangeLoginUrl.clear();
        GrayNSDK::m_GrayN_SDK_ChangeLoginUrl.append(splitStrs.at(1));
        // 游客自动登录升级正式账号路由 // 游客自动登录后进入游客升级账户提示UI页
        GrayNSDK::m_GrayN_SDK_TourAutoLoginUpgradeUrl.clear();
        GrayNSDK::m_GrayN_SDK_TourAutoLoginUpgradeUrl.append(splitStrs.at(2));
        // 正式账号自动登录绑定手机路由 // 正式账号自动登录后需要强绑手机UI页
        GrayNSDK::m_GrayN_SDK_OfficalAutoLoginBindMobileUrl.clear();
        GrayNSDK::m_GrayN_SDK_OfficalAutoLoginBindMobileUrl.append(splitStrs.at(3));
        // 登录前置提示路由 // 登录前置提示UI页
        GrayNSDK::m_GrayN_SDK_NoticeUrl.clear();
        GrayNSDK::m_GrayN_SDK_NoticeUrl.append(splitStrs.at(4));
        // 支付界面路由 // 发起支付后的页面UI
        GrayNSDK::m_GrayN_SDK_PayUrl.clear();
        GrayNSDK::m_GrayN_SDK_PayUrl.append(splitStrs.at(5));
        // 用户中心个人中心路由 // 悬浮框页面UI
        GrayNSDK::m_GrayN_SDK_PersonalCenterUrl.clear();
        GrayNSDK::m_GrayN_SDK_PersonalCenterUrl.append(splitStrs.at(6));
        // 客服中心路由 // 独立客服问题页面UI
        GrayNSDK::m_GrayN_SDK_CustomerUrl.clear();
        GrayNSDK::m_GrayN_SDK_CustomerUrl.append(splitStrs.at(7));
        // 身份认证路由
        GrayNSDK::m_GrayN_SDK_IdentityAuthUrl.clear();
        GrayNSDK::m_GrayN_SDK_IdentityAuthUrl.append(splitStrs.at(8));
        // 支付时游客绑定官网账号路由
        GrayNSDK::m_GrayN_SDK_PayUrlUpgradeUrl.clear();
        GrayNSDK::m_GrayN_SDK_PayUrlUpgradeUrl.append(splitStrs.at(9));
        splitStrs.clear();
        
        // 支付时游客绑定开关
        GrayNSDK::m_GrayN_SDK_ForceTouristBindSwitch = atoi(initInfo["forceTouristBindSwitch"].asString().c_str());
        // 沙盒开关
        GrayNSDK::m_GrayN_SDK_SandBoxSwitch = atoi(initInfo["sandBoxSwitch"].asString().c_str());
        // 是否加载本地
        GrayN_Offical::GetInstance().m_GrayN_Offical_IsLocalRequest = GrayNSDK::m_GrayN_SDK_SandBoxSwitch;

        // 用户中心入口地址
        GrayNSDK::m_GrayN_SDK_UserCenterEntryUrl = initInfo["ucenterEntryUrl"].asString();
//        GrayNcommon::GrayNstringReplace(GrayNSDK::m_GrayN_SDK_UserCenterEntryUrl, "http://", "https://");

        //        GrayNSDK::m_GrayN_SDK_UserCenterEntryUrl = "http://authdev.gamebean.net/ucenter2.0/ucenter_entry3.0/entry";
        // 用户中心核心地址
        GrayNSDK::m_GrayN_SDK_UserCenterCoreUrl = initInfo["ucenterCoreUrl"].asString();
//        GrayNcommon::GrayNstringReplace(GrayNSDK::m_GrayN_SDK_UserCenterCoreUrl, "http://", "https://");
        
        //        GrayNSDK::m_GrayN_SDK_UserCenterCoreUrl = "http://authdev.gamebean.net/ucenter2.0/ucenter_core3.0/core";
        
        // 设置心跳地址及时间
        GrayN_UserHeart::m_GrayN_UserHeart_Url = initInfo["ucenterHeartbeatUrl"].asString();
        // 心跳地址
        string time = initInfo["heartBeatInterval"].asString();
        GrayN_UserHeart::m_GrayN_UserHeart_BeatingTime = atoi(time.c_str());
        GrayN_UserHeart::GrayN_UserHeart_SetListener(&GrayN_UserCenter::GetInstance());
        
        // 计费中心地址
        GrayNSDK::m_GrayN_SDK_BillingDomainName = initInfo["bcenterUrl"].asString();
//        GrayNSDK::m_GrayN_SDK_BillingDomainName = "http://223.202.94.183:8081/billingcenter2.0";
//        GrayNSDK::m_GrayN_SDK_BillingDomainName = "http://pay.0708.com/billingcenter2.0";
        
//        GrayNcommon::GrayNstringReplace(GrayNSDK::m_GrayN_SDK_BillingDomainName, "http://", "https://");

        GrayNSDK::m_GrayN_SDK_BillingUrl = GrayNSDK::m_GrayN_SDK_BillingDomainName;
        GrayNSDK::m_GrayN_SDK_BillingUrl.append(GrayNpayCenterRoute);
        // 统计地址
        GrayNcommon::m_GrayN_StatisticalUrl = initInfo["statisUrl"].asString();
        // 错误日志地址
        GrayNSDK::m_GrayN_SDK_AppErrorUrl = GrayNcommon::m_GrayN_StatisticalUrl;
        GrayNSDK::m_GrayN_SDK_AppErrorUrl.append(GrayNappstoreLogRoute);
        /*5.2.5 */
        GrayNcommon::GrayNsetLocal_StatisticalUrl(GrayNcommon::m_GrayN_StatisticalUrl);

        // SDK日志开关
        GrayNSDK::m_GrayN_SDK_LogSwitch = atoi(initInfo["sdkLogSwitch"].asString().c_str());
        // 计费日志开关
        GrayNSDK::m_GrayN_SDK_ChargeLogSwitch = atoi(initInfo["chargeLogSwitch"].asString().c_str());
        // 协议开关
        GrayNSDK::m_GrayN_SDK_ProtocolSwitch = atoi(initInfo["protocolSwitch"].asString().c_str());
        // appstore广告开关
        GrayNSDK::m_GrayN_SDK_StoreAdSwitch = atoi(initInfo["advertismentSwitch"].asString().c_str());
        /*5.1.9 绑定官网账号开关*/
        GrayNSDK::m_GrayN_SDK_BindOfficialUserSwitch = atoi(initInfo["bindOfficalUserSwitch"].asString().c_str());
//        GrayNSDK::m_GrayN_SDK_BindOfficialUserSwitch = true;
        // GSC前端地址
        GrayNSDK::m_GrayN_SDK_GscFrontUrl = initInfo["gscFrontUrl"].asString();
        GrayNcommon::GrayNstringReplace(GrayNSDK::m_GrayN_SDK_GscFrontUrl, "http://", "https://");
        // 推送地址
//        GrayNcommon::m_GrayN_PushServerUrl = initInfo["pushServerUrl"].asString();
        GrayNcommon::GrayNstringReplace(GrayNcommon::m_GrayN_PushServerUrl, "http://", "https://");
        
        // 限制初始化
        GrayN_JSON::Value limit = data["limit"];
        if (limit["isLimit"].empty() ||
            limit["limitDesc"].empty()) {
            GrayNcommon::GrayN_ConsoleLog("缺少初始化限制信息返回，可能是服务器未配置...");
            //发送错误日志
            p_GrayN_InitErrorType = GrayN_USER_JSON_LOGERROR;
            p_GrayN_InitError = -1;
            GrayN_SendErrorLog();
            return false;
        }
        
        GrayNSDK::m_GrayN_SDK_IsLimit = limit["isLimit"].asString();

        if (atoi(GrayNSDK::m_GrayN_SDK_IsLimit.c_str())) {
            string limitDesc = limit["limitDesc"].asString().c_str();
            GrayNSDK::m_GrayN_SDK_LimitDesc = limitDesc;
        }

        // 公告
        GrayN_JSON::Value notice = data["notice"];
        if (notice["switch"].empty() ||
            notice["content"].empty()) {
            GrayNcommon::GrayN_ConsoleLog("缺少初始化公告信息返回，可能是服务器未配置...");
            // 发送错误日志
            p_GrayN_InitErrorType = GrayN_USER_JSON_LOGERROR;
            p_GrayN_InitError = -1;
            GrayN_SendErrorLog();
            return false;
        }
        GrayNSDK::m_GrayN_SDK_NoticeSwitch = notice["switch"].asString();
        GrayNSDK::m_GrayN_SDK_NoticeContent = notice["content"].asString();
        
        // 激活码开关
        GrayN_JSON::Value activateCodeSwitch = data["activateCode"];
        if (activateCodeSwitch["switch"].empty() ||
            activateCodeSwitch["openActivateWin"].empty()) {
            GrayNcommon::GrayN_ConsoleLog("缺少初始化激活码开关信息返回，可能是服务器未配置...");

            //发送错误日志
            p_GrayN_InitErrorType = GrayN_USER_JSON_LOGERROR;
            p_GrayN_InitError = -1;
            GrayN_SendErrorLog();
            return false;
        }
        GrayNSDK::m_GrayN_SDK_ActivateCodeSwitch = activateCodeSwitch["switch"].asString();
        GrayNSDK::m_GrayN_SDK_OpenActivateWin = activateCodeSwitch["openActivateWin"].asString();
        
        // 身份认证
        GrayN_JSON::Value security = data["security"];
        if (security["identityAuth"].empty()) {
            GrayNcommon::GrayN_ConsoleLog("缺少实名认证信息，可能是服务器未配置...");
            //发送错误日志
            p_GrayN_InitErrorType = GrayN_USER_JSON_LOGERROR;
            p_GrayN_InitError = -1;
            GrayN_SendErrorLog();
            return false;
        }
        GrayNSDK::m_GrayN_SDK_IdentityAuth = security["identityAuth"].asString();
        GrayNSDK::m_GrayN_SDK_PayIdentityAuth = security["payIdentityAuth"].asString();
        
        //初始化成功后，开始日志初始化
        GrayN_SendInitLog();

        //更新
        GrayN_JSON::Value updateRoot;
        updateRoot["service"] = GrayN_JSON::Value(GrayNupdateInterface);
        updateRoot["sessionId"] = GrayN_JSON::Value(GrayNcommon::m_GrayN_SessionId);
        updateRoot["gameVersion"] = GrayN_JSON::Value(GrayNcommon::m_GrayN_GameVersion);
        
        GrayN_JSON::FastWriter fast_writer;
        string tmp = fast_writer.write(updateRoot);
        p_GrayN_Init_DecodeData = tmp;
        p_GrayN_UpdateBody = "";
        GrayN_Des_GrayN::GrayN_DesEncrypt(tmp, p_GrayN_UpdateBody);
        
        //#ifndef OP_USERCENTER
        //        //非官网暂时不加更新
        //        p_GrayN_InitError = 1;   //初始化成功
        //#endif
    } else {
        p_GrayN_InitErrorType = GrayN_USER_JSON_LOGERROR;
        GrayN_SendErrorLog();
        return false;
    }
    return true;
}
#pragma mark- GameUpdate
void GrayN_SDK_Init::GrayN_StartUpdate()
{
    p_GrayN_Init_HttpType = k_GrayN_Update;
    p_GrayN_InitRequestCount = 0;
    GrayNstart();
}
void GrayN_SDK_Init::GrayN_ParseGameUpdate()
{
    GrayN_JSON::Reader    json_reader;
    GrayN_JSON::Value     json_object;
    
    if (!GrayN_ParseInitDesData(json_object)) {
        GrayNcommon::GrayN_ConsoleLog(GrayN_ERROR_DATA_ERROR_STR);

        p_GrayN_InitError = -2;
        return;// json格式解析错
    }
    
    if (json_object["status"].empty() ||
        json_object["data"].empty() ||
        json_object["errorCode"].empty()) {
        GrayNcommon::GrayN_ConsoleLog(GrayN_ERROR_DATA_ERROR_STR);

        p_GrayN_InitError = -2;
        return;//json格式解析错
    }
    if (json_object["status"].asString() != "1") {
        GrayNcommon::GrayN_ConsoleLog(json_object["errorDesc"].asString().c_str());

        p_GrayN_InitError = -2;
        return;//json格式解析错
    }
    
    GrayN_JSON::Value data;
    data = json_object["data"];
    
    // 1:强制更新，2:非强制更新，3：不更新
    GrayNSDK::m_GrayN_SDK_UpdateType = data["code"].asString();
    p_GrayN_UpdateType = atoi(GrayNSDK::m_GrayN_SDK_UpdateType.c_str());
    if (p_GrayN_UpdateType == 3) {
        // 不更新，返回初始化成功
        GrayNcommon::GrayN_ConsoleLog("opCheckUpdate:NO");
        p_GrayN_InitError = 1;
    } else {
        // 更新
        GrayNcommon::GrayN_ConsoleLog("opCheckUpdate:YES");
//        mUpdataJson = data;
        p_GrayN_InitError = 2;
        
        GrayNSDK::m_GrayN_SDK_UpdateVersion = data["version"].asString();
        GrayNSDK::m_GrayN_SDK_UpdateDesc = data["description"].asString();
        GrayNSDK::m_GrayN_SDK_UpdateFileSize = data["fileSize"].asString();
        GrayNSDK::m_GrayN_SDK_UpdateUrl = data["url"].asString();
    }
    p_GrayN_InitIsInitFinished = true;

    
    GrayNchannel::GetInstance().GrayN_ChannelInitOver();
    
    return;
}
#pragma mark- RefreshSessionID
void GrayN_SDK_Init::GrayN_InitGetSessionId()
{
    if (p_GrayN_InitIsInUse) {
        GrayNcommon::GrayN_ConsoleLog("GetSessionId_inUse");
        return;
    }
    p_GrayN_InitIsInUse = true;
    p_GrayN_InitBody.clear();
    p_GrayN_InitBody = GrayN_CreateInitInfo();

    GrayN_InitConnectNetwork(k_GrayN_Get_SessionId, GrayNcommon::m_GrayN_SDK_Init_Url.c_str(), p_GrayN_InitBody);
    GrayN_LoadingUI::GetInstance().GrayN_ShowWaitMainThread(GrayNcommon::GrayNcommonGetLocalLang(GrayN_WaitingString));
}
void GrayN_SDK_Init::GrayN_ParseInitGetSessionId()
{
    GrayN_LoadingUI::GetInstance().GrayN_CloseWaitMainThread();
    GrayN_JSON::Value     json_object;
    if (!GrayN_ParseInitDesData(json_object)) {
        GrayNcommon::GrayN_ConsoleLog("登录初始化数据无法解析！");

        p_GrayN_InitErrorType = GrayN_USER_DES_LOGERROR;
        p_GrayN_InitError = -1;
        GrayN_SendErrorLog();
        return;
    }
    
    if (json_object["errorCode"].empty()) {
        GrayNcommon::GrayN_ConsoleLog("登录初始化数据不完整！");

        p_GrayN_InitErrorType = GrayN_USER_JSON_LOGERROR;
        p_GrayN_InitError = -1;
        GrayN_SendErrorLog();
        return;
    }
    GrayN_JSON::FastWriter parseWriter;
    string parseInfo = parseWriter.write(json_object);

    bool status = atoi(json_object["status"].asString().c_str());
    if (status) {
        GrayN_JSON::Value data = json_object["data"];
        // 会话ID
        GrayNcommon::m_GrayN_SessionId = data["sessionId"].asString();
        GrayN_JSON::Value returnJson;
        returnJson["sessionId"] = GrayNcommon::m_GrayN_SessionId;
        string returnStr = parseWriter.write(returnJson);
//        cout<<returnStr<<endl;
        // 已登录（游戏内）需触发登录再返sessionId，否则sessionId查不到账户信息
        if (GrayNchannel::GetInstance().GrayN_ChannelIsLogin()) {
            GrayN_Offical::GetInstance().GrayN_Offical_LoginGetSessionIdResponse();
        } else {
            GrayN_Offical::GetInstance().GrayN_Offical_GetSessionIdResponse(returnStr);
        }
    } else {
        GrayN_Offical::GetInstance().GrayN_Offical_GetSessionIdResponse("false");
    }
}

#pragma mark - GrayN_Http_GrayN
void GrayN_SDK_Init::GrayN_InitConnectNetwork(int httpType, const char* url, string data)//网络连接
{
    //请求时间
    p_GrayN_InitRequestTime.clear();
    p_GrayN_InitRequestTime = GrayNcommon::GrayNgetCurrent_DateAndTime();
    
    if (httpType == k_GrayN_Init) {
        p_GrayN_InitLogType = "init";
    } else if (httpType == k_GrayN_Update){
        p_GrayN_InitLogType = "update";
    } else if (httpType == k_GrayN_Get_SessionId) {
        p_GrayN_InitLogType = "getSessionId";
    }
    
    p_GrayN_Init_HttpsBuffer.clear();
    p_GrayN_Init_HttpType = httpType;
//    p_GrayN_Init_Https->GrayN_Http_Set_ContentType("application/x-www-form-urlencoded");
//    p_GrayN_Init_Https->GrayN_Http_Post_ByUrl(url, data.c_str(), (int)data.length());
    
    string httpsUrl = url;
//    GrayNcommon::GrayNstringReplace(httpsUrl, "http://", "https://");
    p_GrayN_Init_Https->GrayN_Https_Post(httpsUrl, data);
    
    GrayNcommon::GrayN_DebugLog("opInitHttpType:%s\nopInitHttpUrls:%s\nopInitHttpData:", p_GrayN_InitLogType.c_str(), httpsUrl.c_str());
    GrayNcommon::GrayN_DebugLog(p_GrayN_Init_DecodeData.c_str());

    
    p_GrayN_Init_DecodeData.clear();

}
bool GrayN_SDK_Init::GrayN_ParseInitDesData(GrayN_JSON::Value &json_object)
{
    string decodeStr = "";
    GrayN_Des_GrayN::GrayN_DesDecrypt(p_GrayN_Init_HttpsBuffer, decodeStr);
    
    GrayN_JSON::Reader    json_reader;
    if (decodeStr.length() == 0 || !json_reader.parse(decodeStr, json_object)) {
        //解密失败
        GrayNcommon::GrayN_ConsoleLog("数据异常，解密失败或无法解析！");

        p_GrayN_InitDecryptData.clear();
        p_GrayN_InitDecryptData = p_GrayN_Init_HttpsBuffer;
        GrayNcommon::GrayN_DebugLog("opInitHttpError:%s", p_GrayN_Init_HttpsBuffer.c_str());

        return false;
    }

    GrayNcommon::GrayN_DebugLog("opInitHttpType:%s\nopInitHttpRecv:", p_GrayN_InitLogType.c_str());
    GrayNcommon::GrayN_DebugLog(decodeStr.c_str());

    p_GrayN_InitDecryptData.clear();
    p_GrayN_InitDecryptData = decodeStr;
    
    return true;
}
void GrayN_SDK_Init::GrayN_On_HttpError(GrayN_Http_GrayN* client, GrayN_HttpErrorCode code)
{
    
    p_GrayN_InitHttpErrorCode = code;
    if (p_GrayN_InitHttpErrorCode == k_GrayN_OPEN_ERROR) {
        p_GrayN_InitErrorType = "OPEN_ERROR";
    } else if (p_GrayN_InitHttpErrorCode == k_GrayN_SEND_HEAD_ERROR) {
        p_GrayN_InitErrorType = "SEND_HEAD_ERROR";
    } else if (p_GrayN_InitHttpErrorCode == k_GrayN_SEND_POST_ERROR) {
        p_GrayN_InitErrorType = "SEND_POST_ERROR";
    } else if (p_GrayN_InitHttpErrorCode == k_GrayN_RECV_HEAD_ERROR) {
        p_GrayN_InitErrorType = "RECV_HEAD_ERROR";
    } else if (p_GrayN_InitHttpErrorCode == k_GrayN_RECV_DATA_ERROR) {
        p_GrayN_InitErrorType = "RECV_DATA_ERROR";
    } else if (p_GrayN_InitHttpErrorCode == k_GrayN_DISCONNECTED_ERROR) {
        p_GrayN_InitErrorType = "DISCONNECTED_ERROR";
    }
    GrayNcommon::GrayN_DebugLog("socketError:%s   %s=%s", p_GrayN_InitErrorType.c_str(), p_GrayN_Init_Https->GrayN_Http_Get_SocketError(), p_GrayN_Init_HttpsBuffer.c_str());
    p_GrayN_InitDecryptData = p_GrayN_Init_HttpsBuffer;
    GrayN_SendErrorLog();
    
    if (p_GrayN_Init_HttpType == k_GrayN_Init) {
        static bool isCallback = false;
        /*5.1.8 联网三次失败只返一次初始化成功*/
        if (isCallback == false) {
            if (p_GrayN_InitRequestCount == 3) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    GrayNSDK::GrayN_SDK_CallBackInit(true, "联网失败，但SDK初始化成功");
                });
                isCallback = true;
            }
        }
        
        p_GrayN_InitError = -1;     //初始化失败
    } else if (p_GrayN_Init_HttpType == k_GrayN_Get_SessionId) {
        //获取失败
        GrayN_LoadingUI::GetInstance().GrayN_CloseWaitMainThread();

        p_GrayN_InitIsInUse = false;
        GrayN_Offical::GetInstance().GrayN_Offical_GetSessionIdResponse("false");
        return;
    } else {
        p_GrayN_InitError = -2;     //初始化成功，但更新失败
    }
    GrayNstart();
}

void GrayN_SDK_Init::GrayN_On_HttpEvent(GrayN_Http_GrayN* client, GrayN_HttpEventCode code)
{
    if(code == k_GrayN_SEND_HEAD){
        p_GrayN_Init_HttpsBuffer.clear();
    }else if(code == k_GrayN_COMPLETE)
    {
        if (p_GrayN_Init_HttpType == k_GrayN_Init) {
            if (GrayN_ParseInitInfo()) {
                GrayN_StartUpdate();
                return;
            }
            // 解析失败重连
            GrayNstart();
        } else if (p_GrayN_Init_HttpType == k_GrayN_Get_SessionId) {
            //获取成功
            p_GrayN_InitIsInUse = false;
            GrayN_ParseInitGetSessionId();
            return;
        } else {
            GrayN_ParseGameUpdate();
            GrayNstart();
        }
    }
}

void GrayN_SDK_Init::GrayN_On_HttpResponse(GrayN_Http_GrayN* client,int code,int context_length,int startPos,int endPos,int totalContext,const char* data)
{
    
}

void GrayN_SDK_Init::GrayN_On_Http_Data(GrayN_Http_GrayN* client,const char* data,int count)
{
#ifdef HTTPDEBUG
    GrayNcommon::GrayN_DebugLog("on http length=%d data=%s",count,data);
#endif
    p_GrayN_Init_HttpsBuffer.append(data,count);
}
#pragma mark- ErrorLog
void GrayN_SDK_Init::GrayN_SendErrorLog()
{
    //发送错误日志
    GrayN_ErrorLog_GrayN *errorLog = new GrayN_ErrorLog_GrayN();
    errorLog->GrayN_ErrorLog_SendLog(p_GrayN_InitLogType.c_str(), p_GrayN_InitRequestTime.c_str(), p_GrayN_InitErrorType.c_str(),
                             p_GrayN_Init_Https->GrayN_Http_Get_SocketError(), p_GrayN_Init_Https->GrayN_Http_Get_HttpCode(), p_GrayN_InitDecryptData.c_str());
}

void GrayN_SDK_Init::GrayN_SendInitLog()
{
    GrayN_Log_Device device;
    device.m_GrayN_Log_SDKinfo.m_GrayN_Log_DeviceGroupId = GrayNcommon::m_GrayN_DeviceGroupId;
    device.m_GrayN_Log_SDKinfo.m_GrayN_Log_LocaleId = GrayNcommon::m_GrayN_LocaleId;
    device.m_GrayN_Log_LauchServer.m_GrayN_Log_InitUrl = GrayNcommon::m_GrayN_StatisticalUrl;
    
    GrayNlogCenter::GetInstance().m_GrayN_Log_StatisticalUrl = GrayNcommon::m_GrayN_StatisticalUrl;
    GrayNlogCenter::GetInstance().GrayN_LogInit(device);
}
#pragma mark- Function
bool GrayN_SDK_Init::GrayN_GetInitStatus()
{
    return p_GrayN_InitIsInitFinished;
}
void GrayN_SDK_Init::GrayN_SetInitStatus(bool status)
{
    p_GrayN_InitIsInitFinished = status;
}
