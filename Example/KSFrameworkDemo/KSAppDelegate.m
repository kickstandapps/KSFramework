//
//  KSAppDelegate.m
//  KSFrameworkDemo
//
//  Created by Travis Zehren on 9/13/13.
//  Copyright (c) 2013 Kickstand Apps. All rights reserved.
//

#import "KSAppDelegate.h"
#import "DemoViewController.h"
#import "SideMenuViewController.h"
#import "KSSlideController.h"

@implementation KSAppDelegate

- (DemoViewController *)demoController {
    return [[DemoViewController alloc] initWithNibName:@"DemoViewController" bundle:nil];
}

- (UINavigationController *)navigationController {
    return [[UINavigationController alloc]
            initWithRootViewController:[self demoController]];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    SideMenuViewController *leftMenuViewController = [[SideMenuViewController alloc] init];
    SideMenuViewController *rightMenuViewController = [[SideMenuViewController alloc] init];
    KSSlideController *container = [KSSlideController slideControllerWithCenterViewController:[self navigationController] leftViewController:leftMenuViewController rightViewController:rightMenuViewController];
    
    container.showMenuOverContent = NO;
    container.menuSlideScaleFactor = 0.9;
    //container.menuSlideParallaxFactor = 1.0;
    self.window.rootViewController = container;
    [self.window makeKeyAndVisible];
    
    return YES;
}
@end