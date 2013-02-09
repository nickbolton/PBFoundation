//
//  NSButton+PBFoundation.m
//  PBFoundation
//
//  Created by Nick Bolton on 1/5/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "NSButton+PBFoundation.h"

@implementation NSButton (PBFoundation)

- (NSColor *)textColor {
    NSAttributedString *attrTitle = [self attributedTitle];
    NSUInteger len = [attrTitle length];
    NSRange range = NSMakeRange(0, MIN(len, 1)); // take color from first char
    NSDictionary *attrs = [attrTitle fontAttributesInRange:range];
    NSColor *textColor = [NSColor controlTextColor];
    if (attrs) {
        textColor = [attrs objectForKey:NSForegroundColorAttributeName];
    }
    return textColor;
}

- (void)setTextColor:(NSColor *)textColor {
    NSMutableAttributedString *attrTitle = [[NSMutableAttributedString alloc]
                                            initWithAttributedString:[self attributedTitle]];
    NSUInteger len = [attrTitle length];
    NSRange range = NSMakeRange(0, len);
    [attrTitle addAttribute:NSForegroundColorAttributeName
                      value:textColor
                      range:range];
    [attrTitle fixAttributesInRange:range];
    [self setAttributedTitle:attrTitle];
}

@end
