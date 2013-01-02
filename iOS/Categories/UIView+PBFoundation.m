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

@end
