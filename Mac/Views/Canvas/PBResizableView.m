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
@end

@implementation PBResizableView

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

    if (changed) {
        if ([self.delegate respondsToSelector:@selector(viewDidMove:)]) {
            [(id<PBResizableViewDelegate>)self.delegate viewDidMove:self];
        }
    }
}

- (void)setFrameOrigin:(NSPoint)newOrigin {

    newOrigin = [self roundedPoint:newOrigin];

    BOOL changed = NSEqualPoints(newOrigin, self.frame.origin);

    [super setFrameOrigin:newOrigin];

    if (changed) {
        if ([self.delegate respondsToSelector:@selector(viewDidMove:)]) {
            [(id<PBResizableViewDelegate>)self.delegate viewDidMove:self];
        }
    }
}

- (void)setFrameSize:(NSSize)newSize {

    newSize = [self roundedSize:newSize];

    BOOL changed = NSEqualSizes(newSize, self.frame.size);

    [super setFrameSize:newSize];

    if (changed) {
        if ([self.delegate respondsToSelector:@selector(viewDidMove:)]) {
            [(id<PBResizableViewDelegate>)self.delegate viewDidMove:self];
        }
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
