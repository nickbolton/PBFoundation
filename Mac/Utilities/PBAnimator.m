//
//  PBAnimator.m
//
//  Created by nbolton on 2/19/12.
//  Copyright (c) 2012 Pixelbleed LLC. All rights reserved.
//

#import "PBAnimator.h"
#import <QuartzCore/QuartzCore.h>

@interface PBAnimator ()
@end

@implementation PBAnimator

+ (void)animateWithDuration:(NSTimeInterval)duration
             timingFunction:(CAMediaTimingFunction *)timingFunction
                  animation:(void (^)(void))animationBlock {
    [self animateWithDuration:duration
               timingFunction:timingFunction
                    animation:animationBlock
                   completion:nil];
}

+ (void)animateWithDuration:(NSTimeInterval)duration
             timingFunction:(CAMediaTimingFunction *)timingFunction
                  animation:(void (^)(void))animationBlock
                 completion:(void (^)(void))completionBlock {
    
    [NSAnimationContext beginGrouping];
    NSAnimationContext *currentContext = [NSAnimationContext currentContext];

    currentContext.duration = duration;
    currentContext.timingFunction = timingFunction;
    currentContext.completionHandler = completionBlock;

    animationBlock();
    [NSAnimationContext endGrouping];
}

+ (void)runEndBlock:(void (^)(void))completionBlock {
    completionBlock();
}

@end
