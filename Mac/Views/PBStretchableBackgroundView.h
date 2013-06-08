//
//  PBStretchableBackgroundView.h
//  PBFoundation
//
//  Created by Nick Bolton on 1/5/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PBStretchableBackgroundView : NSImageView

@property (nonatomic, strong) NSImage *backgroundImage;
@property (nonatomic, strong) NSString *backgroundImageName;

@end
