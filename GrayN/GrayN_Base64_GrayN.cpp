//
//  Base64.cpp
//
//  Created by op-mac1 on 13-9-13.
//
//

#import "GrayN_Base64_GrayN.h"

GrayNusing_NameSpace;

static const char *p_GrayNg_pCodes =
"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";

static const unsigned char p_GrayNg_pMap[256] =
{
	255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
	255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
	255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
	255, 255, 255, 255, 255, 255, 255,  62, 255, 255, 255,  63,
    52,  53,  54,  55,  56,  57,  58,  59,  60,  61, 255, 255,
	255, 254, 255, 255, 255,   0,   1,   2,   3,   4,   5,   6,
    7,   8,   9,  10,  11,  12,  13,  14,  15,  16,  17,  18,
    19,  20,  21,  22,  23,  24,  25, 255, 255, 255, 255, 255,
	255,  26,  27,  28,  29,  30,  31,  32,  33,  34,  35,  36,
    37,  38,  39,  40,  41,  42,  43,  44,  45,  46,  47,  48,
    49,  50,  51, 255, 255, 255, 255, 255, 255, 255, 255, 255,
	255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
	255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
	255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
	255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
	255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
	255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
	255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
	255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
	255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
	255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
	255, 255, 255, 255
};

GrayN_Base64_GrayN::GrayN_Base64_GrayN()
{
}

GrayN_Base64_GrayN::~GrayN_Base64_GrayN()
{
}

bool GrayN_Base64_GrayN::GrayN_Base64Encode(const unsigned char *GrayNpIn, unsigned long uInLen, unsigned char *GrayNpOut, unsigned long *GrayNuOutLen)
{
	unsigned long i, len2, leven;
	unsigned char *p;
    
	if(GrayNpOut == NULL || *GrayNuOutLen == 0)
		return false;
    
	//ASSERT((pIn != NULL) && (uInLen != 0) && (pOut != NULL) && (uOutLen != NULL));
    
	len2 = ((uInLen + 2) / 3) << 2;
	if((*GrayNuOutLen) < (len2 + 1)) return false;
    
	p = GrayNpOut;
	leven = 3 * (uInLen / 3);
	for(i = 0; i < leven; i += 3)
	{
		*p++ = p_GrayNg_pCodes[GrayNpIn[0] >> 2];
		*p++ = p_GrayNg_pCodes[((GrayNpIn[0] & 3) << 4) + (GrayNpIn[1] >> 4)];
		*p++ = p_GrayNg_pCodes[((GrayNpIn[1] & 0xf) << 2) + (GrayNpIn[2] >> 6)];
		*p++ = p_GrayNg_pCodes[GrayNpIn[2] & 0x3f];
		GrayNpIn += 3;
	}
    
	if (i < uInLen)
	{
		unsigned char a = GrayNpIn[0];
		unsigned char b = ((i + 1) < uInLen) ? GrayNpIn[1] : 0;
		unsigned char c = 0;
        
		*p++ = p_GrayNg_pCodes[a >> 2];
		*p++ = p_GrayNg_pCodes[((a & 3) << 4) + (b >> 4)];
		*p++ = ((i + 1) < uInLen) ? p_GrayNg_pCodes[((b & 0xf) << 2) + (c >> 6)] : '=';
		*p++ = '=';
	}
    
	*p = 0; // Append NULL byte
	*GrayNuOutLen = p - GrayNpOut;
	return true;
}

bool GrayN_Base64_GrayN::GrayN_Base64Encode(const unsigned char *GrayNpIn, unsigned long GrayNuInLen, string& GrayNstrOut)
{
	unsigned long i, len2, leven;
	GrayNstrOut = "";
    
	//ASSERT((pIn != NULL) && (uInLen != 0) && (pOut != NULL) && (uOutLen != NULL));
    
	len2 = ((GrayNuInLen + 2) / 3) << 2;
	//if((*uOutLen) < (len2 + 1)) return false;
    
	//p = pOut;
	leven = 3 * (GrayNuInLen / 3);
	for(i = 0; i < leven; i += 3)
	{
		GrayNstrOut += p_GrayNg_pCodes[GrayNpIn[0] >> 2];
		GrayNstrOut += p_GrayNg_pCodes[((GrayNpIn[0] & 3) << 4) + (GrayNpIn[1] >> 4)];
		GrayNstrOut += p_GrayNg_pCodes[((GrayNpIn[1] & 0xf) << 2) + (GrayNpIn[2] >> 6)];
		GrayNstrOut += p_GrayNg_pCodes[GrayNpIn[2] & 0x3f];
		GrayNpIn += 3;
	}
    
	if (i < GrayNuInLen)
	{
		unsigned char a = GrayNpIn[0];
		unsigned char b = ((i + 1) < GrayNuInLen) ? GrayNpIn[1] : 0;
		unsigned char c = 0;
        
		GrayNstrOut += p_GrayNg_pCodes[a >> 2];
		GrayNstrOut += p_GrayNg_pCodes[((a & 3) << 4) + (b >> 4)];
		GrayNstrOut += ((i + 1) < GrayNuInLen) ? p_GrayNg_pCodes[((b & 0xf) << 2) + (c >> 6)] : '=';
		GrayNstrOut += '=';
	}
    
	//*p = 0; // Append NULL byte
	//*uOutLen = p - pOut;
	return true;
}

bool GrayN_Base64_GrayN::GrayN_Base64Decode(string& GrayNstrIn, unsigned char *GrayNpOut, unsigned long *GrayNuOutLen)
{
	unsigned long t, x, y, z;
	unsigned char c;
	unsigned long g = 3;
    
	//ASSERT((pIn != NULL) && (uInLen != 0) && (pOut != NULL) && (uOutLen != NULL));
    
	for(x = y = z = t = 0; x < GrayNstrIn.length(); x++)
	{
		c = p_GrayNg_pMap[GrayNstrIn[x]];
		if(c == 255) continue;
		if(c == 254) { c = 0; g--; }
        
		t = (t << 6) | c;
        
		if(++y == 4)
		{
			if((z + g) > *GrayNuOutLen) { return false; } // Buffer overflow
			GrayNpOut[z++] = (unsigned char)((t>>16)&255);
			if(g > 1) GrayNpOut[z++] = (unsigned char)((t>>8)&255);
			if(g > 2) GrayNpOut[z++] = (unsigned char)(t&255);
			y = t = 0;
		}
	}
    
	*GrayNuOutLen = z;
	return true;
}

