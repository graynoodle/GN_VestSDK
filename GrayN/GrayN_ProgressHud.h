//
//
//  MBProgressHUD.h
//  Version 0.5
//  Created by Matej Bukovinski on 2.4.09.
//

// This code is distributed under the terms and conditions of the MIT license. 

// Copyright (c) 2011 Matej Bukovinski
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

@protocol GrayN_ProgressHud_Delegate;


typedef enum {
	/** Progress is shown using an UIActivityIndicatorView. This is the default. */
	GrayN_ProgressHud_ModeIndeterminate,
	/** Progress is shown using a round, pie-chart like, progress view. */
	GrayN_ProgressHud_ModeDeterminate,
	/** Progress is shown using a ring-shaped progress view. */
	GrayN_ProgressHud_ModeAnnularDeterminate,
	/** Shows a custom view */
	GrayN_ProgressHud_ModeCustomView,
	/** Shows only labels */
	GrayN_ProgressHud_ModeText
} GrayN_ProgressHud_Mode;

typedef enum {
	/** Opacity animation */
	GrayN_ProgressHud_AnimationFade,
	/** Opacity + scale animation */
	GrayN_ProgressHud_AnimationZoom
} MBProgressHUDAnimation;


#ifndef GrayN_ProgressHud_STRONG
#if __has_feature(objc_arc)
	#define GrayN_ProgressHud_STRONG strong
#else
	#define GrayN_ProgressHud_STRONG retain
#endif
#endif

#ifndef GrayN_ProgressHud_WEAK
#if __has_feature(objc_arc_weak)
	#define GrayN_ProgressHud_WEAK weak
#elif __has_feature(objc_arc)
	#define GrayN_ProgressHud_WEAK unsafe_unretained
#else
	#define GrayN_ProgressHud_WEAK assign
#endif
#endif


/** 
 * Displays a simple HUD window containing a progress indicator and two optional labels for short messages.
 *
 * This is a simple drop-in class for displaying a progress HUD view similar to Apple's private UIProgressHUD class.
 * The MBProgressHUD window spans over the entire space given to it by the initWithFrame constructor and catches all
 * user input on this region, thereby preventing the user operations on components below the view. The HUD itself is
 * drawn centered as a rounded semi-transparent view which resizes depending on the user specified content.
 *
 * This view supports four modes of operation:
 * - GrayN_ProgressHud_ModeIndeterminate - shows a UIActivityIndicatorView
 * - GrayN_ProgressHud_ModeDeterminate - shows a custom round progress indicator
 * - GrayN_ProgressHud_ModeAnnularDeterminate - shows a custom annular progress indicator
 * - GrayN_ProgressHud_ModeCustomView - shows an arbitrary, user specified view (@see m_GrayNProgressHud_customView)
 *
 * All three modes can have optional labels assigned:
 * - If the labelText property is set and non-empty then a label containing the provided content is placed below the
 *   indicator view.
 * - If also the detailsLabelText property is set then another label is placed below the first label.
 */
@interface GrayN_ProgressHud_oc : UIView

/**
 * Creates a new HUD, adds it to provided view and shows it. The counterpart to this method is GrayN_HideProgressHudForView:animated:.
 * 
 * @param view The view that the HUD will be added to
 * @param animated If set to YES the HUD will appear using the current m_ProgressHud_animationType. If set to NO the HUD will not use
 * animations while appearing.
 * @return A reference to the created HUD.
 *
 * @see GrayN_HideProgressHudForView:animated:
 * @see m_ProgressHud_animationType
 */
+ (GrayN_ProgressHud_oc *)GrayN_ShowProgressHudAddedTo:(UIView *)view animated:(BOOL)animated;

/**
 * Finds the top-most HUD subview and hides it. The counterpart to this method is GrayN_ShowProgressHudAddedTo:animated:.
 *
 * @param view The view that is going to be searched for a HUD subview.
 * @param animated If set to YES the HUD will disappear using the current m_ProgressHud_animationType. If set to NO the HUD will not use
 * animations while disappearing.
 * @return YES if a HUD was found and removed, NO otherwise. 
 *
 * @see GrayN_ShowProgressHudAddedTo:animated:
 * @see m_ProgressHud_animationType
 */
+ (BOOL)GrayN_HideProgressHudForView:(UIView *)view animated:(BOOL)animated;

/**
 * Finds all the HUD subviews and hides them. 
 *
 * @param view The view that is going to be searched for HUD subviews.
 * @param animated If set to YES the HUDs will disappear using the current m_ProgressHud_animationType. If set to NO the HUDs will not use
 * animations while disappearing.
 * @return the number of HUDs found and removed.
 *
 * @see hideAllHUDForView:animated:
 * @see m_ProgressHud_animationType
 */
+ (NSUInteger)GrayN_HideAllProgressHudForView:(UIView *)view animated:(BOOL)animated;

/**
 * Finds the top-most HUD subview and returns it. 
 *
 * @param view The view that is going to be searched.
 * @return A reference to the last HUD subview discovered.
 */
+ (GrayN_ProgressHud_oc *)GrayN_HudForView:(UIView *)view;

/**
 * Finds all HUD subviews and returns them.
 *
 * @param view The view that is going to be searched.
 * @return All found HUD views (array of MBProgressHUD objects).
 */
+ (NSArray *)GrayN_AllHudForView:(UIView *)view;

/** 
 * Display the HUD. You need to make sure that the main thread completes its run loop soon after this method call so
 * the user interface can be updated. Call this method when your task is already set-up to be executed in a new thread
 * (e.g., when using something like NSOperation or calling an asynchronous call like NSURLRequest).
 *
 * @param animated If set to YES the HUD will appear using the current m_ProgressHud_animationType. If set to NO the HUD will not use
 * animations while appearing.
 *
 * @see m_ProgressHud_animationType
 */
- (void)show:(BOOL)animated;

/** 
 * Hide the HUD. This still calls the GrayNhudWasHidden: m_GrayNProgressHud_delegate. This is the counterpart of the show: method. Use it to
 * hide the HUD when your task completes.
 *
 * @param animated If set to YES the HUD will disappear using the current m_ProgressHud_animationType. If set to NO the HUD will not use
 * animations while disappearing.
 *
 * @see m_ProgressHud_animationType
 */
- (void)hide:(BOOL)animated;

/** 
 * Hide the HUD after a delay. This still calls the GrayNhudWasHidden: m_GrayNProgressHud_delegate. This is the counterpart of the show: method. Use it to
 * hide the HUD when your task completes.
 *
 * @param animated If set to YES the HUD will disappear using the current m_ProgressHud_animationType. If set to NO the HUD will not use
 * animations while disappearing.
 * @param delay Delay in secons until the HUD is hidden.
 *
 * @see m_ProgressHud_animationType
 */
- (void)hide:(BOOL)animated afterDelay:(NSTimeInterval)delay;

/** 
 * Shows the HUD while a background task is executing in a new thread, then hides the HUD.
 *
 * This method also takes care of autorelease pools so your method does not have to be concerned with setting up a
 * pool.
 *
 * @param method The method to be executed while the HUD is shown. This method will be executed in a new thread.
 * @param target The object that the target method belongs to.
 * @param object An optional object to be passed to the method.
 * @param animated If set to YES the HUD will (dis)appear using the current m_ProgressHud_animationType. If set to NO the HUD will not use
 * animations while (dis)appearing.
 */
- (void)GrayNshowWhileExecuting:(SEL)method onTarget:(id)target withObject:(id)object animated:(BOOL)animated;

/** 
 * A convenience constructor that initializes the HUD with the window's bounds. Calls the designated constructor with
 * window.bounds as the parameter.
 *
 * @param window The window instance that will provide the bounds for the HUD. Should be the same instance as
 * the HUD's superview (i.e., the window that the HUD will be added to).
 */
- (id)GrayNinitWithWindow:(UIWindow *)window;

/**
 * A convenience constructor that initializes the HUD with the view's bounds. Calls the designated constructor with
 * view.bounds as the parameter
 * 
 * @param view The view instance that will provide the bounds for the HUD. Should be the same instance as
 * the HUD's superview (i.e., the view that the HUD will be added to).
 */
- (id)GrayNinitWithView:(UIView *)view;

/** 
 * MBProgressHUD operation mode. The default is GrayN_ProgressHud_ModeIndeterminate.
 *
 * @see GrayN_ProgressHud_Mode
 */
@property (assign) GrayN_ProgressHud_Mode m_GrayNProgressHud_mode;

/**
 * The animation type that should be used when the HUD is shown and hidden. 
 *
 * @see MBProgressHUDAnimation
 */
@property (assign) MBProgressHUDAnimation m_GrayNProgressHud_animationType;

/**
 * The UIView (e.g., a UIImageView) to be shown when the HUD is in GrayN_ProgressHud_ModeCustomView.
 * For best results use a 37 by 37 pixel view (so the bounds match the built in indicator bounds). 
 */
@property (GrayN_ProgressHud_STRONG) UIView *m_GrayNProgressHud_customView;

/** 
 * The HUD m_GrayNProgressHud_delegate object.
 *
 * @see GrayN_ProgressHud_Delegate
 */
@property (GrayN_ProgressHud_WEAK) id<GrayN_ProgressHud_Delegate> m_GrayNProgressHud_delegate;

/** 
 * An optional short message to be displayed below the activity indicator. The HUD is automatically resized to fit
 * the entire text. If the text is too long it will get clipped by displaying "..." at the end. If left unchanged or
 * set to @"", then no message is displayed.
 */
@property (copy) NSString *m_GrayNlabelText;

/** 
 * An optional details message displayed below the labelText message. This message is displayed only if the labelText
 * property is also set and is different from an empty string (@""). The details text can span multiple lines. 
 */
@property (copy) NSString *m_GrayNdetailsLabelText;

/** 
 * The opacity of the HUD window. Defaults to 0.9 (90% opacity). 
 */
@property (assign) float m_GrayNopacity;

/** 
 * The x-axis offset of the HUD relative to the centre of the superview. 
 */
@property (assign) float m_GrayNxOffset;

/** 
 * The y-ayis offset of the HUD relative to the centre of the superview. 
 */
@property (assign) float m_GrayNyOffset;

/**
 * The amounth of space between the HUD edge and the HUD elements (labels, indicators or custom views). 
 * Defaults to 20.0
 */
@property (assign) float m_GrayNmargin;

/** 
 * Cover the HUD background view with a radial gradient. 
 */
@property (assign) BOOL m_GrayNdimBackground;

/*
 * Grace period is the time (in seconds) that the invoked method may be run without 
 * showing the HUD. If the task finishes before the grace time runs out, the HUD will
 * not be shown at all. 
 * This may be used to prevent HUD display for very short tasks.
 * Defaults to 0 (no grace time).
 * Grace time functionality is only supported when the task status is known!
 * @see taskInProgress
 */
@property (assign) float m_GrayNgraceTime;

/**
 * The minimum time (in seconds) that the HUD is shown. 
 * This avoids the problem of the HUD being shown and than instantly hidden.
 * Defaults to 0 (no minimum show time).
 */
@property (assign) float m_GrayNminShowTime;

/**
 * Indicates that the executed operation is in progress. Needed for correct graceTime operation.
 * If you don't set a graceTime (different than 0.0) this does nothing.
 * This property is automatically set when using GrayNshowWhileExecuting:onTarget:withObject:animated:.
 * When threading is done outside of the HUD (i.e., when the show: and hide: methods are used directly),
 * you need to set this property when your task starts and completes in order to have normal graceTime 
 * functionality.
 */
@property (assign) BOOL m_GrayNtaskInProgress;

/**
 * Removes the HUD from its parent view when hidden. 
 * Defaults to NO. 
 */
@property (assign) BOOL m_GrayNremoveFromSuperViewOnHide;

/** 
 * Font to be used for the main label. Set this property if the default is not adequate. 
 */
@property (GrayN_ProgressHud_STRONG) UIFont* m_GrayNlabelFont;

/** 
 * Font to be used for the details label. Set this property if the default is not adequate. 
 */
@property (GrayN_ProgressHud_STRONG) UIFont* m_GrayNdetailsLabelFont;

/** 
 * The progress of the progress indicator, from 0.0 to 1.0. Defaults to 0.0. 
 */
@property (assign) float m_GrayNprogress;

/**
 * The minimum size of the HUD bezel. Defaults to CGSizeZero (no minimum size).
 */
@property (assign) CGSize m_GrayNminSize;

/**
 * Force the HUD dimensions to be equal if possible. 
 */
@property (assign, getter = isSquare) BOOL m_GrayNsquare;

@end


@protocol GrayN_ProgressHud_Delegate <NSObject>

@optional

/** 
 * Called after the HUD was fully hidden from the screen. 
 */
- (void)GrayNhudWasHidden:(GrayN_ProgressHud_oc *)hud;

@end


/**
 * A progress view for showing definite progress by filling up a circle (pie chart).
 */
@interface GrayN_ProgressView : UIView

/**
 * Progress (0.0 to 1.0)
 */
@property (nonatomic, assign) float m_GrayNprogress;

/*
 * Display mode - NO = round or YES = annular. Defaults to round.
 */
@property (nonatomic, assign, getter = isAnnular) BOOL m_GrayNannular;

@end
