//
//  NSPersistentStoreCoordinator+PBFoundation.m
//  timecop
//
//  Created by Nick Bolton on 3/9/13.
//  Copyright (c) 2013 Pixelbleed LLC. All rights reserved.
//

#import "NSPersistentStoreCoordinator+PBFoundation.h"

@implementation NSPersistentStoreCoordinator (PBFoundation)

+ (NSArray *)PBF_modelsWithName:(NSString *)modelName {
    NSMutableArray *models = [NSMutableArray array];
    NSString *path = [[NSBundle mainBundle] pathForResource:modelName ofType:@"momd"];
    if(![[NSFileManager defaultManager] fileExistsAtPath:path]){
        NSLog(@"Compiled %@.momd file not found.", modelName);
    }

    NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL: [NSURL URLWithString:path] ];
    if(!model){
        NSLog(@"Could not load compiled %@.momd file.", modelName);
    }else{
        [models addObject:model];
    }

    return models;
}

+ (NSPersistentStoreCoordinator *)PBF_coordinatorWithAutoMigratingSqliteStoreNamed:(NSString *) storeFileName
                                                                         modelName:(NSString *)modelName {

    NSManagedObjectModel *model = [NSManagedObjectModel modelByMergingModels:[self PBF_modelsWithName:modelName]];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];

    [coordinator MR_addAutoMigratingSqliteStoreNamed:storeFileName];

    //HACK: lame solution to fix automigration error "Migration failed after first pass"
    if ([[coordinator persistentStores] count] == 0)
    {
        [coordinator performSelector:@selector(MR_addAutoMigratingSqliteStoreNamed:) withObject:storeFileName afterDelay:0.5];
    }

    return coordinator;
}

+ (void)PBF_setupCoreDataStackWithAutoMigratingSqliteStoreNamed:(NSString *)storeFileName
                                                      modelName:(NSString *)modelName {
    NSPersistentStoreCoordinator *coordinator = [self PBF_coordinatorWithAutoMigratingSqliteStoreNamed:storeFileName modelName:modelName];
    [NSManagedObjectContext MR_initializeDefaultContextWithCoordinator:coordinator];
}

@end
