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
}

- (void)mouseDragged:(NSEvent *)event {
    
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

    [_delegate moveableViewMoved:self];
}

@end
