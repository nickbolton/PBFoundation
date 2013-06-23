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

    self.didMove = NO;
    self.moving = NO;
    
    PBResizableView *selectedView = [canvas viewAtPoint:point];

    if (selectedView != nil) {

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
        return;
    }

    NSRect frame = NSZeroRect;
    frame.origin = point;

    canvas.resizingView = [canvas createRectangle:frame];

    [canvas selectView:canvas.resizingView deselectCurrent:YES];

    self.resizeType = PBPResizeTypeDownRight;
    [self determineSelectedViewAnchorPoint:canvas];
    
    self.selectedViewMouseDownFrame = canvas.resizingView.frame;
    
    self.selectedViewAnchor = point;
    
    [canvas retagViews];
}

- (void)mouseUp:(PBClickableView *)view
        atPoint:(NSPoint)point
       inCanvas:(PBDrawingCanvas *)canvas {

    [super mouseUp:view atPoint:point inCanvas:canvas];
    
    if (self.didMove == NO && [NSEvent isCurrentModifiersExactly:NSCommandKeyMask] == NO) {
        if (canvas.resizingView != nil) {

            NSArray *subviews = [canvas.subviews copy];
            for (PBResizableView *view in subviews) {
                if (view != canvas.resizingView) {
                    [canvas deselectView:view];
                }
            }
        }
    }

    canvas.resizingView = nil;

    for (PBResizableView *selectedView in canvas.selectedViews) {

        NSString *viewKey = [canvas viewKey:selectedView];

        canvas.mouseDownSelectedViewOrigins[viewKey] =
        [NSValue valueWithPoint:selectedView.frame.origin];
    }

    self.moving = NO;
}

- (void)mouseDragged:(PBClickableView *)view
             toPoint:(NSPoint)point
            inCanvas:(PBDrawingCanvas *)canvas {

    [super mouseDragged:view toPoint:point inCanvas:canvas];

    if (self.resizeType != PBPResizeTypeNone) {

        PBResizableView *selectedView = canvas.selectedViews.lastObject;

        [canvas selectView:selectedView deselectCurrent:YES];
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
