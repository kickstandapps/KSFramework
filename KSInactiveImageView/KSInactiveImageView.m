//
//  KSInactiveImageView.m
//  KSFramework
//
//  Created by Travis Zehren on 9/13/13.
//  Copyright (c) 2013 Kickstand Apps. All rights reserved.
//

#import "KSInactiveImageView.h"
#import "KSImageAdditions.h"

@interface KSInactiveImageView ()

@property (nonatomic, strong) UIView *baseView;
@property (nonatomic, strong) UIImageView *baseImageView;
@property (nonatomic, strong) UIImageView *blurredImageView;
@property (nonatomic, strong) UIView *tintView;

@end

@implementation KSInactiveImageView

@synthesize baseView = _baseView;
@synthesize baseImageView = _baseImageView;
@synthesize blurredImageView = _blurredImageView;
@synthesize tintView = _tintView;
@synthesize image = _image;
@synthesize tintColor = _tintColor;
@synthesize tintOpacity = _tintOpacity;
@synthesize scale = _scale;
@synthesize blurSize = _blurSize;
@synthesize blurIntensity = _blurIntensity;


- (id)initWithImage:(UIImage *)image
{
    KSInactiveImageView *inactiveImage = [self initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    
    inactiveImage.image = image;
    
    return inactiveImage;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.baseView];
        self.scale = 1;
    }
    return self;
}

- (UIView *)baseView
{
    if (!_baseView)
    {
        _baseView = [[UIView alloc] initWithFrame:self.bounds];
        _baseView.backgroundColor = [UIColor clearColor];
        _baseView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _baseView.autoresizesSubviews = YES;
        
        [_baseView addSubview:self.baseImageView];
        [_baseView addSubview:self.blurredImageView];
        [_baseView addSubview:self.tintView];
    }
    return _baseView;
}

- (UIImageView *)baseImageView
{
    if (!_baseImageView)
    {
        _baseImageView = [[UIImageView alloc] initWithFrame:self.baseView.bounds];
        _baseImageView.backgroundColor = [UIColor clearColor];
        _baseImageView.userInteractionEnabled = YES;
        _baseImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        _baseImageView.image = self.image;
    }
    return _baseImageView;
}

- (UIImageView *)blurredImageView
{
    if (!_blurredImageView)
    {
        _blurredImageView = [[UIImageView alloc] initWithFrame:self.baseView.bounds];
        _blurredImageView.backgroundColor = [UIColor clearColor];
        _blurredImageView.userInteractionEnabled = YES;
        _blurredImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        _blurredImageView.image = self.image;
        _blurredImageView.alpha = 0;
    }
    return _blurredImageView;
}

- (UIView *)tintView
{
    if (!_tintView)
    {
        _tintView = [[UIView alloc] initWithFrame:self.baseView.bounds];
        _tintView.backgroundColor = [UIColor clearColor];
        _tintView.alpha = 0;
        _tintView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _tintView;
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    
    self.baseImageView.image = image;
    
    if (self.blurSize)
    {
        self.blurredImageView.image = [image imageWithBlur:self.blurSize];
    }
}

- (void)setScale:(CGFloat)scale
{
    _scale = MIN(MAX(scale,0),1);
    
    CGRect scaledRect = CGRectMake(0, 0, scale * self.baseView.bounds.size.width, scale * self.baseView.bounds.size.height);
    
    if ((self.edgeHold & KSScaleEdgeHoldTop) == KSScaleEdgeHoldTop)
    {
        scaledRect.origin.y  = 0;
    }
    else if ((self.edgeHold & KSScaleEdgeHoldBottom) == KSScaleEdgeHoldBottom)
    {
        scaledRect.origin.y = self.baseView.bounds.size.height - scaledRect.size.height;
    }
    else
    {
        scaledRect.origin.y = (self.baseView.bounds.size.height - scaledRect.size.height)/2;
    }
    
    if ((self.edgeHold & KSScaleEdgeHoldLeft) == KSScaleEdgeHoldLeft)
    {
        scaledRect.origin.x = 0;
    }
    else if ((self.edgeHold & KSScaleEdgeHoldRight) == KSScaleEdgeHoldRight)
    {
        scaledRect.origin.x = self.baseView.bounds.size.width - scaledRect.size.width;
    }
    else
    {
        scaledRect.origin.x = (self.baseView.bounds.size.width - scaledRect.size.width)/2;
    }
    
    self.baseImageView.frame = scaledRect;
    self.blurredImageView.frame = scaledRect;
    self.tintView.frame = scaledRect;
}

- (void)setTintColor:(UIColor *)tintColor
{
    _tintColor = tintColor;
    
    self.tintView.backgroundColor = tintColor;
}

- (void)setTintOpacity:(CGFloat)tintOpacity
{
    _tintOpacity = tintOpacity;
    
    self.tintView.alpha = tintOpacity;
}

- (void)setBlurSize:(CGFloat)blurSize
{
    _blurSize = blurSize;
    
    self.blurredImageView.image = [self.image imageWithBlur:blurSize];
}

- (void)setBlurIntensity:(CGFloat)blurIntensity
{
    _blurIntensity = blurIntensity;
    
    self.blurredImageView.alpha = blurIntensity;
}

@end
