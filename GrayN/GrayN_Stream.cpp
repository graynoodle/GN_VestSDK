#import <string>
#import "GrayN_Stream.h"
#import <assert.h>

    GrayN_CONSTANT_Utf8::GrayN_CONSTANT_Utf8():length(0),data(NULL)
    {
    }
    GrayN_CONSTANT_Utf8::~GrayN_CONSTANT_Utf8()
    {
        delete[] data;
    }
    GrayN_CONSTANT_Utf8::GrayN_CONSTANT_Utf8(const GrayN_CONSTANT_Utf8& other):length(0),data(NULL)
    {
        this->Set(other.data);
    }
    GrayN_CONSTANT_Utf8::GrayN_CONSTANT_Utf8(const char* other):length(0),data(NULL)
    {
        this->Set(other);
    }
    const GrayN_CONSTANT_Utf8& GrayN_CONSTANT_Utf8::operator=(const GrayN_CONSTANT_Utf8& other)
    {
        if(&other!=this)
        {
            this->Set(other.data);
        }
        return *this;
    }
    const GrayN_CONSTANT_Utf8& GrayN_CONSTANT_Utf8::operator=(const char* other)
    {
        this->Set(other);
        return *this;
    }
    void GrayN_CONSTANT_Utf8::Read(GrayN_InputStream& is)
    {
        int newLength=is.ReadShort();
        if(data==NULL||newLength>length)
        {
            delete[] data;
            data=new char[newLength+1];
        }
        is.Read(data, newLength);
        length=newLength;
        data[newLength]=0;
    }
    void GrayN_CONSTANT_Utf8::Read4HeadUTF(GrayN_InputStream& is)
    {
        int newLength=is.ReadInt();
        if(data==NULL||newLength>length)
        {
            delete data;
            data=new char[newLength+1];
        }
        is.Read(data, newLength);
        length=newLength;
        data[newLength]=0;
    }
    void GrayN_CONSTANT_Utf8::Write(GrayN_OutputStream& os)
    {
        os.WriteShort(length);
        os.Write(data, length);
    }
    void GrayN_CONSTANT_Utf8::Set(const char* value)
    {
        if(value==NULL)
        {
            value="";
        }
        int newLength=strlen(value);
        if(data==NULL||newLength>length)
        {
            delete[] data;
            data=new char[newLength+1];
        }
        memcpy(data, value, newLength);
        length=newLength;
        data[newLength]=0;
    }
    bool   GrayN_CONSTANT_Utf8::Equal(const GrayN_CONSTANT_Utf8* other)
    {
        if(other->length==this->length&&memcmp(data, other->data, this->length)==0)
        {
            return true;
        }
        return false;
    }
    bool  GrayN_CONSTANT_Utf8::Equal(const char* other)
    {
        int otherLength=strlen(other);
        if(otherLength==this->length&&memcmp(data, other, this->length)==0)
        {
            return true;
        }
        return false;
    }
    int GrayN_CONSTANT_Utf8::IndexOf(char ch)
    {
        for(int i=0;i<length;i++)
        {
            if(data[i]==ch)
            {
                return i;
            }
        }
        return -1;
    }
    int GrayN_CONSTANT_Utf8::LastIndexOf(char ch)
    {
        for(int i=length-1;i>=0;i--)
        {
            if(data[i]==ch)
            {
                return i;
            }
        }
        return -1;
    }
    
    
    
    GrayN_InputStream::GrayN_InputStream()
    {
        data=NULL;
        dataLength=0;
        offset=0;
    }
    GrayN_InputStream::~GrayN_InputStream()
    {
    }
    GrayN_InputStream::GrayN_InputStream(char* data,int length,Endian type):data(data),type(type),dataLength(length),offset(0)
    {
    }
    void GrayN_InputStream::Set(char* data,int length,Endian type)
    {
        this->data=data;
        this->dataLength=length;
        this->offset=0;
        this->type=type;
    }
    char GrayN_InputStream::ReadByte()
    {
        if(data==NULL)
        {
            //            MY_THROW(NullPointerException, "GrayN_InputStream::ReadByte");
            assert(false);
        }
        if((offset+1)>Length())
        {
            char buffer[64];
            snprintf(buffer, 64, "GrayN_InputStream::ReadByte(offset:%d,length:%d)",offset,Length());
            //            MY_THROW(IOException, buffer);
            assert(false);
        }
        return data[offset++];
    }
    bool GrayN_InputStream::ReadBoolean()
    {
        if(data==NULL){
            //            MY_THROW(NullPointerException, "GrayN_InputStream::ReadBoolean");
            assert(false);
        }
        if((offset+1)>Length())
        {
            char buffer[64];
            snprintf(buffer, 64, "GrayN_InputStream::ReadBoolean(offset:%d,length:%d)",offset,Length());
            //            MY_THROW(IOException, buffer);
            assert(false);
        }
        
        return data[offset++]?true:false;
    }
    void GrayN_InputStream::Read(char* buf,int length)
    {
        if(data==NULL||buf==NULL){
            //            MY_THROW(NullPointerException, "GrayN_InputStream::Read");
            assert(false);
        }
        if((offset+length)>Length()||length<0)
        {
            char buffer[128];
            snprintf(buffer, 128, "GrayN_InputStream::Read(offset:%d,length:%d,available=%d,readLength:%d)",offset,Length(),Available(),length);
            //            MY_THROW(IOException, buffer);
            assert(false);
        }
        
        
        memcpy(buf,data+offset,length);
        offset+=length;
    }
    void GrayN_InputStream::Skip(int bytes)
    {
        int end=offset+bytes;
        if(end>Length()){
            //            MY_THROW(IOException, "GrayN_InputStream::Skip");
            assert(false);
        }
        offset=end;
    }
    short GrayN_InputStream::ReadShort()
    {
        int b1=ReadByte()&0xFF;
        int b2=ReadByte()&0xFF;
        if(type==Big_Endian)
        {
            return (short)((b1<<8)|b2);
        }else
        {
            return (short)((b2<<8)|b1);
        }
    }
    int GrayN_InputStream::ReadUnsignedShort()
    {
        int b1=ReadByte()&0xFF;
        int b2=ReadByte()&0xFF;
        if(type==Big_Endian)
        {
            return ((b1<<8)|b2);
        }else
        {
            return ((b2<<8)|b1);
        }
    }
    int GrayN_InputStream::ReadInt()
    {
        int b1=ReadByte()&0xFF;
        int b2=ReadByte()&0xFF;
        int b3=ReadByte()&0xFF;
        int b4=ReadByte()&0xFF;
        if(type==Big_Endian)
        {
            return (b1<<24)|(b2<<16)|(b3<<8)|(b4<<0);
        }else
        {
            return (b4<<24)|(b3<<16)|(b2<<8)|(b1<<0);
        }
    }
    float GrayN_InputStream::ReadFloat()
    {
        char buf[4];
        buf[0]=ReadByte()&0xFF;
        buf[1]=ReadByte()&0xFF;
        buf[2]=ReadByte()&0xFF;
        buf[3]=ReadByte()&0xFF;
        return *((float*)&buf);
    }
    double GrayN_InputStream::ReadDouble()
    {
        char buf[8];
        buf[0]=ReadByte()&0xFF;
        buf[1]=ReadByte()&0xFF;
        buf[2]=ReadByte()&0xFF;
        buf[3]=ReadByte()&0xFF;
        buf[4]=ReadByte()&0xFF;
        buf[5]=ReadByte()&0xFF;
        buf[6]=ReadByte()&0xFF;
        buf[7]=ReadByte()&0xFF;
        return *(double*)&buf;
    }
    long long GrayN_InputStream::ReadLong()
    {
        long long b0=ReadByte()&0xFF;
        long long b1=ReadByte()&0xFF;
        long long b2=ReadByte()&0xFF;
        long long b3=ReadByte()&0xFF;
        long long b4=ReadByte()&0xFF;
        long long b5=ReadByte()&0xFF;
        long long b6=ReadByte()&0xFF;
        long long b7=ReadByte()&0xFF;
        if(type==Big_Endian)
        {
            return (b0<<56)|(b1<<48)|(b2<<40)|(b3<<32)|(b4<<24)|(b5<<16)|(b6<<8)|(b7<<0);
        }else
        {
            return ((b7<<56)|(b6<<48)|(b5<<40)|(b4<<32))||((b3<<24)|(b2<<16)|(b1<<8)|(b0<<0));
        }
    }
    
    GrayN_OutputStream::GrayN_OutputStream(Endian type)
    {
        this->type=type;
    }
    
    void GrayN_OutputStream::WriteShort(short v)
    {
        char buf[2];
        if(type==Big_Endian)
        {
            buf[0]=(v>>8);
            buf[1]=(v);
        }else
        {
            buf[0]=(v);
            buf[1]=(v>>8);
        }
        Write(buf, 2);
    }
    void GrayN_OutputStream::WriteInt(int v)
    {
        char buf[4];
        if(type==Big_Endian)
        {
            buf[0]=(v>>24);
            buf[1]=(v>>16);
            buf[2]=(v>>8);
            buf[3]=(v);
        }else
        {
            buf[0]=(v);
            buf[1]=(v>>8);
            buf[2]=(v>>16);
            buf[3]=(v>>24);
        }
        Write(buf, 4);
    }
    void GrayN_OutputStream::WriteFloat(float f)
    {
        char* buf=(char*)&f;
        Write(buf, 4);
    }
    void GrayN_OutputStream::WriteDouble(double d)
    {
        char* buf=(char*)&d;
        Write(buf, 8);
    }
    void GrayN_OutputStream::WriteLong(long long v)
    {
        char buf[8];
        if(type==Big_Endian)
        {
            buf[0]=(v>>56);
            buf[1]=(v>>48);
            buf[2]=(v>>40);
            buf[3]=(v>>32);
            buf[4]=(v>>24);
            buf[5]=(v>>16);
            buf[6]=(v>>8);
            buf[7]=(v);
        }else
        {
            buf[0]=(v);
            buf[1]=(v>>8);
            buf[2]=(v>>16);
            buf[3]=(v>>24);
            buf[4]=(v>>32);
            buf[5]=(v>>40);
            buf[6]=(v>>48);
            buf[7]=(v>>56);
        }
        Write(buf, 8);
    }
    
    ByteArrayOutputStream::ByteArrayOutputStream(int c,Endian type):GrayN_OutputStream(type)
    {
        buffer=new char[c];
        this->capcity=c;
        this->length=0;
    }
    ByteArrayOutputStream::~ByteArrayOutputStream()
    {
        delete buffer;
        buffer=NULL;
    }
    void ByteArrayOutputStream::Write(char* b,int l)
    {
        int oLength=this->length+l;
        if(oLength>capcity)
        {
            int newCapcity=capcity*2+1;
            newCapcity=oLength<newCapcity?newCapcity:oLength+1;
            
            char* newBuffer=new char[newCapcity];
            memcpy(newBuffer, buffer, length);
            delete buffer;
            buffer=newBuffer;
            capcity=newCapcity;
        }
        memcpy(buffer+length, b, l);
        this->length+=l;
    }
    void ByteArrayOutputStream::RemoveHead(int count)
    {
        assert(count<=length);
        memmove(buffer, buffer+count, length-count);
        this->length-=count;
    }
    
