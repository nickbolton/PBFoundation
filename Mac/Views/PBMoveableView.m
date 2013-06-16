//
//  PBMoveableView.m
//  timecop
//
//  Created by Nick Bolton on 11/23/11.
//  Copyright (c) 2011 Pixelbleed LLC. All rights reserved.
//

#import "PBMoveableView.h"

@interface PBMoveableView() {

    BOOL _lookingForMouseUp;
}

@property (nonatomic) NSPoint mouseDownMouseLocation;
@property (nonatomic) NSPoint mouseDownWindowLocation;
@property (nonatomic, getter = isDragging, readwrite) BOOL dragging;
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

    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(windowDidMove:)
     name:NSWindowDidMoveNotification
     object:self.window];
}

- (void)setEnabled:(BOOL)enabled {
    _enabled = enabled;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)windowDidMove:(NSNotification *)notification {
    [_delegate moveableViewMoved:self];
}

- (void)mouseDown:(NSEvent *)event {

    if (_enabled) {
        self.dragging = YES;
        _mouseDownWindowLocation = self.window.frame.origin;
        _mouseDownMouseLocation = [NSEvent mouseLocation];

        [_delegate moveableViewMouseDown:self];
    }
}

- (void)mouseUp:(NSEvent *)event {

    self.dragging = NO;
    if (_enabled) {
        [_delegate moveableViewMouseUp:self];

        if ([self.window isKindOfClass:[PBMainWindow class]]) {
            ((PBMainWindow *)self.window).forceMouseEventsToMoveableView = NO;
        }
    }
}

- (void)lookingForMouseUp {

    if (_lookingForMouseUp) {

        double delayInSeconds = .1f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){

            if ([NSEvent pressedMouseButtons] == 0) {
                _lookingForMouseUp = NO;
                [self mouseUp:nil];
            } else {
                [self lookingForMouseUp];
            }
        });
    }
}

- (void)mouseDragged:(NSEvent *)event {
    
    if (_enabled) {

        if (_dragging == NO) {
            [self mouseDown:nil];
            _lookingForMouseUp = YES;
            [self lookingForMouseUp];
        }

        NSPoint currentLocation;
        NSPoint newOrigin;

        NSScreen *screen = self.window.screen;

        NSRect screenFrame = [screen visibleFrame];
        NSRect windowFrame = [self.window frame];

        currentLocation = [NSEvent mouseLocation];

        newOrigin = _mouseDownWindowLocation;
        newOrigin.x += currentLocation.x - _mouseDownMouseLocation.x;
        newOrigin.y += currentLocation.y - _mouseDownMouseLocation.y;

        CGFloat minY = _screenInsets.bottom;
        CGFloat maxY = NSMaxY(screenFrame) - _screenInsets.top;

        if (screen == [NSScreen screens][0]) {

            if ((newOrigin.y+windowFrame.size.height) > maxY) {
                newOrigin.y = maxY - windowFrame.size.height;
            }

            // guard against going under the dock
            if (newOrigin.y < minY) {
                newOrigin.y = minY;
            }
        }

        //go ahead and move the window to the new location
        [self.window setFrameOrigin:newOrigin];

        [self setNeedsDisplay:YES];        
    }
}

@end
