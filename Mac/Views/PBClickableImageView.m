//
//  PBClickableImageView.m
//  Pods
//
//  Created by Nick Bolton on 6/11/13.
//
//

#import "PBClickableImageView.h"

@implementation PBClickableImageView

- (void)mouseDown:(NSEvent *)event {
    [super mouseDown:event];

    if ([self.target respondsToSelector:self.action]) {
        [self.target performSelector:self.action withObject:self];
    }
}
@end
