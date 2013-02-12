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

@implementation PBListViewMenuButtonBinder

- (void)configureView:(PBListView *)listView
                views:(NSArray *)views
             metaList:(NSArray *)metaList
              atIndex:(NSInteger)index {

    [super configureView:listView views:views metaList:metaList atIndex:index];

    NSButton *button = views[index];
    PBListViewUIElementMeta *meta = metaList[index];

    if (meta.menu != nil) {
        meta.actionHandler = ^(NSButton *button, id entity, PBListViewUIElementMeta *meta) {

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
