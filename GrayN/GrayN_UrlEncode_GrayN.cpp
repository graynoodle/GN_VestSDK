//
//  GrayN_UrlEncode_GrayN.cpp
//
//  Created by gamebean on 13-1-10.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <iostream>
#import "GrayN_UrlEncode_GrayN.h"
#import "assert.h"

GrayNusing_NameSpace;

unsigned char GrayN_ToHex(unsigned char x)
{   
    return  x > 9 ? x + 55 : x + 48;   
}  

unsigned char GrayN_FromHex(unsigned char x)   
{   
    unsigned char y;  
    if (x >= 'A' && x <= 'Z') y = x - 'A' + 10;  
    else if (x >= 'a' && x <= 'z') y = x - 'a' + 10;  
    else if (x >= '0' && x <= '9') y = x - '0';  
    else assert(0);  
    return y;  
}  

void GrayN_UrlEncode_GrayN::GrayN_Url_Encode(const string& str, string& strEncode)  
{  
    size_t length = str.length();  
    for (size_t i = 0; i < length; i++)  
    {  
        if (isalnum((unsigned char)str[i]) ||   
            (str[i] == '-') ||  
            (str[i] == '_') ||   
            (str[i] == '.') ||   
            (str[i] == '~'))  
            strEncode += str[i];  
        else if (str[i] == ' ')  
            strEncode += "+";  
        else  
        {  
            strEncode += '%';  
            strEncode += GrayN_ToHex((unsigned char)str[i] >> 4);
            strEncode += GrayN_ToHex((unsigned char)str[i] % 16);
        }  
    }
}  

void GrayN_UrlEncode_GrayN::GrayN_Url_Decode(const std::string& str, string& strDecode)
{  
    size_t length = str.length();  
    for (size_t i = 0; i < length; i++)  
    {  
        if (str[i] == '+') strDecode += ' ';  
        else if (str[i] == '%')  
        {  
            assert(i + 2 < length);  
            unsigned char hign = GrayN_FromHex((unsigned char)str[++i]);  
            unsigned char low = GrayN_FromHex((unsigned char)str[++i]);  
            strDecode += hign*16 + low;  
        }  
        else strDecode += str[i];  
    } 
} 
