//
//  KSImageAdditions.h
//  KSFramework
//
//  Created by Travis Zehren on 9/13/13.
//  Copyright (c) 2013 Kickstand Apps. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIImage (BoxBlur)

// Blur the current image with a box blur algorithm
// Accepts blur intensity values from 0 to 1
- (UIImage*)imageWithBlur:(CGFloat)blur;

@end


@interface UIView (Screenshot)

// Create UIImage screenshot from any view
- (UIImage *)screenshot;

@end


@interface UIScrollView (Screenshot)

// Create UIImage screenshot from any scrollview
- (UIImage *)screenshot;

@end