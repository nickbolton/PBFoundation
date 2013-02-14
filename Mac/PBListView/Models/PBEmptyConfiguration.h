//
//  PBEmptyConfiguration.h
//  PBListView
//
//  Created by Nick Bolton on 2/11/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBListView.h"

@interface PBEmptyConfiguration : NSObject <PBListViewEntity>

@property (nonatomic, strong) NSString *title;
@property (nonatomic) NSUInteger depth;

+ (PBEmptyConfiguration *)emptyConfigurationWithTitle:(NSString *)title
                                                depth:(NSUInteger)depth;

- (NSUInteger)listViewEntityDepth;

@end
