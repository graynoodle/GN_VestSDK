
#import "GrayN_Thread_GrayN.h"
#import <string>

#import "GrayNconfig.h"

GrayN_NameSpace_Start
class GrayN_Http_GrayN:public GrayN_Thread_GrayN
{
public:
    class GrayN_HttpListener
    {
    public:
        enum GrayN_HttpErrorCode
        {
            k_GrayN_OPEN_ERROR=1,
            k_GrayN_SEND_HEAD_ERROR=2,
            k_GrayN_SEND_POST_ERROR=3,
            k_GrayN_RECV_HEAD_ERROR=4,
            k_GrayN_RECV_DATA_ERROR=5,
            k_GrayN_DISCONNECTED_ERROR=6
        };
        enum GrayN_HttpEventCode
        {
            k_GrayN_OPENED,
            k_GrayN_SEND_HEAD,
            k_GrayN_SEND_POST,
            k_GrayN_RECV_HEAD,
            k_GrayN_RECV_DATA,
            k_GrayN_COMPLETE
        };
    public:
        virtual void GrayN_On_HttpError(GrayN_Http_GrayN* client,GrayN_HttpErrorCode code){}
        virtual void GrayN_On_HttpEvent(GrayN_Http_GrayN* client,GrayN_HttpEventCode code){}
        virtual void GrayN_On_HttpResponse(GrayN_Http_GrayN* client,int code,int context_length,int startPos,int endPos,int totalContext,const char* data){}
        virtual void GrayN_On_Http_Data(GrayN_Http_GrayN* client,const char* data,int count){}
        virtual void GrayN_On_Http_Over(){}
    };
    
public:
    GrayN_Http_GrayN();
    ~GrayN_Http_GrayN();
public:
    void        GrayN_Http_Get_ByUrl(const char* url,int startPos=0,int endPos=0);
    void        GrayN_Http_Post_ByUrl(const char* url,const char* sendData,int sendCount);
    void        GrayN_Http_Set_Listener(GrayN_HttpListener* listener){this->p_GrayN_Listener=listener;}
    void        GrayN_Http_Set_ContentType(const char* contentType);
    int         GrayN_Http_Get_HttpCode();
    const char*  GrayN_Http_Get_SocketError();
    
private:
    int         GrayN_Http_Parse_Respone(const char* data,int& context_length,int& rangeStartPos,int& rangeEndPos,int& totalContext);
    int         GrayN_Http_Check_Respone_Complete(const char* data,int count);
    void        GrayN_Http_Parse_Url(const char* url,std::string& hostName,std::string& port, std::string& resURL);
    void        GrayNrun(void* p);
    void        GrayNfinished();
private:
    std::string  p_GrayN_Http_Url;
    std::string  p_GrayN_Http_Content_Type;
    int         p_GrayN_Http_Start_Position;
    int         p_GrayN_Http_End_Position;
    char*       p_GrayN_Http_Send_Data;
    int         p_GrayN_Http_Send_Count;
    GrayN_HttpListener*   p_GrayN_Listener;
    int         p_GrayN_HttpCode;
    std::string  p_GrayN_SocketError;
    std::string  p_GrayN_HeadData;
};

GrayN_NameSpace_End

