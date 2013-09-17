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

- (IBAction)switchMenuDepth:(id)sender
{
    self.navigationController.slideController.sideViewsOnTop = ((UISwitch *)sender).on;
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
