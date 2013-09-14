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

extern NSString * const KSSlideControllerStateNotificationEvent;

typedef enum {
    KSSlideControllerPanModeNone = 0, // pan disabled
    KSSlideControllerPanModeCenterViewController = 1 << 0, // enable panning on the centerViewController
    KSSlideControllerPanModeSideMenu = 1 << 1, // enable panning on side menus
    KSSlideControllerPanModeDefault = KSSlideControllerPanModeCenterViewController | KSSlideControllerPanModeSideMenu
} KSSlideControllerPanMode;

typedef enum {
    KSSlideControllerStateClosed, // the menu is closed
    KSSlideControllerStateLeftMenuOpen, // the left-hand menu is open
    KSSlideControllerStateRightMenuOpen // the right-hand menu is open
} KSSlideControllerState;

typedef enum {
    KSSlideControllerStateEventMenuWillOpen, // the menu is going to open
    KSSlideControllerStateEventMenuDidOpen, // the menu finished opening
    KSSlideControllerStateEventMenuWillClose, // the menu is going to close
    KSSlideControllerStateEventMenuDidClose // the menu finished closing
} KSSlideControllerStateEvent;


@interface KSSlideController : UIViewController<UIGestureRecognizerDelegate>

+ (KSSlideController *)slideControllerWithCenterViewController:(id)centerViewController
                                                  leftMenuViewController:(id)leftViewController
                                                 rightMenuViewController:(id)rightViewController;

@property (nonatomic, strong) id centerViewController;
@property (nonatomic, strong) UIViewController *leftViewController;
@property (nonatomic, strong) UIViewController *rightViewController;

@property (nonatomic, assign) KSSlideControllerState menuState;
@property (nonatomic, assign) KSSlideControllerPanMode panMode;

// menu open/close animation duration -- user can pan faster than default duration, max duration sets the limit
@property (nonatomic, assign) CGFloat menuAnimationDefaultDuration;
@property (nonatomic, assign) CGFloat menuAnimationMaxDuration;

// width of the side menus
@property (nonatomic, assign) CGFloat menuWidth;
@property (nonatomic, assign) CGFloat leftMenuWidth;
@property (nonatomic, assign) CGFloat rightMenuWidth;

// shadows - content shadow only shown when showMenuOverContent = NO
//         - menu shadows only shown when showMenuOverContent = YES
@property (nonatomic, strong) KSShadow *contentShadow;
@property (nonatomic, strong) KSShadow *leftMenuShadow;
@property (nonatomic, strong) KSShadow *rightMenuShadow;

// menu depth
@property (nonatomic, assign) BOOL showMenuOverContent;

// menu slide-in animation
@property (nonatomic, assign) CGFloat menuSlideParallaxFactor;
// 0 = no menu movement (default)
// > 0 & < 1 = ratio of movement to menu width
// 1 = full menu movement

// menu slide in scaling
@property (nonatomic, assign) CGFloat menuSlideScaleFactor;
// 1 = no scaling (default)
// < 1 = scale of menu or content when not focused upon

// menu slide in blurring (blur -> sharp as menu opens)
@property (nonatomic, assign) CGFloat menuBlurFactor;
// 0 = no blurring (default)
// 1 = full blur

// content slide out blurring (sharp -> blur as menu opens)
@property (nonatomic, assign) CGFloat contentBlurFactor;
// 0 = no blurring (default)
// 1 = full blur

- (void)toggleLeftSideMenuCompletion:(void (^)(void))completion;
- (void)toggleRightSideMenuCompletion:(void (^)(void))completion;
- (void)setMenuState:(MFSideMenuState)menuState completion:(void (^)(void))completion;
- (void)setMenuWidth:(CGFloat)menuWidth animated:(BOOL)animated;
- (void)setLeftMenuWidth:(CGFloat)leftMenuWidth animated:(BOOL)animated;
- (void)setRightMenuWidth:(CGFloat)rightMenuWidth animated:(BOOL)animated;

// can be used to attach a pan gesture recognizer to a custom view
- (UIPanGestureRecognizer *)panGestureRecognizer;

@end