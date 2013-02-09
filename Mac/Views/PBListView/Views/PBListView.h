//
//  PBListView.h
//  PBListView
//
//  Created by Nick Bolton on 2/4/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PBListViewConfig.h"
#import "PBListViewUIElementMeta.h"
#import "PBListViewUIElementBinder.h"
#import "PBListViewTextFieldBinder.h"
#import "PBListViewButtonBinder.h"

@class PBListViewUIElementMeta;

@interface PBListView : NSTableView

@property (nonatomic, strong) Class parentEntityType;
@property (nonatomic, strong) NSArray *staticEntities;

- (void)registerUIElementMeta:(PBListViewUIElementMeta *)meta;

- (void)visualizeConstraints;

@end
