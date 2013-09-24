//
//  KSSlideController.h
//  KSFramework
//
//  This file is part of a fork of MFSideMenu by Michael Frederick.
//
//  Modified by Travis Zehren beginning 9/07/13.
//  Copyright (c) 2013 Kickstand Apps. All rights reserved.
//
//  This file incorporates work covered by the following copyright and
//  permission notice:
//
//    MFSideMenuContainerViewController.h
//    MFSideMenuDemoSplitViewController
//
//    Created by Michael Frederick on 4/2/13.
//    Copyright (c) 2013 Frederick Development. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSViewShadow.h"

// Name of event pushed to NSNotificationCenter when slide controller state has changed.
extern NSString * const KSSlideControllerStateNotificationEvent;

// Used to determine which, if any, views will cause gestures to slide views.
typedef enum {
    KSSlideControllerPanModeNone = 0,
    KSSlideControllerPanModeCenterView = 1 << 0,
    KSSlideControllerPanModeSideView = 1 << 1,
    KSSlideControllerPanModeDefault = KSSlideControllerPanModeCenterView | KSSlideControllerPanModeSideView
} KSSlideControllerPanMode;

// Used to indicate the state of the slide controller.
typedef enum {
    KSSlideControllerStateClosed,
    KSSlideControllerStateLeftViewOpen,
    KSSlideControllerStateRightViewOpen
} KSSlideControllerState;

// Events that will be called to NSNotificationCenter.
typedef enum {
    KSSlideControllerStateEventSideViewWillOpen,
    KSSlideControllerStateEventSideViewDidOpen,
    KSSlideControllerStateEventSideViewWillClose,
    KSSlideControllerStateEventSideViewDidClose
} KSSlideControllerStateEvent;

// Determines whether views continue beneath the status bar or are offset below it.
// Only applicable on iOS 7.
typedef enum {
    KSSlideStatusBarModeOverlay,
    KSSlideStatusBarModeOffset
} KSSlideStatusBarMode;

#pragma mark - UIViewController + KSSlideController

@class KSSlideController;

// Add property to UIViewControllers to identify parent KSSlideController
@interface UIViewController (KSSlideController)

@property(nonatomic, readonly, retain) KSSlideController *slideController;

@end


#pragma mark - KSSlideController

@interface KSSlideController : UIViewController<UIGestureRecognizerDelegate>

// Create KSSlideController with initial view controllers. Sending "nil" is acceptable.
+ (KSSlideController *)slideControllerWithCenterViewController:(id)centerViewController
                                            leftViewController:(id)leftViewController
                                           rightViewController:(id)rightViewController;

@property (nonatomic, strong) id centerViewController;
@property (nonatomic, strong) UIViewController *leftViewController;
@property (nonatomic, strong) UIViewController *rightViewController;

@property (nonatomic, assign) KSSlideControllerState slideControllerState;
@property (nonatomic, assign) KSSlideControllerPanMode panMode;

@property (nonatomic, assign) CGFloat sideViewWidth;
@property (nonatomic, assign) CGFloat leftViewWidth;
@property (nonatomic, assign) CGFloat rightViewWidth;

// Shadows are only shown for view "in front".
@property (nonatomic, strong) KSViewShadow *centerViewShadow;
@property (nonatomic, strong) KSViewShadow *leftViewShadow;
@property (nonatomic, strong) KSViewShadow *rightViewShadow;

// Status bar properties are only used in iOS 7 when you the have status bar showing
@property (nonatomic, assign) KSSlideStatusBarMode statusBarMode;
@property (nonatomic, strong) UIColor *centerViewStatusBarColor;
@property (nonatomic, strong) UIColor *sideViewStatusBarColor;

// Overlap of views. Default is "NO" (center view slides over side views).
@property (nonatomic, assign) BOOL sideViewsInFront;

// Open/close animation duration -- user can pan faster than default duration.
@property (nonatomic, assign) CGFloat slideAnimationDuration;

// Adjust how the background view slides in or out.
// 0 = no background view movement (default).
// > 0 & < 1 = ratio of movement to side view width.
// 1 = full background view movement.
@property (nonatomic, assign) CGFloat slideParallaxFactor;

// Adjust how the background view scales as it slides in or out.
// 1 = no scaling (default).
// < 1 = scale of background view when not focused upon.
@property (nonatomic, assign) CGFloat slideScaleFactor;

// Adjust tint and opacity over inactive center view.
@property (nonatomic, strong) UIColor *slideTintColor;
@property (nonatomic, assign) CGFloat slideTintOpacity;

// Slide in blurring of side views (blur -> sharp as side view opens).
// 0 = no blurring (default).
// 1 = full blur.
@property (nonatomic, assign) CGFloat sideViewBlurFactor;

// Slide out blurring of center view (sharp -> blur as side view opens).
// 0 = no blurring (default).
// 1 = full blur.
@property (nonatomic, assign) CGFloat centerViewBlurFactor;

// Toggle side views open and close. Can pass in optional completion block.
- (void)toggleLeftViewWithCompletion:(void (^)(void))completion;
- (void)toggleRightViewWithCompletion:(void (^)(void))completion;

// Set KSSlideController state explicitly. Can pass in optional completion block.
- (void)setSlideControllerState:(KSSlideControllerState)state completion:(void (^)(void))completion;

// Set the width of side views.
- (void)setSideViewWidth:(CGFloat)sideViewWidth animated:(BOOL)animated;
- (void)setLeftViewWidth:(CGFloat)leftViewWidth animated:(BOOL)animated;
- (void)setRightViewWidth:(CGFloat)rightViewWidth animated:(BOOL)animated;

// can be used to attach a pan gesture recognizer to a custom view
- (UIPanGestureRecognizer *)panGestureRecognizer;

@end