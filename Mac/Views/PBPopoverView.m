//
//  PBPopoverView.m
//  PBNavigationViewController
//
//  Created by Nick Bolton on 6/9/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBPopoverView.h"
#import <QuartzCore/QuartzCore.h>

@interface PBPopoverView()

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
    _beakPosition = -1.0f;
}

- (void)drawRect:(NSRect)dirtyRect {

    [super drawRect:dirtyRect];

    NSGraphicsContext *currentContext = [NSGraphicsContext currentContext];
    [NSGraphicsContext saveGraphicsState];

    NSDrawNinePartImage(dirtyRect,
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

    if (_beakPosition >= 0.0f) {
        NSRect beakFrame;

        if (_flipped) {

            beakFrame = NSMakeRect(_beakPosition,
                                   0.0f,
                                   _beakImage.size.width,
                                   _beakImage.size.height);
        } else {

            beakFrame = NSMakeRect(_beakPosition,
                                   NSHeight(dirtyRect) - _beakImage.size.height,
                                   _beakImage.size.width,
                                   _beakImage.size.height);
        }

        // clear beak rect so it doesn't over shadow

//        [[NSColor clearColor] setFill];
//        NSRectFill(beakFrame);

        NSRect srcRect = NSZeroRect;
        srcRect.size = _beakImage.size;

        [_beakImage
         drawInRect:beakFrame
         fromRect:srcRect
         operation:NSCompositeCopy
         fraction:1.0f];
    }

    [currentContext restoreGraphicsState];

}

@end
