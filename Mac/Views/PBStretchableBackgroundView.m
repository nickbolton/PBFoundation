//
//  PBStretchableBackgroundView.m
//  PBFoundation
//
//  Created by Nick Bolton on 1/5/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBStretchableBackgroundView.h"

@interface PBStretchableBackgroundView()

@property (nonatomic, strong) NSColor *backgroundColor;

@end

@implementation PBStretchableBackgroundView

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
}

- (void)setBackgroundImageName:(NSString *)backgroundImageName {
    _backgroundImageName = backgroundImageName;
    self.backgroundImage = [NSImage imageNamed:backgroundImageName];
}

- (void)setBackgroundImage:(NSImage *)backgroundImage {
    _backgroundImage = backgroundImage;
    self.backgroundColor =
    [NSColor colorWithPatternImage:backgroundImage];
}

- (void)drawRect:(NSRect)dirtyRect {

    NSGraphicsContext* context = [NSGraphicsContext currentContext];
    [context saveGraphicsState];
    [[NSGraphicsContext currentContext] setPatternPhase:NSMakePoint(0,[self frame].size.height)];
    [self.backgroundColor set];
    NSRectFill([self bounds]);
    [context restoreGraphicsState];

    [super drawRect:dirtyRect];
}

@end
