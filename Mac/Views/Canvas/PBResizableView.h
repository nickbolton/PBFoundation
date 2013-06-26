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
@class PBGuideView;

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
@property (nonatomic, getter = isUpdating) BOOL updating;
@property (nonatomic, weak) PBDrawingCanvas *drawingCanvas;
@property (nonatomic) NSEdgeInsets edgeDistances;
@property (nonatomic, weak) PBGuideView *topSpacerView;
@property (nonatomic, weak) PBGuideView *bottomSpacerView;
@property (nonatomic, weak) PBGuideView *leftSpacerView;
@property (nonatomic, weak) PBGuideView *rightSpacerView;
@property (nonatomic, weak) NSView *closestTopView;
@property (nonatomic, weak) NSView *closestBottomView;
@property (nonatomic, weak) NSView *closestLeftView;
@property (nonatomic, weak) NSView *closestRightView;

- (void)setupConstraints;
- (void)setViewFrame:(NSRect)frame animated:(BOOL)animated;

@end
