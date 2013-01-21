//
//  NSTextField+PBFoundation.h
//  PaperPlanes
//
//  Created by Nick Bolton on 1/21/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSTextField (PBFoundation)

- (NSInteger)lineCount;
- (NSSize)sizeOfText:(NSString *)text maxSize:(NSSize)maxSize;
- (void)resizeWithMaxSize:(NSSize)maxSize;

@end
