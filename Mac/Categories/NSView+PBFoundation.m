//
//  NSView+PBFoundation.m
//  SocialScreen
//
//  Created by Nick Bolton on 1/5/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "NSView+PBFoundation.h"
#import "PBAnimator.h"
#import <objc/runtime.h>

static char kPBViewObjectKey;

@implementation NSView (PBFoundation)
- (void)fadeInView:(NSView *)newView {

    [self fadeInView:newView
         middleBlock:nil
     completionBlock:nil];
}

- (void)fadeInView:(NSView *)newView
       middleBlock:(void (^)(void))middleBlock
   completionBlock:(void (^)(void))completionBlock {

    newView.alphaValue = 0.0f;
    [newView setHidden:NO];

    PBAnimator *animator = [[PBAnimator alloc] init];

    objc_setAssociatedObject(newView,
                             &kPBViewObjectKey,
                             animator,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    [animator
     animateWithDuration:PB_WINDOW_ANIMATION_DURATION
     timingFunction:PB_EASE_IN
     animation:^{
         [[self animator] setAlphaValue:0.0];
     }
     completion:^{

         if (middleBlock != nil) {
             middleBlock();
         }

         [animator
          animateWithDuration:PB_WINDOW_ANIMATION_DURATION
          timingFunction:PB_EASE_OUT
          animation:^{
              [[newView animator] setAlphaValue:1.0];
          }
          completion:^{
              [self setHidden:YES];

              if (completionBlock != nil) {
                  completionBlock();
              }

              objc_setAssociatedObject(newView,
                                       &kPBViewObjectKey,
                                       nil,
                                       OBJC_ASSOCIATION_RETAIN_NONATOMIC);
          }];
     }];
}

- (void)rotate:(CGFloat)angle
      duration:(CGFloat)duration
timingFunction:(CAMediaTimingFunction *)timingFunction
completionBlock:(void (^)(void))completionBlock {

    PBAnimator *animator = [[PBAnimator alloc] init];

    objc_setAssociatedObject(self,
                             &kPBViewObjectKey,
                             animator,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    [animator
     animateWithDuration:duration
     timingFunction:timingFunction
     animation:^{
         CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"frameCenterRotation"];
         animation.fromValue = [NSNumber numberWithFloat:self.frameRotation];
         animation.toValue = [NSNumber numberWithFloat:angle];
         animation.delegate = self;
         [self setAnimations:[NSDictionary dictionaryWithObjectsAndKeys:
                              animation, @"frameCenterRotation",
                              nil]];

         [[self animator] setFrameCenterRotation:angle];
     }
     completion:^{
         if (completionBlock != nil) {
             completionBlock();
         }
         [self setAnimations:nil];
         
         objc_setAssociatedObject(self,
                                  &kPBViewObjectKey,
                                  nil,
                                  OBJC_ASSOCIATION_RETAIN_NONATOMIC);
     }];
}

- (void)animateToNewFrame:(NSRect)newFrame
                 duration:(CGFloat)duration
           timingFunction:(CAMediaTimingFunction *)timingFunction
          completionBlock:(void (^)(void))completionBlock {

    PBAnimator *animator = [[PBAnimator alloc] init];

    objc_setAssociatedObject(self,
                             &kPBViewObjectKey,
                             animator,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    [animator
     animateWithDuration:duration
     timingFunction:timingFunction
     animation:^{
         [[self animator] setFrame:newFrame];
     }
     completion:^{
         if (completionBlock != nil) {
             completionBlock();
         }
         objc_setAssociatedObject(self,
                                  &kPBViewObjectKey,
                                  nil,
                                  OBJC_ASSOCIATION_RETAIN_NONATOMIC);
     }];
}

- (void)animateFadeIn:(CGFloat)duration
       timingFunction:(CAMediaTimingFunction *)timingFunction
      completionBlock:(void (^)(void))completionBlock {

    PBAnimator *animator = [[PBAnimator alloc] init];

    objc_setAssociatedObject(self,
                             &kPBViewObjectKey,
                             animator,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    [self setHidden:NO];

    [animator
     animateWithDuration:duration
     timingFunction:timingFunction
     animation:^{
         [[self animator] setAlphaValue:1.0f];
     }
     completion:^{
         if (completionBlock != nil) {
             completionBlock();
         }
         objc_setAssociatedObject(self,
                                  &kPBViewObjectKey,
                                  nil,
                                  OBJC_ASSOCIATION_RETAIN_NONATOMIC);
     }];
}

- (void)animateFadeOut:(CGFloat)duration
        timingFunction:(CAMediaTimingFunction *)timingFunction
       completionBlock:(void (^)(void))completionBlock {

    PBAnimator *animator = [[PBAnimator alloc] init];

    objc_setAssociatedObject(self,
                             &kPBViewObjectKey,
                             animator,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    [animator
     animateWithDuration:duration
     timingFunction:timingFunction
     animation:^{
         [[self animator] setAlphaValue:0.0f];
     }
     completion:^{
         [self setHidden:YES];
         if (completionBlock != nil) {
             completionBlock();
         }
         objc_setAssociatedObject(self,
                                  &kPBViewObjectKey,
                                  nil,
                                  OBJC_ASSOCIATION_RETAIN_NONATOMIC);
     }];
}

- (void)animateFadeOutIn:(CGFloat)duration
             middleBlock:(void (^)(void))middleBlock
         completionBlock:(void (^)(void))completionBlock {

    PBAnimator *animator = [[PBAnimator alloc] init];

    objc_setAssociatedObject(self,
                             &kPBViewObjectKey,
                             animator,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    [animator
     animateWithDuration:duration
     timingFunction:PB_EASE_IN
     animation:^{
         [[self animator] setAlphaValue:0.0f];
     }
     completion:^{
         if (middleBlock != nil) {
             middleBlock();
         }

         [animator
          animateWithDuration:duration
          timingFunction:PB_EASE_OUT
          animation:^{
              [[self animator] setAlphaValue:1.0f];
          }
          completion:^{
              if (completionBlock != nil) {
                  completionBlock();
              }
              objc_setAssociatedObject(self,
                                       &kPBViewObjectKey,
                                       nil,
                                       OBJC_ASSOCIATION_RETAIN_NONATOMIC);
          }];

     }];
}

- (void)pulseAnimation:(CGFloat)duration
           userContext:(id)userContext
       completionBlock:(NSViewAnimationCompletionBlock)completionBlock {

    NSNumber *previousAlphaValue = [NSNumber numberWithFloat:self.alphaValue];

    [CATransaction begin];

    [CATransaction setValue:[NSNumber numberWithFloat:duration/2] forKey:kCATransactionAnimationDuration];
    [CATransaction setCompletionBlock:^{
        [self.layer removeAllAnimations];

        [CATransaction begin];

        [CATransaction setValue:[NSNumber numberWithFloat:duration/2] forKey:kCATransactionAnimationDuration];
        [CATransaction setCompletionBlock:^{
            self.layer.compositingFilter = nil;
            [self.layer removeAllAnimations];
            completionBlock(userContext);
        }];

        CABasicAnimation* animation = [CABasicAnimation animation];
        CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];

        [filter setDefaults];
        [filter setValue:[NSNumber numberWithFloat:0.0] forKey:@"inputRadius"];
        [filter setName:@"blur"];
        [[self layer] setFilters:[NSArray arrayWithObject:filter]];

        animation.keyPath = @"filters.blur.inputRadius";
        animation.fromValue = [NSNumber numberWithFloat:MIN(self.frame.size.width, self.frame.size.height)];
        animation.toValue = [NSNumber numberWithFloat:0.0];
        animation.duration = duration/2;

        [self.layer addAnimation:animation forKey:@"blurAnimation"];

        if ([previousAlphaValue floatValue] < 1.0) {
            [[self animator] setAlphaValue:[previousAlphaValue floatValue]];
        }

        [CATransaction commit];

    }];

    CABasicAnimation* animation = [CABasicAnimation animation];

    CIFilter *blurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [blurFilter setDefaults];
    [blurFilter setValue:[NSNumber numberWithFloat:0.0] forKey:@"inputRadius"];
    [blurFilter setName:@"blur"];

    [[self layer] setFilters:[NSArray arrayWithObjects:blurFilter, nil]];

    animation.keyPath = @"filters.blur.inputRadius";
    animation.fromValue = [NSNumber numberWithFloat:0.0f];
    animation.toValue = [NSNumber numberWithFloat:MIN(self.frame.size.width, self.frame.size.height)];
    animation.duration = duration/2;

    [self.layer addAnimation:animation forKey:@"blurAnimation"];

    [[self animator] setAlphaValue:1.0];

    [CATransaction commit];

}

- (void)setAutoresizingBit:(unsigned int)bitMask toValue:(BOOL)set
{
    if (set)
    { [self setAutoresizingMask:([self autoresizingMask] | bitMask)]; }
    else
    { [self setAutoresizingMask:([self autoresizingMask] & ~bitMask)]; }
}

- (void)fixLeftEdge:(BOOL)fixed
{ [self setAutoresizingBit:NSViewMinXMargin toValue:!fixed]; }

- (void)fixRightEdge:(BOOL)fixed
{ [self setAutoresizingBit:NSViewMaxXMargin toValue:!fixed]; }

- (void)fixTopEdge:(BOOL)fixed
{ [self setAutoresizingBit:NSViewMinYMargin toValue:!fixed]; }

- (void)fixBottomEdge:(BOOL)fixed
{ [self setAutoresizingBit:NSViewMaxYMargin toValue:!fixed]; }

- (void)fixWidth:(BOOL)fixed
{ [self setAutoresizingBit:NSViewWidthSizable toValue:!fixed]; }

- (void)fixHeight:(BOOL)fixed
{ [self setAutoresizingBit:NSViewHeightSizable toValue:!fixed]; }

- (void)dumpViewHierarchy:(NSUInteger)indentLevel {

    NSMutableString *spacing = [NSMutableString string];
    for (int i=0; i<indentLevel; i++) {
        [spacing appendString:@"---"];
    }

    PBLog(@"%@(%@) visible=%d alpha=%f %@", spacing, NSStringFromRect(self.frame), !self.isHidden, self.alphaValue, self);

    for (NSView *child in self.subviews) {
        [child dumpViewHierarchy:indentLevel+1];
    }
}

- (void)findViews:(NSMutableArray **)views OfType:(Class)clazz {

    if (*views == NULL) return;

    if ([self isKindOfClass:clazz] == YES) {
        [*views addObject:self];
    }

    for (NSView *view in self.subviews) {
        [view findViews:views OfType:clazz];
    }
}

- (CALayer *)layerFromContents {
    CALayer *newLayer = [CALayer layer];
    newLayer.bounds = self.bounds;
    NSBitmapImageRep *bitmapRep = [self bitmapImageRepForCachingDisplayInRect:self.bounds];
    [self cacheDisplayInRect:self.bounds toBitmapImageRep:bitmapRep];
    newLayer.contents = (id)bitmapRep.CGImage;
    return newLayer;
}

@end
