#import "GrayNsocket.h"
#import <sys/socket.h>
#import <arpa/inet.h>
#import <sys/errno.h>
#import <stdlib.h>
#import <fcntl.h>
#import <string.h>
#import <unistd.h>
#import <netdb.h>
#import <sys/ioctl.h>
#import <netinet/tcp.h>
#import <netinet/in.h>
#import <assert.h>
#import <iostream>
#import <sstream>
#import "GrayNcommon.h"

GrayNusing_NameSpace;

GrayNsocket::GrayNsocket():p_GrayN_state(k_GrayN_Socket_Ready),p_GrayN_Socket_fd(-1)
#ifdef SDK_IPV6
,p_GrayN_Is_IPV6(false)
#endif
{
    signal(SIGPIPE, SIG_IGN);
}
GrayNsocket::~GrayNsocket()
{
    GrayN_SocketClose();
}
bool GrayNsocket::GrayN_SocketIsOpen()
{
    if(p_GrayN_state>k_GrayN_Socket_Ready)
    {
        return true;
    }
    int					ret_val = 0;
    int					sock_flag;
    int                 setsigpipe = 1;
    struct linger		sock_linger;
    int type = PF_INET;
#ifdef SDK_IPV6
    if (p_GrayN_Is_IPV6) {
        type = PF_INET6;
    }
#endif
    p_GrayN_Socket_fd = socket( type, SOCK_STREAM, 0 );    //IPPROTO_IP
    m_GrayNsocketError.append("(");
    m_GrayNsocketError.append(GrayNcommon::m_GrayNnetworkTypeNum);   //1: WIFI 2:WWAN
    m_GrayNsocketError.append(")");
    if (p_GrayN_Socket_fd < 0 )
    {
#ifdef DEBUG
        std::cout<<"socket 1:p_GrayN_Socket_fd="<<p_GrayN_Socket_fd<<std::endl;
#endif
        m_GrayNsocketError.append("p_GrayN_Socket_fd:");
        m_GrayNsocketError.append(GrayNcommon::GrayNcommonIntegerToString(p_GrayN_Socket_fd));
        goto __FAILED;
    }
    sock_flag = 1;
    ret_val = setsockopt(p_GrayN_Socket_fd, SOL_SOCKET, SO_REUSEADDR, (const void *)&sock_flag, sizeof(sock_flag) );
    if ( ret_val < 0 )
    {
#ifdef DEBUG
        std::cout<<"socket 2:ret_val="<<ret_val<<std::endl;
#endif
        m_GrayNsocketError.append("SO_REUSEADDR:");
        m_GrayNsocketError.append(GrayNcommon::GrayNcommonIntegerToString(ret_val));
        goto __FAILED;
    }
    //SO_LINGER，如果选择此选项, close或 shutdown将等到所有套接字里排队的消息成功发送或到达延迟时间后>才会返回. 否则, 调用将立即返回。
    sock_linger.l_onoff = 0;    ///* 延时状态（打开/关闭） */
    sock_linger.l_linger = 0;   ///* 延时多长时间 */
    ret_val = setsockopt(p_GrayN_Socket_fd, SOL_SOCKET, SO_LINGER, (const void *)&sock_linger, sizeof(sock_linger) );
    if ( ret_val < 0 )
    {
#ifdef DEBUG
        std::cout<<"socket 3:ret_val="<<ret_val<<std::endl;
#endif
        m_GrayNsocketError.append("SO_LINGER:");
        m_GrayNsocketError.append(GrayNcommon::GrayNcommonIntegerToString(ret_val));
        goto __FAILED;
    }
    
    //new  set the timeout
    struct timeval tv_out;
    tv_out.tv_sec = 60;
    tv_out.tv_usec = 0;
    ret_val = setsockopt(p_GrayN_Socket_fd, SOL_SOCKET, SO_RCVTIMEO, &tv_out, sizeof(tv_out));
    if (ret_val < 0) {
#ifdef DEBUG
        std::cout<<"socket 4:ret_val="<<ret_val<<std::endl;
#endif
        m_GrayNsocketError.append("SO_RCVTIMEO:");
        m_GrayNsocketError.append(GrayNcommon::GrayNcommonIntegerToString(ret_val));
        goto __FAILED;
    }
    ret_val = setsockopt(p_GrayN_Socket_fd, SOL_SOCKET, SO_SNDTIMEO, &tv_out, sizeof(tv_out));
    if (ret_val < 0) {
#ifdef DEBUG
        std::cout<<"socket 5:ret_val="<<ret_val<<std::endl;
#endif
        m_GrayNsocketError.append("SO_SNDTIMEO:");
        m_GrayNsocketError.append(GrayNcommon::GrayNcommonIntegerToString(ret_val));
        goto __FAILED;
    }
    
    ret_val = setsockopt(p_GrayN_Socket_fd, SOL_SOCKET, SO_NOSIGPIPE, (void *)&setsigpipe, sizeof(int));
    if ( ret_val < 0 )
    {
        std::cout<<"socket 6:ret_val="<<ret_val<<std::endl;
        m_GrayNsocketError.append("SO_NOSIGPIPE:");
        m_GrayNsocketError.append(GrayNcommon::GrayNcommonIntegerToString(ret_val));
        goto __FAILED;
    }
    
#ifdef SO_REUSEPORT
    sock_flag = 1;
    ret_val = setsockopt(p_GrayN_Socket_fd, SOL_SOCKET, SO_REUSEPORT, (const void *)&sock_flag, sizeof(sock_flag) );
    if ( ret_val < 0 )
    {
#ifdef DEBUG
        std::cout<<"socket 8:ret_val="<<ret_val<<std::endl;
#endif
        m_GrayNsocketError.append("SO_REUSEPORT:");
        m_GrayNsocketError.append(GrayNcommon::GrayNcommonIntegerToString(ret_val));
        goto __FAILED;
    }
#endif
    sock_flag = 1;
    ret_val = setsockopt(p_GrayN_Socket_fd, IPPROTO_TCP, TCP_NODELAY, (const void *)&sock_flag, sizeof(sock_flag) );
    p_GrayN_state=k_GrayN_Socket_Open;
    return true;
    
__FAILED:
    GrayN_SocketClose();
    return false;
}

#ifndef SDK_IPV6
bool GrayNsocket::GrayN_Connector(const char* hostName,const char* port)
{
    m_GrayNsocketError.clear();
    int rc=0;
    if(p_GrayN_state==k_GrayN_Socket_Ready)
    {
        if(GrayN_SocketIsOpen()==false)
        {
            //                XCLOG("socket open fail");
            goto __FAILED;
        }
    }
    struct sockaddr_in	sock_addr;
    bzero(&sock_addr, sizeof(sock_addr));
    sock_addr.sin_family = AF_INET;
    //sock_addr.sin_addr.s_addr = inet_addr(ip);
    sock_addr.sin_port = htons( atoi(port) );
    if (inet_aton(hostName, &sock_addr.sin_addr) == 0) {
        struct hostent *he;
        long long startTime = GrayNcommon::GrayNgetCurrent_TimeStamp();
        he = gethostbyname(hostName);
        if (he == NULL) {
#ifdef DEBUG
            std::cout<<"socket 9:gethostbyname="<<hostName<<",h_errno=="<<hstrerror(h_errno)<<std::endl;
#else
            std::cout<<"socket 9:gethostbyname h_errno=="<<hstrerror(h_errno)<<std::endl;
#endif
            long long tapTime = GrayNcommon::GrayNgetCurrent_TimeStamp()-startTime;
            m_GrayNsocketError.append("gethostbyname(");
            m_GrayNsocketError.append("h_errno=");
            m_GrayNsocketError.append(GrayNcommon::GrayNcommonIntegerToString(h_errno));
            m_GrayNsocketError.append(",time=");
            m_GrayNsocketError.append(GrayNcommon::GrayNcommonLongToString(tapTime));  //记录请求时间，用于查看gethostbyname时间
            m_GrayNsocketError.append(")");
            herror("gethostbyname");
            if (GrayN_ConnectorAddrInfo(hostName, port)) {  //主要是获取IP
                return true;
            }
            std::string ip = GrayNcommon::GrayN_DNSParse(hostName);
            if(ip.length() == 0 || inet_pton(AF_INET, ip.c_str(), &sock_addr.sin_addr) <= 0){
                m_GrayNsocketError.append(",pton=");
                m_GrayNsocketError.append(ip);
                goto __FAILED;
            }
        }else{
            //#ifdef DEBUG
            //            //IP地址
            //            printf("/nh_name:%s,h_aliases:%s,h_addrtype:%d,h_length:%d/n",he->h_name,he->h_aliases[0],he->h_addrtype,he->h_length);
            //            for (int i = 0;he->h_addr_list[i] != NULL;++i)
            //            {
            //                printf("/nh_addr:%s/n",inet_ntoa(*((in_addr*)he->h_addr_list[i])));
            //            }
            //#endif
            memcpy(&sock_addr.sin_addr, he->h_addr, sizeof(struct in_addr));
        }
    }
    rc=connect(p_GrayN_Socket_fd, (const struct sockaddr*)&sock_addr, sizeof(sock_addr));
    if(rc==0)
    {
        p_GrayN_state=k_GrayN_Socket_Connected;
        return true;
    }
    m_GrayNsocketError.append("connect:");
    m_GrayNsocketError.append(GrayNcommon::GrayNcommonIntegerToString(rc));
__FAILED:
    return false;
}

bool GrayNsocket::GrayN_ConnectorAddrInfo(const char* hostName,const char* port)
{
    int rc=0;
    std::string ip;
    char abuf[20];
    // Construct server address information.
    struct addrinfo hints, *serverinfo, *p;
    
    bzero(&hints, sizeof(hints));
    hints.ai_family = AF_INET;
    hints.ai_socktype = SOCK_STREAM;
    
    int error = getaddrinfo(hostName, port, &hints, &serverinfo);
    if (error) {
#ifdef DEBUG
        std::cout<<"hostname="<<hostName<<",error="<<gai_strerror(error)<<std::endl;
#else
        std::cout<<gai_strerror(error)<<std::endl;
#endif
        m_GrayNsocketError.append("getaddrinfo=");
        m_GrayNsocketError.append(GrayNcommon::GrayNcommonIntegerToString(error));
#ifdef DEBUG
        std::cout<<"getaddrinfo(error="<<gai_strerror(error)<<")"<<std::endl;
#endif
        return false;
    }
    
    // Loop through the results and connect to the first we can.
    for (p = serverinfo; p != NULL; p = p->ai_next) {
        if (p->ai_family != AF_INET) {
            continue;
        }
        rc=connect(p_GrayN_Socket_fd, p->ai_addr, p->ai_addrlen);
        struct sockaddr_in *sinp = (struct sockaddr_in *)p->ai_addr;
        ip = inet_ntop(AF_INET, &sinp->sin_addr, abuf,20);
        if(rc==0)
        {
#ifdef DEBUG
            std::cout<<"IP="<<ip<<std::endl;
#endif
            p_GrayN_state=k_GrayN_Socket_Connected;
            m_GrayNsocketError.append("IPP=");
            m_GrayNsocketError.append(ip);
            freeaddrinfo(serverinfo);
            return true;
        }
#ifdef DEBUG
        std::cout<<"IP="<<ip<<",Err="<<rc<<std::endl;
#endif
        m_GrayNsocketError.append("IP=");
        m_GrayNsocketError.append(ip);
        m_GrayNsocketError.append(",Err=");
        m_GrayNsocketError.append(GrayNcommon::GrayNcommonIntegerToString(rc));
    }
    freeaddrinfo(serverinfo);
    return false;
}
#else
bool GrayNsocket::GrayN_Connector(const char* hostName,const char* port)
{
    p_GrayN_Is_IPV6 = false;
    //hostName = "223.202.94.226";
    //判断IPV4 or IPV6
    //hostName = "ipv6.neu6.edu.cn";
    
    m_GrayNsocketError.clear();
    
    int rc=0;
    long long startTime = GrayNcommon::GrayNgetCurrent_TimeStamp();
    const char* hostIP = NULL;
    struct addrinfo *answer, hint, *curr;
    bzero(&hint, sizeof(hint));
    hint.ai_family = AF_UNSPEC;
    hint.ai_socktype = SOCK_STREAM;
    char ipstr2[128];
    struct sockaddr_in  sockaddr_ipv4;
    struct sockaddr_in6 sockaddr_ipv6;
    bzero(&sockaddr_ipv4, sizeof(sockaddr_ipv4));
    bzero(&sockaddr_ipv6, sizeof(sockaddr_ipv6));
    socklen_t socklen;
    
    int error = getaddrinfo(hostName, port,&hint, &answer);
    m_GrayNsocketError.append("err=");
    m_GrayNsocketError.append(GrayNcommon::GrayNcommonIntegerToString(error));
    m_GrayNsocketError.append(",t=");
    long long tapTime = GrayNcommon::GrayNgetCurrent_TimeStamp()-startTime;
    m_GrayNsocketError.append(GrayNcommon::GrayNcommonLongToString(tapTime));
    m_GrayNsocketError.append("|");
    if (error != 0) {
#ifdef DEBUG
        std::cout<<"hostname="<<hostName<<",error="<<gai_strerror(error)<<std::endl;
#else
        std::cout<<gai_strerror(error)<<std::endl;
#endif
        return false;
    }
    
    for (curr = answer; curr != NULL; curr = curr->ai_next) {
        switch (curr->ai_family){
            case AF_UNSPEC:
                //do something here
                break;
            case AF_INET:
                sockaddr_ipv4 = *reinterpret_cast<struct sockaddr_in *>( curr->ai_addr);
                socklen = curr->ai_addrlen;
                hostIP = inet_ntop(AF_INET, &sockaddr_ipv4.sin_addr, ipstr2,sizeof(ipstr2));
                p_GrayN_Is_IPV6 = false;
                if (hostIP == NULL) {
                    break;
                }
                if(GrayN_SocketIsOpen()==false)
                {
                    break;
                }
                
                rc=connect(p_GrayN_Socket_fd, (const struct sockaddr*)&sockaddr_ipv4, socklen);
                m_GrayNsocketError.append(hostIP);
                if(rc==0)
                {
#ifdef DEBUG
                    std::cout<<"hostname="<<hostName<<",hostIP="<<hostIP<<std::endl;
#endif
                    p_GrayN_state=k_GrayN_Socket_Connected;
                    freeaddrinfo(answer);
                    m_GrayNsocketError.append(",s=");
                    tapTime = GrayNcommon::GrayNgetCurrent_TimeStamp()-startTime;
                    m_GrayNsocketError.append(GrayNcommon::GrayNcommonLongToString(tapTime));
                    m_GrayNsocketError.append(",");
                    return true;
                }
#ifdef DEBUG
                std::cout<<"hostname="<<hostName<<"(IPV4)connectError"<<std::endl;
#endif
                p_GrayN_state = k_GrayN_Socket_Ready;
                break;
            case AF_INET6:
                sockaddr_ipv6 = *reinterpret_cast<struct sockaddr_in6 *>( curr->ai_addr);
                socklen = curr->ai_addrlen;
                hostIP = inet_ntop(AF_INET6, &sockaddr_ipv6.sin6_addr, ipstr2,sizeof(ipstr2));
                p_GrayN_Is_IPV6 = true;
                
                if (hostIP == NULL) {
                    break;
                }
                if(GrayN_SocketIsOpen()==false)
                {
                    break;
                }
                
                rc=connect(p_GrayN_Socket_fd, (const struct sockaddr*)&sockaddr_ipv6, socklen);
                m_GrayNsocketError.append(hostIP);
                if(rc==0)
                {
#ifdef DEBUG
                    std::cout<<"hostname="<<hostName<<",hostIP="<<hostIP<<std::endl;
#endif
                    p_GrayN_state=k_GrayN_Socket_Connected;
                    freeaddrinfo(answer);
                    m_GrayNsocketError.append(",s=");
                    tapTime = GrayNcommon::GrayNgetCurrent_TimeStamp()-startTime;
                    m_GrayNsocketError.append(GrayNcommon::GrayNcommonLongToString(tapTime));
                    m_GrayNsocketError.append(",");
                    return true;
                }
#ifdef DEBUG
                std::cout<<"hostname="<<hostName<<"(IPV6)connectError"<<std::endl;
#endif
                p_GrayN_state = k_GrayN_Socket_Ready;
                break;
        }
        
        
    }
    freeaddrinfo(answer);
    m_GrayNsocketError.append(",f=");
    tapTime = GrayNcommon::GrayNgetCurrent_TimeStamp()-startTime;
    m_GrayNsocketError.append(GrayNcommon::GrayNcommonLongToString(tapTime));
    return false;
}
#endif

void  GrayNsocket::GrayN_SocketClose()
{
    if(p_GrayN_Socket_fd!=-1)
    {
        close(p_GrayN_Socket_fd);
        p_GrayN_Socket_fd=-1;
    }
    p_GrayN_state=k_GrayN_Socket_Ready;
}
void GrayNsocket::GrayN_Disconnector()
{
    GrayN_SocketClose();
}
int GrayNsocket::GrayN_SocketSendData(char* data,int length)
{
    int err = send(p_GrayN_Socket_fd,data,length,0);
    m_GrayNsocketError.append("Send:");
    m_GrayNsocketError.append(GrayNcommon::GrayNcommonIntegerToString(err));
    if (err <= 0) {
        m_GrayNsocketError.append("(errno==");
        m_GrayNsocketError.append(GrayNcommon::GrayNcommonIntegerToString(errno));
        m_GrayNsocketError.append(")");
    }
    return err;
}
int GrayNsocket::GrayN_SocketRecvData(char* buffer,int length)
{
    int err = recv(p_GrayN_Socket_fd,buffer,length,0);
    m_GrayNsocketError.append("Recv:");
    m_GrayNsocketError.append(GrayNcommon::GrayNcommonIntegerToString(err));
    if (err <= 0) {
        m_GrayNsocketError.append("(errno==");
        m_GrayNsocketError.append(GrayNcommon::GrayNcommonIntegerToString(errno));
        m_GrayNsocketError.append(")");
    }
    return err;
    //    int err = 0;
    //    m_GrayNsocketError.append("GrayN_SocketRecvData:");
    //    for (int i=0; i<3; i++) {
    //        err = recv(p_GrayN_Socket_fd,buffer,length,0);
    //        if (errno == EINTR) {
    //            m_GrayNsocketError.append("4|");
    //            continue;
    //        }
    //        if (errno == EAGAIN) {
    //            usleep(100);    //100毫秒
    //            continue;
    //        }
    //        m_GrayNsocketError.append(GrayNcommon::GrayNcommonIntegerToString(err));
    //        break;
    //    }
    //    return err;
}

void GrayNsocket::GrayN_SetRecvLength(int contentlength)
{
    m_GrayNsocketError.append("Content-Length:");
    m_GrayNsocketError.append(GrayNcommon::GrayNcommonIntegerToString(contentlength));
}

