#ifndef OurpalmSDK_OPStream_h
#define OurpalmSDK_OPStream_h


#import "GrayNconfig.h"
#import <string.h>
#ifdef __cplusplus
enum Endian
{
    Big_Endian,
    Little_Endian
};
class GrayN_InputStream;
class GrayN_OutputStream;
class GrayN_CONSTANT_Utf8
{
private:
    unsigned int	length;
    char*			data;
public:
    GrayN_CONSTANT_Utf8();
    virtual ~GrayN_CONSTANT_Utf8();
public:
    GrayN_CONSTANT_Utf8(const GrayN_CONSTANT_Utf8& other);
    GrayN_CONSTANT_Utf8(const char* other);
    const GrayN_CONSTANT_Utf8& operator=(const GrayN_CONSTANT_Utf8& other);
    const GrayN_CONSTANT_Utf8& operator=(const char* other);
public:
    void                Read(GrayN_InputStream& is);
    void                Read4HeadUTF(GrayN_InputStream& is);//字符数量是4个字节的（粒子编辑器格式）
    void                Write(GrayN_OutputStream& os);
    inline const char*  Data() const {return data;}
    inline int          Length(){return length;}
    void                Set(const char* value);
    bool                Equal(const GrayN_CONSTANT_Utf8* other);
    bool                Equal(const char* other);
    int                 IndexOf(char ch);
    int                 LastIndexOf(char ch);
};
class GrayN_InputStream
{
protected:
    GrayN_InputStream();
public:
    GrayN_InputStream(char* data,int length,Endian type=Big_Endian);
    virtual ~GrayN_InputStream();
public:
    void            Set(char* data,int length,Endian type=Big_Endian);
    inline char*    Data(){return data;}
    inline int		Offset(){return offset;}
    void            Offset(int of){offset=of;}
    char            ReadByte();
    bool            ReadBoolean();
    void            Read(char* buf,int length);
    void            Skip(int bytes);
    short           ReadShort();
    int             ReadUnsignedShort();
    int             ReadInt();
    float           ReadFloat();
    double          ReadDouble();
    long long       ReadLong();
    inline int      Available(){return dataLength-offset;}
    inline int 		Length(){return dataLength;}
protected:
    char*   data;
    Endian  type;
    int     dataLength;
    int     offset;
};


class GrayN_OutputStream
{
public:
    GrayN_OutputStream(Endian type=Big_Endian);
    virtual ~GrayN_OutputStream(){}
public:
    virtual void    Write(char* buffer,int length)=0;
    inline void     Write(const char* str){Write((char*)str, strlen(str));}
    inline void     WriteByte(char b){Write(&b, 1);}
    inline void     WriteBoolean(bool b){WriteByte(b?1:0);}
    void			WriteShort(short s);
    void            WriteInt(int i);
    void            WriteFloat(float f);
    void            WriteDouble(double d);
    void            WriteLong(long long l);
protected:
    Endian  type;
};

class ByteArrayOutputStream : public GrayN_OutputStream
{
public:
    ByteArrayOutputStream(int capcity=64,Endian type=Big_Endian);
    ~ByteArrayOutputStream();
public:
    void            Write(char* buffer,int length);
    inline char*    Data(){return buffer;}
    inline int      Length(){return length;}
    inline void     Clear(){length=0;}
    void            RemoveHead(int count);
protected:
    char*   buffer;
    int     length;
    int     capcity;
};
#endif

#endif
