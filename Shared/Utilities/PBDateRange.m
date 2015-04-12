//
//  PBDateRange.m
//  PBFoundation
//
//  Created by Nick Bolton on 3/24/12.
//  Copyright (c) 2012 Pixelbleed LLC. All rights reserved.
//

#import "PBDateRange.h"
#import "NSDate+PBFoundation.h"

@interface PBDateRange()

@property (nonatomic) NSUInteger hashValue;

@end

@implementation PBDateRange

+ (id)dateRangeWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate {    
    return
    [[PBDateRange alloc]
     initWithStartDate:startDate
     endDate:endDate];
}

- (id)initWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate {
    
    self = [super init];
    
    if (self != nil) {
        self.startDate = [startDate midnight];
        self.endDate = [endDate endOfDay];
        _hashValue = [self description].hash;
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    
    return [[PBDateRange alloc]
            initWithStartDate:self.startDate
            endDate:self.endDate];
}

- (NSUInteger)hash {
    return _hashValue;
}

- (BOOL)isEqual:(id)object {
    PBDateRange *that = object;
    
    if ([that isKindOfClass:[PBDateRange class]] == YES) {
        return [self.startDate isEqualToDate:that.startDate] && [self.endDate isEqualToDate:self.endDate];
    }
    return NO;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ - %@", _startDate, _endDate];
}

- (BOOL)dateWithinRange:(NSDate *)date {
    return
    [date isGreaterThanOrEqualTo:_startDate] &&
    [date isLessThanOrEqualTo:_endDate];
}

@end
