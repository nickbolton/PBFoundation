//
//  UIBezierView.m
//  PBFoundation
//
//  Created by Nick Bolton on 11/26/12.
//  Copyright (c) 2012 Pixelbleed LLC. All rights reserved.
//

#import "UIBezierView.h"

@implementation UIBezierView

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
