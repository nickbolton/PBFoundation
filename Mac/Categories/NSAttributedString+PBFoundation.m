//
//  NSAttributedString+PBFoundation.m
//  PBFoundation
//
//  Created by Nick Bolton on 12/26/11.
//  Copyright (c) 2011 Pixelbleed LLC. All rights reserved.
//

#import "NSAttributedString+PBFoundation.h"

@implementation NSAttributedString (PBFoundation)

+ (NSAttributedString *)attributedString:(NSString *)text
                                    font:(NSFont *)font
                                   color:(NSColor *)color
                             shadowColor:(NSColor *)shadowColor
                            shadowOffset:(NSSize)shadowOffset {

    NSMutableDictionary *attributes =
    [@{
     NSFontAttributeName : font,
     NSForegroundColorAttributeName : color,
    } mutableCopy];

    NSShadow *shadow = nil;

    if (shadowColor != nil) {
        shadow = [[NSShadow alloc] init];
        shadow.shadowColor = shadowColor;
        shadow.shadowOffset = shadowOffset;
        [attributes setObject:shadow forKey:NSShadowAttributeName];
    }

    return
    [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

@end
