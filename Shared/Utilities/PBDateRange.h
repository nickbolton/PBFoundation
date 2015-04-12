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

- (instancetype)initWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate;

- (BOOL)dateWithinRange:(NSDate *)date;

@end
