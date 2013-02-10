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
                views:(NSArray *)views
             metaList:(NSArray *)metaList
              atIndex:(NSInteger)index;

- (id)buildUIElement;

@end
