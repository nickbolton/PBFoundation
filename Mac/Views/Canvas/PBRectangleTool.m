//
//  PBRectangleTool.m
//  Prototype
//
//  Created by Nick Bolton on 6/23/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBRectangleTool.h"
#import "PBResizableView.h"

@interface PBRectangleTool() {
}

@end

@implementation PBRectangleTool

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

    canvas.showingInfo = YES;

    if (selectedView != nil) {

        self.mouseDownStartingRect = selectedView.frame;

        [self
         determineSelectedViewAnchorPoint:canvas
         forView:selectedView];

        if ([NSEvent isCurrentModifiersExactly:NSCommandKeyMask]) {

            if ([canvas.selectedViews containsObject:selectedView]) {
                [canvas deselectView:selectedView];
            } else {
                [canvas selectView:selectedView deselectCurrent:NO];

                canvas.resizingView = (id)selectedView;

                self.selectedViewMouseDownFrame = selectedView.frame;

                self.moving = YES;
            }
        } else {

            if ([canvas.selectedViews containsObject:selectedView] == NO) {
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

    canvas.resizingView = [canvas createRectangle:frame];
    canvas.resizingView.showingInfo = YES;
    canvas.resizingView.updating = YES;

    [canvas selectView:canvas.resizingView deselectCurrent:YES];

    self.didCreate = YES;
    self.resizeType = PBPResizeTypeDownRight;
    [self determineSelectedViewAnchorPoint:canvas forView:canvas.resizingView];
    
    self.selectedViewMouseDownFrame = canvas.resizingView.frame;
    
    self.selectedViewAnchor = point;
    
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

    canvas.showingInfo = NO;
    canvas.resizingView.showingInfo = NO;
    canvas.resizingView.updating = NO;
    canvas.resizingView = nil;

    for (PBResizableView *selectedView in canvas.selectedViews) {

        NSString *viewKey = [canvas viewKey:selectedView];

        canvas.mouseDownSelectedViewOrigins[viewKey] =
        [NSValue valueWithPoint:selectedView.frame.origin];
    }

    self.moving = NO;

    [canvas updateGuides];
}

- (void)mouseDragged:(PBClickableView *)view
             toPoint:(NSPoint)point
            inCanvas:(PBDrawingCanvas *)canvas {

    [super mouseDragged:view toPoint:point inCanvas:canvas];

    if (self.resizeType != PBPResizeTypeNone) {

        self.didResize = YES;

        if ([canvas isViewSelected:canvas.resizingView] == NO) {
            [canvas selectView:canvas.resizingView deselectCurrent:YES];
        }
        [self resizeSelectedViewAtPoint:point inCanvas:canvas];
        return;
    }

    if (self.moving) {

        self.didMove = YES;

        CGFloat xDelta = point.x - self.mouseDownPoint.x;
        CGFloat yDelta = point.y - self.mouseDownPoint.y;

        for (PBResizableView *selectedView in canvas.selectedViews) {

            NSString *viewKey = [canvas viewKey:selectedView];

            NSPoint mouseDownSelectedViewOrigin =
            [canvas.mouseDownSelectedViewOrigins[viewKey] pointValue];

            NSRect frame = selectedView.frame;
            frame.origin.x = mouseDownSelectedViewOrigin.x + xDelta;
            frame.origin.y = mouseDownSelectedViewOrigin.y + yDelta;

            selectedView.frame = frame;
        }
    }
}

@end
