//
//  PBMoveableView.m
//  timecop
//
//  Created by Nick Bolton on 11/23/11.
//  Copyright (c) 2011 Pixelbleed LLC. All rights reserved.
//

#import "PBMoveableView.h"

@interface PBMoveableView()
@property (nonatomic) NSPoint mouseDownMouseLocation;
@property (nonatomic) NSPoint mouseDownWindowLocation;
@end

@implementation PBMoveableView

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    _enabled = YES;
}

- (BOOL)acceptsFirstMouse:(NSEvent *)event {
    return YES;
}

- (BOOL)acceptsFirstResponder {
    return YES;
}

- (void)mouseDown:(NSEvent *)event {
    [super mouseDown:event];
    _mouseDownWindowLocation = self.window.frame.origin;
    _mouseDownMouseLocation = [NSEvent mouseLocation];

    [_delegate moveableViewMouseDown:self];
}

- (void)mouseUp:(NSEvent *)event {
    [super mouseUp:event];

    [_delegate moveableViewMouseUp:self];
}

- (void)mouseDragged:(NSEvent *)event {

    if (_enabled) {
        NSPoint currentLocation;
        NSPoint newOrigin;

        NSRect screenFrame = [self.window.screen visibleFrame];
        NSRect windowFrame = [self.window frame];

        currentLocation = [NSEvent mouseLocation];

        newOrigin = _mouseDownWindowLocation;
        newOrigin.x += currentLocation.x - _mouseDownMouseLocation.x;
        newOrigin.y += currentLocation.y - _mouseDownMouseLocation.y;

        CGFloat minY = NSMinY(screenFrame);
        CGFloat maxY = NSMaxY(screenFrame);

        // Don't let window get dragged up under the menu bar
        if ((newOrigin.y+windowFrame.size.height) > maxY) {
            newOrigin.y = maxY - windowFrame.size.height;
        } else if (newOrigin.y < minY) {
            newOrigin.y = minY;
        }

        //go ahead and move the window to the new location
        [self.window setFrameOrigin:newOrigin];

        [self setNeedsDisplay:YES];
        
        [_delegate moveableViewMoved:self];
    }
}

@end
