//
//  PBPopoverView.m
//  PBNavigationViewController
//
//  Created by Nick Bolton on 6/9/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBPopoverView.h"
#import <QuartzCore/QuartzCore.h>
#import "PBRunningAverageValue.h"

static NSTimeInterval const kPBPopoverAnimationDuration = .15f;

@interface PBPopoverView() {

    CGFloat _beakTargetPosition;
    CGFloat _beakCurrentPosition;
}

@property (nonatomic, strong) PBRunningAverageValue *beakPosition;

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
    [super commonInit];
    self.beakPosition = [[PBRunningAverageValue alloc] init];
    _beakPosition.queueSize = 1;

}

- (void)setSmoothingBeakMovement:(BOOL)smoothingBeakMovement {
    _smoothingBeakMovement = smoothingBeakMovement;

    if (_smoothingBeakMovement) {
        _beakPosition.queueSize = 10;
    } else {
        _beakPosition.queueSize = 1;
    }

    [self resetBeak];
}

- (void)resetBeak {
    [self.beakPosition clearRunningValues];
    [self setNeedsDisplay:YES];

}

- (CGFloat)calculateBeakPosition {

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
                        NSCompositeSourceAtop,
                        1.0f,
                        _flipped);

    self.beakPosition.value = [self calculateBeakPosition];

    if (_beakPosition.value >= 0.0f && _beakVisible) {
        NSRect beakFrame;

        CGFloat xPos;

        xPos = self.beakPosition.value;

        _beakCurrentPosition = xPos;

        if (_flipped) {

            beakFrame = NSMakeRect(xPos,
                                   0.0f,
                                   _beakImage.size.width,
                                   _beakImage.size.height);
        } else {

            beakFrame = NSMakeRect(xPos,
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

    [super drawRect:dirtyRect];
}

@end
