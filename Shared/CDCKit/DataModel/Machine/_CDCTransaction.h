// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CDCTransaction.h instead.

#import <CoreData/CoreData.h>


extern const struct CDCTransactionAttributes {
	__unsafe_unretained NSString *contents;
	__unsafe_unretained NSString *deviceId;
	__unsafe_unretained NSString *entityId;
} CDCTransactionAttributes;

extern const struct CDCTransactionRelationships {
} CDCTransactionRelationships;

extern const struct CDCTransactionFetchedProperties {
} CDCTransactionFetchedProperties;


@class NSObject;



@interface CDCTransactionID : NSManagedObjectID {}
@end

@interface _CDCTransaction : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (CDCTransactionID*)objectID;




@property (nonatomic, strong) id contents;


//- (BOOL)validateContents:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* deviceId;


//- (BOOL)validateDeviceId:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* entityId;


@property int32_t entityIdValue;
- (int32_t)entityIdValue;
- (void)setEntityIdValue:(int32_t)value_;

//- (BOOL)validateEntityId:(id*)value_ error:(NSError**)error_;






@end

@interface _CDCTransaction (CoreDataGeneratedAccessors)

@end

@interface _CDCTransaction (CoreDataGeneratedPrimitiveAccessors)


- (id)primitiveContents;
- (void)setPrimitiveContents:(id)value;




- (NSString*)primitiveDeviceId;
- (void)setPrimitiveDeviceId:(NSString*)value;




- (NSNumber*)primitiveEntityId;
- (void)setPrimitiveEntityId:(NSNumber*)value;

- (int32_t)primitiveEntityIdValue;
- (void)setPrimitiveEntityIdValue:(int32_t)value_;




@end
