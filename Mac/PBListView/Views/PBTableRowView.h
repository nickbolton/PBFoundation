//
//  PBTableRowView.h
//  PBListView
//
//  Created by Nick Bolton on 2/10/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PBTableRowView;

@protocol PBTableRowDelegate <NSObject>

@required
- (void)rowViewSetHoverState:(PBTableRowView *)rowView;
- (void)rowViewClearHoverState:(PBTableRowView *)rowView;

@end

@interface PBTableRowView : NSTableRowView

@property (nonatomic, strong) NSColor *selectedBackgroundColor;
@property (nonatomic, strong) NSColor *selectedBorderColor;
@property (nonatomic) CGFloat selectedBorderRadius;

@property (nonatomic, strong) NSImage *backgroundImage;
@property (nonatomic, strong) NSImage *hoveringBackgroundImage;
@property (nonatomic, strong) NSImage *selectedBackgroundImage;
@property (nonatomic, strong) NSImage *selectedHoveringBackgroundImage;
@property (nonatomic, strong) NSImage *expandedBackgroundImage;
@property (nonatomic, strong) NSImage *expandedHoveringBackgroundImage;

@property (nonatomic, strong) NSImageView *backgroundImageView;

@property (nonatomic, weak) id <PBTableRowDelegate> delegate;

@property (nonatomic, getter = isExpanded) BOOL expanded;
@property (nonatomic, readonly, getter = isHovering) BOOL hovering;

- (void)startMouseEnteredEvents;
- (void)stopMouseEnteredEvents;
- (BOOL)mouseEnteredEventsStarted;

@end
