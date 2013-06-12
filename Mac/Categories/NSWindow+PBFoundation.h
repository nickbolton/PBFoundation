//
//  NSWindow+PBFoundation.h
//  PBFoundation
//
//  Created by Nick Bolton on 1/2/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSWindow (PBFoundation)

- (void)animateToNewFrame:(NSRect)newFrame
                 duration:(CGFloat)duration
           timingFunction:(CAMediaTimingFunction *)timingFunction
          completionBlock:(void (^)(void))completionBlock;

- (void)animateToNewFrame:(NSRect)newFrame
               animations:(void(^)(void))animations
                 duration:(CGFloat)duration
           timingFunction:(CAMediaTimingFunction *)timingFunction
          completionBlock:(void (^)(void))completionBlock;

- (void)animateToNewOrigin:(NSPoint)newOrigin
                  duration:(CGFloat)duration
            timingFunction:(CAMediaTimingFunction *)timingFunction
           completionBlock:(void (^)(void))completionBlock;

- (void)animateFadeIn:(CGFloat)duration
       timingFunction:(CAMediaTimingFunction *)timingFunction
      completionBlock:(void (^)(void))completionBlock;

- (void)animateFadeOut:(CGFloat)duration
        timingFunction:(CAMediaTimingFunction *)timingFunction
       completionBlock:(void (^)(void))completionBlock;

- (void)animateFadeOut:(CGFloat)duration
              orderOut:(BOOL)orderOut
        timingFunction:(CAMediaTimingFunction *)timingFunction
       completionBlock:(void (^)(void))completionBlock;

- (void)centerWindow;
- (NSRect)centeredFrame;

- (BOOL)animationDebugPressed;

@end
