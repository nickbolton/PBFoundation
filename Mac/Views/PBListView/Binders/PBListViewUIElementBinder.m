//
//  PBListViewUIElementBinder.m
//  PBListView
//
//  Created by Nick Bolton on 2/5/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBListViewUIElementBinder.h"
#import "PBListViewUIElementMeta.h"
#import "PBListView.h"
#import "PBListViewConfig.h"

@implementation PBListViewUIElementBinder

- (id)init {
    self = [super init];

    if (self != nil) {
        _defaultPadding = 10.0f;
    }

    return self;
}

- (void)bindEntity:(id)entity
          withView:(NSView *)view
         usingMeta:(PBListViewUIElementMeta *)meta {
}

- (id)buildUIElementWithMeta:(PBListViewUIElementMeta *)meta {
    return nil;
}

- (void)configureView:(PBListView *)listView
                views:(NSArray *)views
             metaList:(NSArray *)metaList
              atIndex:(NSInteger)index {

    NSAssert(index < views.count,
             @"index out of views range %ld >= %ld", index, views.count);
    NSAssert(index < metaList.count,
             @"index out of metaList range %ld >= %ld", index, metaList.count);
    NSAssert(views.count == metaList.count,
             @"views count not equal to metaList count %ld >= %ld", views.count, metaList.count);

    NSView *view = views[index];
    PBListViewUIElementMeta *meta = metaList[index];

    CGFloat leftMargin =
    [[PBListViewConfig sharedInstance] leftMargin];
    CGFloat rightMargin =
    [[PBListViewConfig sharedInstance] rightMargin];

    NSString *visualFormat;
    NSArray *hConstraints;

    if (meta.configurationHandler != nil) {
        meta.configurationHandler(view, meta);
    }

    CGFloat leftPadding = leftMargin;

    for (NSInteger i = 0; i < index; i++) {
        PBListViewUIElementMeta *prevMeta = metaList[i];
        leftPadding += prevMeta.size.width;
    }

    visualFormat =
    [NSString stringWithFormat:@"H:|-(%f)-[v]-(>=%f)-|", leftPadding, rightMargin];

    hConstraints =
    [NSLayoutConstraint
     constraintsWithVisualFormat:visualFormat
     options:NSLayoutFormatAlignAllCenterX
     metrics:nil
     views:@{@"v" : view}];

    [view.superview addConstraints:hConstraints];

//    [NSLayoutConstraint addWidthConstraint:meta.width toView:view];

    [NSLayoutConstraint addHeightConstraint:meta.size.height toView:view];

    [NSLayoutConstraint verticallyCenterView:view];
}

@end
