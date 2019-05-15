

#import <iostream>

#import "GrayNconfig.h"

GrayN_NameSpace_Start

//struct NetPack
//{
//    char* buffer;
//    int   length;
//    NetPack(char* bu=0,int l=0):buffer(bu),length(l){}
//};
class GrayNsocket
{
public:
    enum GrayN_SocketState
    {
        k_GrayN_Socket_Ready,
        k_GrayN_Socket_Open,
        k_GrayN_Socket_Connected
    };
public:
    GrayNsocket();
    ~GrayNsocket();
public:
    //设置应该接受的数据总长度
    void        GrayN_SetRecvLength(int contentlength);
    bool        GrayN_Connector(const char* hostName,const char* port);
    void        GrayN_Disconnector();
    int         GrayN_SocketSendData(char* data,int length);
    int         GrayN_SocketRecvData(char* buffer,int length);
private:
    bool        GrayN_SocketIsOpen();
#ifndef SDK_IPV6
    bool        GrayN_ConnectorAddrInfo(const char* hostName,const char* port);
#endif
    void        GrayN_SocketClose();
private:
    GrayN_SocketState       p_GrayN_state;
    int         p_GrayN_Socket_fd;
#ifdef SDK_IPV6
    bool        p_GrayN_Is_IPV6;
#endif
    
    
public:
    std::string m_GrayNsocketError;
};

GrayN_NameSpace_End

