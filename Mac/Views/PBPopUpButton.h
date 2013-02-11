//
//  PBPopUpButton.h
//  PBListView
//
//  Created by Nick Bolton on 2/10/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PBPopUpButton : NSPopUpButton

@property (nonatomic) CGFloat offAlphaValue;
@property (nonatomic) CGFloat onAlphaValue;
@property (nonatomic) BOOL hoverAlphaEnabled;

- (void)startTracking;
- (void)stopTracking;

@end
