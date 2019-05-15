
#import "GrayN_CodeScanner.h"
#import <AVFoundation/AVFoundation.h>
#import "GrayN_BaseControl.h"
#import "GrayNbaseSDK.h"
#import "GrayNconfig.h"

@interface GrayN_CodeScanner ()<AVCaptureMetadataOutputObjectsDelegate>
{
    AVCaptureVideoPreviewLayer *p_GrayN_CodeLayer;
}
@property (nonatomic, strong) AVCaptureSession *p_GrayN_Session;
@property (nonatomic, assign) BOOL p_GrayN_IsReading;

@property (nonatomic, assign) UIStatusBarStyle p_GrayNoriginStatusBarStyle;

@property (nonatomic, strong) UIImageView *p_GrayNlineImageView;
@property (nonatomic, strong) NSTimer *p_GrayNtimer;
@property (nonatomic, strong) UILabel *p_GrayNtipLabel;
@property (nonatomic, strong) UILabel *p_GrayNtitleLabel;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;

@end

@implementation GrayN_CodeScanner

- (id)init {
    self = [super init];
    if (self) {
        self.m_GrayN_ScanType = GrayN_CodeScannerTypeAll;
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
    _p_GrayN_Session = nil;
}
- (void)GrayN_AuthorityConfirm
{
    //判断权限
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (granted) {
                static bool isInit = false;
                if (isInit == false) {
                    [self loadScanView];
                    [self startRunning];
                    isInit = true;
                }
            } else {
                [self pressBackButton];
                NSString *title = @"请在iPhone的”设置-隐私-相机“选项中，允许App访问你的相机，并重启游戏";
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:@"" delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil];
                [alertView show];
            }
        });
    }];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadCustomView];
    _m_GrayN_ScanType = GrayN_CodeScannerTypeQRCode;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.p_GrayNoriginStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    
    NSString *codeStr = @"";
    switch (_m_GrayN_ScanType) {
        case GrayN_CodeScannerTypeAll: codeStr = @"二维码/条码"; break;
        case GrayN_CodeScannerTypeQRCode: codeStr = @"二维码"; break;
        case GrayN_CodeScannerTypeBarCode: codeStr = @"条码"; break;
        default: break;
    }
    
    //title
    if (self.m_GrayN_Scanner_Title && self.m_GrayN_Scanner_Title.length > 0) {
        self.p_GrayNtitleLabel.text = self.m_GrayN_Scanner_Title;
    } else {
        self.p_GrayNtitleLabel.text = codeStr;
    }
    
    //tip
    if (self.m_GrayN_Scanner_Tip && self.m_GrayN_Scanner_Tip.length > 0) {
        self.p_GrayNtipLabel.text = self.m_GrayN_Scanner_Tip;
    } else {
        self.p_GrayNtipLabel.text= [NSString stringWithFormat:@"将%@放入框内，即可自动扫描", codeStr];
    }

    [self startRunning];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarStyle:self.p_GrayNoriginStatusBarStyle animated:YES];
    
    [self stopRunning];
    
    [super viewWillDisappear:animated];
}

- (void)loadScanView {
    //获取摄像设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //创建输入流
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    //创建输出流
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc]init];
    //设置代理 在主线程里刷新
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    //初始化链接对象
    self.p_GrayN_Session = [[AVCaptureSession alloc] init];
    //高质量采集率
    [self.p_GrayN_Session setSessionPreset:AVCaptureSessionPresetHigh];
    
    [self.p_GrayN_Session addInput:input];
    [self.p_GrayN_Session addOutput:output];
    //设置扫码支持的编码格式
    switch (self.m_GrayN_ScanType) {
        case GrayN_CodeScannerTypeAll:
            output.metadataObjectTypes=@[AVMetadataObjectTypeQRCode,
                                         AVMetadataObjectTypeEAN13Code,
                                         AVMetadataObjectTypeEAN8Code,
                                         AVMetadataObjectTypeUPCECode,
                                         AVMetadataObjectTypeCode39Code,
                                         AVMetadataObjectTypeCode39Mod43Code,
                                         AVMetadataObjectTypeCode93Code,
                                         AVMetadataObjectTypeCode128Code,
                                         AVMetadataObjectTypePDF417Code];
            break;
            
        case GrayN_CodeScannerTypeQRCode:
            output.metadataObjectTypes=@[AVMetadataObjectTypeQRCode];
            break;
            
        case GrayN_CodeScannerTypeBarCode:
            output.metadataObjectTypes=@[AVMetadataObjectTypeEAN13Code,
                                         AVMetadataObjectTypeEAN8Code,
                                         AVMetadataObjectTypeUPCECode,
                                         AVMetadataObjectTypeCode39Code,
                                         AVMetadataObjectTypeCode39Mod43Code,
                                         AVMetadataObjectTypeCode93Code,
                                         AVMetadataObjectTypeCode128Code,
                                         AVMetadataObjectTypePDF417Code];
            break;

        default:
            break;
    }
    
    p_GrayN_CodeLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.p_GrayN_Session];
    p_GrayN_CodeLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    p_GrayN_CodeLayer.frame = self.view.layer.bounds;
    [self reshapeCodeScanner];
    [self.view.layer insertSublayer:p_GrayN_CodeLayer atIndex:0];
}

- (void)loadCustomView {
    self.view.backgroundColor = [UIColor blackColor];
    
    CGRect rc = [[UIScreen mainScreen] bounds];
    
    
    if ([GrayN_BaseControl GrayN_Base_WindowIsLandScape]) {
        //rc.size.height -= 50;
        _width = rc.size.width * 0.3;
        //height = rc.size.height * 0.2;
        _height = (rc.size.height - (rc.size.width - _width * 2))/2;
    } else {
        //rc.size.height -= 50;
        _width = rc.size.width * 0.1;
        //height = rc.size.height * 0.2;
        _height = (rc.size.height - (rc.size.width - _width * 2))/2;
    }
    
    
    CGFloat alpha = 0.5;
    
    //最上部view
    UIView* upView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, rc.size.width, _height)];
    upView.alpha = alpha;
    upView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:upView];
    
    //左侧的view
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, _height, _width, rc.size.height - _height * 2)];
    leftView.alpha = alpha;
    leftView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:leftView];
    
    //中间扫描区域
    UIImageView *scanCropView=[[UIImageView alloc] initWithFrame:CGRectMake(_width, _height, rc.size.width - _width - _width, rc.size.height - _height - _height)];
    scanCropView.image=[UIImage imageNamed:@"login_scan_code_border"];
    scanCropView. backgroundColor =[ UIColor clearColor ];
    [ self.view addSubview :scanCropView];
    
    //右侧的view
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(rc.size.width - _width, _height, _width, rc.size.height - _height * 2)];
    rightView.alpha = alpha;
    rightView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:rightView];
    
    //底部view
    UIView *downView = [[UIView alloc] initWithFrame:CGRectMake(0, rc.size.height - _height, rc.size.width, _height)];
    downView.alpha = alpha;
    downView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:downView];
    
    //用于说明的label
    self.p_GrayNtipLabel= [[UILabel alloc] init];
    self.p_GrayNtipLabel.backgroundColor = [UIColor clearColor];
    self.p_GrayNtipLabel.frame=CGRectMake(_width, rc.size.height - _height, rc.size.width - _width * 2, 40);
    self.p_GrayNtipLabel.numberOfLines=0;
    self.p_GrayNtipLabel.textColor=[UIColor whiteColor];
    self.p_GrayNtipLabel.textAlignment = NSTextAlignmentCenter;
    self.p_GrayNtipLabel.font = [UIFont systemFontOfSize:15];
    [self.view addSubview:self.p_GrayNtipLabel];
    
    //画中间的基准线
    self.p_GrayNlineImageView = [[UIImageView alloc] initWithFrame:CGRectMake (_width, _height, rc.size.width - 2 * _width, 5)];
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"OurSDK_res.bundle/images/op_code_scanner_line"];
    
    self.p_GrayNlineImageView.image = [UIImage imageWithContentsOfFile:path];
    [self.view addSubview:self.p_GrayNlineImageView];
    
    
    //标题
    self.p_GrayNtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 0, rc.size.width - 50 - 50, 44)];
    self.p_GrayNtitleLabel.backgroundColor = [UIColor clearColor];
    self.p_GrayNtitleLabel.textColor = [UIColor whiteColor];
    self.p_GrayNtitleLabel.font = [UIFont boldSystemFontOfSize:18];
    self.p_GrayNtitleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.p_GrayNtitleLabel];
    
    //返回
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, self.p_GrayNtitleLabel.frame.origin.y, 44, 44)];
    path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"OurSDK_res.bundle/images/op_code_scanner_back"];
    [backButton setImage:[UIImage imageWithContentsOfFile:path] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(pressBackButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
}

- (void)startRunning {
    if (self.p_GrayN_Session) {
        _p_GrayN_IsReading = YES;
        
        [self.p_GrayN_Session startRunning];
        
        _p_GrayNtimer=[NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(moveUpAndDownLine) userInfo:nil repeats: YES];
    }
}

- (void)stopRunning {
    if ([_p_GrayNtimer isValid]) {
        [_p_GrayNtimer invalidate];
        _p_GrayNtimer = nil ;
    }
    
    [self.p_GrayN_Session stopRunning];
}

- (void)pressBackButton {
    [self closeNvc];
}
- (void)closeNvc
{
    UINavigationController *nvc = self.navigationController;
    if (nvc) {
        if (nvc.viewControllers.count == 1) {
            [nvc dismissViewControllerAnimated:YES completion:nil];
        } else {
            [nvc popViewControllerAnimated:NO];
        }
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

//二维码的横线移动
- (void)moveUpAndDownLine {
    CGFloat Y = self.p_GrayNlineImageView.frame.origin.y;
    if (_height + self.p_GrayNlineImageView.frame.size.width - 5 == Y) {
        [UIView beginAnimations: @"asa" context:nil];
        [UIView setAnimationDuration:1.5];
        CGRect frame = self.p_GrayNlineImageView.frame;
        frame.origin.y = _height;
        self.p_GrayNlineImageView.frame = frame;
        [UIView commitAnimations];
    } else if (_height == Y){
        [UIView beginAnimations: @"asa" context:nil];
        [UIView setAnimationDuration:1.5];
        CGRect frame = self.p_GrayNlineImageView.frame;
        frame.origin.y = _height + self.p_GrayNlineImageView.frame.size.width - 5;
        self.p_GrayNlineImageView.frame = frame;
        [UIView commitAnimations];
    }
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (!_p_GrayN_IsReading) {
        return;
    }
    if (metadataObjects.count > 0) {
        _p_GrayN_IsReading = NO;
        AVMetadataMachineReadableCodeObject *metadataObject = metadataObjects[0];
        NSString *result = metadataObject.stringValue;
        
        if (self.m_GrayN_Scanner_ResultBlock) {
            self.m_GrayN_Scanner_ResultBlock(result?:@"");
        }
        
        [self closeNvc];
    }
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if([GrayN_BaseControl GrayN_Base_WindowIsAutoOrientation]){
        if (UIInterfaceOrientationIsLandscape([GrayN_BaseControl GrayN_Base_WindowInitOrientation])) {
            return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
        } else {
            return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
        }
    } else {
        if ([GrayN_BaseControl GrayN_Base_WindowInitOrientation] == toInterfaceOrientation) {
            return YES;
        } else {
            return NO;
        }
    }
}
- (void)reshapeCodeScanner
{
    if (GrayNgetStatusBarOrientation == UIInterfaceOrientationLandscapeRight) {
        [p_GrayN_CodeLayer connection].videoOrientation = AVCaptureVideoOrientationLandscapeRight;
    } else if (GrayNgetStatusBarOrientation == UIInterfaceOrientationLandscapeLeft) {
        [p_GrayN_CodeLayer connection].videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
    } else if (GrayNgetStatusBarOrientation == UIInterfaceOrientationPortrait) {
        [p_GrayN_CodeLayer connection].videoOrientation = AVCaptureVideoOrientationPortrait;
    } else {
        [p_GrayN_CodeLayer connection].videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
    }
}
- (BOOL)shouldAutorotate
{
    [self reshapeCodeScanner];
    
    return [GrayN_BaseControl GrayN_Base_WindowIsAutoOrientation];
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
        return [GrayN_BaseControl GrayN_Base_SupportedInterfaceOrientations];
}


- (BOOL)prefersHomeIndicatorAutoHidden
{
    return [GrayNbaseSDK GrayNhomeIndicator_AutoHidden];
}
- (UIRectEdge)preferredScreenEdgesDeferringSystemGestures
{
    return [GrayNbaseSDK GrayNdeferring_SystemGestures];
}

@end
