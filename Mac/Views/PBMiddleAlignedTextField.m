//
//  PBMiddleAlignedTextField.m
//  PBFoundation
//
//  Created by Nick Bolton on 2/3/11.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBMiddleAlignedTextField.h"

@implementation PBMiddleAlignedTextField

- (void)drawRect:(NSRect)rect {
    NSRect drawFrame = rect;
    NSSize titleSize = [[self attributedStringValue] size];
    drawFrame.origin.y = _yoffset + drawFrame.origin.y - .5 + (drawFrame.size.height - titleSize.height) / 2.0;

    drawFrame = NSIntegralRect(drawFrame);
    [super drawRect:drawFrame];
}

@end
