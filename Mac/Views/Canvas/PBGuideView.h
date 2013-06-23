//
//  PBGuideView.h
//  PBFoundation
//
//  Created by Nick Bolton on 6/8/12.
//  Copyright (c) 2012 Pixelbleed LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PBGuideView : NSView

@property (nonatomic, getter = isVertical) BOOL vertical;
@property (nonatomic, strong) NSImage *horizontalImage;
@property (nonatomic, strong) NSImage *verticalImage;

@end
