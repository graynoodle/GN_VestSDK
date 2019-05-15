//
//  GrayNcustomServiceConfig.h
//
//  Created by JackYin on 15-8-11.
//  Copyright (c) 2015年 op-mac1. All rights reserved.
//


#define GrayNcustomServiceGetString(key) \
[[GrayNcustomService_Control GrayNshare] GrayNgetLanString:(key)]

//语言资源

#define GrayNcustomService_Title @"Title"
#define GrayNcustomService_Sure @"Sure"
#define GrayNcustomService_Cancel @"Cancel"
#define GrayNcustomService_Suggestion @"Suggestion"
#define GrayNcustomService_PicAlertNumError @"PicAlertNumError" //最多上传2张图片！
#define GrayNcustomService_PicAlertLargeError @"PicAlertLargeError"//图片大小不能超过5M
#define GrayNcustomService_UploadPic @"UpLoadPic" //上传截图


