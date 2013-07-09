//
//  PBDrawingTool.h
//  Prototype
//
//  Created by Nick Bolton on 6/23/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBDrawingCanvas.h"

@interface PBDrawingTool : NSObject <PBDrawingTool>

@property (nonatomic) NSPoint mouseDownPoint;
@property (nonatomic) NSRect boundingRect;
@property (nonatomic) NSRect mouseDownStartingRect;
@property (nonatomic) PBPResizeType resizeType;
@property (nonatomic) NSPoint selectedViewAnchor;
@property (nonatomic) NSRect selectedViewMouseDownFrame;
@property (nonatomic) BOOL didMove;
@property (nonatomic) BOOL didResize;
@property (nonatomic) BOOL didCreate;
@property (nonatomic) BOOL moving;
@property (nonatomic) BOOL shouldSnapOnResize;

- (PBResizableView *)mouseInteractingViewInCanvas:(PBDrawingCanvas *)canvas;

// private
- (void)determineResizeTypeForView:(PBResizableView *)view
                           atPoint:(NSPoint)point
                          inCanvas:(PBDrawingCanvas *)canvas;
- (void)setCursorForResizeType;
- (void)determineSelectedViewAnchorPoint:(PBDrawingCanvas *)canvas;
- (void)determineSelectedViewAnchorPoint:(PBDrawingCanvas *)canvas forView:(PBResizableView *)selectedView;
- (void)resizeSelectedViewAtPoint:(NSPoint)point
                         inCanvas:(PBDrawingCanvas *)canvas;

// edge operations

- (NSRect)topSnapRect:(NSRect)rect
         resizingRect:(BOOL)resizingRect
               canvas:(PBDrawingCanvas *)canvas
             snapView:(PBResizableView **)snapView;
- (NSRect)bottomSnapRect:(NSRect)rect
            resizingRect:(BOOL)resizingRect
                  canvas:(PBDrawingCanvas *)canvas
                snapView:(PBResizableView **)snapView;
- (NSRect)leftSnapRect:(NSRect)rect
          resizingRect:(BOOL)resizingRect
                canvas:(PBDrawingCanvas *)canvas
              snapView:(PBResizableView **)snapView;
- (NSRect)rightSnapRect:(NSRect)rect
           resizingRect:(BOOL)resizingRect
                 canvas:(PBDrawingCanvas *)canvas
               snapView:(PBResizableView **)snapView;
- (BOOL)topEdgesIntersect:(NSRect)rect1
                    rect2:(NSRect)rect2
            containerSize:(NSSize)containerSize
            snapThreshold:(CGFloat)snapThreshold;
- (BOOL)topEdgeIntersects:(NSRect)rect1
               bottomEdge:(NSRect)rect2
            containerSize:(NSSize)containerSize
            snapThreshold:(CGFloat)snapThreshold;
- (BOOL)bottomEdgesIntersect:(NSRect)rect1
                       rect2:(NSRect)rect2
               containerSize:(NSSize)containerSize
               snapThreshold:(CGFloat)snapThreshold;
- (BOOL)bottomEdgeIntersects:(NSRect)rect1
                     topEdge:(NSRect)rect2
               containerSize:(NSSize)containerSize
               snapThreshold:(CGFloat)snapThreshold;
- (BOOL)leftEdgesIntersect:(NSRect)rect1
                     rect2:(NSRect)rect2
             containerSize:(NSSize)containerSize
             snapThreshold:(CGFloat)snapThreshold;
- (BOOL)leftEdgeIntersects:(NSRect)rect1
                 rightEdge:(NSRect)rect2
             containerSize:(NSSize)containerSize
             snapThreshold:(CGFloat)snapThreshold;
- (BOOL)rightEdgesIntersect:(NSRect)rect1
                      rect2:(NSRect)rect2
              containerSize:(NSSize)containerSize
              snapThreshold:(CGFloat)snapThreshold;
- (BOOL)rightEdgeIntersects:(NSRect)rect1
                   leftEdge:(NSRect)rect2
              containerSize:(NSSize)containerSize
              snapThreshold:(CGFloat)snapThreshold;


@end
