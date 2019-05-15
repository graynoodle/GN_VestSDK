//
//  GrayN_TempleQueue.h
//  OurpalmSDK
//
//  Created by op-mac1 on 13-12-13.
//
//

#ifndef __OurpalmSDK__TempleQueue__
#define __OurpalmSDK__TempleQueue__

#import <iostream>

using namespace std;

GrayN_NameSpace_Start

    class GrayN_AppLogRequest
    {
    public:
        string m_GrayNappLogTime;
        string m_GrayNappLog;
    };

    class GrayN_AppRequest_GrayN
    {
    public:
        string m_GrayN_AppRequest_SSID;
        string m_GrayN_AppRequest_ProductId;
        string m_GrayN_AppRequest_StartTime;           //请求苹果服务器的时间
        string m_GrayN_AppRequest_CountryCode;         //国家码
        string m_GrayN_AppRequest_CurrencyCode;        //货币码
    };
    
    class GrayN_AppVerifyRequest
    {
    public:
        string GrayN_AppVerifyRequest_LogId;               //日志key，用于数据库删除
        string GrayN_AppVerifyRequest_SSID;                //订单号（目前有两种可能：1、订单号 2、订单号|国家码）
        string GrayN_AppVerifyRequest_AppReceipt;          //苹果收据
        string GrayN_AppVerifyRequest_CountryCode;         //国家码
        string GrayN_AppVerifyRequest_CurrencyCode;        //货币码
        //本地同步订单的收据类型：(3、4为同一版SDK添加)
        //1、订单号（没有国家码和货币码）
        //2、订单号|国家码（有国家码没有货币码）
        //3、订单号 有国家码和货币码(由于支付中断，没有将本地数据删除)
        //4、没有国家码和货币码（漏单原因造成）
        string GrayN_AppVerifyRequest_OrderType;
    };
    
    //定义队列的节点结构
    template <class T>
    struct NODE
    {
        NODE()
        {
            data = NULL;
        }
        ~NODE()
        {
            if(data != NULL)
            {
                delete data;
                data = NULL;
            }
        }
        NODE<T>* next;
        T* data;
    };
    
    template <class T>
    class GrayN_TempleQueue
    {
    public:
        inline static GrayN_TempleQueue<T>& GetInstance()
        {
            static GrayN_TempleQueue<T> GrayNtempleQueue;
            return GrayNtempleQueue;
        }
        
    public:
        GrayN_TempleQueue()
        {
            NODE<T>* p = new NODE<T>;
            if (NULL == p)
            {
                cout << "Failed to malloc the node." << endl;
                return;
            }
            p->data = NULL;
            p->next = NULL;
            front = p;
            rear = p;
        }
        
        ~GrayN_TempleQueue()
        {
            while (front->next != NULL) {
                NODE<T>* p = front->next;
                front->next = p->next;
                front->data = p->data;
                delete p;
                p = NULL;
            }
        }
        
        void push(T* e)
        {
            NODE<T>* p = new NODE<T>;
            if (NULL == p)
            {
                cout << "Failed to malloc the node." << endl;
                return;
            }
            p->data = e;
            p->next = NULL;
            rear->next = p;
            rear = p;
        }
        
        //在队头出队
        void pop()
        {
            if (front == rear)
            {
                cout << "The queue is empty." << endl;
            }
            else
            {
                //注意：front并没有移动位置，只是更改了值
                NODE<T>* p = front->next;
                front->next = p->next;
                front->data = p->data;
                //注意判断当只有一个元素，且删除它之后，rear指向的node被删除
                //应将其指向头结点
                if (rear == p)
                {
                    rear = front;
                }
                delete p;
                p = NULL;
            }
        }
        
        //取得队头元素
        T* front_element()
        {
            if (front == rear)
            {
#ifdef DEBUG
                cout << "The queue is empty." << endl;
#endif
                return NULL;
            }
            else
            {
                NODE<T>* p = front->next;
                return p->data;
            }
        }
        
        T* back_element()
        {
            if (front == rear)
            {
                cout << "The queue is empty." << endl;
                return NULL;
            }
            else
            {
                return rear->data;
            }
        }
        
        //取得队列元素个数，
        int size()
        {
            int count(0);
            
            NODE<T>* p = front;
            
            while (p != rear)
            {
                p = p->next;
                count++;
            }
            return count;
        }
        
        //判断队列是否为空
        bool empty()
        {
            if (front == rear)
            {
                return true;
            }
            else
            {
                return false;
            }
        }

        
    private:
        NODE<T>* front;     //指向头结点的指针。 front->next->data是队头第一个元素。
        NODE<T>* rear;      //指向队尾（最后添加的一个元素）的指针
    };
        
GrayN_NameSpace_End


#endif /* defined(__OurpalmSDK__TempleQueue__) */
