#KSImageAdditions
__*Part of KSFramework*__

This controller adds several useful categories to add image processing functionality to UIView, UIScrollView, and UIImage.

This controller uses a box blurring method as shared by Jake Gunderson on his [blog](http://indieambitions.com/idevblogaday/perform-blur-vimage-accelerate-framework-tutorial/).

##Features

- Create a UIImage "screenshot" from any UIView or UIScrollView.
- Add a box blur to any UIImage.


##Installation

####CocoaPods
Add the following to your Podfile.
`pod 'KSFramework/KSImageAdditions', '~> 1.0'`

####Manually
Add the `KSImageAdditions` folder to your project. Add required Apple frameworks to your project. 

`KSImageAdditions` uses ARC. If you have a project that doesn't use ARC, just add the `-fobjc-arc` compiler flag to the `KSImageAdditions` files.

######Required Frameworks
- `Accelerate.framework`
- `QuartzCore.framework`

##Categories

####UIImage+BoxBlur

This category adds a method that returns a blurred image of desired intensity from any UIImage.

```objective-c
@interface UIImage (BoxBlur)

// Blur the current image with a box blur algorithm
// Accepts blur intensity values from 0 to 1
- (UIImage*)imageWithBlur:(CGFloat)blur;

@end
```

####UIView+Screenshot

This category adds a  method that returns a UIImage screenshot from any UIView.

```objective-c
@interface UIView (Screenshot)

// Create UIImage screenshot from any view
- (UIImage *)screenshot;

@end
```

####UIScrollView+Screenshot

This category adds a method that returns a UIImage screenshot from any UIScrollView.

```objective-c
@interface UIScrollView (Screenshot)

// Create UIImage screenshot from any scrollview
- (UIImage *)screenshot;

@end
```

##Contact

developer@kickstandapps.com<br />
http://kickstandapps.com<br />
http://twitter.com/kickstandapps
