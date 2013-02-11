//
//  PBListViewSwitchButtonBinder.m
//  PBListView
//
//  Created by Nick Bolton on 2/9/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBListViewSwitchButtonBinder.h"
#import "PBListViewUIElementMeta.h"

@implementation PBListViewSwitchButtonBinder

- (id)buildUIElement:(PBListView *)listView {
    NSButton *button = [super buildUIElement:listView];
    button.buttonType = NSSwitchButton;
    return button;
}

- (void)bindEntity:(id)entity
          withView:(NSButton *)button
             atRow:(NSInteger)row
         usingMeta:(PBListViewUIElementMeta *)meta {

    [super bindEntity:entity withView:button atRow:row usingMeta:meta];

    NSAssert([button isKindOfClass:[NSButton class]],
             @"view is not of type NSButton");

    NSAssert([meta isKindOfClass:[PBListViewUIElementMeta class]],
             @"meta is not of type PBListViewUIElementMeta");

    NSNumber *switchValue = @NO;

    if (meta.keyPath != nil) {
        id value = [entity valueForKeyPath:meta.keyPath];
        if (value != nil) {

            if (meta.valueTransformer != nil) {
                value = meta.valueTransformer(value);
            }

            NSAssert([value isKindOfClass:[NSNumber class]],
                     @"value of %@ at keyPath '%@' is not an NSNumber",
                     NSStringFromClass([entity class]), meta.keyPath);

            switchValue = value;
        }
    }
    
    button.state = switchValue.boolValue ? NSOnState : NSOffState;
}

@end
