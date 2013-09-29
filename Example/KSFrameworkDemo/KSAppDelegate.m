//
//  KSAppDelegate.m
//  KSFrameworkDemo
//
//  Created by Travis Zehren on 9/13/13.
//  Copyright (c) 2013 Kickstand Apps. All rights reserved.
//

#import "KSAppDelegate.h"
#import "DemoSlideViewController.h"
#import "SideMenuViewController.h"
#import "KSSlideController.h"
#import "DemoPullDownViewController.h"

@interface KSAppDelegate ()

@property (nonatomic, strong) UITabBarController *tabController;
@property (nonatomic, strong) DemoSlideViewController *demoSlideController;
@property (nonatomic, strong) UINavigationController *navigationController;
@property (nonatomic, strong) KSSlideController *slideController;
@property (nonatomic, strong) DemoPullDownViewController *demoPullDownController;

@end

@implementation KSAppDelegate

@synthesize tabController = _tabController;
@synthesize demoSlideController = _demoSlideController;
@synthesize navigationController = _navigationController;
@synthesize slideController = _slideController;
@synthesize demoPullDownController = _demoPullDownController;

- (UITabBarController *)tabController {
    if (!_tabController) {
        _tabController = [[UITabBarController alloc] init];
    }
    return _tabController;
}

- (DemoSlideViewController *)demoSlideController {
    if (!_demoSlideController)
    {
        _demoSlideController = [[DemoSlideViewController alloc] initWithNibName:@"DemoSlideViewController" bundle:nil];
        
        _demoSlideController.title = @"KSFramework Demo";
        _demoSlideController.navigationItem.rightBarButtonItem = [self rightMenuBarButtonItem];
        _demoSlideController.navigationItem.leftBarButtonItem = [self leftMenuBarButtonItem];
    }
    return _demoSlideController;
}

- (KSSlideController *)slideController {
    if (!_slideController)
    {
        SideMenuViewController *leftMenuViewController = [[SideMenuViewController alloc] init];
        SideMenuViewController *rightMenuViewController = [[SideMenuViewController alloc] init];

        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
            [leftMenuViewController.tableView setContentInset:UIEdgeInsetsMake([UIApplication sharedApplication].statusBarFrame.size.height, leftMenuViewController.tableView.contentInset.left, self.tabController.tabBar.frame.size.height, leftMenuViewController.tableView.contentInset.right)];
        
            [rightMenuViewController.tableView setContentInset:UIEdgeInsetsMake([UIApplication sharedApplication].statusBarFrame.size.height, rightMenuViewController.tableView.contentInset.left, self.tabController.tabBar.frame.size.height, rightMenuViewController.tableView.contentInset.right)];
        }
        
        _slideController = [KSSlideController slideControllerWithCenterViewController:self.navigationController leftViewController:leftMenuViewController rightViewController:rightMenuViewController];
        
        _slideController.centerViewStatusBarColor = [UIColor clearColor];
        _slideController.sideViewStatusBarColor = [UIColor blackColor];
        
        _slideController.title = @"KSSlideController";
    }
    return _slideController;
}

- (UINavigationController *)navigationController {
    if (!_navigationController)
    {
        _navigationController = [[UINavigationController alloc] initWithRootViewController:[self demoSlideController]];
    }
    return _navigationController;
}

- (DemoPullDownViewController *)demoPullDownController {
    if (!_demoPullDownController) {
        _demoPullDownController = [[DemoPullDownViewController alloc] init];
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
            [_demoPullDownController.scrollView setContentInset:UIEdgeInsetsMake(_demoPullDownController.scrollView.contentInset.top, _demoPullDownController.scrollView.contentInset.left, self.tabController.tabBar.frame.size.height, _demoPullDownController.scrollView.contentInset.right)];
        }
                
        _demoPullDownController.title = @"KSPullDownController";
    }
    return _demoPullDownController;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.tabController.viewControllers = [NSArray arrayWithObjects:self.slideController,self.demoPullDownController, nil];
    
    self.window.rootViewController = self.tabController;
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;

    [self.window makeKeyAndVisible];

    return YES;
}


#pragma mark - Setup Bar Button Items

- (UIBarButtonItem *)leftMenuBarButtonItem {
    return [[UIBarButtonItem alloc]
            initWithImage:[UIImage imageNamed:@"menu-icon.png"] style:UIBarButtonItemStyleBordered
            target:self
            action:@selector(leftSideMenuButtonPressed:)];
}

- (UIBarButtonItem *)rightMenuBarButtonItem {
    return [[UIBarButtonItem alloc]
            initWithImage:[UIImage imageNamed:@"menu-icon.png"] style:UIBarButtonItemStyleBordered
            target:self
            action:@selector(rightSideMenuButtonPressed:)];
}


#pragma mark -
#pragma mark - UIBarButtonItem Callbacks

- (void)leftSideMenuButtonPressed:(id)sender {
    [self.slideController toggleLeftViewWithCompletion:nil];
}

- (void)rightSideMenuButtonPressed:(id)sender {
    [self.slideController toggleRightViewWithCompletion:nil];
}


@end