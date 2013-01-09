//
//  PBAnimator.h
//
//  Created by nbolton on 2/19/12.
//  Copyright (c) 2012 Pixelbleed LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CAMediaTimingFunction;

@interface PBAnimator : NSObject

+ (void)animateWithDuration:(NSTimeInterval)duration
             timingFunction:(CAMediaTimingFunction *)timingFunction
                  animation:(void (^)(void))animationBlock;

+ (void)animateWithDuration:(NSTimeInterval)duration
             timingFunction:(CAMediaTimingFunction *)timingFunction
                  animation:(void (^)(void))animationBlock
                 completion:(void (^)(void))completionBlock;

@end
