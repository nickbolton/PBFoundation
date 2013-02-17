//
//  CDCManager.m
//  TestAppMac
//
//  Created by Nick Bolton on 2/17/13.
//  Copyright 2013 Pixelbleed. All rights reserved.
//

#import "CDCManager.h"
#import "UbiquityStoreManager.h"

@interface CDCManager() <UbiquityStoreManagerDelegate> {
}

@property (nonatomic, readwrite) UbiquityStoreManager *ubiquityStoreManager;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, readwrite) NSManagedObjectContext *managedObjectContext;

@end

@implementation CDCManager

- (id)init {
    self = [super init];
    if (self) {

        self.ubiquityStoreManager =
        [[UbiquityStoreManager alloc]
         initWithManagedObjectModel: [self managedObjectModel]
         localStoreURL: [self storeURL]
         containerIdentifier: nil
         additionalStoreOptions: nil];

        _ubiquityStoreManager.delegate = self;

        [self setupManagedObjectContext];

        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(mergeChanges:)
         name:RefreshAllViewsNotificationKey
         object:nil];
    }
    return self;
}

#pragma mark - Core Data

- (void)mergeChanges:(NSNotification *)notification {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (NSURL *)storeURL {
	return [[self applicationFilesDirectory] URLByAppendingPathComponent:@"CDCManager.sqlite"];
}

- (NSURL *)applicationFilesDirectory {

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    appSupportURL = [appSupportURL URLByAppendingPathComponent:@"CDCManager"];

    if ([fileManager fileExistsAtPath:[appSupportURL path]] == NO) {

        NSError *error = nil;
        [fileManager
         createDirectoryAtURL:appSupportURL
         withIntermediateDirectories:YES
         attributes:nil
         error:&error];

        if (error != nil) {
            NSLog(@"Failed create CDC data folder: %@", error);
        }
    }

    return appSupportURL;
}

- (void)setupManagedObjectContext {
    NSPersistentStoreCoordinator *coordinator = _ubiquityStoreManager.persistentStoreCoordinator;

    if (coordinator != nil) {
        NSManagedObjectContext* moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];

        [moc performBlockAndWait:^{
            [moc setPersistentStoreCoordinator: coordinator];
        }];

        _managedObjectContext = moc;
        _managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
    }
}

- (NSManagedObjectContext *)managedObjectContext {
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel) {
        return _managedObjectModel;
    }

    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"CDCManager" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (void)save {

    dispatch_async(_ubiquityStoreManager.persistentStorageQueue, ^{

        [_managedObjectContext performBlockAndWait:^{

            NSError *error = nil;

            if (![_managedObjectContext save:&error]) {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
#if DEBUG
                abort();
#endif
            }
        }];
    });
}

#pragma mark - UbiquityStoreManagerDelegate Conformance

// STEP 4 - Implement the UbiquityStoreManager delegate methods

- (NSManagedObjectContext *)managedObjectContextForUbiquityStoreManager:(UbiquityStoreManager *)usm {
	return self.managedObjectContext;
}

- (void)ubiquityStoreManager:(UbiquityStoreManager *)manager didSwitchToiCloud:(BOOL)didSwitch {
    NSLog(@"%s didSwitch: %d", __PRETTY_FUNCTION__, didSwitch);
}

- (void)ubiquityStoreManager:(UbiquityStoreManager *)manager didEncounterError:(NSError *)error cause:(UbiquityStoreManagerErrorCause)cause context:(id)context {
    NSLog(@"error: %@", [error localizedDescription]);
    NSArray *detailedErrors = [[error userInfo] objectForKey:NSDetailedErrorsKey];
    if (detailedErrors != nil && [detailedErrors count] > 0) {
        for (NSError *detailedError in detailedErrors) {
            NSLog(@"DetailedError: %@", [detailedError userInfo]);
        }
    } else {
        NSLog(@"%@", [error userInfo]);
    }
}

- (void)ubiquityStoreManager:(UbiquityStoreManager *)manager log:(NSString *)message {
	NSLog(@"UbiquityStoreManager: %@", message);
}


#pragma mark - Singleton Methods

static dispatch_once_t predicate_;
static CDCManager *sharedInstance_ = nil;

+ (id)sharedInstance {
    
    dispatch_once(&predicate_, ^{
        sharedInstance_ = [CDCManager alloc];
        sharedInstance_ = [sharedInstance_ init];
    });
    
    return sharedInstance_;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

@end
