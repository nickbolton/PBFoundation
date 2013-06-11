//
//  PBMoveableView.h
//  timecop
//
//  Created by Nick Bolton on 11/23/11.
//  Copyright (c) 2011 Pixelbleed LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PPMainView.h"

@class PBMoveableView;

@protocol PBMoveableViewDelegate <NSObject>

- (void)moveableViewMoved:(PBMoveableView *)view;
- (void)moveableViewMouseDown:(PBMoveableView *)view;
- (void)moveableViewMouseUp:(PBMoveableView *)view;

@end

@interface PBMoveableView : PPMainView

@property (nonatomic, weak) IBOutlet id <PBMoveableViewDelegate> delegate;

@property (nonatomic, getter = isEnabled) BOOL enabled;
@property (nonatomic, getter = isDragging, readonly) BOOL dragging;
@property (nonatomic) NSEdgeInsets screenInsets;

- (void)commonInit;

@end
