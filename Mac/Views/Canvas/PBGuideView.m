//
//  PBGuideView.m
//  PBFoundation
//
//  Created by Nick Bolton on 6/8/12.
//  Copyright (c) 2012 Pixelbleed LLC. All rights reserved.
//

#import "PBGuideView.h"

NSImage *MMGuideViewVerticalImage = nil;
NSImage *MMGuideViewHorizontalImage = nil;

NSImage * getMMGuideViewVerticalImage() {
    if (MMGuideViewVerticalImage == nil) {
        MMGuideViewVerticalImage = [NSImage imageNamed:@"guideVertical.png"];
    }
    return MMGuideViewVerticalImage;
}

NSImage * getMMGuideViewHorizontalImage() {
    if (MMGuideViewHorizontalImage == nil) {
        MMGuideViewHorizontalImage = [NSImage imageNamed:@"guideHorizontal.png"];
    }
    return MMGuideViewHorizontalImage;
}

@interface MMGuideView()

- (void)drawVertical:(NSRect)frame;
- (void)drawHorizontal:(NSRect)frame;
@end

@implementation MMGuideView

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

    NSColor *fillColor = [NSColor colorWithPatternImage:getMMGuideViewHorizontalImage()];
    [fillColor set];
    NSRectFill([self bounds]);
    
    [currentContext restoreGraphicsState];
}

- (void)drawVertical:(NSRect)frame {
    
    NSGraphicsContext *currentContext = [NSGraphicsContext currentContext];
    [currentContext saveGraphicsState];
    
    NSColor *fillColor = [NSColor colorWithPatternImage:getMMGuideViewVerticalImage()];
    [fillColor set];
    NSRectFill([self bounds]);
    
    [currentContext restoreGraphicsState];
}

@end
