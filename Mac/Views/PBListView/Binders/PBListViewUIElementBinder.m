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
             atRow:(NSInteger)row
         usingMeta:(PBListViewUIElementMeta *)meta {
}

- (id)buildUIElement {
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
    NSView *prevView = index > 0 ? views[index-1] : nil;
    PBListViewUIElementMeta *meta = metaList[index];

    if (meta.configurationHandler != nil) {
        meta.configurationHandler(view, meta);
    }

    if (meta.image != nil && [view respondsToSelector:@selector(setImage:)]) {
        [(NSButton *)view setImage:meta.image];
    }

    if (meta.alternateImage != nil && [view respondsToSelector:@selector(setAlternateImage:)]) {
        [(NSButton *)view setAlternateImage:meta.alternateImage];
    }

    if (meta.actionHandler != nil && [view respondsToSelector:@selector(setTarget:)]) {
        [(NSButton *)view setTarget:meta];
    }

    if (meta.actionHandler != nil && [view respondsToSelector:@selector(setAction:)]) {
        [(NSButton *)view setAction:@selector(invokeAction:)];
    }

    CGFloat leftMargin =
    [[PBListViewConfig sharedInstance] leftMargin];
    CGFloat rightMargin =
    [[PBListViewConfig sharedInstance] rightMargin];

    NSString *visualFormat;
    NSArray *hConstraints;

    CGFloat leftPadding = leftMargin;

    for (NSInteger i = 0; i < index; i++) {
        PBListViewUIElementMeta *prevMeta = metaList[i];
        leftPadding += prevMeta.size.width;
    }

    if (index == 0) {
        visualFormat =
        [NSString stringWithFormat:@"H:|-(%f)-[v]-(>=%f)-|", leftPadding, rightMargin];
    } if (index == (views.count - 1)) {
        visualFormat =
        [NSString stringWithFormat:@"H:|-(<=%f)-[v]-(%f)-|", leftPadding, rightMargin];
    } else {
        visualFormat =
        [NSString stringWithFormat:@"H:|-(<=%f)-[v]-(>=%f)-|", leftPadding, rightMargin];
    }

    hConstraints =
    [NSLayoutConstraint
     constraintsWithVisualFormat:visualFormat
     options:NSLayoutFormatAlignAllCenterX
     metrics:nil
     views:@{@"v" : view}];

    [view.superview addConstraints:hConstraints];

    if (prevView != nil) {

        NSLayoutConstraint *constraint =
        [NSLayoutConstraint
         constraintWithItem:view
         attribute:NSLayoutAttributeLeft
         relatedBy:NSLayoutRelationGreaterThanOrEqual
         toItem:prevView
         attribute:NSLayoutAttributeRight
         multiplier:1.0f
         constant:0.0f];

        [view.superview addConstraint:constraint];
    }

    if (index == 0) {
        [NSLayoutConstraint addWidthConstraint:meta.size.width toView:view];
    } else {
        [NSLayoutConstraint addMaxWidthConstraint:meta.size.width toView:view];
    }

    [NSLayoutConstraint addHeightConstraint:meta.size.height toView:view];

    [NSLayoutConstraint verticallyCenterView:view];
}

@end
