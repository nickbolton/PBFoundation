//
//  PBListViewUIElementBinder.h
//  PBListView
//
//  Created by Nick Bolton on 2/5/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PBListView;
@class PBListViewUIElementMeta;

@interface PBListViewUIElementBinder : NSObject

@property (nonatomic) CGFloat defaultPadding;

- (void)bindEntity:(id)entity
          withView:(NSView *)view
             atRow:(NSInteger)row
         usingMeta:(PBListViewUIElementMeta *)meta;

- (void)configureView:(PBListView *)listView
                 view:(NSView *)view
                 meta:(PBListViewUIElementMeta *)meta
        relativeViews:(NSMutableArray *)relativeViews
     relativeMetaList:(NSMutableArray *)relativeMetaList;

- (void)runtimeConfiguration:(PBListViewUIElementMeta *)meta
                        view:(NSView *)view;

- (id)buildUIElement:(PBListView *)listView;

@end
