//
//  KSSlideController.h
//  KSFramework
//
//  This file is part of a fork of MFSideSideView by Michael Frederick.
//
//  Modified by Travis Zehren beginning 9/07/13.
//  Copyright (c) 2013 Kickstand Apps. All rights reserved.
//
//  This file incorporates work covered by the following copyright and
//  permission notice:
//
//    MFSideMenuContainerViewController.m
//    MFSideMenuDemoSplitViewController
//
//    Created by Michael Frederick on 4/2/13.
//    Copyright (c) 2013 Frederick Development. All rights reserved.
//

#import "KSSlideController.h"
#import "KSImageAdditions.h"
#import "KSInactiveImageView.h"

NSString * const KSSlideControllerStateNotificationEvent = @"KSSlideControllerStateNotificationEvent";

typedef enum {
    KSSlideControllerPanDirectionNone,
    KSSlideControllerPanDirectionLeft,
    KSSlideControllerPanDirectionRight
} KSSlideControllerPanDirection;


@interface KSSlideController ()

@property (nonatomic, assign) CGFloat iOSVersion;

@property (nonatomic, strong) UIView *centerContainer;
@property (nonatomic, strong) UIView *leftContainer;
@property (nonatomic, strong) UIView *rightContainer;

@property (nonatomic, strong) UIView *statusBarBackgroundView;

@property (nonatomic, strong) KSInactiveImageView *centerOverlay;
@property (nonatomic, strong) KSInactiveImageView *leftOverlay;
@property (nonatomic, strong) KSInactiveImageView *rightOverlay;

@property (nonatomic, assign) CGPoint panGestureOrigin;
@property (nonatomic, assign) CGFloat panGestureVelocity;
@property (nonatomic, assign) KSSlideControllerPanDirection panDirection;

@property (nonatomic, assign) BOOL viewHasLoaded;
@property (nonatomic, assign) BOOL viewHasAppeared;

@end


#pragma mark - UIViewController + KSSlideController
#pragma mark -

@implementation UIViewController (KSSlideController)

@dynamic slideController;

- (KSSlideController *)slideController
{
    id containerView = self;
    while (![containerView isKindOfClass:[KSSlideController class]] && containerView) {
        if ([containerView respondsToSelector:@selector(parentViewController)]) {
            containerView = [containerView parentViewController];
        }
        
        if ([containerView respondsToSelector:@selector(splitViewController)] && !containerView) {
            containerView = [containerView splitViewController];
        }
    }
    
    return containerView;
}

@end


#pragma mark - KSSlideController
#pragma mark -

@implementation KSSlideController

@synthesize iOSVersion = _iOSVersion;
@synthesize viewHasLoaded;
@synthesize viewHasAppeared;
@synthesize leftViewController = _leftViewController;
@synthesize centerViewController = _centerViewController;
@synthesize rightViewController = _rightViewController;
@synthesize centerContainer = _centerContainer;
@synthesize leftContainer = _leftContainer;
@synthesize rightContainer = _rightContainer;
@synthesize centerOverlay;
@synthesize leftOverlay;
@synthesize rightOverlay;
@synthesize panMode;
@synthesize panGestureOrigin;
@synthesize panGestureVelocity;
@synthesize slideControllerState = _slideControllerState;
@synthesize panDirection;
@synthesize leftViewWidth = _leftViewWidth;
@synthesize rightViewWidth = _rightViewWidth;
@synthesize sideViewsInFront = _sideViewsInFront;
@synthesize slideParallaxFactor = _slideParallaxFactor;
@synthesize slideScaleFactor = _slideScaleFactor;
@synthesize slideTintColor = _slideTintColor;
@synthesize slideTintOpacity = _slideTintOpacity;
@synthesize sideViewBlurFactor = _sideViewBlurFactor;
@synthesize centerViewBlurFactor = _centerViewBlurFactor;
@synthesize centerViewShadow;
@synthesize leftViewShadow;
@synthesize rightViewShadow;
@synthesize statusBarBackgroundView = _statusBarBackgroundView;
@synthesize centerViewStatusBarColor = _centerViewStatusBarColor;
@synthesize sideViewStatusBarColor = _sideViewStatusBarColor;


#pragma mark - Initialization

+ (KSSlideController *)slideControllerWithCenterViewController:(id)centerViewController
                                            leftViewController:(id)leftViewController
                                           rightViewController:(id)rightViewController {
    KSSlideController *controller = [[KSSlideController alloc] init];
    controller.leftViewController = leftViewController;
    controller.centerViewController = centerViewController;
    controller.rightViewController = rightViewController;
    return controller;
}

- (id) init {
    self = [super init];
    if(self) {
        [self setDefaultSettings];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)inCoder {
    id coder = [super initWithCoder:inCoder];
    [self setDefaultSettings];
    return coder;
}

- (void)setDefaultSettings {
    self.sideViewSlideScaleFactor = 1.0;
    self.sideViewSlideParallaxFactor = 0.0;
    self.slideControllerState = KSSlideControllerStateClosed;
    self.sideViewWidth = 270.0f;
    self.slideAnimationDuration = 0.4f;
    self.panMode = KSSlideControllerPanModeDefault;
}

- (CGFloat)iOSVersion
{
    if (!_iOSVersion) {
        _iOSVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    }
    return _iOSVersion;
}

- (UIView *)centerContainer {
    if (!_centerContainer) {
        CGRect centerFrame = self.view.bounds;
        if (self.iOSVersion >= 7 && self.statusBarMode == KSSlideStatusBarModeOffset) {
            centerFrame.origin.y = self.statusBarBackgroundView.bounds.size.height;
            centerFrame.size.height -= self.statusBarBackgroundView.bounds.size.height;
        }
        
        _centerContainer = [[UIView alloc] initWithFrame:centerFrame];
        
        _centerContainer.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _centerContainer.backgroundColor = [UIColor clearColor];
        
        if (![self.centerViewController view].superview) {
            [self.centerViewController view].frame = _centerContainer.bounds;
            [_centerContainer addSubview:[self.centerViewController view]];
        }
        
        self.centerOverlay = [[KSInactiveImageView alloc] initWithFrame:_centerContainer.bounds];
        self.centerOverlay.hidden = YES;
        self.centerOverlay.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_centerContainer addSubview:self.centerOverlay];
        
        self.centerViewShadow = [KSViewShadow shadowWithView:_centerContainer];
        [self.centerViewShadow refresh];
    }
    
    return _centerContainer;
}

- (UIView *)leftContainer {
    if (!_leftContainer) {
        CGRect leftFrame = CGRectMake(-self.leftViewWidth, 0, self.leftViewWidth, self.view.bounds.size.height);
        if (self.iOSVersion >= 7 && self.statusBarMode == KSSlideStatusBarModeOffset) {
            leftFrame.origin.y = self.statusBarBackgroundView.bounds.size.height;
            leftFrame.size.height -= self.statusBarBackgroundView.bounds.size.height;
        }
        
        _leftContainer = [[UIView alloc] initWithFrame:leftFrame];

        _leftContainer.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _leftContainer.backgroundColor = [UIColor clearColor];
        _leftContainer.hidden = YES;

        if (!self.leftViewController.view.superview) {
            self.leftViewController.view.frame = _leftContainer.bounds;
            [_leftContainer addSubview:self.leftViewController.view];
        }

        self.leftOverlay = [[KSInactiveImageView alloc] initWithFrame:_leftContainer.bounds];
        self.leftOverlay.hidden = YES;
        self.leftOverlay.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_leftContainer addSubview:self.leftOverlay];

        self.leftViewShadow = [KSViewShadow shadowWithView:_leftContainer];
        [self.leftViewShadow refresh];
    }
    
    return _leftContainer;
}

- (UIView *)rightContainer {
    if (!_rightContainer) {
        CGRect rightFrame = CGRectMake(self.view.bounds.size.width, 0, self.rightViewWidth, self.view.bounds.size.height);
        if (self.iOSVersion >= 7 && self.statusBarMode == KSSlideStatusBarModeOffset) {
            rightFrame.origin.y = self.statusBarBackgroundView.bounds.size.height;
            rightFrame.size.height -= self.statusBarBackgroundView.bounds.size.height;
        }
        
        _rightContainer = [[UIView alloc] initWithFrame:rightFrame];
        
        _rightContainer.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _rightContainer.backgroundColor = [UIColor clearColor];
        _rightContainer.hidden = YES;
        
        if (!self.rightViewController.view.superview) {
            self.rightViewController.view.frame = _rightContainer.bounds;
            [_rightContainer addSubview:self.rightViewController.view];
        }
        
        self.rightOverlay = [[KSInactiveImageView alloc] initWithFrame:_rightContainer.bounds];
        self.rightOverlay.hidden = YES;
        self.rightOverlay.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_rightContainer addSubview:self.rightOverlay];
        
        self.rightViewShadow = [KSViewShadow shadowWithView:_rightContainer];
        [self.rightViewShadow refresh];
    }
    
    return _rightContainer;
}

- (UIView *)statusBarBackgroundView {
    if (!_statusBarBackgroundView) {
        CGFloat barHeight = 0;
        if (self.iOSVersion >= 7 && ![UIApplication sharedApplication].statusBarHidden) {
            barHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
        }
        _statusBarBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width,barHeight)];
        _statusBarBackgroundView.backgroundColor = self.centerViewStatusBarColor;
    }
    return _statusBarBackgroundView;
}

- (UIColor *)centerViewStatusBarColor {
    if (!_centerViewStatusBarColor) {
        _centerViewStatusBarColor = [UIColor clearColor];
    }
    return _centerViewStatusBarColor;
}

- (UIColor *)sideViewStatusBarColor {
    if (!_sideViewStatusBarColor) {
        _sideViewStatusBarColor = [UIColor clearColor];
    }
    return _sideViewStatusBarColor;
}


#pragma mark -
#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.viewHasLoaded) {
        [self.view addSubview:self.leftContainer];
        [self.view addSubview:self.rightContainer];
        [self.view addSubview:self.centerContainer];
        [self.view addSubview:self.statusBarBackgroundView];
        
        self.viewHasLoaded = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if(!self.viewHasAppeared) {
        [self setLeftViewFrameToClosedPosition];
        [self setRightViewFrameToClosedPosition];
        [self addGestureRecognizers];
        [self.centerViewShadow refresh];
        [self.leftViewShadow refresh];
        [self.rightViewShadow refresh];
        
        self.leftOverlay.image = self.leftViewController.view.screenshot;
        self.rightOverlay.image = self.rightViewController.view.screenshot;
        self.centerOverlay.image = [self.centerViewController view].screenshot;
        
        [self setSlideControllerState:KSSlideControllerStateClosed];
        
        self.viewHasAppeared = YES;
    }
}


#pragma mark -
#pragma mark - UIViewController Rotation

-(NSUInteger)supportedInterfaceOrientations {
    if (self.centerViewController) {
        if ([self.centerViewController isKindOfClass:[UINavigationController class]]) {
            return [((UINavigationController *)self.centerViewController).topViewController supportedInterfaceOrientations];
        }
        
        return [self.centerViewController supportedInterfaceOrientations];
    }
    
    return [super supportedInterfaceOrientations];
}

-(BOOL)shouldAutorotate {
    if (self.centerViewController) {
        if ([self.centerViewController isKindOfClass:[UINavigationController class]]) {
            return [((UINavigationController *)self.centerViewController).topViewController shouldAutorotate];
        }
        
        return [self.centerViewController shouldAutorotate];
    }
    
    return YES;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    if (self.centerViewController) {
        if ([self.centerViewController isKindOfClass:[UINavigationController class]]) {
            return [((UINavigationController *)self.centerViewController).topViewController preferredInterfaceOrientationForPresentation];
        }
        
        return [self.centerViewController preferredInterfaceOrientationForPresentation];
    }
    
    return UIInterfaceOrientationPortrait;
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [self.centerViewShadow shadowedViewWillRotate];
    [self.leftViewShadow shadowedViewWillRotate];
    [self.rightViewShadow shadowedViewWillRotate];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    [self.centerViewShadow shadowedViewDidRotate];
    [self.leftViewShadow shadowedViewDidRotate];
    [self.rightViewShadow shadowedViewDidRotate];
}


#pragma mark -
#pragma mark - UIViewController Containment

- (void)setLeftViewController:(UIViewController *)leftViewController {
    [self removeChildViewControllerFromContainer:_leftViewController];
    
    _leftViewController = leftViewController;
    
    if(!_leftViewController) {
        return;
    }
    
    [self addChildViewController:_leftViewController];
    if (self.viewHasLoaded) {
        _leftViewController.view.frame = self.leftContainer.bounds;
        [self.leftContainer addSubview:_leftViewController.view];
    }
    
    [_leftViewController didMoveToParentViewController:self];
    
    if(self.viewHasAppeared) {
        [self setLeftViewFrameToClosedPosition];
    }
}

- (void)setCenterViewController:(UIViewController *)centerViewController {
    [self removeChildViewControllerFromContainer:_centerViewController];
    
    _centerViewController = centerViewController;
    
    if(!_centerViewController) {
        return;
    }
    
    [self addChildViewController:_centerViewController];
    if (self.viewHasLoaded) {
        [((UIViewController *)_centerViewController) view].frame = self.centerContainer.bounds;
        [self.centerContainer addSubview:[_centerViewController view]];
    }
    
    [_centerViewController didMoveToParentViewController:self];
}

- (void)setRightViewController:(UIViewController *)rightViewController {
    [self removeChildViewControllerFromContainer:_rightViewController];
    
    _rightViewController = rightViewController;
    
    if(!_rightViewController) {
        return;
    }
    
    [self addChildViewController:_rightViewController];
    if (self.viewHasLoaded) {
        _rightViewController.view.frame = self.rightContainer.bounds;
        [self.rightContainer addSubview:_rightViewController.view];
    }
    
    [_rightViewController didMoveToParentViewController:self];
    
    if(self.viewHasAppeared) {
        [self setRightViewFrameToClosedPosition];
    }
}

- (void)removeChildViewControllerFromContainer:(UIViewController *)childViewController {
    if(!childViewController) return;
    [childViewController willMoveToParentViewController:nil];
    [childViewController removeFromParentViewController];
    [childViewController.view removeFromSuperview];
}


#pragma mark -
#pragma mark - UIGestureRecognizer Helpers

- (UIPanGestureRecognizer *)panGestureRecognizer {
    UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handlePan:)];
	[recognizer setMaximumNumberOfTouches:1];
    [recognizer setDelegate:self];
    return recognizer;
}

- (void)addGestureRecognizers {
    [self.centerContainer addGestureRecognizer:[self centerTapGestureRecognizer]];
    [self.centerContainer addGestureRecognizer:[self panGestureRecognizer]];
    [self.leftContainer addGestureRecognizer:[self panGestureRecognizer]];
    [self.rightContainer addGestureRecognizer:[self panGestureRecognizer]];
}

- (UITapGestureRecognizer *)centerTapGestureRecognizer {
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]
                                             initWithTarget:self
                                             action:@selector(centerViewControllerTapped:)];
    [tapRecognizer setDelegate:self];
    return tapRecognizer;
}


#pragma mark -
#pragma mark - Slide Controller State

- (void)toggleLeftViewWithCompletion:(void (^)(void))completion {
    if(self.slideControllerState == KSSlideControllerStateLeftViewOpen) {
        [self setSlideControllerState:KSSlideControllerStateClosed completion:completion];
    }
    else {
        [self setSlideControllerState:KSSlideControllerStateLeftViewOpen completion:completion];
    }
}

- (void)toggleRightViewWithCompletion:(void (^)(void))completion {
    if(self.slideControllerState == KSSlideControllerStateRightViewOpen) {
        [self setSlideControllerState:KSSlideControllerStateClosed completion:completion];
    }
    else {
        [self setSlideControllerState:KSSlideControllerStateRightViewOpen completion:completion];
    }
}

- (void)openLeftViewWithCompletion:(void (^)(void))completion {
    if(self.leftViewController) {
        if (!self.sideViewsInFront && self.centerContainer.frame.origin.x == 0) {
            self.leftOverlay.scale = self.slideScaleFactor;
        }
        [self setControllerOffset:self.leftViewWidth animated:YES completion:completion];
    }
}

- (void)openRightViewWithCompletion:(void (^)(void))completion {
    if(self.rightViewController) {
        if (!self.sideViewsInFront && self.centerContainer.frame.origin.x == 0) {
            self.rightOverlay.scale = self.slideScaleFactor;
        }
        [self setControllerOffset:-self.rightViewWidth animated:YES completion:completion];
    }
}

- (void)closeSideViewWithCompletion:(void (^)(void))completion {
    [self setControllerOffset:0 animated:YES completion:completion];
}

- (void)setSlideControllerState:(KSSlideControllerState)slideControllerState {
    [self setSlideControllerState:slideControllerState completion:nil];
}

- (void)setSlideControllerState:(KSSlideControllerState)state completion:(void (^)(void))completion {
    if (!self.viewHasLoaded) {
        _slideControllerState = state;
        return;
    }
    
    void (^innerCompletion)() = ^{
        _slideControllerState = state;
        
        [self setUserInteractionStateForCenterViewController];
        KSSlideControllerStateEvent eventType = (_slideControllerState == KSSlideControllerStateClosed) ? KSSlideControllerStateEventSideViewDidClose : KSSlideControllerStateEventSideViewDidOpen;
        [self sendStateEventNotification:eventType];
        
        if(completion) {
            completion();
        }
    };
    
    switch (state) {
        case KSSlideControllerStateClosed: {
            [self sendStateEventNotification:KSSlideControllerStateEventSideViewWillClose];
            [self closeSideViewWithCompletion:^{
                self.centerOverlay.image = nil;
                self.centerOverlay.hidden = YES;
                [self.centerViewController view].hidden = NO;
                
                self.leftContainer.hidden = YES;
                self.leftOverlay.image = nil;
                self.leftOverlay.hidden = YES;
                self.leftViewController.view.hidden = NO;
                
                self.rightContainer.hidden = YES;
                self.rightOverlay.image = nil;
                self.rightOverlay.hidden = YES;
                self.rightViewController.view.hidden = NO;
                
                innerCompletion();
            }];
            break;
        }
        case KSSlideControllerStateLeftViewOpen: {
            if(self.leftViewController) {
                [self sendStateEventNotification:KSSlideControllerStateEventSideViewWillOpen];
                [self leftViewWillShow];
                [self openLeftViewWithCompletion:^{
                    self.leftOverlay.image = nil;
                    self.leftOverlay.hidden = YES;
                    self.leftViewController.view.hidden = NO;
                    self.leftViewShadow.shadowedView = self.leftContainer;
                    [self.leftViewShadow refresh];
                    innerCompletion();
                }];
            }
            break;
        }
        case KSSlideControllerStateRightViewOpen: {
            if(self.rightViewController) {
                [self sendStateEventNotification:KSSlideControllerStateEventSideViewWillOpen];
                [self rightViewWillShow];
                [self openRightViewWithCompletion:^{
                    self.rightOverlay.image = nil;
                    self.rightOverlay.hidden = YES;
                    self.rightViewController.view.hidden = NO;
                    self.rightViewShadow.shadowedView = self.rightContainer;
                    [self.rightViewShadow refresh];
                    innerCompletion();
                }];
            }
            break;
        }
        default:
            break;
    }
}

// these callbacks are called when the side view will become visible, not neccessarily when they will OPEN
- (void)leftViewWillShow {
    self.leftContainer.hidden = NO;
}

- (void)rightViewWillShow {
    self.rightContainer.hidden = NO;
}


#pragma mark -
#pragma mark - State Event Notification

- (void)sendStateEventNotification:(KSSlideControllerStateEvent)event {
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:event] forKey:@"eventType"];
    [[NSNotificationCenter defaultCenter] postNotificationName:KSSlideControllerStateNotificationEvent object:self userInfo:userInfo];
}


#pragma mark -
#pragma mark - View Controller Movements

// Set offset from negative self.rightViewWidth to positive self.leftViewWidth
// An offset of 0 is closed

- (void)setControllerOffset:(CGFloat)offset animated:(BOOL)animated completion:(void (^)(void))completion {
    [self setControllerOffset:offset additionalAnimations:nil animated:animated completion:completion];
}

- (void)setControllerOffset:(CGFloat)offset
       additionalAnimations:(void (^)(void))additionalAnimations
                   animated:(BOOL)animated
                 completion:(void (^)(void))completion {
    void (^innerCompletion)() = ^ {
        self.panGestureVelocity = 0.0;
        if(completion) {
            completion();
        }
    };
    
    if(animated) {
        CGFloat centerViewControllerXPosition = CGRectGetMinX(self.centerContainer.frame)/(self.sideViewsInFront ? self.slideParallaxFactor : 1);
        
        CGFloat duration = [self animationDurationFromStartPosition:centerViewControllerXPosition toEndPosition:offset];
                
        [UIView animateWithDuration:duration animations:^{
            CGFloat leftAlpha = self.leftViewShadow.alpha;
            CGFloat rightAlpha = self.rightViewShadow.alpha;
            
            [self setControllerOffset:offset];
            
            if (self.leftViewShadow.alpha != leftAlpha && leftAlpha > 0) {
                self.leftViewShadow.alpha = leftAlpha;
            }
            
            if (self.rightViewShadow.alpha != rightAlpha && rightAlpha > 0) {
                self.rightViewShadow.alpha = rightAlpha;
            }
            
            if(additionalAnimations) additionalAnimations();
        } completion:^(BOOL finished) {
            [self setControllerOffset:offset];
            innerCompletion();
        }];
    }
    else {
        [self setControllerOffset:offset];
        if(additionalAnimations) {
            additionalAnimations();
        }
        innerCompletion();
    }
}

- (void)setControllerOffset:(CGFloat)offset {
    CGRect statusRect = self.statusBarBackgroundView.frame;
    if (self.iOSVersion >= 7 && ![UIApplication sharedApplication].statusBarHidden) {
        statusRect.size.height = [UIApplication sharedApplication].statusBarFrame.size.height;
    }
    else {
        statusRect.size.height = 0;
    }
    self.statusBarBackgroundView.frame = statusRect;
    
    CGFloat statusBarOffset = 0;
    if (self.iOSVersion >= 7 && self.statusBarMode == KSSlideStatusBarModeOffset) {
        statusBarOffset = self.statusBarBackgroundView.bounds.size.height;
    }
    
    CGRect leftFrame = self.leftContainer.frame;
    CGRect centerFrame = self.centerContainer.frame;
    CGRect rightFrame = self.rightContainer.frame;
    
    leftFrame.origin.y = statusBarOffset;
    centerFrame.origin.y = statusBarOffset;
    rightFrame.origin.y = statusBarOffset;
    leftFrame.size.height = self.view.bounds.size.height - statusBarOffset;
    centerFrame.size.height = self.view.bounds.size.height - statusBarOffset;
    rightFrame.size.height = self.view.bounds.size.height - statusBarOffset;
        
    leftFrame.origin.x = MIN(0, MAX(-self.leftViewWidth, offset - self.leftViewWidth)) * (self.sideViewsInFront ? 1 : self.slideParallaxFactor);
    centerFrame.origin.x = offset * (self.sideViewsInFront ? self.slideParallaxFactor : 1);
    rightFrame.origin.x = centerFrame.size.width - self.rightViewWidth * (1 - (self.sideViewsInFront ? 1 : self.slideParallaxFactor)) + offset * (self.sideViewsInFront ? 1 : self.slideParallaxFactor);
    
    self.leftContainer.frame = leftFrame;
    self.centerContainer.frame = centerFrame;
    self.rightContainer.frame = rightFrame;
    
    self.leftViewShadow.alpha = MAX(0, MIN(1, offset/20));
    self.rightViewShadow.alpha = MAX(0, MIN(1, -offset/20));
    
    
    // handle inactive views
    if (offset != 0 && self.centerOverlay.hidden == YES && (self.slideTintOpacity || self.centerViewBlurFactor || (self.sideViewsInFront && self.slideScaleFactor != 1))) {
        if (self.centerViewBlurFactor || (self.sideViewsInFront && self.slideScaleFactor != 1))
        {
            self.centerOverlay.image = [self.centerViewController view].screenshot;
            [self.centerViewController view].hidden = YES;
        }
        self.centerOverlay.hidden = NO;
    }
    
    if (self.leftOverlay.hidden == YES && (self.sideViewBlurFactor || (!self.sideViewsInFront && self.slideScaleFactor != 1))) {
        self.leftOverlay.image = self.leftViewController.view.screenshot;
        self.leftOverlay.hidden = NO;
        self.leftViewController.view.hidden = YES;
    }

    if (self.rightOverlay.hidden == YES && (self.sideViewBlurFactor || (!self.sideViewsInFront && self.slideScaleFactor != 1))) {
        self.rightOverlay.image = self.rightViewController.view.screenshot;
        self.rightOverlay.hidden = NO;
        self.rightViewController.view.hidden = YES;
    }

    
    CGFloat slideRatio = offset == 0 ? 0 : MAX(offset/self.leftViewWidth, -offset/self.rightViewWidth);
    
    if ((offset < 0 && self.slideParallaxFactor > 0.5) || (offset > 0 && self.slideParallaxFactor < 0.5)) {
        self.centerOverlay.edgeHold = KSScaleEdgeHoldRight;
    }
    else {
        self.centerOverlay.edgeHold = KSScaleEdgeHoldLeft;
    }
    
    if (self.slideParallaxFactor < 0.5) {
        self.leftOverlay.edgeHold = KSScaleEdgeHoldLeft;
        self.rightOverlay.edgeHold = KSScaleEdgeHoldRight;
    }
    else {
        self.leftOverlay.edgeHold = KSScaleEdgeHoldRight;
        self.rightOverlay.edgeHold = KSScaleEdgeHoldLeft;
    }
    
    if (self.sideViewsInFront) {
        self.centerOverlay.scale = 1 - (slideRatio * (1 - self.slideScaleFactor));
        self.leftOverlay.scale = 1;
        self.rightOverlay.scale = 1;
    }
    else {
        self.centerOverlay.scale = 1;
        self.leftOverlay.scale = 1 - (1 - slideRatio) * (1 - self.slideScaleFactor);
        self.rightOverlay.scale = 1 - (1 - slideRatio) * (1 - self.slideScaleFactor);
    }
    
    if (self.statusBarBackgroundView.bounds.size.height) {
        CGFloat centerRed = 0.0, centerGreen = 0.0, centerBlue = 0.0, centerAlpha = 1.0;
        BOOL centerColor = [self.centerViewStatusBarColor getRed:&centerRed green:&centerGreen blue:&centerBlue alpha:&centerAlpha];
        if (!centerColor) {
            CGFloat white = 0.0;
            [self.centerViewStatusBarColor getWhite:&white alpha:&centerAlpha];
            centerRed = white;
            centerGreen = white;
            centerBlue = white;
        }
        
        CGFloat sideRed = 0.0, sideGreen = 0.0, sideBlue = 0.0, sideAlpha = 1.0;
        BOOL sideColor = [self.sideViewStatusBarColor getRed:&sideRed green:&sideGreen blue:&sideBlue alpha:&sideAlpha];
        if (!sideColor) {
            CGFloat white = 0.0;
            [self.sideViewStatusBarColor getWhite:&white alpha:&sideAlpha];
            sideRed = white;
            sideGreen = white;
            sideBlue = white;
        }
        if (!centerRed && !centerGreen && !centerBlue && !centerAlpha) {
            centerRed = sideRed;
            centerGreen = sideGreen;
            centerBlue = sideBlue;
        }
        
        CGFloat redValue = centerRed + (sideRed - centerRed) * slideRatio;
        CGFloat greenValue = centerGreen + (sideGreen - centerGreen) * slideRatio;
        CGFloat blueValue = centerBlue + (sideBlue - centerBlue) * slideRatio;
        CGFloat alphaValue = centerAlpha + (sideAlpha - centerAlpha) * slideRatio;
        
        self.statusBarBackgroundView.backgroundColor = [UIColor colorWithRed:redValue green:greenValue blue:blueValue alpha:alphaValue];
    }
    
    self.centerOverlay.tintOpacity = slideRatio * self.slideTintOpacity;
    self.centerOverlay.blurIntensity = 1 - pow(slideRatio - 1,2);
    self.leftOverlay.blurIntensity = 1 - (pow(slideRatio,2));
    self.rightOverlay.blurIntensity = 1 - (pow(slideRatio,2));
}

- (CGFloat)animationDurationFromStartPosition:(CGFloat)startPosition toEndPosition:(CGFloat)endPosition {
    CGFloat animationPositionDelta = ABS(endPosition - startPosition);
    
    CGFloat duration;
    if(ABS(self.panGestureVelocity) > 1.0) {
        // try to continue the animation at the speed the user was swiping
        duration = animationPositionDelta / ABS(self.panGestureVelocity);
    }
    else {
        // no swipe was used, user tapped the bar button item
        CGFloat sideViewWidth = MAX(_leftViewWidth, _rightViewWidth);
        CGFloat animationPerecent = (animationPositionDelta == 0) ? 0 : sideViewWidth / animationPositionDelta;
        duration = self.slideAnimationDuration * animationPerecent;
    }
    
    return MIN(duration, self.slideAnimationDuration);
}

- (void) setLeftViewFrameToClosedPosition {
    if(!self.leftViewController) return;
    CGRect leftFrame = self.leftContainer.frame;
    leftFrame.size.width = self.leftViewWidth;
    leftFrame.size.height = self.view.bounds.size.height;
    leftFrame.origin.x = -self.leftViewWidth * (self.sideViewsInFront ? 1 : self.slideParallaxFactor);
    leftFrame.origin.y = 0;
    self.leftContainer.frame = leftFrame;
    self.leftContainer.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleHeight;
}

- (void) setRightViewFrameToClosedPosition {
    if(!self.rightViewController) return;
    CGRect rightFrame = self.rightContainer.frame;
    rightFrame.size.width = self.rightViewWidth;
    rightFrame.size.height = self.view.bounds.size.height;
    rightFrame.origin.y = 0;
    rightFrame.origin.x = self.view.bounds.size.width - self.rightViewWidth * (1 - (self.sideViewsInFront ? 1 : self.slideParallaxFactor));
    self.rightContainer.frame = rightFrame;
    self.rightContainer.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleHeight;
}


#pragma mark -
#pragma mark - Side View Width

- (void)setSideViewWidth:(CGFloat)sideViewWidth {
    [self setSideViewWidth:sideViewWidth animated:YES];
}

- (void)setLeftViewWidth:(CGFloat)leftViewWidth {
    [self setLeftViewWidth:leftViewWidth animated:YES];
}

- (void)setRightViewWidth:(CGFloat)rightViewWidth {
    [self setRightViewWidth:rightViewWidth animated:YES];
}

- (void)setSideViewWidth:(CGFloat)sideViewWidth animated:(BOOL)animated {
    [self setLeftViewWidth:sideViewWidth animated:animated];
    [self setRightViewWidth:sideViewWidth animated:animated];
}

- (void)setLeftViewWidth:(CGFloat)leftViewWidth animated:(BOOL)animated {
    _leftViewWidth = leftViewWidth;
    
    if (!self.viewHasLoaded) {
        return;
    }
    
    if(self.slideControllerState != KSSlideControllerStateLeftViewOpen) {
        [self setLeftViewFrameToClosedPosition];
        return;
    }
    
    CGRect sideViewRect = self.leftContainer.frame;
    sideViewRect.size.width = _leftViewWidth;
    self.leftContainer.frame = sideViewRect;
    
    [self setControllerOffset:_leftViewWidth animated:animated completion:nil];
}

- (void)setRightViewWidth:(CGFloat)rightViewWidth animated:(BOOL)animated {
    _rightViewWidth = rightViewWidth;
    
    if (!self.viewHasLoaded) {
        return;
    }
    
    if(self.slideControllerState != KSSlideControllerStateRightViewOpen) {
        [self setRightViewFrameToClosedPosition];
        return;
    }
    
    CGRect sideViewRect = self.rightContainer.frame;
    sideViewRect.origin.x = self.view.bounds.size.width - _rightViewWidth;
    sideViewRect.size.width = _rightViewWidth;
    self.rightContainer.frame = sideViewRect;
    
    [self setControllerOffset:-_rightViewWidth animated:animated completion:nil];
}


#pragma mark -
#pragma mark - Side View Sliding Options

- (void)setSideViewsInFront:(BOOL)sideViewsOnTop
{
    _sideViewsInFront = sideViewsOnTop;
    
    if (_sideViewsInFront) {
        [self.view sendSubviewToBack:self.centerContainer];
    }
    else {
        [self.view bringSubviewToFront:self.centerContainer];
        [self.view bringSubviewToFront:self.statusBarBackgroundView];
    }
    
    [self setSlideControllerState:self.slideControllerState];
}

- (void)setSideViewSlideParallaxFactor:(CGFloat)sideViewSlideParallaxFactor {
    _slideParallaxFactor = MAX(0, MIN(1, sideViewSlideParallaxFactor));
}

- (void)setSideViewSlideScaleFactor:(CGFloat)sideViewSlideScaleFactor {
    _slideScaleFactor = MAX(0, MIN(1, sideViewSlideScaleFactor));
}

- (void)setSlideTintColor:(UIColor *)slideTintColor {
    _slideTintColor = slideTintColor;
    self.centerOverlay.tintColor = slideTintColor;
}

- (void)setSideViewSlideTintOpacity:(CGFloat)sideViewSlideTintOpacity {
    _slideTintOpacity = MAX(0, MIN(1, sideViewSlideTintOpacity));
}

- (void)setSideViewBlurFactor:(CGFloat)sideViewBlurFactor {
    _sideViewBlurFactor = MAX(0, MIN(1, sideViewBlurFactor));
    
    self.leftOverlay.blurSize = _sideViewBlurFactor;
    self.rightOverlay.blurSize = _sideViewBlurFactor;
}

- (void)setCenterViewBlurFactor:(CGFloat)centerViewBlurFactor {
    _centerViewBlurFactor = MAX(0, MIN(1, centerViewBlurFactor));
    
    self.centerOverlay.blurSize = _centerViewBlurFactor;
}


#pragma mark -
#pragma mark - KSSlideControllerPanMode

- (BOOL) centerViewControllerPanEnabled {
    return ((self.panMode & KSSlideControllerPanModeCenterView) == KSSlideControllerPanModeCenterView);
}

- (BOOL) sidesideViewPanEnabled {
    return ((self.panMode & KSSlideControllerPanModeSideView) == KSSlideControllerPanModeSideView);
}


#pragma mark -
#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]] &&
       self.slideControllerState != KSSlideControllerStateClosed) {
        return YES;
    }
    
    if([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        if([gestureRecognizer.view isEqual:self.centerContainer]) {
            return [self centerViewControllerPanEnabled];
        }
        
        if([gestureRecognizer.view isEqual:self.leftContainer] || [gestureRecognizer.view isEqual:self.rightContainer]) {
            return [self sidesideViewPanEnabled];
        }
        
        // pan gesture is attached to a custom view
        return YES;
    }
    
    return NO;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
	return NO;
}


#pragma mark -
#pragma mark - UIGestureRecognizer Callbacks

// this method handles any pan event
// and sets the navigation controller's frame as needed
- (void) handlePan:(UIPanGestureRecognizer *)recognizer {
    UIView *view = [self.centerViewController view];
    
	if(recognizer.state == UIGestureRecognizerStateBegan) {
        // remember where the pan started
        panGestureOrigin = view.frame.origin;
        self.panDirection = KSSlideControllerPanDirectionNone;
	}
    
    if(self.panDirection == KSSlideControllerPanDirectionNone) {
        CGPoint translatedPoint = [recognizer translationInView:view];
        if(translatedPoint.x > 0) {
            self.panDirection = KSSlideControllerPanDirectionRight;
            if(self.leftViewController && self.slideControllerState == KSSlideControllerStateClosed) {
                [self leftViewWillShow];
            }
        }
        else if(translatedPoint.x < 0) {
            self.panDirection = KSSlideControllerPanDirectionLeft;
            if(self.rightViewController && self.slideControllerState == KSSlideControllerStateClosed) {
                [self rightViewWillShow];
            }
        }
    }
    
    if((self.slideControllerState == KSSlideControllerStateRightViewOpen && self.panDirection == KSSlideControllerPanDirectionLeft)
       || (self.slideControllerState == KSSlideControllerStateLeftViewOpen && self.panDirection == KSSlideControllerPanDirectionRight)) {
        self.panDirection = KSSlideControllerPanDirectionNone;
        return;
    }
    
    if(self.panDirection == KSSlideControllerPanDirectionLeft) {
        [self handleLeftPan:recognizer];
    }
    else if(self.panDirection == KSSlideControllerPanDirectionRight) {
        [self handleRightPan:recognizer];
    }
    
    if (self.panDirection == KSSlideControllerPanDirectionNone && recognizer.state == UIGestureRecognizerStateEnded) {
        [self setSlideControllerState:KSSlideControllerStateClosed];
    }
}

- (void) handleRightPan:(UIPanGestureRecognizer *)recognizer {
    if(!self.leftViewController && self.slideControllerState == KSSlideControllerStateClosed) {
        return;
    }
    
    UIView *view = [self.centerViewController view];
    
    CGPoint translatedPoint = [recognizer translationInView:view];
    CGPoint adjustedOrigin = CGPointZero;
    if (self.slideControllerState == KSSlideControllerStateRightViewOpen) {
        adjustedOrigin.x = -self.rightViewWidth;
    }
    else if (self.slideControllerState == KSSlideControllerStateLeftViewOpen) {
        adjustedOrigin.x = self.leftViewWidth;
    }
    translatedPoint = CGPointMake(adjustedOrigin.x + translatedPoint.x,
                                  adjustedOrigin.y + translatedPoint.y);
    
    translatedPoint.x = MAX(translatedPoint.x, -1*self.rightViewWidth);
    translatedPoint.x = MIN(translatedPoint.x, self.leftViewWidth);
    
    if(self.slideControllerState == KSSlideControllerStateRightViewOpen) {
        // side view is already open, the most the user can do is close it in this gesture
        translatedPoint.x = MIN(translatedPoint.x, 0);
    } else {
        // we are opening the sideView
        translatedPoint.x = MAX(translatedPoint.x, 0);
    }
    
    if(recognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint velocity = [recognizer velocityInView:view];
        CGFloat finalX = translatedPoint.x + (.35*velocity.x);
        CGFloat viewWidth = view.frame.size.width;
        
        if(self.slideControllerState == KSSlideControllerStateClosed) {
            BOOL showsideView = (finalX > viewWidth/2) || (finalX > self.leftViewWidth/2);
            if(showsideView) {
                self.panGestureVelocity = velocity.x;
                [self setSlideControllerState:KSSlideControllerStateLeftViewOpen];
            }
            else {
                self.panGestureVelocity = 0;
                [self setSlideControllerState:KSSlideControllerStateClosed];
            }
        }
        else {
            BOOL hidesideView = (finalX > adjustedOrigin.x);
            if(hidesideView) {
                self.panGestureVelocity = velocity.x;
                [self setSlideControllerState:KSSlideControllerStateClosed];
            }
            else {
                self.panGestureVelocity = 0;
                [self setSlideControllerState:KSSlideControllerStateRightViewOpen];
            }
        }
    }
    else {
        [self setControllerOffset:translatedPoint.x];
    }
    
    if (translatedPoint.x == 0) {
        self.leftContainer.hidden = YES;
        self.rightContainer.hidden = YES;
        self.panDirection = KSSlideControllerPanDirectionNone;
    }
}

- (void) handleLeftPan:(UIPanGestureRecognizer *)recognizer {
    if(!self.rightViewController && self.slideControllerState == KSSlideControllerStateClosed) {
        return;
    }
    
    UIView *view = [self.centerViewController view];
    
    CGPoint translatedPoint = [recognizer translationInView:view];
    CGPoint adjustedOrigin = panGestureOrigin;
    if (self.slideControllerState == KSSlideControllerStateRightViewOpen) {
        adjustedOrigin.x = -self.rightViewWidth;
    }
    else if (self.slideControllerState == KSSlideControllerStateLeftViewOpen) {
        adjustedOrigin.x = self.leftViewWidth;
    }
    translatedPoint = CGPointMake(adjustedOrigin.x + translatedPoint.x,
                                  adjustedOrigin.y + translatedPoint.y);
    
    translatedPoint.x = MAX(translatedPoint.x, -1*self.rightViewWidth);
    translatedPoint.x = MIN(translatedPoint.x, self.leftViewWidth);
    if(self.slideControllerState == KSSlideControllerStateLeftViewOpen) {
        // don't let the pan go less than 0 if the side view is already open
        translatedPoint.x = MAX(translatedPoint.x, 0);
    }
    else {
        // we are opening the sideView
        translatedPoint.x = MIN(translatedPoint.x, 0);
    }

	if(recognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint velocity = [recognizer velocityInView:view];
        CGFloat finalX = translatedPoint.x + (.35*velocity.x);
        CGFloat viewWidth = view.frame.size.width;
        
        if(self.slideControllerState == KSSlideControllerStateClosed) {
            BOOL showsideView = (finalX < -1*viewWidth/2) || (finalX < -1*self.rightViewWidth/2);
            if(showsideView) {
                self.panGestureVelocity = velocity.x;
                [self setSlideControllerState:KSSlideControllerStateRightViewOpen];
            }
            else {
                self.panGestureVelocity = 0;
                [self setSlideControllerState:KSSlideControllerStateClosed];
            }
        }
        else {
            BOOL hidesideView = (finalX < adjustedOrigin.x);
            if(hidesideView) {
                self.panGestureVelocity = velocity.x;
                [self setSlideControllerState:KSSlideControllerStateClosed];
            }
            else {
                self.panGestureVelocity = 0;
                [self setSlideControllerState:KSSlideControllerStateLeftViewOpen];
            }
        }
	}
    else {
        [self setControllerOffset:translatedPoint.x];
    }
    
    if (translatedPoint.x == 0) {
        self.leftContainer.hidden = YES;
        self.rightContainer.hidden = YES;
        self.panDirection = KSSlideControllerPanDirectionNone;
    }
}

- (void)centerViewControllerTapped:(id)sender {
    if(self.slideControllerState != KSSlideControllerStateClosed) {
        [self setSlideControllerState:KSSlideControllerStateClosed];
    }
}

- (void)setUserInteractionStateForCenterViewController {
    // disable user interaction on the current stack of view controllers if the side view is visible
    if([self.centerViewController respondsToSelector:@selector(viewControllers)]) {
        NSArray *viewControllers = [self.centerViewController viewControllers];
        for(UIViewController* viewController in viewControllers) {
            viewController.view.userInteractionEnabled = (self.slideControllerState == KSSlideControllerStateClosed);
        }
    }
}

@end