//
//  PBClickableView.h
//  MiniMeasure
//
//  Created by Nick Bolton on 6/8/12.
//  Copyright (c) 2012 Pixelbleed LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PBAcceptsFirstView.h"

@class PBClickableView;

@protocol PBClickableViewDelegate <PBAcceptsFirstViewDelegate>

@optional
- (void)viewMousedDown:(PBClickableView *)view atPoint:(NSPoint)point;
- (void)viewMousedUp:(PBClickableView *)view atPoint:(NSPoint)point;
- (void)viewMouseDragged:(PBClickableView *)view atPoint:(NSPoint)point;

@end

@interface PBClickableView : PBAcceptsFirstView

@end
