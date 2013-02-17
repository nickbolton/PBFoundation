// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CDCTransaction.m instead.

#import "_CDCTransaction.h"

const struct CDCTransactionAttributes CDCTransactionAttributes = {
	.contents = @"contents",
	.deviceId = @"deviceId",
	.entityId = @"entityId",
};

const struct CDCTransactionRelationships CDCTransactionRelationships = {
};

const struct CDCTransactionFetchedProperties CDCTransactionFetchedProperties = {
};

@implementation CDCTransactionID
@end

@implementation _CDCTransaction

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"CDCTransaction" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"CDCTransaction";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"CDCTransaction" inManagedObjectContext:moc_];
}

- (CDCTransactionID*)objectID {
	return (CDCTransactionID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"entityIdValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"entityId"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}




@dynamic contents;






@dynamic deviceId;






@dynamic entityId;



- (int32_t)entityIdValue {
	NSNumber *result = [self entityId];
	return [result intValue];
}

- (void)setEntityIdValue:(int32_t)value_ {
	[self setEntityId:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveEntityIdValue {
	NSNumber *result = [self primitiveEntityId];
	return [result intValue];
}

- (void)setPrimitiveEntityIdValue:(int32_t)value_ {
	[self setPrimitiveEntityId:[NSNumber numberWithInt:value_]];
}










@end
