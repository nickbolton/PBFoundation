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

- (void)setFrameAnimated:(NSRect)frame;

@end
