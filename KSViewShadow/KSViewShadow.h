//
//  KSViewShadow.h
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

#import <Foundation/Foundation.h>

@interface KSViewShadow : NSObject

// Enable or disable the shadow (default = YES)
@property (nonatomic, assign) BOOL enabled;

// Shadow radius (default = 10.0f)
@property (nonatomic, assign) CGFloat radius;

// Shadow color (default = black)
@property (nonatomic, strong) UIColor *color;

// Shadow opacity (default = 0.75f)
@property (nonatomic, assign) CGFloat opacity;

// Set view to be shadowed
@property (nonatomic, assign) UIView *shadowedView;

// Alpha should only be used for gradual showing/hiding of shadow.
// Opacity should be used to adjust transparency of shadow.
@property (nonatomic, assign) CGFloat alpha;

// Create KSViewShadow attached to specified view.
// Default .color = [UIColor blackColor]
// Default .radius = 10.0f
// Default .opacity = 0.75f
+ (KSViewShadow *)shadowWithView:(UIView *)shadowedView;

// Create KSViewShadow with specified color, radius, and opacity.
+ (KSViewShadow *)shadowWithColor:(UIColor *)color radius:(CGFloat)radius opacity:(CGFloat)opacity;

// Refresh shadow should be called after any changes to the view being shadowed.
- (void)refresh;

// Call these methods in when orientation will change to
// prepare shadow for animated transition.
- (void)shadowedViewWillRotate;
- (void)shadowedViewDidRotate;

@end