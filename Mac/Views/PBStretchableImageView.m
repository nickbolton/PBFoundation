//
//  PBStretchableImageView.m
//  PaperPlanes
//
//  Created by Nick Bolton on 1/5/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBStretchableImageView.h"

@implementation PBStretchableImageView

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
    _vertical = NO;
    _flipped = NO;
    _alpha = 1.0f;
}

- (void)drawRect:(NSRect)rect {

    NSDrawThreePartImage(rect,
                         _topImage,
                         _middleImage,
                         _bottomImage,
                         _vertical,
                         NSCompositeSourceOver,
                         _alpha,
                         _flipped);
}

@end
