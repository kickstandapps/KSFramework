#KSInactiveImageView
__*Part of KSFramework*__

This control acts as a UIImageView, but with the added ability to make an image appear inactive through the use of tinting, scaling, and blurring.

One potential use is locating the KSInactiveImageView in place of a view and passing in a screenshot. The screenshot can then be manipulated to make view appear inactive.

##Features

- Accepts any image just like a UIImageView
- Ability to make image appear inactive through various methods.
  - Scale image down, while holding any desired edge.
  - Blur image with desired blur size and intensity.
  - Overlay image with tint of desired color and opacity.

##Installation

####CocoaPods
Add the following to your Podfile.
`pod 'KSFramework/KSInactiveImageView', '~> 1.0'`

####Manually
Add the `KSInactiveImageView` folder to your project. Add required `KSFramework` folders to your project. Add required Apple frameworks to your project. 

`KSInactiveImageView` uses ARC. If you have a project that doesn't use ARC, just add the `-fobjc-arc` compiler flag to the `KSInactiveImageView` files.

######Required KSFramework Folders
- `KSImageAdditions`

######Required Frameworks
- `Accelerate.framework`
- `QuartzCore.framework`

##Usage

####Basic Setup

Either initialize with an image, or send an image to an already initialized instance.
```objective-c
// Initializing
- (id)initWithImage:(UIImage *)image;

// Image Data
@property (nonatomic, strong) UIImage *image;
```

####Scaling

```objective-c
// Set scale of image (from 0 to 1*)
// and edge to hold to (default -> none)
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, assign) KSScaleEdgeHold edgeHold;

// KSScaleEdgeHold options
KSScaleEdgeHoldNone    // Image is scaled while centered in view.

KSScaleEdgeHoldTop     // Image is scaled while holding to either
KSScaleEdgeHoldBottom  // the top edge or bottom edge.

KSScaleEdgeHoldLeft    // Image is scaled while holding to either
KSScaleEdgeHoldRight   // the left edge or right edge.
```

####Blurring

```objective-c
// Set size of box blur (from 0* to 1)
@property (nonatomic, assign) CGFloat blurSize;

// Set blur intensity (from 0* to 1)
// This property should be used to gradually increase or decrease blurring 
// as it is not as graphically intensive as changing blurSize.
@property (nonatomic, assign) CGFloat blurIntensity;
```

####Tinted Overlay

```objective-c
// Set overlay tint color (default -> clear)
// and opacity (from 0* to 1)
@property (nonatomic, strong) UIColor *tintColor;
@property (nonatomic, assign) CGFloat tintOpacity;
```

##Contact

developer@kickstandapps.com<br />
http://kickstandapps.com<br />
http://twitter.com/kickstandapps
