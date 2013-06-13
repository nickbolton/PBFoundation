//
//  PBCalendarManager.m
//  PBFoundation
//
//  Created by Nick Bolton on 3/14/12.
//  Copyright 2012 Pixelbleed LLC. All rights reserved.
//

#import "PBCalendarManager.h"

@interface PBCalendarManager()

@end

@implementation PBCalendarManager

- (id)init {
    
    self = [super init];
    
    if (self != nil) {
    }
    
    return self;
}


- (NSCalendar *)calendarForCurrentThread {

    static NSString * const threadDictionaryKey = @"NSDateAGCategoryGregorianCalendar";

    NSMutableDictionary *threadDictionary = [[NSThread currentThread] threadDictionary];

	NSCalendar *gregorianCalendar = [threadDictionary objectForKey:threadDictionaryKey];
    if (gregorianCalendar == nil) {
		gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
		[threadDictionary setObject:gregorianCalendar forKey:threadDictionaryKey];
	}
    return gregorianCalendar;
}

#pragma mark - Singleton Methods

static dispatch_once_t predicate_;
static PBCalendarManager *sharedInstance_ = nil;

+ (id)sharedInstance {
    
    dispatch_once(&predicate_, ^{
        sharedInstance_ = [PBCalendarManager alloc];
        sharedInstance_ = [sharedInstance_ init];
    });
    
    return sharedInstance_;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

@end
