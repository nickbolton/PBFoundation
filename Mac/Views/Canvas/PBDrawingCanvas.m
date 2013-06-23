//
//  PBDrawingCanvas.m
//  Prototype
//
//  Created by Nick Bolton on 6/23/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBDrawingCanvas.h"
#import "PBResizableView.h"
#import "PBRectangleTool.h"
#import "PBSelectionTool.h"
#import <Carbon/Carbon.h>

@interface PBDrawingCanvas() <PBClickableViewDelegate> {

    NSInteger _lastTabbedView;
}

@property (nonatomic, readwrite) NSMutableArray *selectedViews;
@property (nonatomic, readwrite) NSMutableDictionary *mouseDownSelectedViewOrigins;
@property (nonatomic, strong) NSTrackingArea *trackingArea;
@property (nonatomic, strong) id<PBDrawingTool> drawingTool;

@end


@implementation PBDrawingCanvas

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.selectedViews = [NSMutableArray array];
    self.delegate = self;
    self.mouseDownSelectedViewOrigins = [NSMutableDictionary dictionary];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupNotifications];
}

#pragma mark - Private

- (void)setupNotifications {

    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(windowDidResignMain:)
     name:NSWindowDidResignMainNotification
     object:self.window];

    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(windowDidBecomeMain:)
     name:NSWindowDidBecomeMainNotification
     object:self.window];

    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(windowWillClose:)
     name:NSWindowWillCloseNotification
     object:self.window];
}

- (void)setToolType:(PBDrawingCanvasToolType)toolType {
    _toolType = toolType;

    [_drawingTool cleanup];

    switch (_toolType) {
        case PBDrawingCanvasToolTypeNone:
            self.drawingTool = nil;
            break;

        case PBDrawingCanvasToolTypeRectangle:
            self.drawingTool = [[PBRectangleTool alloc] init];
            break;

        case PBDrawingCanvasToolTypeSelect:
            self.drawingTool = [[PBSelectionTool alloc] init];
            break;

        default:
            break;
    }
    [self setNeedsDisplay:YES];
}

- (void)selectNextContainer {

    if (_lastTabbedView == 0) {
        _lastTabbedView = ((NSView *)_selectedViews.lastObject).tag - 1;
    }
    _lastTabbedView++;

    if (_lastTabbedView > self.subviews.count) {
        _lastTabbedView = 1;
    }

    PBResizableView *view = [self viewWithTag:_lastTabbedView];
    [self selectView:view deselectCurrent:YES];
}

- (void)selectPreviousContainer {

    if (_lastTabbedView == 0) {
        _lastTabbedView = ((NSView *)_selectedViews.lastObject).tag + 1;
    }
    _lastTabbedView--;

    if (_lastTabbedView <= 0) {
        _lastTabbedView = self.subviews.count;
    }

    PBResizableView *view = [self viewWithTag:_lastTabbedView];
    [self selectView:view deselectCurrent:YES];
}

- (PBResizableView *)createRectangle:(NSRect)frame {

    PBResizableView *view = [[PBResizableView alloc] initWithFrame:frame];
    view.backgroundColor = [NSColor greenColor];
    view.delegate = self;

    [self.undoManager
     registerUndoWithTarget:self
     selector:@selector(deleteViews:)
     object:@[view]];
    [self.undoManager setActionName:PBLoc(@"Delete Rectangle")];

    return view;
}

- (NSArray *)createRectangles:(NSArray *)frames {

    [self deselectAllContainers];

    NSMutableArray *views = [NSMutableArray array];

    for (NSValue *frameValue in frames) {

        NSRect frame = frameValue.rectValue;

        PBResizableView *view = [[PBResizableView alloc] initWithFrame:frame];
        view.backgroundColor = [NSColor greenColor];
        view.delegate = self;

        [views addObject:view];
        [self selectView:view deselectCurrent:NO];
        [self addSubview:view];
    }

    NSString *actionName;

    if (frames.count == 1) {
        actionName = PBLoc(@"Delete Rectangle");
    } else {
        actionName = PBLoc(@"Delete Rectangles");
    }

    [self.undoManager
     registerUndoWithTarget:self
     selector:@selector(deleteViews:)
     object:views];
    [self.undoManager setActionName:actionName];

    return views;
}

- (void)deleteViews:(NSArray *)views {

    PBApplication *app = (id)NSApp;
    app.userInteractionEnabled = NO;

    NSMutableArray *frames = [NSMutableArray arrayWithCapacity:views.count];

    for (NSView *view in views) {
        [frames addObject:[NSValue valueWithRect:view.frame]];
    }

    NSString *actionName;

    if (views.count == 1) {
        actionName = PBLoc(@"Restore Rectangle");
    } else {
        actionName = PBLoc(@"Restore Rectangles");
    }

    [self.undoManager
     registerUndoWithTarget:self
     selector:@selector(createRectangles:)
     object:frames];
    [self.undoManager setActionName:actionName];

    [PBAnimator
     animateWithDuration:PB_WINDOW_ANIMATION_DURATION
     timingFunction:PB_EASE_OUT
     animation:^{

         for (NSView *view in views) {
             [[view animator] setAlphaValue:0.0f];
         }

     } completion:^{

         for (NSView *view in views) {
             [view removeFromSuperview];
         }

         app.userInteractionEnabled = YES;

         [_selectedViews removeObjectsInArray:views];

         [self retagViews];

     }];
}

- (void)selectAllContainers {

    NSArray *subviews = [self.subviews copy];
    for (PBResizableView *view in subviews) {
        [self selectView:view deselectCurrent:NO];
    }
}

- (void)deselectAllContainers {

    NSArray *subviews = [self.subviews copy];
    for (PBResizableView *view in subviews) {
        [self deselectView:view];
    }
}

- (void)startMouseTracking {
    if (_trackingArea == nil) {

        int opts = (NSTrackingMouseMoved | NSTrackingActiveAlways);
        self.trackingArea =
        [[NSTrackingArea alloc]
         initWithRect:self.bounds
         options:opts
         owner:self
         userInfo:nil];
        [self addTrackingArea:_trackingArea];
    }
}

- (void)stopMouseTracking {
    [self removeTrackingArea:_trackingArea];
    self.trackingArea = nil;
}

- (NSPoint)windowLocationOfMouse {
    NSPoint mouseLocation = [NSEvent mouseLocation];

    return
    [self.window convertScreenToBase:mouseLocation];
}

- (void)mouseEntered:(NSEvent *)event {
}

- (void)mouseExited:(NSEvent *)event {
}

- (void)mouseMoved:(NSEvent *)event {

    NSPoint windowLocation = [self windowLocationOfMouse];
    [_drawingTool mouseMovedToPoint:windowLocation inCanvas:self];
}

- (PBResizableView *)viewAtPoint:(NSPoint)point {

    __block PBResizableView *selectedView = nil;

    [self.subviews
     enumerateObjectsWithOptions:NSEnumerationReverse
     usingBlock:^(PBResizableView *view, NSUInteger idx, BOOL *stop) {

         if (NSPointInRect(point, view.frame)) {
             selectedView = view;
             *stop = YES;
         }
     }];

    return selectedView;
}

- (void)selectOnlyViewsInRect:(NSRect)rect {

    [self deselectAllContainers];

    NSArray *subviews = [self.subviews copy];
    for (PBResizableView *view in subviews) {

        if (NSContainsRect(rect, view.frame)) {

            [self selectView:view deselectCurrent:NO];
        }
    }
}

- (void)selectView:(PBResizableView *)view
   deselectCurrent:(BOOL)deselectCurrent {

    if (deselectCurrent) {

        NSArray *selectedViews = [_selectedViews copy];
        for (PBResizableView *selectedView in selectedViews) {
            [self deselectView:selectedView];
        }
    }

    [_selectedViews addObject:view];
    view.borderWidth = 1;
    view.borderColor = [NSColor blackColor];

    [self addSubview:view];

    NSString *viewKey = [self viewKey:view];

    _mouseDownSelectedViewOrigins[viewKey] =
    [NSValue valueWithPoint:view.frame.origin];
}

- (void)deselectView:(PBResizableView *)view {

    if ([_drawingTool shouldDeselectView:view]) {
        NSString *viewKey = [self viewKey:view];
        [_mouseDownSelectedViewOrigins removeObjectForKey:viewKey];

        view.borderWidth = 0;
        view.borderColor = nil;
        [view setNeedsDisplay:YES];
        [_selectedViews removeObject:view];
    }
}

- (NSString *)viewKey:(NSView *)view {
    return [NSString stringWithFormat:@"%p", view];
}

- (void)retagViews {

    NSInteger tag = 1;

    for (PBResizableView *view in self.subviews) {
        view.tag = tag++;
    }
}

- (NSSize)roundedSize:(NSSize)size {
    return NSMakeSize(roundf(size.width), roundf(size.height));
}

- (NSPoint)roundedPoint:(NSPoint)point {
    return NSMakePoint(roundf(point.x), roundf(point.y));
}

- (NSRect)roundedRect:(NSRect)rect {
    NSRect roundedRect = NSZeroRect;
    roundedRect.origin = [self roundedPoint:rect.origin];
    roundedRect.size = [self roundedSize:rect.size];
    return roundedRect;
}

#pragma mark - PBClickableViewDelegate Conformance

- (void)viewMousedDown:(PBClickableView *)view atPoint:(NSPoint)point {
    [_drawingTool mouseDown:view atPoint:point inCanvas:self];
}

- (void)viewMousedUp:(PBClickableView *)view atPoint:(NSPoint)point {
    [_drawingTool mouseUp:view atPoint:point inCanvas:self];
}

- (void)viewMouseDragged:(PBClickableView *)view atPoint:(NSPoint)point {
    [_drawingTool mouseDragged:view toPoint:point inCanvas:self];
}

#pragma mark - NSWindowDelegate Conformance

- (void) windowDidBecomeMain:(NSNotification *)notification {
    [self startMouseTracking];
}

- (void) windowDidResignMain:(NSNotification *)notification {
    [self stopMouseTracking];
}

- (void) windowWillClose:(NSNotification *)notification {
    [self stopMouseTracking];
}

#pragma mark - Key Handling

- (void)handleKeyEvent:(NSEvent *)event {
    
    NSLog(@"keyCode: %d", event.keyCode);
    
    switch (event.keyCode) {
        case kVK_Delete:
            
            if ([event isModifiersExactly:0]) {
                [self deleteViews:_selectedViews];
            }
            break;
            
        case kVK_ANSI_A:
            
            if ([event isModifiersExactly:NSCommandKeyMask]) {
                [self selectAllContainers];
            }
            break;
            
        case kVK_UpArrow:
            break;
            
        case kVK_DownArrow:
            break;
            
        case kVK_Tab:
            
            if ([event isModifiersExactly:0]) {
                [self selectNextContainer];
            } else if ([event isModifiersExactly:NSShiftKeyMask]) {
                [self selectPreviousContainer];
            }
            
            break;
    }
}

- (void)keyDown:(NSEvent *)event {
    [self handleKeyEvent:event];
}

#pragma mark - Drawing

- (void)drawRect:(NSRect)dirtyRect {
    [_drawingTool drawBackgroundInCanvas:self dirtyRect:dirtyRect];
    [super drawRect:dirtyRect];
    [_drawingTool drawForegroundInCanvas:self dirtyRect:dirtyRect];
}

@end
