//
//  PBRunningAverageValue.m
//  Pods
//
//  Created by Nick Bolton on 6/11/13.
//
//

#import "PBRunningAverageValue.h"

static NSInteger const kPBSampleQueueSize = 10;

@interface PBRunningAverageValue() {
    CGFloat _avgValue;
    CGFloat _totalValue;
}

@property (nonatomic, strong) NSMutableArray *values;

@end

@implementation PBRunningAverageValue

@dynamic value;

- (NSMutableArray *)values {
    if (_values == nil) {
        self.values = [NSMutableArray array];
    }
    return _values;
}

- (CGFloat)value {
    return _avgValue;
}

- (void)setValue:(CGFloat)value {

    // keep a running average

    if (self.values.count == kPBSampleQueueSize) {

        CGFloat firstValue = [self.values[0] floatValue];

        _totalValue -= firstValue;

        [self.values removeObjectAtIndex:0];
    }

    [self.values addObject:@(value)];

    _totalValue += value;

    _avgValue = _totalValue / self.values.count;
}

- (void)clearRunningValues {
    [self.values removeAllObjects];
    _avgValue = 0.0f;
    _totalValue = 0.0f;
}

@end
