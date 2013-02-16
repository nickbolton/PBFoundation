//
//  PBListViewRowMeta.h
//  PBListView
//
//  Created by Nick Bolton on 2/15/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PBMenu;
@class PBTableRowView;
@class PBListViewRowMeta;
@class PBListView;

typedef void(^PBRowConfigurationHandler)(PBTableRowView *rowview, PBListViewRowMeta *rowMeta);

@interface PBListViewRowMeta : NSObject

@property (nonatomic, weak) PBListView *listView;

@property (nonatomic) CGFloat rowHeight;
@property (nonatomic, strong) PBMenu *contextMenu;
@property (nonatomic, strong) NSIndexSet *contextMenuSeparatorPositions;
@property (nonatomic, strong) NSArray *commands;
@property (nonatomic, assign) PBRowConfigurationHandler configurationHandler;
@property (nonatomic) BOOL expandsOnClick;

+ (PBListViewRowMeta *)rowMeta;

@end
