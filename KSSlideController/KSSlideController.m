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

@property (nonatomic, strong) UIView *centerContainer;
@property (nonatomic, strong) UIView *leftContainer;
@property (nonatomic, strong) UIView *rightContainer;

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
    while (![containerView isKindOfClass:[KSSlideController class]] && containerView)
    {
        if ([containerView respondsToSelector:@selector(parentViewController)])
        {
            containerView = [containerView parentViewController];
        }
        if ([containerView respondsToSelector:@selector(splitViewController)] && !containerView)
        {
            containerView = [containerView splitViewController];
        }
    }
    return containerView;
}

@end


#pragma mark - KSSlideController
#pragma mark -

@implementation KSSlideController

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
@synthesize menuState = _menuState;
@synthesize panDirection;
@synthesize leftMenuWidth = _leftMenuWidth;
@synthesize rightMenuWidth = _rightMenuWidth;
@synthesize showMenuOverContent = _showMenuOverContent;
@synthesize menuSlideParallaxFactor = _menuSlideParallaxFactor;
@synthesize menuSlideScaleFactor = _menuSlideScaleFactor;
@synthesize menuBlurFactor = _menuBlurFactor;
@synthesize contentBlurFactor = _contentBlurFactor;
@synthesize contentShadow;
@synthesize leftMenuShadow;
@synthesize rightMenuShadow;


#pragma mark - Initialization

+ (KSSlideController *)slideControllerWithCenterViewController:(id)centerViewController
                                            leftViewController:(id)leftViewController
                                           rightViewController:(id)rightViewController
{
    KSSlideController *controller = [[KSSlideController alloc] init];
    controller.leftViewController = leftViewController;
    controller.centerViewController = centerViewController;
    controller.rightViewController = rightViewController;
    return controller;
}

- (id) init {
    self = [super init];
    if(self)
    {
        [self setDefaultSettings];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)inCoder
{
    id coder = [super initWithCoder:inCoder];
    [self setDefaultSettings];
    return coder;
}

- (void)setDefaultSettings
{
    self.menuSlideScaleFactor = 1.0;
    self.menuSlideParallaxFactor = 0.0;
    self.menuState = KSSlideControllerStateClosed;
    self.menuWidth = 270.0f;
    self.menuAnimationDefaultDuration = 0.4f;
    self.menuAnimationMaxDuration = 0.4f;
    self.panMode = KSSlideControllerPanModeDefault;
}

- (UIView *)centerContainer
{
    if (!_centerContainer)
    {
        _centerContainer = [[UIView alloc] initWithFrame:self.view.bounds];
        
        _centerContainer.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _centerContainer.backgroundColor = [UIColor clearColor];
        
        if (![self.centerViewController view].superview)
        {
            [self.centerViewController view].frame = _centerContainer.bounds;
            [_centerContainer addSubview:[self.centerViewController view]];
        }
        
        self.centerOverlay = [[KSInactiveImageView alloc] initWithFrame:_centerContainer.bounds];
        self.centerOverlay.hidden = YES;
        self.centerOverlay.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_centerContainer addSubview:self.centerOverlay];
        
        self.contentShadow = [KSViewShadow shadowWithView:_centerContainer];
        [self.contentShadow refresh];
    }
    return _centerContainer;
}

- (UIView *)leftContainer
{
    if (!_leftContainer)
    {
        _leftContainer = [[UIView alloc] initWithFrame:CGRectMake(-self.leftMenuWidth, 0, self.leftMenuWidth, self.view.bounds.size.height)];

        _leftContainer.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _leftContainer.backgroundColor = [UIColor clearColor];
        _leftContainer.hidden = YES;

        if (!self.leftViewController.view.superview)
        {
            self.leftViewController.view.frame = _leftContainer.bounds;
            [_leftContainer addSubview:self.leftViewController.view];
        }

        self.leftOverlay = [[KSInactiveImageView alloc] initWithFrame:_leftContainer.bounds];
        self.leftOverlay.hidden = YES;
        self.leftOverlay.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_leftContainer addSubview:self.leftOverlay];

        self.leftMenuShadow = [KSViewShadow shadowWithView:_leftContainer];
        [self.leftMenuShadow refresh];
    }
    return _leftContainer;
}

- (UIView *)rightContainer
{
    if (!_rightContainer)
    {
        _rightContainer = [[UIView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width, 0, self.rightMenuWidth, self.view.bounds.size.height)];
        
        _rightContainer.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _rightContainer.backgroundColor = [UIColor clearColor];
        _rightContainer.hidden = YES;
        
        if (!self.rightViewController.view.superview)
        {
            self.rightViewController.view.frame = _rightContainer.bounds;
            [_rightContainer addSubview:self.rightViewController.view];
        }
        
        self.rightOverlay = [[KSInactiveImageView alloc] initWithFrame:_rightContainer.bounds];
        self.rightOverlay.hidden = YES;
        self.rightOverlay.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_rightContainer addSubview:self.rightOverlay];
        
        self.rightMenuShadow = [KSViewShadow shadowWithView:_rightContainer];
        [self.rightMenuShadow refresh];
    }
    return _rightContainer;
}


#pragma mark -
#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.viewHasLoaded)
    {
        [self.view addSubview:self.leftContainer];
        [self.view addSubview:self.rightContainer];
        [self.view addSubview:self.centerContainer];
        
        self.viewHasLoaded = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if(!self.viewHasAppeared) {
        [self setLeftSideMenuFrameToClosedPosition];
        [self setRightSideMenuFrameToClosedPosition];
        [self addGestureRecognizers];
        [self.contentShadow refresh];
        [self.leftMenuShadow refresh];
        [self.rightMenuShadow refresh];
        
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
    
    [self.contentShadow shadowedViewWillRotate];
    [self.leftMenuShadow shadowedViewWillRotate];
    [self.rightMenuShadow shadowedViewWillRotate];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    [self.contentShadow shadowedViewDidRotate];
    [self.leftMenuShadow shadowedViewDidRotate];
    [self.rightMenuShadow shadowedViewDidRotate];
}


#pragma mark -
#pragma mark - UIViewController Containment

- (void)setLeftViewController:(UIViewController *)leftViewController {
    [self removeChildViewControllerFromContainer:_leftViewController];
    
    _leftViewController = leftViewController;
    if(!_leftViewController) return;
    
    [self addChildViewController:_leftViewController];
    if (self.viewHasLoaded)
    {
        _leftViewController.view.frame = self.leftContainer.bounds;
        [self.leftContainer addSubview:_leftViewController.view];
    }
    [_leftViewController didMoveToParentViewController:self];
    
    if(self.viewHasAppeared) [self setLeftSideMenuFrameToClosedPosition];
}

- (void)setCenterViewController:(UIViewController *)centerViewController {
    [self removeChildViewControllerFromContainer:_centerViewController];
    
    _centerViewController = centerViewController;
    if(!_centerViewController) return;
    
    [self addChildViewController:_centerViewController];
    if (self.viewHasLoaded)
    {
        [((UIViewController *)_centerViewController) view].frame = self.centerContainer.bounds;
        [self.centerContainer addSubview:[_centerViewController view]];
    }    
    [_centerViewController didMoveToParentViewController:self];
}

- (void)setRightViewController:(UIViewController *)rightViewController {
    [self removeChildViewControllerFromContainer:_rightViewController];
    
    _rightViewController = rightViewController;
    if(!_rightViewController) return;
    
    [self addChildViewController:_rightViewController];
    if (self.viewHasLoaded)
    {
        _rightViewController.view.frame = self.rightContainer.bounds;
        [self.rightContainer addSubview:_rightViewController.view];
    }
    [_rightViewController didMoveToParentViewController:self];
    
    if(self.viewHasAppeared) [self setRightSideMenuFrameToClosedPosition];
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

- (UITapGestureRecognizer *)centerTapGestureRecognizer
{
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]
                                             initWithTarget:self
                                             action:@selector(centerViewControllerTapped:)];
    [tapRecognizer setDelegate:self];
    return tapRecognizer;
}


#pragma mark -
#pragma mark - Menu State

- (void)toggleLeftSideMenuCompletion:(void (^)(void))completion {
    if(self.menuState == KSSlideControllerStateLeftMenuOpen) {
        [self setMenuState:KSSlideControllerStateClosed completion:completion];
    } else {
        [self setMenuState:KSSlideControllerStateLeftMenuOpen completion:completion];
    }
}

- (void)toggleRightSideMenuCompletion:(void (^)(void))completion {
    if(self.menuState == KSSlideControllerStateRightMenuOpen) {
        [self setMenuState:KSSlideControllerStateClosed completion:completion];
    } else {
        [self setMenuState:KSSlideControllerStateRightMenuOpen completion:completion];
    }
}

- (void)openLeftSideMenuCompletion:(void (^)(void))completion {
    if(!self.leftViewController) return;
    
    [self setControllerOffset:self.leftMenuWidth animated:YES completion:completion];
}

- (void)openRightSideMenuCompletion:(void (^)(void))completion {
    if(!self.rightViewController) return;
    
    [self setControllerOffset:-self.rightMenuWidth animated:YES completion:completion];
}

- (void)closeSideMenuCompletion:(void (^)(void))completion {
    [self setControllerOffset:0 animated:YES completion:completion];
}

- (void)setMenuState:(KSSlideControllerState)menuState {
    [self setMenuState:menuState completion:nil];
}

- (void)setMenuState:(KSSlideControllerState)menuState completion:(void (^)(void))completion {
    if (!self.viewHasLoaded)
    {
        _menuState = menuState;
        return;
    }
    
    void (^innerCompletion)() = ^ {
        _menuState = menuState;
        
        [self setUserInteractionStateForCenterViewController];
        KSSlideControllerStateEvent eventType = (_menuState == KSSlideControllerStateClosed) ? KSSlideControllerStateEventMenuDidClose : KSSlideControllerStateEventMenuDidOpen;
        [self sendStateEventNotification:eventType];
        
        if(completion) completion();
    };
    
    switch (menuState) {
        case KSSlideControllerStateClosed: {
            [self sendStateEventNotification:KSSlideControllerStateEventMenuWillClose];
            [self closeSideMenuCompletion:^{
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
        case KSSlideControllerStateLeftMenuOpen: {
            if(!self.leftViewController) return;
            [self sendStateEventNotification:KSSlideControllerStateEventMenuWillOpen];
            [self leftMenuWillShow];
            [self openLeftSideMenuCompletion:^{
                self.leftOverlay.image = nil;
                self.leftOverlay.hidden = YES;
                self.leftViewController.view.hidden = NO;
                self.leftMenuShadow.shadowedView = self.leftContainer;
                [self.leftMenuShadow refresh];
                innerCompletion();
            }];
            break;
        }
        case KSSlideControllerStateRightMenuOpen: {
            if(!self.rightViewController) return;
            [self sendStateEventNotification:KSSlideControllerStateEventMenuWillOpen];
            [self rightMenuWillShow];
            [self openRightSideMenuCompletion:^{
                self.rightOverlay.image = nil;
                self.rightOverlay.hidden = YES;
                self.rightViewController.view.hidden = NO;
                self.rightMenuShadow.shadowedView = self.rightContainer;
                [self.rightMenuShadow refresh];
                innerCompletion();
            }];
            break;
        }
        default:
            break;
    }
}

// these callbacks are called when the menu will become visible, not neccessarily when they will OPEN
- (void)leftMenuWillShow {
    self.leftContainer.hidden = NO;
}

- (void)rightMenuWillShow {
    self.rightContainer.hidden = NO;
}


#pragma mark -
#pragma mark - State Event Notification

- (void)sendStateEventNotification:(KSSlideControllerStateEvent)event {
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:event]
                                                         forKey:@"eventType"];
    [[NSNotificationCenter defaultCenter] postNotificationName:KSSlideControllerStateNotificationEvent
                                                        object:self
                                                      userInfo:userInfo];
}


#pragma mark -
#pragma mark - View Controller Movements

// Set offset from negative self.rightMenuWidth to positive self.leftMenuWidth
// An offset of 0 is closed

- (void)setControllerOffset:(CGFloat)offset animated:(BOOL)animated completion:(void (^)(void))completion {
    [self setControllerOffset:offset additionalAnimations:nil
                     animated:animated completion:completion];
}

- (void)setControllerOffset:(CGFloat)offset
       additionalAnimations:(void (^)(void))additionalAnimations
                   animated:(BOOL)animated
                 completion:(void (^)(void))completion {
    void (^innerCompletion)() = ^ {
        self.panGestureVelocity = 0.0;
        if(completion) completion();
    };
    
    if(animated) {
        CGFloat centerViewControllerXPosition = (self.centerViewController) ? self.centerContainer.frame.origin.x/(self.showMenuOverContent ? self.menuSlideParallaxFactor : 1) : 0;
        CGFloat duration = [self animationDurationFromStartPosition:centerViewControllerXPosition toEndPosition:offset];
                
        [UIView animateWithDuration:duration animations:^{
            CGFloat leftAlpha = self.leftMenuShadow.alpha;
            CGFloat rightAlpha = self.rightMenuShadow.alpha;
            
            [self setControllerOffset:offset];
            
            // Otherwise shadow is removed while menu closes
            if (self.leftMenuShadow.alpha != leftAlpha && leftAlpha > 0)
                self.leftMenuShadow.alpha = leftAlpha;
            if (self.rightMenuShadow.alpha != rightAlpha && rightAlpha > 0)
                self.rightMenuShadow.alpha = rightAlpha;
            
            if(additionalAnimations) additionalAnimations();
        } completion:^(BOOL finished) {
            [self setControllerOffset:offset];
            innerCompletion();
        }];
    } else {
        [self setControllerOffset:offset];
        if(additionalAnimations) additionalAnimations();
        innerCompletion();
    }
}

- (void)setControllerOffset:(CGFloat)offset {
    CGRect leftFrame = self.leftContainer.frame;
    CGRect centerFrame = self.centerContainer.frame;
    CGRect rightFrame = self.rightContainer.frame;
    leftFrame.origin.x = MIN(0, MAX(-self.leftMenuWidth, offset - self.leftMenuWidth)) * (self.showMenuOverContent ? 1 : self.menuSlideParallaxFactor);
    centerFrame.origin.x = offset * (self.showMenuOverContent ? self.menuSlideParallaxFactor : 1);
    rightFrame.origin.x = centerFrame.size.width - self.rightMenuWidth * (1 - (self.showMenuOverContent ? 1 : self.menuSlideParallaxFactor)) + offset * (self.showMenuOverContent ? 1 : self.menuSlideParallaxFactor);
    
    self.leftContainer.frame = leftFrame;
    self.centerContainer.frame = centerFrame;
    self.rightContainer.frame = rightFrame;
    
    self.leftMenuShadow.alpha = MAX(0, MIN(1, offset/20));
    self.rightMenuShadow.alpha = MAX(0, MIN(1, -offset/20));
    
    
    // handle inactive views
    if (offset != 0 && self.centerOverlay.hidden == YES)
    {
        self.centerOverlay.image = [self.centerViewController view].screenshot;
        self.centerOverlay.hidden = NO;
        [self.centerViewController view].hidden = YES;
        
        self.leftOverlay.image = self.leftViewController.view.screenshot;
        self.leftOverlay.hidden = NO;
        self.leftViewController.view.hidden = YES;
        
        self.rightOverlay.image = self.rightViewController.view.screenshot;
        self.rightOverlay.hidden = NO;
        self.rightViewController.view.hidden = YES;
    }
    else if (offset != self.leftMenuWidth && self.leftOverlay.hidden == YES)
    {
        self.leftOverlay.image = self.leftViewController.view.screenshot;
        self.leftOverlay.hidden = NO;
        self.leftViewController.view.hidden = YES;
    }
    else if (offset != self.rightMenuWidth && self.rightOverlay.hidden == YES)
    {
        self.rightOverlay.image = self.rightViewController.view.screenshot;
        self.rightOverlay.hidden = NO;
        self.rightViewController.view.hidden = YES;
    }
    
    CGFloat slideRatio = offset == 0 ? 0 : MAX(offset/self.leftMenuWidth, -offset/self.rightMenuWidth);
    
    if ((offset < 0 && self.menuSlideParallaxFactor > 0.5) || (offset > 0 && self.menuSlideParallaxFactor < 0.5))
    {
        self.centerOverlay.edgeHold = KSScaleEdgeHoldRight;
    }
    else
    {
        self.centerOverlay.edgeHold = KSScaleEdgeHoldLeft;
    }
    
    if (self.menuSlideParallaxFactor < 0.5)
    {
        self.leftOverlay.edgeHold = KSScaleEdgeHoldLeft;
        self.rightOverlay.edgeHold = KSScaleEdgeHoldRight;
    }
    else
    {
        self.leftOverlay.edgeHold = KSScaleEdgeHoldRight;
        self.rightOverlay.edgeHold = KSScaleEdgeHoldLeft;
    }
    
    if (self.showMenuOverContent)
    {
        self.centerOverlay.scale = 1 - (slideRatio * (1 - self.menuSlideScaleFactor));
        self.leftOverlay.scale = 1;
        self.rightOverlay.scale = 1;
    }
    else
    {
        self.centerOverlay.scale = 1;
        self.leftOverlay.scale = 1 - (1 - slideRatio) * (1 - self.menuSlideScaleFactor);
        self.rightOverlay.scale = 1 - (1 - slideRatio) * (1 - self.menuSlideScaleFactor);
    }
    
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
    } else {
        // no swipe was used, user tapped the bar button item
        // TODO: full animation duration hard to calculate with two menu widths
        CGFloat menuWidth = MAX(_leftMenuWidth, _rightMenuWidth);
        CGFloat animationPerecent = (animationPositionDelta == 0) ? 0 : menuWidth / animationPositionDelta;
        duration = self.menuAnimationDefaultDuration * animationPerecent;
    }
    
    return MIN(duration, self.menuAnimationMaxDuration);
}

- (void) setLeftSideMenuFrameToClosedPosition {
    if(!self.leftViewController) return;
    CGRect leftFrame = self.leftContainer.frame;
    leftFrame.size.width = self.leftMenuWidth;
    leftFrame.size.height = self.view.bounds.size.height;
    leftFrame.origin.x = -self.leftMenuWidth * (self.showMenuOverContent ? 1 : self.menuSlideParallaxFactor);
    leftFrame.origin.y = 0;
    self.leftContainer.frame = leftFrame;
    self.leftContainer.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleHeight;
}

- (void) setRightSideMenuFrameToClosedPosition {
    if(!self.rightViewController) return;
    CGRect rightFrame = self.rightContainer.frame;
    rightFrame.size.width = self.rightMenuWidth;
    rightFrame.size.height = self.view.bounds.size.height;
    rightFrame.origin.y = 0;
    rightFrame.origin.x = self.view.bounds.size.width - self.rightMenuWidth * (1 - (self.showMenuOverContent ? 1 : self.menuSlideParallaxFactor));
    self.rightContainer.frame = rightFrame;
    self.rightContainer.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleHeight;
}


#pragma mark -
#pragma mark - Side Menu Width

- (void)setMenuWidth:(CGFloat)menuWidth {
    [self setMenuWidth:menuWidth animated:YES];
}

- (void)setLeftMenuWidth:(CGFloat)leftMenuWidth {
    [self setLeftMenuWidth:leftMenuWidth animated:YES];
}

- (void)setRightMenuWidth:(CGFloat)rightMenuWidth {
    [self setRightMenuWidth:rightMenuWidth animated:YES];
}

- (void)setMenuWidth:(CGFloat)menuWidth animated:(BOOL)animated {
    [self setLeftMenuWidth:menuWidth animated:animated];
    [self setRightMenuWidth:menuWidth animated:animated];
}

- (void)setLeftMenuWidth:(CGFloat)leftMenuWidth animated:(BOOL)animated {
    _leftMenuWidth = leftMenuWidth;
    
    if (!self.viewHasLoaded)
    {
        return;
    }
    
    if(self.menuState != KSSlideControllerStateLeftMenuOpen) {
        [self setLeftSideMenuFrameToClosedPosition];
        return;
    }
    
    CGRect menuRect = self.leftContainer.frame;
    menuRect.size.width = _leftMenuWidth;
    self.leftContainer.frame = menuRect;
    
    [self setControllerOffset:_leftMenuWidth animated:animated completion:nil];
}

- (void)setRightMenuWidth:(CGFloat)rightMenuWidth animated:(BOOL)animated {
    _rightMenuWidth = rightMenuWidth;
    
    if (!self.viewHasLoaded)
    {
        return;
    }
    
    if(self.menuState != KSSlideControllerStateRightMenuOpen) {
        [self setRightSideMenuFrameToClosedPosition];
        return;
    }
    
    CGRect menuRect = self.rightContainer.frame;
    menuRect.origin.x = self.view.bounds.size.width - _rightMenuWidth;
    menuRect.size.width = _rightMenuWidth;
    self.rightContainer.frame = menuRect;
    
    [self setControllerOffset:-_rightMenuWidth animated:animated completion:nil];
}


#pragma mark -
#pragma mark - Menu Sliding Options

- (void)setShowMenuOverContent:(BOOL)showMenuOverContent
{
    _showMenuOverContent = showMenuOverContent;
    
    if (_showMenuOverContent)
    {
        [self.view sendSubviewToBack:self.centerContainer];
    }
    else
    {
        [self.view bringSubviewToFront:self.centerContainer];
    }
}

- (void)setMenuSlideParallaxFactor:(CGFloat)menuSlideParallaxFactor
{
    _menuSlideParallaxFactor = MAX(0, MIN(1, menuSlideParallaxFactor));
}

- (void)setMenuSlideScaleFactor:(CGFloat)menuSlideScaleFactor
{
    _menuSlideScaleFactor = MAX(0, MIN(1, menuSlideScaleFactor));
}

- (void)setMenuBlurFactor:(CGFloat)menuBlurFactor
{
    _menuBlurFactor = MAX(0, MIN(1, menuBlurFactor));
    
    self.leftOverlay.blurSize = _menuBlurFactor;
    self.rightOverlay.blurSize = _menuBlurFactor;
}

- (void)setContentBlurFactor:(CGFloat)contentBlurFactor
{
    _contentBlurFactor = MAX(0, MIN(1, contentBlurFactor));
    
    self.centerOverlay.blurSize = _contentBlurFactor;
}


#pragma mark -
#pragma mark - KSSlideControllerPanMode

- (BOOL) centerViewControllerPanEnabled {
    return ((self.panMode & KSSlideControllerPanModeCenterViewController) == KSSlideControllerPanModeCenterViewController);
}

- (BOOL) sideMenuPanEnabled {
    return ((self.panMode & KSSlideControllerPanModeSideMenu) == KSSlideControllerPanModeSideMenu);
}


#pragma mark -
#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]] &&
       self.menuState != KSSlideControllerStateClosed) return YES;
    
    if([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        if([gestureRecognizer.view isEqual:self.centerContainer])
            return [self centerViewControllerPanEnabled];
        
        if([gestureRecognizer.view isEqual:self.leftContainer] || [gestureRecognizer.view isEqual:self.rightContainer])
            return [self sideMenuPanEnabled];
        
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
            if(self.leftViewController && self.menuState == KSSlideControllerStateClosed) {
                [self leftMenuWillShow];
            }
        }
        else if(translatedPoint.x < 0) {
            self.panDirection = KSSlideControllerPanDirectionLeft;
            if(self.rightViewController && self.menuState == KSSlideControllerStateClosed) {
                [self rightMenuWillShow];
            }
        }
    }
    
    if((self.menuState == KSSlideControllerStateRightMenuOpen && self.panDirection == KSSlideControllerPanDirectionLeft)
       || (self.menuState == KSSlideControllerStateLeftMenuOpen && self.panDirection == KSSlideControllerPanDirectionRight)) {
        self.panDirection = KSSlideControllerPanDirectionNone;
        return;
    }
    
    if(self.panDirection == KSSlideControllerPanDirectionLeft) {
        [self handleLeftPan:recognizer];
    } else if(self.panDirection == KSSlideControllerPanDirectionRight) {
        [self handleRightPan:recognizer];
    }
    
    if (self.panDirection == KSSlideControllerPanDirectionNone && recognizer.state == UIGestureRecognizerStateEnded) {
        [self setMenuState:KSSlideControllerStateClosed];
    }
}

- (void) handleRightPan:(UIPanGestureRecognizer *)recognizer {
    if(!self.leftViewController && self.menuState == KSSlideControllerStateClosed) return;
    
    UIView *view = [self.centerViewController view];
    
    CGPoint translatedPoint = [recognizer translationInView:view];
    CGPoint adjustedOrigin = CGPointZero;
    if (self.menuState == KSSlideControllerStateRightMenuOpen)
        adjustedOrigin.x = -self.rightMenuWidth;
    else if (self.menuState == KSSlideControllerStateLeftMenuOpen)
        adjustedOrigin.x = self.leftMenuWidth;
    translatedPoint = CGPointMake(adjustedOrigin.x + translatedPoint.x,
                                  adjustedOrigin.y + translatedPoint.y);
    
    translatedPoint.x = MAX(translatedPoint.x, -1*self.rightMenuWidth);
    translatedPoint.x = MIN(translatedPoint.x, self.leftMenuWidth);
    
    if(self.menuState == KSSlideControllerStateRightMenuOpen) {
        // menu is already open, the most the user can do is close it in this gesture
        translatedPoint.x = MIN(translatedPoint.x, 0);
    } else {
        // we are opening the menu
        translatedPoint.x = MAX(translatedPoint.x, 0);
    }
    
    if(recognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint velocity = [recognizer velocityInView:view];
        CGFloat finalX = translatedPoint.x + (.35*velocity.x);
        CGFloat viewWidth = view.frame.size.width;
        
        if(self.menuState == KSSlideControllerStateClosed) {
            BOOL showMenu = (finalX > viewWidth/2) || (finalX > self.leftMenuWidth/2);
            if(showMenu) {
                self.panGestureVelocity = velocity.x;
                [self setMenuState:KSSlideControllerStateLeftMenuOpen];
            } else {
                self.panGestureVelocity = 0;
                [self setMenuState:KSSlideControllerStateClosed];
            }
        } else {
            BOOL hideMenu = (finalX > adjustedOrigin.x);
            if(hideMenu) {
                self.panGestureVelocity = velocity.x;
                [self setMenuState:KSSlideControllerStateClosed];
            } else {
                self.panGestureVelocity = 0;
                [self setMenuState:KSSlideControllerStateRightMenuOpen];
            }
        }
    } else {
        [self setControllerOffset:translatedPoint.x];
    }
    
    if (translatedPoint.x == 0)
        self.panDirection = KSSlideControllerPanDirectionNone;
}

- (void) handleLeftPan:(UIPanGestureRecognizer *)recognizer {
    if(!self.rightViewController && self.menuState == KSSlideControllerStateClosed) return;
    
    UIView *view = [self.centerViewController view];
    
    CGPoint translatedPoint = [recognizer translationInView:view];
    CGPoint adjustedOrigin = panGestureOrigin;
    if (self.menuState == KSSlideControllerStateRightMenuOpen)
        adjustedOrigin.x = -self.rightMenuWidth;
    else if (self.menuState == KSSlideControllerStateLeftMenuOpen)
        adjustedOrigin.x = self.leftMenuWidth;
    translatedPoint = CGPointMake(adjustedOrigin.x + translatedPoint.x,
                                  adjustedOrigin.y + translatedPoint.y);
    
    translatedPoint.x = MAX(translatedPoint.x, -1*self.rightMenuWidth);
    translatedPoint.x = MIN(translatedPoint.x, self.leftMenuWidth);
    if(self.menuState == KSSlideControllerStateLeftMenuOpen) {
        // don't let the pan go less than 0 if the menu is already open
        translatedPoint.x = MAX(translatedPoint.x, 0);
    } else {
        // we are opening the menu
        translatedPoint.x = MIN(translatedPoint.x, 0);
    }

	if(recognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint velocity = [recognizer velocityInView:view];
        CGFloat finalX = translatedPoint.x + (.35*velocity.x);
        CGFloat viewWidth = view.frame.size.width;
        
        if(self.menuState == KSSlideControllerStateClosed) {
            BOOL showMenu = (finalX < -1*viewWidth/2) || (finalX < -1*self.rightMenuWidth/2);
            if(showMenu) {
                self.panGestureVelocity = velocity.x;
                [self setMenuState:KSSlideControllerStateRightMenuOpen];
            } else {
                self.panGestureVelocity = 0;
                [self setMenuState:KSSlideControllerStateClosed];
            }
        } else {
            BOOL hideMenu = (finalX < adjustedOrigin.x);
            if(hideMenu) {
                self.panGestureVelocity = velocity.x;
                [self setMenuState:KSSlideControllerStateClosed];
            } else {
                self.panGestureVelocity = 0;
                [self setMenuState:KSSlideControllerStateLeftMenuOpen];
            }
        }
	} else {
        [self setControllerOffset:translatedPoint.x];
    }
    
    if (translatedPoint.x == 0)
        self.panDirection = KSSlideControllerPanDirectionNone;
}

- (void)centerViewControllerTapped:(id)sender {
    if(self.menuState != KSSlideControllerStateClosed) {
        [self setMenuState:KSSlideControllerStateClosed];
    }
}

- (void)setUserInteractionStateForCenterViewController {
    // disable user interaction on the current stack of view controllers if the menu is visible
    if([self.centerViewController respondsToSelector:@selector(viewControllers)]) {
        NSArray *viewControllers = [self.centerViewController viewControllers];
        for(UIViewController* viewController in viewControllers) {
            viewController.view.userInteractionEnabled = (self.menuState == KSSlideControllerStateClosed);
        }
    }
}

@end