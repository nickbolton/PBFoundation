//
//  PBShadowTextFieldCell.m
//  PBFoundation
//
//  Created by Nick Bolton on 2/9/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBShadowTextFieldCell.h"

@implementation PBShadowTextFieldCell

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {

    if (_textShadowColor != nil) {
        NSShadow *shadow = [[NSShadow alloc] init];
        shadow.shadowColor = _textShadowColor;
        shadow.shadowOffset = _textShadowOffset;
        shadow.shadowBlurRadius = 0.0f;
        [shadow set];
    }

    [super drawInteriorWithFrame:cellFrame inView:controlView];
}

@end
