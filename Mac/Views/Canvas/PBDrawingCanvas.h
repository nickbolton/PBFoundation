//
//  PBDrawingCanvas.h
//  Prototype
//
//  Created by Nick Bolton on 6/23/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBClickableView.h"

extern NSString * const kPBDrawingCanvasSelectedViewsNotification;
extern NSString * const kPBDrawingCanvasSelectedViewsKey;

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

typedef NS_ENUM(NSInteger, PBPResizeType) {

    PBPResizeTypeNone = 0,
    PBPResizeTypeUp,
    PBPResizeTypeDown,
    PBPResizeTypeLeft,
    PBPResizeTypeRight,
    PBPResizeTypeUpLeft,
    PBPResizeTypeUpRight,
    PBPResizeTypeDownLeft,
    PBPResizeTypeDownRight,
};

@class PBDrawingCanvas;
@class PBResizableView;

@protocol PBDrawingTool <NSObject>

@property (nonatomic) NSPoint mouseDownPoint;
@property (nonatomic) NSRect boundingRect;
@property (nonatomic) PBPResizeType resizeType;

- (void)cleanup;
- (void)rotate;
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
- (NSDictionary *)trackingRectsForMouseEvents;
- (void)mouseEnteredTrackingRect:(NSRect)rect rectIdentifier:(NSString *)rectIdentifier;
- (void)mouseExitedTrackingRect:(NSRect)rect rectIdentifier:(NSString *)rectIdentifier;

@end

@interface PBDrawingCanvas : PBClickableView <PBAcceptsFirstViewDelegate>

@property (nonatomic) PBDrawingCanvasToolType toolType;
@property (nonatomic) NSColor *defaultToolColor;
@property (nonatomic) NSColor *toolSelectedColor;
@property (nonatomic) NSColor *toolUnselectedColor;
@property (nonatomic) NSColor *toolBorderColor;
@property (nonatomic) NSInteger toolBorderWidth;
@property (nonatomic) BOOL showSelectionGuides;
@property (nonatomic, readonly) NSTextField *infoLabel;
@property (nonatomic, strong) NSImage *verticalGuideImage;
@property (nonatomic, strong) NSImage *horizontalGuideImage;
@property (nonatomic) NSDictionary *dataSourceViews;
@property (nonatomic, strong) NSDictionary *dataSourceImages;
@property (nonatomic, getter = isLandscape) BOOL landscape;
@property (nonatomic) CGFloat windowTitleHeight;
@property (nonatomic) CGFloat scaleFactor;

// private

@property (nonatomic, readonly) NSMutableArray *selectedViews;
@property (nonatomic, readonly) NSMutableArray *toolViews;
@property (nonatomic, strong) PBResizableView *resizingView;
@property (nonatomic, readonly) NSMutableDictionary *mouseDownSelectedViewOrigins;
@property (nonatomic, strong) NSColor *backgroundColor;
@property (nonatomic, strong) NSColor *scrollViewBackgroundColor;
@property (nonatomic, getter = isShowingInfo) BOOL showingInfo;
@property (nonatomic, readonly) NSScrollView *scrollView;

- (NSPoint)roundedPoint:(NSPoint)point;
- (NSRect)roundedRect:(NSRect)rect;
- (NSSize)roundedSize:(NSSize)size;

- (void)calculateEdgeDistances;
- (void)updateSpacers;
- (PBResizableView *)viewAtPoint:(NSPoint)point;
- (void)selectView:(PBResizableView *)view deselectCurrent:(BOOL)deselectCurrent;
- (void)deselectView:(PBResizableView *)view;
- (void)resizeViewAt:(NSRect)frame toFrame:(NSRect)toFrame;
- (void)resizeView:(PBResizableView *)view
           toFrame:(NSRect)toFrame
           animate:(BOOL)animate;
- (void)updateGuidesForView:(PBResizableView *)view;
- (PBResizableView *)createRectangle:(NSRect)frame;
- (NSArray *)createRectangles:(NSArray *)frames;
- (void)deleteViews:(NSArray *)views;
- (void)retagViews;
- (NSPoint)mouseLocationInWindow;
- (NSPoint)mouseLocationInDocument;
- (void)selectOnlyViewsInRect:(NSRect)rect;
- (BOOL)isViewSelected:(PBResizableView *)view;
- (void)setInfoValue:(NSString *)value;
- (void)updateInfoLabel:(PBResizableView *)view;
- (void)willRotateWindow:(NSRect)frame;
- (void)willResizeWindow:(NSRect)frame;
- (void)moveView:(PBResizableView *)view offset:(NSPoint)offset;
- (void)updateMouseDownSelectedViewOrigin:(PBResizableView *)view;

@end
