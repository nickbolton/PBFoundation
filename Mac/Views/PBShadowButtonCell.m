//
//  PBShadowButtonCell.m
//  PBListView
//
//  Created by Nick Bolton on 2/9/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBShadowButtonCell.h"

@implementation PBShadowButtonCell

- (NSRect)drawTitle:(NSAttributedString *)title
          withFrame:(NSRect)frame
             inView:(NSView *)controlView {

    if (_textShadowColor != nil) {
        NSShadow *shadow = [[NSShadow alloc] init];
        shadow.shadowColor = _textShadowColor;
        shadow.shadowOffset = _textShadowOffset;
        shadow.shadowBlurRadius = 0.0f;
        [shadow set];
    }

    frame.origin.y += _yOffset;

    return
    [super
     drawTitle:title
     withFrame:frame
     inView:controlView];
}

@end
