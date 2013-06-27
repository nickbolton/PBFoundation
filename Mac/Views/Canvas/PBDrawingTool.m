//
//  PBDrawingTool.m
//  Prototype
//
//  Created by Nick Bolton on 6/23/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBDrawingTool.h"
#import "PBDrawingCanvas.h"
#import "PBResizableView.h"

#define DISTANCE(x, y) ( ((x) < (y)) ? ((y) - (x)) : ((x) - (y)) )

NSPoint PBDrawingToolClosestPointInRect(NSPoint pt, NSRect rc) {
    float x, y;
    if (pt.x < NSMinX(rc))
        x = NSMinX(rc);
    else if (pt.x > NSMaxX(rc))
        x = NSMaxX(rc);
    else
        x = pt.x;

    if (pt.y < NSMinY(rc))
        y = NSMinY(rc);
    else if (pt.y > NSMaxY(rc))
        y = NSMaxY(rc);
    else
        y = pt.y;

    return NSMakePoint(x, y);
}

NSPoint PBDrawingToolClosestPointOnRectEdge(NSPoint pt, NSRect rc) {
    if (NSPointInRect(pt, rc) == NO)
        return PBDrawingToolClosestPointInRect(pt, rc);

    // find closest edge

    float d[4];
    d[0] = pt.x - NSMinX(rc);
    d[1] = pt.y - NSMinY(rc);
    d[2] = NSMaxX(rc) - pt.x;
    d[3] = NSMaxY(rc) - pt.y;

    // find minimum in the array d[]
    int i_min = 0;
    float d_min = d[i_min];
    int i;
    for (i=1; i < 4; ++i)
        if (d[i] < d_min)
            d_min = d[ i_min = i ];

    NSPoint result;
    switch (i_min)
    {
        case 0: result = NSMakePoint(NSMinX(rc), pt.y); break;
        case 1: result = NSMakePoint(pt.x, NSMinY(rc)); break;
        case 2: result = NSMakePoint(NSMaxX(rc), pt.y); break;
        case 3: result = NSMakePoint(pt.x, NSMaxY(rc)); break;
    }
    return result;
}

CGFloat PBDrawingToolDistance(NSPoint a, NSPoint b) {
    return MIN( DISTANCE(a.x, b.x), DISTANCE(a.y, b.y) );
}

@interface PBDrawingTool() {
}

@end


@implementation PBDrawingTool

- (PBResizableView *)mouseInteractingViewInCanvas:(PBDrawingCanvas *)canvas {

    PBResizableView *result = nil;
    CGFloat minDistance = MAXFLOAT;

    NSPoint mouseLocation = [canvas windowLocationOfMouse];

    for (PBResizableView *view in canvas.toolViews) {

        NSPoint closestPoint =
        PBDrawingToolClosestPointOnRectEdge(mouseLocation, view.frame);

        CGFloat distance = PBDrawingToolDistance(closestPoint, mouseLocation);

        if (distance < minDistance) {
            result = view;
            minDistance = distance;
        }
    }

    return result;
}

- (void)cleanup {
}

- (BOOL)shouldDeselectView:(PBResizableView *)view {
    return YES;
}

- (void)mouseDown:(PBClickableView *)view
          atPoint:(NSPoint)point
         inCanvas:(PBDrawingCanvas *)canvas {
    self.mouseDownPoint = [canvas roundedPoint:point];
    self.didMove = NO;
    self.didResize = NO;
    self.moving = NO;
    self.didCreate = NO;
}

- (void)mouseUp:(PBClickableView *)view
        atPoint:(NSPoint)point
       inCanvas:(PBDrawingCanvas *)canvas {

    CGFloat minX = MIN(self.mouseDownPoint.x, point.x);
    CGFloat maxX = MAX(self.mouseDownPoint.x, point.x);
    CGFloat minY = MIN(self.mouseDownPoint.y, point.y);
    CGFloat maxY = MAX(self.mouseDownPoint.y, point.y);

    self.boundingRect = NSMakeRect(minX, minY, maxX - minX, maxY - minY);
}

- (void)mouseDragged:(PBClickableView *)view
             toPoint:(NSPoint)point
            inCanvas:(PBDrawingCanvas *)canvas {

    CGFloat minX = MIN(self.mouseDownPoint.x, point.x);
    CGFloat maxX = MAX(self.mouseDownPoint.x, point.x);
    CGFloat minY = MIN(self.mouseDownPoint.y, point.y);
    CGFloat maxY = MAX(self.mouseDownPoint.y, point.y);

    self.boundingRect =
    [canvas roundedRect:NSMakeRect(minX, minY, maxX - minX, maxY - minY)];
}

- (void)mouseMovedToPoint:(NSPoint)point inCanvas:(PBDrawingCanvas *)canvas {
    
}

- (void)drawBackgroundInCanvas:(PBDrawingCanvas *)canvas dirtyRect:(NSRect)dirtyRect {
}

- (void)drawForegroundInCanvas:(PBDrawingCanvas *)canvas dirtyRect:(NSRect)dirtyRect {
}

- (void)determineSelectedViewAnchorPoint:(PBDrawingCanvas *)canvas {

    NSView *selectedView =
    [self mouseInteractingViewInCanvas:canvas];

    [self determineSelectedViewAnchorPoint:canvas forView:selectedView];
}

- (void)determineSelectedViewAnchorPoint:(PBDrawingCanvas *)canvas forView:(NSView *)selectedView {
    
    switch (_resizeType) {
        case PBPResizeTypeUp:
            _selectedViewAnchor =
            NSMakePoint(NSMidX(selectedView.frame), NSMinY(selectedView.frame));
            break;

        case PBPResizeTypeDown:
            _selectedViewAnchor =
            NSMakePoint(NSMidX(selectedView.frame), NSMaxY(selectedView.frame));
            break;

        case PBPResizeTypeLeft:
            _selectedViewAnchor =
            NSMakePoint(NSMaxX(selectedView.frame), NSMidY(selectedView.frame));
            break;

        case PBPResizeTypeRight:
            _selectedViewAnchor =
            NSMakePoint(NSMinX(selectedView.frame), NSMidY(selectedView.frame));
            break;

        case PBPResizeTypeUpLeft:
            _selectedViewAnchor =
            NSMakePoint(NSMaxX(selectedView.frame), NSMinY(selectedView.frame));
            break;

        case PBPResizeTypeUpRight:
            _selectedViewAnchor =
            NSMakePoint(NSMinX(selectedView.frame), NSMinY(selectedView.frame));
            break;

        case PBPResizeTypeDownLeft:
            _selectedViewAnchor =
            NSMakePoint(NSMaxX(selectedView.frame), NSMaxY(selectedView.frame));
            break;

        case PBPResizeTypeDownRight:
            _selectedViewAnchor =
            NSMakePoint(NSMinX(selectedView.frame), NSMaxY(selectedView.frame));
            break;

        default:
            break;
    }
}

- (void)determineResizeTypeForView:(NSView *)view
                           atPoint:(NSPoint)point
                          inCanvas:(PBDrawingCanvas *)canvas {

    static CGFloat detectSize = 10.0f;

    if ([NSEvent isCurrentModifiersExactly:NSAlternateKeyMask]) {
        _resizeType = PBPResizeTypeNone;
        return;
    }

    NSRect frame;

    // up-left
    frame =
    NSMakeRect(NSMinX(view.frame),
               NSMaxY(view.frame) - detectSize,
               detectSize,
               detectSize);

    if (NSPointInRect(point, frame)) {
        _resizeType = PBPResizeTypeUpLeft;
        [self determineSelectedViewAnchorPoint:canvas];
        return;
    }

    // up-right
    frame =
    NSMakeRect(NSMaxX(view.frame) - detectSize,
               NSMaxY(view.frame) - detectSize,
               detectSize,
               detectSize);

    if (NSPointInRect(point, frame)) {
        _resizeType = PBPResizeTypeUpRight;
        [self determineSelectedViewAnchorPoint:canvas];
        return;
    }

    // down-left
    frame =
    NSMakeRect(NSMinX(view.frame),
               NSMinY(view.frame),
               detectSize,
               detectSize);

    if (NSPointInRect(point, frame)) {
        _resizeType = PBPResizeTypeDownLeft;
        [self determineSelectedViewAnchorPoint:canvas];
        return;
    }

    // down-right
    frame =
    NSMakeRect(NSMaxX(view.frame) - detectSize,
               NSMinY(view.frame),
               detectSize,
               detectSize);

    if (NSPointInRect(point, frame)) {
        _resizeType = PBPResizeTypeDownRight;
        [self determineSelectedViewAnchorPoint:canvas];
        return;
    }

    // left
    frame =
    NSMakeRect(NSMinX(view.frame),
               NSMinY(view.frame),
               detectSize,
               NSHeight(view.frame));

    if (NSPointInRect(point, frame)) {
        _resizeType = PBPResizeTypeLeft;
        [self determineSelectedViewAnchorPoint:canvas];
        return;
    }

    // right
    frame =
    NSMakeRect(NSMaxX(view.frame) - detectSize,
               NSMinY(view.frame),
               detectSize,
               NSHeight(view.frame));

    if (NSPointInRect(point, frame)) {
        _resizeType = PBPResizeTypeRight;
        [self determineSelectedViewAnchorPoint:canvas];
        return;
    }

    // up
    frame =
    NSMakeRect(NSMinX(view.frame),
               NSMaxY(view.frame) - detectSize,
               NSWidth(view.frame),
               detectSize);

    if (NSPointInRect(point, frame)) {
        _resizeType = PBPResizeTypeUp;
        [self determineSelectedViewAnchorPoint:canvas];
        return;
    }

    // down
    frame =
    NSMakeRect(NSMinX(view.frame),
               NSMinY(view.frame),
               NSWidth(view.frame),
               detectSize);

    if (NSPointInRect(point, frame)) {
        _resizeType = PBPResizeTypeDown;
        [self determineSelectedViewAnchorPoint:canvas];
        return;
    }

}

- (void)setCursorForResizeType {

    switch (_resizeType) {
        case PBPResizeTypeNone:
            [[NSCursor arrowCursor] set];
            break;

        case PBPResizeTypeUp:
            [[NSCursor resizeUpDownCursor] set];
            break;

        case PBPResizeTypeDown:
            [[NSCursor resizeUpDownCursor] set];
            break;

        case PBPResizeTypeLeft:
            [[NSCursor resizeLeftRightCursor] set];
            break;

        case PBPResizeTypeRight:
            [[NSCursor resizeLeftRightCursor] set];
            break;

        case PBPResizeTypeUpLeft:
            [[NSCursor crosshairCursor] set];
            break;

        case PBPResizeTypeUpRight:
            [[NSCursor crosshairCursor] set];
            break;

        case PBPResizeTypeDownLeft:
            [[NSCursor crosshairCursor] set];
            break;

        case PBPResizeTypeDownRight:
            [[NSCursor crosshairCursor] set];
            break;

        default:
            break;
    }
}

- (void)resizeSelectedViewAtPoint:(NSPoint)point
                         inCanvas:(PBDrawingCanvas *)canvas {

    static CGFloat minDimension = 1.0f;

    point.x = roundf(point.x);
    point.y = roundf(point.y);

    NSRect frame = canvas.resizingView.frame;

    NSPoint mouseLocation = [canvas windowLocationOfMouse];

    switch (_resizeType) {
        case PBPResizeTypeUp:

            if (mouseLocation.y < NSMinY(_selectedViewMouseDownFrame)) {
                _resizeType = PBPResizeTypeDown;

                _selectedViewMouseDownFrame = canvas.resizingView.frame;

                self.mouseDownPoint = mouseLocation;
                [self resizeSelectedViewAtPoint:point inCanvas:canvas];
                return;
            }

            frame.origin.y = _selectedViewAnchor.y;
            frame.size.height = roundf(point.y - NSMinY(frame));
            frame.size.height = MAX(minDimension, NSHeight(frame));

            break;

        case PBPResizeTypeDown:

            if (mouseLocation.y > NSMaxY(_selectedViewMouseDownFrame)) {
                _resizeType = PBPResizeTypeUp;

                _selectedViewMouseDownFrame = canvas.resizingView.frame;

                self.mouseDownPoint = mouseLocation;
                [self resizeSelectedViewAtPoint:point inCanvas:canvas];
                return;
            }

            frame.origin.y = point.y;
            frame.size.height = roundf(_selectedViewAnchor.y - NSMinY(frame));
            frame.size.height = MAX(minDimension, NSHeight(frame));

            break;

        case PBPResizeTypeLeft:

            if (mouseLocation.x > NSMaxX(_selectedViewMouseDownFrame)) {
                _resizeType = PBPResizeTypeRight;

                _selectedViewMouseDownFrame = canvas.resizingView.frame;

                self.mouseDownPoint = mouseLocation;
                [self resizeSelectedViewAtPoint:point inCanvas:canvas];
                return;
            }

            frame.origin.x = point.x;
            frame.size.width = roundf(_selectedViewAnchor.x - NSMinX(frame));
            frame.size.width = MAX(minDimension, NSWidth(frame));

            break;

        case PBPResizeTypeRight:

            if (mouseLocation.x < NSMinX(_selectedViewMouseDownFrame)) {
                _resizeType = PBPResizeTypeLeft;

                _selectedViewMouseDownFrame = canvas.resizingView.frame;

                self.mouseDownPoint = mouseLocation;
                [self resizeSelectedViewAtPoint:point inCanvas:canvas];
                return;
            }

            frame.origin.x = _selectedViewAnchor.x;
            frame.size.width = roundf(point.x - NSMinX(frame));
            frame.size.width = MAX(minDimension, NSWidth(frame));

            break;

        case PBPResizeTypeUpLeft: {

            BOOL vertChanged = NO;
            BOOL horzChanged = NO;

            if (mouseLocation.y < NSMinY(_selectedViewMouseDownFrame)) {
                vertChanged = YES;
            }

            if (mouseLocation.x > NSMaxX(_selectedViewMouseDownFrame)) {
                horzChanged = YES;
            }

            if (vertChanged || horzChanged) {

                if (vertChanged && horzChanged) {
                    _resizeType = PBPResizeTypeDownRight;
                } else if (vertChanged) {
                    _resizeType = PBPResizeTypeDownLeft;
                } else {
                    _resizeType = PBPResizeTypeUpRight;
                }

                _selectedViewMouseDownFrame = canvas.resizingView.frame;

                self.mouseDownPoint = mouseLocation;
                [self resizeSelectedViewAtPoint:point inCanvas:canvas];
                return;
            }

            frame.origin.y = _selectedViewAnchor.y;
            frame.size.height = roundf(point.y - NSMinY(frame));
            frame.size.height = MAX(minDimension, NSHeight(frame));

            frame.origin.x = point.x;
            frame.size.width = roundf(_selectedViewAnchor.x - NSMinX(frame));
            frame.size.width = MAX(minDimension, NSWidth(frame));

        } break;

        case PBPResizeTypeUpRight: {

            BOOL vertChanged = NO;
            BOOL horzChanged = NO;

            if (mouseLocation.y < NSMinY(_selectedViewMouseDownFrame)) {
                vertChanged = YES;
            }

            if (mouseLocation.x < NSMinX(_selectedViewMouseDownFrame)) {
                horzChanged = YES;
            }

            if (vertChanged || horzChanged) {

                if (vertChanged && horzChanged) {
                    _resizeType = PBPResizeTypeDownLeft;
                } else if (vertChanged) {
                    _resizeType = PBPResizeTypeDownRight;
                } else {
                    _resizeType = PBPResizeTypeUpLeft;
                }

                _selectedViewMouseDownFrame = canvas.resizingView.frame;

                self.mouseDownPoint = mouseLocation;
                [self resizeSelectedViewAtPoint:point inCanvas:canvas];
                return;
            }

            frame.origin.y = _selectedViewAnchor.y;
            frame.size.height = roundf(point.y - NSMinY(frame));
            frame.size.height = MAX(minDimension, NSHeight(frame));

            frame.origin.x = _selectedViewAnchor.x;
            frame.size.width = roundf(point.x - NSMinX(frame));
            frame.size.width = MAX(minDimension, NSWidth(frame));

        } break;

        case PBPResizeTypeDownLeft: {

            BOOL vertChanged = NO;
            BOOL horzChanged = NO;

            if (mouseLocation.y > NSMaxY(_selectedViewMouseDownFrame)) {
                vertChanged = YES;
            }

            if (mouseLocation.x > NSMaxX(_selectedViewMouseDownFrame)) {
                horzChanged = YES;
            }

            if (vertChanged || horzChanged) {

                if (vertChanged && horzChanged) {
                    _resizeType = PBPResizeTypeUpRight;
                } else if (vertChanged) {
                    _resizeType = PBPResizeTypeUpLeft;
                } else {
                    _resizeType = PBPResizeTypeDownRight;
                }

                _selectedViewMouseDownFrame = canvas.resizingView.frame;

                self.mouseDownPoint = mouseLocation;
                [self resizeSelectedViewAtPoint:point inCanvas:canvas];
                return;
            }

            frame.origin.y = point.y;
            frame.size.height = roundf(_selectedViewAnchor.y - NSMinY(frame));
            frame.size.height = MAX(minDimension, NSHeight(frame));

            frame.origin.x = point.x;
            frame.size.width = roundf(_selectedViewAnchor.x - NSMinX(frame));
            frame.size.width = MAX(minDimension, NSWidth(frame));

        } break;

        case PBPResizeTypeDownRight: {

            BOOL vertChanged = NO;
            BOOL horzChanged = NO;

            if (mouseLocation.y > NSMaxY(_selectedViewMouseDownFrame)) {
                vertChanged = YES;
            }

            if (mouseLocation.x < NSMinX(_selectedViewMouseDownFrame)) {
                horzChanged = YES;
            }

            if (vertChanged || horzChanged) {
                
                if (vertChanged && horzChanged) {
                    _resizeType = PBPResizeTypeUpLeft;
                } else if (vertChanged) {
                    _resizeType = PBPResizeTypeUpRight;
                } else {
                    _resizeType = PBPResizeTypeDownLeft;
                }
                
                _selectedViewMouseDownFrame = canvas.resizingView.frame;
                
                self.mouseDownPoint = mouseLocation;
                [self resizeSelectedViewAtPoint:point inCanvas:canvas];
                return;
            }
            
            frame.origin.y = point.y;
            frame.size.height = roundf(_selectedViewAnchor.y - NSMinY(frame));
            frame.size.height = MAX(minDimension, NSHeight(frame));
            
            frame.origin.x = _selectedViewAnchor.x;
            frame.size.width = roundf(point.x - NSMinX(frame));
            frame.size.width = MAX(minDimension, NSWidth(frame));
            
        } break;
            
        default:
            break;
    }

    [canvas.resizingView setViewFrame:frame animated:NO];
}

#pragma mark - Mouse Tracking

- (NSDictionary *)trackingRectsForMouseEvents {

    // returns dictionary of identifiers -> NSValue (NSRect)
//    return
//    @{
//      @"id" : [NSValue valueWithRect:NSMakeRect(0.0f, 0.0f, 100.0f, 100.0f)],
//      };

    return nil;
}

- (void)mouseEnteredTrackingRect:(NSRect)rect
                  rectIdentifier:(NSString *)rectIdentifier {
}

- (void)mouseExitedTrackingRect:(NSRect)rect
                 rectIdentifier:(NSString *)rectIdentifier {
}

@end
