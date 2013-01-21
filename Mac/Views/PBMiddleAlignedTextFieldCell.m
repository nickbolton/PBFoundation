//
//  PBMiddleAlignedTextFieldCell.m
//  PBFoundation
//
//  Created by Nick Bolton on 2/2/11.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBMiddleAlignedTextFieldCell.h"

@implementation PBMiddleAlignedTextFieldCell

- (NSRect)titleRectForBounds:(NSRect)theRect {
    NSRect titleFrame = [super titleRectForBounds:theRect];
    NSSize titleSize = [[self attributedStringValue] size];
    titleFrame.origin.y = _yoffset + theRect.origin.y - .5 + (theRect.size.height - titleSize.height) / 2.0;
    return NSIntegralRect(titleFrame);
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    NSRect titleRect = [self titleRectForBounds:cellFrame];
    [[self attributedStringValue] drawInRect:titleRect];
}

@end
