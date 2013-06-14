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

static CVReturn PBPopoverViewDisplayLinkCallback(CVDisplayLinkRef displayLink,
                                                 const CVTimeStamp* nowTimestamp,
                                                 const CVTimeStamp* outputTime,
                                                 CVOptionFlags flagsIn,
                                                 CVOptionFlags* flagsOut,
                                                 void* displayLinkContext);

static NSTimeInterval const kPBPopoverAnimationDuration = .15f;

static PBPopoverView *_PBPopoverViewInstance = nil;

@interface PBPopoverView() {

    CVDisplayLinkRef _displayLink;
    CGFloat _beakTargetPosition;
    CGFloat _beakCurrentPosition;
    CGFloat _remainingAnimationDuration;
    CGFloat _beakDelta;
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

- (void)dealloc {

    if (_displayLink != nil) {
        CVDisplayLinkRelease(_displayLink);
        _displayLink = nil;
    }
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

- (void)setAnimating:(BOOL)animating {
    _animating = animating;

    if (_animating) {

        if (_displayLink == nil) {
            _PBPopoverViewInstance = self;
            CVDisplayLinkCreateWithActiveCGDisplays(&_displayLink);
            CVDisplayLinkSetOutputCallback(_displayLink, &PBPopoverViewDisplayLinkCallback, (__bridge void*)self);
            CVDisplayLinkStart(_displayLink);
        }

    } else {

        CVDisplayLinkRelease(_displayLink);
        _displayLink = nil;
    }
}

- (void)resetBeak {
    [self.beakPosition clearRunningValues];
    [self setNeedsDisplay:YES];

    if (_animating) {
        _beakTargetPosition = [self calculateBeakPosition];
        _remainingAnimationDuration = kPBPopoverAnimationDuration;
        _beakDelta = (_beakTargetPosition - _beakCurrentPosition) / (60.0f * kPBPopoverAnimationDuration);
    }
}

- (void)setBeakReferencePoint:(NSPoint)beakReferencePoint {
    _beakReferencePoint = beakReferencePoint;

    if (_animating) {
        _beakTargetPosition = [self calculateBeakPosition];
        _remainingAnimationDuration = kPBPopoverAnimationDuration;
        _beakDelta = (_beakTargetPosition - _beakCurrentPosition) / (60.0f * kPBPopoverAnimationDuration);
    }
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
    
    if ((_animating ||_beakPosition.value >= 0.0f) && _beakVisible) {
        NSRect beakFrame;

        CGFloat xPos;

        if (_animating) {

            xPos = _beakCurrentPosition + _beakDelta;

            if (_beakDelta >= 0.0f) {

                xPos = MIN(xPos, _beakTargetPosition);

            } else {

                xPos = MAX(xPos, _beakTargetPosition);
            }

        } else {

            xPos = self.beakPosition.value;
        }

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

static CVReturn PBPopoverViewDisplayLinkCallback(CVDisplayLinkRef displayLink,
                                                 const CVTimeStamp* nowTimestamp,
                                                 const CVTimeStamp* outputTime,
                                                 CVOptionFlags flagsIn,
                                                 CVOptionFlags* flagsOut,
                                                 void* displayLinkContext) {
    [_PBPopoverViewInstance setNeedsDisplay:YES];
}
