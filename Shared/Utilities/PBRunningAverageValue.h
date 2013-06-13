//
//  PBRunningAverageValue.h
//  Pods
//
//  Created by Nick Bolton on 6/11/13.
//
//

#import <Foundation/Foundation.h>

@interface PBRunningAverageValue : NSObject

@property (nonatomic) CGFloat value;
@property (nonatomic) NSUInteger queueSize;

- (void)clearRunningValues;

@end
