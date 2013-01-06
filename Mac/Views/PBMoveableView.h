//
//  PBMoveableView.h
//  timecop
//
//  Created by Nick Bolton on 11/23/11.
//  Copyright (c) 2011 Pixelbleed LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PBMoveableView;

@protocol PBMoveableViewDelegate <NSObject>

- (void)moveableViewMoved:(PBMoveableView *)view;

@end

@interface PBMoveableView : NSView

@property (nonatomic, weak) IBOutlet id <PBMoveableViewDelegate> delegate;

@end
