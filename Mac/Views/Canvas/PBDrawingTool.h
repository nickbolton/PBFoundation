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

- (PBResizableView *)mouseInteractingViewInCanvas:(PBDrawingCanvas *)canvas;

// private
- (void)determineResizeTypeForView:(NSView *)view
                           atPoint:(NSPoint)point
                          inCanvas:(PBDrawingCanvas *)canvas;
- (void)setCursorForResizeType;
- (void)determineSelectedViewAnchorPoint:(PBDrawingCanvas *)canvas;
- (void)determineSelectedViewAnchorPoint:(PBDrawingCanvas *)canvas forView:(NSView *)selectedView;
- (void)resizeSelectedViewAtPoint:(NSPoint)point
                         inCanvas:(PBDrawingCanvas *)canvas;

@end
