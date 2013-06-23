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
    
    if ([_clickableViewDelegate respondsToSelector:@selector(viewMousedDown:atPoint:)]) {
        [_clickableViewDelegate viewMousedDown:self atPoint:event.locationInWindow];
    }
}

- (void)mouseUp:(NSEvent *)event {
    [super mouseUp:event];

    if ([_clickableViewDelegate respondsToSelector:@selector(viewMousedUp:atPoint:)]) {
        [_clickableViewDelegate viewMousedUp:self atPoint:event.locationInWindow];
    }
}

- (void)mouseDragged:(NSEvent *)event {
    [super mouseDragged:event];

    if ([_clickableViewDelegate respondsToSelector:@selector(viewMouseDragged:atPoint:)]) {
        [_clickableViewDelegate viewMouseDragged:self atPoint:event.locationInWindow];
    }
}

@end
