//
//  Des.h
//
//  Created by gamebean on 13-1-10.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <string>
using namespace std;

#import "GrayNconfig.h"
GrayN_NameSpace_Start
    
#define GrayN_BYTE_GrayN   unsigned char
#define GrayN_LPBYTE_GrayN   GrayN_BYTE_GrayN* 
#define GrayN_LPCBYTE_GrayN   const GrayN_BYTE_GrayN*

class GrayN_Des_GrayN
{
public:
    GrayN_Des_GrayN();
    ~GrayN_Des_GrayN();        
public:
//    static void GrayN_DesEncrypt(char *In, long datalen, const char *Key, int keylen, string& is);
//    static void DesDecrypt(char *In, long datalen, const char *Key, int keylen, string& is);
    
    static void GrayN_DesEncrypt(string In, string Key, string &Out);
    static void GrayN_DesDecrypt(string In, string Key, string &Out);
    static void GrayN_DesEncrypt(string In, string &Out);
    static void GrayN_DesDecrypt(string In, string &Out);

private:
    static int GrayN_CDesEnter(GrayN_LPCBYTE_GrayN in, GrayN_LPBYTE_GrayN out, int datalen, const GrayN_BYTE_GrayN key[8], int type);
};

GrayN_NameSpace_End

