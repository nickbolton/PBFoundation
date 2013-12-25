//
//  UIView+PBFoundation.m
//  PBFoundation
//
//  Created by Nick Bolton on 4/1/12.
//  Copyright (c) 2012 Pixelbleed LLC. All rights reserved.
//

#import "UIView+PBFoundation.h"
#import <QuartzCore/QuartzCore.h>

#define ARC4RANDOM_MAX      0x100000000
#define MIN_DIFFERENCE      0.15f

@implementation UIView (PBFoundation)

- (void)removeAllSubviews {
    NSArray *subviews = [self.subviews copy];
    for (UIView *view in subviews) {
        [view removeFromSuperview];
    }
}

- (void)disableGesturesOfType:(Class)gestureType recurse:(BOOL)recurse {

    for (UIGestureRecognizer *gesture in self.gestureRecognizers) {
        if ([gesture isKindOfClass:gestureType]) {
            gesture.enabled = NO;
            [self removeGestureRecognizer:gesture];
        }
    }

    if (recurse) {
        for (UIView *childView in self.subviews) {
            [childView disableGesturesOfType:gestureType recurse:recurse];
        }
    }
}

- (void)DEBUG_colorizeSelfAndSubviews {
    NSArray *subviews = [self subviews];
    
    double r = ((double)arc4random() / ARC4RANDOM_MAX);
    double g = ((double)arc4random() / ARC4RANDOM_MAX);
    double b = ((double)arc4random() / ARC4RANDOM_MAX);
    
    UIColor *color = [UIColor colorWithRed:r green:g blue:b alpha:1.0];
    
    [self setBackgroundColor:color];
    
    for (int i = 0; i < (NSInteger)[subviews count]; i++) {
        UIView *subview = [subviews objectAtIndex:i];
        
        [subview DEBUG_colorizeSelfAndSubviews];
    }
}

- (void)fadeOutInWithDuration:(CGFloat)duration andBlock:(void(^)(void))block {
    
    [UIView animateWithDuration:duration/2.0f
                     animations:^{
                         self.alpha = 0.0f;
                     }
                     completion:^(BOOL finished) {
                        
                         if (block != nil) {
                             block();
                         }
                         
                         [UIView animateWithDuration:duration/2.0f
                                          animations:^{
                                              self.alpha = 1.0f;
                                          }
                          ];
                     }
     ];
}

- (UIImage *)snapshot {
    UIGraphicsBeginImageContext(self.bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [self.layer renderInContext:context];
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();    
    return image;
}

- (void)addFadingMaskWithStartPoint:(CGPoint)startPoint
                           endPoint:(CGPoint)endPoint
                             colors:(NSArray *)colors {
    
    CAGradientLayer *fadeMaskLayer = [CAGradientLayer layer];
    fadeMaskLayer.frame = self.bounds;
    fadeMaskLayer.colors = colors;
    fadeMaskLayer.startPoint = startPoint;
    fadeMaskLayer.endPoint = endPoint;
    self.layer.mask = fadeMaskLayer;
}

- (void)addFadingMaskWithEdgeInsets:(UIEdgeInsets)edgeInsets {

    CGFloat fadePercentage;

    if (edgeInsets.bottom > 0.0f && edgeInsets.bottom < CGRectGetHeight(self.bounds)) {
        fadePercentage = (CGRectGetHeight(self.bounds) - edgeInsets.bottom) / CGRectGetHeight(self.bounds);

        [self
         addFadingMaskWithStartPoint:CGPointMake(0.5f, fadePercentage)
         endPoint:CGPointMake(0.5f, 1.0f)
         colors:@[(id)[UIColor whiteColor].CGColor, (id)[UIColor clearColor].CGColor]];
    }

    if (edgeInsets.top > 0.0f && edgeInsets.top < CGRectGetHeight(self.bounds)) {

        fadePercentage = edgeInsets.top / CGRectGetHeight(self.bounds);

        [self
         addFadingMaskWithStartPoint:CGPointMake(0.5f, 0.0f)
         endPoint:CGPointMake(0.5f, fadePercentage)
         colors:@[(id)[UIColor clearColor].CGColor, (id)[UIColor whiteColor].CGColor]];
    }

    if (edgeInsets.right > 0.0f && edgeInsets.right < CGRectGetWidth(self.bounds)) {
        fadePercentage = (CGRectGetWidth(self.bounds) - edgeInsets.right) / CGRectGetWidth(self.bounds);

        [self
         addFadingMaskWithStartPoint:CGPointMake(fadePercentage, 0.5f)
         endPoint:CGPointMake(1.0f, 0.5f)
         colors:@[(id)[UIColor whiteColor].CGColor, (id)[UIColor clearColor].CGColor]];
    }

    if (edgeInsets.left > 0.0f && edgeInsets.left < CGRectGetWidth(self.bounds)) {

        fadePercentage = edgeInsets.left / CGRectGetWidth(self.bounds);

        [self
         addFadingMaskWithStartPoint:CGPointMake(0.0f, 0.5f)
         endPoint:CGPointMake(fadePercentage, 0.5f)
         colors:@[(id)[UIColor clearColor].CGColor, (id)[UIColor whiteColor].CGColor]];
    }

}

- (void)startWiggleAnimationWithRotation:(CGFloat)rotation
                             translation:(CGPoint)translation {

    CAAnimation *rotationAnimation = [self wiggleRotationAnimation:rotation];
    [self.layer addAnimation:rotationAnimation forKey:@"wiggleRotation"];

    CAAnimation *translationXAnimation = [self wiggleTranslationXAnimation:translation.x];
    [self.layer addAnimation:translationXAnimation forKey:@"wiggleTranslationX"];

    CAAnimation *translationYAnimation = [self wiggleTranslationYAnimation:translation.y];
    [self.layer addAnimation:translationYAnimation forKey:@"wiggleTranslationY"];
}

- (void)stopWiggleAnimation {
    [self.layer removeAnimationForKey:@"wiggleRotation"];
    [self.layer removeAnimationForKey:@"wiggleTranslationX"];
    [self.layer removeAnimationForKey:@"wiggleTranslationY"];
}

- (CAAnimation *)wiggleRotationAnimation:(CGFloat)rotation {
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation"];
    anim.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:-rotation],
                   [NSNumber numberWithFloat:rotation],
                   nil];
    anim.duration = 0.1f;
    anim.autoreverses = YES;
    anim.repeatCount = HUGE_VALF;
    return anim;
}

- (CAAnimation *)wiggleTranslationXAnimation:(CGFloat)x {
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.x"];
    anim.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:-x],
                   [NSNumber numberWithFloat:x],
                   nil];
    anim.duration = 0.05f;
    anim.autoreverses = YES;
    anim.repeatCount = HUGE_VALF;
    anim.additive = YES;
    return anim;
}

- (CAAnimation *)wiggleTranslationYAnimation:(CGFloat)y {
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.y"];
    anim.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:-y],
                   [NSNumber numberWithFloat:y],
                   nil];
    anim.duration = 0.08f;
    anim.autoreverses = YES;
    anim.repeatCount = HUGE_VALF;
    anim.additive = YES;
    return anim;
}

- (UIImage *)pb_screenshot {
    return
    [self
     pb_screenshotInBounds:self.bounds
     afterScreenUpdates:NO];
}

- (UIImage *)pb_screenshotInBounds:(CGRect)bounds afterScreenUpdates:(BOOL)afterScreenUpdates {
    UIGraphicsBeginImageContext(bounds.size);
    if([self respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]){
        [self drawViewHierarchyInRect:bounds afterScreenUpdates:afterScreenUpdates];
    }
    else{
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    }
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData *imageData = UIImageJPEGRepresentation(image, 0.75);
    image = [UIImage imageWithData:imageData];
    return image;
}

@end
