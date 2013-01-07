//
//  PBNotifyingButton.m
//  PBFoundation
//
//  Created by Nick Bolton on 1/6/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBNotifyingButton.h"

@interface PBNotifyingButton() {

    BOOL _mouseOverView;
    NSTrackingRectTag _trackingTag;
}

@end

@implementation PBNotifyingButton

- (void)awakeFromNib {
    _mouseOverView = NO;
    NSRect frame = NSMakeRect(0, 0, NSWidth(self.frame), NSHeight(self.frame));
    _trackingTag = [self addTrackingRect:NSIntegralRect(frame) owner:self userData:nil assumeInside:NO];
}

- (void)mouseDown:(NSEvent *)event {

    if (self.target != nil && _mouseDownAction != nil) {
        [self.target performSelector:_mouseDownAction withObject:self];
    }

    [super mouseDown:event];
}

- (void)mouseUp:(NSEvent *)event {

    if (self.target != nil && _mouseUpAction != nil) {
        [self.target performSelector:_mouseUpAction withObject:self];
    }

    [super mouseUp:event];
}

- (void)mouseMoved:(NSEvent *)event {

    if (self.target != nil && _mouseMovedAction != nil) {
        [self.target performSelector:_mouseMovedAction withObject:self];
    }

    [super mouseMoved:event];
}

- (void)mouseEntered:(NSEvent *)event {

    _mouseOverView = YES;

    if (self.target != nil && _mouseEnteredAction != nil) {
        [self.target performSelector:_mouseEnteredAction withObject:self];
    }

    [super mouseEntered:event];
}

- (void)mouseExited:(NSEvent *)event {

    _mouseOverView = NO;

    if (self.target != nil && _mouseExitedAction != nil) {
        [self.target performSelector:_mouseExitedAction withObject:self];
    }

    [super mouseExited:event];
}

@end
