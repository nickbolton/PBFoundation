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

@synthesize flipped = _flipped;

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

- (void)drawRect:(NSRect)dirtyRect {

    NSDrawThreePartImage(self.bounds,
                         _startCapImage,
                         _centerFillImage,
                         _endCapImage,
                         _vertical,
                         NSCompositeSourceAtop,
                         1.0f,
                         _flipped);

    [super drawRect:dirtyRect];
}

@end
