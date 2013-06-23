//
//  PBClickableView.m
//  MiniMeasure
//
//  Created by Nick Bolton on 6/8/12.
//  Copyright (c) 2012 Pixelbleed LLC. All rights reserved.
//

#import "PBClickableView.h"

@implementation PBClickableView

- (void)mouseDown:(NSEvent *)event {
    [super mouseDown:event];
    
    if ([self.delegate respondsToSelector:@selector(viewMousedDown:atPoint:)]) {
        [(id<PBClickableViewDelegate>)self.delegate
         viewMousedDown:self atPoint:event.locationInWindow];
    }
}

- (void)mouseUp:(NSEvent *)event {
    [super mouseUp:event];

    if ([self.delegate respondsToSelector:@selector(viewMousedUp:atPoint:)]) {
        [(id<PBClickableViewDelegate>)self.delegate
         viewMousedUp:self atPoint:event.locationInWindow];
    }
}

- (void)mouseDragged:(NSEvent *)event {
    [super mouseDragged:event];

    if ([self.delegate respondsToSelector:@selector(viewMouseDragged:atPoint:)]) {
        [(id<PBClickableViewDelegate>)self.delegate
         viewMouseDragged:self atPoint:event.locationInWindow];
    }
}

@end
