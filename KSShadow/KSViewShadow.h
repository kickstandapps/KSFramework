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

@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, assign) CGFloat radius;
@property (nonatomic, assign) CGFloat opacity;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, assign) UIView *shadowedView;
@property (nonatomic, assign) CGFloat alpha;

+ (KSViewShadow *)shadowWithView:(UIView *)shadowedView;
+ (KSViewShadow *)shadowWithColor:(UIColor *)color radius:(CGFloat)radius opacity:(CGFloat)opacity;

- (void)refresh;
- (void)shadowedViewWillRotate;
- (void)shadowedViewDidRotate;

@end