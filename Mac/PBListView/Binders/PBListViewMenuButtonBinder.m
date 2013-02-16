//
//  PBListViewMenuButtonBinder.m
//  PBListView
//
//  Created by Nick Bolton on 2/10/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBListViewMenuButtonBinder.h"
#import "PBListViewUIElementMeta.h"
#import "PBMenu.h"
#import "PBButton.h"

@implementation PBListViewMenuButtonBinder

- (void)configureView:(PBListView *)listView
                 view:(PBButton *)button
                 meta:(PBListViewUIElementMeta *)meta
        relativeViews:(NSMutableArray *)relativeViews
     relativeMetaList:(NSMutableArray *)relativeMetaList {

    NSAssert([button isKindOfClass:[PBButton class]], @"view is not a PBButton");

    [super
     configureView:listView
     view:button
     meta:meta
     relativeViews:relativeViews
     relativeMetaList:relativeMetaList];

    if (meta.menu != nil) {
        meta.actionHandler = ^(NSButton *button, id entity, PBListViewUIElementMeta *meta, PBListView *listView) {

            NSWindow *window = button.window;
            NSEvent *event = window.currentEvent;

            NSPoint otherPoint =
            [[[[NSApp delegate] window] contentView]
             convertPoint:button.frame.origin
             fromView:button.superview];

            otherPoint.y -= 1;

            event = [NSEvent mouseEventWithType:event.type
                                       location:otherPoint
                                  modifierFlags:event.modifierFlags
                                      timestamp:event.timestamp
                                   windowNumber:event.windowNumber
                                        context:event.context
                                    eventNumber:event.eventNumber
                                     clickCount:event.clickCount
                                       pressure:event.pressure];

            meta.menu.attachedView = button;
            [NSMenu popUpContextMenu:meta.menu withEvent:event forView:button];
            
        };

        button.target = meta;
        button.action = @selector(invokeAction:);
    }

}

@end
