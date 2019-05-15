//
//  GrayN_UrlEncode_GrayN.h
//
//  Created by gamebean on 13-1-10.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//


using namespace std;
#import "GrayNconfig.h"
GrayN_NameSpace_Start
    
class GrayN_UrlEncode_GrayN
{
public:
    static void GrayN_Url_Encode(const string& str, string& strEncode);
    static void GrayN_Url_Decode(const string& str, string& strDecode);
};    

GrayN_NameSpace_End

