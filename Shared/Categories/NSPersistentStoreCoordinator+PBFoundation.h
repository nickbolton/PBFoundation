//
//  NSPersistentStoreCoordinator+PBFoundation.h
//  timecop
//
//  Created by Nick Bolton on 3/9/13.
//  Copyright (c) 2013 Pixelbleed LLC. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSPersistentStoreCoordinator (PBFoundation)

+ (void)PBF_setupCoreDataStackWithAutoMigratingSqliteStoreNamed:(NSString *)storeFileName
                                                      modelName:(NSString *)modelName;

@end
