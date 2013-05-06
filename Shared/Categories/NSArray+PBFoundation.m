//
//  NSArray+PBFoundation.m
//  SocialScreen
//
//  Created by Nick Bolton on 1/2/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "NSArray+PBFoundation.h"
#import <CoreData/CoreData.h>

@implementation NSArray (PBFoundation)

- (NSArray *)objectIDArray {

    NSMutableArray *result = [NSMutableArray arrayWithCapacity:self.count];

    for (NSManagedObject *entity in self) {
        if ([entity isKindOfClass:[NSManagedObject class]]) {
            if (entity.objectID != nil) {
                [result addObject:entity.objectID];
            }
        }
    }
    return result;
}

- (id)firstObject {

    id first = nil;

    if (self.count > 0) {
        first = self[0];
    }

    return first;
}

+ (NSArray *)arrayWithCollections:(id)collectionObject, ... {

    if (collectionObject == nil) {
        return [NSArray array];
    }

    NSMutableArray *array = [NSMutableArray array];

    if ([collectionObject isKindOfClass:[NSArray class]]) {
        [array addObjectsFromArray:collectionObject];
    } else if ([collectionObject isKindOfClass:[NSSet class]]) {
        [array addObjectsFromArray:((NSSet *)collectionObject).allObjects];
    } else {
        assert(NO);
    }

    va_list args;
    va_start(args, collectionObject);
    id collection;

    while ( (collection = va_arg ( args, id )) ) {

        if ([collection isKindOfClass:[NSArray class]]) {
            [array addObjectsFromArray:collection];
        } else if ([collection isKindOfClass:[NSSet class]]) {
            [array addObjectsFromArray:((NSSet *)collection).allObjects];
        } else {
            assert(NO);
        }
    }

    va_end ( args );

    return array;
}

@end
