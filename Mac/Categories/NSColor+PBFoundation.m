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

- (void)getRGBComponents:(CGFloat *)red
                   green:(CGFloat *)green
                    blue:(CGFloat *)blue
                   alpha:(CGFloat *)alpha {

    if ([self.colorSpaceName isEqualToString:NSCalibratedWhiteColorSpace]) {

        if (red != NULL) {
            *red = self.whiteComponent;
        }
        if (blue != NULL) {
            *blue = self.whiteComponent;
        }
        if (green != NULL) {
            *green = self.whiteComponent;
        }
        if (alpha != NULL) {
            *alpha = self.alphaComponent;
        }

    } else {

        [self getRed:red green:green blue:blue alpha:alpha];
    }

}

- (NSColor *)colorWithAlpha:(CGFloat)alpha {
    
    CGFloat red;
    CGFloat blue;
    CGFloat green;

    [self getRGBComponents:&red green:&green blue:&blue alpha:&alpha];

    return
    [NSColor
     colorWithCalibratedRed:red
     green:green
     blue:blue
     alpha:alpha];
}

- (NSInteger)hexValue {
    CGFloat components[4];

    [self getRGBComponents:&components[0] green:&components[1] blue:&components[2] alpha:&components[3]];

    NSInteger red, green, blue;

    red = (components[0]*255.0f) * 65536;
    green = (components[1]*255.0f) * 256;
    blue = components[2]*255.0f;

    return red + green + blue;
}

- (NSColor *)contrastingColor {

    CGFloat val = 0;

    CGFloat red;
    CGFloat blue;
    CGFloat green;
    CGFloat alpha;

    [self getRGBComponents:&red green:&green blue:&blue alpha:&alpha];

    // Counting the perceptive luminance - human eye favors green color...
    CGFloat a = 1 - ( 0.299 * red + 0.587 * green + 0.114 * blue);

    if (a < 0.5) {
        val = 0; // bright colors - black font
    } else {
        val = 255; // dark colors - white font
    }

    return [NSColor colorWithCalibratedRed:val green:val blue:val alpha:alpha];
}

@end
