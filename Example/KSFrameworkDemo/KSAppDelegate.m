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

@interface KSAppDelegate ()

@property (nonatomic, strong) DemoSlideViewController *demoController;
@property (nonatomic, strong) UINavigationController *navigationController;
@property (nonatomic, strong) KSSlideController *slideController;

@end

@implementation KSAppDelegate

@synthesize demoController = _demoController;
@synthesize navigationController = _navigationController;
@synthesize slideController = _slideController;

- (DemoSlideViewController *)demoController {
    if (!_demoController)
    {
        _demoController = [[DemoSlideViewController alloc] initWithNibName:@"DemoSlideViewController" bundle:nil];
        
        _demoController.title = @"KSFramework Demo";
        _demoController.navigationItem.rightBarButtonItem = [self rightMenuBarButtonItem];
        _demoController.navigationItem.leftBarButtonItem = [self leftMenuBarButtonItem];
    }
    return _demoController;
}

- (KSSlideController *)slideController {
    if (!_slideController)
    {
        SideMenuViewController *leftMenuViewController = [[SideMenuViewController alloc] init];
        SideMenuViewController *rightMenuViewController = [[SideMenuViewController alloc] init];
        
        _slideController = [KSSlideController slideControllerWithCenterViewController:self.navigationController leftViewController:leftMenuViewController rightViewController:rightMenuViewController];
    }
    return _slideController;
}

- (UINavigationController *)navigationController {
    if (!_navigationController)
    {
        _navigationController = [[UINavigationController alloc] initWithRootViewController:[self demoController]];
    }
    return _navigationController;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.window.rootViewController = self.slideController;
    
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