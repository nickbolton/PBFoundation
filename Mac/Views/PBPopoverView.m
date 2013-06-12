//
//  PBPopoverView.m
//  PBNavigationViewController
//
//  Created by Nick Bolton on 6/9/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBPopoverView.h"
#import <QuartzCore/QuartzCore.h>

@interface PBPopoverView() {
}

@end

@implementation PBPopoverView

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
}

- (CGFloat)beakPosition {

    static CGFloat padding = 25.0f;

    NSRect referenceFrame = NSZeroRect;
    referenceFrame.origin = _beakReferencePoint;

    NSRect referenceFrameInWindowSpace =
    [self.window convertRectFromScreen:referenceFrame];

    NSPoint referencePointInViewSpace =
    [self convertPointFromBacking:referenceFrameInWindowSpace.origin];

    CGFloat distanceToRightSize = NSWidth(self.frame) - referencePointInViewSpace.x;

    CGFloat position = NSWidth(self.frame) - distanceToRightSize - (_beakImage.size.width / 2.0f);

    position = MIN(position, NSWidth(self.frame) - _beakImage.size.width - padding);
    position = MAX(position, padding);

    return position;
}

- (void)drawRect:(NSRect)dirtyRect {

    [super drawRect:dirtyRect];

    NSDrawNinePartImage(self.bounds,
                        _topLeftImage,
                        _topImage,
                        _topRightImage,
                        _leftImage,
                        _centerImage,
                        _rightImage,
                        _bottomLeftImage,
                        _bottomImage,
                        _bottomRightImage,
                        NSCompositeSourceIn,
                        1.0f,
                        _flipped);

    CGFloat beakPosition = [self beakPosition];
    
    if (beakPosition >= 0.0f && _beakVisible) {
        NSRect beakFrame;

        if (_flipped) {

            beakFrame = NSMakeRect(beakPosition,
                                   0.0f,
                                   _beakImage.size.width,
                                   _beakImage.size.height);
        } else {

            beakFrame = NSMakeRect(beakPosition,
                                   NSHeight(self.bounds) - _beakImage.size.height,
                                   _beakImage.size.width,
                                   _beakImage.size.height);
        }

        // clear beak rect so it doesn't over shadow

        NSRect srcRect = NSZeroRect;
        srcRect.size = _beakImage.size;

        [_beakImage
         drawInRect:beakFrame
         fromRect:srcRect
         operation:NSCompositeCopy
         fraction:1.0f];
    }

}

@end
