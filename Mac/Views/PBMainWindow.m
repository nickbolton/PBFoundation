//
//  PBMainWindow.m
//  PBFoundation
//
//  Created by Nick Bolton on 1/5/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBMainWindow.h"
#import "PBMoveableView.h"

@implementation PBMainWindow

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (self != nil) {
        [self commonInit];
    }
    return self;
}

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag {
    self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag];
    if (self != nil) {
        [self commonInit];
    }
    return self;
}

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag screen:(NSScreen *)screen {
    self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag screen:screen];
    if (self != nil) {
        [self commonInit];
    }
    return self;
}

- (void)setFrame:(NSRect)frameRect display:(BOOL)displayFlag animate:(BOOL)animateFlag {
    [super setFrame:frameRect display:displayFlag animate:animateFlag];

//    NSLog(@"%s frame: %@", __PRETTY_FUNCTION__, NSStringFromRect(frameRect));
}

- (void)setFrame:(NSRect)frameRect display:(BOOL)displayFlag {
    [super setFrame:frameRect display:displayFlag];

//    NSLog(@"%s frame: %@", __PRETTY_FUNCTION__, NSStringFromRect(frameRect));
}

- (void)setFrameOrigin:(NSPoint)point {
    [super setFrameOrigin:point];

//    NSLog(@"%s origin: %@", __PRETTY_FUNCTION__, NSStringFromPoint(point));
}

- (void)commonInit {
    self.userInteractionEnabled = YES;
    _forceMouseEventsToMoveableView = NO;
}

- (BOOL)acceptsFirstMouse:(NSEvent *)event {
    return YES;
}

- (BOOL)canBecomeMainWindow {
    return YES;
}

- (BOOL)canBecomeKeyWindow {
    return YES;
}

- (BOOL)acceptsFirstResponder {
    return YES;
}

- (void)sendEvent:(NSEvent *)event {
    if (_userInteractionEnabled) {
        [super sendEvent:event];

        if (_forceMouseEventsToMoveableView && self.isMainWindow == YES) {

            PBMoveableView *view = self.contentView;

            if ([view isKindOfClass:[PBMoveableView class]]) {

                switch (event.type) {
                    case NSMouseMoved:
                        [view mouseMoved:event];
                        break;

                    case NSLeftMouseDown:
                        [view mouseDown:event];
                        break;

                    case NSLeftMouseUp:
                        [view mouseDown:event];
                        break;

                    case NSLeftMouseDragged:
                        [view mouseDragged:event];
                        break;

                    default:
                        break;
                }
            }
        }
    }
}

@end
