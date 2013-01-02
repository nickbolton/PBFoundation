//
//  UIColor+PBFoundation.m
//  PBFoundation
//
//  Created by Nick Bolton on 3/24/12.
//  Copyright (c) 2012 Pixelbleed LLC. All rights reserved.
//

#import "UIColor+PBFoundation.h"

@implementation UIColor (PBFoundation)

+ (UIColor *)randomColor {
    CGFloat red =  (CGFloat)random()/(CGFloat)RAND_MAX;
    CGFloat blue = (CGFloat)random()/(CGFloat)RAND_MAX;
    CGFloat green = (CGFloat)random()/(CGFloat)RAND_MAX;
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
}

+ (UIColor *)colorWithRGBHex:(UInt32)hex {
    return [UIColor colorWithRGBHex:hex alpha:1.0f];
}

+ (UIColor *)colorWithRGBHex:(UInt32)hex alpha:(CGFloat)alpha {
	int r = (hex >> 16) & 0xFF;
	int g = (hex >> 8) & 0xFF;
	int b = (hex) & 0xFF;
    
	return [UIColor colorWithRed:r / 255.0f
						   green:g / 255.0f
							blue:b / 255.0f
						   alpha:alpha];
}

- (UIColor *)colorWithAlpha:(CGFloat)alpha {
    
    CGFloat red;
    CGFloat blue;
    CGFloat green;

    [self getRed:&red green:&green blue:&blue alpha:nil];
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

- (UIColor *)contrastingColor {
    
    CGFloat hue, saturation, brightness, alpha;
    
    [self getHue:&hue
      saturation:&saturation
      brightness:&brightness
           alpha:&alpha];

    return [UIColor colorWithHue:1-hue
                      saturation:saturation
                      brightness:brightness
                           alpha:alpha];
}

@end
