//
//  PBDrawingCanvas.h
//  Prototype
//
//  Created by Nick Bolton on 6/23/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBClickableView.h"

typedef NS_ENUM(NSInteger, PBDrawingCanvasToolType) {

    PBDrawingCanvasToolTypeNone = 0,
    PBDrawingCanvasToolTypeSelect,
    PBDrawingCanvasToolTypeRectangle,
};

typedef NS_ENUM(NSInteger, PBGuidePosition) {

    PBGuidePositionLeft = 0,
    PBGuidePositionRight,
    PBGuidePositionTop,
    PBGuidePositionBottom,
};


@class PBDrawingCanvas;
@class PBResizableView;

@protocol PBDrawingTool <NSObject>

@property (nonatomic) NSPoint mouseDownPoint;
@property (nonatomic) NSRect boundingRect;

- (void)cleanup;
- (BOOL)shouldDeselectView:(PBResizableView *)view;
- (void)mouseDown:(PBClickableView *)view
          atPoint:(NSPoint)point
         inCanvas:(PBDrawingCanvas *)canvas;
- (void)mouseUp:(PBClickableView *)view
        atPoint:(NSPoint)point
       inCanvas:(PBDrawingCanvas *)canvas;
- (void)mouseDragged:(PBClickableView *)view
             toPoint:(NSPoint)point
            inCanvas:(PBDrawingCanvas *)canvas;
- (void)mouseMovedToPoint:(NSPoint)point inCanvas:(PBDrawingCanvas *)canvas;
- (void)drawBackgroundInCanvas:(PBDrawingCanvas *)canvas
                     dirtyRect:(NSRect)dirtyRect;
- (void)drawForegroundInCanvas:(PBDrawingCanvas *)canvas
                     dirtyRect:(NSRect)dirtyRect;

@end

@interface PBDrawingCanvas : PBClickableView <PBAcceptsFirstViewDelegate>

@property (nonatomic) PBDrawingCanvasToolType toolType;
@property (nonatomic) NSColor *toolColor;
@property (nonatomic) NSColor *toolSelectedColor;
@property (nonatomic) NSColor *toolBorderColor;
@property (nonatomic) NSInteger toolBorderWidth;
@property (nonatomic) BOOL showSelectionGuides;

// private

@property (nonatomic, readonly) NSMutableArray *selectedViews;
@property (nonatomic, readonly) NSMutableArray *toolViews;
@property (nonatomic, strong) PBResizableView *resizingView;
@property (nonatomic, readonly) NSMutableDictionary *mouseDownSelectedViewOrigins;
@property (nonatomic, strong) NSColor *backgroundColor;

- (NSPoint)roundedPoint:(NSPoint)point;
- (NSRect)roundedRect:(NSRect)rect;
- (NSSize)roundedSize:(NSSize)size;

- (PBResizableView *)viewAtPoint:(NSPoint)point;
- (void)selectView:(PBResizableView *)view deselectCurrent:(BOOL)deselectCurrent;
- (void)deselectView:(PBResizableView *)view;

- (PBResizableView *)createRectangle:(NSRect)frame;
- (NSArray *)createRectangles:(NSArray *)frames;
- (void)deleteViews:(NSArray *)views;
- (void)retagViews;
- (NSPoint)windowLocationOfMouse;
- (NSString *)viewKey:(NSView *)view;
- (void)selectOnlyViewsInRect:(NSRect)rect;
- (void)updateGuides;

@end
