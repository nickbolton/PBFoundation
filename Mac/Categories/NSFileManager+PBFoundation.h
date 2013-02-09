//
//  NSFileManager+PBFoundation.h
//  PBFoundation
//
//  Created by Nick Bolton on 12/19/12.
//  Copyright (c) 2012 Pixelbleed. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (PBFoundation)

+ (void)deleteItemAtPathIfNecessary:(NSString *)itemPath error:(NSError **)error;

@end
