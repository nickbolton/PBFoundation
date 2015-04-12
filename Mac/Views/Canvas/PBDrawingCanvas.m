//
//  PBDrawingCanvas.m
//  Prototype
//
//  Created by Nick Bolton on 6/23/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBDrawingCanvas.h"
#import "PBRectangleTool.h"
#import "PBSelectionTool.h"
#import "PBGuideView.h"
#import "PBSpacerView.h"
#import "PBResizableView.h"
#import <Carbon/Carbon.h>

NSString * const kPBDrawingCanvasSelectedViewsNotification = @"kPBDrawingCanvasSelectedViewsNotification";
NSString * const kPBDrawingCanvasSelectedViewsKey = @"selected-views";
NSString * const kPBDrawingCanvasResizableViewsKey = @"views";
NSString * const kPBDrawingCanvasSelectedKey = @"selected";
NSString * const kPBDrawingCanvasLandscapeKey = @"landscape";
NSString * const kPBDrawingCanvasBackgroundColorKey = @"bgColor";

static NSComparisonResult PBDrawingCanvasViewsComparator( NSView * view1, NSView * view2, void * context) {

    PBDrawingCanvas *canvas = (__bridge PBDrawingCanvas *)(context);

    if ([view1 isKindOfClass:[PBGuideView class]]) {
        return NSOrderedAscending;
    } else if ([view2 isKindOfClass:[PBGuideView class]]) {
        return NSOrderedDescending;
    } else if ([view1 isKindOfClass:[PBSpacerView class]]) {
        return NSOrderedAscending;
    } else if ([view2 isKindOfClass:[PBSpacerView class]]) {
        return NSOrderedDescending;
    } else if ([canvas.selectedViews containsObject:view1]) {
        return NSOrderedAscending;
    } else if ([canvas.selectedViews containsObject:view2]) {
        return NSOrderedDescending;
    }

    return NSOrderedSame;
}

typedef NS_ENUM(NSInteger, PBDrawingCanvasConstraint) {

    PBDrawingCanvasConstraintNone   = 0,
    PBDrawingCanvasConstraintTop    = (0x1 << 0),
    PBDrawingCanvasConstraintBottom = (0x1 << 1),
    PBDrawingCanvasConstraintLeft   = (0x1 << 2),
    PBDrawingCanvasConstraintRight  = (0x1 << 3),
    PBDrawingCanvasConstraintAll    = (PBDrawingCanvasConstraintTop|
                                       PBDrawingCanvasConstraintBottom|
                                       PBDrawingCanvasConstraintLeft|
                                       PBDrawingCanvasConstraintRight),
};

@interface PBDrawingCanvas() <PBClickableViewDelegate, PBSpacerProtocol> {

    NSInteger _lastTabbedView;
}

@property (nonatomic, readwrite) NSScrollView *scrollView;
@property (nonatomic, readwrite) NSMutableArray *selectedViews;
@property (nonatomic, readwrite) NSMutableArray *toolViews;
@property (nonatomic, readwrite) NSMutableDictionary *mouseDownSelectedViewOrigins;
@property (nonatomic, strong) NSMutableArray *spacerViews;
@property (nonatomic, strong) NSMutableDictionary *guideReferenceViews;
@property (nonatomic, strong) NSTrackingArea *trackingArea;
@property (nonatomic, strong) id<PBDrawingTool> drawingTool;
@property (nonatomic, readwrite) NSTextField *infoLabel;
@property (nonatomic, strong) NSMutableDictionary *toolTrackingRects;
@property (nonatomic, strong) NSMutableArray *toolTrackingRectTags;
@property (nonatomic, strong) NSLayoutConstraint *infoLabelLeftSpace;
@property (nonatomic, strong) NSLayoutConstraint *infoLabelBottomSpace;
@property (nonatomic) NSRect newDocumentFrame;
@property (nonatomic) NSSize lastDocumentSize;

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

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Setup

- (void)setupNotifications {

    [[NSNotificationCenter defaultCenter]
     postNotificationName:kPBDrawingCanvasSelectedViewsNotification
     object:self
     userInfo:nil];

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

    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(windowDidResize:)
     name:NSWindowDidResizeNotification
     object:self.window];
}

- (void)commonInit {
    _newDocumentFrame.size.width = -1.0f;

    self.selectedViews = [NSMutableArray array];
    self.toolViews = [NSMutableArray array];
    self.spacerViews = [NSMutableArray array];
    self.delegate = self;
    self.mouseDownSelectedViewOrigins = [NSMutableDictionary dictionary];
    self.toolTrackingRects = [NSMutableDictionary dictionary];
    self.toolTrackingRectTags = [NSMutableArray array];
    self.guideViews = [NSMutableDictionary dictionary];
    self.guideReferenceViews = [NSMutableDictionary dictionary];
    self.defaultToolColor = [NSColor whiteColor];
    self.toolSelectedColor = nil;
    self.toolUnselectedColor = [NSColor colorWithRGBHex:0 alpha:.2];
    self.toolBorderColor = [NSColor blackColor];
    self.lastDocumentSize = self.window.frame.size;
    _snapThreshold = 5.0f;
    _toolBorderWidth = 1;
    _scaleFactor = 1.0f;

    [PBGuideView setHorizontalImage:_horizontalGuideImage];
    [PBGuideView setVerticalImage:_verticalGuideImage];

    [self registerForDraggedTypes:@[NSFilenamesPboardType, NSTIFFPboardType]];
}

- (void)awakeFromNib {
    [super awakeFromNib];

    [self
     sortSubviewsUsingFunction:PBDrawingCanvasViewsComparator
     context:(__bridge void *)(self)];

    [self setupScrollView];
    [self setupGuideViews];
    [self setupInfoLabel];
    [self setupNotifications];
}

- (void)setupScrollView {
    self.scrollView = [[NSScrollView alloc] initWithFrame:self.bounds];
    _scrollView.borderType = NSNoBorder;
    _scrollView.hasHorizontalScroller = YES;
    _scrollView.hasVerticalScroller = YES;
    _scrollView.autohidesScrollers = YES;
//    _scrollView.hasHorizontalRuler = YES;
//    _scrollView.hasVerticalRuler = YES;
    _scrollView.autoresizingMask = NSViewWidthSizable|NSViewHeightSizable;

    _scrollView.backgroundColor = _scrollViewBackgroundColor;

    NSView *documentView = [[NSView alloc] initWithFrame:self.bounds];
    documentView.wantsLayer = YES;
    documentView.layer.backgroundColor = _backgroundColor.CGColor;

    _scrollView.documentView = documentView;

    [self addSubview:_scrollView];
}

- (void)setupGuideViews {

    for (NSView *view in _guideViews.allValues) {
        [_scrollView.documentView addSubview:view positioned:NSWindowAbove relativeTo:nil];
    }
}

- (void)setupInfoLabel {
    
    self.infoLabel = [[NSTextField alloc] initWithFrame:NSZeroRect];
    [_infoLabel setBezeled:NO];
    [_infoLabel setDrawsBackground:NO];
    [_infoLabel setEditable:NO];
    [_infoLabel setSelectable:NO];
    _infoLabel.alphaValue = 0.0f;
    _infoLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _infoLabel.textColor = [NSColor whiteColor];
    _infoLabel.drawsBackground = NO;

    [_scrollView.documentView addSubview:_infoLabel];

    [self updateInfoLabel:_resizingView];
}

#pragma mark - Setters and Getters

- (void)setBackgroundColor:(NSColor *)backgroundColor {
    _backgroundColor = backgroundColor;
    [_scrollView.documentView layer].backgroundColor = backgroundColor.CGColor;
}

- (void)setScrollViewBackgroundColor:(NSColor *)scrollViewBackgroundColor {
    _scrollViewBackgroundColor = scrollViewBackgroundColor;
    _scrollView.backgroundColor = scrollViewBackgroundColor;
}

- (NSDictionary *)dataSourceViews {

    NSMutableDictionary *dataSource = [NSMutableDictionary dictionary];

    NSMutableArray *views = [NSMutableArray arrayWithCapacity:_toolViews.count];

    NSMutableDictionary *backgroundImages = [NSMutableDictionary dictionary];

    for (PBResizableView *view in _toolViews) {

        NSMutableDictionary *viewDataSource = [view.dataSource mutableCopy];

        viewDataSource[kPBDrawingCanvasSelectedKey] = @(view.isSelected);

        NSImage *backgroundImage = viewDataSource[@"backgroundImage"];

        if (backgroundImage != nil) {

            NSString *guid = [NSString timestampedGuid];
            backgroundImages[guid] = backgroundImage;
            [viewDataSource removeObjectForKey:@"backgroundImage"];
            viewDataSource[@"backgroundImageID"] = guid;
        }

        [views addObject:viewDataSource];
    }

    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat alpha;

    [_backgroundColor getRGBComponents:&red green:&green blue:&blue alpha:&alpha];

    dataSource[kPBDrawingCanvasBackgroundColorKey] =
    @{
      @"r" : @(red),
      @"g" : @(green),
      @"b" : @(blue),
      @"a" : @(alpha),
      };

    dataSource[kPBDrawingCanvasResizableViewsKey] = views;
    dataSource[kPBDrawingCanvasLandscapeKey] = @(_landscape);

    self.dataSourceImages = backgroundImages;

    return dataSource;
}

- (void)setDataSourceViews:(NSDictionary *)dataSource {

    for (NSDictionary *view in dataSource[kPBDrawingCanvasResizableViewsKey]) {

        NSRect frame = NSRectFromString(view[@"frame"]);

        NSDictionary *topSpacer = view[@"topSpacer"];
        NSDictionary *bottomSpacer = view[@"bottomSpacer"];
        NSDictionary *leftSpacer = view[@"leftSpacer"];
        NSDictionary *rightSpacer = view[@"rightSpacer"];
        NSDictionary *backgroundColor = view[@"bgColor"];

        NSString *backgroundImageID = view[@"backgroundImageID"];

        PBResizableView *resizableView = [self createRectangle:frame];
        [self updateSpacersForView:resizableView];
        [resizableView.topSpacerView updateFromDataSource:topSpacer];
        [resizableView.bottomSpacerView updateFromDataSource:bottomSpacer];
        [resizableView.leftSpacerView updateFromDataSource:leftSpacer];
        [resizableView.rightSpacerView updateFromDataSource:rightSpacer];

        if (backgroundImageID != nil) {
            resizableView.backgroundImage = _dataSourceImages[backgroundImageID];
        }

        resizableView.backgroundColor =
        [NSColor
         colorWithCalibratedRed:[backgroundColor[@"r"] floatValue]
         green:[backgroundColor[@"g"] floatValue]
         blue:[backgroundColor[@"b"] floatValue]
         alpha:[backgroundColor[@"a"] floatValue]];

        [_scrollView.documentView addSubview:resizableView];
        [_toolViews addObject:resizableView];
    }

    [self retagViews];

    _landscape = [dataSource[kPBDrawingCanvasLandscapeKey] boolValue];

    NSDictionary *bgColor = dataSource[kPBDrawingCanvasBackgroundColorKey];

    self.backgroundColor =
    [NSColor
     colorWithCalibratedRed:[bgColor[@"r"] floatValue]
     green:[bgColor[@"g"] floatValue]
     blue:[bgColor[@"b"] floatValue]
     alpha:[bgColor[@"a"] floatValue]];

    NSTimeInterval delayInSeconds = .5f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){

        [[NSNotificationCenter defaultCenter]
         postNotificationName:kPBDrawingCanvasSelectedViewsNotification
         object:self
         userInfo:@{kPBDrawingCanvasSelectedViewsKey : _selectedViews}];
    });
}

- (void)setScaleFactor:(CGFloat)scaleFactor {

    CGFloat diff = scaleFactor / _scaleFactor;

    _scaleFactor = scaleFactor;

    NSRect frame = self.bounds;
    frame.size.width = _scaleFactor * NSWidth(self.frame);
    frame.size.height = _scaleFactor * NSHeight(self.frame);

    [_scrollView.documentView setFrame:frame];

    for (PBResizableView *view in _toolViews) {

        NSRect frame = view.frame;
        frame.origin.x *= diff;
        frame.origin.y *= diff;
        frame.size.width *= diff;
        frame.size.height *= diff;
        [self resizeView:view toFrame:frame animate:NO];
        [view updateInfo];
    }

    [_scrollView documentVisibleRect].origin;
    NSPoint scrollPoint;

    scrollPoint.x *= diff;
    scrollPoint.y *= diff;

    scrollPoint.y += diff * NSHeight(_scrollView.frame);

    [_scrollView.contentView scrollPoint:scrollPoint];

    [self calculateEdgeDistances];
    [self updateGuides];
    [self updateTrackingAreas];
}

#pragma mark - Private

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

- (void)setToolSelectedColor:(NSColor *)color {
    _toolSelectedColor = color;

    for (PBResizableView *view in _selectedViews) {

        if ([view isKindOfClass:[PBResizableView class]]) {
            view.foregroundColor = color;
            [view setNeedsDisplay:YES];
        }
    }
}

- (void)setToolUnselectedColor:(NSColor *)color {

    _toolUnselectedColor = color;

    for (PBResizableView *view in _toolViews) {

        if ([view isKindOfClass:[PBResizableView class]]) {

            if (view.isSelected == NO) {
                view.foregroundColor = color;
                [view setNeedsDisplay:YES];
            }
        }
    }
}

- (void)selectNextContainer {

    if (_lastTabbedView == 0) {
        if (_selectedViews.count > 0) {
            _lastTabbedView = ((NSView *)_selectedViews.lastObject).tag - 1;
        } else {
            _lastTabbedView = 0;
        }
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
    view.backgroundColor = _defaultToolColor;
    view.delegate = self;
    view.drawingCanvas = self;
    view.key = [NSString timestampedGuid];

    [self.undoManager
     registerUndoWithTarget:self
     selector:@selector(deleteViews:)
     object:@[view]];
    [self.undoManager setActionName:PBLoc(@"Delete Rectangle")];

    [self setupTrackingRects];
    [self calculateEdgeDistances];

    return view;
}

- (void)createRectangleWithImage:(NSImage *)image {

    NSRect frame = NSZeroRect;
    frame.size = image.size;

    frame.size.width *= _scaleFactor;
    frame.size.height *= _scaleFactor;

    NSPoint scrollOrigin = _scrollView.documentVisibleRect.origin;

    NSRect containerFrame = [_scrollView.documentView frame];

    NSPoint center = [self mouseLocationInDocument];

    frame.origin.x = center.x - ((NSWidth(frame)+scrollOrigin.x) / 2.0f);
    frame.origin.y = center.y - ((NSHeight(frame)+scrollOrigin.x) / 2.0f);

//    frame.origin.x = (NSWidth(containerFrame) - NSWidth(frame) + scrollOrigin.x) / 2.0f;
//    frame.origin.y = (NSHeight(containerFrame) - NSHeight(frame) + scrollOrigin.y) / 2.0f;

    PBResizableView *view = [self createRectangle:frame];
    view.backgroundColor = _defaultToolColor;
    view.delegate = self;
    view.drawingCanvas = self;
    view.alphaValue = 1.0f;
    view.key = [NSString timestampedGuid];

    [_scrollView.documentView addSubview:view];
    [view setupConstraints];
    [_toolViews addObject:view];
    [self selectView:view deselectCurrent:YES];

    view.backgroundImage = image;
}

- (NSArray *)createRectangles:(NSArray *)frames {

    [self deselectAllContainers];

    NSMutableArray *views = [NSMutableArray array];

    for (NSValue *frameValue in frames) {

        NSRect frame = frameValue.rectValue;

        PBResizableView *view = [[PBResizableView alloc] initWithFrame:frame];
        view.backgroundColor = _defaultToolColor;
        view.delegate = self;
        view.drawingCanvas = self;
        view.alphaValue = 0.0f;
        view.key = [NSString timestampedGuid];

        [views addObject:view];
        [self selectView:view deselectCurrent:NO];
        [_scrollView.documentView addSubview:view];
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
    [self retagViews];

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

         _infoLabel.animator.alphaValue = 0.0f;

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

         [[NSNotificationCenter defaultCenter]
          postNotificationName:kPBDrawingCanvasSelectedViewsNotification
          object:self
          userInfo:@{kPBDrawingCanvasSelectedViewsKey : _selectedViews}];
     }];
}

- (void)selectAllContainers {

    NSArray *toolViews = [_toolViews copy];
    for (PBResizableView *view in toolViews) {
        [self selectView:view deselectCurrent:NO];
    }

    [[NSNotificationCenter defaultCenter]
     postNotificationName:kPBDrawingCanvasSelectedViewsNotification
     object:self
     userInfo:@{kPBDrawingCanvasSelectedViewsKey : _selectedViews}];
}

- (void)deselectAllContainers {

    for (PBResizableView *view in _toolViews) {
        [self deselectView:view];
    }

    [[NSNotificationCenter defaultCenter]
     postNotificationName:kPBDrawingCanvasSelectedViewsNotification
     object:self
     userInfo:@{kPBDrawingCanvasSelectedViewsKey : _selectedViews}];
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

- (NSPoint)mouseLocationInWindow {
    NSPoint mouseLocation = [NSEvent mouseLocation];
    return [self.window convertScreenToBase:mouseLocation];
}

- (NSPoint)mouseLocationInDocument {
    NSPoint windowLocation = [self mouseLocationInWindow];

    NSPoint location =
    [_scrollView.documentView convertPointFromBase:windowLocation];

    NSPoint documentOrigin = [_scrollView documentVisibleRect].origin;

    location.x += documentOrigin.x;
    location.y += documentOrigin.y;

    return location;
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

- (void)updateMouseDownSelectedViewOrigin:(PBResizableView *)view {
    _mouseDownSelectedViewOrigins[view.key] =
    [NSValue valueWithPoint:view.frame.origin];
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


        if (view.isSelected == NO) {
            [_selectedViews addObject:view];
            view.showingInfo = YES;
            [view
             setViewFrame:view.frame
             withContainerFrame:self.frame
             animate:NO];
        }

        view.foregroundColor = _toolSelectedColor;
        view.borderWidth = _toolBorderWidth;
        view.borderColor = _toolBorderColor;

        [_scrollView.documentView addSubview:view];
        [view setupConstraints];
        [_toolViews removeObject:view];
        [_toolViews addObject:view];
        _lastTabbedView = view.tag;

        _mouseDownSelectedViewOrigins[view.key] =
        [NSValue valueWithPoint:view.frame.origin];

        if (_selectedViews.count == 1) {
            [self.window makeFirstResponder:view];
        }
    }

    [self showGuides];
}

- (void)deselectView:(PBResizableView *)view {

    if ([_drawingTool shouldDeselectView:view]) {
        [_mouseDownSelectedViewOrigins removeObjectForKey:view.key];

        view.showingInfo = NO;
        view.borderWidth = 0;
        view.foregroundColor = _toolUnselectedColor;
        view.borderColor = nil;
        [view setNeedsDisplay:YES];
        [_selectedViews removeObject:view];

        [view updateSpacers];

        [self showGuides];

        [[NSNotificationCenter defaultCenter]
         postNotificationName:kPBDrawingCanvasSelectedViewsNotification
         object:self
         userInfo:@{kPBDrawingCanvasSelectedViewsKey : _selectedViews}];
    }
}

- (void)resizeView:(PBResizableView *)view
           toFrame:(NSRect)toFrame
           animate:(BOOL)animate {

    NSRect oldFrame = view.frame;

    [view
     setViewFrame:toFrame
     withContainerFrame:self.frame
     animate:animate];

    [[self.undoManager prepareWithInvocationTarget:self]
     resizeViewAt:toFrame toFrame:oldFrame];
    [self.undoManager setActionName:PBLoc(@"Resize Rectangle")];

    if (view.isSelected) {
        _mouseDownSelectedViewOrigins[view.key] =
        [NSValue valueWithPoint:toFrame.origin];
    }

    [[NSNotificationCenter defaultCenter]
     postNotificationName:kPBDrawingCanvasSelectedViewsNotification
     object:self
     userInfo:@{kPBDrawingCanvasSelectedViewsKey : _selectedViews}];
}

- (void)resizeViewAt:(NSRect)frame toFrame:(NSRect)toFrame {

    for (PBResizableView *view in _toolViews) {
        if (NSEqualRects(view.frame, frame)) {
            [self resizeView:view toFrame:toFrame animate:YES];
            break;
        }
    }
}

- (void)retagViews {

    NSInteger tag = 1;

    for (PBResizableView *view in _toolViews) {
        if ([view isKindOfClass:[PBResizableView class]]) {
            view.tag = tag++;
        }
    }
}

- (CGFloat)roundedValue:(CGFloat)value {
    CGFloat scale = self.window != nil ? self.window.backingScaleFactor : 1.0f;
    return roundf(value * scale) / scale;
}

- (NSSize)roundedSize:(NSSize)size {
    return
    NSMakeSize([self roundedValue:size.width],
               [self roundedValue:size.height]);
}

- (NSPoint)roundedPoint:(NSPoint)point {
    return
    NSMakePoint([self roundedValue:point.x],
                [self roundedValue:point.y]);
}

- (NSRect)roundedRect:(NSRect)rect {
    NSRect roundedRect = NSZeroRect;
    roundedRect.origin = [self roundedPoint:rect.origin];
    roundedRect.size = [self roundedSize:rect.size];
    return roundedRect;
}

- (void)doMoveView:(PBResizableView *)view offset:(NSPoint)offset {

    NSRect frame = NSOffsetRect(view.frame, offset.x, offset.y);

    [view
     setViewFrame:frame
     withContainerFrame:self.frame
     animate:NO];

    _mouseDownSelectedViewOrigins[view.key] =
    [NSValue valueWithPoint:frame.origin];

}

- (void)moveView:(PBResizableView *)view offset:(NSPoint)offset {

    [self doMoveView:view offset:offset];

    [self calculateEdgeDistances];

    [[NSNotificationCenter defaultCenter]
     postNotificationName:kPBDrawingCanvasSelectedViewsNotification
     object:self
     userInfo:@{kPBDrawingCanvasSelectedViewsKey : _selectedViews}];

}

- (void)moveSelectedViews:(NSPoint)offset {

    for (PBResizableView *selectedView in _selectedViews) {

        [self doMoveView:selectedView offset:offset];
    }

    [self calculateEdgeDistances];

    [[NSNotificationCenter defaultCenter]
     postNotificationName:kPBDrawingCanvasSelectedViewsNotification
     object:self
     userInfo:@{kPBDrawingCanvasSelectedViewsKey : _selectedViews}];
}

- (void)willResizeWindow:(NSRect)frame {

    _newDocumentFrame = frame;

    _newDocumentFrame.size.height -= _windowTitleHeight;

    _newDocumentFrame.size.width *= _scaleFactor;
    _newDocumentFrame.size.height *= _scaleFactor;

    for (PBResizableView *view in _toolViews) {

        [view willRotateWindow:_newDocumentFrame];
    }

    for (PBResizableView *selectedView in _selectedViews) {

        _mouseDownSelectedViewOrigins[selectedView.key] =
        [NSValue valueWithPoint:selectedView.frame.origin];
    }

    [self updateSpacers];
    [self updateGuides];
    [self setNeedsLayout:YES];

    _newDocumentFrame.size.width = -1.0f;
}

- (void)willRotateWindow:(NSRect)frame {

    [self willResizeWindow:frame];

}

#pragma mark - Edge Calculations

- (void)calculateEdgeDistances {

    if (_toolViews.count == 0) return;

    for (PBResizableView *view in _toolViews) {
        view.closestTopView = nil;
        view.closestBottomView = nil;
        view.closestLeftView = nil;
        view.closestRightView = nil;
        view.edgeDistances =
        NSEdgeInsetsMake(MAXFLOAT, MAXFLOAT, MAXFLOAT, MAXFLOAT);

        [self setDistancesToWindowEdges:view];
    }

    [self updateSpacers];
}

- (void)updateSpacers {

    for (PBResizableView *view in _toolViews) {
        //        NSLog(@"view: %@ - %f, %f, %f, %f",
        //              NSStringFromRect(view.frame),
        //              view.edgeDistances.top,
        //              view.edgeDistances.left,
        //              view.edgeDistances.bottom,
        //              view.edgeDistances.right);

        [self updateSpacersForView:view];
    }
}

- (void)updateSpacersForView:(PBResizableView *)view {

    if (_showSpacers == NO) return;
    
    PBResizableView *oppositeView;
    PBSpacerView *spacerView;
    PBSpacerView *overlappingSpacerView;
    NSNumber *alphaValue;

    spacerView = view.topSpacerView;
    oppositeView = view.closestTopView;

    BOOL isSelected = view.isSelected;

    if (spacerView == nil) {
        spacerView =
        [[PBSpacerView alloc]
         initWithTopView:oppositeView
         bottomView:view
         value:view.edgeDistances.top];
        spacerView.delegate = self;
        spacerView.constraining = YES;
        [_scrollView.documentView addSubview:spacerView];
        [_spacerViews addObject:spacerView];
        view.topSpacerView = spacerView;
    } else {
        spacerView.view2 = oppositeView;
        spacerView.value = view.edgeDistances.top;

        overlappingSpacerView = [spacerView overlappingSpacerView];

        if (overlappingSpacerView != nil) {
            spacerView.constraining = overlappingSpacerView.constraining;
        }
    }
    spacerView.scale = _scaleFactor;
    spacerView.alphaValue = isSelected ? 1.0f : 0.0f;
    spacerView.hidden = spacerView.alphaValue == 0.0f;
    [spacerView setNeedsLayout:YES];

    spacerView = view.bottomSpacerView;
    oppositeView = view.closestBottomView;

    if (spacerView == nil) {
        spacerView =
        [[PBSpacerView alloc]
         initWithTopView:view
         bottomView:oppositeView
         value:view.edgeDistances.bottom];
        spacerView.delegate = self;
        spacerView.constraining = NO;
        [_scrollView.documentView addSubview:spacerView];
        [_spacerViews addObject:spacerView];
        view.bottomSpacerView = spacerView;
    } else {
        spacerView.view1 = oppositeView;
        spacerView.value = view.edgeDistances.bottom;

        overlappingSpacerView = [spacerView overlappingSpacerView];

        if (overlappingSpacerView != nil) {
            spacerView.constraining = overlappingSpacerView.constraining;
        }
    }
    spacerView.scale = _scaleFactor;
    spacerView.alphaValue = isSelected && (view.closestBottomView == nil || view.closestBottomView.isSelected == NO) ? 1.0f : 0.0f;
    spacerView.hidden = spacerView.alphaValue == 0.0f;
    [spacerView setNeedsLayout:YES];

    spacerView = view.leftSpacerView;
    oppositeView = view.closestLeftView;

    if (spacerView == nil) {
        spacerView =
        [[PBSpacerView alloc]
         initWithLeftView:oppositeView
         rightView:view
         value:view.edgeDistances.left];
        spacerView.delegate = self;
        spacerView.constraining = YES;
        [_scrollView.documentView addSubview:spacerView];
        [_spacerViews addObject:spacerView];
        view.leftSpacerView = spacerView;
    } else {
        spacerView.view1 = oppositeView;
        spacerView.value = view.edgeDistances.left;

        overlappingSpacerView = [spacerView overlappingSpacerView];

        if (overlappingSpacerView != nil) {
            spacerView.constraining = overlappingSpacerView.constraining;
        }
    }
    spacerView.scale = _scaleFactor;
    spacerView.alphaValue = isSelected ? 1.0f : 0.0f;
    spacerView.hidden = spacerView.alphaValue == 0.0f;
    [spacerView setNeedsLayout:YES];

    spacerView = view.rightSpacerView;
    oppositeView = view.closestRightView;

    if (spacerView == nil) {
        spacerView =
        [[PBSpacerView alloc]
         initWithLeftView:view
         rightView:oppositeView
         value:view.edgeDistances.right];
        spacerView.delegate = self;
        spacerView.constraining = NO;
        [_scrollView.documentView addSubview:spacerView];
        [_spacerViews addObject:spacerView];
        view.rightSpacerView = spacerView;
    } else {
        spacerView.view2 = oppositeView;
        spacerView.value = view.edgeDistances.right;

        overlappingSpacerView = [spacerView overlappingSpacerView];

        if (overlappingSpacerView != nil) {
            spacerView.constraining = overlappingSpacerView.constraining;
        }
    }
    spacerView.scale = _scaleFactor;
    spacerView.alphaValue = isSelected && (view.closestRightView == nil || view.closestRightView.isSelected == NO) ? 1.0f : 0.0f;
    spacerView.hidden = spacerView.alphaValue == 0.0f;
    [spacerView setNeedsLayout:YES];
}

- (void)calculateEdgeDistances2 {

    if (_toolViews.count == 0) return;

//    for (NSView *view in _spacerViews) {
//        [view removeFromSuperview];
//    }
//
//    [_spacerViews removeAllObjects];

    for (PBResizableView *view in _toolViews) {
        view.closestTopView = nil;
        view.closestBottomView = nil;
        view.closestLeftView = nil;
        view.closestRightView = nil;
//        view.topSpacerView = nil;
//        view.bottomSpacerView = nil;
//        view.leftSpacerView = nil;
//        view.rightSpacerView = nil;
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

    [self updateSpacers];
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

    NSRect documentFrame =
    _newDocumentFrame.size.width >= 0 ? _newDocumentFrame : [_scrollView.documentView frame];

    CGFloat top = MIN(view.edgeDistances.top,
                      NSHeight(documentFrame) - NSMaxY(view.frame));

    CGFloat left = MIN(view.edgeDistances.left,
                       NSMinX(view.frame));

    CGFloat bottom = MIN(view.edgeDistances.bottom,
                         NSMinY(view.frame));

    CGFloat right = MIN(view.edgeDistances.right,
                      NSWidth(documentFrame) - NSMaxX(view.frame));

    view.edgeDistances = NSEdgeInsetsMake(top, left, bottom, right);
}

- (void)toggleSelectedViewTopConstraint {

    PBSpacerView *spacerView = nil;

    for (PBResizableView *view in _selectedViews) {
        if (spacerView == nil ||
            NSMaxY(view.topSpacerView.frame) > NSMaxY(spacerView.frame)) {
            spacerView = view.topSpacerView;
        }
    }

    PBSpacerView *overlappingView = [spacerView overlappingSpacerView];
    
    spacerView.constraining = !spacerView.isConstraining;
    overlappingView.constraining = spacerView.constraining;
    [spacerView setNeedsDisplay:YES];
    [overlappingView setNeedsDisplay:YES];

    [[NSNotificationCenter defaultCenter]
     postNotificationName:kPBDrawingCanvasSelectedViewsNotification
     object:self
     userInfo:@{kPBDrawingCanvasSelectedViewsKey : _selectedViews}];

}

- (void)toggleSelectedViewBottomConstraint {

    PBSpacerView *spacerView = nil;

    for (PBResizableView *view in _selectedViews) {
        if (spacerView == nil ||
            NSMinY(view.bottomSpacerView.frame) < NSMinY(spacerView.frame)) {
            spacerView = view.bottomSpacerView;
        }
    }

    PBSpacerView *overlappingView = [spacerView overlappingSpacerView];

    spacerView.constraining = !spacerView.isConstraining;
    overlappingView.constraining = spacerView.constraining;
    [spacerView setNeedsDisplay:YES];
    [overlappingView setNeedsDisplay:YES];

    [[NSNotificationCenter defaultCenter]
     postNotificationName:kPBDrawingCanvasSelectedViewsNotification
     object:self
     userInfo:@{kPBDrawingCanvasSelectedViewsKey : _selectedViews}];
}

- (void)toggleSelectedViewLeftConstraint {

    PBSpacerView *spacerView = nil;

    for (PBResizableView *view in _selectedViews) {
        if (spacerView == nil ||
            NSMinX(view.leftSpacerView.frame) < NSMinX(spacerView.frame)) {
            spacerView = view.leftSpacerView;
        }
    }

    PBSpacerView *overlappingView = [spacerView overlappingSpacerView];

    spacerView.constraining = !spacerView.isConstraining;
    overlappingView.constraining = spacerView.constraining;
    [spacerView setNeedsDisplay:YES];
    [overlappingView setNeedsDisplay:YES];

    [[NSNotificationCenter defaultCenter]
     postNotificationName:kPBDrawingCanvasSelectedViewsNotification
     object:self
     userInfo:@{kPBDrawingCanvasSelectedViewsKey : _selectedViews}];
}

- (void)toggleSelectedViewRightConstraint {

    PBSpacerView *spacerView = nil;

    for (PBResizableView *view in _selectedViews) {
        if (spacerView == nil ||
            NSMaxX(view.rightSpacerView.frame) > NSMaxX(spacerView.frame)) {
            spacerView = view.rightSpacerView;
        }
    }

    PBSpacerView *overlappingView = [spacerView overlappingSpacerView];

    spacerView.constraining = !spacerView.isConstraining;
    overlappingView.constraining = spacerView.constraining;
    [spacerView setNeedsDisplay:YES];
    [overlappingView setNeedsDisplay:YES];

    [[NSNotificationCenter defaultCenter]
     postNotificationName:kPBDrawingCanvasSelectedViewsNotification
     object:self
     userInfo:@{kPBDrawingCanvasSelectedViewsKey : _selectedViews}];
}

- (void)pinSelectedViewsTop {

    PBResizableView *topMostView = nil;

    for (PBResizableView *view in _selectedViews) {

        if (topMostView == nil ||
            NSMaxY(view.frame) > NSMaxY(topMostView.frame)) {
            topMostView = view;
        }
    }

    if (topMostView != nil) {

        CGFloat distance =
        NSHeight(topMostView.superview.frame) - NSMaxY(topMostView.frame);

        
        [self moveSelectedViews:NSMakePoint(0.0f, distance)];
    }
}

- (void)pinSelectedViewsBottom {

    PBResizableView *bottomMostView = nil;

    for (PBResizableView *view in _selectedViews) {

        if (bottomMostView == nil ||
            NSMinY(view.frame) < NSMinY(bottomMostView.frame)) {
            bottomMostView = view;
        }
    }

    if (bottomMostView != nil) {
        [self moveSelectedViews:NSMakePoint(0.0f, -NSMinY(bottomMostView.frame))];
    }
}

- (void)pinSelectedViewsLeft {

    PBResizableView *leftMostView = nil;

    for (PBResizableView *view in _selectedViews) {

        if (leftMostView == nil ||
            NSMinX(view.frame) < NSMinX(leftMostView.frame)) {
            leftMostView = view;
        }
    }

    if (leftMostView != nil) {
        [self moveSelectedViews:NSMakePoint(-NSMinX(leftMostView.frame), 0.0f)];
    }
}

- (void)pinSelectedViewsRight {

    PBResizableView *rightMostView = nil;

    for (PBResizableView *view in _selectedViews) {

        if (rightMostView == nil ||
            NSMaxX(view.frame) > NSMaxX(rightMostView.frame)) {
            rightMostView = view;
        }
    }

    if (rightMostView != nil) {

        CGFloat distance =
        NSWidth(rightMostView.superview.frame) - NSMaxX(rightMostView.frame);

        [self moveSelectedViews:NSMakePoint(distance, 0.0f)];
    }
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

    _infoLabel.textColor = [NSColor whiteColor];
}

- (void)updateInfoLabel:(PBResizableView *)view {

    NSPoint mouseLocation = [self mouseLocationInDocument];

    self.showingInfo =
    NSEqualSizes(NSZeroSize, view.frame.size) == NO &&
    view.isShowingInfoLabel == NO;

    CGFloat left = NSMaxX(view.frame) + 5.0f;
    CGFloat bottom =
    NSMidY(view.frame) - 8.0f + (NSHeight(_infoLabel.frame) / 2.0f);

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

- (void)updateGuidesForView:(PBResizableView *)view {
    [self viewDidMove:view updateTrackingAndConstraintEdges:NO];
    [self updateInfoLabel:view];
}

- (void)updateGuides {

    NSInteger idx = 1;
    for (PBResizableView *view in _toolViews) {

        BOOL update = idx++ == _toolViews.count;
        [self viewDidMove:view updateTrackingAndConstraintEdges:update];
    }
}

- (void)viewDidMove:(PBResizableView *)view {
    [self viewDidMove:view updateTrackingAndConstraintEdges:YES];
}

- (void)viewDidMove:(PBResizableView *)view updateTrackingAndConstraintEdges:(BOOL)update {

    NSDictionary *referenceViews = [_guideReferenceViews copy];

    for (NSNumber *positionType in referenceViews) {

        if (view == _guideReferenceViews[positionType]) {

            PBGuideView *guideView = _guideViews[positionType];
            guideView.frame = [self guideFrameForView:view atPosition:positionType.integerValue];
        }
    }

    if (update) {
        [self setupTrackingRects];
        [self calculateEdgeDistances];
    }
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
    NSRect documentFrame =
    _newDocumentFrame.size.width >= 0.0f ?
    _newDocumentFrame : [_scrollView.documentView frame];
    
    CGFloat minDimension = 1.0f / self.window.backingScaleFactor;

    switch (guidePosition) {
        case PBGuidePositionLeft:

            frame = NSMakeRect(NSMinX(view.frame),
                               0.0f,
                               minDimension,
                               NSHeight(documentFrame));
            break;

        case PBGuidePositionRight:

            frame = NSMakeRect(NSMaxX(view.frame) - minDimension,
                               0.0f,
                               minDimension,
                               NSHeight(documentFrame));
            break;

        case PBGuidePositionTop:

            frame = NSMakeRect(0.0f,
                               NSMaxY(view.frame) - minDimension,
                               NSWidth(documentFrame),
                               minDimension);
            break;

        case PBGuidePositionBottom:

            frame = NSMakeRect(0.0f,
                               NSMinY(view.frame),
                               NSWidth(documentFrame),
                               minDimension);
            break;

    }
    
    return [self roundedRect:frame];
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

    CGFloat alpha = 0.0f;

    if (view != nil) {
        guideView.frame = [self guideFrameForView:view atPosition:guidePosition];
        alpha = 1.0f;

        _guideReferenceViews[@(guidePosition)] = view;

        [_scrollView.documentView addSubview:guideView positioned:NSWindowAbove relativeTo:nil];
    }

    [PBAnimator
     animateWithDuration:PB_WINDOW_ANIMATION_DURATION
     timingFunction:PB_EASE_INOUT
     animation:^{
         guideView.animator.alphaValue = alpha;
     }];
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

#pragma mark - PBSpacerProtocol Conformance

- (void)spacerViewClicked:(PBSpacerView *)spacerView {
    spacerView.constraining = !spacerView.constraining;
    PBResizableView *view1 = spacerView.view1;
    PBResizableView *view2 = spacerView.view2;

    for (PBSpacerView *view in _spacerViews) {
        if (view != spacerView &&
            view.view1 != nil &&
            view.view2 != nil) {

            if ((view.view1 == view2 &&
                 view.view2 == view1) ||
                (view.view1 == view1 &&
                 view.view2 == view2)) {
                    
                view.constraining = spacerView.constraining;
            }
        }
    }

    [view1 validateConstraints:spacerView];
    [view2 validateConstraints:spacerView];

    [[NSNotificationCenter defaultCenter]
     postNotificationName:kPBDrawingCanvasSelectedViewsNotification
     object:self
     userInfo:@{kPBDrawingCanvasSelectedViewsKey : _selectedViews}];
}

#pragma mark - Tracking Rects

- (void)removeAllToolTrackingRects {

    NSPoint mouseLocation = [self mouseLocationInDocument];

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

    NSPoint mouseLocation = [self mouseLocationInDocument];

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
    NSPoint windowLocation = [self mouseLocationInDocument];
    [_drawingTool mouseMovedToPoint:windowLocation inCanvas:self];
}

#pragma mark - PBClickableViewDelegate Conformance

- (void)viewMousedDown:(PBClickableView *)view atPoint:(NSPoint)point {

    NSPoint pointInDocument =
    [_scrollView.documentView convertPoint:point fromView:view];

    [_drawingTool mouseDown:view atPoint:pointInDocument inCanvas:self];
}

- (void)viewMousedUp:(PBClickableView *)view atPoint:(NSPoint)point {

    NSPoint pointInDocument =
    [_scrollView.documentView convertPoint:point fromView:view];

    [_drawingTool mouseUp:view atPoint:pointInDocument inCanvas:self];

    [[NSNotificationCenter defaultCenter]
     postNotificationName:kPBDrawingCanvasSelectedViewsNotification
     object:self
     userInfo:@{kPBDrawingCanvasSelectedViewsKey : _selectedViews}];
}

- (void)viewMouseDragged:(PBClickableView *)view atPoint:(NSPoint)point {

    NSPoint pointInDocument =
    [_scrollView.documentView convertPoint:point fromView:view];

    [_drawingTool mouseDragged:view toPoint:pointInDocument inCanvas:self];

    [[NSNotificationCenter defaultCenter]
     postNotificationName:kPBDrawingCanvasSelectedViewsNotification
     object:self
     userInfo:@{kPBDrawingCanvasSelectedViewsKey : _selectedViews}];
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

- (void)windowDidResize:(NSNotification *)notification {

    NSRect documentFrame = _scrollView.bounds;
    documentFrame.size.width = _scaleFactor * NSWidth(_scrollView.bounds);
    documentFrame.size.height = _scaleFactor * NSHeight(_scrollView.bounds);

    [_scrollView.documentView setFrame:documentFrame];

    [self stopMouseTracking];
    [self startMouseTracking];

    [[NSNotificationCenter defaultCenter]
     postNotificationName:kPBDrawingCanvasSelectedViewsNotification
     object:self
     userInfo:@{kPBDrawingCanvasSelectedViewsKey : _selectedViews}];

    self.lastDocumentSize = self.window.frame.size;
}

#pragma mark - Key Handling

- (void)handleKeyEvent:(NSEvent *)event {
    
//    NSLog(@"keyCode: %d, modifiers: %d", event.keyCode, event.modifierFlags);

    CGFloat minDimension = 1.0f / self.window.backingScaleFactor;

    NSInteger movementMultiplier = 1 * _scaleFactor;

    if ([event isModifiersExactly:NSShiftKeyMask] ||
        [event isModifiersExactly:NSShiftKeyMask|NSNumericPadKeyMask|NSFunctionKeyMask]) {
        movementMultiplier = 10 * _scaleFactor;
    }

    switch (event.keyCode) {
        case kVK_Delete:
            
            if ([event isModifiersExactly:0]) {

                if (_selectedViews.count == 1) {

                    PBResizableView *view = _selectedViews[0];
                    if (view.backgroundImage != nil) {
                        view.backgroundImage = nil;
                    } else {
                        [self deleteViews:_selectedViews];
                    }
                } else {
                    [self deleteViews:_selectedViews];
                }
            }
            break;
            
        case kVK_ANSI_A:
            
            if ([event isModifiersExactly:NSCommandKeyMask]) {
                [self selectAllContainers];
            }
            break;
            
        case kVK_LeftArrow:
            if ([event isModifiersExactly:0] ||
                [event isModifiersExactly:NSShiftKeyMask] ||
                [event isModifiersExactly:NSNumericPadKeyMask|NSFunctionKeyMask] ||
                [event isModifiersExactly:NSShiftKeyMask|NSNumericPadKeyMask|NSFunctionKeyMask]) {
                [self moveSelectedViews:NSMakePoint(-minDimension * movementMultiplier, 0.0f)];
            } else if ([event isModifiersExactly:NSShiftKeyMask|NSCommandKeyMask] ||
                       [event isModifiersExactly:NSShiftKeyMask|NSCommandKeyMask|NSNumericPadKeyMask|NSFunctionKeyMask]) {
                [self pinSelectedViewsLeft];
            } else if ([event isModifiersExactly:NSAlternateKeyMask] ||
                       [event isModifiersExactly:NSAlternateKeyMask|NSNumericPadKeyMask|NSFunctionKeyMask]) {
                [self toggleSelectedViewLeftConstraint];
            }

            break;

        case kVK_RightArrow:
            if ([event isModifiersExactly:0] ||
                [event isModifiersExactly:NSShiftKeyMask] ||
                [event isModifiersExactly:NSNumericPadKeyMask|NSFunctionKeyMask] ||
                [event isModifiersExactly:NSShiftKeyMask|NSNumericPadKeyMask|NSFunctionKeyMask]) {
                [self moveSelectedViews:NSMakePoint(minDimension * movementMultiplier, 0.0f)];
            } else if ([event isModifiersExactly:NSShiftKeyMask|NSCommandKeyMask] ||
                       [event isModifiersExactly:NSShiftKeyMask|NSCommandKeyMask|NSNumericPadKeyMask|NSFunctionKeyMask]) {
                [self pinSelectedViewsRight];
            } else if ([event isModifiersExactly:NSAlternateKeyMask] ||
                       [event isModifiersExactly:NSAlternateKeyMask|NSNumericPadKeyMask|NSFunctionKeyMask]) {
                [self toggleSelectedViewRightConstraint];
            }
            break;

        case kVK_UpArrow:
            if ([event isModifiersExactly:0] ||
                [event isModifiersExactly:NSShiftKeyMask] ||
                [event isModifiersExactly:NSNumericPadKeyMask|NSFunctionKeyMask] ||
                [event isModifiersExactly:NSShiftKeyMask|NSNumericPadKeyMask|NSFunctionKeyMask]) {
                [self moveSelectedViews:NSMakePoint(0.0f, minDimension * movementMultiplier)];
            } else if ([event isModifiersExactly:NSShiftKeyMask|NSCommandKeyMask] ||
                       [event isModifiersExactly:NSShiftKeyMask|NSCommandKeyMask|NSNumericPadKeyMask|NSFunctionKeyMask]) {
                [self pinSelectedViewsTop];
            } else if ([event isModifiersExactly:NSAlternateKeyMask] ||
                       [event isModifiersExactly:NSAlternateKeyMask|NSNumericPadKeyMask|NSFunctionKeyMask]) {
                [self toggleSelectedViewTopConstraint];
            }
            break;

        case kVK_DownArrow:
            if ([event isModifiersExactly:0] ||
                [event isModifiersExactly:NSShiftKeyMask] ||
                [event isModifiersExactly:NSNumericPadKeyMask|NSFunctionKeyMask] ||
                [event isModifiersExactly:NSShiftKeyMask|NSNumericPadKeyMask|NSFunctionKeyMask]) {
                [self moveSelectedViews:NSMakePoint(0.0f, -minDimension * movementMultiplier)];
            } else if ([event isModifiersExactly:NSShiftKeyMask|NSCommandKeyMask] ||
                       [event isModifiersExactly:NSShiftKeyMask|NSCommandKeyMask|NSNumericPadKeyMask|NSFunctionKeyMask]) {
                [self pinSelectedViewsBottom];
            } else if ([event isModifiersExactly:NSAlternateKeyMask] ||
                       [event isModifiersExactly:NSAlternateKeyMask|NSNumericPadKeyMask|NSFunctionKeyMask]) {
                [self toggleSelectedViewBottomConstraint];
            }
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

#pragma mark - First Responder

- (void)paste:(id)sender {

    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    NSArray *items = pasteboard.pasteboardItems;
    NSPasteboardItem *lastItem = items.lastObject;

    NSArray *imageTypesAry = @[@"public.tiff"];

    if ([[lastItem availableTypeFromArray:imageTypesAry] isEqualToString:@"public.tiff"]) {
        NSData *imageData = [lastItem dataForType:@"public.tiff"];
        [self createRectangleWithImage:[[NSImage alloc] initWithData:imageData]];
    }
}

#pragma mark - Drag n Drop

- (NSArray *)imageFilenamesForPasteboard:(id)sender {
    if ([sender respondsToSelector:@selector(draggingPasteboard)] == NO) return nil;

    NSPasteboard *pasteboard = [sender draggingPasteboard];
    NSArray *imageTypesAry = @[NSFilenamesPboardType];

    NSString *desiredType =
    [pasteboard availableTypeFromArray:imageTypesAry];

    if ([desiredType isEqualToString:NSFilenamesPboardType]) {

        NSArray *filenames =
        [pasteboard propertyListForType:@"NSFilenamesPboardType"];

        NSMutableArray *imageFilenames = [NSMutableArray array];

        for (NSString *filename in filenames) {

            NSString *ext = [[filename pathExtension] lowercaseString];

            if ([ext isEqualToString:@"png"]  ||
                [ext isEqualToString:@"tiff"] ||
                [ext isEqualToString:@"jpg"]) {
                [imageFilenames addObject:filename];
            }
        }

        return imageFilenames;
    }

    return nil;
}

- (NSDragOperation)draggingEntered:(id )sender {

    if ([sender respondsToSelector:@selector(draggingPasteboard)] == NO) {
        return NSDragOperationNone;
    }

    if ([self imageFilenamesForPasteboard:sender].count == 1) {

        if ((NSDragOperationGeneric & [sender draggingSourceOperationMask]) == NSDragOperationGeneric) {
            return NSDragOperationCopy;
        }

    } else {

        NSPasteboard *pasteboard = [sender draggingPasteboard];
        NSArray *imageTypesAry = @[NSPasteboardTypeTIFF];

        NSString *desiredType =
        [pasteboard availableTypeFromArray:imageTypesAry];

        if ([desiredType isEqualToString:NSPasteboardTypeTIFF]) {
            return NSDragOperationCopy;
        }
    }
    return NSDragOperationNone;
}

- (NSDragOperation)draggingUpdated:(id < NSDraggingInfo >)sender {
    return NSDragOperationGeneric;
}

- (void)draggingEnded:(id < NSDraggingInfo >)sender {
}

- (void)draggingExited:(id < NSDraggingInfo >)sender {
}

- (BOOL)prepareForDragOperation:(id )sender {
    return YES;
}

- (BOOL)performDragOperation:(id )sender {
    NSArray *filenames = [self imageFilenamesForPasteboard:sender];

    if (filenames.count == 1) {

        NSImage *image =
        [[NSImage alloc] initWithContentsOfFile:filenames[0]];
        [self createRectangleWithImage:image];
        return YES;
        
    } else {

        NSPasteboard *pasteboard = [sender draggingPasteboard];

        NSArray *imageTypesAry = @[NSPasteboardTypeTIFF];

        NSString *desiredType =
        [pasteboard availableTypeFromArray:imageTypesAry];

        if ([desiredType isEqualToString:NSPasteboardTypeTIFF]) {

            NSData *imageData = [pasteboard dataForType:desiredType];
            [self
             createRectangleWithImage:[[NSImage alloc] initWithData:imageData]];
        }
    }
    return NO;
}

- (void)concludeDragOperation:(id )sender {
    [self setNeedsDisplay:YES];
}

#pragma mark - Drawing

- (void)drawRect:(NSRect)dirtyRect {

    [_drawingTool drawBackgroundInCanvas:self dirtyRect:dirtyRect];
    [super drawRect:dirtyRect];
    [_drawingTool drawForegroundInCanvas:self dirtyRect:dirtyRect];
}

@end
