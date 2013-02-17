//
//  PBListViewImageBinder.m
//  PBListView
//
//  Created by Nick Bolton on 2/10/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBListViewImageBinder.h"
#import "PBListViewUIElementMeta.h"

@implementation PBListViewImageBinder

- (id)buildUIElement:(PBListView *)listView {
    NSImageView *imageView =
    [[NSImageView alloc] initWithFrame:NSZeroRect];
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    imageView.imageScaling = NSImageScaleNone;
    imageView.imageAlignment = NSImageAlignCenter;
    return imageView;
}

- (void)postGlobalConfiguration:(PBListView *)listView
                           meta:(PBListViewUIElementMeta *)meta
                           view:(NSImageView *)imageView {
    
    NSAssert([imageView isKindOfClass:[NSImageView class]], @"view is not a NSImageView");

    imageView.image = meta.image;

    NSRect frame = imageView.frame;
    frame.size = meta.image.size;
    imageView.frame = frame;

    meta.size = meta.image.size;
}

@end
