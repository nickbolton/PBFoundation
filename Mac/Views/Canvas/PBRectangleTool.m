//
//  PBRectangleTool.m
//  Prototype
//
//  Created by Nick Bolton on 6/23/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBRectangleTool.h"
#import "PBResizableView.h"
#import "PBGuideView.h"

@interface PBRectangleTool() {
}

@end

@implementation PBRectangleTool

- (void)determineResizeTypeForView:(PBResizableView *)view
                           atPoint:(NSPoint)point
                          inCanvas:(PBDrawingCanvas *)canvas {

    if (view.backgroundImage != nil) {
        self.resizeType = PBPResizeTypeNone;
    } else {
        [super determineResizeTypeForView:view atPoint:point inCanvas:canvas];
    }
}

- (void)mouseMovedToPoint:(NSPoint)point inCanvas:(PBDrawingCanvas *)canvas {

    NSView *view = [canvas viewAtPoint:point];

    self.resizeType = PBPResizeTypeNone;

    if (view != nil) {
        [self determineResizeTypeForView:view atPoint:point inCanvas:canvas];
    }

    [self setCursorForResizeType];
}

- (void)mouseDown:(PBClickableView *)view
          atPoint:(NSPoint)point
         inCanvas:(PBDrawingCanvas *)canvas {

    [super mouseDown:view atPoint:point inCanvas:canvas];

    point.x = roundf(point.x);
    point.y = roundf(point.y);
    
    PBResizableView *selectedView = [canvas viewAtPoint:point];

    if (selectedView != nil) {

        self.mouseDownStartingRect = selectedView.frame;

        [self
         determineSelectedViewAnchorPoint:canvas
         forView:selectedView];

        if ([NSEvent isCurrentModifiersExactly:NSCommandKeyMask]) {

            if (selectedView.isSelected) {
                [canvas deselectView:selectedView];
            } else {
                [canvas selectView:selectedView deselectCurrent:NO];

                canvas.resizingView = (id)selectedView;

                self.selectedViewMouseDownFrame = selectedView.frame;

                self.moving = YES;
            }
        } else if ([NSEvent isCurrentModifiersExactly:NSAlternateKeyMask]) {

            [self
             createRectangle:selectedView.frame
             deselectCurrent:YES
             resizeType:PBPResizeTypeNone
             inCanvas:canvas];

            self.moving = YES;

        } else {

            if (selectedView.isSelected == NO) {
                [canvas selectView:(id)selectedView deselectCurrent:YES];
            }

            canvas.resizingView = (id)selectedView;

            self.selectedViewMouseDownFrame = selectedView.frame;

            self.moving = YES;
        }

        canvas.resizingView.showingInfo = YES;
        canvas.resizingView.updating = YES;

        if ([NSEvent isCurrentModifiersExactly:NSAlternateKeyMask]) {
            self.resizeType = PBPResizeTypeNone;
        }

        return;
    }

    NSRect frame = NSZeroRect;
    frame.origin = point;

    [self
     createRectangle:frame
     deselectCurrent:YES
     resizeType:PBPResizeTypeDownRight
     inCanvas:canvas];
}

- (void)createRectangle:(NSRect)frame
        deselectCurrent:(BOOL)deselectCurrent
             resizeType:(PBPResizeType)resizeType
               inCanvas:(PBDrawingCanvas *)canvas {

    canvas.resizingView = [canvas createRectangle:frame];
    canvas.resizingView.showingInfo = YES;
    canvas.resizingView.updating = YES;

    [canvas selectView:canvas.resizingView deselectCurrent:deselectCurrent];

    self.didCreate = YES;
    self.resizeType = resizeType;
    [self determineSelectedViewAnchorPoint:canvas forView:canvas.resizingView];

    self.selectedViewMouseDownFrame = canvas.resizingView.frame;

    self.selectedViewAnchor = frame.origin;

    [canvas retagViews];
}

- (void)mouseUp:(PBClickableView *)view
        atPoint:(NSPoint)point
       inCanvas:(PBDrawingCanvas *)canvas {

    [super mouseUp:view atPoint:point inCanvas:canvas];

    if (canvas.resizingView != nil &&
        NSEqualSizes(NSZeroSize, canvas.resizingView.frame.size)) {
        [canvas deleteViews:@[canvas.resizingView]];
        return;
    }

    if (self.didCreate == NO &&
        self.didResize &&
        canvas.resizingView != nil &&
        NSEqualRects(self.mouseDownStartingRect, canvas.resizingView.frame) == NO) {

        [[canvas.undoManager prepareWithInvocationTarget:canvas]
         resizeViewAt:canvas.resizingView.frame toFrame:self.mouseDownStartingRect];
        [canvas.undoManager setActionName:PBLoc(@"Resize Rectangle")];
    }
    
    if (self.didMove == NO && [NSEvent isCurrentModifiersExactly:NSCommandKeyMask] == NO) {
        if (canvas.resizingView != nil) {

            for (PBResizableView *view in canvas.toolViews) {
                if (view != canvas.resizingView) {
                    [canvas deselectView:view];
                }
            }
        }
    }

//    BOOL showInfo = NSPointInRect(point, canvas.resizingView.frame);

//    canvas.resizingView.showingInfo = showInfo;
    canvas.resizingView.updating = NO;
    canvas.resizingView = nil;

    for (PBResizableView *selectedView in canvas.selectedViews) {

        canvas.mouseDownSelectedViewOrigins[selectedView.key] =
        [NSValue valueWithPoint:selectedView.frame.origin];
    }

    self.moving = NO;
}

- (void)mouseDragged:(PBClickableView *)view
             toPoint:(NSPoint)point
            inCanvas:(PBDrawingCanvas *)canvas {

    [super mouseDragged:view toPoint:point inCanvas:canvas];

    if (self.resizeType != PBPResizeTypeNone) {

        self.didResize = YES;

        [canvas selectView:canvas.resizingView deselectCurrent:YES];
        [self resizeSelectedViewAtPoint:point inCanvas:canvas];
        return;
    }

    if (self.moving) {

        self.didMove = YES;

        for (PBResizableView *view in canvas.toolViews) {

            if (view.isSelected == NO) {
                [view unhighlight];
            }
        }

        CGFloat xDelta = roundf(point.x - self.mouseDownPoint.x);
        CGFloat yDelta = roundf(point.y - self.mouseDownPoint.y);

        for (PBResizableView *selectedView in canvas.selectedViews) {

            NSPoint mouseDownSelectedViewOrigin =
            [canvas.mouseDownSelectedViewOrigins[selectedView.key] pointValue];

            NSRect frame = selectedView.frame;
            frame.origin.x = mouseDownSelectedViewOrigin.x + xDelta;
            frame.origin.y = mouseDownSelectedViewOrigin.y + yDelta;

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

                if (snapToContainerTop) {
                    frame.origin.y = NSMaxY([canvas.scrollView.documentView bounds]) - NSHeight(frame);
                }

                if (snapToContainerBottom) {
                    frame.origin.y = 0.0f;
                }

                if (snapToContainerLeft) {
                    frame.origin.x = 0.0f;
                }

                if (snapToContainerRight) {
                    frame.origin.x = NSMaxX([canvas.scrollView.documentView bounds]) - NSWidth(frame);
                }

                if (snapBottomToBottomView != nil) {
                    frame.origin.y = NSMinY(snapBottomToBottomView.frame);
                }

                if (snapBottomToTopView != nil) {
                    frame.origin.y = NSMaxY(snapBottomToTopView.frame);
                }

                if (snapTopToTopView != nil) {
                    frame.origin.y = NSMaxY(snapTopToTopView.frame) - NSHeight(frame);
                }

                if (snapTopToBottomView != nil) {
                    frame.origin.y = NSMinY(snapTopToBottomView.frame) - NSHeight(frame);
                }
                
                if (snapRightToRightView != nil) {
                    frame.origin.x = NSMaxX(snapRightToRightView.frame) - NSWidth(frame);
                }
                
                if (snapRightToLeftView != nil) {
                    frame.origin.x = NSMinX(snapRightToLeftView.frame) - NSWidth(frame);
                }
                
                if (snapLeftToLeftView != nil) {
                    frame.origin.x = NSMinX(snapLeftToLeftView.frame);
                }
                
                if (snapLeftToRightView != nil) {
                    frame.origin.x = NSMaxX(snapLeftToRightView.frame);
                }
            }

            [selectedView
             setViewFrame:frame
             withContainerFrame:[canvas.scrollView.documentView frame]
             animate:NO];
        }
    }
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

@end
