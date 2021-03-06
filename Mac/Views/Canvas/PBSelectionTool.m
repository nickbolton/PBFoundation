//
//  PBSelectionTool.m
//  Prototype
//
//  Created by Nick Bolton on 6/23/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBSelectionTool.h"
#import "PBResizableView.h"

@interface PBSelectionTool() {
}

@property (nonatomic, strong) PBResizableView *selectionView;

@end

@implementation PBSelectionTool

- (void)cleanup {
    [_selectionView removeFromSuperview];
    self.selectionView = nil;
}

- (BOOL)shouldDeselectView:(PBResizableView *)view {
    return _selectionView == nil || view != _selectionView;
}

- (PBResizableView *)viewOnTop {
    return _selectionView;
}

- (PBResizableView *)mouseInteractingViewInCanvas:(PBDrawingCanvas *)canvas {
    return _selectionView;
}

- (PBResizableView *)createRectangle:(NSRect)frame
                            inCanvas:(PBDrawingCanvas *)canvas {

    PBResizableView *view = [[PBResizableView alloc] initWithFrame:frame];
    view.borderColor = [NSColor whiteColor];
    view.borderWidth = 1;
    view.key = [NSString timestampedGuid];
    view.borderDashPattern = @[@2, @2];
    view.delegate = canvas;
    view.drawingCanvas = canvas;

    return view;
}

- (void)mouseMovedToPoint:(NSPoint)point inCanvas:(PBDrawingCanvas *)canvas {

    self.resizeType = PBPResizeTypeNone;

    if (NSPointInRect(point, _selectionView.frame)) {
        [self
         determineResizeTypeForView:_selectionView
         atPoint:point
         inCanvas:canvas];
    }

    [self setCursorForResizeType];
}

- (void)mouseDown:(PBClickableView *)view
          atPoint:(NSPoint)point
         inCanvas:(PBDrawingCanvas *)canvas {

    [super mouseDown:view atPoint:point inCanvas:canvas];

    self.moving = NO;

    if (NSPointInRect(point, _selectionView.frame)) {

        canvas.resizingView = _selectionView;

        self.selectedViewMouseDownFrame = _selectionView.frame;

        self.moving = YES;
        
    } else {

        [_selectionView removeFromSuperview];
        self.selectionView = nil;
    }
}

- (NSRect)movedRectAtPoint:(NSPoint)point inCanvas:(PBDrawingCanvas *)canvas {

    CGFloat xDelta = point.x - self.mouseDownPoint.x;
    CGFloat yDelta = point.y - self.mouseDownPoint.y;

    NSPoint mouseDownSelectedViewOrigin =
    [canvas.mouseDownSelectedViewOrigins[_selectionView.key] pointValue];

    NSRect frame = _selectionView.frame;
    frame.origin.x = mouseDownSelectedViewOrigin.x + xDelta;
    frame.origin.y = mouseDownSelectedViewOrigin.y + yDelta;
    return frame;
}

- (void)mouseUp:(PBClickableView *)view
        atPoint:(NSPoint)point
       inCanvas:(PBDrawingCanvas *)canvas {

    [super mouseUp:view atPoint:point inCanvas:canvas];

    if (self.moving) {
        self.boundingRect = [self movedRectAtPoint:point inCanvas:canvas];
    }

    [canvas selectOnlyViewsInRect:self.boundingRect];

    if (_selectionView != nil) {
        canvas.mouseDownSelectedViewOrigins[_selectionView.key] =
        [NSValue valueWithPoint:_selectionView.frame.origin];
    }

    self.moving = NO;
}

- (void)mouseDragged:(PBClickableView *)view
             toPoint:(NSPoint)point
            inCanvas:(PBDrawingCanvas *)canvas {

    [super mouseDragged:view toPoint:point inCanvas:canvas];

    if (self.resizeType != PBPResizeTypeNone) {
        [self resizeSelectedViewAtPoint:point inCanvas:canvas];
        self.boundingRect = _selectionView.frame;
        [canvas selectOnlyViewsInRect:self.boundingRect];
        return;
    }

    if (self.moving) {

        NSRect frame = [self movedRectAtPoint:point inCanvas:canvas];

        [_selectionView
         setViewFrame:frame
         withContainerFrame:[canvas.scrollView.documentView frame]
         animate:NO];
        self.boundingRect = frame;

    } else {

        if (_selectionView == nil) {
            self.selectionView =
            [self createRectangle:self.boundingRect inCanvas:canvas];
            [canvas.scrollView.documentView addSubview:_selectionView positioned:NSWindowAbove relativeTo:nil];
            [_selectionView setupConstraints];

        } else {
            [self.selectionView
             setViewFrame:self.boundingRect
             withContainerFrame:[canvas.scrollView.documentView frame]
             animate:NO];
        }
    }

    [canvas selectOnlyViewsInRect:self.boundingRect];
    [canvas.scrollView.documentView addSubview:_selectionView positioned:NSWindowAbove relativeTo:nil];
}

@end
