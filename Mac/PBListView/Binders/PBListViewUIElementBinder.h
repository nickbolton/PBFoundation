//
//  PBListViewUIElementBinder.h
//  PBListView
//
//  Created by Nick Bolton on 2/5/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PBListViewEntity;
@class PBListView;
@class PBListViewUIElementMeta;

@interface PBListViewUIElementBinder : NSObject

@property (nonatomic) CGFloat defaultPadding;
@property (nonatomic, getter = isEditable) BOOL editable;

- (void)bindEntity:(id)entity
          withView:(NSView *)view
             atRow:(NSInteger)row
         usingMeta:(PBListViewUIElementMeta *)meta;

- (void)configureView:(PBListView *)listView
                 view:(NSView *)view
                 meta:(PBListViewUIElementMeta *)meta
        relativeViews:(NSMutableArray *)relativeViews
     relativeMetaList:(NSMutableArray *)relativeMetaList;

- (void)runtimeConfiguration:(PBListView *)listView
                        meta:(PBListViewUIElementMeta *)meta
                        view:(NSView *)view
                         row:(NSInteger)row;

- (id)buildUIElement:(PBListView *)listView;

@end
