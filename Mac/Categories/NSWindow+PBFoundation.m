//
//  NSWindow+PBFoundation.m
//  PBFoundation
//
//  Created by Nick Bolton on 1/2/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "NSWindow+PBFoundation.h"

@implementation NSWindow (PBFoundation)

- (void)animateToNewOrigin:(NSPoint)newOrigin
                  duration:(CGFloat)duration
            timingFunction:(CAMediaTimingFunction *)timingFunction
           completionBlock:(void (^)(void))completionBlock {

    [PBAnimator
     animateWithDuration:duration
     timingFunction:timingFunction
     animation:^{
         [[self animator] setFrameOrigin:newOrigin];
     }
     completion:^{
         if (completionBlock != nil) {
             completionBlock();
         }
     }];
}

- (void)animateToNewFrame:(NSRect)newFrame
                 duration:(CGFloat)duration
           timingFunction:(CAMediaTimingFunction *)timingFunction
          completionBlock:(void (^)(void))completionBlock {
    [self
     animateToNewFrame:newFrame
     animations:nil
     duration:duration
     timingFunction:timingFunction
     completionBlock:completionBlock];
}

- (void)animateToNewFrame:(NSRect)newFrame
               animations:(void(^)(void))animations
                 duration:(CGFloat)duration
           timingFunction:(CAMediaTimingFunction *)timingFunction
          completionBlock:(void (^)(void))completionBlock {

    [PBAnimator
     animateWithDuration:duration
     timingFunction:timingFunction
     animation:^{

         if (animations != nil) {
             animations();
         }
         [[self animator] setFrame:newFrame display:YES];
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

    [self
     animateFadeOut:duration
     orderOut:NO
     timingFunction:timingFunction
     completionBlock:completionBlock];
}

- (void)animateFadeOut:(CGFloat)duration
              orderOut:(BOOL)orderOut
        timingFunction:(CAMediaTimingFunction *)timingFunction
       completionBlock:(void (^)(void))completionBlock {

    [PBAnimator
     animateWithDuration:duration
     timingFunction:timingFunction
     animation:^{
         [[self animator] setAlphaValue:0.0f];
     }
     completion:^{
         if (orderOut == YES) {
             [self orderOut:nil];
         }
         if (completionBlock != nil) {
             completionBlock();
         }
     }];
}

- (NSRect)centeredFrame {
    NSRect visibleFrame = [[NSScreen mainScreen] visibleFrame];
    NSRect windowFrame = [self frame];
    return NSMakeRect((visibleFrame.size.width - windowFrame.size.width) * 0.5,
                      (visibleFrame.size.height - windowFrame.size.height) * 0.6,
                      windowFrame.size.width, windowFrame.size.height);
}

- (void)centerWindow {
    [self setFrame:[self centeredFrame] display:YES];
}

- (BOOL)animationDebugPressed {

    NSEvent *event = [self currentEvent];

    if ((event.type & (NSKeyDown | NSKeyUp)) != 0) {
        NSInteger allControlsMask = NSCommandKeyMask | NSShiftKeyMask | NSControlKeyMask | NSAlternateKeyMask | NSFunctionKeyMask;
        return (event.modifierFlags & allControlsMask) == (NSControlKeyMask | NSAlternateKeyMask | NSFunctionKeyMask | NSCommandKeyMask);
    }

    return NO;
}

@end
