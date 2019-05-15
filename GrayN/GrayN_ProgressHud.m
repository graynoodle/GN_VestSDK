//
// MBProgressHUD.m
// Version 0.5
// Created by Matej Bukovinski on 2.4.09.
//
//

#import "GrayN_ProgressHud.h"


#if __has_feature(objc_arc)
#define MB_AUTORELEASE(exp) exp
#define MB_RELEASE(exp) exp
#define MB_RETAIN(exp) exp
#else
#define MB_AUTORELEASE(exp) [exp autorelease]
#define MB_RELEASE(exp) [exp release]
#define MB_RETAIN(exp) [exp retain]
#endif


static const CGFloat p_GrayN_Padding = 4.f;
static const CGFloat p_GrayN_LabelFontSize = 16.f;
static const CGFloat p_GrayN_DetailsLabelFontSize = 12.f;
static int          p_GrayN_NumOfLine = 1;

@interface GrayN_ProgressHud_oc ()

- (void)GrayNsetupLabels;
- (void)GrayNregisterForKVO;
- (void)GrayNunregisterFromKVO;
- (NSArray *)GrayNobservableKeypaths;
- (void)GrayNregisterForNotifications;
- (void)GrayNunregisterFromNotifications;
- (void)GrayNupdateUIForKeypath:(NSString *)keyPath;
- (void)GrayNhideUsingAnimation:(BOOL)animated;
- (void)GrayNshowUsingAnimation:(BOOL)animated;
- (void)GrayNdone;
- (void)GrayNupdateIndicators;
- (void)GrayNhandleGraceTimer:(NSTimer *)theTimer;
- (void)GrayNhandleMinShowTimer:(NSTimer *)theTimer;
- (void)GrayNsetTransformForCurrentOrientation:(BOOL)animated;
- (void)GrayNcleanUp;
- (void)GrayNlaunchExecution;
- (void)GrayNdeviceOrientationDidChange:(NSNotification *)notification;
- (void)GrayNhideDelayed:(NSNumber *)animated;

@property (GrayN_ProgressHud_STRONG) UIView *m_GrayNindicator;
@property (GrayN_ProgressHud_STRONG) NSTimer *m_GrayNgraceTimer;
@property (GrayN_ProgressHud_STRONG) NSTimer *m_GrayNminShowTimer;
@property (GrayN_ProgressHud_STRONG) NSDate *m_GrayNshowStarted;
@property (assign) CGSize m_GrayNsize;

@end


@implementation GrayN_ProgressHud_oc
{
    BOOL m_GrayNuseAnimation;
    SEL m_GrayNmethodForExecution;
    id m_GrayNtargetForExecution;
    id m_GrayNobjectForExecution;
    UILabel *m_GrayNlabel;
    UILabel *m_GrayNdetailsLabel;
    BOOL m_GrayNisFinished;
    CGAffineTransform m_GrayNrotationTransform;
}

#pragma mark - Properties

@synthesize m_GrayNProgressHud_animationType;
@synthesize m_GrayNProgressHud_delegate;
@synthesize m_GrayNopacity;
@synthesize m_GrayNlabelFont;
@synthesize m_GrayNdetailsLabelFont;
@synthesize m_GrayNindicator;
@synthesize m_GrayNxOffset;
@synthesize m_GrayNyOffset;
@synthesize m_GrayNminSize;
@synthesize m_GrayNsquare;
@synthesize m_GrayNmargin;
@synthesize m_GrayNdimBackground;
@synthesize m_GrayNgraceTime;
@synthesize m_GrayNminShowTime;
@synthesize m_GrayNgraceTimer;
@synthesize m_GrayNminShowTimer;
@synthesize m_GrayNtaskInProgress;
@synthesize m_GrayNremoveFromSuperViewOnHide;
@synthesize m_GrayNProgressHud_customView;
@synthesize m_GrayNshowStarted;
@synthesize m_GrayNProgressHud_mode;
@synthesize m_GrayNlabelText;
@synthesize m_GrayNdetailsLabelText;
@synthesize m_GrayNprogress;
@synthesize m_GrayNsize;

#pragma mark - Class methods

+ (GrayN_ProgressHud_oc *)GrayN_ShowProgressHudAddedTo:(UIView *)view animated:(BOOL)animated
{
    GrayN_ProgressHud_oc *hud = [[GrayN_ProgressHud_oc alloc] GrayNinitWithView:view];
    [view addSubview:hud];
    [hud show:animated];
    return MB_AUTORELEASE(hud);
}

+ (BOOL)GrayN_HideProgressHudForView:(UIView *)view animated:(BOOL)animated
{
    GrayN_ProgressHud_oc *hud = [GrayN_ProgressHud_oc GrayN_HudForView:view];
    if (hud != nil) {
        hud.m_GrayNremoveFromSuperViewOnHide = YES;
        [hud hide:animated];
        return YES;
    }
    return NO;
}

+ (NSUInteger)GrayN_HideAllProgressHudForView:(UIView *)view animated:(BOOL)animated
{
    NSArray *huds = [self GrayN_AllHudForView:view];
    for (GrayN_ProgressHud_oc *hud in huds) {
        hud.m_GrayNremoveFromSuperViewOnHide = YES;
        [hud hide:animated];
    }
    return [huds count];
}

+ (GrayN_ProgressHud_oc *)GrayN_HudForView:(UIView *)view
{
    GrayN_ProgressHud_oc *hud = nil;
    NSArray *subviews = view.subviews;
    Class hudClass = [GrayN_ProgressHud_oc class];
    for (UIView *view in subviews) {
        if ([view isKindOfClass:hudClass]) {
            hud = (GrayN_ProgressHud_oc *)view;
        }
    }
    return hud;
}

+ (NSArray *)GrayN_AllHudForView:(UIView *)view
{
    NSMutableArray *huds = [NSMutableArray array];
    NSArray *subviews = view.subviews;
    Class hudClass = [GrayN_ProgressHud_oc class];
    for (UIView *view in subviews) {
        if ([view isKindOfClass:hudClass]) {
            [huds addObject:view];
        }
    }
    return [NSArray arrayWithArray:huds];
}

#pragma mark - Lifecycle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Set default values for properties
        self.m_GrayNProgressHud_animationType = GrayN_ProgressHud_AnimationFade;
        self.m_GrayNProgressHud_mode = GrayN_ProgressHud_ModeIndeterminate;
        self.m_GrayNlabelText = nil;

        self.m_GrayNdetailsLabelText = nil;
        self.m_GrayNopacity = 0.8f;
        self.m_GrayNlabelFont = [UIFont boldSystemFontOfSize:p_GrayN_LabelFontSize];
        self.m_GrayNdetailsLabelFont = [UIFont boldSystemFontOfSize:p_GrayN_DetailsLabelFontSize];
        self.m_GrayNxOffset = 0.0f;
        self.m_GrayNyOffset = 0.0f;
        self.m_GrayNdimBackground = NO;
        self.m_GrayNmargin = 20.0f;
        self.m_GrayNgraceTime = 0.0f;
        self.m_GrayNminShowTime = 0.0f;
        self.m_GrayNremoveFromSuperViewOnHide = NO;
        self.m_GrayNminSize = CGSizeZero;
        self.m_GrayNsquare = NO;
        self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin
								| UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        // Transparent background
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        // Make it invisible for now
        self.alpha = 0.0f;
        self.
        m_GrayNtaskInProgress = NO;
        m_GrayNrotationTransform = CGAffineTransformIdentity;
        
        [self GrayNsetupLabels];
        [self GrayNupdateIndicators];
        [self GrayNregisterForKVO];
        [self GrayNregisterForNotifications];
    }
    return self;
}

- (id)GrayNinitWithView:(UIView *)view
{
    NSAssert(view, @"View must not be nil.");
    id me = [self initWithFrame:view.bounds];
    // We need to take care of rotation ourselfs if we're adding the HUD to a window
    if ([view isKindOfClass:[UIWindow class]]) {
        [self GrayNsetTransformForCurrentOrientation:NO];
    }
    return me;
}

- (id)GrayNinitWithWindow:(UIWindow *)window
{
    return [self GrayNinitWithView:window];
}

- (void)dealloc
{
    [self GrayNunregisterFromNotifications];
    [self GrayNunregisterFromKVO];
#if !__has_feature(objc_arc)
    [m_GrayNindicator release];
    [m_GrayNlabel release];
    [m_GrayNdetailsLabel release];
    [m_GrayNlabelText release];
    [m_GrayNdetailsLabelText release];
    [m_GrayNgraceTimer release];
    [m_GrayNminShowTimer release];
    [m_GrayNshowStarted release];
    [m_GrayNProgressHud_customView release];
    [super dealloc];
#endif
}

#pragma mark - Show & hide

- (void)show:(BOOL)animated
{
    m_GrayNuseAnimation = animated;
    // If the grace time is set postpone the HUD display
    if (self.m_GrayNgraceTime > 0.0) {
        self.m_GrayNgraceTimer = [NSTimer scheduledTimerWithTimeInterval:self.m_GrayNgraceTime target:self
                                                         selector:@selector(GrayNhandleGraceTimer:) userInfo:nil repeats:NO];
    }
    // ... otherwise show the HUD imediately
    else {
        [self setNeedsDisplay];
        [self GrayNshowUsingAnimation:m_GrayNuseAnimation];
    }
}

- (void)hide:(BOOL)animated
{
    m_GrayNuseAnimation = animated;
    // If the minShow time is set, calculate how long the hud was shown,
    // and pospone the hiding operation if necessary
    if (self.m_GrayNminShowTime > 0.0 && m_GrayNshowStarted) {
        NSTimeInterval interv = [[NSDate date] timeIntervalSinceDate:m_GrayNshowStarted];
        if (interv < self.m_GrayNminShowTime) {
            self.m_GrayNminShowTimer = [NSTimer scheduledTimerWithTimeInterval:(self.m_GrayNminShowTime - interv) target:self
                                                               selector:@selector(GrayNhandleMinShowTimer:) userInfo:nil repeats:NO];
            return;
        }
    }
    // ... otherwise hide the HUD immediately
    [self GrayNhideUsingAnimation:m_GrayNuseAnimation];
}

- (void)hide:(BOOL)animated afterDelay:(NSTimeInterval)delay
{
    [self performSelector:@selector(GrayNhideDelayed:) withObject:[NSNumber numberWithBool:animated] afterDelay:delay];
}

- (void)GrayNhideDelayed:(NSNumber *)animated
{
    [self hide:[animated boolValue]];
}

#pragma mark - Timer callbacks

- (void)GrayNhandleGraceTimer:(NSTimer *)theTimer
{
    // Show the HUD only if the task is still running
    if (m_GrayNtaskInProgress) {
        [self setNeedsDisplay];
        [self GrayNshowUsingAnimation:m_GrayNuseAnimation];
    }
}

- (void)GrayNhandleMinShowTimer:(NSTimer *)theTimer
{
    [self GrayNhideUsingAnimation:m_GrayNuseAnimation];
}

#pragma mark - Internal show & hide operations

- (void)GrayNshowUsingAnimation:(BOOL)animated {
    self.alpha = 0.0f;
    if (animated && m_GrayNProgressHud_animationType == GrayN_ProgressHud_AnimationZoom) {
        self.transform = CGAffineTransformConcat(m_GrayNrotationTransform, CGAffineTransformMakeScale(1.5f, 1.5f));
    }
    self.m_GrayNshowStarted = [NSDate date];
    // Fade in
    if (animated) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.30];
        self.alpha = 1.0f;
        if (m_GrayNProgressHud_animationType == GrayN_ProgressHud_AnimationZoom) {
            self.transform = m_GrayNrotationTransform;
        }
        [UIView commitAnimations];
    }
    else {
        self.alpha = 1.0f;
    }
}

- (void)GrayNhideUsingAnimation:(BOOL)animated
{
    // Fade out
    if (animated && m_GrayNshowStarted) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.30];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(animationFinished:finished:context:)];
        // 0.02 prevents the hud from passing through touches during the animation the hud will get completely hidden
        // in the GrayNdone method
        if (m_GrayNProgressHud_animationType == GrayN_ProgressHud_AnimationZoom) {
            self.transform = CGAffineTransformConcat(m_GrayNrotationTransform, CGAffineTransformMakeScale(0.5f, 0.5f));
        }
        self.alpha = 0.02f;
        [UIView commitAnimations];
    }
    else {
        self.alpha = 0.0f;
        [self GrayNdone];
    }
    self.m_GrayNshowStarted = nil;
}

- (void)animationFinished:(NSString *)animationID finished:(BOOL)finished context:(void*)context {
    [self GrayNdone];
}

- (void)GrayNdone {
    m_GrayNisFinished = YES;
    self.alpha = 0.0f;
    if ([m_GrayNProgressHud_delegate respondsToSelector:@selector(GrayNhudWasHidden:)]) {
        [m_GrayNProgressHud_delegate performSelector:@selector(GrayNhudWasHidden:) withObject:self];
    }
    if (m_GrayNremoveFromSuperViewOnHide) {
        [self removeFromSuperview];
    }
}

#pragma mark - Threading

- (void)GrayNshowWhileExecuting:(SEL)method onTarget:(id)target withObject:(id)object animated:(BOOL)animated
{
    m_GrayNmethodForExecution = method;
    m_GrayNtargetForExecution = MB_RETAIN(target);
    m_GrayNobjectForExecution = MB_RETAIN(object);
    // Launch execution in new thread
    self.m_GrayNtaskInProgress = YES;
    [NSThread detachNewThreadSelector:@selector(GrayNlaunchExecution) toTarget:self withObject:nil];
    // Show HUD view
    [self show:animated];
}

- (void)GrayNlaunchExecution
{
    @autoreleasepool {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        // Start executing the requested task
        [m_GrayNtargetForExecution performSelector:m_GrayNmethodForExecution withObject:m_GrayNobjectForExecution];
#pragma clang diagnostic pop
        // Task completed, update view in main thread (note: view operations should
        // be done only in the main thread)
        [self performSelectorOnMainThread:@selector(GrayNcleanUp) withObject:nil waitUntilDone:NO];
    }
}

- (void)GrayNcleanUp
{
    m_GrayNtaskInProgress = NO;
    self.m_GrayNindicator = nil;
#if !__has_feature(objc_arc)
    [m_GrayNtargetForExecution release];
    [m_GrayNobjectForExecution release];
#endif
    [self hide:m_GrayNuseAnimation];
}

#pragma mark - UI

- (void)GrayNsetupLabels
{
    m_GrayNlabel = [[UILabel alloc] initWithFrame:self.bounds];
    m_GrayNlabel.adjustsFontSizeToFitWidth = NO;
    m_GrayNlabel.textAlignment = NSTextAlignmentCenter;
    m_GrayNlabel.opaque = NO;
    m_GrayNlabel.backgroundColor = [UIColor clearColor];
    m_GrayNlabel.textColor = [UIColor whiteColor];
    m_GrayNlabel.numberOfLines = 0;
    m_GrayNlabel.font = self.m_GrayNlabelFont;
    m_GrayNlabel.text = self.m_GrayNlabelText;
    m_GrayNlabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self addSubview:m_GrayNlabel];
    //    NSLog(@"label.frame=%@",NSStringFromCGRect(label.frame));
    
    m_GrayNdetailsLabel = [[UILabel alloc] initWithFrame:self.bounds];
    m_GrayNdetailsLabel.font = self.m_GrayNdetailsLabelFont;
    m_GrayNdetailsLabel.adjustsFontSizeToFitWidth = NO;
    m_GrayNdetailsLabel.textAlignment = NSTextAlignmentCenter;
    m_GrayNdetailsLabel.opaque = NO;
    m_GrayNdetailsLabel.backgroundColor = [UIColor clearColor];
    m_GrayNdetailsLabel.textColor = [UIColor whiteColor];
    m_GrayNdetailsLabel.numberOfLines = 0;
    m_GrayNdetailsLabel.font = self.m_GrayNdetailsLabelFont;
    m_GrayNdetailsLabel.text = self.m_GrayNdetailsLabelText;
    m_GrayNdetailsLabel.lineBreakMode = NSLineBreakByWordWrapping;

    [self addSubview:m_GrayNdetailsLabel];
}

- (void)GrayNupdateIndicators
{
    
    BOOL isActivityIndicator = [m_GrayNindicator isKindOfClass:[UIActivityIndicatorView class]];
    BOOL isRoundIndicator = [m_GrayNindicator isKindOfClass:[GrayN_ProgressView class]];
    
    if (m_GrayNProgressHud_mode == GrayN_ProgressHud_ModeIndeterminate &&  !isActivityIndicator) {
        // Update to indeterminate indicator
        [m_GrayNindicator removeFromSuperview];
        self.m_GrayNindicator = MB_AUTORELEASE([[UIActivityIndicatorView alloc]
                                         initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge]);
        [(UIActivityIndicatorView *)m_GrayNindicator startAnimating];
        [self addSubview:m_GrayNindicator];
    }
    else if (m_GrayNProgressHud_mode == GrayN_ProgressHud_ModeDeterminate || m_GrayNProgressHud_mode == GrayN_ProgressHud_ModeAnnularDeterminate) {
        if (!isRoundIndicator) {
            // Update to determinante indicator
            [m_GrayNindicator removeFromSuperview];
            self.m_GrayNindicator = MB_AUTORELEASE([[GrayN_ProgressView alloc] init]);
            [self addSubview:m_GrayNindicator];
        }
        if (m_GrayNProgressHud_mode == GrayN_ProgressHud_ModeAnnularDeterminate) {
            [(GrayN_ProgressView *)m_GrayNindicator setAnnular:YES];
        }
    }
    else if (m_GrayNProgressHud_mode == GrayN_ProgressHud_ModeCustomView && m_GrayNProgressHud_customView != m_GrayNindicator) {
        // Update custom view indicator
        [m_GrayNindicator removeFromSuperview];
        self.m_GrayNindicator = m_GrayNProgressHud_customView;
        [self addSubview:m_GrayNindicator];
    } else if (m_GrayNProgressHud_mode == GrayN_ProgressHud_ModeText) {
        [m_GrayNindicator removeFromSuperview];
        self.m_GrayNindicator = nil;
    }
}

#pragma mark - Layout

- (void)layoutSubviews {
    
    // Entirely cover the parent view
    UIView *parent = self.superview;
    if (parent) {
        self.frame = parent.bounds;
    }
    CGRect bounds = self.bounds;
    
    // Determine the total widt and height needed
    CGFloat maxWidth = bounds.size.width - 4 * m_GrayNmargin;
    CGSize totalSize = CGSizeZero;
    
    CGRect indicatorF = m_GrayNindicator.bounds;
    indicatorF.size.width = MIN(indicatorF.size.width, maxWidth);
    totalSize.width = MAX(totalSize.width, indicatorF.size.width);
    totalSize.height += indicatorF.size.height;
    
    CGSize labelSize = [m_GrayNlabel.text sizeWithFont:m_GrayNlabel.font];
    int lineNum = labelSize.width/maxWidth;
    if (lineNum == 0) {
        lineNum = 1;
    } else {
        lineNum+=1;
    }
    if (p_GrayN_NumOfLine >= 2) {
        lineNum = p_GrayN_NumOfLine;
    }
    CGSize maxSize = CGSizeMake(maxWidth, labelSize.height*lineNum);
    labelSize = [m_GrayNlabel.text sizeWithFont:m_GrayNlabel.font
                       constrainedToSize:maxSize
                           lineBreakMode:m_GrayNlabel.lineBreakMode];
    //    NSLog(@"labelSize=%@",NSStringFromCGSize(labelSize));
    labelSize.width = MIN(labelSize.width, maxWidth);
    totalSize.width = MAX(totalSize.width, labelSize.width);
    totalSize.height += labelSize.height;
    if (labelSize.height > 0.f && indicatorF.size.height > 0.f) {
        totalSize.height += p_GrayN_Padding;
    }
    
    CGFloat remainingHeight = bounds.size.height - totalSize.height - p_GrayN_Padding - 4 * m_GrayNmargin;
    //CGSize
    maxSize = CGSizeMake(maxWidth, remainingHeight);
    CGSize detailsLabelSize = [m_GrayNdetailsLabel.text sizeWithFont:m_GrayNdetailsLabel.font
                                            constrainedToSize:maxSize lineBreakMode:m_GrayNdetailsLabel.lineBreakMode];
    totalSize.width = MAX(totalSize.width, detailsLabelSize.width);
    totalSize.height += detailsLabelSize.height;
    if (detailsLabelSize.height > 0.f && (indicatorF.size.height > 0.f || labelSize.height > 0.f)) {
        totalSize.height += p_GrayN_Padding;
    }
    
    totalSize.width += 2 * m_GrayNmargin;
    totalSize.height += 2 * m_GrayNmargin;
    
    // Position elements
    CGFloat yPos = roundf(((bounds.size.height - totalSize.height) / 2)) + m_GrayNmargin + m_GrayNyOffset;
    CGFloat xPos = m_GrayNxOffset;
    indicatorF.origin.y = yPos;
    indicatorF.origin.x = roundf((bounds.size.width - indicatorF.size.width) / 2) + xPos;
    m_GrayNindicator.frame = indicatorF;
    yPos += indicatorF.size.height;
    
    if (labelSize.height > 0.f && indicatorF.size.height > 0.f) {
        yPos += p_GrayN_Padding;
    }
    CGRect labelF;
    labelF.origin.y = yPos;
    labelF.origin.x = roundf((bounds.size.width - labelSize.width) / 2) + xPos;
    labelF.size = labelSize;
    m_GrayNlabel.frame = labelF;
    yPos += labelF.size.height;
    
    if (detailsLabelSize.height > 0.f && (indicatorF.size.height > 0.f || labelSize.height > 0.f)) {
        yPos += p_GrayN_Padding;
    }
    CGRect detailsLabelF;
    detailsLabelF.origin.y = yPos;
    detailsLabelF.origin.x = roundf((bounds.size.width - detailsLabelSize.width) / 2) + xPos;
    detailsLabelF.size = detailsLabelSize;
    m_GrayNdetailsLabel.frame = detailsLabelF;
    
    // Enforce minsize and quare rules
    if (m_GrayNsquare) {
        CGFloat max = MAX(totalSize.width, totalSize.height);
        if (max <= bounds.size.width - 2 * m_GrayNmargin) {
            totalSize.width = max;
        }
        if (max <= bounds.size.height - 2 * m_GrayNmargin) {
            totalSize.height = max;
        }
    }
    if (totalSize.width < m_GrayNminSize.width) {
        totalSize.width = m_GrayNminSize.width;
    }
    if (totalSize.height < m_GrayNminSize.height) {
        totalSize.height = m_GrayNminSize.height;
    }
//    totalSize.height *= 2;
    self.m_GrayNsize = totalSize;
}

#pragma mark BG Drawing

- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (m_GrayNdimBackground) {
        //Gradient colours
        size_t gradLocationsNum = 2;
        CGFloat gradLocations[2] = {0.0f, 1.0f};
        CGFloat gradColors[8] = {0.0f,0.0f,0.0f,0.0f,0.0f,0.0f,0.0f,0.75f};
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, gradColors, gradLocations, gradLocationsNum);
        CGColorSpaceRelease(colorSpace);
        //Gradient center
        CGPoint gradCenter= CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        //Gradient radius
        float gradRadius = MIN(self.bounds.size.width , self.bounds.size.height) ;
        //Gradient draw
        CGContextDrawRadialGradient (context, gradient, gradCenter,
                                     0, gradCenter, gradRadius,
                                     kCGGradientDrawsAfterEndLocation);
        CGGradientRelease(gradient);
    }
    
    // Center HUD
    CGRect allRect = self.bounds;
    // Draw rounded HUD bacgroud rect
    CGRect boxRect = CGRectMake(roundf((allRect.size.width - m_GrayNsize.width) / 2) + self.m_GrayNxOffset,
                                roundf((allRect.size.height - m_GrayNsize.height) / 2) + self.m_GrayNyOffset, m_GrayNsize.width, m_GrayNsize.height);
    float radius = 10.0f;
    CGContextBeginPath(context);
    CGContextSetGrayFillColor(context, 0.0f, self.m_GrayNopacity);
    CGContextMoveToPoint(context, CGRectGetMinX(boxRect) + radius, CGRectGetMinY(boxRect));
    CGContextAddArc(context, CGRectGetMaxX(boxRect) - radius, CGRectGetMinY(boxRect) + radius, radius, 3 * (float)M_PI / 2, 0, 0);
    CGContextAddArc(context, CGRectGetMaxX(boxRect) - radius, CGRectGetMaxY(boxRect) - radius, radius, 0, (float)M_PI / 2, 0);
    CGContextAddArc(context, CGRectGetMinX(boxRect) + radius, CGRectGetMaxY(boxRect) - radius, radius, (float)M_PI / 2, (float)M_PI, 0);
    CGContextAddArc(context, CGRectGetMinX(boxRect) + radius, CGRectGetMinY(boxRect) + radius, radius, (float)M_PI, 3 * (float)M_PI / 2, 0);
    CGContextClosePath(context);
    CGContextFillPath(context);
}

#pragma mark - KVO

- (void)GrayNregisterForKVO {
    for (NSString *keyPath in [self GrayNobservableKeypaths]) {
        [self addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:NULL];
    }
}

- (void)GrayNunregisterFromKVO {
    for (NSString *keyPath in [self GrayNobservableKeypaths]) {
        [self removeObserver:self forKeyPath:keyPath];
    }
}

- (NSArray *)GrayNobservableKeypaths {
    return [NSArray arrayWithObjects:@"m_GrayNmode", @"m_GrayNcustomView", @"m_GrayNlabelText", @"m_GrayNlabelFont",
            @"m_GrayNdetailsLabelText", @"m_GrayNdetailsLabelFont", @"m_GrayNprogress", nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(GrayNupdateUIForKeypath:) withObject:keyPath waitUntilDone:NO];
    } else {
        [self GrayNupdateUIForKeypath:keyPath];
    }
}

- (void)GrayNupdateUIForKeypath:(NSString *)keyPath
{
    if ([keyPath isEqualToString:@"m_GrayNmode"] || [keyPath isEqualToString:@"m_GrayNcustomView"]) {
        [self GrayNupdateIndicators];
    } else if ([keyPath isEqualToString:@"m_GrayNlabelText"]) {
         NSString *msg = [NSString stringWithFormat:@"%@",[self.m_GrayNlabelText stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"]];
//        msg = @"当充值发生在游戏外时，请不要继续。重新回到游戏再充值！\n订单已生成，正在获取商品信息...";
        NSArray *numOfN = [msg componentsSeparatedByString:@"\n"];
        p_GrayN_NumOfLine = (int)numOfN.count;
//        NSLog(@"SSSSSSSSSSS%d",p_GrayN_NumOfLine);

        m_GrayNlabel.text = msg;
        
//        NSLog(@"xxxxxxxx=%@",msg);
    } else if ([keyPath isEqualToString:@"m_GrayNlabelFont"]) {
        m_GrayNlabel.font = self.m_GrayNlabelFont;
    } else if ([keyPath isEqualToString:@"m_GrayNdetailsLabelText"]) {
        m_GrayNdetailsLabel.text = self.m_GrayNdetailsLabelText;
    } else if ([keyPath isEqualToString:@"m_GrayNdetailsLabelFont"]) {
        m_GrayNdetailsLabel.font = self.m_GrayNdetailsLabelFont;
    } else if ([keyPath isEqualToString:@"m_GrayNprogress"]) {
        if ([m_GrayNindicator respondsToSelector:@selector(setProgress:)]) {
            [(id)m_GrayNindicator setProgress:m_GrayNprogress];
        }
        return;
    }
    [self setNeedsLayout];
    [self setNeedsDisplay];
}

#pragma mark - Notifications

- (void)GrayNregisterForNotifications
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(GrayNdeviceOrientationDidChange:)
               name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)GrayNunregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)GrayNdeviceOrientationDidChange:(NSNotification *)notification
{
    UIView *superview = self.superview;
    if (!superview) {
        return;
    } else if ([superview isKindOfClass:[UIWindow class]]) {
        [self GrayNsetTransformForCurrentOrientation:YES];
    } else {
        self.bounds = self.superview.bounds;
        [self setNeedsDisplay];
    }
}

- (void)GrayNsetTransformForCurrentOrientation:(BOOL)animated {
    // Stay in sync with the superview
    if (self.superview) {
        self.bounds = self.superview.bounds;
        [self setNeedsDisplay];
    }
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    float radians = 0;
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        if (orientation == UIInterfaceOrientationLandscapeLeft) { radians = -M_PI_2; }
        else { radians = M_PI_2; }
        // Window coordinates differ!
        self.bounds = CGRectMake(0, 0, self.bounds.size.height, self.bounds.size.width);
    } else {
        if (orientation == UIInterfaceOrientationPortraitUpsideDown) { radians = M_PI; }
        else { radians = 0; }
    }
    m_GrayNrotationTransform = CGAffineTransformMakeRotation(radians);
    
    if (animated) {
        [UIView beginAnimations:nil context:nil];
    }
    [self setTransform:m_GrayNrotationTransform];
    if (animated) {
        [UIView commitAnimations];
    }
}

@end


@implementation GrayN_ProgressView
{
    float _progress;
    BOOL _annular;
}

#pragma mark - Accessors

- (float)progress {
    return _progress;
}

- (void)setProgress:(float)progress {
    _progress = progress;
    [self setNeedsDisplay];
}

- (BOOL)isAnnular {
    return _annular;
}

- (void)setAnnular:(BOOL)annular {
    _annular = annular;
    [self setNeedsDisplay];
}

#pragma mark - Lifecycle

- (id)init {
    return [self initWithFrame:CGRectMake(0.f, 0.f, 37.f, 37.f)];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        _progress = 0.f;
        _annular = NO;
    }
    return self;
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect {
    
    CGRect allRect = self.bounds;
    CGRect circleRect = CGRectInset(allRect, 2.0f, 2.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (_annular) {
        // Draw background
        CGFloat lineWidth = 5.f;
        UIBezierPath *processBackgroundPath = [UIBezierPath bezierPath];
        processBackgroundPath.lineWidth = lineWidth;
        processBackgroundPath.lineCapStyle = kCGLineCapRound;
        CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        CGFloat radius = (self.bounds.size.width - lineWidth)/2;
        CGFloat startAngle = - ((float)M_PI / 2); // 90 degrees
        CGFloat endAngle = (2 * (float)M_PI) + startAngle;
        [processBackgroundPath addArcWithCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
        [[UIColor colorWithRed:1 green:1 blue:1 alpha:0.1] set];
        [processBackgroundPath stroke];
        // Draw progress
        UIBezierPath *processPath = [UIBezierPath bezierPath];
        processPath.lineCapStyle = kCGLineCapRound;
        processPath.lineWidth = lineWidth;
        endAngle = (self.progress * 2 * (float)M_PI) + startAngle;
        [processPath addArcWithCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
        [[UIColor whiteColor] set];
        [processPath stroke];
    } else {
        // Draw background
        CGContextSetRGBStrokeColor(context, 1.0f, 1.0f, 1.0f, 1.0f); // white
        CGContextSetRGBFillColor(context, 1.0f, 1.0f, 1.0f, 0.1f); // translucent white
        CGContextSetLineWidth(context, 2.0f);
        CGContextFillEllipseInRect(context, circleRect);
        CGContextStrokeEllipseInRect(context, circleRect);
        // Draw progress
        CGPoint center = CGPointMake(allRect.size.width / 2, allRect.size.height / 2);
        CGFloat radius = (allRect.size.width - 4) / 2;
        CGFloat startAngle = - ((float)M_PI / 2); // 90 degrees
        CGFloat endAngle = (self.progress * 2 * (float)M_PI) + startAngle;
        CGContextSetRGBFillColor(context, 1.0f, 1.0f, 1.0f, 1.0f); // white
        CGContextMoveToPoint(context, center.x, center.y);
        CGContextAddArc(context, center.x, center.y, radius, startAngle, endAngle, 0);
        CGContextClosePath(context);
        CGContextFillPath(context);
    }
}

@end
