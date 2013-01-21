//
//  NSTextField+PBFoundation.m
//  PaperPlanes
//
//  Created by Nick Bolton on 1/21/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "NSTextField+PBFoundation.h"

@implementation NSTextField (PBFoundation)

- (NSSize)sizeOfText:(NSString *)text maxSize:(NSSize)maxSize {

    NSDictionary *textAttributes = @{
    NSFontAttributeName : self.font,
    };

    NSRect frame =
    [text
     boundingRectWithSize:maxSize
     options:NSStringDrawingUsesLineFragmentOrigin
     attributes:textAttributes];

    frame.size.width = maxSize.width;
    
    return frame.size;
}

- (void)resizeWithMaxSize:(NSSize)maxSize {
    NSRect frame = self.frame;
    frame.size = [self sizeOfText:self.stringValue maxSize:maxSize];
    self.frame = frame;
}

- (NSInteger)lineCount {

    NSSize size =
    NSMakeSize(NSWidth(self.superview.frame), NSHeight(self.superview.frame));

    NSSize lineSize = [self sizeOfText:@"Hello" maxSize:size];
    return (roundf((float)NSHeight(self.frame) / (float)lineSize.height));
}

@end
