//
//  PBGuideView.m
//  PBFoundation
//
//  Created by Nick Bolton on 6/8/12.
//  Copyright (c) 2012 Pixelbleed LLC. All rights reserved.
//

#import "PBGuideView.h"

static NSImage *PBGuideViewHorizontalImage = nil;
static NSImage *PBGuideViewVerticalImage = nil;

@interface PBGuideView()

- (void)drawVertical:(NSRect)frame;
- (void)drawHorizontal:(NSRect)frame;
@end

@implementation PBGuideView

+ (void)setHorizontalImage:(NSImage *)image {
    PBGuideViewHorizontalImage = image;
}

+ (void)setVerticalImage:(NSImage *)image {
    PBGuideViewVerticalImage = image;
}

+ (NSImage *)horizontalImage {
    if (PBGuideViewHorizontalImage == nil) {
        PBGuideViewHorizontalImage = [NSImage imageNamed:@"guideHorizontal"];
    }
    return PBGuideViewHorizontalImage;

}

+ (NSImage *)verticalImage {
    if (PBGuideViewVerticalImage == nil) {
        PBGuideViewVerticalImage = [NSImage imageNamed:@"guideVertical"];
    }
    return PBGuideViewVerticalImage;
}

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
}

- (void)setFrame:(NSRect)frameRect {
    if (NSWidth(frameRect) > 0.0f && NSHeight(frameRect) > 0.0f) {
//        NSLog(@"%s frame: %@", __PRETTY_FUNCTION__, NSStringFromRect(frameRect));

        [super setFrame:frameRect];
    }
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

    NSColor *fillColor = [NSColor colorWithPatternImage:[PBGuideView horizontalImage]];
    [fillColor set];
    NSRectFill([self bounds]);
    
    [currentContext restoreGraphicsState];
}

- (void)drawVertical:(NSRect)frame {
    
    NSGraphicsContext *currentContext = [NSGraphicsContext currentContext];
    [currentContext saveGraphicsState];
    
    NSColor *fillColor = [NSColor colorWithPatternImage:[PBGuideView verticalImage]];
    [fillColor set];
    NSRectFill([self bounds]);
    
    [currentContext restoreGraphicsState];
}

@end
