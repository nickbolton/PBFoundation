//
//  NSImage+PBFoundation.m
//  PBFoundation
//
//  Created by Nick Bolton on 12/23/12.
//  Copyright (c) 2012 Pixelbleed. All rights reserved.
//

#import "NSImage+PBFoundation.h"
#import <QuickLook/QuickLook.h>

@implementation NSImage (PBFoundation)

- (NSData *)pngData {

    [self lockFocus];

    NSBitmapImageRep* bitmapRep =
    [[NSBitmapImageRep alloc]
     initWithFocusedViewRect:NSMakeRect(0, 0, self.size.width, self.size.height)];

    [self unlockFocus];

    return [bitmapRep representationUsingType:NSPNGFileType properties:nil];
}


+ (NSImage *)imageWithPreviewOfFileAtPath:(NSString *)path
                                   ofSize:(NSSize)size
                                   asIcon:(BOOL)icon {

    NSURL *fileURL = [NSURL fileURLWithPath:path];
    if (!path || !fileURL) {
        return nil;
    }

    NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:icon]
                                                     forKey:(NSString *)kQLThumbnailOptionIconModeKey];
    CGImageRef ref = QLThumbnailImageCreate(kCFAllocatorDefault,
                                            (__bridge CFURLRef)fileURL,
                                            CGSizeMake(size.width, size.height),
                                            (__bridge CFDictionaryRef)dict);

    if (ref != NULL) {
        // Take advantage of NSBitmapImageRep's -initWithCGImage: initializer, new in Leopard,
        // which is a lot more efficient than copying pixel data into a brand new NSImage.
        // Thanks to Troy Stephens @ Apple for pointing this new method out to me.
        NSBitmapImageRep *bitmapImageRep = [[NSBitmapImageRep alloc] initWithCGImage:ref];
        NSImage *newImage = nil;
        if (bitmapImageRep) {
            newImage = [[NSImage alloc] initWithSize:[bitmapImageRep size]];
            [newImage addRepresentation:bitmapImageRep];

            if (newImage) {
                CFRelease(ref);
                return newImage;
            }
        }
        CFRelease(ref);
    } else {
        // If we couldn't get a Quick Look preview, fall back on the file's Finder icon.
        NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFile:path];
        if (icon) {
            [icon setSize:size];
        }
        return icon;
    }

    return nil;
}

@end
