//
//  KSInactiveImageView.h
//  KSFrameworkDemo
//
//  Created by Travis Zehren on 9/13/13.
//  Copyright (c) 2013 Kickstand Apps. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    KSScaleEdgeHoldNone     = 0,
    KSScaleEdgeHoldTop      = 1 << 0,
    KSScaleEdgeHoldBottom   = 2 << 0,
    KSScaleEdgeHoldLeft     = 1 << 1,
    KSScaleEdgeHoldRight    = 2 << 1,
} KSScaleEdgeHold;

@interface KSInactiveImageView : UIView

#pragma mark - UIImageView Properties and Methods

// Initializing
- (id)initWithImage:(UIImage *)image;

// Image Data
@property (nonatomic, strong) UIImage *image;


#pragma mark - KSInactiveImageView

// Set scale of image (from 0 to 1*)
// and edge to hold to (default -> none)
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, assign) KSScaleEdgeHold edgeHold;

// Set overlay tint color (default -> clear)
// and opacity (from 0* to 1)
@property (nonatomic, strong) UIColor *tintColor;
@property (nonatomic, assign) CGFloat tintOpacity;

// Set size of box blur (from 0* to 1)
// and blur intensity (from 0* to 1)
@property (nonatomic, assign) CGFloat blurSize;
@property (nonatomic, assign) CGFloat blurIntensity;

@end
