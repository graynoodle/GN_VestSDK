#import "GrayNsocket.h"
#import <iostream>
#import <string>
#import <algorithm>

#import "GrayN_Http_GrayN.h"
#import "GrayNcommon.h"
using namespace std;

//#define HTTPDEBUG

GrayNusing_NameSpace;

GrayN_Http_GrayN::GrayN_Http_GrayN()
{
    p_GrayN_Listener = NULL;
    p_GrayN_Http_Url = "";
    p_GrayN_Http_Content_Type = "";
    p_GrayN_Http_Start_Position = 0;
    p_GrayN_Http_End_Position = 0;
    p_GrayN_Http_Send_Data = NULL;
    p_GrayN_Http_Send_Count = 0;
}

GrayN_Http_GrayN::~GrayN_Http_GrayN()
{
    if (this->p_GrayN_Http_Send_Data != NULL) {
        delete this->p_GrayN_Http_Send_Data;
        this->p_GrayN_Http_Send_Data = NULL;
    }
}
void GrayN_Http_GrayN::GrayN_Http_Parse_Url(const char* url,std::string& hostName,std::string& port,std::string& resURL)
{
    //如果是以http://开头

    if(strcasestr(url, "http://")==url)
    {
        url+=strlen("http://");
    }
    //查找端口
    int urlLength=(int)strlen(url);
    int portIndex=-1;
    int resURLIndex=-1;
    int ipEndIndex=urlLength-1;
    for(int i=0;i<urlLength;i++)
    {
        char ch=url[i];
        if(ch==':')
        {
            ipEndIndex=i;
            portIndex=i;
            break;
        }else if(ch=='/')
        {
            ipEndIndex=i;
            resURLIndex=i;
            break;
        }
    }
    
    char temp[64];
    memcpy(temp, url, ipEndIndex);
    temp[ipEndIndex]=0;
    hostName=temp;
    
    if(portIndex!=-1)
    {
        for(int i=portIndex;i<urlLength;i++)
        {
            char ch=url[i];
            if(ch=='/')
            {
                resURLIndex=i;
                break;
            }
        }
    }else
    {
        port="80";
    }
    if(portIndex!=-1&&resURLIndex!=-1&&resURLIndex>portIndex)
    {//"pay.gamebean.net:8080/billingcenter2.0/gameClient/main.do?"
        string tmp(url);
        int pos = (int)tmp.find('/');
        port = tmp.substr(portIndex+1,pos-portIndex-1);
        //port=url+portIndex+1;
    }
    //设置资源路径
    if(resURLIndex!=-1)
    {
        resURL=url+resURLIndex;
    }
}
int GrayN_Http_GrayN::GrayN_Http_Parse_Respone(const char* data,int& context_length,int& rangeStartPos,int& rangeEndPos,int& totalContext)
{
    int responedCode=-1;
    char* codeLine=(char*)strstr(data, "\r\n");
    if(codeLine!=NULL)
    {
        int length=(int)(codeLine-data);
        int startIndex=-1;
        for(int i=0;i<length;i++)
        {
            if(data[i]==' ')
            {
                startIndex=i;
                break;
            }
        }
        if(startIndex!=-1)
        {
            startIndex++;
            responedCode=atoi(data+startIndex);
        }
        
    }
#define CONTEXT_LENGHT_FLAG "Content-Length: "
    char* contextLength=(char*)strstr(data, CONTEXT_LENGHT_FLAG);
    if(contextLength!=NULL)
    {
        context_length=atoi(contextLength+strlen(CONTEXT_LENGHT_FLAG));
    }
#define CONTEXT_RANGE_FLAG "Content-Range: bytes "
    
    char* context_range=(char*)strstr(data, CONTEXT_RANGE_FLAG);
    if(context_range!=NULL)
    {
        rangeStartPos=atoi(context_range+strlen(CONTEXT_RANGE_FLAG));
        char* endPos=strstr(context_range+strlen(CONTEXT_RANGE_FLAG), "-");
        if(endPos!=NULL)
        {
            rangeEndPos=atoi(endPos+1);
            
            char* rnPos=strstr(endPos, "/");
            if(rnPos!=NULL)
            {
                totalContext=atoi(rnPos+1);
            }
            
        }else {
            rangeEndPos=rangeStartPos=0;
            totalContext=0;
        }
    }
    return responedCode;
}
int GrayN_Http_GrayN::GrayN_Http_Check_Respone_Complete(const char* data,int count)
{
    string tmp(data);
    int compareCount=count-4;
    for(int i=0;i<compareCount;i++,data++)
    {
        if(memcmp(data, "\r\n\r\n", 4)==0)
        {
            p_GrayN_HeadData.clear();
            p_GrayN_HeadData = tmp.substr(0,i);

#ifdef HTTPDEBUG
            GrayNcommon::GrayN_DebugLog("OPGameSDK HEAD:%s",p_GrayN_HeadData.c_str());
#endif
            return i;
        }
    }
    return 0;
}

void GrayN_Http_GrayN::GrayN_Http_Set_ContentType(const char* contentType)
{
    this->p_GrayN_Http_Content_Type = contentType;
}
void GrayN_Http_GrayN::GrayN_Http_Get_ByUrl(const char* url,int startPos,int endPos)
{
    this->p_GrayN_Http_Url=url;
    this->p_GrayN_Http_Start_Position=startPos;
    this->p_GrayN_Http_End_Position=endPos;
    this->p_GrayN_Http_Send_Count=0;
    this->p_GrayN_Http_Send_Data=NULL;
    this->p_GrayN_HttpCode = -1;
    this->GrayNstart();
}
void GrayN_Http_GrayN::GrayN_Http_Post_ByUrl(const char* url,const char* sendData,int sendCount)
{
    //GrayNcommon::GrayN_DebugLog("[GrayN_Http_GrayN::GrayN_Http_Post_ByUrl][GrayNstart]");
    this->p_GrayN_Http_Url=url;
    this->p_GrayN_Http_Start_Position=0;
    this->p_GrayN_Http_End_Position=0;
    this->p_GrayN_Http_Send_Count=sendCount;
    delete this->p_GrayN_Http_Send_Data;
    this->p_GrayN_Http_Send_Data = NULL;
    int dataLen = (int)strlen(sendData);
    this->p_GrayN_Http_Send_Data = new char[dataLen + 1];
    //GrayNcommon::GrayN_DebugLog("[sendData===%s]",sendData);
    memcpy(this->p_GrayN_Http_Send_Data, sendData, dataLen+1);
   
    //GrayNcommon::GrayN_DebugLog("[GrayN_Http_GrayN::GrayN_Http_Post_ByUrl][over]");
    this->p_GrayN_HttpCode = -1;
    this->GrayNstart();
}
int GrayN_Http_GrayN::GrayN_Http_Get_HttpCode()
{
    return p_GrayN_HttpCode;
}

const char* GrayN_Http_GrayN::GrayN_Http_Get_SocketError()
{
    return p_GrayN_SocketError.c_str();
}

void GrayN_Http_GrayN::GrayNrun(void* p)
{ 
    if(p_GrayN_Listener!=NULL&&p_GrayN_Http_Url.length()>10)
    {
        const static int RECV_BUFFER_COUNT=3*1024;
        char tempBuffer[RECV_BUFFER_COUNT];
        
        std::string hostName;
        std::string port;
        std::string resURL;
        bool completeSkip = false;//是否跳转完成∫
        std::string locationUrl = "";
        do{
            if(locationUrl.length() > 0){//发现跳转地址
                p_GrayN_Http_Url = locationUrl;
            }
            GrayN_Http_Parse_Url(p_GrayN_Http_Url.c_str(),hostName,port,resURL);
            GrayNsocket socket;
            p_GrayN_SocketError.clear();        //清空
            if(socket.GrayN_Connector(hostName.c_str(), port.c_str()))
            {
                bool bPost=p_GrayN_Http_Send_Count!=0&&p_GrayN_Http_Send_Data!=NULL;
                {
                    
//                    char portBuffer[32];
//#ifdef WIN32
//                    _snprintf_s(portBuffer, 32, "%d",port);
//#else
//                    snprintf(portBuffer, 32, "%d",port);
//#endif
//                    
                    //Http请求头
                    std::string heads;
                    heads.append(bPost?"POST ":"GET ");
                    heads.append(resURL.c_str());
                    heads.append(" HTTP/1.0\r\n");
                    if(p_GrayN_Http_Content_Type.length()>0){
                        heads.append("Content-Type:");
                        heads.append(p_GrayN_Http_Content_Type);
                        heads.append("\r\n");
                    }
                    heads.append("Accept: */*\r\n");
                    heads.append("User-Agent: MyGameEngine\r\n");
                    heads.append("Accept-Charset: utf-8\r\n");
                    //*****************自定义header
                    heads.append(GrayNcommon::m_GrayN_HttpStaticHeader);
                    string dynamheader;
                    GrayNcommon::GrayNgetHttpDynamicHeader(dynamheader);
                    GrayNcommon::GrayN_DebugLog("opHttpDynamicHeader\n\n%s", dynamheader.c_str());
                    heads.append(dynamheader);
                    //*****************
                    heads.append("Host: ");
                    heads.append(hostName.c_str());
                    heads.append(":");
                    heads.append(port);
                    heads.append("\r\n");
                    //cout<<heads<<endl;
                    if(p_GrayN_Http_End_Position!=0)//断点续传功能 startPos!=0&&
                    {
                        //snprintf(tempBuffer, RECV_BUFFER_COUNT, "Range: bytes=%d-%d\n",startPos,GrayN_Http_End_Position);

                        snprintf(tempBuffer, RECV_BUFFER_COUNT, "Range: bytes=%d-\r\n",p_GrayN_Http_End_Position);
                        heads.append(tempBuffer);
                    }
                    if(bPost)
                    {

                        snprintf(tempBuffer, RECV_BUFFER_COUNT, "Content-Length: %d\r\n",p_GrayN_Http_Send_Count);
                        heads.append(tempBuffer);
                    }
                    heads.append("Connection: Close\r\n");
                    heads.append("\r\n");
                    
#ifdef HTTPDEBUG
                    GrayNcommon::GrayN_DebugLog("请求信息头  -->%s", heads.data());
#endif
                    //发送请求头
                    const char* httpHead=heads.c_str();
                    int tmpSendTotal=heads.length();
                    int tmpSendCount=0;
                    while(tmpSendCount<tmpSendTotal)
                    {
                        int sc=socket.GrayN_SocketSendData((char*)httpHead+tmpSendCount, tmpSendTotal-tmpSendCount);
                        if(sc==-1||sc==0)
                        {
                            p_GrayN_SocketError = socket.m_GrayNsocketError;
                            p_GrayN_Listener->GrayN_On_HttpError(this, GrayN_HttpListener::k_GrayN_SEND_HEAD_ERROR);
                            return;
                        }
                        else if(sc==0)
                        {
                            p_GrayN_SocketError = socket.m_GrayNsocketError;
                            p_GrayN_Listener->GrayN_On_HttpError(this, GrayN_HttpListener::k_GrayN_DISCONNECTED_ERROR);
                            return;
                        }
                        else {
                            tmpSendCount+=sc;
                        }
                    }
                    p_GrayN_Listener->GrayN_On_HttpEvent(this, GrayN_HttpListener::k_GrayN_SEND_HEAD);
                }
                
                if(bPost)//如果是Post方式
                {
#ifdef HTTPDEBUG
                    GrayNcommon::GrayN_DebugLog("===========发送 post body=============");
#endif
                    int tmpSendTotal = p_GrayN_Http_Send_Count;
                    int tmpSendCount = 0;
                    while(tmpSendCount<tmpSendTotal)
                    {
                        int sc=socket.GrayN_SocketSendData(p_GrayN_Http_Send_Data+tmpSendCount, tmpSendTotal-tmpSendCount);
                        if(sc==-1)
                        {
                            p_GrayN_SocketError = socket.m_GrayNsocketError;
                            p_GrayN_Listener->GrayN_On_HttpError(this, GrayN_HttpListener::k_GrayN_SEND_POST_ERROR);
                            return;
                        }else if(sc==0)
                        {
                            p_GrayN_SocketError = socket.m_GrayNsocketError;
                            p_GrayN_Listener->GrayN_On_HttpError(this, GrayN_HttpListener::k_GrayN_DISCONNECTED_ERROR);
                            return;
                        }
                        else {
                            tmpSendCount+=sc;
                        }
                    }
                    p_GrayN_Listener->GrayN_On_HttpEvent(this, GrayN_HttpListener::k_GrayN_SEND_POST);
                }
#ifdef HTTPDEBUG
                GrayNcommon::GrayN_DebugLog("===========开始接受响应================");
#endif
                //接收响应头
                int  recvTotal=0;
                int  responedCount=0;
                memset(tempBuffer, 0x00, sizeof(tempBuffer));
                while(responedCount==0)
                {
                    int rc=socket.GrayN_SocketRecvData(tempBuffer+recvTotal,(RECV_BUFFER_COUNT-1-recvTotal));
#ifdef HTTPDEBUG
                    GrayNcommon::GrayN_DebugLog("接受信息头 part2 %s", tempBuffer);
#endif
                    if(rc==-1||rc==0)//rc=0表明服务器断开连接了，或者服务器发送了0个字节
                    {
                        p_GrayN_SocketError = socket.m_GrayNsocketError;
                        p_GrayN_Listener->GrayN_On_HttpError(this, GrayN_HttpListener::k_GrayN_RECV_HEAD_ERROR);
                        return;
                    }else {
                        recvTotal+=rc;
                        tempBuffer[recvTotal]=0;
                        responedCount=GrayN_Http_Check_Respone_Complete(tempBuffer,recvTotal);
                        if(responedCount!=0)
                        {
                            tempBuffer[responedCount+2]=0;
                            tempBuffer[responedCount+3]=0;
                            responedCount+=4;
                            break;
                        }
                    }
                }

                if(responedCount!=0)//如果收到正常,responedCount指httpbody的开始位置
                {
                    std::string head = tempBuffer;
                    int index = head.find("HTTP/");
                    if(index >= 0){
                        std::string code = head.substr(index+9, 3);
                        p_GrayN_HttpCode = atoi(code.c_str());
                        if(strcmp(code.c_str(), "301") == 0 || strcmp(code.c_str(), "302") == 0){//取跳转地址
                            GrayNcommon::GrayN_DebugLog("接受信息头 %s", "301====302");
                            index = head.find("Location:");
                            locationUrl = head.substr(index + 10);
                            locationUrl = locationUrl.substr(0, locationUrl.length() - 2);
                            socket.GrayN_Disconnector();
                            continue;
                        }
                    }

                    //注意头信息的查看用代码显示，debug命令显示的有问题
                    //GrayNcommon::GrayN_DebugLog("接受信息头 %s", tempBuffer);
                    p_GrayN_Listener->GrayN_On_HttpEvent(this, GrayN_HttpListener::k_GrayN_RECV_HEAD);
                    
                    int context_length=0;
                    
                    int rangeStartPos=0;
                    int rangeEndPos=0;
                    int rangeTotal=0;
                    int responedCode=GrayN_Http_Parse_Respone(tempBuffer,context_length,rangeStartPos,rangeEndPos,rangeTotal);
                    if (responedCode!=200) {
                        GrayNcommon::GrayN_DebugLog("responedCode========%d",responedCode);
                        //cout<<"context_length======="<<context_length<<endl;
                    }
                    
                    //主要用途是为了跟踪错误，判断RecvData为0时是正常关闭还是异常关闭
                    socket.GrayN_SetRecvLength(context_length);
                    
                    //p_GrayN_Listener->GrayN_On_HttpResponse(this, responedCode, context_length, rangeStartPos, rangeEndPos,rangeTotal,tempBuffer);
                    p_GrayN_Listener->GrayN_On_HttpEvent(this, GrayN_HttpListener::k_GrayN_RECV_DATA);
                    int remainCount=recvTotal-responedCount;
                    if(remainCount>0)
                    {
                        //tempBuffer中除包含http头外，还有部分body数据，易忽略
                        p_GrayN_Listener->GrayN_On_Http_Data(this,tempBuffer+responedCount, remainCount);
                    }
                    int  recvCount=remainCount;
                    memset(tempBuffer, 0x00, sizeof(tempBuffer));
                    while(recvCount<context_length)
                    {
                        //GrayNcommon::GrayN_DebugLog("接受数据==========");
                        int rcc=socket.GrayN_SocketRecvData(tempBuffer,RECV_BUFFER_COUNT);
                        if(rcc>0)
                        {
                            recvCount+=rcc;
                            p_GrayN_Listener->GrayN_On_Http_Data(this, tempBuffer, rcc);
                        }
                        else if(rcc==-1)
                        {
                            p_GrayN_SocketError = socket.m_GrayNsocketError;
                            p_GrayN_Listener->GrayN_On_HttpError(this, GrayN_HttpListener::k_GrayN_RECV_DATA_ERROR);
                            return;
                        }else if(rcc==0)
                        {
                            p_GrayN_SocketError = socket.m_GrayNsocketError;
                            p_GrayN_Listener->GrayN_On_HttpError(this, GrayN_HttpListener::k_GrayN_DISCONNECTED_ERROR);
                            return;
                        }
                    }
                    //GrayNcommon::GrayN_DebugLog("数据长度 %d", context_length);
                    p_GrayN_Listener->GrayN_On_HttpEvent(this, GrayN_HttpListener::k_GrayN_COMPLETE);                        
                }
            }
            else {
                
                p_GrayN_SocketError = socket.m_GrayNsocketError;
                GrayNcommon::GrayN_DebugLog("无法连接的地址:%s",p_GrayN_Http_Url.c_str());
                GrayNcommon::GrayN_DebugLog("error=%s",p_GrayN_SocketError.c_str());

                p_GrayN_Listener->GrayN_On_HttpError(this, GrayN_HttpListener::k_GrayN_OPEN_ERROR);
            }
            completeSkip = true;
            locationUrl = "";
        }while (!completeSkip);
        
    }
}

void GrayN_Http_GrayN::GrayNfinished()
{
    if (p_GrayN_Listener) {
        p_GrayN_Listener->GrayN_On_Http_Over();
    }
}

