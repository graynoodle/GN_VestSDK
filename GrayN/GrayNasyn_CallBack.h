
typedef void (*GrayNasyn_CallBack_Function)(void*);

#import "GrayNconfig.h"
GrayN_NameSpace_Start
    class GrayNasyn_CallBack
    {
    public:
        GrayNasyn_CallBack();
        ~GrayNasyn_CallBack();
        static GrayNasyn_CallBack& GetInstance(){
            static GrayNasyn_CallBack GrayNcall;
            return GrayNcall;
        }
        
        void GrayNstartAsyn_CallBack(GrayNasyn_CallBack_Function GrayNfunction, void* GrayNargs);
    private:
        void* GrayNasyn_CallBackInstance;
    };

GrayN_NameSpace_End


