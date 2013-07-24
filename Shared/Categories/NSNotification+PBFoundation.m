//
//  NSNotification+PBFoundation.m
//  timecop
//
//  Created by Nick Bolton on 6/24/12.
//  Copyright (c) 2012 Pixelbleed LLC. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "NSNotification+PBFoundation.h"
#import "NSArray+PBFoundation.h"

@implementation NSNotification (PBFoundation)

- (NSSet *)insertedManagedObjects {
    NSDictionary *userInfo = [self userInfo];
    return [userInfo objectForKey:NSInsertedObjectsKey];
}

- (NSSet *)updatedManagedObjects {
    NSDictionary *userInfo = [self userInfo];
    return [userInfo objectForKey:NSUpdatedObjectsKey];
}

- (NSSet *)deletedManagedObjects {
    NSDictionary *userInfo = [self userInfo];
    return [userInfo objectForKey:NSDeletedObjectsKey];
}

- (NSArray *)allManagedObjectUpdates {
    NSDictionary *userInfo = [self userInfo];
    NSSet *inserted = [userInfo objectForKey:NSInsertedObjectsKey];
    NSSet *updated = [userInfo objectForKey:NSUpdatedObjectsKey];
    NSSet *deleted = [userInfo objectForKey:NSDeletedObjectsKey];
    
    if (inserted == nil) {
        inserted = [NSSet set];
    }
    
    if (updated == nil) {
        updated = [NSSet set];
    }
    
    if (deleted == nil) {
        deleted = [NSSet set];
    }
    
    return [NSArray arrayWithCollections:
            inserted, updated, deleted, nil];
}

- (NSArray *)allManagedObjectsOfType:(Class)type {

    NSMutableArray *result = [NSMutableArray array];
    
    for (id obj in [self allManagedObjectUpdates]) {
        if (type == nil || [obj isKindOfClass:type]) {
            [result addObject:obj];
        }
    }
    return result;
}

- (NSArray *)insertedManagedObjectsOfType:(Class)type {

    NSMutableArray *result = [NSMutableArray array];
    
    for (id obj in [self insertedManagedObjects]) {
        if (type == nil || [obj isKindOfClass:type]) {
            [result addObject:obj];
        }
    }
    return result;
}

- (NSArray *)updatedManagedObjectsOfType:(Class)type {
    NSMutableArray *result = [NSMutableArray array];
    
    for (id obj in [self updatedManagedObjects]) {
        if (type == nil || [obj isKindOfClass:type]) {
            [result addObject:obj];
        }
    }
    return result;

}

- (NSArray *)deletedManagedObjectsOfType:(Class)type {
    NSMutableArray *result = [NSMutableArray array];
    
    for (id obj in [self deletedManagedObjects]) {
        if (type == nil || [obj isKindOfClass:type]) {
            [result addObject:obj];
        }
    }
    return result;

}

- (BOOL)insertedManagedObjectsContainsType:(Class)type {
    for (id obj in [self insertedManagedObjects]) {
        if (type == nil || [obj isKindOfClass:type]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)updatedManagedObjectsContainsType:(Class)type {
    for (id obj in [self updatedManagedObjects]) {
        if (type == nil || [obj isKindOfClass:type]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)deletedManagedObjectsContainsType:(Class)type {
    for (id obj in [self deletedManagedObjects]) {
        if (type == nil || [obj isKindOfClass:type]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)allManagedObjectsContainsType:(Class)type {
    for (id obj in [self allManagedObjectUpdates]) {
        if (type == nil || [obj isKindOfClass:type]) {
            return YES;
        }
    }
    return NO;
}

@end
