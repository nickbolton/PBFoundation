//
//  PBResizableView.m
//  Prototype
//
//  Created by Nick Bolton on 6/22/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBResizableView.h"
#import "PBGuideView.h"

@interface PBResizableView()

@property (nonatomic, strong) NSTextField *infoLabel;
@property (nonatomic, strong) NSTrackingArea *trackingArea;

@end

@implementation PBResizableView

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

    self.infoLabel = [[NSTextField alloc] initWithFrame:NSZeroRect];
    [_infoLabel setBezeled:NO];
    [_infoLabel setDrawsBackground:NO];
    [_infoLabel setEditable:NO];
    [_infoLabel setSelectable:NO];
    _infoLabel.alphaValue = 0.0f;
    _infoLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _infoLabel.textColor = [NSColor whiteColor];

    [self addSubview:_infoLabel];

    [NSLayoutConstraint horizontallyCenterView:_infoLabel];
    [NSLayoutConstraint verticallyCenterView:_infoLabel];
}

- (void)startMouseTracking {
    if (_trackingArea == nil) {

        int opts = (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways);
        self.trackingArea =
        [[NSTrackingArea alloc]
         initWithRect:self.bounds
         options:opts
         owner:self
         userInfo:nil];
        [self addTrackingArea:_trackingArea];
    }
}

- (void)setAlphaValue:(CGFloat)viewAlpha {

    if (viewAlpha > 0.0f) {
        [self startMouseTracking];
    } else {
        [self stopMouseTracking];
    }
}

- (void)stopMouseTracking {
    [self removeTrackingArea:_trackingArea];
    self.trackingArea = nil;
}

- (void)mouseEntered:(NSEvent *)event {
    self.showingInfo = YES;
    _drawingCanvas.showingInfo = YES;
}

- (void)mouseExited:(NSEvent *)event {
    if (_updating == NO) {
        self.showingInfo = NO;
        _drawingCanvas.showingInfo = NO;
    }
}

- (void)setShowingInfo:(BOOL)showingInfo {
    _showingInfo = showingInfo;

    CGFloat alpha = showingInfo ? 1.0f : 0.0f;

    [self updateInfo];

    [PBAnimator
     animateWithDuration:.3f
     timingFunction:PB_EASE_OUT
     animation:^{
         _infoLabel.animator.alphaValue = alpha;
     }];
}

- (void)updateInfo {

    if (_showingInfo) {

        _infoLabel.stringValue =
        [NSString stringWithFormat:@"(%.0f, %.0f)",
         NSWidth(self.frame), NSHeight(self.frame)];

        [_infoLabel sizeToFit];
        [_drawingCanvas setInfoValue:_infoLabel.stringValue];
    }
}

- (NSSize)roundedSize:(NSSize)size {
    return NSMakeSize(roundf(size.width), roundf(size.height));
}

- (NSPoint)roundedPoint:(NSPoint)point {
    return NSMakePoint(roundf(point.x), roundf(point.y));
}

- (void)setFrame:(NSRect)frameRect {

    frameRect.origin = [self roundedPoint:frameRect.origin];
    frameRect.size = [self roundedSize:frameRect.size];

    BOOL changed = NSEqualRects(frameRect, self.frame);

    [super setFrame:frameRect];

    if ([self.delegate respondsToSelector:@selector(viewDidMove:)]) {
        [(id<PBResizableViewDelegate>)self.delegate viewDidMove:self];
    }

    [self updateInfo];
    [self stopMouseTracking];
    [self startMouseTracking];
}

- (void)setFrameOrigin:(NSPoint)newOrigin {

    newOrigin = [self roundedPoint:newOrigin];

    BOOL changed = NSEqualPoints(newOrigin, self.frame.origin);

    [super setFrameOrigin:newOrigin];

    if ([self.delegate respondsToSelector:@selector(viewDidMove:)]) {
        [(id<PBResizableViewDelegate>)self.delegate viewDidMove:self];
    }

    [self updateInfo];
}

- (void)setFrameSize:(NSSize)newSize {

    newSize = [self roundedSize:newSize];

    BOOL changed = NSEqualSizes(newSize, self.frame.size);

    [super setFrameSize:newSize];

    if ([self.delegate respondsToSelector:@selector(viewDidMove:)]) {
        [(id<PBResizableViewDelegate>)self.delegate viewDidMove:self];
    }

    [self updateInfo];
}

- (void)setFrameAnimated:(NSRect)frame {

    [PBAnimator
     animateWithDuration:.3f
     timingFunction:PB_EASE_INOUT
     animation:^{
         self.animator.frame = frame;
     } completion:^{
         [self updateInfo];
     }];
}

#pragma mark - Drawing

- (void)drawRect:(NSRect)dirtyRect {

    if (_backgroundColor != nil) {
        [_backgroundColor setFill];
        NSRectFillUsingOperation(dirtyRect, NSCompositeSourceOver);
    }

    if (_borderColor != nil && _borderWidth > 0) {

        NSBezierPath *borderPath =
        [NSBezierPath bezierPathWithRect:self.bounds];

        if (_borderDashPattern.count > 0) {
            CGFloat dashPattern[_borderDashPattern.count];

            NSInteger idx = 0;

            for (NSNumber *value in _borderDashPattern) {
                dashPattern[idx++] = value.floatValue;
            }

            [borderPath
             setLineDash:dashPattern
             count:_borderDashPattern.count
             phase:_borderDashPhase];
        }

        [_borderColor setStroke];

        [borderPath stroke];
    }

    [super drawRect:dirtyRect];
}

@end
