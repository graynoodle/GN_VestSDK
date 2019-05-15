//
//  GrayNconfig.h
//
//  Created by op-mac1 on 13-12-31.
//  Copyright (c) 2013年 op-mac1. All rights reserved.
//

#import "GrayNlanguage.h"
#import "GrayNerror.h"

#define GrayNbaseVersion "9.0.1"

// 指定命名空间
#define GrayN_NameSpace_Start                     namespace ourpalmpay {
#define GrayN_NameSpace_End                       }

#define GrayNusing_NameSpace                     using namespace ourpalmpay

#define GrayNprivateKey "ourpalm^"

#ifdef DEBUG
//#define OPCharge_Test
//#define DomainName "http://223.202.94.183:8080/ucenter_entry3.0/entry"
#endif

//#define DomainName "http://auth.gamebean.net/ucenter2.0/entry/entry"
//#define UsercenterURL "/uMember/userLoginMgr.do?"
#define GrayNpayCenterRoute "/gameClient/main.do?"
#define GrayNappstoreVerifyRoute "/palmBilling/appStorePay/query.do?"
#define GrayNappstoreLogRoute "/ac?"

#define GrayNinitInterface         "palm.platform.ucenter.init"
#define GrayNupdateInterface       "palm.platform.ucenter.sdkUpgrade"
#define GrayNverifyInterface       "palm.platform.ucenter.thirdHiddenLogin"
#define GrayNspeedyLoginInterface  "palm.platform.ucenter.speedyLogin"
#define GrayNcommonLoginInterface  "palm.platform.ucenter.login"
#define GrayNheartBeatInterface    "palm.platform.ucenter.heartbeat"
#define GrayNroleCorrespondUserInterface "palm.platform.ucenter.userRoleInfo"

/*5.2.1 二维码借口*/
#define GrayNscannerInterface "palm.platform.ucenter.scanQRCode"
#define GrayNscannerConfirmInterface "palm.platform.ucenter.loginByQRCode"

//***********************计费中心*******************
//#define POST_KEY "Key=i_sct|c_s_v|cd|ud|ptm|ptmi|p_c_l|s_o|ptsi|icid|ptu|s_v|f_os|h_u|j_c_u|j_c_m&KKey=ptm|ptmi&i_sct=1"
//筛选计费点接口
#define GrayNsortPurchasePointInterface "0002"
#define GrayNsortPurchaseResultInterface "0003"
#define GrayNexchangeGamecodeInterface "0008"

/* 颜色 */
#define GrayNwhiteColor [UIColor whiteColor]
#define GrayNblackColor [UIColor blackColor]
#define GrayNclearColor [UIColor clearColor]

#define GrayNtoastBackgroundColor [UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1]
#define GrayNorangeColor [UIColor colorWithRed:248.0f/255.0f green:181.0f/255.0f blue:81.0f/255.0f alpha:1]
#define GrayNhudBackgroundColor [UIColor colorWithRed:245.0f/255.0f green:245.0f/255.0f blue:245.0f/255.0f alpha:1]

/* 安全释放 */
#define GrayNreleaseSafe(_ptr_) if((_ptr_) != nil) {[_ptr_ release]; _ptr_ = nil;}

/* 尺寸 */
#define GrayNmarginLine 1
#define GrayNtoast_Edge_Width 10
#define GrayNscreen_Ratio [[GrayN_BaseControl GrayN_Share] GrayNreturnDisplayRatio]

#define GrayNtitle_Font_Size       24*GrayNscreen_Ratio
#define GrayNrestrict_Length 12


/* 获取字符串的方法 */
#define GrayNgetResBundleStr(key) \
[[GrayN_BaseControl GrayN_Share] GrayNgetLanString:(key)]


///* 新版界面 */
#define GrayNhudLineColor [UIColor colorWithRed:201.0f/255.0f green:201.0f/255.0f blue:201.0f/255.0f alpha:1]

#define GrayNisStraightBangsDevice \
({\
bool space = false;\
if (@available(iOS 11.0, *))\
space = (!UIEdgeInsetsEqualToEdgeInsets([UIApplication sharedApplication].windows[0].safeAreaInsets, UIEdgeInsetsZero));\
(space);\
})

//#define GrayNisStraightBangsDevice  (!UIEdgeInsetsEqualToEdgeInsets([UIApplication sharedApplication].windows[0].safeAreaInsets, UIEdgeInsetsZero))
//#define GrayNisStraightBangsDevice ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)
#define GrayNgetStatusBarOrientation [UIApplication sharedApplication].statusBarOrientation
#define GrayNstraightBangsTopEdge 30


#define GrayNgameCenter_PlatformId "0329"

/*5.2.1*/
#define GrayN_QR_BlueColor [GrayN_Tools GrayNcolorWithHexString:@"#36cbf4" alpha:1.0]
#define GrayN_QR_GrayColor [GrayN_Tools GrayNcolorWithHexString:@"#6e6e6e" alpha:1.0]




