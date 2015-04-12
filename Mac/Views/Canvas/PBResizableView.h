//
//  PBResizableView.h
//  Prototype
//
//  Created by Nick Bolton on 6/22/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBAcceptsFirstView.h"
#import "PBDrawingCanvas.h"

@class PBResizableView;
@class PBSpacerView;

@protocol PBResizableViewDelegate <PBAcceptsFirstViewDelegate>

@optional
- (void)viewDidMove:(PBResizableView *)view;

@end

@interface PBResizableView : PBAcceptsFirstView

@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSColor *backgroundColor;
@property (nonatomic, strong) NSColor *foregroundColor;
@property (nonatomic, strong) NSColor *dropTargetColor;
@property (nonatomic, strong) NSColor *highlightColor;
@property (nonatomic, strong) NSImage *backgroundImage;
@property (nonatomic, strong) NSColor *borderColor;
@property (nonatomic, strong) NSArray *borderDashPattern;
@property (nonatomic) NSInteger borderDashPhase;
@property (nonatomic) NSInteger borderWidth;
@property (nonatomic, getter = isShowingInfo) BOOL showingInfo;
@property (nonatomic, getter = isShowingInfoLabel) BOOL showingInfoLabel;
@property (nonatomic, getter = isUpdating) BOOL updating;
@property (nonatomic, weak) PBDrawingCanvas *drawingCanvas;
@property (nonatomic) NSEdgeInsets edgeDistances;
@property (nonatomic, weak) PBSpacerView *topSpacerView;
@property (nonatomic, weak) PBSpacerView *bottomSpacerView;
@property (nonatomic, weak) PBSpacerView *leftSpacerView;
@property (nonatomic, weak) PBSpacerView *rightSpacerView;
@property (nonatomic, weak) PBResizableView *closestTopView;
@property (nonatomic, weak) PBResizableView *closestBottomView;
@property (nonatomic, weak) PBResizableView *closestLeftView;
@property (nonatomic, weak) PBResizableView *closestRightView;
@property (nonatomic, readonly) NSTextField *infoLabel;
@property (nonatomic) NSRect unscaledFrame;
@property (nonatomic, getter = isSelected, readonly) BOOL selected;

- (void)setupConstraints;
- (void)updateViewConstraints;
- (void)willRotateWindow:(NSRect)frame;
- (void)validateConstraints:(PBSpacerView *)spacerView;
- (void)setViewFrame:(NSRect)frame
  withContainerFrame:(NSRect)containerFrame
             animate:(BOOL)animate;
- (void)updateSpacers;

- (NSDictionary *)dataSource;
- (void)updateTopSpaceConstraint:(CGFloat)value;
- (void)updateBottomSpaceConstraint:(CGFloat)value;
- (void)updateLeftSpaceConstraint:(CGFloat)value;
- (void)updateRightSpaceConstraint:(CGFloat)value;
- (void)updateWidthConstraint:(CGFloat)value;
- (void)updateHeightConstraint:(CGFloat)value;
- (void)updateInfo;
- (void)highlight;
- (void)unhighlight;
- (void)setDropTarget;
- (void)clearDropTarget;
- (void)setTag:(NSInteger)tag;

@end
