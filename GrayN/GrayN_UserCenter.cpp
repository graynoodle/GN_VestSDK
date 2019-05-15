#import "GrayN_UserCenter.h"
#import "OPGameSDK.h"
#import "GrayN_UserHeart.h"
#import "GrayN_ErrorLog_GrayN.h"
#import "GrayN_Offical.h"
#import "GrayNchannel.h"
#import "GrayN_Des_GrayN.h"

GrayNusing_NameSpace;

GrayN_UserCenter::GrayN_UserCenter()
{
    p_GrayN_UserCenter_Https = new GrayN_Https_GrayN();

    p_GrayN_UserCenter_Https->GrayN_Http_Set_Listener(this);
    
    p_GrayN_UserCenter_Asyn_CallBack = new GrayNasyn_CallBack();
    p_GrayN_UserCenter_UserHeart = NULL;
    p_GrayN_UserCenterObject = NULL;
    m_GrayN_UserCenter_IsAutoLogin = true;
}

GrayN_UserCenter::~GrayN_UserCenter()
{
    if (p_GrayN_UserCenter_Https) {
        delete p_GrayN_UserCenter_Https;
        p_GrayN_UserCenter_Https = NULL;
    }
    if (p_GrayN_UserCenter_Asyn_CallBack) {
        delete p_GrayN_UserCenter_Asyn_CallBack;
        p_GrayN_UserCenter_Asyn_CallBack = NULL;
    }
    if (p_GrayN_UserCenter_UserHeart) {
        p_GrayN_UserCenter_UserHeart->GrayN_UserHeart_StopHeartBeat();          //用此方式释放
    }
}

#pragma mark- 登录
void GrayN_UserCenter::GrayN_UserCenter_SpeedyLogin(bool isAutoLogin, bool getSessionId)
{
    m_GrayN_UserCenter_IsAutoLogin = isAutoLogin;
    GrayN_JSON::Value tmpJson;
    tmpJson["service"] = GrayN_JSON::Value(GrayNspeedyLoginInterface);
    tmpJson["sessionId"] = GrayN_JSON::Value(GrayNcommon::m_GrayN_SessionId);
    tmpJson["deviceId"] = GrayN_JSON::Value(GrayNcommon::m_GrayN_IDFA);
    tmpJson["activateTokenId"] = GrayN_JSON::Value(GrayNSDK::m_GrayN_SDK_ActivateTokenId);
    GrayN_JSON::FastWriter fast_writer;
    string tmp = fast_writer.write(tmpJson);
    p_GrayN_UserCenter_DecodeData = tmp;

    GrayNcommon::GrayN_DebugLog("speedyLogin = %s",tmp.c_str());
    
    GrayN_Des_GrayN::GrayN_DesEncrypt(tmp, tmp);

    if (getSessionId) {
        GrayN_UserCenter::GrayN_UserCenter_ConnectNetwork(GrayN_UserCenter_Get_SessionId, GrayNSDK::m_GrayN_SDK_UserCenterEntryUrl.c_str(), tmp);
    } else {
        GrayN_UserCenter::GrayN_UserCenter_ConnectNetwork(GrayN_UserCenter_Login, GrayNSDK::m_GrayN_SDK_UserCenterEntryUrl.c_str(), tmp);
    }
}

void GrayN_UserCenter::GrayN_UserCenter_CommonLogin(string userName, string userPwd, bool isAutoLogin, bool getSessionId)
{
    m_GrayN_UserCenter_IsAutoLogin = isAutoLogin;
    GrayN_JSON::Value tmpJson;
    tmpJson["service"] = GrayN_JSON::Value(GrayNcommonLoginInterface);
    tmpJson["sessionId"] = GrayN_JSON::Value(GrayNcommon::m_GrayN_SessionId);
    tmpJson["loginName"] = GrayN_JSON::Value(userName);
    /* 如果密码为空
     * 1.任意传入一个密码避免异常请求
     * 2.用户中心会返回密码错误提示
     */
    string password = userPwd;
    if (password == "") {
        password = "123456";
    }
    tmpJson["userPwd"] = GrayN_JSON::Value(password);
    tmpJson["activateTokenId"] = GrayN_JSON::Value(GrayNSDK::m_GrayN_SDK_ActivateTokenId);
    GrayN_JSON::FastWriter fast_writer;
    string tmp = fast_writer.write(tmpJson);
    p_GrayN_UserCenter_DecodeData = tmp;
    
    GrayN_Des_GrayN::GrayN_DesEncrypt(tmp, tmp);
    
    if (getSessionId) {
        GrayN_UserCenter::GrayN_UserCenter_ConnectNetwork(GrayN_UserCenter_Get_SessionId, GrayNSDK::m_GrayN_SDK_UserCenterEntryUrl.c_str(), tmp);
    } else {
        GrayN_UserCenter::GrayN_UserCenter_ConnectNetwork(GrayN_UserCenter_Login, GrayNSDK::m_GrayN_SDK_UserCenterEntryUrl.c_str(), tmp);
    }
}
#pragma mark- 登录解析
void GrayN_UserCenter::GrayN_UserCenter_ParseLoginInfo()
{
    GrayN_JSON::Value     json_object;
    
    if (!GrayN_UserCenter_ParseDesData(json_object)) {
        GrayNcommon::GrayN_ConsoleLog("登陆返回的数据无法解析！");
        GrayN_Offical::GetInstance().GrayN_Offical_ShowSwitchAccountView();
        return;
    }
    
//        cout<<"GrayN_UserCenter_ParseLoginInfo()"<<endl;
//        cout<<p_GrayN_UserCenter_DecryptData.c_str()<<endl;
    
    if (json_object["errorCode"].empty() ||
        json_object["errorDesc"].empty()) {
        GrayNcommon::GrayN_ConsoleLog("登陆返回的数据不完整！");
        //发送错误日志
        GrayN_ErrorLog_GrayN *errorLog = new GrayN_ErrorLog_GrayN();
        errorLog->GrayN_ErrorLog_SendLog(p_GrayN_UserCenter_LogType.c_str(), p_GrayN_UserCenter_RequestTime.c_str(), GrayN_USER_JSON_LOGERROR,
                                 p_GrayN_UserCenter_Https->GrayN_Http_Get_SocketError(),p_GrayN_UserCenter_Https->GrayN_Http_Get_HttpCode(), p_GrayN_UserCenter_DecryptData.c_str());
        GrayN_Offical::GetInstance().GrayN_Offical_ShowSwitchAccountView();
        return;
    }
    GrayN_Offical::GetInstance().m_GrayN_Offical_LoginData = json_object["data"];
    if (!m_GrayN_UserCenter_IsAutoLogin) {
        GrayN_JSON::Value responseJson;
        responseJson["data"] = json_object;
        responseJson["status"] = "0";
        GrayN_JSON::FastWriter writer;
        string response = writer.write(responseJson);
        GrayN_Offical::GetInstance().GrayN_Offical_UserInfoResponse(response);
        return;
    }
    
    string errorCode = json_object["errorCode"].asString();
    string desc = json_object["errorDesc"].asString();
    string status = json_object["status"].asString();
    
    GrayN_JSON::Value dataJson = json_object["data"];
    
    GrayNcommon::m_GrayN_Game_UserId = dataJson["userId"].asString();
    GrayNcommon::m_GrayN_Game_UserName  = dataJson["userName"].asString();
    GrayNcommon::m_GrayN_Game_PalmId  = dataJson["palmId"].asString();
    GrayNcommon::m_GrayN_Game_PhoneNum = dataJson["phone"].asString();

    if (atoi(status.c_str())) {
        // 保存用户信息
        GrayN_Offical::GetInstance().GrayN_Offical_UpdateUserInfo(dataJson);
        
        // 成功
        string loginType = dataJson["loginType"].asString();
        GrayNcommon::m_GrayN_LoginType = loginType;
        GrayNcommon::m_GrayN_CurrentUserType = dataJson["currentUserType"].asString();
        
        // 发送用户中心的注册登录日志
        GrayNSDK::GrayN_SDK_SendUserRegisterLoginLog();
        
        if (loginType == "speedyLogin" || loginType == "speedyRegister") {
            GrayN_Offical::GetInstance().GrayN_Offical_ShowUpgradeTipView();
            //            GrayN_Offical::GetInstance().GrayN_Offical_ShowWelcome("");
        } else {
            // 实名认证判断 0：未验证 1：验证中 2：验证成功 -1：验证失败
            GrayNSDK::m_GrayN_SDK_IdentityStatus = dataJson["identityAuth"]["status"].asString();
            
            string isNeedBindPhone = dataJson["bindPhone"]["isNeed"].asString();
            if (atoi(isNeedBindPhone.c_str()) && !GrayNSDK::m_GrayN_SDK_SandBoxSwitch) {
                GrayN_Offical::GetInstance().GrayN_Offical_ShowBindPhoneView();
                return;
            }
            
            
            // 验证身份 0:无需认证； 1：强制认证； 2：非强制认证;
            int identityType = atoi(GrayNSDK::m_GrayN_SDK_IdentityAuth.c_str());
            if ((identityType == 2 || identityType == 1) && (GrayNSDK::m_GrayN_SDK_IdentityStatus == "-1" || GrayNSDK::m_GrayN_SDK_IdentityStatus == "0") && !GrayNSDK::m_GrayN_SDK_SandBoxSwitch) {
                cout<<"ShowIdentityAuthentication="<<GrayNSDK::m_GrayN_SDK_IdentityAuth<<endl;
                GrayN_Offical::GetInstance().GrayN_Offical_ShowID_Authentication();
                return;
            }
            
            // 限制登录
            GrayN_JSON::Value limit = dataJson["limit"];
            int isLimit = atoi(limit["isLimit"].asString().c_str());
            string limitDesc = limit["limitDesc"].asString();
            if (isLimit && !GrayNSDK::m_GrayN_SDK_SandBoxSwitch) {
                GrayN_JSON::FastWriter fast_writer;
                string tmp = fast_writer.write(limit);
                GrayNcommon::GrayN_ConsoleLog(tmp.c_str());
                
                string desc = limit["limitDesc"].asString();
                GrayNchannel::GetInstance().GrayN_ChannelLogout();
                GrayN_LoadingUI::GetInstance().GrayN_ShowMsgBox(GrayNcommon::GrayNcommonGetLocalLang(GrayN_Title), desc.c_str(), 0, 1);
                GrayN_LoadingUI::GetInstance().GrayN_CloseWait();
                return;
            }
            
            GrayN_JSON::Value userInfo_json;
            userInfo_json["palmId"] = dataJson["palmId"].asString();
            userInfo_json["nickName"] = dataJson["nickName"].asString();
            
            GrayN_JSON::Value tmp_json;
            tmp_json["returnJson"] = userInfo_json;
            tmp_json["userId"] = dataJson["userId"].asString();
            
            // 手机号登录账号使用手机号作为用户名显示
            string::size_type idx = GrayNcommon::m_GrayN_CurrentUserType.find("phone");
            if ( idx !=string::npos) {
                tmp_json["userName"] = dataJson["phone"].asString();
            } else {
                tmp_json["userName"] = dataJson["userName"].asString();
            }
            tmp_json["tokenId"] = GrayNcommon::m_GrayN_SessionId;
            tmp_json["currentUserType"] = GrayNcommon::m_GrayN_CurrentUserType;
            /*5.2.3 返回服务器所有数据*/
            tmp_json["data"] = dataJson;

            GrayN_JSON::FastWriter fast_writer;
            string tmp = fast_writer.write(tmp_json);
            
            string currentUserType = dataJson["currentUserType"].asString();
            if (currentUserType == "thirdHidden") {
                string nickName;
                GrayN_Offical::GetInstance().GrayN_Offical_GetCurrentThirdHiddenNickName(GrayNcommon::m_GrayN_Game_UserId, nickName);
                GrayN_Offical::GetInstance().GrayN_Offical_ShowWelcome(nickName);
            } else if (currentUserType == "phone") {
                string bindPhone;
                bindPhone = dataJson["phone"].asString();
                GrayN_Offical::GetInstance().GrayN_Offical_ShowWelcome(bindPhone);
            } else {
                GrayN_Offical::GetInstance().GrayN_Offical_ShowWelcome(GrayNcommon::m_GrayN_Game_UserName);
            }
            GrayNSDK::GrayN_SDK_CallBackLogin(true, tmp.c_str());
        }
    } else {
        if (!m_GrayN_UserCenter_IsAutoLogin) {
            GrayN_JSON::Value responseJson;
            responseJson["data"] = json_object;
            responseJson["status"] = "1";
            GrayN_JSON::FastWriter writer;
            string response = writer.write(responseJson);
            GrayN_Offical::GetInstance().GrayN_Offical_UserInfoResponse(response);
            return;
        }
        
        GrayNcommon::GrayN_ConsoleLog(desc.c_str());
        GrayN_Offical::GetInstance().GrayN_Offical_ShowSwitchAccountView();
        GrayN_Offical::GetInstance().GrayN_Offical_ShowToast(desc, false);
    }
}
#pragma mark- 已登录情况下session失效，需要调一次登录才能把用户信息和sessionId对应上
void GrayN_UserCenter::GrayN_UserCenter_ParseGetSessionIdLogin()
{
    GrayN_JSON::Value     json_object;
    
    if (!GrayN_UserCenter_ParseDesData(json_object)) {
        GrayNcommon::GrayN_ConsoleLog("登陆返回的数据无法解析！");
        GrayN_Offical::GetInstance().GrayN_Offical_GetSessionIdResponse("false");
        return;
    }
    
    if (json_object["errorCode"].empty() ||
        json_object["errorDesc"].empty()) {
        GrayNcommon::GrayN_ConsoleLog("登陆返回的数据不完整！");
        GrayN_Offical::GetInstance().GrayN_Offical_GetSessionIdResponse("false");
        return;
    }
    
    string status = json_object["status"].asString();
    if (atoi(status.c_str())) {
        GrayN_JSON::FastWriter parseWriter;
        GrayN_JSON::Value returnJson;
        returnJson["sessionId"] = GrayNcommon::m_GrayN_SessionId;
        string returnStr = parseWriter.write(returnJson);
        GrayN_Offical::GetInstance().GrayN_Offical_GetSessionIdResponse(returnStr);
    } else {
        GrayN_Offical::GetInstance().GrayN_Offical_GetSessionIdResponse("false");
    }
}
#pragma mark- 二次验证
void GrayN_UserCenter::GrayN_UserCenter_LoginVerify_GrayN(GrayN_JSON::Value &verifyJson)//登录验证
{
    GrayN_JSON::Value root;
    root["service"] = GrayN_JSON::Value(GrayNverifyInterface);
    root["sessionId"] = GrayN_JSON::Value(GrayNcommon::m_GrayN_SessionId);
    root["userPlatformId"] = GrayN_JSON::Value(GrayNcommon::m_GrayN_UserPlatformId);
    root["activateTokenId"] = GrayN_JSON::Value(GrayNSDK::m_GrayN_SDK_ActivateTokenId);
    root["sdkParams"] = verifyJson;
    
    GrayN_JSON::FastWriter fast_writer;
    string tmp = fast_writer.write(root);
    p_GrayN_UserCenter_DecodeData = tmp;
    
    string desData = "";
    GrayN_Des_GrayN::GrayN_DesEncrypt(tmp, desData);
    
    GrayN_UserCenter::GrayN_UserCenter_ConnectNetwork(GrayN_UserCenter_LoginVerify, GrayNSDK::m_GrayN_SDK_UserCenterEntryUrl.c_str(), desData);
}
#pragma mark- 二次验证解析
void GrayN_UserCenter::GrayN_UserCenter_ParseLoginVerify()
{
    GrayN_JSON::Reader    json_reader;
    GrayN_JSON::Value     json_object;
    
    if (!GrayN_UserCenter_ParseDesData(json_object) || json_object["status"].empty()) {
        GrayNcommon::GrayN_ConsoleLog("登录验证返回的数据无法解析！");
        GrayNSDK::GrayN_SDK_CallBackLogin(false, GrayN_JSON_NETDATA_ERROR);
        return;
    }
    
    string errorCode = json_object["errorCode"].asString();
    string errorDesc = json_object["errorDesc"].asString();
    
    int status = atoi(json_object["status"].asString().c_str());
    
    GrayN_JSON::Value data = json_object["data"];
    if (errorCode.c_str() == NULL || errorDesc.c_str() == NULL) {
        GrayNcommon::GrayN_ConsoleLog("未知错误！");
        return;
    }
    GrayN_JSON::Value limit = data["limit"];
    int isLimit = atoi(limit["isLimit"].asString().c_str());
    string limitDesc = limit["limitDesc"].asString();
    if (isLimit) {
        GrayN_JSON::FastWriter fast_writer;
        string tmp = fast_writer.write(limit);
        GrayNcommon::GrayN_ConsoleLog(tmp.c_str());
        
        string desc = limit["limitDesc"].asString();
        GrayNchannel::GetInstance().GrayN_ChannelLogout();
        GrayN_LoadingUI::GetInstance().GrayN_ShowMsgBox(GrayNcommon::GrayNcommonGetLocalLang(GrayN_Title), desc.c_str(), 0, 1);
        GrayN_LoadingUI::GetInstance().GrayN_CloseWait();
        return;
    }
    
    if (status == 1) {
        
        
        GrayNcommon::m_GrayN_LoginType = data["loginType"].asString();
        if (GrayNcommon::m_GrayN_LoginType.length() == 0) {
            //会影响到用户注册登录日志的发送
            GrayNSDK::GrayN_SDK_CallBackLogin(false, GrayN_LOGIN_LOGINTYPENULL_ERROR);

            return;
        }
        /******保存值******/
        // 用户ID
        GrayNcommon::m_GrayN_Game_UserId = data["userId"].asString();
        // 掌趣用户名
        GrayNcommon::m_GrayN_Game_UserName = data["currentUserName"].asString();
        // 掌趣号
        GrayNcommon::m_GrayN_Game_PalmId = data["palmId"].asString();
        // 掌趣昵称
        GrayNcommon::m_GrayN_Game_NickName = data["nickName"].asString();
        // 用户登录手机号
        GrayNcommon::m_GrayN_Game_PhoneNum = data["phone"].asString();
        // 用户登录邮箱
        GrayNcommon::m_GrayN_Game_Email = data["email"].asString();
        // 当前用户登录类型
        GrayNcommon::m_GrayN_CurrentUserType = data["currentUserType"].asString();
        
        /*5.1.9保存用户信息*/
        GrayN_Offical::GetInstance().GrayN_Offical_DelAllUserInfoAndUpdateLastone(data);
        
        // 发送用户中心的注册登录日志
        GrayNSDK::GrayN_SDK_SendUserRegisterLoginLog();
        
        GrayN_JSON::Value userInfo_json;
        userInfo_json["palmId"] = data["palmId"].asString();
        userInfo_json["nickName"] = data["nickName"].asString();
        
        GrayN_JSON::Value tmp_json;
        tmp_json["returnJson"] = userInfo_json;
        tmp_json["userId"] = data["userId"].asString();
        tmp_json["userName"] = data["currentUserName"].asString();
        tmp_json["tokenId"] = GrayNcommon::m_GrayN_SessionId;
        tmp_json["currentUserType"] = GrayNcommon::m_GrayN_CurrentUserType;
        /*5.2.3 返回服务器所有数据*/
        tmp_json["data"] = data;
        
        GrayN_JSON::FastWriter fast_writer;
        string tmp = fast_writer.write(tmp_json);
        GrayNSDK::GrayN_SDK_CallBackLogin(true, tmp.c_str());

        /*5.1.9 判断是否弹出绑定官网账号页面*/
        if (GrayNSDK::m_GrayN_SDK_BindOfficialUserSwitch) {
            GrayN_Offical::GetInstance().GrayN_Offical_ShowBindOfficialView();
        }

    } else {
        GrayN_LoadingUI::GetInstance().GrayN_CloseWait();
        GrayN_JSON::FastWriter fast_writer;
        string tmp = fast_writer.write(json_object);
        GrayNcommon::GrayN_ConsoleLog(tmp.c_str());
        
        string desc = json_object["errorDesc"].asString();

        GrayNchannel::GetInstance().GrayN_ChannelLogout();
        GrayN_LoadingUI::GetInstance().GrayN_ShowMsgBox(GrayNcommon::GrayNcommonGetLocalLang(GrayN_Title), desc.c_str(), 0, 1);
    }
}
void GrayN_UserCenter::GrayN_UserCenter_GCLoginVerify_GrayN(string playerID, string alias)//登录验证
{    
    GrayN_JSON::Value root;
    GrayN_JSON::Value params;
    params["alias"] = GrayN_JSON::Value(alias);
    params["playerID"] = GrayN_JSON::Value(playerID);
    
    root["service"] = GrayN_JSON::Value(GrayNverifyInterface);
    root["sessionId"] = GrayN_JSON::Value(GrayNcommon::m_GrayN_SessionId);
    root["userPlatformId"] = GrayN_JSON::Value(GrayNgameCenter_PlatformId);
    root["activateTokenId"] = GrayN_JSON::Value(GrayNSDK::m_GrayN_SDK_ActivateTokenId);
    root["sdkParams"] = params;
    
    GrayN_JSON::FastWriter fast_writer;
    string tmp = fast_writer.write(root);
    p_GrayN_UserCenter_DecodeData = tmp;
    
    string desData = "";
    GrayN_Des_GrayN::GrayN_DesEncrypt(tmp, desData);
    
    GrayN_UserCenter::GrayN_UserCenter_ConnectNetwork(GrayN_UserCenter_GC_LoginVerify, GrayNSDK::m_GrayN_SDK_UserCenterEntryUrl.c_str(), desData);
}
void GrayN_UserCenter::GrayN_UserCenter_GCParseLoginVerify()
{
    GrayN_LoadingUI::GetInstance().GrayN_CloseWait();

    GrayN_JSON::Reader    json_reader;
    GrayN_JSON::Value     json_object;
    
    if (!GrayN_UserCenter_ParseDesData(json_object) || json_object["status"].empty()) {
        GrayNcommon::GrayN_ConsoleLog("登录验证返回的数据无法解析！");
        GrayN_Offical::GetInstance().GrayN_Offical_GC_Callback("NULL", "NULL", false);
        return;
    }
    
    string errorCode = json_object["errorCode"].asString();
    string errorDesc = json_object["errorDesc"].asString();
    
    int status = atoi(json_object["status"].asString().c_str());
    
    GrayN_JSON::Value data = json_object["data"];
    if (errorCode.c_str() == NULL || errorDesc.c_str() == NULL) {
        GrayNcommon::GrayN_ConsoleLog("未知错误！");
        return;
    }
    
    if (status == 1) {

        string userName = data["currentUserName"].asString();
        string current = data["currentUserType"].asString();
        GrayN_Offical::GetInstance().GrayN_Offical_GC_Callback(userName, current, true);
        
    } else {
        GrayN_Offical::GetInstance().GrayN_Offical_GC_Callback("NULL", "NULL", false);
    }
}
#pragma mark- 手机扫二维码登录借口
void GrayN_UserCenter::GrayN_UserCenter_QRScanner_GrayN()
{
    GrayN_JSON::Value root;
    
    root["service"] = GrayN_JSON::Value(GrayNscannerInterface);
    root["QRCodeTokenId"] = GrayN_JSON::Value(GrayNcommon::m_GrayN_QRCodeTokenId);
    
    GrayN_JSON::FastWriter fast_writer;
    string tmp = fast_writer.write(root);
    p_GrayN_UserCenter_DecodeData = tmp;
    
    string desData = "";
    GrayN_Des_GrayN::GrayN_DesEncrypt(tmp, desData);
    
    GrayN_UserCenter::GrayN_UserCenter_ConnectNetwork(GrayN_UserCenter_QR_Scanner, GrayNSDK::m_GrayN_SDK_UserCenterEntryUrl.c_str(), desData);
}
void GrayN_UserCenter::GrayN_UserCenter_ParseQRScanner()
{
    GrayN_LoadingUI::GetInstance().GrayN_CloseWait();
    
    GrayN_JSON::Reader    json_reader;
    GrayN_JSON::Value     json_object;
    
    if (!GrayN_UserCenter_ParseDesData(json_object) || json_object["status"].empty()) {
        GrayNcommon::GrayN_ConsoleLog("ParseQRScanner数据无法解析！");
        GrayN_LoadingUI::GetInstance().GrayN_ShowMsgBox(GrayNcommon::GrayNcommonGetLocalLang(GrayN_Title), "ParseQRScanner数据无法解析！", 0, 1);
        return;
    }
    
    string errorCode = json_object["errorCode"].asString();
    string errorDesc = json_object["errorDesc"].asString();
    string desc = errorCode;
    desc.append(":");
    desc.append(errorDesc);
    
    int status = atoi(json_object["status"].asString().c_str());
    
    GrayN_JSON::Value data = json_object["data"];
    if (errorCode.c_str() == NULL || errorDesc.c_str() == NULL) {
        GrayNcommon::GrayN_ConsoleLog("未知错误！");
        return;
    }
    
    if (status == 1) {
        GrayN_Offical::GetInstance().GrayN_Offical_ShowQRConfirmView();
    } else {
        GrayN_LoadingUI::GetInstance().GrayN_ShowMsgBox(GrayNcommon::GrayNcommonGetLocalLang(GrayN_Title), desc.c_str(), 0, 1);
    }
    
}
void GrayN_UserCenter::GrayN_UserCenter_QRScannerConfirm_GrayN()
{
    GrayN_JSON::Value root;
    
    root["service"] = GrayN_JSON::Value(GrayNscannerConfirmInterface);
    root["QRCodeTokenId"] = GrayN_JSON::Value(GrayNcommon::m_GrayN_QRCodeTokenId);
    root["sessionId"] = GrayN_JSON::Value(GrayNcommon::m_GrayN_SessionId);

    GrayN_JSON::FastWriter fast_writer;
    string tmp = fast_writer.write(root);
    p_GrayN_UserCenter_DecodeData = tmp;
    
    string desData = "";
    GrayN_Des_GrayN::GrayN_DesEncrypt(tmp, desData);
    
    GrayN_UserCenter::GrayN_UserCenter_ConnectNetwork(GrayN_UserCenter_QR_ScannerConfirm, GrayNSDK::m_GrayN_SDK_UserCenterEntryUrl.c_str(), desData);
}
void GrayN_UserCenter::GrayN_UserCenter_ParseQRScannerConfirm()
{
    GrayN_LoadingUI::GetInstance().GrayN_CloseWait();
    
    GrayN_JSON::Reader    json_reader;
    GrayN_JSON::Value     json_object;
    
    if (!GrayN_UserCenter_ParseDesData(json_object) || json_object["status"].empty()) {
        GrayNcommon::GrayN_ConsoleLog("ParseQRScannerConfirm数据无法解析！");
        GrayN_LoadingUI::GetInstance().GrayN_ShowMsgBox(GrayNcommon::GrayNcommonGetLocalLang(GrayN_Title), "ParseQRScannerConfirm数据无法解析！", 0, 1);
        return;
    }
    
    string errorCode = json_object["errorCode"].asString();
    string errorDesc = json_object["errorDesc"].asString();
    string desc = errorCode;
    desc.append(":");
    desc.append(errorDesc);
    
    int status = atoi(json_object["status"].asString().c_str());
    
    GrayN_JSON::Value data = json_object["data"];
    if (errorCode.c_str() == NULL || errorDesc.c_str() == NULL) {
        GrayNcommon::GrayN_ConsoleLog("未知错误！");
        return;
    }
    
    if (status == 1) {
        GrayN_Offical::GetInstance().GrayN_Offical_CloseQRConfirmView();
        GrayN_Offical::GetInstance().GrayN_Offical_ShowToast("登录成功", YES);

    } else {
        GrayN_LoadingUI::GetInstance().GrayN_ShowMsgBox(GrayNcommon::GrayNcommonGetLocalLang(GrayN_Title), desc.c_str(), 0, 1);
    }
}
#pragma mark- 角色、用户对应接口
void GrayN_UserCenter::GrayN_UserCenter_RoleInfoCorrespondUserInfo(GrayN_UserCenter *obj)
{
    p_GrayN_UserCenterObject = obj;
    
    GrayN_JSON::Value root;
    root["service"] = GrayN_JSON::Value(GrayNroleCorrespondUserInterface);
    root["userId"] = GrayN_JSON::Value(GrayNcommon::m_GrayN_Game_UserId);
    root["sessionId"] = GrayN_JSON::Value(GrayNcommon::m_GrayN_SessionId);
    root["roleId"] = GrayN_JSON::Value(GrayNcommon::m_GrayN_Game_RoleId);
    root["roleName"] = GrayN_JSON::Value(GrayNcommon::m_GrayN_Game_RoleName);
    root["serverId"] = GrayN_JSON::Value(GrayNcommon::m_GrayN_Game_ServerId);
    root["pCode"] = GrayN_JSON::Value(GrayNcommon::m_GrayN_P_Code);
    
    GrayN_JSON::FastWriter fast_writer;
    string tmp = fast_writer.write(root);
    p_GrayN_UserCenter_DecodeData = tmp;

    string desData = "";
    GrayN_Des_GrayN::GrayN_DesEncrypt(tmp, desData);
    
    p_GrayN_UserCenter_Https->GrayN_Thread_OpenSwitch();
    GrayN_UserCenter::GrayN_UserCenter_ConnectNetwork(GrayN_UserCenter_Role_Correspond_User, GrayNSDK::m_GrayN_SDK_UserCenterCoreUrl.c_str(), desData);
}
#pragma mark- 解析角色、用户对应接口
void GrayN_UserCenter::GrayN_UserCenter_ParseRoleInfoCorrespondUserInfo()
{
    GrayN_JSON::Value     json_object;
    if (!GrayN_UserCenter_ParseDesData(json_object)) {
        GrayNcommon::GrayN_DebugLog("GrayN_UserCenter_ParseRoleInfoCorrespondUserInfo 数据异常！");
        return;// json格式解析错
    }
    
    if (json_object["status"].empty() ||
        json_object["errorCode"].empty() ||
        json_object["errorDesc"].empty()) {
        GrayNcommon::GrayN_DebugLog("GrayN_UserCenter_ParseRoleInfoCorrespondUserInfo 数据异常！");
        return;//json格式解析错
    }
    
    const char* statusStr = json_object["status"].asCString();
    int status = atoi(statusStr);
    if (status == 1) {
        GrayNcommon::GrayN_DebugLog("GrayN_UserCenter_ParseRoleInfoCorrespondUserInfo 成功！");
    } else {
        GrayNcommon::GrayN_DebugLog("GrayN_UserCenter_ParseRoleInfoCorrespondUserInfo 失败！");
    }
}
bool GrayN_UserCenter::GrayN_UserCenter_ParseDesData(GrayN_JSON::Value &json_object)
{
    //解密
    string tmpBuf = "";
    GrayN_Des_GrayN::GrayN_DesDecrypt(p_GrayN_UserCenter_HttpBuffer, tmpBuf);
    
    GrayNcommon::GrayN_DebugLog("GrayN_UserCenter GrayN_UserCenter_ParseDesData:");
    GrayNcommon::GrayN_DebugLog(tmpBuf.c_str());

    GrayN_JSON::Reader    json_reader;
    if (!json_reader.parse(tmpBuf, json_object)){
        GrayNcommon::GrayN_ConsoleLog("GrayN_UserCenter::GrayN_UserCenter_ParseDesData:数据异常，无法解析！");
        GrayNcommon::GrayN_ConsoleLog(tmpBuf.c_str());
        
        //加入错误发送日志
        if (p_GrayN_UserCenter_HttpType == GrayN_UserCenter_Login || p_GrayN_UserCenter_HttpType == GrayN_UserCenter_LoginVerify) {
            GrayN_ErrorLog_GrayN *errorLog = new GrayN_ErrorLog_GrayN();
            errorLog->GrayN_ErrorLog_SendLog(p_GrayN_UserCenter_LogType.c_str(), p_GrayN_UserCenter_RequestTime.c_str(), GrayN_USER_DES_LOGERROR,
                                     p_GrayN_UserCenter_Https->GrayN_Http_Get_SocketError(),p_GrayN_UserCenter_Https->GrayN_Http_Get_HttpCode(), p_GrayN_UserCenter_HttpBuffer.c_str());
        }
        return false;//json格式解析错误
    }
    p_GrayN_UserCenter_DecryptData.clear();
    p_GrayN_UserCenter_DecryptData = tmpBuf;
    
    return true;
}
#pragma mark- 网络
void GrayN_UserCenter::GrayN_UserCenter_ConnectNetwork(int httpType, const char* url, string data)//网络连接
{
    // 请求时间
    p_GrayN_UserCenter_StartTime = GrayNcommon::GrayNgetCurrent_TimeStamp();
    p_GrayN_UserCenter_RequestTime.clear();
    p_GrayN_UserCenter_RequestTime = GrayNcommon::GrayNgetCurrent_DateAndTime();
    
    if (httpType == GrayN_UserCenter_Login){
        p_GrayN_UserCenter_LogType = "oplogin";
    } else if (httpType == GrayN_UserCenter_LoginVerify){
        p_GrayN_UserCenter_LogType = "thirdLogin";
    } else if (httpType == GrayN_UserCenter_Role_Correspond_User){
        p_GrayN_UserCenter_LogType = "roleCorrespondUser";
    } else if (httpType == GrayN_UserCenter_Get_SessionId){
        p_GrayN_UserCenter_LogType = "getSessionId";
    } else if (httpType == GrayN_UserCenter_QR_Scanner){
        p_GrayN_UserCenter_LogType = "qrScanner";
    } else if (httpType == GrayN_UserCenter_QR_ScannerConfirm){
        p_GrayN_UserCenter_LogType = "qrScannerConfirm";
    }
    
    //    return;
    
    p_GrayN_UserCenter_HttpBuffer.clear();
    p_GrayN_UserCenter_HttpType = httpType;

    string httpsUrl = url;
    GrayNcommon::GrayNstringReplace(httpsUrl, "http://", "https://");
    p_GrayN_UserCenter_Https->GrayN_Https_Post(httpsUrl, data);
    GrayNcommon::GrayN_DebugLog("opUserCenterHttpType:%s\nopUserCenterHttpUrls:%s\nopUserCenterHttpData:", p_GrayN_UserCenter_LogType.c_str(), httpsUrl.c_str());
    GrayNcommon::GrayN_DebugLog(p_GrayN_UserCenter_DecodeData.c_str());

}
#pragma mark - http
void GrayN_UserCenter::GrayN_UserCenter_ParseHttpError(void* args)
{
    bool ifTimeOut = false;
    p_GrayN_UserCenter_EndTime = GrayNcommon::GrayNgetCurrent_TimeStamp();
    if (p_GrayN_UserCenter_EndTime-p_GrayN_UserCenter_StartTime > 40000) {    //40s
        ifTimeOut = true;
    }
    
    int errorCode = GrayN_NONEERROR;
    const char *errorJson = NULL;
    if (!ifTimeOut) {
        errorCode = GrayN_ERROR_HTTP_OPENERROR;
        errorJson = GrayN_JSON_NETWORK_ERROR;
        GrayNcommon::GrayN_ConsoleLog(GrayNcommon::GrayNcommonGetLocalLang(GrayN_NetworkError));
        GrayN_LoadingUI::GetInstance().GrayN_ShowMsgBox(GrayNcommon::GrayNcommonGetLocalLang(GrayN_Title), GrayNcommon::GrayNcommonGetLocalLang(GrayN_NetworkError), 0, 1);

    } else {
        errorCode = GrayN_ERROR_HTTP_TIMEOUT;
        errorJson = GrayN_JSON_TIMEOUT_ERROR;
        GrayNcommon::GrayN_ConsoleLog(GrayN_TimeOut);
        GrayN_LoadingUI::GetInstance().GrayN_ShowMsgBox(GrayNcommon::GrayNcommonGetLocalLang(GrayN_Title), GrayNcommon::GrayNcommonGetLocalLang(GrayN_TimeOut), 0, 1);
    }
    
    //加入错误发送日志
    if (p_GrayN_UserCenter_HttpType == GrayN_UserCenter_Login || p_GrayN_UserCenter_HttpType == GrayN_UserCenter_LoginVerify) {
        string tmp;
        if (p_GrayN_UserCenter_HttpErrorCode == k_GrayN_OPEN_ERROR) {
            tmp = "OPEN_ERROR";
        } else if (p_GrayN_UserCenter_HttpErrorCode == k_GrayN_SEND_HEAD_ERROR) {
            tmp = "SEND_HEAD_ERROR";
        } else if (p_GrayN_UserCenter_HttpErrorCode == k_GrayN_SEND_POST_ERROR) {
            tmp = "SEND_POST_ERROR";
        } else if (p_GrayN_UserCenter_HttpErrorCode == k_GrayN_RECV_HEAD_ERROR) {
            tmp = "RECV_HEAD_ERROR";
        } else if (p_GrayN_UserCenter_HttpErrorCode == k_GrayN_RECV_DATA_ERROR) {
            tmp = "RECV_DATA_ERROR";
        } else if (p_GrayN_UserCenter_HttpErrorCode == k_GrayN_DISCONNECTED_ERROR) {
            tmp = "DISCONNECTED_ERROR";
        }
        GrayN_ErrorLog_GrayN *errorLog = new GrayN_ErrorLog_GrayN();
        errorLog->GrayN_ErrorLog_SendLog(p_GrayN_UserCenter_LogType.c_str(), p_GrayN_UserCenter_RequestTime.c_str(), tmp.c_str(),
                                 p_GrayN_UserCenter_Https->GrayN_Http_Get_SocketError(),p_GrayN_UserCenter_Https->GrayN_Http_Get_HttpCode(), p_GrayN_UserCenter_HttpBuffer.c_str());
    }
    
    switch (p_GrayN_UserCenter_HttpType) {
        case GrayN_UserCenter_Login:
            // 登陆
            if (!m_GrayN_UserCenter_IsAutoLogin) {
                GrayN_JSON::Value responseJson;
                responseJson["data"] = errorCode;
                responseJson["status"] = "1";
                GrayN_JSON::FastWriter writer;
                string response = writer.write(responseJson);
                GrayN_Offical::GetInstance().GrayN_Offical_UserInfoResponse(response);
            }
            GrayNchannel::GetInstance().m_GrayN_IsLogining = false;

            break;
        case GrayN_UserCenter_Get_SessionId:
            GrayN_Offical::GetInstance().GrayN_Offical_GetSessionIdResponse("false");
            break;
        case GrayN_UserCenter_Role_Correspond_User:
            break;
//        case OP_ActivateCode:
//            break;
        case GrayN_UserCenter_LoginVerify:
            // 二次验证
            GrayNSDK::GrayN_SDK_CallBackLogin(false, errorJson);
            break;
        case GrayN_UserCenter_QR_Scanner:
        {
//            string body(GrayNcommon::GrayNcommonGetLocalLang(GrayN_InitFailed));
//            GrayN_LoadingUI::GetInstance().GrayN_ShowMsgBox(GrayNcommon::GrayNcommonGetLocalLang(GrayN_Title), GrayNcommon::GrayNcommonGetLocalLang(body.c_str()), 0, 1);
            // 扫码解析失败
            break;
        }
        case GrayN_UserCenter_QR_ScannerConfirm:
        {
            // 扫码解析登录失败
            break;
        }
        default:

            break;
    }
}

void GrayN_UserCenter::GrayN_UserCenter_ParseHttpData(GrayN_Http_GrayN* client)
{
    switch (p_GrayN_UserCenter_HttpType) {
        case GrayN_UserCenter_Login:
            GrayN_UserCenter_ParseLoginInfo();
            break;
        case GrayN_UserCenter_Get_SessionId:
            GrayN_UserCenter_ParseGetSessionIdLogin();
            break;
        case GrayN_UserCenter_Role_Correspond_User:
            break;
        case GrayN_UserCenter_LoginVerify:
            GrayN_UserCenter_ParseLoginVerify();
            break;
        case GrayN_UserCenter_GC_LoginVerify:
            GrayN_UserCenter_GCParseLoginVerify();
            break;
        case GrayN_UserCenter_QR_Scanner:
            GrayN_UserCenter_ParseQRScanner();
            break;
        case GrayN_UserCenter_QR_ScannerConfirm:
            GrayN_UserCenter_ParseQRScannerConfirm();
            break;
        default:
            break;
    }
}

void GrayN_UserCenter::GrayN_UserCenter_ProcessHttpError(void* args)
{
    GrayN_UserCenter::GetInstance().GrayN_UserCenter_ParseHttpError(args);
}

void GrayN_UserCenter::GrayN_On_HttpError(GrayN_Http_GrayN* client, GrayN_HttpErrorCode code)
{
#ifdef HTTPDEBUG
    GrayNcommon::GrayN_DebugLog("on http error code=%d", code);
#endif
    //非常重要
    if (p_GrayN_UserCenter_HttpType == GrayN_UserCenter_Role_Correspond_User) {
        GrayNcommon::GrayN_DebugLog("GrayN_UserCenter_ParseHttpError=GrayN_UserCenter_Role_Correspond_User 用户角色关联失败！");
        return;
    }
    p_GrayN_UserCenter_HttpErrorCode = code;
    p_GrayN_UserCenter_Asyn_CallBack->GrayNstartAsyn_CallBack(GrayN_UserCenter::GrayN_UserCenter_ProcessHttpError, &code);

}
void GrayN_UserCenter::GrayN_UserCenter_ProcessParseHttpData(void* args)
{
    GrayN_UserCenter::GetInstance().GrayN_UserCenter_ParseHttpData((GrayN_Http_GrayN*)args);
}
void GrayN_UserCenter::GrayN_On_HttpEvent(GrayN_Http_GrayN* client, GrayN_HttpEventCode code)
{
#ifdef HTTPDEBUG
    GrayNcommon::GrayN_DebugLog("on http event code = %d", code);
#endif
    if (code == k_GrayN_SEND_HEAD) {
        p_GrayN_UserCenter_HttpBuffer.clear();
    } else if(code == k_GrayN_COMPLETE) {
        
        //非常重要，这是个新的线程，只需要发送用户关联即可，无需与界面交互
        if (p_GrayN_UserCenter_HttpType == GrayN_UserCenter_Role_Correspond_User) {
#ifdef HTTPDEBUG
            cout<<"OPGameSDK LOG:GrayN_UserCenter_Role_Correspond_User"<<endl;
#endif
            GrayN_UserCenter_ParseRoleInfoCorrespondUserInfo();
            return;
        }
        p_GrayN_UserCenter_Asyn_CallBack->GrayNstartAsyn_CallBack(GrayN_UserCenter::GrayN_UserCenter_ProcessParseHttpData, client);

    }
}

void GrayN_UserCenter::GrayN_On_HttpResponse(GrayN_Http_GrayN* client,int code,int context_length,int startPos,int endPos,int totalContext,const char* data)
{
    
}

void GrayN_UserCenter::GrayN_On_Http_Data(GrayN_Http_GrayN* client,const char* data,int count)
{
#ifdef HTTPDEBUG
    GrayNcommon::GrayN_DebugLog("on http length=%d data=%s",count,data);
#endif
    p_GrayN_UserCenter_HttpBuffer.append(data,count);
}

void GrayN_UserCenter::GrayN_On_Http_Over()
{
    GrayNcommon::GrayN_DebugLog("GrayN_UserCenter::GrayN_On_Http_Over()");
    if (p_GrayN_UserCenterObject) {
        delete p_GrayN_UserCenterObject;
        p_GrayN_UserCenterObject = NULL;
    }
}
#pragma mark- 用户中心心跳
void GrayN_UserCenter::GrayN_UserCenter_StartHeartBeat()
{
    p_GrayN_UserCenter_UserHeart = new GrayN_UserHeart();
    p_GrayN_UserCenter_UserHeart->GrayN_UserHeart_HeartBeating();
}
void GrayN_UserCenter::GrayN_UserCenter_StopHeartBeat()
{
    if (p_GrayN_UserCenter_UserHeart) {
        p_GrayN_UserCenter_UserHeart->GrayN_UserHeart_StopHeartBeat();
        p_GrayN_UserCenter_UserHeart = NULL;
    }
}

