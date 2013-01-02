//
//  UIImage+PBFoundation.m
//  PBFoundation
//
//  Created by Nick Bolton on 12/12/12.
//  Copyright (c) 2012 Pixelbleed. All rights reserved.
//

#import "UIImage+PBFoundation.h"

@implementation UIImage (PBFoundation)

- (UIColor *)colorAtPoint:(CGPoint)point {
    /* adapted from top answer on stack overflow:
     http://stackoverflow.com/questions/448125/how-to-get-pixel-data-from-a-uiimage-cocoa-touch-or-cgimage-core-graphics
     */

    // First get the image into your data buffer
    CGImageRef imageRef = [self CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    size_t length = height * width * 4;
    unsigned char *rawData = (unsigned char*) calloc(length, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);

    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);

    // Now your rawData contains the image data in the RGBA8888 pixel format.
    NSInteger byteIndex = (bytesPerRow * (NSInteger)point.y) + (NSInteger)point.x * bytesPerPixel;

    UIColor *aColor = nil;

    if (byteIndex < length) {
        CGFloat red   = (CGFloat)rawData[byteIndex] / 255.f;
        CGFloat green = (CGFloat)rawData[byteIndex + 1] / 255.f;
        CGFloat blue  = (CGFloat)rawData[byteIndex + 2] / 255.f;
        CGFloat alpha = (CGFloat)rawData[byteIndex + 3] / 255.f;

        aColor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
    }

    free(rawData);

    return aColor;
}

- (NSArray *)colorsForStripAtX:(NSUInteger)x {
    NSMutableArray *colors = [NSMutableArray arrayWithCapacity:self.size.height];

    CGImageRef imageRef = [self CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    size_t length = height * width * 4;
    unsigned char *rawData = (unsigned char*) calloc(length, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);

    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);

    // Now your rawData contains the image data in the RGBA8888 pixel format.
    for (NSInteger row = 0; row < (NSInteger)self.size.height; row++) {
        NSInteger byteIndex = (bytesPerRow * row) + x * bytesPerPixel;

        UIColor *aColor = nil;

        if (byteIndex < length) {
            CGFloat red   = (CGFloat)rawData[byteIndex] / 255.f;
            CGFloat green = (CGFloat)rawData[byteIndex + 1] / 255.f;
            CGFloat blue  = (CGFloat)rawData[byteIndex + 2] / 255.f;
            CGFloat alpha = (CGFloat)rawData[byteIndex + 3] / 255.f;

            aColor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
        }

        if (aColor) {
            [colors addObject:aColor];
        }
    }

    free(rawData);

    return colors;
}

- (NSArray *)colorsForStripAtY:(NSUInteger)y {
    NSMutableArray *colors = [NSMutableArray arrayWithCapacity:self.size.height];

    CGImageRef imageRef = [self CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    size_t length = height * width * 4;
    unsigned char *rawData = (unsigned char*) calloc(length, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);

    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);

    // Now your rawData contains the image data in the RGBA8888 pixel format.
    for (NSInteger column = 0; column < (NSInteger)self.size.height; column++) {
        NSInteger byteIndex = (bytesPerRow * y) + column * bytesPerPixel;

        UIColor *aColor = nil;

        if (byteIndex < length) {
            CGFloat red   = (CGFloat)rawData[byteIndex] / 255.f;
            CGFloat green = (CGFloat)rawData[byteIndex + 1] / 255.f;
            CGFloat blue  = (CGFloat)rawData[byteIndex + 2] / 255.f;
            CGFloat alpha = (CGFloat)rawData[byteIndex + 3] / 255.f;

            aColor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
        }

        if (aColor) {
            [colors addObject:aColor];
        }
    }

    free(rawData);

    return colors;
}

@end
