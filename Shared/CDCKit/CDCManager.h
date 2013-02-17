//
//  CDCManager.h
//  TestAppMac
//
//  Created by Nick Bolton on 2/17/13.
//  Copyright 2013 Pixelbleed. All rights reserved.
//

@class UbiquityStoreManager;

@interface CDCManager : NSObject

+ (CDCManager *)sharedInstance;

@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readonly) UbiquityStoreManager *ubiquityStoreManager;

@end
