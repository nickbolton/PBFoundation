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

#define ARC4RANDOM_MAX      0x100000000
#define MIN_DIFFERENCE      0.15f

@implementation NSView (PBFoundation)

- (void)DEBUG_colorizeSelfAndSubviews {
    [self DEBUG_colorizeSelfAndSubviews:0];
}

- (void)DEBUG_colorizeSelfAndSubviews:(NSInteger)depth {

    static NSArray *initialColors = nil;

    if (initialColors == nil) {
        initialColors = @[
        [NSColor redColor],
        [NSColor yellowColor],
        [NSColor greenColor],
        [NSColor blueColor],
        [NSColor purpleColor],
        [NSColor orangeColor],
        [NSColor brownColor],
        [NSColor blackColor],
        ];
    }

    NSArray *subviews = [self subviews];

    NSColor *color;

    if (depth < initialColors.count) {
        color = [initialColors objectAtIndex:depth];
    } else {
        double r = ((double)arc4random() / ARC4RANDOM_MAX);
        double g = ((double)arc4random() / ARC4RANDOM_MAX);
        double b = ((double)arc4random() / ARC4RANDOM_MAX);
        
        color = [NSColor colorWithCalibratedRed:r green:g blue:b alpha:1.0f];
    }

    NSTextField *testField = [[NSTextField alloc] initWithFrame:self.bounds];
    testField.backgroundColor = color;
    [testField setEditable:NO];
    [self addSubview:testField positioned:NSWindowBelow relativeTo:nil];

    for (NSInteger i = 0; i < (NSInteger)[subviews count]; i++) {
        NSView *subview = [subviews objectAtIndex:i];

        [subview DEBUG_colorizeSelfAndSubviews:depth+1];
    }
}

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

    [PBAnimator
     animateWithDuration:PB_WINDOW_ANIMATION_DURATION
     timingFunction:PB_EASE_IN
     animation:^{
         [[self animator] setAlphaValue:0.0];
     }
     completion:^{

         if (middleBlock != nil) {
             middleBlock();
         }

         [PBAnimator
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
          }];
     }];
}

- (void)rotate:(CGFloat)angle
      duration:(CGFloat)duration
timingFunction:(CAMediaTimingFunction *)timingFunction
completionBlock:(void (^)(void))completionBlock {

    [PBAnimator
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
     }];
}

- (void)animateToNewFrame:(NSRect)newFrame
                 duration:(CGFloat)duration
           timingFunction:(CAMediaTimingFunction *)timingFunction
          completionBlock:(void (^)(void))completionBlock {

    [PBAnimator
     animateWithDuration:duration
     timingFunction:timingFunction
     animation:^{
         [[self animator] setFrame:newFrame];
     }
     completion:^{
         if (completionBlock != nil) {
             completionBlock();
         }
     }];
}

- (void)animateFadeIn:(CGFloat)duration
       timingFunction:(CAMediaTimingFunction *)timingFunction
      completionBlock:(void (^)(void))completionBlock {

    [self setHidden:NO];

    [PBAnimator
     animateWithDuration:duration
     timingFunction:timingFunction
     animation:^{
         [[self animator] setAlphaValue:1.0f];
     }
     completion:^{
         if (completionBlock != nil) {
             completionBlock();
         }
     }];
}

- (void)animateFadeOut:(CGFloat)duration
        timingFunction:(CAMediaTimingFunction *)timingFunction
       completionBlock:(void (^)(void))completionBlock {

    [PBAnimator
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
     }];
}

- (void)animateFadeOutIn:(CGFloat)duration
             middleBlock:(void (^)(void))middleBlock
         completionBlock:(void (^)(void))completionBlock {
    [self
     animateFadeOutIn:duration
     animations:nil
     middleBlock:middleBlock
     completionBlock:completionBlock];
}

- (void)animateFadeOutIn:(CGFloat)duration
              animations:(void (^)(void))animations
             middleBlock:(void (^)(void))middleBlock
         completionBlock:(void (^)(void))completionBlock {

    CGFloat alphaValue = self.alphaValue;

    [PBAnimator
     animateWithDuration:duration
     timingFunction:PB_EASE_IN
     animation:^{
         if (animations != nil) {
             animations();
         }
         [[self animator] setAlphaValue:0.0f];
     }
     completion:^{
         if (middleBlock != nil) {
             middleBlock();
         }

         [PBAnimator
          animateWithDuration:duration
          timingFunction:PB_EASE_OUT
          animation:^{
              [[self animator] setAlphaValue:alphaValue];
          }
          completion:^{
              if (completionBlock != nil) {
                  completionBlock();
              }
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

- (void)findFirstView:(NSView **)view ofType:(Class)clazz {

    NSAssert(view != nil, @"view parent reference is nil");
    *view = nil;
    
    NSMutableArray *views = [NSMutableArray array];
    [self findViews:&views ofType:clazz];
    if (views.count > 0) {
        *view = [views objectAtIndex:0];
    }
}

- (void)findViews:(NSMutableArray **)views ofType:(Class)clazz {

    if (*views == NULL) return;

    if ([self isKindOfClass:clazz] == YES) {
        [*views addObject:self];
    }

    for (NSView *view in self.subviews) {
        [view findViews:views ofType:clazz];
    }
}

- (id)findFirstParentOfType:(Class)clazz {

    NSView *parent = self.superview;

    if ([parent isKindOfClass:clazz]) {
        return parent;
    }

    return [parent findFirstParentOfType:clazz];
}

- (CALayer *)layerFromContents {
    CALayer *newLayer = [CALayer layer];
    newLayer.bounds = self.bounds;
    NSBitmapImageRep *bitmapRep = [self bitmapImageRepForCachingDisplayInRect:self.bounds];
    [self cacheDisplayInRect:self.bounds toBitmapImageRep:bitmapRep];
    newLayer.contents = (id)bitmapRep.CGImage;
    return newLayer;
}

- (NSPoint)locationOfMouse {
    NSPoint globalLocation = [NSEvent mouseLocation];
    NSPoint windowLocation = [self.window convertScreenToBase:globalLocation];
    return [self convertPoint:windowLocation fromView:nil];
}

- (NSImage *)pngSnapshot {
    NSBitmapImageRep *imageRep =
    [self bitmapImageRepForCachingDisplayInRect:self.bounds];
    [self cacheDisplayInRect:self.bounds toBitmapImageRep:imageRep];
    return [[NSImage alloc] initWithData:imageRep.TIFFRepresentation];
}

@end
