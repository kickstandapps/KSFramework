//
//  KSPullDownController.m
//  KSFrameworkDemo
//
//  Created by Travis Zehren on 9/24/13.
//  Copyright (c) 2013 Kickstand Apps. All rights reserved.
//

#import "KSPullDownController.h"

@interface KSPullDownController ()

@property (nonatomic, assign) CGFloat iOSVersion;

@property (nonatomic, assign) BOOL viewHasLoaded;

@property (nonatomic, strong) UIView *statusBarBackgroundView;

@property (nonatomic, assign, readwrite) KSPullDownControllerState pullDownControllerState;
@property (nonatomic, strong) UIView *pullDownViewContainer;

@end


#pragma mark -
#pragma mark - UIViewController + KSPullDownController

@implementation UIViewController (KSPullDownController)

@dynamic pullDownController;

- (KSPullDownController *)pullDownController
{
    id containerView = self;
    while (![containerView isKindOfClass:[KSPullDownController class]] && containerView) {
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


#pragma mark -
#pragma mark - KSPullDownController

@implementation KSPullDownController

@synthesize iOSVersion = _iOSVersion;
@synthesize viewHasLoaded;
@synthesize pullDownControllerState = _pullDownControllerState;
@synthesize pullDownViewContainer = _pullDownViewContainer;
@synthesize scrollView = _scrollView;
@synthesize showScrollIndicator = _showScrollIndicator;
@synthesize pullDownViewController = _pullDownViewController;
@synthesize pullDownViewHeight = _pullDownViewHeight;
@synthesize pullDownBreakPoint;
@synthesize openPullDownViewCompletion = _openPullDownViewCompletion;
@synthesize closePullDownViewCompletion = _closePullDownViewCompletion;
@synthesize statusBarBackgroundView = _statusBarBackgroundView;
@synthesize statusBarMode = _statusBarMode;
@synthesize statusBarColor = _statusBarColor;


#pragma mark -
#pragma mark - Initialization

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (CGFloat)iOSVersion
{
    if (!_iOSVersion) {
        _iOSVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    }
    return _iOSVersion;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.delegate = self;
    }
    return _scrollView;
}

- (void)setShowScrollIndicator:(BOOL)showScrollIndicator {
    _showScrollIndicator = showScrollIndicator;
    
    self.scrollView.showsVerticalScrollIndicator = showScrollIndicator;
}

- (UIView *)pullDownViewContainer {
    if (!_pullDownViewContainer) {
        CGRect pullDownViewFrame = CGRectMake(0, -self.pullDownViewHeight, self.scrollView.bounds.size.width, self.pullDownViewHeight);

        _pullDownViewContainer = [[UIView alloc] initWithFrame:pullDownViewFrame];
        
        _pullDownViewContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _pullDownViewContainer.backgroundColor = [UIColor clearColor];
        
        if (!self.pullDownViewController.view.superview) {
            self.pullDownViewController.view.frame = _pullDownViewContainer.bounds;
            [_pullDownViewContainer addSubview:self.pullDownViewController.view];
        }
    }
    return _pullDownViewContainer;
}

- (UIView *)statusBarBackgroundView {
    if (!_statusBarBackgroundView) {
        CGFloat barHeight = 0;
        if (self.iOSVersion >= 7 && ![UIApplication sharedApplication].statusBarHidden) {
            if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
                barHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
            }
            else {
                barHeight = [UIApplication sharedApplication].statusBarFrame.size.width;
            }
        }
        _statusBarBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width,barHeight)];
        _statusBarBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _statusBarBackgroundView.backgroundColor = self.statusBarColor;
    }
    return _statusBarBackgroundView;
}

- (void)setStatusBarMode:(KSPullDownStatusBarMode)statusBarMode {
    _statusBarMode = statusBarMode;
    
    [self updateStatusBarFrame];
}

- (UIColor *)statusBarColor {
    if (!_statusBarColor) {
        _statusBarColor = [UIColor clearColor];
    }
    return _statusBarColor;
}

- (void)setStatusBarColor:(UIColor *)statusBarColor {
    _statusBarColor = statusBarColor;
    self.statusBarBackgroundView.backgroundColor = statusBarColor;
}


#pragma mark -
#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!self.viewHasLoaded) {
        [self updateStatusBarFrame];
        
        [self.view addSubview:self.scrollView];
        [self.scrollView addSubview:self.pullDownViewContainer];
        [self.view addSubview:self.statusBarBackgroundView];
        
        self.viewHasLoaded = YES;
    }
}

- (void)updateStatusBarFrame {
    CGFloat barHeight = 0;
    if (self.iOSVersion >= 7 && ![UIApplication sharedApplication].statusBarHidden) {
        if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
            barHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
        }
        else {
            barHeight = [UIApplication sharedApplication].statusBarFrame.size.width;
        }
    }
    self.statusBarBackgroundView.frame = CGRectMake(0, 0, self.view.bounds.size.width,barHeight);
    
    CGRect scrollFrame = self.view.bounds;
    if (self.iOSVersion >= 7 && self.statusBarMode == KSPullDownStatusBarModeOffset) {
        scrollFrame.origin.y = self.statusBarBackgroundView.bounds.size.height;
        scrollFrame.size.height -= self.statusBarBackgroundView.bounds.size.height;
    }
    self.scrollView.frame = scrollFrame;
}


#pragma mark -
#pragma mark - UIViewController Containment

- (void)setPullDownViewController:(UIViewController *)pullDownViewController {
    [self removeChildViewControllerFromContainer:pullDownViewController];
    
    _pullDownViewController = pullDownViewController;
    
    if(!_pullDownViewController) {
        self.pullDownViewContainer.frame = CGRectMake(0, 0, self.scrollView.bounds.size.width, 0);
        return;
    }
    
    [self addChildViewController:_pullDownViewController];
    if (self.viewHasLoaded) {
        _pullDownViewController.view.frame = self.pullDownViewContainer.bounds;
        [self.pullDownViewContainer addSubview:_pullDownViewController.view];
    }
    
    self.pullDownViewContainer.frame = CGRectMake(0, -self.pullDownViewHeight, self.scrollView.bounds.size.width, self.pullDownViewHeight);

    
    [_pullDownViewController didMoveToParentViewController:self];
}

- (void)removeChildViewControllerFromContainer:(UIViewController *)childViewController {
    if(!childViewController) return;
    [childViewController willMoveToParentViewController:nil];
    [childViewController removeFromParentViewController];
    [childViewController.view removeFromSuperview];
}


#pragma mark -
#pragma mark - Pull Down View Methods

- (void)setPullDownControllerState:(KSPullDownControllerState)pullDownControllerState withAnimatedDuration:(CGFloat)duration {
    if (pullDownControllerState == KSPullDownControllerStateOpen) {
        self.scrollView.showsVerticalScrollIndicator = NO;
        
        [UIView animateWithDuration:duration animations:^{
            self.scrollView.contentInset = UIEdgeInsetsMake(self.pullDownViewHeight, self.scrollView.contentInset.left, self.scrollView.contentInset.bottom, self.scrollView.contentInset.right);
            self.scrollView.contentOffset = CGPointMake(0,-self.pullDownViewHeight);
        } completion:^(BOOL finish) {
            if ([self.delegate respondsToSelector:@selector(pullDownViewControllerOpenRatio:)]) {
                [self.delegate pullDownViewControllerOpenRatio:1];
            }
            if (self.pullDownControllerState == KSPullDownControllerStateClosed) {
                self.pullDownControllerState = KSPullDownControllerStateOpen;
                if (self.openPullDownViewCompletion) {
                    self.openPullDownViewCompletion ();
                }
            }
        }];
    }
    else if (pullDownControllerState == KSPullDownControllerStateClosed) {
        if (self.scrollView.contentOffset.y < 0) {
            self.scrollView.showsVerticalScrollIndicator = NO;
            
            [UIView animateWithDuration:duration animations:^{
                self.scrollView.contentInset = UIEdgeInsetsMake(0, self.scrollView.contentInset.left, self.scrollView.contentInset.bottom, self.scrollView.contentInset.right);
            } completion:^(BOOL finish){
                self.scrollView.showsVerticalScrollIndicator = self.showScrollIndicator;
                if ([self.delegate respondsToSelector:@selector(pullDownViewControllerOpenRatio:)]) {
                    [self.delegate pullDownViewControllerOpenRatio:0];
                }
                if (self.pullDownControllerState == KSPullDownControllerStateOpen) {
                    self.pullDownControllerState = KSPullDownControllerStateClosed;
                    if (self.closePullDownViewCompletion) {
                        self.closePullDownViewCompletion ();
                    }
                }
            }];
        }
        else {
            self.scrollView.contentInset = UIEdgeInsetsMake(0, self.scrollView.contentInset.left, self.scrollView.contentInset.bottom, self.scrollView.contentInset.right);            self.scrollView.showsVerticalScrollIndicator = self.showScrollIndicator;
            if (self.pullDownControllerState == KSPullDownControllerStateOpen) {
                self.pullDownControllerState = KSPullDownControllerStateClosed;
                if ([self.delegate respondsToSelector:@selector(pullDownViewControllerOpenRatio:)]) {
                    [self.delegate pullDownViewControllerOpenRatio:0];
                }
                if (self.closePullDownViewCompletion) {
                    self.closePullDownViewCompletion ();
                }
            }
        }
    }
}

- (void)setPullDownViewHeight:(CGFloat)pullDownViewHeight {
    _pullDownViewHeight = pullDownViewHeight;
    
    if (self.viewHasLoaded) {
        self.pullDownViewContainer.frame = CGRectMake(0, -pullDownViewHeight, self.scrollView.bounds.size.width, pullDownViewHeight);
    }
}


#pragma mark -
#pragma mark - ScrollView Delegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.scrollView && scrollView.contentOffset.y < -self.pullDownViewHeight) {
        scrollView.contentOffset = CGPointMake(0, -self.pullDownViewHeight);
    }
    
    if (scrollView == self.scrollView && scrollView.contentOffset.y < 0 && [self.delegate respondsToSelector:@selector(pullDownViewControllerOpenRatio:)]) {
        [self.delegate pullDownViewControllerOpenRatio:-scrollView.contentOffset.y/self.pullDownViewHeight];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (scrollView == self.scrollView && ((scrollView.contentOffset.y < 0 && velocity.y < -1.0) || (scrollView.contentOffset.y <= -self.pullDownBreakPoint && velocity.y <= 0)))
    {
        *targetContentOffset = CGPointMake(0,-self.pullDownViewHeight);
        [self setPullDownControllerState:KSPullDownControllerStateOpen withAnimatedDuration:MAX(0, 0.3 + (velocity.y / 10))];
    }
    else if (scrollView == self.scrollView && scrollView.contentOffset.y < 0) {
        *targetContentOffset = CGPointZero;
        [self setPullDownControllerState:KSPullDownControllerStateClosed withAnimatedDuration:MAX(0, 0.3 - (velocity.y / 10))];
    }
    else if (scrollView == self.scrollView) {
        [self setPullDownControllerState:KSPullDownControllerStateClosed withAnimatedDuration:0];
    }
}

@end
