//
//  PBGuideView.m
//  PBFoundation
//
//  Created by Nick Bolton on 6/8/12.
//  Copyright (c) 2012 Pixelbleed LLC. All rights reserved.
//

#import "PBGuideView.h"

@interface PBGuideView()

- (void)drawVertical:(NSRect)frame;
- (void)drawHorizontal:(NSRect)frame;
@end

@implementation PBGuideView

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

- (void)commonInit {
    self.horizontalImage = [NSImage imageNamed:@"guideHorizontal.png"];
    self.verticalImage = [NSImage imageNamed:@"guideVertical.png"];
}

- (void)drawRect:(NSRect)dirtyRect {
    
    if (_vertical) {
        [self drawVertical:dirtyRect];
    } else {
        [self drawHorizontal:dirtyRect];
    }
}

- (void)drawHorizontal:(NSRect)frame {
    
    NSGraphicsContext *currentContext = [NSGraphicsContext currentContext];
    [currentContext saveGraphicsState];

    NSColor *fillColor = [NSColor colorWithPatternImage:_horizontalImage];
    [fillColor set];
    NSRectFill([self bounds]);
    
    [currentContext restoreGraphicsState];
}

- (void)drawVertical:(NSRect)frame {
    
    NSGraphicsContext *currentContext = [NSGraphicsContext currentContext];
    [currentContext saveGraphicsState];
    
    NSColor *fillColor = [NSColor colorWithPatternImage:_verticalImage];
    [fillColor set];
    NSRectFill([self bounds]);
    
    [currentContext restoreGraphicsState];
}

@end
