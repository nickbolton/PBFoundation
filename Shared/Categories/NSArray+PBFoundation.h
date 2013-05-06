//
//  NSArray+PBFoundation.h
//  SocialScreen
//
//  Created by Nick Bolton on 1/2/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (PBFoundation)

+ (NSArray *)arrayWithCollections:(id)collectionObject, ...;

- (NSArray *)objectIDArray;

- (id)firstObject;
@end
