//
//  DemoMenuViewController.m
//  KSFrameworkDemo
//
//  Created by Travis Zehren on 9/28/13.
//  Copyright (c) 2013 Kickstand Apps. All rights reserved.
//

#import "DemoMenuViewController.h"

@interface DemoMenuViewController ()

@property (nonatomic, strong) UILabel *optionsLabel;
@property (nonatomic, strong) UILabel *downArrows;

@property (nonatomic, strong) UIButton *redButton;
@property (nonatomic, strong) UIButton *greenButton;
@property (nonatomic, strong) UIButton *blueButton;

@end

@implementation DemoMenuViewController

@synthesize optionsLabel = _optionsLabel;
@synthesize downArrows = _downArrows;
@synthesize redButton = _redButton;
@synthesize greenButton = _greenButton;
@synthesize blueButton = _blueButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (UILabel *)optionsLabel
{
    if (!_optionsLabel)
    {
        _optionsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, self.view.bounds.size.width, 30)];
        _optionsLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
        _optionsLabel.backgroundColor = [UIColor clearColor];
        _optionsLabel.textColor = [UIColor colorWithWhite:0.6 alpha:1.0];
        _optionsLabel.text = @"Background Color";
        _optionsLabel.font = [UIFont fontWithName:@"Avenir" size:17];
        _optionsLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _optionsLabel;
}

- (UILabel *)downArrows
{
    if (!_downArrows)
    {
        _downArrows = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, self.view.bounds.size.width, 30)];
        _downArrows.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
        _downArrows.backgroundColor = [UIColor clearColor];
        _downArrows.textColor = [UIColor colorWithWhite:0.6 alpha:1.0];
        _downArrows.text = @"↓                               ↓";
        _downArrows.font = [UIFont fontWithName:@"Avenir" size:17];
        _downArrows.textAlignment = NSTextAlignmentCenter;
    }
    return _downArrows;
}

- (UIButton *)redButton {
    if (!_redButton) {
        _redButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width * .1, 40, self.view.bounds.size.width * .2, 40)];
        _redButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
        [_redButton setTitle:@"Red" forState:UIControlStateNormal];
        _redButton.titleLabel.textColor = [UIColor whiteColor];
        _redButton.backgroundColor = [UIColor colorWithHue:0/360.0 saturation:0.89 brightness:1.0 alpha:1.0];
        _redButton.titleLabel.font = [UIFont fontWithName:@"Avenir" size:17];
        [_redButton addTarget:self action:@selector(chooseRedColor) forControlEvents:UIControlEventTouchUpInside];
    }
    return _redButton;
}

- (UIButton *)greenButton {
    if (!_greenButton) {
        _greenButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width * .4, 40, self.view.bounds.size.width * .2, 40)];
        _greenButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
        [_greenButton setTitle:@"Green" forState:UIControlStateNormal];
        _greenButton.titleLabel.textColor = [UIColor whiteColor];
        _greenButton.backgroundColor = [UIColor colorWithHue:128/360.0 saturation:0.89 brightness:1.0 alpha:1.0];
        _greenButton.titleLabel.font = [UIFont fontWithName:@"Avenir" size:17];
        [_greenButton addTarget:self action:@selector(chooseGreenColor) forControlEvents:UIControlEventTouchUpInside];
    }
    return _greenButton;
}

- (UIButton *)blueButton {
    if (!_blueButton) {
        _blueButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width * .7, 40, self.view.bounds.size.width * .2, 40)];
        _blueButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
        [_blueButton setTitle:@"Blue" forState:UIControlStateNormal];
        _blueButton.titleLabel.textColor = [UIColor whiteColor];
        _blueButton.backgroundColor = [UIColor colorWithHue:210/360.0 saturation:0.89 brightness:1.0 alpha:1.0];
        _blueButton.titleLabel.font = [UIFont fontWithName:@"Avenir" size:17];
        [_blueButton addTarget:self action:@selector(chooseBlueColor) forControlEvents:UIControlEventTouchUpInside];
    }
    return _blueButton;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor darkGrayColor];
    
    [self.view addSubview:self.redButton];
    [self.view addSubview:self.greenButton];
    [self.view addSubview:self.blueButton];
    
    [self.view addSubview:self.optionsLabel];
    [self.view addSubview:self.downArrows];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    //[self updateButtonFramesAtOrientation:toInterfaceOrientation];
}

- (void)updateButtonFramesAtOrientation:(UIInterfaceOrientation)orientation {
    CGFloat width;
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        width = MIN(self.pullDownController.view.bounds.size.width, self.pullDownController.view.bounds.size.height);
    }
    else {
        width = MAX(self.pullDownController.view.bounds.size.width, self.pullDownController.view.bounds.size.height);
    }
    
    self.redButton.frame = CGRectMake(width * .1, 40, width * .2, 40);
    self.greenButton.frame = CGRectMake(width * .4, 40, width * .2, 40);
    self.blueButton.frame = CGRectMake(width * .7, 40, width * .2, 40);
}

- (void)chooseRedColor {
    self.pullDownController.scrollView.backgroundColor = [UIColor colorWithHue:0/360.0 saturation:0.89 brightness:1.0 alpha:1.0];
    [self.pullDownController setPullDownControllerState:KSPullDownControllerStateClosed withAnimatedDuration:0.3];
}

- (void)chooseGreenColor {
    self.pullDownController.scrollView.backgroundColor = [UIColor colorWithHue:128/360.0 saturation:0.89 brightness:0.9 alpha:1.0];
    [self.pullDownController setPullDownControllerState:KSPullDownControllerStateClosed withAnimatedDuration:0.3];
}

- (void)chooseBlueColor {
    self.pullDownController.scrollView.backgroundColor = [UIColor colorWithHue:210/360.0 saturation:0.89 brightness:1.0 alpha:1.0];
    [self.pullDownController setPullDownControllerState:KSPullDownControllerStateClosed withAnimatedDuration:0.3];
}

- (void)pullDownViewControllerOpenRatio:(CGFloat)openRatio {
    if (openRatio < .5 && self.pullDownController.pullDownControllerState == KSPullDownControllerStateClosed) {
        self.downArrows.hidden = NO;
    }
    else {
        self.downArrows.hidden = YES;
    }
}

@end
