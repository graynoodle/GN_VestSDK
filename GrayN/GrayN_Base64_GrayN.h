

#import <iostream>
#import <string>

using namespace std;

#import "GrayNconfig.h"

GrayN_NameSpace_Start
class GrayN_Base64_GrayN
{
public:
	GrayN_Base64_GrayN();
	~GrayN_Base64_GrayN();
    
	/*********************************************************
     * 函数说明：将输入数据进行base64编码
     * 参数说明：[in]pIn		需要进行编码的数据
     [in]uInLen  输入参数的字节数
     [out]strOut 输出的进行base64编码之后的字符串
     * 返回值  ：true处理成功,false失败
     * 作  者  ：ChenLi
     * 编写时间：2009-02-17
     **********************************************************/
	bool static GrayN_Base64Encode(const unsigned char *GrayNpIn, unsigned long GrayNuInLen, string& GrayNstrOut);
    
	/*********************************************************
     * 函数说明：将输入数据进行base64编码
     * 参数说明：[in]pIn			需要进行编码的数据
     [in]uInLen		输入参数的字节数
     [out]pOut		输出的进行base64编码之后的字符串
     [out]uOutLen	输出的进行base64编码之后的字符串长度
     * 返回值  ：true处理成功,false失败
     * 作  者  ：ChenLi
     * 编写时间：2009-02-17
     **********************************************************/
	bool static GrayN_Base64Encode(const unsigned char *GrayNpIn, unsigned long GrayNuInLen, unsigned char *GrayNpOut, unsigned long *GrayNuOutLen);
	
	/*********************************************************
     * 函数说明：将输入数据进行base64解码
     * 参数说明：[in]strIn		需要进行解码的数据
     [out]pOut		输出解码之后的节数数据
     [out]uOutLen	输出的解码之后的字节数长度
     * 返回值  ：true处理成功,false失败
     * 作  者  ：ChenLi
     * 编写时间：2009-02-17
     **********************************************************/
	bool static GrayN_Base64Decode(string& GrayNstrIn, unsigned char *GrayNpOut, unsigned long *GrayNuOutLen) ;
    
	/*********************************************************
     * 函数说明：将输入数据进行base64解码
     * 参数说明：[in]strIn		需要进行解码的数据
     [out]pOut		输出解码之后的节数数据
     [out]uOutLen	输出的解码之后的字节数长度
     * 返回值  ：true处理成功,false失败
     * 作  者  ：ChenLi
     * 编写时间：2009-02-17
     **********************************************************/
	bool static GrayN_Base64Decode(const unsigned char *GrayNpIn, unsigned long GrayNuInLen, unsigned char *GrayNpOut, unsigned long *GrayNuOutLen) ;
};

GrayN_NameSpace_End

