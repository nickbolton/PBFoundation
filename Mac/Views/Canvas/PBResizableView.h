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

@property (nonatomic, strong) NSColor *backgroundColor;
@property (nonatomic, strong) NSColor *borderColor;
@property (nonatomic, strong) NSArray *borderDashPattern;
@property (nonatomic) NSInteger borderDashPhase;
@property (nonatomic) NSInteger borderWidth;
@property (nonatomic) NSInteger tag;
@property (nonatomic, getter = isShowingInfo) BOOL showingInfo;
@property (nonatomic, getter = isShowingInfoLabel) BOOL showingInfoLabel;
@property (nonatomic, getter = isUpdating) BOOL updating;
@property (nonatomic, weak) PBDrawingCanvas *drawingCanvas;
@property (nonatomic) NSEdgeInsets edgeDistances;
@property (nonatomic, weak) PBSpacerView *topSpacerView;
@property (nonatomic, weak) PBSpacerView *bottomSpacerView;
@property (nonatomic, weak) PBSpacerView *leftSpacerView;
@property (nonatomic, weak) PBSpacerView *rightSpacerView;
@property (nonatomic, weak) NSView *closestTopView;
@property (nonatomic, weak) NSView *closestBottomView;
@property (nonatomic, weak) NSView *closestLeftView;
@property (nonatomic, weak) NSView *closestRightView;
@property (nonatomic, readonly) NSTextField *infoLabel;

- (void)setupConstraints;
- (void)setViewFrame:(NSRect)frame animated:(BOOL)animated;

@end
