//
//  DemoPullDownViewController.m
//  KSFrameworkDemo
//
//  Created by Travis Zehren on 9/28/13.
//  Copyright (c) 2013 Kickstand Apps. All rights reserved.
//

#import "DemoPullDownViewController.h"
#import "DemoMenuViewController.h"

@interface DemoPullDownViewController ()

@property (nonatomic, strong) DemoMenuViewController *menu;

@end

@implementation DemoPullDownViewController

@synthesize menu = _menu;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (DemoMenuViewController  *)menu {
    if (!_menu) {
        _menu = [[DemoMenuViewController alloc] init];
    }
    return _menu;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.statusBarColor = [UIColor colorWithWhite:0.0 alpha:0.3];
	   
    self.scrollView.backgroundColor = [UIColor blueColor];
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width, 20 * 50 + 20);
    
    for (int i = 0; i < 20; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 20 + 50 * i, self.scrollView.bounds.size.width, 50)];
        label.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
        
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont fontWithName:@"Avenir" size:20];
        label.text = [NSString stringWithFormat:@"Random Number: %d",arc4random() % 101];
        
        [self.scrollView addSubview:label];
    }
    
    self.pullDownViewHeight = 140;
    self.pullDownBreakPoint = 50;
    self.pullDownViewController = self.menu;
    self.delegate = self.menu;
}

@end
