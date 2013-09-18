#KSViewShadow
__*Part of KSFramework*__

This controller adds a configurable shadow to any view that is passed to it.

Some code for this control was forked from the [MFSideMenu](https://github.com/mikefrederick/MFSideMenu) project by Michael Frederick.

##Features

- Works with any view
- Nice set of configuration options
- Lightweight, simple and readable code.


##Installation

####CocoaPods
Add `pod '****'` to your Podfile.

####Manually
Add the `KSViewShadow` folder to your project. Add required Apple frameworks to your project. 

`KSViewShadow` uses ARC. If you have a project that doesn't use ARC, just add the `-fobjc-arc` compiler flag to the `KSViewShadow` files.

######Required Frameworks
- `QuartzCore.framework`

##Usage

####Basic Setup

In your view controller:<br />
```objective-c
#import "KSViewShadow.h"

KSViewShadow *shadow = [KSViewShadow shadowWithColor:[UIColor blackColor]
				     radius:10.0f
				     opacity:0.75f];
shadow.shadowedView = self.view;

// or…

// Uses default values listed in option above
KSViewShadow *shadow = [KSViewShadow shadowWithView:self.view];
```

####Configurable Options

```objective-c
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
```

####Refreshing the Shadow

Refresh shadow should be called after any changes to the view being shadowed.

```objective-c
- (void)refresh;
```

####Orientation Changes

Call these methods in when orientation will change to prepare shadow for animated transition.

```objective-c
- (void)shadowedViewWillRotate;

- (void)shadowedViewDidRotate;
```

##Contact

developer@kickstandapps.com<br />
http://kickstandapps.com<br />
http://twitter.com/kickstandapps
