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
#import "PBGuideView.h"
#import <Carbon/Carbon.h>

static NSComparisonResult PBDrawingCanvasViewsComparator( NSView * view1, NSView * view2, void * context) {

    PBDrawingCanvas *canvas = (__bridge PBDrawingCanvas *)(context);
    
    if ([view1 isKindOfClass:[PBGuideView class]]) {
        return NSOrderedAscending;
    } else if ([view2 isKindOfClass:[PBGuideView class]]) {
        return NSOrderedDescending;
    } else if ([canvas.selectedViews containsObject:view1]) {
        return NSOrderedAscending;
    } else if ([canvas.selectedViews containsObject:view2]) {
        return NSOrderedDescending;
    }

    return NSOrderedSame;
}

@interface PBDrawingCanvas() <PBClickableViewDelegate> {

    NSInteger _lastTabbedView;
}

@property (nonatomic, readwrite) NSMutableArray *selectedViews;
@property (nonatomic, readwrite) NSMutableArray *toolViews;
@property (nonatomic, readwrite) NSMutableDictionary *mouseDownSelectedViewOrigins;
@property (nonatomic, strong) NSMutableDictionary *guideViews;
@property (nonatomic, strong) NSMutableDictionary *guideReferenceViews;
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
    self.toolViews = [NSMutableArray array];
    self.delegate = self;
    self.mouseDownSelectedViewOrigins = [NSMutableDictionary dictionary];
    self.guideViews = [NSMutableDictionary dictionary];
    self.guideReferenceViews = [NSMutableDictionary dictionary];
    self.toolColor = [NSColor greenColor];
    self.toolSelectedColor = [NSColor redColor];
    self.toolBorderColor = [NSColor blackColor];
    _toolBorderWidth = 1;

    _guideViews[@(PBGuidePositionTop)] =
    [self guideForPosition:PBGuidePositionTop];

    _guideViews[@(PBGuidePositionBottom)] =
    [self guideForPosition:PBGuidePositionBottom];

    _guideViews[@(PBGuidePositionLeft)] =
    [self guideForPosition:PBGuidePositionLeft];

    _guideViews[@(PBGuidePositionRight)] =
    [self guideForPosition:PBGuidePositionRight];

    for (NSView *view in _guideViews.allValues) {
        [self addSubview:view positioned:NSWindowAbove relativeTo:nil];
    }

    [self
     sortSubviewsUsingFunction:PBDrawingCanvasViewsComparator context:(__bridge void *)(self)];
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

- (void)setShowSelectionGuides:(BOOL)showSelectionGuides {
    _showSelectionGuides = showSelectionGuides;

    [self showGuides];
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

- (void)setToolBorderColor:(NSColor *)toolBorderColor {
    _toolBorderColor = toolBorderColor;

    for (PBResizableView *view in _toolViews) {
        view.borderColor = toolBorderColor;
    }
}

- (void)setToolBorderWidth:(NSInteger)toolBorderWidth {
    _toolBorderWidth = toolBorderWidth;

    for (PBResizableView *view in _toolViews) {
        view.borderWidth = toolBorderWidth;
    }
}

- (void)setToolColor:(NSColor *)toolColor {
    _toolColor = toolColor;

    for (PBResizableView *view in _toolViews) {

        if ([_selectedViews containsObject:view] == NO) {
            view.backgroundColor = toolColor;
            [view setNeedsDisplay:YES];
        }
    }
}

- (void)setToolSelectedColor:(NSColor *)toolSelectedColor {
    _toolSelectedColor = toolSelectedColor;

    for (PBResizableView *view in _selectedViews) {

        if ([view isKindOfClass:[PBResizableView class]]) {
            view.backgroundColor = toolSelectedColor;
            [view setNeedsDisplay:YES];
        }
    }
}

- (void)selectNextContainer {

    if (_lastTabbedView == 0) {
        _lastTabbedView = ((NSView *)_selectedViews.lastObject).tag - 1;
    }
    _lastTabbedView++;

    if (_lastTabbedView > _toolViews.count) {
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
        _lastTabbedView = _toolViews.count;
    }

    PBResizableView *view = [self viewWithTag:_lastTabbedView];
    [self selectView:view deselectCurrent:YES];
}

- (PBResizableView *)createRectangle:(NSRect)frame {

    PBResizableView *view = [[PBResizableView alloc] initWithFrame:frame];
    view.backgroundColor = _toolColor;
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
        view.backgroundColor = _toolColor;
        view.delegate = self;

        [views addObject:view];
        [self selectView:view deselectCurrent:NO];
        [self addSubview:view];
        [_toolViews addObject:view];
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

    NSArray *targetViews = [views copy];

    for (NSView *view in targetViews) {
        [frames addObject:[NSValue valueWithRect:view.frame]];
    }

    NSString *actionName;

    if (targetViews.count == 1) {
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

         for (PBResizableView *view in targetViews) {
             [[view animator] setAlphaValue:0.0f];
         }

     } completion:^{

         for (PBResizableView *view in targetViews) {
             [view removeFromSuperview];
         }

         app.userInteractionEnabled = YES;

         [_selectedViews removeObjectsInArray:targetViews];
         [_toolViews removeObjectsInArray:targetViews];

         [self retagViews];
         [self showGuides];
     }];
}

- (void)selectAllContainers {

    NSArray *toolViews = [_toolViews copy];
    for (PBResizableView *view in toolViews) {
        [self selectView:view deselectCurrent:NO];
    }
}

- (void)deselectAllContainers {

    for (PBResizableView *view in _toolViews) {
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

    [_toolViews
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

    for (PBResizableView *view in _toolViews) {

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

    view.backgroundColor = _toolSelectedColor;
    view.borderWidth = _toolBorderWidth;
    view.borderColor = _toolBorderColor;

    [self addSubview:view];
    [_toolViews removeObject:view];
    [_toolViews addObject:view];

    NSString *viewKey = [self viewKey:view];

    _mouseDownSelectedViewOrigins[viewKey] =
    [NSValue valueWithPoint:view.frame.origin];

    [self showGuides];
}

- (void)deselectView:(PBResizableView *)view {

    if ([_drawingTool shouldDeselectView:view]) {
        NSString *viewKey = [self viewKey:view];
        [_mouseDownSelectedViewOrigins removeObjectForKey:viewKey];

        view.backgroundColor = _toolColor;
        view.borderWidth = 0;
        view.borderColor = nil;
        [view setNeedsDisplay:YES];
        [_selectedViews removeObject:view];

        [self showGuides];
    }
}

- (NSString *)viewKey:(NSView *)view {
    return [NSString stringWithFormat:@"%p", view];
}

- (void)retagViews {

    NSInteger tag = 1;

    for (PBResizableView *view in _toolViews) {
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

#pragma mark - Guides

- (void)viewDidMove:(PBResizableView *)view {

    NSDictionary *referenceViews = [_guideReferenceViews copy];

    for (NSNumber *positionType in referenceViews) {

        if (view == _guideReferenceViews[positionType]) {
            [self attachGuideToView:view atPosition:positionType.integerValue];
        }
    }
}

- (PBGuideView *)guideForPosition:(PBGuidePosition)guidePosition {

    PBGuideView *view = [[PBGuideView alloc] initWithFrame:NSZeroRect];

    view.vertical =
    guidePosition == PBGuidePositionLeft ||
    guidePosition == PBGuidePositionRight;

    return view;
}

- (NSRect)guideFrameForView:(PBResizableView *)view
                 atPosition:(PBGuidePosition)guidePosition {

    NSRect frame;

    switch (guidePosition) {
        case PBGuidePositionLeft:

            frame = NSMakeRect(NSMinX(view.frame),
                               0.0f,
                               1.0f,
                               NSHeight(view.superview.frame));
            break;

        case PBGuidePositionRight:

            frame = NSMakeRect(NSMaxX(view.frame) - 1.0f,
                               0.0f,
                               1.0f,
                               NSHeight(view.superview.frame));
            break;

        case PBGuidePositionTop:

            frame = NSMakeRect(0.0f,
                               NSMaxY(view.frame) - 1.0f,
                               NSWidth(view.superview.frame),
                               1.0f);
            break;

        case PBGuidePositionBottom:

            frame = NSMakeRect(0.0f,
                               NSMinY(view.frame),
                               NSWidth(view.superview.frame),
                               1.0f);
            break;

    }
    
    return [self roundedRect:frame];
}

- (void)updateGuides {
//    [self showGuides];
}

- (void)removeAllGuides {

    for (PBGuideView *view in _guideViews.allValues) {
        view.frame = NSZeroRect;
    }

    [_guideReferenceViews removeAllObjects];
}

- (void)attachGuideToView:(PBResizableView *)view
               atPosition:(PBGuidePosition)guidePosition {

    if (view != nil) {
        PBGuideView *guideView = _guideViews[@(guidePosition)];
        guideView.frame = [self guideFrameForView:view atPosition:guidePosition];

        _guideReferenceViews[@(guidePosition)] = view;

        [self addSubview:guideView positioned:NSWindowAbove relativeTo:nil];
    }
}

- (void)showGuides {
    [self removeAllGuides];

    if (_showSelectionGuides) {
        PBResizableView *topMostView =
        [self selectedViewAtFarthestPosition:PBGuidePositionTop];
        [self attachGuideToView:topMostView atPosition:PBGuidePositionTop];

        PBResizableView *bottomMostView =
        [self selectedViewAtFarthestPosition:PBGuidePositionBottom];
        [self attachGuideToView:bottomMostView atPosition:PBGuidePositionBottom];

        PBResizableView *leftMostView =
        [self selectedViewAtFarthestPosition:PBGuidePositionLeft];
        [self attachGuideToView:leftMostView atPosition:PBGuidePositionLeft];

        PBResizableView *rightMostView =
        [self selectedViewAtFarthestPosition:PBGuidePositionRight];
        [self attachGuideToView:rightMostView atPosition:PBGuidePositionRight];
    }
}

- (PBResizableView *)selectedViewAtFarthestPosition:(PBGuidePosition)guidePosition {

    PBResizableView *result = nil;

    for (PBResizableView *view in _selectedViews) {

        if (result == nil) {
            result = view;
            continue;
        }

        switch (guidePosition) {
            case PBGuidePositionTop:

                if (NSMaxY(view.frame) > NSMaxY(result.frame)) {
                    result = view;
                }

                break;

            case PBGuidePositionBottom:

                if (NSMinY(view.frame) < NSMinY(result.frame)) {
                    result = view;
                }

                break;

            case PBGuidePositionLeft:

                if (NSMinX(view.frame) < NSMinX(result.frame)) {
                    result = view;
                }

                break;

            case PBGuidePositionRight:
                
                if (NSMaxX(view.frame) > NSMaxX(result.frame)) {
                    result = view;
                }
                
                break;
        }
    }
    
    return result;
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

        default:
            break;
    }
}

- (void)keyDown:(NSEvent *)event {
    [self handleKeyEvent:event];
}

#pragma mark - Drawing

- (void)drawRect:(NSRect)dirtyRect {

    if (_backgroundColor != nil) {
        [_backgroundColor setFill];
        NSRectFillUsingOperation(dirtyRect, NSCompositeSourceOver);
    }

    [_drawingTool drawBackgroundInCanvas:self dirtyRect:dirtyRect];
    [super drawRect:dirtyRect];
    [_drawingTool drawForegroundInCanvas:self dirtyRect:dirtyRect];
}

@end
