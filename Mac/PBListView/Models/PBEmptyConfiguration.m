//
//  PBEmptyConfiguration.m
//  PBListView
//
//  Created by Nick Bolton on 2/11/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBEmptyConfiguration.h"

@implementation PBEmptyConfiguration

+ (PBEmptyConfiguration *)emptyConfigurationWithTitle:(NSString *)title
                                                depth:(NSUInteger)depth {

    PBEmptyConfiguration *emptyConfiguration =
    [[PBEmptyConfiguration alloc] init];
    
    emptyConfiguration.title = title;
    emptyConfiguration.depth = depth;
    return emptyConfiguration;
}

- (NSUInteger)listViewEntityDepth {
    return _depth;
}

@end
