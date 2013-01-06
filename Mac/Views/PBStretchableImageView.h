//
//  PBStretchableImageView.h
//  PaperPlanes
//
//  Created by Nick Bolton on 1/5/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PBStretchableImageView : NSImageView

@property (nonatomic, strong) NSImage *topImage;
@property (nonatomic, strong) NSImage *middleImage;
@property (nonatomic, strong) NSImage *bottomImage;
@property (nonatomic, getter = isVertical) BOOL vertical;
@property (nonatomic, getter = isFlipped) BOOL flipped;
@property (nonatomic) CGFloat alpha;

@end
