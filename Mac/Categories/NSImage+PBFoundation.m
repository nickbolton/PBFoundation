//
//  NSImage+PBFoundation.m
//  PBFoundation
//
//  Created by Nick Bolton on 12/23/12.
//  Copyright (c) 2012 Pixelbleed. All rights reserved.
//

#import "NSImage+PBFoundation.h"

@implementation NSImage (PBFoundation)

- (NSData *)pngData {

    [self lockFocus];

    NSBitmapImageRep* bitmapRep =
    [[NSBitmapImageRep alloc]
     initWithFocusedViewRect:NSMakeRect(0, 0, self.size.width, self.size.height)];

    [self unlockFocus];

    return [bitmapRep representationUsingType:NSPNGFileType properties:nil];
}

@end
