//
//  Des.cpp
//
//  Created by gamebean on 13-1-10.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//
#import <iostream>
#import <stdlib.h>
#import <stdio.h>

#import "GrayNcommon.h"
#import "GrayNconfig.h"
#import "GrayN_Des_GrayN.h"

using namespace std;


GrayN_NameSpace_Start

GrayN_Des_GrayN::GrayN_Des_GrayN()
{
    
}
GrayN_Des_GrayN::~GrayN_Des_GrayN()
{
    
}

void GrayN_Char2Hex_GrayN(unsigned char *GrayNdata, int GrayNlen, string& GrayNresult)
{
    GrayNresult.clear();
    for (int n = 0; n < GrayNlen; n++) {
        char tt[3];

        // 格式化字符串成对
        snprintf(tt, 3, "%02X", GrayNdata[n]);
        GrayNresult.append(tt);
    }
}

int GrayN_Hex2Char_GrayN(string &GrayNdata, unsigned char *GrayNout)
{
    int len = (int)GrayNdata.length();
    if ((len % 2) != 0){
        GrayNcommon::GrayN_DebugLog("Des解析数据不是偶数！");
        GrayNout = NULL;
        return 0;
    }
    
    for (int i = 0; i < len / 2; i++) {
        string tmp = GrayNdata.substr(i*2, 2);
        unsigned char ttt = (unsigned char)(strtol(tmp.c_str(), NULL, 16));
        GrayNout[i] = ttt;
    }
    return len / 2;
}

#define GET_UTF8_CHAR(ptr, c)                         \
{                                                     \
int x = *ptr++;                                   \
if(x & 0x80) {                                    \
int y = *ptr++;                               \
if(x & 0x20) {                                \
int z = *ptr++;                           \
c = ((x&0xf)<<12)+((y&0x3f)<<6)+(z&0x3f); \
} else                                        \
c = ((x&0x1f)<<6)+(y&0x3f);                   \
} else                                            \
c = x;                                            \
}

int GrayN_UTF8Len_GrayN(char *GrayNutf8)
{
    int count;
    for(count = 0; *GrayNutf8; count++) {
        int x = *GrayNutf8;
        GrayNutf8 += (x & 0x80) ? ((x & 0x20) ? 3 : 2) : 1;
    }
    return count;
}

void GrayN_ConvertUTF8_GrayN(char *GrayNutf8, unsigned short *GrayNbuff)
{
    while(*GrayNutf8)
        GET_UTF8_CHAR(GrayNutf8, *GrayNbuff++);
}

unsigned char* GrayN_UTF2Unicode_GrayN(unsigned char *GrayNutf8)
{
    int nLength = GrayN_UTF8Len_GrayN((char*)GrayNutf8);
    unsigned short* buffer = new unsigned short[nLength];
    GrayN_ConvertUTF8_GrayN((char*)GrayNutf8,buffer);
    return (unsigned char*)buffer;
}

//int GrayN_Unicode2UTF8_GrayN(unsigned short *GrayNunicode, int GrayNlen, char *GrayNutf8)
//{
//    char *ptr = GrayNutf8;
//    for(; GrayNlen > 0; GrayNlen--) {
//        unsigned short c = *GrayNunicode++;
//        if((c == 0) || (c > 0x7f)) {
//            if(c > 0x7ff) {
//                *ptr++ = (c >> 12) | 0xe0;
//                *ptr++ = ((c >> 6) & 0x3f) | 0x80;
//            } else
//                *ptr++ = (c >> 6) | 0xc0;
//            *ptr++ = (c&0x3f) | 0x80;
//        } else
//            *ptr++ = (char)c;
//    }
//
//    *ptr = '\0';
//    string temp = GrayNutf8;
//    return (int)temp.length();
//}

//int CharToUTF8(unsigned char* in, int len, char* out)
//{
//    unsigned char* temp = GrayN_UTF2Unicode_GrayN(in);
//    return GrayN_Unicode2UTF8_GrayN((unsigned short*)temp, len, out);
//}

/*
 *   GrayN_Bin2ASCII_GrayN 函数说明：
 *     将64字节的01字符串转换成对应的8个字节
 *   返回：
 *     转换后结果的指针
 *   参数：
 *     const GrayN_BYTE_GrayN byte[64] 输入字符串
 *     GrayN_BYTE_GrayN bit[8] 输出的转换结果
 */
GrayN_LPBYTE_GrayN GrayN_Bin2ASCII_GrayN(const GrayN_BYTE_GrayN GrayNbyte[64], GrayN_BYTE_GrayN GrayNbit[8])
{
    for(int i = 0; i < 8; i++)
    {
        GrayNbit[i] = GrayNbyte[i * 8] * 128 + GrayNbyte[i * 8 + 1] * 64 +
        GrayNbyte[i * 8 + 2] * 32 + GrayNbyte[i * 8 + 3] * 16 +
        GrayNbyte[i * 8 + 4] * 8 + GrayNbyte[i * 8 + 5] * 4 +
        GrayNbyte[i * 8 + 6] * 2 + GrayNbyte[i * 8 + 7];
    }
    return GrayNbit;
}

/*
 *   GrayN_ASCII2Bin_GrayN 函数说明：
 *     将8个字节输入转换成对应的64字节的01字符串
 *   返回：
 *     转换后结果的指针
 *   参数：
 *     const GrayN_BYTE_GrayN bit[8] 输入字符串
 *     GrayN_BYTE_GrayN byte[64] 输出的转换结果
 */
GrayN_LPBYTE_GrayN GrayN_ASCII2Bin_GrayN(const GrayN_BYTE_GrayN GrayNbit[8], GrayN_BYTE_GrayN GrayNbyte[64])
{
    for(int i=0; i<8; i++)
        for(int j=0; j<8; j++)
            GrayNbyte[i*8 + j] = (GrayNbit[i] >> (7-j)) & 0x01;
    return GrayNbyte;
}

/*
 *   GrayN_SReplace_GrayN 函数说明：
 *     S选择
 *   返回：
 *     无
 *   参数：
 *     GrayN_BYTE_GrayN s_bit[8] 输入暨选择后的输出
 */
void GrayN_SReplace_GrayN(GrayN_BYTE_GrayN GrayNs_bit[8])
{
    int p[32] = {
        16,7,20,21,
        29,12,28,17,
        1,15,23,26,
        5,18,31,10,
        2,8,24,14,
        32,27,3,9,
        19,13,30,6,
        22,11,4,25
    };
    GrayN_BYTE_GrayN s[][4][16] = {
        {
            14,4,13,1,2,15,11,8,3,10,6,12,5,9,0,7,
            0,15,7,4,14,2,13,1,10,6,12,11,9,5,3,8,
            4,1,14,8,13,6,2,11,15,12,9,7,3,10,5,0,
            15,12,8,2,4,9,1,7,5,11,3,14,10,0,6,13
        },
        {
            15,1,8,14,6,11,3,4,9,7,2,13,12,0,5,10,
            3,13,4,7,15,2,8,14,12,0,1,10,6,9,11,5,
            0,14,7,11,10,4,13,1,5,8,12,6,9,3,2,15,
            13,8,10,1,3,15,4,2,11,6,7,12,0,5,14,9
        },
        {
            10,0,9,14,6,3,15,5,1,13,12,7,11,4,2,8,
            13,7,0,9,3,4,6,10,2,8,5,14,12,11,15,1,
            13,6,4,9,8,15,3,0,11,1,2,12,5,10,14,7,
            1,10,13,0,6,9,8,7,4,15,14,3,11,5,2,12
        },
        {
            7,13,14,3,0,6,9,10,1,2,8,5,11,12,4,15,
            13,8,11,5,6,15,0,3,4,7,2,12,1,10,14,9,
            10,6,9,0,12,11,7,13,15,1,3,14,5,2,8,4,
            3,15,0,6,10,1,13,8,9,4,5,11,12,7,2,14
        },
        {
            2,12,4,1,7,10,11,6,8,5,3,15,13,0,14,9,
            14,11,2,12,4,7,13,1,5,0,15,10,3,9,8,6,
            4,2,1,11,10,13,7,8,15,9,12,5,6,3,0,14,
            11,8,12,7,1,14,2,13,6,15,0,9,10,4,5,3,
        },
        {
            12,1,10,15,9,2,6,8,0,13,3,4,14,7,5,11,
            10,15,4,2,7,12,9,5,6,1,13,14,0,11,3,8,
            9,14,15,5,2,8,12,3,7,0,4,10,1,13,11,6,
            4,3,2,12,9,5,15,10,11,14,1,7,6,0,8,13
        },
        {
            4,11,2,14,15,0,8,13,3,12,9,7,5,10,6,1,
            13,0,11,7,4,9,1,10,14,3,5,12,2,15,8,6,
            1,4,11,13,12,3,7,14,10,15,6,8,0,5,9,2,
            6,11,13,8,1,4,10,7,9,5,0,15,14,2,3,12
        },
        {
            13,2,8,4,6,15,11,1,10,9,3,14,5,0,12,7,
            1,15,13,8,10,3,7,4,12,5,6,11,0,14,9,2,
            7,11,4,1,9,12,14,2,0,6,10,13,15,3,5,8,
            2,1,14,7,4,10,8,13,15,12,9,0,3,5,6,11
        }
    };
    GrayN_BYTE_GrayN s_byte[64] = {0};
    GrayN_BYTE_GrayN s_byte1[64] = {0};
    GrayN_BYTE_GrayN row = 0, col = 0;
    GrayN_BYTE_GrayN s_out_bit[8] = {0};
    
    // 转成二进制字符串处理
    GrayN_ASCII2Bin_GrayN(GrayNs_bit, s_byte);
    for(int i = 0; i < 8; i++)
    {
        // 0、5位为row，1、2、3、4位为col，在S表中选择一个八位的数
        row = s_byte[i * 6] * 2 + s_byte[i * 6 + 5];
        col = s_byte[i * 6 + 1] * 8 + s_byte[i * 6 + 2] * 4 + s_byte[i * 6 + 3] * 2 + s_byte[i * 6 + 4];
        s_out_bit[i] = s[i][row][col];
    }
    // 将八个选择的八位数据压缩表示
    s_out_bit[0] = (s_out_bit[0] << 4) + s_out_bit[1];
    s_out_bit[1] = (s_out_bit[2] << 4) + s_out_bit[3];
    s_out_bit[2] = (s_out_bit[4] << 4) + s_out_bit[5];
    s_out_bit[3] = (s_out_bit[6] << 4) + s_out_bit[7];
    // 转成二进制字符串处理
    GrayN_ASCII2Bin_GrayN(s_out_bit, s_byte);
    // 换位
    for(int i = 0; i < 32; i++)
        s_byte1[i] = s_byte[p[i] - 1];
    // 生成最后结果
    GrayN_Bin2ASCII_GrayN(s_byte1, GrayNs_bit);
}

/*
 *   GrayN_GenSubKey_GrayN 函数说明：
 *     由输入的密钥得到16个子密钥
 *   返回：
 *     无
 *   参数：
 *     const GrayN_BYTE_GrayN oldkey[8] 输入密钥
 *     GrayN_BYTE_GrayN newkey[16][8] 输出的子密钥
 */

void GrayN_GenSubKey_GrayN(const GrayN_BYTE_GrayN GrayNoldkey[8], GrayN_BYTE_GrayN GrayNnewkey[16][8])
{
    int i, k, rol = 0;
    
    //缩小换位表1
    int pc_1[56] = {57,49,41,33,25,17,9,
        1,58,50,42,34,26,18,
        10,2,59,51,43,35,27,
        19,11,3,60,52,44,36,
        63,55,47,39,31,23,15,
        7,62,54,46,38,30,22,
        14,6,61,53,45,37,29,
        21,13,5,28,20,12,4};
    //缩小换位表2
    int pc_2[48] = {14,17,11,24,1,5,
        3,28,15,6,21,10,
        23,19,12,4,26,8,
        16,7,27,20,13,2,
        41,52,31,37,47,55,
        30,40,51,45,33,48,
        44,49,39,56,34,53,
        46,42,50,36,29,32};
    //16次循环左移对应的左移位数
    int ccmovebit[16] = {1,1,2,2,2,2,2,2,1,2,2,2,2,2,2,1};
    
    GrayN_BYTE_GrayN oldkey_byte[64];
    GrayN_BYTE_GrayN oldkey_byte1[64];
    GrayN_BYTE_GrayN oldkey_byte2[64];
    GrayN_BYTE_GrayN oldkey_c[56];
    GrayN_BYTE_GrayN oldkey_d[56];
    GrayN_BYTE_GrayN newkey_byte[16][64];
    
    GrayN_ASCII2Bin_GrayN(GrayNoldkey, oldkey_byte);
    
    //位变换
    for(i = 0; i < 56; i++)
        oldkey_byte1[i] = oldkey_byte[pc_1[i] - 1];
    //分为左右两部分，复制一遍以便于循环左移
    for(i = 0; i < 28; i++)
        oldkey_c[i] = oldkey_byte1[i], oldkey_c[i + 28] = oldkey_byte1[i],
        oldkey_d[i] = oldkey_byte1[i + 28], oldkey_d[i + 28] = oldkey_byte1[i + 28];
    
    // 分别生成16个子密钥
    for(i = 0; i < 16; i++) {
        // 循环左移
        rol += ccmovebit[i];
        // 合并左移后的结果
        for(k = 0; k < 28; k++)
            oldkey_byte2[k] = oldkey_c[k + rol], oldkey_byte2[k + 28] = oldkey_d[k + rol];
        // 位变换
        for(k = 0; k < 48; k++)
            newkey_byte[i][k] = oldkey_byte2[pc_2[k] - 1];
        
    }
    // 生成最终结果
    for(i = 0; i < 16; i++)
        GrayN_Bin2ASCII_GrayN(newkey_byte[i], GrayNnewkey[i]);
}
/*
 *   endes 函数说明：
 *     DES加密
 *   返回：
 *     无
 *   参数：
 *     const GrayN_BYTE_GrayN m_bit[8] 输入的原文
 *     const GrayN_BYTE_GrayN k_bit[8] 输入的密钥
 *     GrayN_BYTE_GrayN e_bit[8] 输出的密文
 */
void GrayN_EnDES_GrayN(const GrayN_BYTE_GrayN GrayNm_bit[8], const GrayN_BYTE_GrayN GrayNk_bit[8], GrayN_BYTE_GrayN GrayNe_bit[8])
{
    // 换位表IP
    int ip[64] = {
        58,50,42,34,26,18,10,2,
        60,52,44,36,28,20,12,4,
        62,54,46,38,30,22,14,6,
        64,56,48,40,32,24,16,8,
        57,49,41,33,25,17,9,1,
        59,51,43,35,27,19,11,3,
        61,53,45,37,29,21,13,5,
        63,55,47,39,31,23,15,7
    };
    
    // 换位表IP_1
    int ip_1[64] = {
        40,8,48,16,56,24,64,32,
        39,7,47,15,55,23,63,31,
        38,6,46,14,54,22,62,30,
        37,5,45,13,53,21,61,29,
        36,4,44,12,52,20,60,28,
        35,3,43,11,51,19,59,27,
        34,2,42,10,50,18,58,26,
        33,1,41,9,49,17,57,25
    };
    
    // 放大换位表
    int e[48] = {
        32,1, 2, 3, 4, 5,
        4, 5, 6, 7, 8, 9,
        8, 9, 10,11,12,13,
        12,13,14,15,16,17,
        16,17,18,19,20,21,
        20,21,22,23,24,25,
        24,25,26,27,28,29,
        28,29,30,31,32,1
    };
    GrayN_BYTE_GrayN m_bit1[8] = {0};
    GrayN_BYTE_GrayN m_byte[64] = {0};
    GrayN_BYTE_GrayN m_byte1[64] = {0};
    GrayN_BYTE_GrayN key_n[16][8] = {0};
    GrayN_BYTE_GrayN l_bit[17][8] = {0};
    GrayN_BYTE_GrayN r_bit[17][8] = {0};
    GrayN_BYTE_GrayN e_byte[64] = {0};
    GrayN_BYTE_GrayN e_byte1[64] = {0};
    GrayN_BYTE_GrayN r_byte[64] = {0};
    GrayN_BYTE_GrayN r_byte1[64] = {0};
    int i, j;
    
    // 根据密钥生成16个子密钥
    GrayN_GenSubKey_GrayN(GrayNk_bit, key_n);
    // 将待加密字串变换成01串
    GrayN_ASCII2Bin_GrayN(GrayNm_bit, m_byte);
    // 按照ip表对待加密字串进行位变换
    for(i = 0; i < 64; i++)
        m_byte1[i] = m_byte[ip[i] - 1];
    // 位变换后的待加密字串
    GrayN_Bin2ASCII_GrayN(m_byte1, m_bit1);
    // 将位变换后的待加密字串分成两组，分别为前4字节L和后4字节R，作为迭代的基础（第0次迭代）
    for(i = 0; i < 4; i++)
        l_bit[0][i] = m_bit1[i], r_bit[0][i] = m_bit1[i + 4];
    
    // 16次迭代运算
    for(i = 1; i <= 16; i++)
    {
        // R的上一次的迭代结果作为L的当前次迭代结果
        for(j = 0; j < 4; j++)
            l_bit[i][j] = r_bit[i-1][j];
        
        GrayN_ASCII2Bin_GrayN(r_bit[i-1], r_byte);
        // 将R的上一次迭代结果按E表进行位扩展得到48位中间结果
        for(j = 0; j < 48; j++)
            r_byte1[j] = r_byte[e[j] - 1];
        GrayN_Bin2ASCII_GrayN(r_byte1, r_bit[i-1]);
        
        // 与第I-1个子密钥进行异或运算
        for(j = 0; j < 6; j++)
            r_bit[i-1][j] = r_bit[i-1][j] ^ key_n[i-1][j];
        
        // 进行S选择，得到32位中间结果
        GrayN_SReplace_GrayN(r_bit[i - 1]);
        
        // 结果与L的上次迭代结果异或得到R的此次迭代结果
        for(j = 0; j < 4; j++)
        {
            r_bit[i][j] = l_bit[i-1][j] ^ r_bit[i-1][j];
        }
    }
    // 组合最终迭代结果
    for(i = 0; i < 4; i++)
        GrayNe_bit[i] = r_bit[16][i], GrayNe_bit[i + 4] = l_bit[16][i];
    
    GrayN_ASCII2Bin_GrayN(GrayNe_bit, e_byte);
    // 按照表IP-1进行位变换
    for(i = 0; i < 64; i++)
        e_byte1[i] = e_byte[ip_1[i] - 1];
    // 得到最后的加密结果
    GrayN_Bin2ASCII_GrayN(e_byte1, GrayNe_bit);
}
/*
 *   GrayN_UnDES_GrayN 函数说明：
 *     DES解密，与加密步骤完全相同，只是迭代顺序是从16到1
 *   返回：
 *     无
 *   参数：
 *     const GrayN_BYTE_GrayN m_bit[8] 输入的密文
 *     const GrayN_BYTE_GrayN k_bit[8] 输入的密钥
 *     GrayN_BYTE_GrayN e_bit[8] 输出解密后的原文
 */
void GrayN_UnDES_GrayN(const GrayN_BYTE_GrayN GrayNm_bit[8], const GrayN_BYTE_GrayN GrayNk_bit[8], GrayN_BYTE_GrayN GrayNe_bit[8])
{
    // 换位表IP
    int ip[64] = {
        58,50,42,34,26,18,10,2,
        60,52,44,36,28,20,12,4,
        62,54,46,38,30,22,14,6,
        64,56,48,40,32,24,16,8,
        57,49,41,33,25,17,9,1,
        59,51,43,35,27,19,11,3,
        61,53,45,37,29,21,13,5,
        63,55,47,39,31,23,15,7
    };
    // 换位表IP_1
    int ip_1[64] = {
        40,8,48,16,56,24,64,32,
        39,7,47,15,55,23,63,31,
        38,6,46,14,54,22,62,30,
        37,5,45,13,53,21,61,29,
        36,4,44,12,52,20,60,28,
        35,3,43,11,51,19,59,27,
        34,2,42,10,50,18,58,26,
        33,1,41,9,49,17,57,25
    };
    // 放大换位表
    int e[48] = {
        32,1, 2, 3, 4, 5,
        4, 5, 6, 7, 8, 9,
        8, 9, 10,11,12,13,
        12,13,14,15,16,17,
        16,17,18,19,20,21,
        20,21,22,23,24,25,
        24,25,26,27,28,29,
        28,29,30,31,32,1
    };
    GrayN_BYTE_GrayN m_bit1[8] = {0};
    GrayN_BYTE_GrayN m_byte[64] = {0};
    GrayN_BYTE_GrayN m_byte1[64] = {0};
    GrayN_BYTE_GrayN key_n[16][8] = {0};
    GrayN_BYTE_GrayN l_bit[17][8] = {0};
    GrayN_BYTE_GrayN r_bit[17][8] = {0};
    GrayN_BYTE_GrayN e_byte[64] = {0};
    GrayN_BYTE_GrayN e_byte1[64] = {0};
    GrayN_BYTE_GrayN l_byte[64] = {0};
    GrayN_BYTE_GrayN l_byte1[64] = {0};
    int i = 0, j = 0;
    
    // 根据密钥生成16个子密钥
    GrayN_GenSubKey_GrayN(GrayNk_bit, key_n);
    // 将待加密字串变换成01串
    GrayN_ASCII2Bin_GrayN(GrayNm_bit, m_byte);
    // 按照ip表对待加密字串进行位变换
    for(i = 0; i < 64; i++)
        m_byte1[i] = m_byte[ip[i] - 1];
    // 位变换后的待加密字串
    GrayN_Bin2ASCII_GrayN(m_byte1, m_bit1);
    // 将位变换后的待加密字串分成两组，分别为前4字节R和后4字节L，作为迭代的基础（第16次迭代）
    for(i = 0; i < 4; i++)
        r_bit[16][i] = m_bit1[i], l_bit[16][i] = m_bit1[i + 4];
    
    // 16次迭代运算
    for(i = 16; i > 0; i--)
    {
        // L的上一次的迭代结果作为R的当前次迭代结果
        for(j = 0; j < 4; j++)
            r_bit[i-1][j] = l_bit[i][j];
        
        GrayN_ASCII2Bin_GrayN(l_bit[i], l_byte);
        // 将L的上一次迭代结果按E表进行位扩展得到48位中间结果
        for(j = 0; j < 48; j++)
            l_byte1[j] = l_byte[e[j] - 1];
        GrayN_Bin2ASCII_GrayN(l_byte1, l_bit[i]);
        
        // 与第I-1个子密钥进行异或运算
        for(j = 0; j < 6; j++)
            l_bit[i][j] = l_bit[i][j] ^ key_n[i-1][j];
        
        // 进行S选择，得到32位中间结果
        GrayN_SReplace_GrayN(l_bit[i]);
        
        // 结果与R的上次迭代结果异或得到L的此次迭代结果
        for(j = 0; j < 4; j++)
        {
            l_bit[i-1][j] = r_bit[i][j] ^ l_bit[i][j];
        }
    }
    // 组合最终迭代结果
    for(i = 0; i < 4; i++)
        GrayNe_bit[i] = l_bit[0][i], GrayNe_bit[i + 4] = r_bit[0][i];
    
    GrayN_ASCII2Bin_GrayN(GrayNe_bit, e_byte);
    // 按照表IP-1进行位变换
    for(i = 0; i < 64; i++)
        e_byte1[i] = e_byte[ip_1[i] - 1];
    // 得到最后的结果
    GrayN_Bin2ASCII_GrayN(e_byte1, GrayNe_bit);
}
/*
 *   CDesEnter 函数说明：
 *     des加密/解密入口
 *   返回：
 *     1则成功,0失败
 *   参数：
 *     in 需要加密或解密的数据
 *         注意：in缓冲区的大小必须和datalen相同.
 *     out 加密后或解密后输出。
 *         注意：out缓冲区大小必须是8的倍数而且比datalen大或者相等。
 *         如datalen=7，out缓冲区的大小应该是8，datalen=8,out缓冲区的大小应该是8,
 *         datalen=9,out缓冲区的大小应该是16，依此类推。
 *     datalen 数据长度(字节)。
 *         注意:datalen 必须是8的倍数。
 *     key 8个字节的加密或解密的密码。
 *     type 是对数据进行加密还是解密
 *         0 表示加密 1 表示解密
 */
int GrayN_Des_GrayN::GrayN_CDesEnter(GrayN_LPCBYTE_GrayN GrayNin, GrayN_LPBYTE_GrayN GrayNout, int GrayNdatalen, const GrayN_BYTE_GrayN GrayNkey[8], int GrayNtype)
{
    // 判断输入参数是否正确，失败的情况为：
    // !in： in指针（输入缓冲）无效
    // !out： out指针（输出缓冲）无效
    // datalen<1： 数据长度不正确
    // !key： 加/解密密码无效
    // type && ((datalen % 8) !=0：选择解密方式但是输入密文不为8的倍数
    if ((!GrayNin) || (!GrayNout) || (GrayNdatalen<1) || (!GrayNkey) || (GrayNtype && ((GrayNdatalen%8) != 0))) {
        GrayNcommon::GrayN_DebugLog("Des解密失败，输入字符有问题");
        return false;
    }
    
    if (GrayNtype == 0) //选择的模式是加密
    {
        // 用于存储待加密字串最后的若干字节
        // DES算法是以8个字节为单位进行加密，如果待加密字串以8为单位分段加密时，最后一段不足
        // 8字节，则在后面补0，使其最后一段的长度为8字节
        // te8bit是作为存储待加密字串最后一段（不足8字节）的变量
        GrayN_BYTE_GrayN te8bit[8]={0,0,0,0,0,0,0,0};
        
        // 这是待加密字串的调整长度
        // 如果原始长度是8的整数倍，则调整长度的值和原来的长度一样
        // 如果原始长度不是8的整数倍，则调整长度的值是能被8整除且不大于原来长度的最大整数。
        // 也就是不需要补齐的块的总长度。
        int te_fixlen = GrayNdatalen - (GrayNdatalen % 8);
        
        // 将待加密密文以8为单位分段，把最后长度不足8的一段存储到te8bit中。
        for(int i = 0; i < (GrayNdatalen % 8); i++)
            te8bit[i] = GrayNin[te_fixlen + i];
        
        // 将待加密字串分以8字节为单位分段加密
        for(int i = 0; i < te_fixlen; i += 8)
            GrayN_EnDES_GrayN(GrayNin + i, GrayNkey, GrayNout + i);
        
        // 如果待加密字串不是8的整数倍，则将最后一段补齐（补0）后加密
        if(GrayNdatalen % 8 != 0)
            GrayN_EnDES_GrayN(te8bit, GrayNkey, GrayNout + GrayNdatalen / 8 * 8);
    }
    else   //选择的模式是解密
    {
        // 将密文以8字节为单位分段解密
        for(int i = 0; i < GrayNdatalen; i += 8)
        {
            if(i == 184)
            {
                //i-=4;
            }
            GrayN_UnDES_GrayN(GrayNin + i, GrayNkey, GrayNout + i);
        }
    }
    return true;
}
/* 加密 */
void GrayN_Des_GrayN::GrayN_DesEncrypt(string GrayNIn, string GrayNKey, string& GrayNOut)
{
    int len = (int)(GrayNIn.length()+7)/8*8;
    unsigned char* charOut = new unsigned char[len+1];
    GrayN_CDesEnter((unsigned char*)GrayNIn.c_str(), charOut,(int)GrayNIn.length(), (const unsigned char*)GrayNKey.c_str(), 0);
    GrayN_Char2Hex_GrayN(charOut, len, GrayNOut);
    delete[] charOut;
}
/* 解密 */
void GrayN_Des_GrayN::GrayN_DesDecrypt(string GrayNIn, string GrayNKey, string& GrayNOut)
{
    if (GrayNIn == "") {
        return;
    }
    unsigned char* charIn = new unsigned char[GrayNIn.length()/2];
    int len = GrayN_Hex2Char_GrayN(GrayNIn, charIn);
    unsigned char* charOut = new unsigned char[len+1];
    GrayN_CDesEnter(charIn, charOut, len, (const unsigned char*)GrayNKey.c_str(), 1);
    
    string desOut = (char*)charOut;
    // 保证输出字符串长度跟输入一致
    desOut = desOut.substr(0, GrayNIn.length()/2);
    GrayNOut = desOut;
    
    delete[] charIn;
    delete[] charOut;
}
void GrayN_Des_GrayN::GrayN_DesEncrypt(string GrayNIn, string &GrayNOut)
{
    string data = "";
    string desData = "";
    GrayN_Des_GrayN::GrayN_DesEncrypt(GrayNIn, GrayNcommon::m_GrayN_SecretKey.c_str(), desData);
    data.append(desData);
    data.append(GrayNcommon::m_GrayN_DesKey.c_str());
    
    GrayNOut = data;
}
void GrayN_Des_GrayN::GrayN_DesDecrypt(string GrayNIn, string &GrayNOut)
{
    if (GrayNIn == "") {
        return;
    }
    // 必须从密文后16位解出密钥，该密钥不一定==m_GrayN_SecretKey
    string decodeStr = "";
    decodeStr.append(GrayNIn);
    string desPro = decodeStr.substr(0, decodeStr.length()-16);
    //    cout<<"desPro"<<endl;
    //    cout<<desPro<<endl;
    string desKey = decodeStr.substr(decodeStr.length()-16, decodeStr.length());
    //    cout<<"desKey"<<endl;
    //    cout<<desKey<<endl;
    
    string desDecodeKey = "";
    
    GrayN_Des_GrayN::GrayN_DesDecrypt(desKey, GrayNprivateKey, desDecodeKey);
//    cout<<desDecodeKey<<endl;
    GrayN_Des_GrayN::GrayN_DesDecrypt(desPro, desDecodeKey, decodeStr);
//    cout<<decodeStr<<endl;
    GrayNOut = decodeStr;
}

GrayN_NameSpace_End
