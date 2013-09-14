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
#import <QuartzCore/QuartzCore.h>
#import "KSImageAdditions.h"

NSString * const KSSlideControllerStateNotificationEvent = @"KSSlideControllerStateNotificationEvent";

typedef enum {
    KSSlideControllerPanDirectionNone,
    KSSlideControllerPanDirectionLeft,
    KSSlideControllerPanDirectionRight
} KSSlideControllerPanDirection;


@interface KSSlideController ()

@property (nonatomic, strong) UIView *leftMenuContainer;
@property (nonatomic, strong) UIView *rightMenuContainer;

@property (nonatomic, strong) UIImageView *centerImageView;
@property (nonatomic, strong) UIImageView *leftImageView;
@property (nonatomic, strong) UIImageView *rightImageView;

@property (nonatomic, strong) UIImageView *centerBlurView;
@property (nonatomic, strong) UIImageView *leftBlurView;
@property (nonatomic, strong) UIImageView *rightBlurView;

@property (nonatomic, assign) CGPoint panGestureOrigin;
@property (nonatomic, assign) CGFloat panGestureVelocity;
@property (nonatomic, assign) KSSlideControllerPanDirection panDirection;

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

@synthesize leftViewController = _leftViewController;
@synthesize centerViewController = _centerViewController;
@synthesize rightViewController = _rightViewController;
@synthesize leftMenuContainer = _leftMenuContainer;
@synthesize rightMenuContainer = _rightMenuContainer;
@synthesize centerImageView;
@synthesize leftImageView;
@synthesize rightImageView;
@synthesize centerBlurView;
@synthesize leftBlurView;
@synthesize rightBlurView;
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
@synthesize menuAnimationDefaultDuration;
@synthesize menuAnimationMaxDuration;
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
    if (self.leftMenuContainer) return;
    
    self.rightMenuContainer = [[UIView alloc] init];
    
    self.centerImageView = [[UIImageView alloc] init];
    self.leftImageView = [[UIImageView alloc] init];
    self.rightImageView = [[UIImageView alloc] init];
    self.menuSlideScaleFactor = 1.0;
    
    self.centerBlurView = [[UIImageView alloc] init];
    self.leftBlurView = [[UIImageView alloc] init];
    self.rightBlurView = [[UIImageView alloc] init];
    
    self.menuState = KSSlideControllerStateClosed;
    self.menuWidth = 270.0f;
    self.menuAnimationDefaultDuration = 0.4f;
    self.menuAnimationMaxDuration = 0.4f;
    self.panMode = KSSlideControllerPanModeDefault;
    self.viewHasAppeared = NO;
}

- (UIView *)leftMenuContainer
{
    if (!_leftMenuContainer)
    {
        _leftMenuContainer = [[UIView alloc] init];
        _leftMenuContainer.frame = CGRectMake(-self.leftMenuWidth, 0, self.leftMenuWidth, self.view.bounds.size.height);
        
        _leftMenuContainer.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _leftMenuContainer.backgroundColor = [UIColor clearColor];
        
        [_leftMenuContainer addSubview:self.leftViewController.view];
        
        [self.view addSubview:_leftMenuContainer];
    }
    return _leftMenuContainer;
}

- (UIView *)rightMenuContainer
{
    if (!_rightMenuContainer)
    {
        _rightMenuContainer = [[UIView alloc] init];
        _rightMenuContainer.frame = CGRectMake(self.view.bounds.size.width, 0, self.rightMenuWidth, self.view.bounds.size.height);
        
        _rightMenuContainer.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _rightMenuContainer.backgroundColor = [UIColor clearColor];
        
        [_rightMenuContainer addSubview:self.rightViewController.view];
        
        [self.view addSubview:_rightMenuContainer];
    }
    return _rightMenuContainer;
}


- (void)setupMenuContainerViews {
    self.centerImageView.image = nil;
    self.centerImageView.contentMode = UIViewContentModeScaleToFill;
    self.centerImageView.userInteractionEnabled = YES;
    self.centerImageView.hidden = YES;
    self.centerImageView.backgroundColor = [UIColor clearColor];
    self.centerImageView.frame = self.view.bounds;
    
    NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject: self.centerImageView];
    
    self.centerBlurView = [NSKeyedUnarchiver unarchiveObjectWithData: archivedData];;
    
    self.leftImageView = [NSKeyedUnarchiver unarchiveObjectWithData: archivedData];
    self.leftImageView.frame = self.leftMenuContainer.bounds;
    
    self.leftBlurView = [NSKeyedUnarchiver unarchiveObjectWithData: archivedData];
    self.leftBlurView.frame = self.leftImageView.frame;
    
    self.rightImageView = [NSKeyedUnarchiver unarchiveObjectWithData: archivedData];
    self.rightImageView.frame = self.rightMenuContainer.bounds;
    
    self.rightBlurView = [NSKeyedUnarchiver unarchiveObjectWithData: archivedData];
    self.rightBlurView.frame = self.rightImageView.frame;
    
    [self.view addSubview:self.centerImageView];
    [self.view addSubview:self.centerBlurView];
    [self.leftMenuContainer addSubview:self.leftImageView];
    [self.leftMenuContainer addSubview:self.leftBlurView];
    [self.rightMenuContainer addSubview:self.rightImageView];
    [self.rightMenuContainer addSubview:self.rightBlurView];
}


#pragma mark -
#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupMenuContainerViews];
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
    self.leftMenuShadow = nil;
    
    _leftViewController = leftViewController;
    if(!_leftViewController) return;
    
    [self addChildViewController:_leftViewController];
    _leftViewController.view.frame = self.leftMenuContainer.bounds;
    [self.leftMenuContainer addSubview:_leftViewController.view];
    [_leftViewController didMoveToParentViewController:self];
    
    if(self.viewHasAppeared) [self setLeftSideMenuFrameToClosedPosition];
    
    self.leftMenuShadow = [KSViewShadow shadowWithView:self.leftMenuContainer];
    [self.leftMenuShadow refresh];
}

- (void)setCenterViewController:(UIViewController *)centerViewController {
    [self removeCenterGestureRecognizers];
    [self removeChildViewControllerFromContainer:_centerViewController];
    self.contentShadow = nil;
    
    CGPoint origin = ((UIViewController *)_centerViewController).view.frame.origin;
    _centerViewController = centerViewController;
    if(!_centerViewController) return;
    
    [self addChildViewController:_centerViewController];
    [self.view addSubview:[_centerViewController view]];
    [((UIViewController *)_centerViewController) view].frame = (CGRect){.origin = origin, .size=centerViewController.view.frame.size};
    
    [_centerViewController didMoveToParentViewController:self];
    
    self.contentShadow = [KSViewShadow shadowWithView:[_centerViewController view]];
    [self.contentShadow refresh];
    [self addCenterGestureRecognizers];
}

- (void)setRightViewController:(UIViewController *)rightViewController {
    [self removeChildViewControllerFromContainer:_rightViewController];
    self.rightMenuShadow = nil;
    
    _rightViewController = rightViewController;
    if(!_rightViewController) return;
    
    [self addChildViewController:_rightViewController];
    _rightViewController.view.frame = self.rightMenuContainer.bounds;
    [self.rightMenuContainer addSubview:_rightViewController.view];
    [_rightViewController didMoveToParentViewController:self];
    
    if(self.viewHasAppeared) [self setRightSideMenuFrameToClosedPosition];
    
    self.rightMenuShadow = [KSViewShadow shadowWithView:self.rightMenuContainer];
    [self.rightMenuShadow refresh];
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
    [self addCenterGestureRecognizers];
    [self.leftMenuContainer addGestureRecognizer:[self panGestureRecognizer]];
    [self.rightMenuContainer addGestureRecognizer:[self panGestureRecognizer]];
}

- (void)removeCenterGestureRecognizers
{
    if (self.centerViewController)
    {
        [[self.centerViewController view] removeGestureRecognizer:[self centerTapGestureRecognizer]];
        [[self.centerViewController view] removeGestureRecognizer:[self panGestureRecognizer]];
        [self.centerImageView removeGestureRecognizer:[self centerTapGestureRecognizer]];
        [self.centerImageView removeGestureRecognizer:[self panGestureRecognizer]];
        [self.centerBlurView removeGestureRecognizer:[self panGestureRecognizer]];
    }
}
- (void)addCenterGestureRecognizers
{
    if (self.centerViewController)
    {
        [[self.centerViewController view] addGestureRecognizer:[self centerTapGestureRecognizer]];
        [[self.centerViewController view] addGestureRecognizer:[self panGestureRecognizer]];
        [self.centerImageView addGestureRecognizer:[self centerTapGestureRecognizer]];
        [self.centerImageView addGestureRecognizer:[self panGestureRecognizer]];
        [self.centerBlurView addGestureRecognizer:[self centerTapGestureRecognizer]];
        [self.centerBlurView addGestureRecognizer:[self panGestureRecognizer]];
    }
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
                self.leftMenuContainer.hidden = YES;
                self.rightMenuContainer.hidden = YES;
                self.centerImageView.image = nil;
                self.centerImageView.hidden = YES;
                self.centerBlurView.image = nil;
                self.centerBlurView.alpha = 0;
                self.centerBlurView.hidden = YES;
                [self.centerViewController view].hidden = NO;
                self.contentShadow.shadowedView = [self.centerViewController view];
                [self.contentShadow refresh];
                
                self.leftImageView.image = nil;
                self.leftImageView.hidden = YES;
                self.leftBlurView.image = nil;
                self.leftBlurView.alpha = 1;
                self.leftBlurView.hidden = YES;
                self.leftViewController.view.hidden = NO;
                self.leftMenuShadow.shadowedView = self.leftMenuContainer;
                [self.leftMenuShadow refresh];
                
                self.rightImageView.image = nil;
                self.rightImageView.hidden = YES;
                self.rightBlurView.image = nil;
                self.rightBlurView.alpha = 1;
                self.rightBlurView.hidden = YES;
                self.rightViewController.view.hidden = NO;
                self.rightMenuShadow.shadowedView = self.rightMenuContainer;
                [self.rightMenuShadow refresh];
                
                innerCompletion();
            }];
            break;
        }
        case KSSlideControllerStateLeftMenuOpen: {
            if(!self.leftViewController) return;
            [self sendStateEventNotification:KSSlideControllerStateEventMenuWillOpen];
            [self leftMenuWillShow];
            [self openLeftSideMenuCompletion:^{
                self.leftImageView.image = nil;
                self.leftImageView.hidden = YES;
                self.leftBlurView.image = nil;
                self.leftBlurView.alpha = 0;
                self.leftBlurView.hidden = YES;
                self.leftViewController.view.hidden = NO;
                self.leftMenuShadow.shadowedView = self.leftMenuContainer;
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
                self.rightImageView.image = nil;
                self.rightImageView.hidden = YES;
                self.rightBlurView.image = nil;
                self.rightBlurView.alpha = 0;
                self.rightBlurView.hidden = YES;
                self.rightViewController.view.hidden = NO;
                self.rightMenuShadow.shadowedView = self.rightMenuContainer;
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
    self.leftMenuContainer.hidden = NO;
}

- (void)rightMenuWillShow {
    self.rightMenuContainer.hidden = NO;
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
        CGFloat centerViewControllerXPosition = [self.centerViewController view].frame.origin.x/(self.showMenuOverContent ? self.menuSlideParallaxFactor : 1);
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
    CGRect leftFrame = self.leftMenuContainer.frame;
    CGRect centerFrame = [self.centerViewController view].frame;
    CGRect rightFrame = self.rightMenuContainer.frame;
    
    leftFrame.origin.x = MIN(0, MAX(-self.leftMenuWidth, offset - self.leftMenuWidth)) * (self.showMenuOverContent ? 1 : self.menuSlideParallaxFactor);
    centerFrame.origin.x = offset * (self.showMenuOverContent ? self.menuSlideParallaxFactor : 1);
    rightFrame.origin.x = centerFrame.size.width - self.rightMenuWidth * (1 - (self.showMenuOverContent ? 1 : self.menuSlideParallaxFactor)) + offset * (self.showMenuOverContent ? 1 : self.menuSlideParallaxFactor);
    
    
    self.leftMenuContainer.frame = leftFrame;
    [self.centerViewController view].frame = centerFrame;
    self.rightMenuContainer.frame = rightFrame;
    
    self.leftMenuShadow.alpha = MAX(0, MIN(1, offset/20));
    self.rightMenuShadow.alpha = MAX(0, MIN(1, -offset/20));
    
    
    // handle scaling
    if (offset != 0 && self.centerImageView.hidden == YES)
    {
        self.centerImageView.image = [self.centerViewController view].screenshot;
        self.centerImageView.layer.sublayers = nil;
        self.contentShadow.shadowedView = self.centerImageView;
        [self.contentShadow refresh];
        self.centerImageView.hidden = NO;
        self.centerBlurView.image = [self.centerImageView.image imageWithBlur:self.contentBlurFactor];
        self.centerBlurView.hidden = NO;
        [self.centerViewController view].hidden = YES;
        
        self.leftImageView.image = self.leftViewController.view.screenshot;
        self.leftImageView.layer.sublayers = nil;
        self.leftMenuShadow.shadowedView = self.leftImageView;
        [self.leftMenuShadow refresh];
        self.leftImageView.hidden = NO;
        self.leftBlurView.image = [self.leftImageView.image imageWithBlur:self.menuBlurFactor];
        self.leftBlurView.hidden = NO;
        self.leftViewController.view.hidden = YES;
        
        self.rightImageView.image = self.rightViewController.view.screenshot;
        self.rightImageView.layer.sublayers = nil;
        self.rightMenuShadow.shadowedView = self.rightImageView;
        [self.rightMenuShadow refresh];
        self.rightImageView.hidden = NO;
        self.rightBlurView.image = [self.rightImageView.image imageWithBlur:self.menuBlurFactor];
        self.rightBlurView.hidden = NO;
        self.rightViewController.view.hidden = YES;
    }
    if (offset != self.leftMenuWidth && self.leftImageView.hidden == YES)
    {
        self.leftImageView.image = self.leftViewController.view.screenshot;
        self.leftImageView.layer.sublayers = nil;
        self.leftMenuShadow.shadowedView = self.leftImageView;
        [self.leftMenuShadow refresh];
        self.leftImageView.hidden = NO;
        self.leftBlurView.image = [self.leftImageView.image imageWithBlur:self.menuBlurFactor];
        self.leftBlurView.hidden = NO;
        self.leftViewController.view.hidden = YES;
    }
    if (offset != self.rightMenuWidth && self.rightImageView.hidden == YES)
    {
        self.rightImageView.image = self.rightViewController.view.screenshot;
        self.rightImageView.layer.sublayers = nil;
        self.rightMenuShadow.shadowedView = self.rightImageView;
        [self.rightMenuShadow refresh];
        self.rightImageView.hidden = NO;
        self.rightBlurView.image = [self.rightImageView.image imageWithBlur:self.menuBlurFactor];
        self.rightBlurView.hidden = NO;
        self.rightViewController.view.hidden = YES;
    }
    
    CGFloat slideRatio = offset == 0 ? 0 : MAX(offset/self.leftMenuWidth, -offset/self.rightMenuWidth);
    
    CGRect centerImageFrame = centerFrame;
    centerImageFrame.size.width = (1 - (1 - (self.showMenuOverContent ? self.menuSlideScaleFactor : 1)) * slideRatio) * centerFrame.size.width;
    centerImageFrame.size.height = (1 - (1 - (self.showMenuOverContent ? self.menuSlideScaleFactor : 1)) * slideRatio) * centerFrame.size.height;
    centerImageFrame.origin.y = (1 - (self.showMenuOverContent ? self.menuSlideScaleFactor : 1)) * slideRatio * centerFrame.size.height / 2;
    if (offset > 0)
        centerImageFrame.origin.x = MAX(MIN((centerFrame.size.width - centerImageFrame.size.width)/2 + centerFrame.origin.x,leftFrame.origin.x + leftFrame.size.width),self.view.bounds.size.width - centerImageFrame.size.width);
    else if (offset < 0)
        centerImageFrame.origin.x = MIN(MAX((centerFrame.size.width - centerImageFrame.size.width)/2 + centerFrame.origin.x, rightFrame.origin.x - centerImageFrame.size.width),0);
    
    self.centerImageView.frame = centerImageFrame;
    
    CGRect leftImageFrame = self.leftMenuContainer.bounds;
    leftImageFrame.size.width = (1 - (1 - (self.showMenuOverContent ? 1 : self.menuSlideScaleFactor)) * (1 - slideRatio)) * leftFrame.size.width;
    leftImageFrame.size.height = (1 - (1 - (self.showMenuOverContent ? 1 : self.menuSlideScaleFactor)) * (1 - slideRatio)) * leftFrame.size.height;
    leftImageFrame.origin.x = 0;
    leftImageFrame.origin.y = (leftFrame.size.height - leftImageFrame.size.height) / 2;
    
    self.leftImageView.frame = leftImageFrame;
    
    CGRect rightImageFrame = self.rightMenuContainer.bounds;
    rightImageFrame.size.width = (1 - (1 - (self.showMenuOverContent ? 1 : self.menuSlideScaleFactor)) * (1 - slideRatio)) * rightFrame.size.width;
    rightImageFrame.size.height = (1 - (1 - (self.showMenuOverContent ? 1 : self.menuSlideScaleFactor)) * (1 - slideRatio)) * rightFrame.size.height;
    rightImageFrame.origin.x = rightFrame.size.width - rightImageFrame.size.width;
    rightImageFrame.origin.y = (rightFrame.size.height - rightImageFrame.size.height) / 2;
    
    self.rightImageView.frame = rightImageFrame;
    
    self.centerBlurView.frame = centerImageFrame;
    self.centerBlurView.alpha = 1 - pow(slideRatio - 1,2);
    
    self.leftBlurView.frame = leftImageFrame;
    self.leftBlurView.alpha = 1 - (pow(slideRatio,2));
    
    self.rightBlurView.frame = rightImageFrame;
    self.rightBlurView.alpha = 1 - (pow(slideRatio,2));
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
    CGRect leftFrame = self.leftMenuContainer.frame;
    leftFrame.size.width = self.leftMenuWidth;
    leftFrame.size.height = self.view.bounds.size.height;
    leftFrame.origin.x = -self.leftMenuWidth * (self.showMenuOverContent ? 1 : self.menuSlideParallaxFactor);
    leftFrame.origin.y = 0;
    self.leftMenuContainer.frame = leftFrame;
    self.leftMenuContainer.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleHeight;
}

- (void) setRightSideMenuFrameToClosedPosition {
    if(!self.rightViewController) return;
    CGRect rightFrame = self.rightMenuContainer.frame;
    rightFrame.size.width = self.rightMenuWidth;
    rightFrame.size.height = self.view.bounds.size.height;
    rightFrame.origin.y = 0;
    rightFrame.origin.x = self.view.bounds.size.width - self.rightMenuWidth * (1 - (self.showMenuOverContent ? 1 : self.menuSlideParallaxFactor));
    self.rightMenuContainer.frame = rightFrame;
    self.rightMenuContainer.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleHeight;
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
    
    if(self.menuState != KSSlideControllerStateLeftMenuOpen) {
        [self setLeftSideMenuFrameToClosedPosition];
        return;
    }
    
    CGRect menuRect = self.leftMenuContainer.frame;
    menuRect.size.width = _leftMenuWidth;
    self.leftMenuContainer.frame = menuRect;
    
    [self setControllerOffset:_leftMenuWidth animated:animated completion:nil];
}

- (void)setRightMenuWidth:(CGFloat)rightMenuWidth animated:(BOOL)animated {
    _rightMenuWidth = rightMenuWidth;
    
    if(self.menuState != KSSlideControllerStateRightMenuOpen) {
        [self setRightSideMenuFrameToClosedPosition];
        return;
    }
    
    CGRect menuRect = self.rightMenuContainer.frame;
    menuRect.origin.x = self.view.bounds.size.width - _rightMenuWidth;
    menuRect.size.width = _rightMenuWidth;
    self.rightMenuContainer.frame = menuRect;
    
    [self setControllerOffset:-_rightMenuWidth animated:animated completion:nil];
}


#pragma mark -
#pragma mark - Menu Sliding Options

- (void)setShowMenuOverContent:(BOOL)showMenuOverContent
{
    _showMenuOverContent = showMenuOverContent;
    
    if (_showMenuOverContent)
    {
        [self.view sendSubviewToBack:[self.centerViewController view]];
        [self.view sendSubviewToBack:self.centerBlurView];
        [self.view sendSubviewToBack:self.centerImageView];
    }
    else
    {
        [self.view bringSubviewToFront:[self.centerViewController view]];
        [self.view bringSubviewToFront:self.centerImageView];
        [self.view bringSubviewToFront:self.centerBlurView];
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
}

- (void)setContentBlurFactor:(CGFloat)contentBlurFactor
{
    _contentBlurFactor = MAX(0, MIN(1, contentBlurFactor));
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
        if([gestureRecognizer.view isEqual:[self.centerViewController view]])
            return [self centerViewControllerPanEnabled];
        
        if([gestureRecognizer.view isEqual:self.leftMenuContainer] || [gestureRecognizer.view isEqual:self.rightMenuContainer])
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
    
    [self setControllerOffset:translatedPoint.x];
    
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