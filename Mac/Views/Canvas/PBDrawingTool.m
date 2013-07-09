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

    NSPoint mouseLocation = [canvas mouseLocationInDocument];

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

- (void)rotate {
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
    self.resizeType = PBPResizeTypeNone;

    for (PBResizableView *view in canvas.toolViews) {
        [view unhighlight];
    }
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

- (void)determineSelectedViewAnchorPoint:(PBDrawingCanvas *)canvas forView:(PBResizableView *)selectedView {
    
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

- (void)determineResizeTypeForView:(PBResizableView *)view
                           atPoint:(NSPoint)point
                          inCanvas:(PBDrawingCanvas *)canvas {

    CGFloat detectSize = 10.0f * canvas.scaleFactor;
    CGFloat padding = 1.0f * canvas.scaleFactor;

    if ([NSEvent isCurrentModifiersExactly:NSAlternateKeyMask]) {
        _resizeType = PBPResizeTypeNone;
        return;
    }

    NSRect frame;

    // up-left
    frame =
    NSMakeRect(NSMinX(view.frame) + padding,
               NSMaxY(view.frame) - padding - detectSize,
               detectSize,
               detectSize);

    if (NSPointInRect(point, frame)) {
        _resizeType = PBPResizeTypeUpLeft;
        [self determineSelectedViewAnchorPoint:canvas];
        return;
    }

    // up-right
    frame =
    NSMakeRect(NSMaxX(view.frame) - detectSize - padding,
               NSMaxY(view.frame) - detectSize - padding,
               detectSize,
               detectSize);

    if (NSPointInRect(point, frame)) {
        _resizeType = PBPResizeTypeUpRight;
        [self determineSelectedViewAnchorPoint:canvas];
        return;
    }

    // down-left
    frame =
    NSMakeRect(NSMinX(view.frame) + padding,
               NSMinY(view.frame) + padding,
               detectSize,
               detectSize);

    if (NSPointInRect(point, frame)) {
        _resizeType = PBPResizeTypeDownLeft;
        [self determineSelectedViewAnchorPoint:canvas];
        return;
    }

    // down-right
    frame =
    NSMakeRect(NSMaxX(view.frame) - detectSize - padding,
               NSMinY(view.frame) + padding,
               detectSize,
               detectSize);

    if (NSPointInRect(point, frame)) {
        _resizeType = PBPResizeTypeDownRight;
        [self determineSelectedViewAnchorPoint:canvas];
        return;
    }

    // left
    frame =
    NSMakeRect(NSMinX(view.frame) + padding,
               NSMinY(view.frame) + padding,
               detectSize,
               NSHeight(view.frame));

    if (NSPointInRect(point, frame)) {
        _resizeType = PBPResizeTypeLeft;
        [self determineSelectedViewAnchorPoint:canvas];
        return;
    }

    // right
    frame =
    NSMakeRect(NSMaxX(view.frame) - detectSize - padding,
               NSMinY(view.frame) + padding,
               detectSize,
               NSHeight(view.frame));

    if (NSPointInRect(point, frame)) {
        _resizeType = PBPResizeTypeRight;
        [self determineSelectedViewAnchorPoint:canvas];
        return;
    }

    // up
    frame =
    NSMakeRect(NSMinX(view.frame) + padding,
               NSMaxY(view.frame) - detectSize - padding,
               NSWidth(view.frame),
               detectSize);

    if (NSPointInRect(point, frame)) {
        _resizeType = PBPResizeTypeUp;
        [self determineSelectedViewAnchorPoint:canvas];
        return;
    }

    // down
    frame =
    NSMakeRect(NSMinX(view.frame) + padding,
               NSMinY(view.frame) + padding,
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

    NSPoint mouseLocation = [canvas mouseLocationInDocument];

    BOOL nonZeroRect = NSEqualRects(frame, NSZeroRect) == NO;
    CGFloat xOffset, yOffset;

    PBResizableView *snapView = nil;
    NSRect snapRect;

    switch (_resizeType) {
        case PBPResizeTypeUp:

            if (nonZeroRect && mouseLocation.y < NSMinY(_selectedViewMouseDownFrame)) {
                _resizeType = PBPResizeTypeDown;

                _selectedViewMouseDownFrame = canvas.resizingView.frame;

                self.mouseDownPoint = mouseLocation;
                [self resizeSelectedViewAtPoint:point inCanvas:canvas];
                return;
            }

            yOffset = NSMaxY(self.mouseDownStartingRect) - self.mouseDownPoint.y;

            frame.origin.y = _selectedViewAnchor.y;
            frame.size.height = roundf(point.y - NSMinY(frame) + yOffset);
            frame.size.height = MAX(minDimension, NSHeight(frame));

            if (self.shouldSnapOnResize && canvas.snapThreshold > 0.0f) {

                snapRect =
                [self
                 topSnapRect:frame
                 resizingRect:YES
                 canvas:canvas
                 snapView:&snapView];

                if (NSEqualRects(snapRect, NSZeroRect) == NO) {

                    frame.size.height += NSMinY(snapRect) - NSMaxY(frame);

                    if (snapView != nil) {
                        [snapView highlight];
                    }
                }
            }

            break;

        case PBPResizeTypeDown:

            if (nonZeroRect && mouseLocation.y > NSMaxY(_selectedViewMouseDownFrame)) {
                _resizeType = PBPResizeTypeUp;

                _selectedViewMouseDownFrame = canvas.resizingView.frame;

                self.mouseDownPoint = mouseLocation;
                [self resizeSelectedViewAtPoint:point inCanvas:canvas];
                return;
            }

            yOffset = NSMinY(self.mouseDownStartingRect) - self.mouseDownPoint.y;

            frame.origin.y = point.y + yOffset;
            frame.size.height = roundf(_selectedViewAnchor.y - NSMinY(frame));
            frame.size.height = MAX(minDimension, NSHeight(frame));

            if (self.shouldSnapOnResize && canvas.snapThreshold > 0.0f) {

                snapRect =
                [self
                 bottomSnapRect:frame
                 resizingRect:YES
                 canvas:canvas
                 snapView:&snapView];

                if (NSEqualRects(snapRect, NSZeroRect) == NO) {

                    frame.size.height -= NSMinY(snapRect) - NSMinY(frame);
                    frame.origin.y = NSMinY(snapRect);

                    if (snapView != nil) {
                        [snapView highlight];
                    }
                }
            }

            break;

        case PBPResizeTypeLeft:

            if (nonZeroRect && mouseLocation.x > NSMaxX(_selectedViewMouseDownFrame)) {
                _resizeType = PBPResizeTypeRight;

                _selectedViewMouseDownFrame = canvas.resizingView.frame;

                self.mouseDownPoint = mouseLocation;
                [self resizeSelectedViewAtPoint:point inCanvas:canvas];
                return;
            }

            frame.origin.x = point.x;
            frame.size.width = roundf(_selectedViewAnchor.x - NSMinX(frame));
            frame.size.width = MAX(minDimension, NSWidth(frame));

            if (self.shouldSnapOnResize && canvas.snapThreshold > 0.0f) {

                snapRect =
                [self
                 leftSnapRect:frame
                 resizingRect:YES
                 canvas:canvas
                 snapView:&snapView];

                if (NSEqualRects(snapRect, NSZeroRect) == NO) {

                    frame.size.width -= NSMinX(snapRect) - NSMinX(frame);
                    frame.origin.x = NSMinX(snapRect);

                    if (snapView != nil) {
                        [snapView highlight];
                    }
                }
            }

            break;

        case PBPResizeTypeRight:

            if (nonZeroRect && mouseLocation.x < NSMinX(_selectedViewMouseDownFrame)) {
                _resizeType = PBPResizeTypeLeft;

                _selectedViewMouseDownFrame = canvas.resizingView.frame;

                self.mouseDownPoint = mouseLocation;
                [self resizeSelectedViewAtPoint:point inCanvas:canvas];
                return;
            }

            frame.origin.x = _selectedViewAnchor.x;
            frame.size.width = roundf(point.x - NSMinX(frame));
            frame.size.width = MAX(minDimension, NSWidth(frame));

            if (self.shouldSnapOnResize && canvas.snapThreshold > 0.0f) {

                snapRect =
                [self
                 rightSnapRect:frame
                 resizingRect:YES
                 canvas:canvas
                 snapView:&snapView];

                if (NSEqualRects(snapRect, NSZeroRect) == NO) {

                    frame.size.width += NSMinX(snapRect) - NSMaxX(frame);

                    if (snapView != nil) {
                        [snapView highlight];
                    }
                }
            }

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

            if (nonZeroRect && (vertChanged || horzChanged)) {

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

            if (self.shouldSnapOnResize && canvas.snapThreshold > 0.0f) {

                snapRect =
                [self
                 topSnapRect:frame
                 resizingRect:YES
                 canvas:canvas
                 snapView:&snapView];

                if (NSEqualRects(snapRect, NSZeroRect) == NO) {

                    frame.size.height += NSMinY(snapRect) - NSMaxY(frame);

                    if (snapView != nil) {
                        [snapView highlight];
                    }
                }

                snapRect =
                [self
                 leftSnapRect:frame
                 resizingRect:YES
                 canvas:canvas
                 snapView:&snapView];

                if (NSEqualRects(snapRect, NSZeroRect) == NO) {

                    frame.size.width -= NSMinX(snapRect) - NSMinX(frame);
                    frame.origin.x = NSMinX(snapRect);

                    if (snapView != nil) {
                        [snapView highlight];
                    }
                }
            }

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


            if (nonZeroRect && (vertChanged || horzChanged)) {

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

            if (self.shouldSnapOnResize && canvas.snapThreshold > 0.0f) {

                snapRect =
                [self
                 topSnapRect:frame
                 resizingRect:YES
                 canvas:canvas
                 snapView:&snapView];

                if (NSEqualRects(snapRect, NSZeroRect) == NO) {

                    frame.size.height += NSMinY(snapRect) - NSMaxY(frame);

                    if (snapView != nil) {
                        [snapView highlight];
                    }
                }

                snapRect =
                [self
                 rightSnapRect:frame
                 resizingRect:YES
                 canvas:canvas
                 snapView:&snapView];

                if (NSEqualRects(snapRect, NSZeroRect) == NO) {

                    frame.size.width += NSMinX(snapRect) - NSMaxX(frame);

                    if (snapView != nil) {
                        [snapView highlight];
                    }
                }
            }

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

            if (nonZeroRect && (vertChanged || horzChanged)) {

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

            if (self.shouldSnapOnResize && canvas.snapThreshold > 0.0f) {

                snapRect =
                [self
                 bottomSnapRect:frame
                 resizingRect:YES
                 canvas:canvas
                 snapView:&snapView];

                if (NSEqualRects(snapRect, NSZeroRect) == NO) {

                    frame.size.height -= NSMinY(snapRect) - NSMinY(frame);
                    frame.origin.y = NSMinY(snapRect);

                    if (snapView != nil) {
                        [snapView highlight];
                    }
                }

                snapRect =
                [self
                 leftSnapRect:frame
                 resizingRect:YES
                 canvas:canvas
                 snapView:&snapView];

                if (NSEqualRects(snapRect, NSZeroRect) == NO) {

                    frame.size.width -= NSMinX(snapRect) - NSMinX(frame);
                    frame.origin.x = NSMinX(snapRect);

                    if (snapView != nil) {
                        [snapView highlight];
                    }
                }
            }

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

            if (nonZeroRect && (vertChanged || horzChanged)) {

                if (vertChanged && horzChanged) {
                    _resizeType = PBPResizeTypeUpLeft;
                } else if (vertChanged) {
                    _resizeType = PBPResizeTypeUpRight;
                } else {
                    _resizeType = PBPResizeTypeDownLeft;
                }
                
                _selectedViewMouseDownFrame = canvas.resizingView.frame;

                if (NSEqualRects(_selectedViewMouseDownFrame, NSZeroRect) == NO) {
                    return;
                }

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

            if (self.shouldSnapOnResize && canvas.snapThreshold > 0.0f) {

                snapRect =
                [self
                 bottomSnapRect:frame
                 resizingRect:YES
                 canvas:canvas
                 snapView:&snapView];

                if (NSEqualRects(snapRect, NSZeroRect) == NO) {

                    frame.size.height -= NSMinY(snapRect) - NSMinY(frame);
                    frame.origin.y = NSMinY(snapRect);

                    if (snapView != nil) {
                        [snapView highlight];
                    }
                }

                snapRect =
                [self
                 rightSnapRect:frame
                 resizingRect:YES
                 canvas:canvas
                 snapView:&snapView];

                if (NSEqualRects(snapRect, NSZeroRect) == NO) {

                    frame.size.width += NSMinX(snapRect) - NSMaxX(frame);

                    if (snapView != nil) {
                        [snapView highlight];
                    }
                }
            }

        } break;
            
        default:
            break;
    }

    [canvas.resizingView
     setViewFrame:frame
     withContainerFrame:[canvas.scrollView.documentView frame]
     animate:NO];
    
    [canvas updateInfoLabel:canvas.resizingView];
}

#pragma mark - Edge Operations

- (NSRect)topSnapRect:(NSRect)rect
         resizingRect:(BOOL)resizingRect
               canvas:(PBDrawingCanvas *)canvas
             snapView:(PBResizableView **)snapView {

    PBResizableView *snapTopToTopView = nil;
    PBResizableView *snapTopToBottomView = nil;

    if (snapView != NULL) {
        *snapView = nil;
    }

    for (PBResizableView *view in canvas.toolViews) {

        if (view.isSelected == NO) {

            if ([self
                 topEdgesIntersect:rect
                 rect2:view.frame
                 containerSize:canvas.frame.size
                 snapThreshold:canvas.snapThreshold]) {
                snapTopToTopView = view;

                if (snapView != NULL) {
                    *snapView = view;
                }
                break;
            }

            if ([self
                 topEdgeIntersects:rect
                 bottomEdge:view.frame
                 containerSize:canvas.frame.size
                 snapThreshold:canvas.snapThreshold]) {
                snapTopToBottomView = view;

                if (snapView != NULL) {
                    *snapView = view;
                }
                break;
            }
        }
    }

    if (snapTopToTopView != nil) {

        if (resizingRect) {
            return
            NSMakeRect(0.0f,
                       NSMaxY(snapTopToTopView.frame),
                       1.0f,
                       1.0f);
        } else {
            return
            NSMakeRect(0.0f,
                       NSMaxY(snapTopToTopView.frame) - NSHeight(rect),
                       1.0f,
                       1.0f);
        }
    }

    if (snapTopToBottomView != nil) {
        if (resizingRect) {
            return
            NSMakeRect(0.0f,
                       NSMinY(snapTopToBottomView.frame),
                       1.0f,
                       1.0f);
        } else {
            return
            NSMakeRect(0.0f,
                       NSMinY(snapTopToBottomView.frame) - NSHeight(rect),
                       1.0f,
                       1.0f);
        }
    }

    if ([self
         topEdgesIntersect:rect
         rect2:[canvas.scrollView.documentView bounds]
         containerSize:canvas.frame.size
         snapThreshold:canvas.snapThreshold]) {

        if (resizingRect) {
            return
            NSMakeRect(0.0f,
                       NSMaxY([canvas.scrollView.documentView bounds]),
                       1.0f,
                       1.0f);
        } else {
            return
            NSMakeRect(0.0f,
                       NSMaxY([canvas.scrollView.documentView bounds]) - NSHeight(rect),
                       1.0f,
                       1.0f);
        }
    }

    return NSZeroRect;
}

- (NSRect)bottomSnapRect:(NSRect)rect
            resizingRect:(BOOL)resizingRect
                  canvas:(PBDrawingCanvas *)canvas
                snapView:(PBResizableView **)snapView {

    PBResizableView *snapBottomToBottomView = nil;
    PBResizableView *snapBottomToTopView = nil;

    if (snapView != NULL) {
        *snapView = nil;
    }

    for (PBResizableView *view in canvas.toolViews) {

        if (view.isSelected == NO) {

            if ([self
                 bottomEdgesIntersect:rect
                 rect2:view.frame
                 containerSize:canvas.frame.size
                 snapThreshold:canvas.snapThreshold]) {

                snapBottomToBottomView = view;

                if (snapView != NULL) {
                    *snapView = view;
                }
                break;
            }

            if ([self
                 bottomEdgeIntersects:rect
                 topEdge:view.frame
                 containerSize:canvas.frame.size
                 snapThreshold:canvas.snapThreshold]) {

                snapBottomToTopView = view;

                if (snapView != NULL) {
                    *snapView = view;
                }
                break;
            }
        }
    }

    if (snapBottomToBottomView != nil) {
        return
        NSMakeRect(0.0f,
                   NSMinY(snapBottomToBottomView.frame),
                   1.0f,
                   1.0f);
    }

    if (snapBottomToTopView != nil) {
        return
        NSMakeRect(0.0f,
                   NSMaxY(snapBottomToTopView.frame),
                   1.0f,
                   1.0f);
    }

    if ([self
         bottomEdgesIntersect:rect
         rect2:[canvas.scrollView.documentView bounds]
         containerSize:canvas.frame.size
         snapThreshold:canvas.snapThreshold]) {

        return
        NSMakeRect(0.0f,
                   0.0f,
                   1.0f,
                   1.0f);
    }

    return NSZeroRect;
}

- (NSRect)leftSnapRect:(NSRect)rect
          resizingRect:(BOOL)resizingRect
                canvas:(PBDrawingCanvas *)canvas
              snapView:(PBResizableView **)snapView {

    PBResizableView *snapLeftToLeftView = nil;
    PBResizableView *snapLeftToRightView = nil;

    if (snapView != NULL) {
        *snapView = nil;
    }

    for (PBResizableView *view in canvas.toolViews) {

        if (view.isSelected == NO) {

            if ([self
                 leftEdgesIntersect:rect
                 rect2:view.frame
                 containerSize:canvas.frame.size
                 snapThreshold:canvas.snapThreshold]) {

                snapLeftToLeftView = view;

                if (snapView != NULL) {
                    *snapView = view;
                }
                break;
            }

            if ([self
                 leftEdgeIntersects:rect
                 rightEdge:view.frame
                 containerSize:canvas.frame.size
                 snapThreshold:canvas.snapThreshold]) {

                snapLeftToRightView = view;

                if (snapView != NULL) {
                    *snapView = view;
                }
                break;
            }
        }
    }

    if (snapLeftToLeftView != nil) {
        return
        NSMakeRect(NSMinX(snapLeftToLeftView.frame),
                   0.0f,
                   1.0f,
                   1.0f);
    }

    if (snapLeftToRightView != nil) {
        return
        NSMakeRect(NSMaxX(snapLeftToRightView.frame),
                   0.0f,
                   1.0f,
                   1.0f);
    }

    if ([self
         leftEdgesIntersect:rect
         rect2:[canvas.scrollView.documentView bounds]
         containerSize:canvas.frame.size
         snapThreshold:canvas.snapThreshold]) {

        return
        NSMakeRect(0.0f,
                   0.0f,
                   1.0f,
                   1.0f);
    }

    return NSZeroRect;
}

- (NSRect)rightSnapRect:(NSRect)rect
           resizingRect:(BOOL)resizingRect
                 canvas:(PBDrawingCanvas *)canvas
               snapView:(PBResizableView **)snapView {

    PBResizableView *snapRightToRightView = nil;
    PBResizableView *snapRightToLeftView = nil;

    if (snapView != NULL) {
        *snapView = nil;
    }

    for (PBResizableView *view in canvas.toolViews) {

        if (view.isSelected == NO) {

            if ([self
                 rightEdgesIntersect:rect
                 rect2:view.frame
                 containerSize:canvas.frame.size
                 snapThreshold:canvas.snapThreshold]) {

                snapRightToRightView = view;

                if (snapView != NULL) {
                    *snapView = view;
                }
                break;
            }

            if ([self
                 rightEdgeIntersects:rect
                 leftEdge:view.frame
                 containerSize:canvas.frame.size
                 snapThreshold:canvas.snapThreshold]) {

                snapRightToLeftView = view;

                if (snapView != NULL) {
                    *snapView = view;
                }
                break;
            }
        }
    }

    if (snapRightToRightView != nil) {

        if (resizingRect) {
            return
            NSMakeRect(NSMaxX(snapRightToRightView.frame),
                       0.0f,
                       1.0f,
                       1.0f);
        } else {
            return
            NSMakeRect(NSMaxX(snapRightToRightView.frame) - NSWidth(rect),
                       0.0f,
                       1.0f,
                       1.0f);
        }
    }

    if (snapRightToLeftView != nil) {

        if (resizingRect) {
            return
            NSMakeRect(NSMinX(snapRightToLeftView.frame),
                       0.0f,
                       1.0f,
                       1.0f);
        } else {
            return
            NSMakeRect(NSMinX(snapRightToLeftView.frame) - NSWidth(rect),
                       0.0f,
                       1.0f,
                       1.0f);
        }
    }
    
    if ([self
         rightEdgesIntersect:rect
         rect2:[canvas.scrollView.documentView bounds]
         containerSize:canvas.frame.size
         snapThreshold:canvas.snapThreshold]) {

        if (resizingRect) {
            return
            NSMakeRect(NSMaxX([canvas.scrollView.documentView bounds]),
                       0.0f,
                       1.0f,
                       1.0f);
        } else {
            return
            NSMakeRect(NSMaxX([canvas.scrollView.documentView bounds]) - NSWidth(rect),
                       0.0f,
                       1.0f,
                       1.0f);
        }
    }
    
    return NSZeroRect;
}

- (BOOL)topEdgesIntersect:(NSRect)rect1
                    rect2:(NSRect)rect2
            containerSize:(NSSize)containerSize
            snapThreshold:(CGFloat)snapThreshold {

    NSRect snapRect1 =
    NSMakeRect(0.0f,
               NSMaxY(rect1) - snapThreshold,
               containerSize.width,
               snapThreshold * 2.0f);

    NSRect snapRect2 =
    NSMakeRect(0.0f,
               NSMaxY(rect2) - snapThreshold,
               containerSize.width,
               snapThreshold * 2.0f);

    return NSIntersectsRect(snapRect1, snapRect2);
}

- (BOOL)topEdgeIntersects:(NSRect)rect1
               bottomEdge:(NSRect)rect2
            containerSize:(NSSize)containerSize
            snapThreshold:(CGFloat)snapThreshold {

    NSRect snapRect1 =
    NSMakeRect(0.0f,
               NSMaxY(rect1) - snapThreshold,
               containerSize.width,
               snapThreshold * 2.0f);

    NSRect snapRect2 =
    NSMakeRect(0.0f,
               NSMinY(rect2) - snapThreshold,
               containerSize.width,
               snapThreshold * 2.0f);

    return NSIntersectsRect(snapRect1, snapRect2);
}

- (BOOL)bottomEdgesIntersect:(NSRect)rect1
                       rect2:(NSRect)rect2
               containerSize:(NSSize)containerSize
               snapThreshold:(CGFloat)snapThreshold {

    NSRect snapRect1 =
    NSMakeRect(0.0f,
               NSMinY(rect1) - snapThreshold,
               containerSize.width,
               snapThreshold * 2.0f);

    NSRect snapRect2 =
    NSMakeRect(0.0f,
               NSMinY(rect2) - snapThreshold,
               containerSize.width,
               snapThreshold * 2.0f);

    return NSIntersectsRect(snapRect1, snapRect2);
}

- (BOOL)bottomEdgeIntersects:(NSRect)rect1
                     topEdge:(NSRect)rect2
               containerSize:(NSSize)containerSize
               snapThreshold:(CGFloat)snapThreshold {

    NSRect snapRect1 =
    NSMakeRect(0.0f,
               NSMinY(rect1) - snapThreshold,
               containerSize.width,
               snapThreshold * 2.0f);

    NSRect snapRect2 =
    NSMakeRect(0.0f,
               NSMaxY(rect2) - snapThreshold,
               containerSize.width,
               snapThreshold * 2.0f);

    return NSIntersectsRect(snapRect1, snapRect2);
}

- (BOOL)leftEdgesIntersect:(NSRect)rect1
                     rect2:(NSRect)rect2
             containerSize:(NSSize)containerSize
             snapThreshold:(CGFloat)snapThreshold {

    NSRect snapRect1 =
    NSMakeRect(NSMinX(rect1) - snapThreshold,
               0.0f,
               snapThreshold * 2.0f,
               containerSize.height);

    NSRect snapRect2 =
    NSMakeRect(NSMinX(rect2) - snapThreshold,
               0.0f,
               snapThreshold * 2.0f,
               containerSize.height);

    return NSIntersectsRect(snapRect1, snapRect2);
}

- (BOOL)leftEdgeIntersects:(NSRect)rect1
                 rightEdge:(NSRect)rect2
             containerSize:(NSSize)containerSize
             snapThreshold:(CGFloat)snapThreshold {

    NSRect snapRect1 =
    NSMakeRect(NSMinX(rect1) - snapThreshold,
               0.0f,
               snapThreshold * 2.0f,
               containerSize.height);

    NSRect snapRect2 =
    NSMakeRect(NSMaxX(rect2) - snapThreshold,
               0.0f,
               snapThreshold * 2.0f,
               containerSize.height);

    return NSIntersectsRect(snapRect1, snapRect2);
}

- (BOOL)rightEdgesIntersect:(NSRect)rect1
                      rect2:(NSRect)rect2
              containerSize:(NSSize)containerSize
              snapThreshold:(CGFloat)snapThreshold {

    NSRect snapRect1 =
    NSMakeRect(NSMaxX(rect1) - snapThreshold,
               0.0f,
               snapThreshold * 2.0f,
               containerSize.height);

    NSRect snapRect2 =
    NSMakeRect(NSMaxX(rect2) - snapThreshold,
               0.0f,
               snapThreshold * 2.0f,
               containerSize.height);

    return NSIntersectsRect(snapRect1, snapRect2);
}

- (BOOL)rightEdgeIntersects:(NSRect)rect1
                   leftEdge:(NSRect)rect2
              containerSize:(NSSize)containerSize
              snapThreshold:(CGFloat)snapThreshold {

    NSRect snapRect1 =
    NSMakeRect(NSMaxX(rect1) - snapThreshold,
               0.0f,
               snapThreshold * 2.0f,
               containerSize.height);

    NSRect snapRect2 =
    NSMakeRect(NSMinX(rect2) - snapThreshold,
               0.0f,
               snapThreshold * 2.0f,
               containerSize.height);
    
    return NSIntersectsRect(snapRect1, snapRect2);
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
