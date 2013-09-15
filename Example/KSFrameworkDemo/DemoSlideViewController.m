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
    self.navigationController.slideController.showMenuOverContent = ((UISwitch *)sender).on;
}

- (IBAction)slideParallaxFactor:(id)sender
{
    self.navigationController.slideController.menuSlideParallaxFactor = ((UISlider *)sender).value;
}

- (IBAction)slideScaleFactor:(id)sender
{
    self.navigationController.slideController.menuSlideScaleFactor = ((UISlider *)sender).value;
}

- (IBAction)slideMenuBlurFactor:(id)sender
{
    self.navigationController.slideController.menuBlurFactor = ((UISlider *)sender).value;
}

- (IBAction)slideContentBlurFactor:(id)sender
{
    self.navigationController.slideController.contentBlurFactor = ((UISlider *)sender).value;
}

@end
