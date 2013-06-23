//
//  PBAcceptsFirstView.m
//  timecop
//
//  Created by Nick Bolton on 12/22/11.
//  Copyright (c) 2011 Pixelbleed LLC. All rights reserved.
//

#import "PBAcceptsFirstView.h"

@implementation PBAcceptsFirstView

- (BOOL)acceptsFirstMouse:(NSEvent *)event {
    return YES;
}

- (BOOL)acceptsFirstResponder {
    return YES;
}

- (BOOL)becomeFirstResponder {
    return YES;
}

#pragma mark - Key Handling

- (void)keyDown:(NSEvent *)event {
    [_delegate handleKeyEvent:event];
}

@end
