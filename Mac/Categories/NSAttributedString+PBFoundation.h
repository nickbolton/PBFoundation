//
//  NSAttributedString+PBFoundation.h
//  PBFoundation
//
//  Created by Nick Bolton on 12/26/11.
//  Copyright (c) 2011 Pixelbleed LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSAttributedString (PBFoundation)

+ (NSAttributedString *)attributedString:(NSString *)text
                                    font:(NSFont *)font
                                   color:(NSColor *)color
                             shadowColor:(NSColor *)shadowColor
                            shadowOffset:(NSSize)shadowOffset;

@end
