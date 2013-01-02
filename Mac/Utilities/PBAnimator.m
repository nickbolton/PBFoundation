//
//  PBAnimator.m
//
//  Created by nbolton on 2/19/12.
//  Copyright (c) 2012 Pixelbleed LLC. All rights reserved.
//

#import "PBAnimator.h"
#import <QuartzCore/QuartzCore.h>

@interface PBAnimator ()
- (void)runEndBlock:(void (^)(void))completionBlock;
@end

@implementation PBAnimator

- (void)animateWithDuration:(NSTimeInterval)duration
             timingFunction:(CAMediaTimingFunction *)timingFunction
                  animation:(void (^)(void))animationBlock {
    [self animateWithDuration:duration
               timingFunction:timingFunction
                    animation:animationBlock
                   completion:nil];
}

- (void)animateWithDuration:(NSTimeInterval)duration
             timingFunction:(CAMediaTimingFunction *)timingFunction
                  animation:(void (^)(void))animationBlock
                 completion:(void (^)(void))completionBlock {
    
    [NSAnimationContext beginGrouping];
    NSAnimationContext *currentContext = [NSAnimationContext currentContext];

    BOOL hasCompletionBlockSupport = [currentContext respondsToSelector:@selector(setCompletionHandler:)];
    
    [currentContext setDuration:duration];
    
    if ([currentContext respondsToSelector:@selector(setTimingFunction:)] == YES) {
        [currentContext performSelector:@selector(setTimingFunction:) withObject:timingFunction];
    }
    
    if (hasCompletionBlockSupport == YES && completionBlock != nil) {
        [currentContext performSelector:@selector(setCompletionHandler:) withObject:completionBlock]; 
    }
    
    animationBlock();
    [NSAnimationContext endGrouping];
    
    if(completionBlock != nil && hasCompletionBlockSupport == NO) {
        id completionBlockCopy = [completionBlock copy];
        [self performSelector:@selector(runEndBlock:) withObject:completionBlockCopy afterDelay:duration + .05f];
    }
}

- (void)runEndBlock:(void (^)(void))completionBlock {
    completionBlock();
}

@end
