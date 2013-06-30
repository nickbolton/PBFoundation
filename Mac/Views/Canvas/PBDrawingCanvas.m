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
#import "PBSpacerView.h"
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
@property (nonatomic, strong) NSMutableArray *spacerViews;
@property (nonatomic, strong) NSMutableDictionary *guideReferenceViews;
@property (nonatomic, strong) NSTrackingArea *trackingArea;
@property (nonatomic, strong) id<PBDrawingTool> drawingTool;
@property (nonatomic, readwrite) NSTextField *infoLabel;
@property (nonatomic, strong) NSMutableDictionary *toolTrackingRects;
@property (nonatomic, strong) NSMutableArray *toolTrackingRectTags;
@property (nonatomic, strong) NSLayoutConstraint *infoLabelLeftSpace;
@property (nonatomic, strong) NSLayoutConstraint *infoLabelBottomSpace;

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
    self.spacerViews = [NSMutableArray array];
    self.delegate = self;
    self.mouseDownSelectedViewOrigins = [NSMutableDictionary dictionary];
    self.toolTrackingRects = [NSMutableDictionary dictionary];
    self.toolTrackingRectTags = [NSMutableArray array];
    self.guideViews = [NSMutableDictionary dictionary];
    self.guideReferenceViews = [NSMutableDictionary dictionary];
    self.toolColor = [NSColor greenColor];
    self.toolSelectedColor = [NSColor redColor];
    self.toolBorderColor = [NSColor blackColor];
    _toolBorderWidth = 1;

    for (NSView *view in _guideViews.allValues) {
        [self addSubview:view positioned:NSWindowAbove relativeTo:nil];
    }

    [self
     sortSubviewsUsingFunction:PBDrawingCanvasViewsComparator context:(__bridge void *)(self)];

    self.infoLabel = [[NSTextField alloc] initWithFrame:NSZeroRect];
    [_infoLabel setBezeled:NO];
    [_infoLabel setDrawsBackground:NO];
    [_infoLabel setEditable:NO];
    [_infoLabel setSelectable:NO];
    _infoLabel.alphaValue = 0.0f;
    _infoLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _infoLabel.textColor = [NSColor whiteColor];

    [self addSubview:_infoLabel];

    [self updateInfoLabel:_resizingView];

    [PBGuideView setHorizontalImage:_horizontalGuideImage];
    [PBGuideView setVerticalImage:_verticalGuideImage];
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

    if (showSelectionGuides) {
        _guideViews[@(PBGuidePositionTop)] =
        [self guideForPosition:PBGuidePositionTop];

        _guideViews[@(PBGuidePositionBottom)] =
        [self guideForPosition:PBGuidePositionBottom];

        _guideViews[@(PBGuidePositionLeft)] =
        [self guideForPosition:PBGuidePositionLeft];

        _guideViews[@(PBGuidePositionRight)] =
        [self guideForPosition:PBGuidePositionRight];
        
        [self showGuides];
    }
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
    view.drawingCanvas = self;

    [self.undoManager
     registerUndoWithTarget:self
     selector:@selector(deleteViews:)
     object:@[view]];
    [self.undoManager setActionName:PBLoc(@"Delete Rectangle")];

    [self setupTrackingRects];
    [self calculateEdgeDistances];

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
        view.drawingCanvas = self;
        view.alphaValue = 0.0f;

        [views addObject:view];
        [self selectView:view deselectCurrent:NO];
        [self addSubview:view];
        [view setupConstraints];
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

    [PBAnimator
     animateWithDuration:.3f
     timingFunction:PB_EASE_OUT
     animation:^{

         for (NSView *view in views) {
             view.animator.alphaValue = 1.0f;
         }
     }];

    [self setupTrackingRects];
    [self calculateEdgeDistances];

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

    [[self.undoManager prepareWithInvocationTarget:self]
     createRectangles:frames];

    [self.undoManager setActionName:actionName];

    [self removeAllGuides];

    [PBAnimator
     animateWithDuration:PB_WINDOW_ANIMATION_DURATION
     timingFunction:PB_EASE_OUT
     animation:^{

         for (PBResizableView *view in targetViews) {
             view.animator.alphaValue = 0.0f;
             view.topSpacerView.animator.alphaValue = 0.0f;
             view.bottomSpacerView.animator.alphaValue = 0.0f;
             view.leftSpacerView.animator.alphaValue = 0.0f;
             view.rightSpacerView.animator.alphaValue = 0.0f;
         }

     } completion:^{

         for (PBResizableView *view in targetViews) {
             [view.topSpacerView removeFromSuperview];
             [view.bottomSpacerView removeFromSuperview];
             [view.leftSpacerView removeFromSuperview];
             [view.rightSpacerView removeFromSuperview];
             [view removeFromSuperview];
         }

         app.userInteractionEnabled = YES;

         [_selectedViews removeObjectsInArray:targetViews];
         [_toolViews removeObjectsInArray:targetViews];

         [self retagViews];
         [self showGuides];
         [self setupTrackingRects];
         [self calculateEdgeDistances];
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
        [self setupTrackingRects];
    }
}

- (void)stopMouseTracking {
    [self removeTrackingArea:_trackingArea];
    self.trackingArea = nil;

    [self removeAllToolTrackingRects];
}

- (NSPoint)windowLocationOfMouse {
    NSPoint mouseLocation = [NSEvent mouseLocation];

    return
    [self.window convertScreenToBase:mouseLocation];
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

    NSArray *toolViews = [_toolViews copy];
    for (PBResizableView *view in toolViews) {

        if (NSContainsRect(rect, view.frame)) {
            [self selectView:view deselectCurrent:NO];
        }
    }
}

- (BOOL)isViewSelected:(PBResizableView *)view {
    return [_selectedViews containsObject:view];
}

- (void)selectView:(PBResizableView *)view
   deselectCurrent:(BOOL)deselectCurrent {

    if (deselectCurrent) {

        NSArray *selectedViews = [_selectedViews copy];
        for (PBResizableView *selectedView in selectedViews) {
            if (selectedView != view) {
                [self deselectView:selectedView];
            }
        }
    }

    if (view != nil) {

        if ([_selectedViews containsObject:view] == NO) {
            [_selectedViews addObject:view];
        }

        view.backgroundColor = _toolSelectedColor;
        view.borderWidth = _toolBorderWidth;
        view.borderColor = _toolBorderColor;

        [self addSubview:view];
        [view setupConstraints];
        [_toolViews removeObject:view];
        [_toolViews addObject:view];

        NSString *viewKey = [self viewKey:view];

        _mouseDownSelectedViewOrigins[viewKey] =
        [NSValue valueWithPoint:view.frame.origin];

        if (_selectedViews.count == 1) {
            view.showingInfo = YES;
        }
    }

    [self showGuides];
}

- (void)deselectView:(PBResizableView *)view {

    if ([_drawingTool shouldDeselectView:view]) {
        NSString *viewKey = [self viewKey:view];
        [_mouseDownSelectedViewOrigins removeObjectForKey:viewKey];

        view.showingInfo = NO;
        view.backgroundColor = _toolColor;
        view.borderWidth = 0;
        view.borderColor = nil;
        [view setNeedsDisplay:YES];
        [_selectedViews removeObject:view];

        [self showGuides];
    }
}

- (void)resizeViewAt:(NSRect)frame toFrame:(NSRect)toFrame {

    for (PBResizableView *view in _toolViews) {
        if (NSEqualRects(view.frame, frame)) {

            NSRect oldFrame = view.frame;

            [view setViewFrame:toFrame animated:YES];

            [[self.undoManager prepareWithInvocationTarget:self]
             resizeViewAt:toFrame toFrame:oldFrame];
            [self.undoManager setActionName:PBLoc(@"Resize Rectangle")];

            break;
        }
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

- (void)moveSelectedRulers:(NSPoint)offset {

    for (PBResizableView *selectedView in _selectedViews) {

        NSRect frame = NSOffsetRect(selectedView.frame, offset.x, offset.y);

        [selectedView setViewFrame:frame animated:NO];

        NSString *viewKey = [self viewKey:selectedView];

        _mouseDownSelectedViewOrigins[viewKey] =
        [NSValue valueWithPoint:frame.origin];
    }
}

#pragma mark - Edge Calculations

- (void)calculateEdgeDistances {

    if (_toolViews.count == 0) return;

    for (NSView *view in _spacerViews) {
        [view removeFromSuperview];
    }
    
    [_spacerViews removeAllObjects];

    for (PBResizableView *view in _toolViews) {
        view.closestTopView = nil;
        view.closestBottomView = nil;
        view.closestLeftView = nil;
        view.closestRightView = nil;
        view.topSpacerView = nil;
        view.bottomSpacerView = nil;
        view.leftSpacerView = nil;
        view.rightSpacerView = nil;
        view.edgeDistances =
        NSEdgeInsetsMake(MAXFLOAT, MAXFLOAT, MAXFLOAT, MAXFLOAT);
    }

    if (_toolViews.count == 1) {

        PBResizableView *view1 = _toolViews.lastObject;
        [self setDistancesToWindowEdges:view1];
    }

    for (NSInteger i = 0; i < _toolViews.count - 1; i++) {

        PBResizableView *view1 = _toolViews[i];

        [self setDistancesToWindowEdges:view1];

        for (NSInteger j = i + 1; j < _toolViews.count; j++) {

            PBResizableView *view2 = _toolViews[j];

            [self setDistancesToWindowEdges:view2];

            // check the top of view1

            NSRect rectToTop = [self rectToTopOfWindow:view1];

            NSRect intersectingRect =
            NSIntersectionRect(rectToTop, view2.frame);

            if (NSEqualRects(intersectingRect, NSZeroRect) == NO) {

                CGFloat distance = NSMinY(view2.frame) - NSMaxY(view1.frame);

                if (distance >= 0.0f && distance < view1.edgeDistances.top) {

                    NSEdgeInsets edgeDistances = view1.edgeDistances;
                    edgeDistances.top = distance;
                    view1.edgeDistances = edgeDistances;
                    view1.closestTopView = view2;

                    edgeDistances = view2.edgeDistances;
                    edgeDistances.bottom = distance;
                    view2.edgeDistances = edgeDistances;
                    view2.closestBottomView = view1;
                }
            }

            // check the bottom of view1

            NSRect rectToBottom = [self rectToBottomOfWindow:view1];

            intersectingRect =
            NSIntersectionRect(rectToBottom, view2.frame);

            if (NSEqualRects(intersectingRect, NSZeroRect) == NO) {

                CGFloat distance = NSMinY(view1.frame) - NSMaxY(view2.frame);

                if (distance >= 0.0f && distance < view1.edgeDistances.bottom) {

                    NSEdgeInsets edgeDistances = view1.edgeDistances;
                    edgeDistances.bottom = distance;
                    view1.edgeDistances = edgeDistances;
                    view1.closestBottomView = view2;

                    edgeDistances = view2.edgeDistances;
                    edgeDistances.top = distance;
                    view2.edgeDistances = edgeDistances;
                    view2.closestTopView = view1;
                }
            }

            // check the left of view1

            NSRect rectToLeft = [self rectToLeftOfWindow:view1];

            intersectingRect =
            NSIntersectionRect(rectToLeft, view2.frame);

            if (NSEqualRects(intersectingRect, NSZeroRect) == NO) {

                CGFloat distance = NSMinX(view1.frame) - NSMaxX(view2.frame);

                if (distance >= 0.0f && distance < view1.edgeDistances.left) {

                    NSEdgeInsets edgeDistances = view1.edgeDistances;
                    edgeDistances.left = distance;
                    view1.edgeDistances = edgeDistances;
                    view1.closestLeftView = view2;

                    edgeDistances = view2.edgeDistances;
                    edgeDistances.right = distance;
                    view2.edgeDistances = edgeDistances;
                    view2.closestRightView = view1;
                }
            }

            // check the right of view1

            NSRect rectToRight = [self rectToRightOfWindow:view1];

            intersectingRect =
            NSIntersectionRect(rectToRight, view2.frame);

            if (NSEqualRects(intersectingRect, NSZeroRect) == NO) {

                CGFloat distance = NSMinX(view2.frame) - NSMaxX(view1.frame);

                if (distance >= 0.0f && distance < view1.edgeDistances.right) {

                    NSEdgeInsets edgeDistances = view1.edgeDistances;
                    edgeDistances.right = distance;
                    view1.edgeDistances = edgeDistances;
                    view1.closestRightView = view2;

                    edgeDistances = view2.edgeDistances;
                    edgeDistances.left = distance;
                    view2.edgeDistances = edgeDistances;
                    view2.closestLeftView = view1;
                }
            }
        }
    }

    for (PBResizableView *view in _toolViews) {
//        NSLog(@"view: %@ - %f, %f, %f, %f",
//              NSStringFromRect(view.frame),
//              view.edgeDistances.top,
//              view.edgeDistances.left,
//              view.edgeDistances.bottom,
//              view.edgeDistances.right);

        PBSpacerView *spacerView;

        spacerView =
        [[PBSpacerView alloc]
         initWithTopView:view.closestTopView
         bottomView:view
         value:view.edgeDistances.top];
        [self addSubview:spacerView];
        [_spacerViews addObject:spacerView];
        view.topSpacerView = spacerView;
        spacerView.alphaValue = view.closestBottomView == nil ? 1.0f : 0.0f;

        spacerView =
        [[PBSpacerView alloc]
         initWithTopView:view
         bottomView:view.closestBottomView
         value:view.edgeDistances.bottom];
        [self addSubview:spacerView];
        [_spacerViews addObject:spacerView];
        view.bottomSpacerView = spacerView;

        spacerView =
        [[PBSpacerView alloc]
         initWithLeftView:view.closestLeftView
         rightView:view
         value:view.edgeDistances.left];
        [self addSubview:spacerView];
        [_spacerViews addObject:spacerView];
        view.leftSpacerView = spacerView;

        spacerView =
        [[PBSpacerView alloc]
         initWithLeftView:view
         rightView:view.closestRightView
         value:view.edgeDistances.right];
        [self addSubview:spacerView];
        [_spacerViews addObject:spacerView];
        view.rightSpacerView = spacerView;
        spacerView.alphaValue = view.closestLeftView == nil ? 1.0f : 0.0f;
    }
}

- (void)alignSpacer:(NSView *)spacerView toTopOfView:(NSView *)view {

    NSLayoutConstraint *alignToHorizontalCenter =
    [NSLayoutConstraint
     constraintWithItem:spacerView
     attribute:NSLayoutAttributeCenterX
     relatedBy:NSLayoutRelationEqual
     toItem:view
     attribute:NSLayoutAttributeCenterX
     multiplier:1.0f
     constant:0.0f];

    NSLayoutConstraint *verticalSpace =
    [NSLayoutConstraint
     constraintWithItem:spacerView
     attribute:NSLayoutAttributeBottom
     relatedBy:NSLayoutRelationEqual
     toItem:view
     attribute:NSLayoutAttributeTop
     multiplier:1.0f
     constant:0.0f];

    [self addConstraint:alignToHorizontalCenter];
    [self addConstraint:verticalSpace];
}

- (void)alignSpacer:(NSView *)spacerView toBottomOfView:(NSView *)view {

    NSLayoutConstraint *alignToHorizontalCenter =
    [NSLayoutConstraint
     constraintWithItem:spacerView
     attribute:NSLayoutAttributeCenterX
     relatedBy:NSLayoutRelationEqual
     toItem:view
     attribute:NSLayoutAttributeCenterX
     multiplier:1.0f
     constant:0.0f];

    NSLayoutConstraint *verticalSpace =
    [NSLayoutConstraint
     constraintWithItem:spacerView
     attribute:NSLayoutAttributeTop
     relatedBy:NSLayoutRelationEqual
     toItem:view
     attribute:NSLayoutAttributeBottom
     multiplier:1.0f
     constant:0.0f];

    [self addConstraint:alignToHorizontalCenter];
    [self addConstraint:verticalSpace];

}

- (void)alignSpacer:(NSView *)spacerView toLeftOfView:(NSView *)view {

    NSLayoutConstraint *alignToVerticalCenter =
    [NSLayoutConstraint
     constraintWithItem:spacerView
     attribute:NSLayoutAttributeCenterY
     relatedBy:NSLayoutRelationEqual
     toItem:view
     attribute:NSLayoutAttributeCenterY
     multiplier:1.0f
     constant:0.0f];

    NSLayoutConstraint *horizontalSpace =
    [NSLayoutConstraint
     constraintWithItem:spacerView
     attribute:NSLayoutAttributeRight
     relatedBy:NSLayoutRelationEqual
     toItem:view
     attribute:NSLayoutAttributeLeft
     multiplier:1.0f
     constant:0.0f];

    [self addConstraint:alignToVerticalCenter];
    [self addConstraint:horizontalSpace];
}

- (void)alignSpacer:(NSView *)spacerView toRightOfView:(NSView *)view {

    NSLayoutConstraint *alignToVerticalCenter =
    [NSLayoutConstraint
     constraintWithItem:spacerView
     attribute:NSLayoutAttributeCenterY
     relatedBy:NSLayoutRelationEqual
     toItem:view
     attribute:NSLayoutAttributeCenterY
     multiplier:1.0f
     constant:0.0f];

    NSLayoutConstraint *horizontalSpace =
    [NSLayoutConstraint
     constraintWithItem:spacerView
     attribute:NSLayoutAttributeLeft
     relatedBy:NSLayoutRelationEqual
     toItem:view
     attribute:NSLayoutAttributeRight
     multiplier:1.0f
     constant:0.0f];

    [self addConstraint:alignToVerticalCenter];
    [self addConstraint:horizontalSpace];
}

- (NSRect)rectToTopOfWindow:(PBResizableView *)view {
    return
    NSMakeRect(NSMinX(view.frame),
               NSMaxY(view.frame),
               NSWidth(view.frame),
               view.edgeDistances.top);
}

- (NSRect)rectToBottomOfWindow:(PBResizableView *)view {
    return
    NSMakeRect(NSMinX(view.frame),
               0.0f,
               NSWidth(view.frame),
               view.edgeDistances.bottom);
}

- (NSRect)rectToLeftOfWindow:(PBResizableView *)view {
    return
    NSMakeRect(0.0f,
               NSMinY(view.frame),
               view.edgeDistances.left,
               NSHeight(view.frame));
}

- (NSRect)rectToRightOfWindow:(PBResizableView *)view {
    return
    NSMakeRect(NSMaxX(view.frame),
               NSMinY(view.frame),
               view.edgeDistances.right,
               NSHeight(view.frame));
}

- (void)setDistancesToWindowEdges:(PBResizableView *)view {

//    CGFloat top, CGFloat left, CGFloat bottom, CGFloat right

    CGFloat top = MIN(view.edgeDistances.top,
                      NSHeight(view.window.frame) - NSMaxY(view.frame));

    CGFloat left = MIN(view.edgeDistances.left,
                       NSMinX(view.frame));

    CGFloat bottom = MIN(view.edgeDistances.bottom,
                         NSMinY(view.frame));

    CGFloat right = MIN(view.edgeDistances.right,
                      NSWidth(view.window.frame) - NSMaxX(view.frame));

    view.edgeDistances = NSEdgeInsetsMake(top, left, bottom, right);
}

#pragma mark - Info Label

- (void)setInfoValue:(NSString *)value {

    if (_showingInfo) {
        _infoLabel.stringValue = value;
        [_infoLabel sizeToFit];
    }
}

- (void)setShowingInfo:(BOOL)showingInfo {
    _showingInfo = showingInfo;

    CGFloat alpha = showingInfo ? 1.0f : 0.0f;
    _infoLabel.alphaValue = alpha;
}

- (void)updateInfoLabel:(PBResizableView *)view {

    NSPoint mouseLocation = [self windowLocationOfMouse];

    self.showingInfo =
    NSEqualSizes(NSZeroSize, view.frame.size) == NO &&
    view.isShowingInfoLabel == NO;

    CGFloat left = NSMaxX(view.frame) + 5.0f;
    CGFloat bottom = NSMidY(view.frame) - 8.0f;

    if (_infoLabelLeftSpace == nil) {
        self.infoLabelLeftSpace =
        [NSLayoutConstraint
         alignToLeft:_infoLabel
         withPadding:left];

        self.infoLabelBottomSpace =
        [NSLayoutConstraint
         alignToBottom:_infoLabel
         withPadding:-bottom];
    } else {

        _infoLabelLeftSpace.constant = left;
        _infoLabelBottomSpace.constant = -bottom;
    }
}

#pragma mark - Guides

- (void)viewDidMove:(PBResizableView *)view {

    NSDictionary *referenceViews = [_guideReferenceViews copy];

    NSView *selectedView = _selectedViews.firstObject;

    for (NSNumber *positionType in referenceViews) {

        if (view == _guideReferenceViews[positionType]) {

            PBGuideView *guideView = _guideViews[positionType];
            guideView.frame = [self guideFrameForView:view atPosition:positionType.integerValue];
        }
    }

    [self setupTrackingRects];
    [self calculateEdgeDistances];
}

- (PBGuideView *)guideForPosition:(PBGuidePosition)guidePosition {
    
    PBGuideView *view = [[PBGuideView alloc] initWithFrame:NSZeroRect];
    view.translatesAutoresizingMaskIntoConstraints = NO;

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

    PBGuideView *guideView = _guideViews[@(guidePosition)];

    if (view != nil) {
        guideView.frame = [self guideFrameForView:view atPosition:guidePosition];
        guideView.alphaValue = 1.0f;

        _guideReferenceViews[@(guidePosition)] = view;

        [self addSubview:guideView positioned:NSWindowAbove relativeTo:nil];
    } else {
        guideView.alphaValue = 0.0f;
    }
}

- (void)showGuides {

    if (_showSelectionGuides) {

        NSView *selectedView = _selectedViews.firstObject;

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

#pragma mark - Tracking Rects

- (void)removeAllToolTrackingRects {

    NSPoint mouseLocation = [self windowLocationOfMouse];

    for (NSNumber *rectTag in _toolTrackingRectTags) {
        [self removeTrackingRect:rectTag.integerValue];
    }
    for (NSString *identifier in _toolTrackingRects) {

        NSValue *rectValue = _toolTrackingRects[identifier];
        if (NSPointInRect(mouseLocation, rectValue.rectValue)) {
            [_drawingTool
             mouseExitedTrackingRect:rectValue.rectValue
             rectIdentifier:identifier];
        }
    }
    [_toolTrackingRectTags removeAllObjects];
    [_toolTrackingRects removeAllObjects];
}

- (void)setupTrackingRects {

    [self removeAllToolTrackingRects];
    
    NSDictionary *rects =
    [_drawingTool trackingRectsForMouseEvents];

    NSPoint mouseLocation = [self windowLocationOfMouse];

    for (NSString *identifier in rects) {

        NSValue *rectValue = rects[identifier];

        NSTrackingRectTag rectTag =
        [self
         addTrackingRect:rectValue.rectValue
         owner:self
         userData:(__bridge void *)(identifier)
         assumeInside:YES];

        [_toolTrackingRectTags addObject:@(rectTag)];
        _toolTrackingRects[identifier] = rectValue;

        if (NSPointInRect(mouseLocation, rectValue.rectValue)) {
            [_drawingTool
             mouseEnteredTrackingRect:rectValue.rectValue
             rectIdentifier:identifier];
        }
    }
}

- (void)mouseEntered:(NSEvent *)event {

    NSString *rectIdentifier = event.userData;

    if (rectIdentifier != nil) {

        NSValue *rectValue = _toolTrackingRects[rectIdentifier];

        [_drawingTool
         mouseEnteredTrackingRect:rectValue.rectValue
         rectIdentifier:rectIdentifier];
    }
}

- (void)mouseExited:(NSEvent *)event {

    NSString *rectIdentifier = event.userData;

    if (rectIdentifier != nil) {

        NSValue *rectValue = _toolTrackingRects[rectIdentifier];

        [_drawingTool
         mouseExitedTrackingRect:rectValue.rectValue
         rectIdentifier:rectIdentifier];
    }
}

- (void)mouseMoved:(NSEvent *)event {
    NSPoint windowLocation = [self windowLocationOfMouse];
    [_drawingTool mouseMovedToPoint:windowLocation inCanvas:self];
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
    
//    NSLog(@"keyCode: %d, modifiers: %d", event.keyCode, event.modifierFlags);

    NSInteger movementMultiplier = 1;

    if ([event isModifiersExactly:NSShiftKeyMask] ||
        [event isModifiersExactly:NSShiftKeyMask|NSNumericPadKeyMask|NSFunctionKeyMask]) {
        movementMultiplier = 10;
    }

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
            
        case kVK_LeftArrow:
            [self moveSelectedRulers:NSMakePoint(-1.0f * movementMultiplier, 0.0f)];
            break;

        case kVK_RightArrow:
            [self moveSelectedRulers:NSMakePoint(1.0f * movementMultiplier, 0.0f)];
            break;

        case kVK_UpArrow:
            [self moveSelectedRulers:NSMakePoint(0.0f, 1.0f * movementMultiplier)];
            break;

        case kVK_DownArrow:
            [self moveSelectedRulers:NSMakePoint(0.0f, -1.0f * movementMultiplier)];
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
