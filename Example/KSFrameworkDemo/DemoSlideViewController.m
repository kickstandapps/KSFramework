//
//  DemoSlideViewController.m
//  KSFrameworkDemo
//
//  Created by Travis Zehren on 9/15/13.
//  Copyright (c) 2013 Kickstand Apps. All rights reserved.
//

#import "DemoSlideViewController.h"
#import "KSSlideController.h"

@interface DemoSlideViewController ()

@end

@implementation DemoSlideViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBarTintColor:)]) {
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0 green:128/255.0 blue:1 alpha:1];
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        
        self.title = self.title;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([[UIDevice currentDevice] orientation] == UIInterfaceOrientationLandscapeLeft) {
        self.slideController.pinnedLeftView = YES;
    } else {
        self.slideController.pinnedLeftView = NO;
    }
    
    if ([[UIDevice currentDevice] orientation] == UIInterfaceOrientationLandscapeRight) {
        self.slideController.pinnedRightView = YES;
    } else {
        self.slideController.pinnedRightView = NO;
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    if ([[UIDevice currentDevice] orientation] == UIInterfaceOrientationLandscapeLeft) {
        self.slideController.pinnedLeftView = YES;
    } else {
        self.slideController.pinnedLeftView = NO;
    }
    
    if ([[UIDevice currentDevice] orientation] == UIInterfaceOrientationLandscapeRight) {
        self.slideController.pinnedRightView = YES;
    } else {
        self.slideController.pinnedRightView = NO;
    }
}

- (void)setTitle:(NSString *)title
{
    [super setTitle:title];
    
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBarTintColor:)]) {
        for (UIView *view in self.navigationController.navigationBar.subviews) {
            if (view.tag != 0) {
                [view removeFromSuperview];
            }
        }
    
        UILabel *myLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 10, 40)];
        [myLabel setFont:[UIFont fontWithName:@"AvenirNext-DemiBold" size:17]];
        [myLabel setTextColor:[UIColor whiteColor]];
        [myLabel setText:title];
        [self.navigationController.navigationBar.topItem setTitleView:myLabel];
    }
}

- (IBAction)switchMenuDepth:(id)sender
{
    self.navigationController.slideController.sideViewsInFront = ((UISwitch *)sender).on;
}

- (IBAction)slideParallaxFactor:(id)sender
{
    self.navigationController.slideController.slideParallaxFactor = ((UISlider *)sender).value;
}

- (IBAction)slideScaleFactor:(id)sender
{
    self.navigationController.slideController.slideScaleFactor = ((UISlider *)sender).value;
}

- (IBAction)slideTintOpacity:(id)sender
{
    self.navigationController.slideController.slideTintColor = [UIColor whiteColor];
    self.navigationController.slideController.slideTintOpacity = ((UISlider *)sender).value;
}

- (IBAction)slideMenuBlurFactor:(id)sender
{
    self.navigationController.slideController.sideViewBlurFactor = ((UISlider *)sender).value;
}

- (IBAction)slideContentBlurFactor:(id)sender
{
    self.navigationController.slideController.centerViewBlurFactor = ((UISlider *)sender).value;
}

@end
