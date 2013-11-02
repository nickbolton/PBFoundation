//
//  PBBezierView.m
//  BerlinDecision
//
//  Created by Nick Bolton on 7/13/13.
//  Copyright (c) 2013 MutualMobile. All rights reserved.
//

#import "PBBezierView.h"

@implementation PBBezierView

- (void)fillBackgroundPath {
    if (self.pathFillColor != nil) {
        [self.pathFillColor setFill];
        [self.bezierPath fill];
    }
}

- (void)strokeBackgroundPath {
    if (self.pathStrokeColor != nil) {
        [self.pathStrokeColor setStroke];
        [self.bezierPath stroke];
    }
}

- (void)applyBlurFromReferenceViewInRect:(CGRect)rect {
    [_blurImage drawInRect:rect];
}

- (void)drawRect:(CGRect)rect {

    [self fillBackgroundPath];
    [self strokeBackgroundPath];
    [self applyBlurFromReferenceViewInRect:rect];
    [super drawRect:rect];
}

@end
