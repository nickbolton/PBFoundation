//
//  PBManagedObjectContextManager.h
//  PBFoundation
//
//  Created by Nick Bolton on 12/22/12.
//  Copyright 2012 Pixelbleed. All rights reserved.
//

@interface PBManagedObjectContextManager : NSObject

@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSManagedObjectContext *globalObjectContext;
@property (nonatomic, strong) NSString *storeFolder;
@property (nonatomic, strong) NSString *storeName;
@property (nonatomic, strong) NSString *storeExtension;
@property (nonatomic, readonly) dispatch_queue_t backgroundQueue;

- (id)initWithStoreFolder:(NSString *)storeFolder
                storeName:(NSString *)storeName
           storeExtension:(NSString *)storeExtension;

- (NSURL *)persistenceStoreURL;
- (NSManagedObjectContext *)managedObjectContext;

@end
