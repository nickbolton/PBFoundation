//
//  PBResizableView.m
//  Prototype
//
//  Created by Nick Bolton on 6/22/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBResizableView.h"
#import "PBSpacerView.h"

@interface PBResizableView()

@property (nonatomic, readwrite) NSTextField *infoLabel;
//@property (nonatomic, strong) NSTrackingArea *trackingArea;
@property (nonatomic, strong) NSLayoutConstraint *bottomSpace;
@property (nonatomic, strong) NSLayoutConstraint *leftSpace;
@property (nonatomic, strong) NSLayoutConstraint *width;
@property (nonatomic, strong) NSLayoutConstraint *height;

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
    _infoLabel.bezeled = NO;
    _infoLabel.drawsBackground = NO;
//    _infoLabel.backgroundColor = [NSColor redColor];
    _infoLabel.editable = NO;
    _infoLabel.selectable = NO;
    _infoLabel.alphaValue = 0.0f;
    _infoLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _infoLabel.textColor = [NSColor whiteColor];
    _infoLabel.font = [NSFont fontWithName:@"HelveticaNeue" size:17.0f];

    [self addSubview:_infoLabel];

    [NSLayoutConstraint horizontallyCenterView:_infoLabel];
    [NSLayoutConstraint verticallyCenterView:_infoLabel padding:-3.0f];
}

- (void)setupConstraints {
    self.translatesAutoresizingMaskIntoConstraints = NO;

    if (_width == nil) {
        self.width =
        [NSLayoutConstraint addWidthConstraint:NSWidth(self.frame) toView:self];
    }

    if (_height == nil) {
        self.height =
        [NSLayoutConstraint addHeightConstraint:NSHeight(self.frame) toView:self];
    }

    if (_bottomSpace == nil) {
        self.bottomSpace =
        [NSLayoutConstraint alignToBottom:self withPadding:-NSMinY(self.frame)];
    }

    if (_leftSpace == nil) {
        self.leftSpace =
        [NSLayoutConstraint alignToLeft:self withPadding:NSMinX(self.frame)];
    }
}

//- (void)startMouseTracking {
//    if (_trackingArea == nil) {
//
//        int opts = (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways | NSTrackingMouseMoved);
//        self.trackingArea =
//        [[NSTrackingArea alloc]
//         initWithRect:self.bounds
//         options:opts
//         owner:self
//         userInfo:nil];
//        [self addTrackingArea:_trackingArea];
//    }
//}

//- (void)setAlphaValue:(CGFloat)viewAlpha {
//
//    if (viewAlpha > 0.0f) {
//        [self startMouseTracking];
//    } else {
//        [self stopMouseTracking];
//    }
//}

//- (void)stopMouseTracking {
//    [self removeTrackingArea:_trackingArea];
//    self.trackingArea = nil;
//}
//
//- (void)mouseEntered:(NSEvent *)event {
//    self.showingInfo = YES;
//}
//
//- (void)mouseExited:(NSEvent *)event {
//    if (_updating == NO) {
//        self.showingInfo = NO;
//    }
//}
//
//- (void)mouseMoved:(NSEvent *)event {
//    if (_updating == NO && _showingInfo == NO) {
//        self.showingInfo = YES;
//    }
//}

- (void)setShowingInfo:(BOOL)showingInfo {

    BOOL changed = _showingInfo != showingInfo;
    
    _showingInfo = showingInfo;

    if (changed) {
        [self updateInfo];
    }
}

- (void)updateInfo {

    _infoLabel.stringValue =
    [NSString stringWithFormat:@"(%.0f, %.0f)",
     NSWidth(self.frame), NSHeight(self.frame)];

    [_infoLabel sizeToFit];
    [_drawingCanvas setInfoValue:_infoLabel.stringValue];

    [self updateTopSpacerView];
    [self updateBottomSpacerView];
    [self updateLeftSpacerView];
    [self updateRightSpacerView];

    _showingInfoLabel =
    NSWidth(self.frame) > NSWidth(_infoLabel.frame) &&
    NSHeight(self.frame) > NSHeight(_infoLabel.frame);

    CGFloat alpha = _showingInfo ? 1.0f : 0.0f;
    CGFloat infoAlpha = _showingInfo && _showingInfoLabel ? 1.0f : 0.0f;

    _infoLabel.alphaValue = infoAlpha;

    [_drawingCanvas updateInfoLabel:self];

    [PBAnimator
     animateWithDuration:.3f
     timingFunction:PB_EASE_OUT
     animation:^{

         _topSpacerView.animator.alphaValue = alpha;

         if (_closestBottomView == nil) {
             _bottomSpacerView.animator.alphaValue = alpha;
         } else {
             _bottomSpacerView.animator.alphaValue = 0.0f;
         }

         _leftSpacerView.animator.alphaValue = alpha;

         if (_closestRightView == nil) {
             _rightSpacerView.animator.alphaValue = alpha;
         } else {
             _rightSpacerView.animator.alphaValue = 0.0f;
         }
     }];
}

- (void)updateTopSpacerView {
}

- (void)updateBottomSpacerView {

    if (_closestBottomView == nil) {

    } else {
    }
}

- (void)updateLeftSpacerView {

    NSRect frame = _leftSpacerView.frame;

    CGFloat yPos;
    CGFloat width;

    if (_closestLeftView != nil) {

    } else {

        yPos = NSMidY(self.frame) - (NSHeight(frame) / 2.0f);

        frame.origin.y = yPos;
        frame.size.width = NSMinX(self.frame);
    }

    _leftSpacerView.frame = frame;
    [_leftSpacerView updateWidth];
}

- (void)updateRightSpacerView {

    if (_closestRightView == nil) {
    } else {
    }
}

- (NSSize)roundedSize:(NSSize)size {
    return NSMakeSize(roundf(size.width), roundf(size.height));
}

- (NSPoint)roundedPoint:(NSPoint)point {
    return NSMakePoint(roundf(point.x), roundf(point.y));
}

- (void)setFrame:(NSRect)frameRect {

//    NSLog(@"%s frame: %@", __PRETTY_FUNCTION__, NSStringFromRect(frameRect));
//    NSLog(@"%s constraints: %@", __PRETTY_FUNCTION__, self.constraints);
//    NSLog(@"%s super.constraints: %@", __PRETTY_FUNCTION__, self.superview.constraints);

    frameRect.origin = [self roundedPoint:frameRect.origin];
    frameRect.size = [self roundedSize:frameRect.size];

    BOOL changed = NSEqualRects(frameRect, self.frame);

    [super setFrame:frameRect];

    if ([self.delegate respondsToSelector:@selector(viewDidMove:)]) {
        [(id<PBResizableViewDelegate>)self.delegate viewDidMove:self];
    }

    [self updateInfo];
//    [self stopMouseTracking];
//    [self startMouseTracking];
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

- (void)setViewFrame:(NSRect)frame animated:(BOOL)animated {
    
    if (animated) {

        [NSAnimationContext beginGrouping];
        NSAnimationContext.currentContext.duration = .3f;
        NSAnimationContext.currentContext.completionHandler = nil;

        [_bottomSpace.animator setConstant:-NSMinY(frame)];
        [_leftSpace.animator setConstant:NSMinX(frame)];
        [_width.animator setConstant:NSWidth(frame)];
        [_height.animator setConstant:NSHeight(frame)];

        [NSAnimationContext endGrouping];

    } else {

        _bottomSpace.constant = -NSMinY(frame);
        _leftSpace.constant = NSMinX(frame);
        _width.constant = NSWidth(frame);
        _height.constant = NSHeight(frame);
        [self setNeedsLayout:YES];
    }
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
