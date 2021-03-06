//
//  KSImageAdditions.m
//  KSFramework
//
//  Created by Travis Zehren on 9/13/13.
//  Copyright (c) 2013 Kickstand Apps. All rights reserved.
//

#import "KSImageAdditions.h"
#import <Accelerate/Accelerate.h>
#import <QuartzCore/QuartzCore.h>


// Box Blur Algorithm:
//
//   Copyright (c) Jake Gunderson
//   http://indieambitions.com/idevblogaday/perform-blur-vimage-accelerate-framework-tutorial/


#pragma mark - UIImage + BoxBlur

@implementation UIImage (BoxBlur)

- (UIImage *)imageWithBlur:(CGFloat)blur
{
    if (blur == 0)
    {
        return self;
    }
    if (blur < 0.f || blur > 1.f)
    {
        blur = 0.5f;
    }
    int boxSize = (int)(blur * 20);
    boxSize = boxSize - (boxSize % 2) + 1;
    
    //Get CGImage from UIImage
    CGImageRef img = self.CGImage;
    
    //setup variables
    vImage_Buffer inBuffer, outBuffer;
    
    vImage_Error error;
    
    void *pixelBuffer;
    
    //create vImage_Buffer with data from CGImageRef
    
    //These two lines get get the data from the CGImage
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    
    //The next three lines set up the inBuffer object based on the attributes of the CGImage
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    //This sets the pointer to the data for the inBuffer object
    inBuffer.data = (void *)CFDataGetBytePtr(inBitmapData);
    
    //create vImage_Buffer for output
    
    //allocate a buffer for the output image and check if it exists in the next three lines
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    
    if(pixelBuffer == NULL)
    {
        NSLog(@"No pixelbuffer");
    }
    
    //set up the output buffer object based on the same dimensions as the input image
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    //perform convolution - this is the call for our type of data
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    
    //check for an error in the call to perform the convolution
    if (error)
    {
        NSLog(@"error from convolution %ld", error);
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef ctx = CGBitmapContextCreate(outBuffer.data,
                                             outBuffer.width,
                                             outBuffer.height,
                                             8,
                                             outBuffer.rowBytes,
                                             colorSpace,
                                             (CGBitmapInfo)kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipFirst);
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    
    //clean up
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    
    free(pixelBuffer);
    CFRelease(inBitmapData);
    
    CGImageRelease(imageRef);
    
    return returnImage;
}

@end


#pragma mark - UIView + Screenshot

@implementation UIView (Screenshot)

- (UIImage *)screenshot
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size,self.opaque,[[UIScreen mainScreen] scale]);
    if ([self respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
        [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:NO];
    }
    else {
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    }
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end


#pragma mark - UIScrollView + Screenshot

@implementation UIScrollView (Screenshot)

-(UIImage *)screenshot
{
    // Freeze scrollview
    CGPoint offset = self.contentOffset;
    [self setContentOffset:offset animated:NO];

    CGSize pageSize = self.bounds.size;
    UIGraphicsBeginImageContextWithOptions(pageSize,self.opaque,[[UIScreen mainScreen] scale]);

    CGContextRef resizedContext = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(resizedContext, -self.contentOffset.x, -self.contentOffset.y);
    if ([self respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
        [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:NO];
    }
    else {
        [self.layer renderInContext:resizedContext];
    }
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return image;
}

@end
