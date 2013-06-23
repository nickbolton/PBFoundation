//
//  NSColor+PBFoundation.m
//  PBFoundation
//
//  Created by Nick Bolton on 1/16/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "NSColor+PBFoundation.h"

@implementation NSColor (PBFoundation)

+ (NSColor *)colorWithRGBHex:(UInt32)hex {
    return [NSColor colorWithRGBHex:hex alpha:1.0f];
}

+ (NSColor *)colorWithRGBHex:(UInt32)hex alpha:(CGFloat)alpha {
    int r = (hex >> 16) & 0xFF;
    int g = (hex >> 8) & 0xFF;
    int b = (hex) & 0xFF;
    
    return
    [NSColor
     colorWithCalibratedRed:r / 255.0f
     green:g / 255.0f
     blue:b / 255.0f
     alpha:alpha];
}

- (NSColor *)colorWithAlpha:(CGFloat)alpha {
    
    CGFloat red;
    CGFloat blue;
    CGFloat green;

    [self getRed:&red green:&green blue:&blue alpha:nil];
    
    return
    [NSColor
     colorWithCalibratedRed:red
     green:green
     blue:blue
     alpha:alpha];
}

@end
