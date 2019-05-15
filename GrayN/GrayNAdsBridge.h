

#import <iostream>
#import "GrayNconfig.h"
GrayN_NameSpace_Start

class OPAdsBridge
{
public:
    inline static OPAdsBridge& GetInstance() {
        static OPAdsBridge lolo;
        return lolo;
    }
    
private:
    OPAdsBridge();
    ~OPAdsBridge();
    
public:
    void checkInit();
    void logEvent(const char* ourpalm_event_key, const char* event_paras);
    
private:
    id adsSDK;
    
};

GrayN_NameSpace_End
