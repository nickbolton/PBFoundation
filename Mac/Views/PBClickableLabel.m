//
//  PBClickableLabel.m
//  PBFoundation
//
//  Created by Nick Bolton on 1/11/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBClickableLabel.h"

@implementation PBClickableLabel

- (void)mouseDown:(NSEvent *)event {
    [super mouseDown:event];

    if ([_delegate respondsToSelector:@selector(labelClicked:)]) {
        [_delegate labelClicked:self];
    }

    if (event.clickCount > 1) {

        if ([_delegate respondsToSelector:@selector(labelDoubleClicked:)]) {
            [_delegate labelDoubleClicked:self];
        }
    }
}

- (void)mouseUp:(NSEvent *)event {
    [super mouseUp:event];

    if ([_delegate respondsToSelector:@selector(labelMouseUp:)]) {
        [_delegate labelMouseUp:self];
    }
}

@end
