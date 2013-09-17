//
//  KSViewShadow.m
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
//    MFSideMenuShadow.h
//    MFSideMenuDemoSearchBar
//
//    Created by Michael Frederick on 5/13/13.
//    Copyright (c) 2013 Frederick Development. All rights reserved.
//


#import "KSViewShadow.h"
#import <QuartzCore/QuartzCore.h>

@implementation KSViewShadow

@synthesize color = _color;
@synthesize opacity = _opacity;
@synthesize radius = _radius;
@synthesize enabled = _enabled;
@synthesize shadowedView;
@synthesize alpha = _alpha;

+ (KSViewShadow *)shadowWithView:(UIView *)shadowedView
{
    KSViewShadow *shadow = [KSViewShadow shadowWithColor:[UIColor blackColor] radius:10.0f opacity:0.75f];
    shadow.shadowedView = shadowedView;
    return shadow;
}

+ (KSViewShadow *)shadowWithColor:(UIColor *)color radius:(CGFloat)radius opacity:(CGFloat)opacity
{
    KSViewShadow *shadow = [KSViewShadow new];
    shadow.color = color;
    shadow.radius = radius;
    shadow.opacity = opacity;
    return shadow;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        self.color = [UIColor blackColor];
        self.opacity = 0.75f;
        self.radius = 10.0f;
        self.enabled = YES;
        self.alpha = 1.0;
    }
    return self;
}


#pragma mark -
#pragma mark - Property Setters

- (void)setEnabled:(BOOL)shadowEnabled
{
    _enabled = shadowEnabled;
    [self refresh];
}

- (void)setRadius:(CGFloat)shadowRadius
{
    _radius = shadowRadius;
    [self refresh];
}

- (void)setColor:(UIColor *)shadowColor
{
    _color = shadowColor;
    [self refresh];
}

- (void)setOpacity:(CGFloat)shadowOpacity
{
    _opacity = shadowOpacity;
    [self refresh];
}

- (void)setAlpha:(CGFloat)shadowAlpha
{
    _alpha = shadowAlpha;
    [self refresh];
}

#pragma mark -
#pragma mark - refreshing

- (void)refresh
{
    if(_enabled)
    {
        [self show];
    }
    
    else
    {
        [self hide];
    }
}

- (void)show
{
    CGRect pathRect = self.shadowedView.bounds;
    pathRect.size = self.shadowedView.frame.size;
    self.shadowedView.layer.masksToBounds = NO;
    self.shadowedView.layer.shadowPath = [UIBezierPath bezierPathWithRect:pathRect].CGPath;
    self.shadowedView.layer.shadowOpacity = self.opacity * self.alpha;
    self.shadowedView.layer.shadowRadius = self.radius;
    self.shadowedView.layer.shadowColor = [self.color CGColor];
    self.shadowedView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
}

- (void)hide
{
    self.shadowedView.layer.shadowOpacity = 0.0f;
    self.shadowedView.layer.shadowRadius = 0.0f;
}


#pragma mark -
#pragma mark - ShadowedView Rotation

- (void)shadowedViewWillRotate
{
    self.shadowedView.layer.shadowPath = nil;
    self.shadowedView.layer.shouldRasterize = YES;
}

- (void)shadowedViewDidRotate
{
    [self refresh];
    self.shadowedView.layer.shouldRasterize = NO;
}

@end
