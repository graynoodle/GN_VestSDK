
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, GrayN_CodeScannerType) {
    GrayN_CodeScannerTypeAll = 0,   //default, scan QRCode and barcode
    GrayN_CodeScannerTypeQRCode,    //scan QRCode only
    GrayN_CodeScannerTypeBarCode,   //scan barcode only
};

@interface GrayN_CodeScanner : UIViewController

@property (nonatomic, assign) GrayN_CodeScannerType m_GrayN_ScanType;
@property (nonatomic, copy) NSString *m_GrayN_Scanner_Title;
@property (nonatomic, copy) NSString *m_GrayN_Scanner_Tip;

@property (nonatomic, copy) void(^m_GrayN_Scanner_ResultBlock)(NSString *value);

- (void)GrayN_AuthorityConfirm;
@end
