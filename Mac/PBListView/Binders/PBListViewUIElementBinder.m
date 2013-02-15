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

- (id)buildUIElement:(PBListView *)listView {
    return nil;
}

- (void)postClientConfiguration:(PBListView *)listView
                           meta:(PBListViewUIElementMeta *)meta
                           view:(NSView *)view {
}

- (void)configureView:(PBListView *)listView
                 view:(NSView *)view
                 meta:(PBListViewUIElementMeta *)meta
        relativeViews:(NSMutableArray *)relativeViews
     relativeMetaList:(NSMutableArray *)relativeMetaList {

    NSView *prevView = relativeViews.lastObject;

    if (meta.configurationHandler != nil && meta.hasBeenUserConfigured == NO) {
        meta.configurationHandler(view, meta);
        meta.hasBeenUserConfigured = YES;
    }

    [self postClientConfiguration:listView meta:meta view:view];

    if (meta.actionHandler != nil && [view respondsToSelector:@selector(setTarget:)]) {
        [(NSButton *)view setTarget:meta];
    }

    if (meta.actionHandler != nil && [view respondsToSelector:@selector(setAction:)]) {
        [(NSButton *)view setAction:@selector(invokeAction:)];
    }

    if (meta.anchorPosition != PBListViewAnchorPositionNone) {

        [self
         layoutAnchoredElement:view
         meta:meta
         listViewConfig:listView.listViewConfig];
        
    } else {


        CGFloat leftMargin = meta.ignoreMargins ? 0.0f : [listView.listViewConfig leftMargin];
        CGFloat rightMargin = meta.ignoreMargins ? 0.0f : [listView.listViewConfig rightMargin];

        NSString *visualFormat;
        NSArray *hConstraints;

        CGFloat fixedPosition = leftMargin + meta.leftPadding;

        if (meta.fixedPosition) {
            for (PBListViewUIElementMeta *prevMeta in relativeMetaList) {
                fixedPosition += prevMeta.size.width;
            }
        }

        if (relativeViews.count == 0) {
            visualFormat =
            [NSString stringWithFormat:@"H:|-(%f)-[v]-(>=%f)-|", leftMargin, rightMargin];
        } else {
            if (meta.fixedPosition) {
                visualFormat =
                [NSString stringWithFormat:@"H:|-(%f)-[v]-(>=%f)-|", fixedPosition, rightMargin];
            } else {
                visualFormat =
                [NSString stringWithFormat:@"H:[v]-(>=%f)-|", rightMargin];

                NSLayoutConstraint *constraint =
                [NSLayoutConstraint
                 constraintWithItem:view
                 attribute:NSLayoutAttributeLeft
                 relatedBy:NSLayoutRelationEqual
                 toItem:prevView
                 attribute:NSLayoutAttributeRight
                 multiplier:1.0f
                 constant:meta.leftPadding];

                [view.superview addConstraint:constraint];

            }
        }

        hConstraints =
        [NSLayoutConstraint
         constraintsWithVisualFormat:visualFormat
         options:NSLayoutFormatAlignAllCenterX
         metrics:nil
         views:@{@"v" : view}];

        [view.superview addConstraints:hConstraints];

        if (relativeViews.count == 0) {
            [NSLayoutConstraint
             addWidthConstraint:MIN(meta.size.width, NSWidth(view.superview.frame)-leftMargin-rightMargin)
             toView:view];
        } else {
            [NSLayoutConstraint addMaxWidthConstraint:meta.size.width toView:view];
        }
        
        [NSLayoutConstraint addHeightConstraint:meta.size.height toView:view];
        
        [NSLayoutConstraint verticallyCenterView:view];
        
        [relativeViews addObject:view];
        [relativeMetaList addObject:meta];
    }
}

- (void)layoutAnchoredElement:(NSView *)view
                         meta:(PBListViewUIElementMeta *)meta
               listViewConfig:(PBListViewConfig *)listViewConfig {

    CGFloat leftMargin = meta.ignoreMargins ? 0.0f : [listViewConfig leftMargin];
    CGFloat rightMargin = meta.ignoreMargins ? 0.0f : [listViewConfig rightMargin];

    [NSLayoutConstraint addWidthConstraint:meta.size.width toView:view];
    [NSLayoutConstraint addHeightConstraint:meta.size.height toView:view];

    switch (meta.anchorPosition) {

        case PBListViewAnchorPositionCenter:

            [NSLayoutConstraint horizontallyCenterView:view];
            [NSLayoutConstraint verticallyCenterView:view];

#if DEBUG
            if (meta.anchorInsets.top + meta.anchorInsets.bottom + meta.anchorInsets.left + meta.anchorInsets.right > 0) {
                NSLog(@"Warming: anchorInsets will be ignored for CENTER anchor position");
            }
#endif
            break;
            
        case PBListViewAnchorPositionTop:

            [NSLayoutConstraint horizontallyCenterView:view];
            [NSLayoutConstraint alignToTop:view withPadding:meta.anchorInsets.top];

#if DEBUG
            if (meta.anchorInsets.bottom + meta.anchorInsets.left + meta.anchorInsets.right > 0) {
                NSLog(@"Warming: anchorInsets other than top will be ignored for TOP anchor position");
            }
#endif
            break;
            
        case PBListViewAnchorPositionBottom:

            [NSLayoutConstraint horizontallyCenterView:view];
            [NSLayoutConstraint alignToBottom:view withPadding:-meta.anchorInsets.bottom];

#if DEBUG
            if (meta.anchorInsets.top + meta.anchorInsets.left + meta.anchorInsets.right > 0) {
                NSLog(@"Warming: anchorInsets other than bottom will be ignored for BOTTOM anchor position");
            }
#endif
            break;
            
        case PBListViewAnchorPositionLeft:

            [NSLayoutConstraint verticallyCenterView:view];
            [NSLayoutConstraint alignToLeft:view withPadding:meta.anchorInsets.left + leftMargin];

#if DEBUG
            if (meta.anchorInsets.top + meta.anchorInsets.bottom + meta.anchorInsets.right > 0) {
                NSLog(@"Warming: anchorInsets other than left will be ignored for LEFT anchor position");
            }
#endif
            break;
            
        case PBListViewAnchorPositionRight:

            [NSLayoutConstraint verticallyCenterView:view];
            [NSLayoutConstraint alignToRight:view withPadding:-meta.anchorInsets.right - rightMargin];

#if DEBUG
            if (meta.anchorInsets.top + meta.anchorInsets.bottom + meta.anchorInsets.left > 0) {
                NSLog(@"Warming: anchorInsets other than right will be ignored for RIGHT anchor position");
            }
#endif
            break;
            
        case PBListViewAnchorPositionTopLeft:

            [NSLayoutConstraint alignToTop:view withPadding:meta.anchorInsets.top];
            [NSLayoutConstraint alignToLeft:view withPadding:meta.anchorInsets.left + leftMargin];

#if DEBUG
            if (meta.anchorInsets.top + meta.anchorInsets.bottom + meta.anchorInsets.right > 0) {
                NSLog(@"Warming: anchorInsets other than left will be ignored for TOPLEFT anchor position");
            }
#endif
            break;
            
        case PBListViewAnchorPositionTopRight:

            [NSLayoutConstraint alignToTop:view withPadding:meta.anchorInsets.top];
            [NSLayoutConstraint alignToRight:view withPadding:-meta.anchorInsets.right - rightMargin];

#if DEBUG
            if (meta.anchorInsets.top + meta.anchorInsets.bottom + meta.anchorInsets.left > 0) {
                NSLog(@"Warming: anchorInsets other than right will be ignored for TOPRIGHT anchor position");
            }
#endif
            break;
            
        case PBListViewAnchorPositionBottomLeft:

            [NSLayoutConstraint alignToBottom:view withPadding:-meta.anchorInsets.bottom];
            [NSLayoutConstraint alignToLeft:view withPadding:meta.anchorInsets.left + leftMargin];

#if DEBUG
            if (meta.anchorInsets.top + meta.anchorInsets.bottom + meta.anchorInsets.right > 0) {
                NSLog(@"Warming: anchorInsets other than left will be ignored for BOTTOMLEFT anchor position");
            }
#endif
            break;
            
        case PBListViewAnchorPositionBottomRight:

            [NSLayoutConstraint alignToBottom:view withPadding:-meta.anchorInsets.bottom];
            [NSLayoutConstraint alignToRight:view withPadding:-meta.anchorInsets.right - rightMargin];

#if DEBUG
            if (meta.anchorInsets.top + meta.anchorInsets.bottom + meta.anchorInsets.left > 0) {
                NSLog(@"Warming: anchorInsets other than right will be ignored for BOTTOMRIGHT anchor position");
            }
#endif
            break;

        case PBListViewAnchorPositionNone:
            // never get here
            break;
    }

}

@end
