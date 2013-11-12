//
//  PBDateRange.h
//  PBFoundation
//
//  Created by Nick Bolton on 3/24/12.
//  Copyright (c) 2012 Pixelbleed LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PBDateRange : NSObject <NSCopying>

@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;

+ (instancetype)dateRangeWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate;

+ (instancetype)dateRangeWithStartDate:(NSDate *)startDate
                               endDate:(NSDate *)endDate
                  alignToDayBoundaries:(BOOL)alignToDayBoundaries;

- (id)initWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate;
- (id)initWithStartDate:(NSDate *)startDate
                endDate:(NSDate *)endDate
   alignToDayBoundaries:(BOOL)alignToDayBoundaries;

- (BOOL)dateWithinRange:(NSDate *)date;
- (void)adjustDateRangeToDate:(NSDate *)date;

@end
