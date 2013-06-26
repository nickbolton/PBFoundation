//
//  PBGuideView.h
//  PBFoundation
//
//  Created by Nick Bolton on 6/8/12.
//  Copyright (c) 2012 Pixelbleed LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PBGuideView : NSView

+ (void)setHorizontalImage:(NSImage *)image;
+ (void)setVerticalImage:(NSImage *)image;

@property (nonatomic, getter = isVertical) BOOL vertical;

@end
