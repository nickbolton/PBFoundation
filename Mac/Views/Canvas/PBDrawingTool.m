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

@interface PBDrawingTool() {
}

@end


@implementation PBDrawingTool

- (PBResizableView *)mouseInteractingViewInCanvas:(PBDrawingCanvas *)canvas {
    return canvas.selectedViews.lastObject;
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

    NSRect frame;

    // up-left
    frame =
    NSMakeRect(NSMinX(view.frame) - detectSize,
               NSMaxY(view.frame) - detectSize,
               detectSize*2.0f,
               detectSize*2.0f);

    if (NSPointInRect(point, frame)) {
        _resizeType = PBPResizeTypeUpLeft;
        [self determineSelectedViewAnchorPoint:canvas];
        return;
    }

    // up-right
    frame =
    NSMakeRect(NSMaxX(view.frame) - detectSize,
               NSMaxY(view.frame) - detectSize,
               detectSize*2.0f,
               detectSize*2.0f);

    if (NSPointInRect(point, frame)) {
        _resizeType = PBPResizeTypeUpRight;
        [self determineSelectedViewAnchorPoint:canvas];
        return;
    }

    // down-left
    frame =
    NSMakeRect(NSMinX(view.frame) - detectSize,
               NSMinY(view.frame) - detectSize,
               detectSize*2.0f,
               detectSize*2.0f);

    if (NSPointInRect(point, frame)) {
        _resizeType = PBPResizeTypeDownLeft;
        [self determineSelectedViewAnchorPoint:canvas];
        return;
    }

    // down-right
    frame =
    NSMakeRect(NSMaxX(view.frame) - detectSize,
               NSMinY(view.frame) - detectSize,
               detectSize*2.0f,
               detectSize*2.0f);

    if (NSPointInRect(point, frame)) {
        _resizeType = PBPResizeTypeDownRight;
        [self determineSelectedViewAnchorPoint:canvas];
        return;
    }

    // left
    frame =
    NSMakeRect(NSMinX(view.frame) - detectSize,
               NSMinY(view.frame) - detectSize,
               detectSize*2.0f,
               NSHeight(view.frame) + detectSize*2.0f);

    if (NSPointInRect(point, frame)) {
        _resizeType = PBPResizeTypeLeft;
        [self determineSelectedViewAnchorPoint:canvas];
        return;
    }

    // right
    frame =
    NSMakeRect(NSMaxX(view.frame) - detectSize,
               NSMinY(view.frame) - detectSize,
               detectSize*2.0f,
               NSHeight(view.frame) + detectSize*2.0f);

    if (NSPointInRect(point, frame)) {
        _resizeType = PBPResizeTypeRight;
        [self determineSelectedViewAnchorPoint:canvas];
        return;
    }

    // up
    frame =
    NSMakeRect(NSMinX(view.frame) - detectSize,
               NSMaxY(view.frame) - detectSize,
               NSWidth(view.frame) +  detectSize*2.0f,
               detectSize*2.0f);

    if (NSPointInRect(point, frame)) {
        _resizeType = PBPResizeTypeUp;
        [self determineSelectedViewAnchorPoint:canvas];
        return;
    }

    // down
    frame =
    NSMakeRect(NSMinX(view.frame) - detectSize,
               NSMinY(view.frame) - detectSize,
               NSWidth(view.frame) +  detectSize*2.0f,
               detectSize*2.0f);

    if (NSPointInRect(point, frame)) {
        _resizeType = PBPResizeTypeDown;
        [self determineSelectedViewAnchorPoint:canvas];
        return;
    }

    _resizeType = PBPResizeTypeNone;
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
    
    canvas.resizingView.frame = frame;
}

@end
