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
    
    CGFloat minDimension = 1.0f / canvas.window.backingScaleFactor;
    CGFloat padding = minDimension * canvas.scaleFactor;

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

    CGFloat minDimension = 1.0f / canvas.window.backingScaleFactor;

    point = [canvas roundedPoint:point];

    NSRect frame = canvas.resizingView.frame;

    NSPoint mouseLocation = [canvas mouseLocationInDocument];

    BOOL nonZeroRect = NSEqualRects(frame, NSZeroRect) == NO;
    CGFloat xOffset, yOffset;

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
            frame.size.height = [canvas roundedValue:point.y - NSMinY(frame) + yOffset];
            frame.size.height = MAX(minDimension, NSHeight(frame));

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
            frame.size.height = [canvas roundedValue:_selectedViewAnchor.y - NSMinY(frame)];
            frame.size.height = MAX(minDimension, NSHeight(frame));

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
            frame.size.width = [canvas roundedValue:_selectedViewAnchor.x - NSMinX(frame)];
            frame.size.width = MAX(minDimension, NSWidth(frame));

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
            frame.size.width = [canvas roundedValue:point.x - NSMinX(frame)];
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
            frame.size.height = [canvas roundedValue:point.y - NSMinY(frame)];
            frame.size.height = MAX(minDimension, NSHeight(frame));

            frame.origin.x = point.x;
            frame.size.width = [canvas roundedValue:_selectedViewAnchor.x - NSMinX(frame)];
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
            frame.size.height = [canvas roundedValue:point.y - NSMinY(frame)];
            frame.size.height = MAX(minDimension, NSHeight(frame));

            frame.origin.x = _selectedViewAnchor.x;
            frame.size.width = [canvas roundedValue:point.x - NSMinX(frame)];
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
            frame.size.height = [canvas roundedValue:_selectedViewAnchor.y - NSMinY(frame)];
            frame.size.height = MAX(minDimension, NSHeight(frame));

            frame.origin.x = point.x;
            frame.size.width = [canvas roundedValue:_selectedViewAnchor.x - NSMinX(frame)];
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
            frame.size.height = [canvas roundedValue:_selectedViewAnchor.y - NSMinY(frame)];
            frame.size.height = MAX(minDimension, NSHeight(frame));
            
            frame.origin.x = _selectedViewAnchor.x;
            frame.size.width = [canvas roundedValue:point.x - NSMinX(frame)];
            frame.size.width = MAX(minDimension, NSWidth(frame));
            
        } break;
            
        default:
            break;
    }
    
    if (canvas.snapThreshold > 0.0f) {
        
        BOOL snapToContainerTop = NO;
        BOOL snapToContainerBottom = NO;
        BOOL snapToContainerLeft = NO;
        BOOL snapToContainerRight = NO;
        
        PBResizableView *snapTopToTopView = nil;
        PBResizableView *snapBottomToBottomView = nil;
        PBResizableView *snapLeftToLeftView = nil;
        PBResizableView *snapRightToRightView = nil;
        PBResizableView *snapTopToBottomView = nil;
        PBResizableView *snapBottomToTopView = nil;
        PBResizableView *snapLeftToRightView = nil;
        PBResizableView *snapRightToLeftView = nil;
        
        if (canvas.selectedViews.count == 1) {
            
            if ([self
                 topEdgesIntersect:frame
                 rect2:[canvas.scrollView.documentView bounds]
                 containerSize:canvas.frame.size
                 snapThreshold:canvas.snapThreshold]) {
                snapToContainerTop = YES;
            }
            
            if ([self
                 bottomEdgesIntersect:frame
                 rect2:[canvas.scrollView.documentView bounds]
                 containerSize:canvas.frame.size
                 snapThreshold:canvas.snapThreshold]) {
                snapToContainerBottom = YES;
            }
            
            if ([self
                 leftEdgesIntersect:frame
                 rect2:[canvas.scrollView.documentView bounds]
                 containerSize:canvas.frame.size
                 snapThreshold:canvas.snapThreshold]) {
                snapToContainerLeft = YES;
            }
            
            if ([self
                 rightEdgesIntersect:frame
                 rect2:[canvas.scrollView.documentView bounds]
                 containerSize:canvas.frame.size
                 snapThreshold:canvas.snapThreshold]) {
                snapToContainerRight = YES;
            }
            
            for (PBResizableView *view in canvas.toolViews) {
                
                if (view.isSelected == NO) {
                    
                    if ([self
                         topEdgesIntersect:view.frame
                         rect2:frame
                         containerSize:canvas.frame.size
                         snapThreshold:canvas.snapThreshold]) {
                        snapTopToTopView = view;
                        [view highlight];
                    }
                    
                    if ([self
                         topEdgeIntersects:frame
                         bottomEdge:view.frame
                         containerSize:canvas.frame.size
                         snapThreshold:canvas.snapThreshold]) {
                        snapTopToBottomView = view;
                        [view highlight];
                    }
                    
                    if ([self
                         bottomEdgesIntersect:view.frame
                         rect2:frame
                         containerSize:canvas.frame.size
                         snapThreshold:canvas.snapThreshold]) {
                        snapBottomToBottomView = view;
                        [view highlight];
                    }
                    
                    if ([self
                         bottomEdgeIntersects:frame
                         topEdge:view.frame
                         containerSize:canvas.frame.size
                         snapThreshold:canvas.snapThreshold]) {
                        snapBottomToTopView = view;
                        [view highlight];
                    }
                    
                    if ([self
                         leftEdgesIntersect:view.frame
                         rect2:frame
                         containerSize:canvas.frame.size
                         snapThreshold:canvas.snapThreshold]) {
                        snapLeftToLeftView = view;
                        [view highlight];
                    }
                    
                    if ([self
                         leftEdgeIntersects:frame
                         rightEdge:view.frame
                         containerSize:canvas.frame.size
                         snapThreshold:canvas.snapThreshold]) {
                        snapLeftToRightView = view;
                        [view highlight];
                    }
                    
                    if ([self
                         rightEdgesIntersect:view.frame
                         rect2:frame
                         containerSize:canvas.frame.size
                         snapThreshold:canvas.snapThreshold]) {
                        snapRightToRightView = view;
                        [view highlight];
                    }
                    
                    if ([self
                         rightEdgeIntersects:frame
                         leftEdge:view.frame
                         containerSize:canvas.frame.size
                         snapThreshold:canvas.snapThreshold]) {
                        snapRightToLeftView = view;
                        [view highlight];
                    }
                }
            }
        }
        
        CGFloat pos;
        CGFloat delta;
        
        if (snapToContainerTop) {
            
            pos = NSMaxY([canvas.scrollView.documentView bounds]) - NSHeight(frame);
            delta = pos - frame.origin.y;
            frame.size.height += delta;
        }
        
        if (snapToContainerBottom) {
            
            pos = 0.0f;
            delta = pos - frame.origin.y;
            frame.origin.y = pos;
            frame.size.height -= delta;
        }
        
        if (snapToContainerLeft) {
            
            pos = 0.0f;
            delta = pos - frame.origin.x;
            frame.origin.x = pos;
            frame.size.width -= delta;
        }
        
        if (snapToContainerRight) {
            
            pos = NSMaxX([canvas.scrollView.documentView bounds]) - NSWidth(frame);
            delta = pos - frame.origin.x;
            frame.size.width += delta;
        }
        
        if (snapBottomToBottomView != nil) {
            
            pos = NSMinY(snapBottomToBottomView.frame);
            delta = pos - frame.origin.y;
            frame.origin.y = pos;
            frame.size.height -= delta;
        }
        
        if (snapBottomToTopView != nil) {
            
            pos = NSMaxY(snapBottomToTopView.frame);
            delta = pos - frame.origin.y;
            frame.origin.y = pos;
            frame.size.height -= delta;
        }
        
        if (snapTopToTopView != nil) {
            
            pos = NSMaxY(snapTopToTopView.frame) - NSHeight(frame);
            delta = pos - frame.origin.y;
            frame.size.height += delta;
        }
        
        if (snapTopToBottomView != nil) {
            
            pos = NSMinY(snapTopToBottomView.frame) - NSHeight(frame);
            delta = pos - frame.origin.y;
            frame.size.height += delta;
        }
        
        if (snapRightToRightView != nil) {
            
            pos = NSMaxX(snapRightToRightView.frame) - NSWidth(frame);
            delta = pos - frame.origin.x;
            frame.size.width += delta;
        }
        
        if (snapRightToLeftView != nil) {
            
            pos = NSMinX(snapRightToLeftView.frame) - NSWidth(frame);
            delta = pos - frame.origin.x;
            frame.size.width += delta;
        }
        
        if (snapLeftToLeftView != nil) {
            
            pos = NSMinX(snapLeftToLeftView.frame);
            delta = pos - frame.origin.x;
            frame.origin.x = pos;
            frame.size.width -= delta;
        }
        
        if (snapLeftToRightView != nil) {
            
            pos = NSMaxX(snapLeftToRightView.frame);
            delta = pos - frame.origin.x;
            frame.origin.x = pos;
            frame.size.width -= delta;
        }
    }

    [canvas.resizingView
     setViewFrame:frame
     withContainerFrame:[canvas.scrollView.documentView frame]
     animate:NO];
    
    [canvas updateInfoLabel:canvas.resizingView];
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
