//
//  PBShadowButtonCell.h
//  PBListView
//
//  Created by Nick Bolton on 2/9/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PBShadowButtonCell : NSButtonCell

@property (nonatomic, strong) NSColor *textShadowColor;
@property (nonatomic) NSSize textShadowOffset;
@property (nonatomic) CGFloat yOffset;

@end
