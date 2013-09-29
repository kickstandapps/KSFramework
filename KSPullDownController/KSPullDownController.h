//
//  KSPullDownController.h
//  KSFrameworkDemo
//
//  Created by Travis Zehren on 9/24/13.
//  Copyright (c) 2013 Kickstand Apps. All rights reserved.
//

#import <UIKit/UIKit.h>

// Used to indicate the state of the pull down controller.
typedef enum {
    KSPullDownControllerStateClosed,
    KSPullDownControllerStateOpen,
} KSPullDownControllerState;

// Determines whether views continue beneath the status bar or are offset below it.
// Only applicable on iOS 7.
typedef enum {
    KSPullDownStatusBarModeOverlay,
    KSPullDownStatusBarModeOffset
} KSPullDownStatusBarMode;


#pragma mark - UIViewController + KSPullDownController

@class KSPullDownController;

// Add property to UIViewControllers to identify parent KSPullDownController.
@interface UIViewController (KSPullDownController)

@property(nonatomic, readonly, retain) KSPullDownController *pullDownController;

@end


#pragma mark - KSPullDownController

@protocol KSPullDownControllerDelegate;

@interface KSPullDownController : UIViewController <UIScrollViewDelegate>

@property (nonatomic, weak) id<KSPullDownControllerDelegate> delegate;

@property (nonatomic, assign, readonly) KSPullDownControllerState pullDownControllerState;

@property (nonatomic, strong) UIViewController *pullDownViewController;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, assign) BOOL showScrollIndicator;

// Set the height of the pull down view.
@property (nonatomic, assign) CGFloat pullDownViewHeight;
// Set the height at which the pull down view will release open/closed.
@property (nonatomic, assign) CGFloat pullDownBreakPoint;

// Set a block to be called when the pull down view is opened or closed.
@property (nonatomic, copy) void (^openPullDownViewCompletion)();
@property (nonatomic, copy) void (^closePullDownViewCompletion)();

// Status bar properties are only used in iOS 7 when you the have status bar showing.
@property (nonatomic, assign) KSPullDownStatusBarMode statusBarMode;
@property (nonatomic, strong) UIColor *statusBarColor;

// Call when changing app-wide status bar (hiding/showing).
- (void)updateStatusBarFrame;

// Call to set the pull down controller state.
- (void)setPullDownControllerState:(KSPullDownControllerState)pullDownControllerState withAnimatedDuration:(CGFloat)duration;

@end


/////////////////////////////////

#pragma mark - KSPullDownControllerDelegate

@protocol KSPullDownControllerDelegate <NSObject>

@optional

// Returns the ratio of pull down view that is shown.
- (void) pullDownViewControllerOpenRatio:(CGFloat)openRatio;

@end
