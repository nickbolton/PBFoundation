//
//  PBApplication.m
//  PBListView
//
//  Created by Nick Bolton on 2/10/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBApplication.h"

@implementation PBApplication

- (id)init {
    self = [super init];

    if (self != nil) {
        _userInteractionEnabled = YES;
    }

    return self;
}

- (void)sendEvent:(NSEvent *)event {
    if (_userInteractionEnabled) {
        [super sendEvent:event];
    }
}

@end
