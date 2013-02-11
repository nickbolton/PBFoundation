//
//  PBListViewTextFieldBinder.m
//  PBListView
//
//  Created by Nick Bolton on 2/5/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBListView.h"
#import "PBListViewTextFieldBinder.h"
#import "PBShadowTextFieldCell.h"
#import "PBListViewUIElementMeta.h"
#import "PBListViewConfig.h"

@implementation PBListViewTextFieldBinder

- (id)buildUIElement:(PBListView *)listView {
    NSTextField *textField = [[NSTextField alloc] initWithFrame:NSZeroRect];
    PBShadowTextFieldCell *cell = [[PBShadowTextFieldCell alloc] init];
    cell.yoffset = -2.0f;
    textField.cell = cell;

    textField.alignment = NSLeftTextAlignment;
    textField.bezeled = NO;
    textField.editable = NO;
    textField.selectable = NO;
    textField.drawsBackground = NO;
//    [textField DEBUG_colorizeSelfAndSubviews];
    ((NSTextFieldCell *)textField.cell).lineBreakMode = NSLineBreakByTruncatingTail;

    return textField;
}

- (void)postClientConfiguration:(PBListView *)listView
                           meta:(PBListViewUIElementMeta *)meta
                           view:(NSTextField *)textField
                          index:(NSInteger)index {
    NSAssert([textField isKindOfClass:[NSTextField class]], @"view is not a NSTextField");

    PBShadowTextFieldCell *cell = textField.cell;

    textField.font = meta.textFont;
    textField.textColor = meta.textColor;
    cell.textShadowColor = meta.textShadowColor;
    cell.textShadowOffset = meta.shadowOffset;
}


- (void)bindEntity:(id)entity
          withView:(NSTextField *)textField
             atRow:(NSInteger)row
         usingMeta:(PBListViewUIElementMeta *)meta {

    [super bindEntity:entity withView:textField atRow:row usingMeta:meta];

    NSAssert([textField isKindOfClass:[NSTextField class]],
             @"view is not of type NSTextField");

    NSAssert([meta isKindOfClass:[PBListViewUIElementMeta class]],
             @"meta is not of type PBListViewUIElementMeta");

    NSString *text = @"";
    if (meta.keyPath != nil) {
        id value = [entity valueForKeyPath:meta.keyPath];
        if (value != nil) {

            if (meta.valueTransformer != nil) {
                value = meta.valueTransformer(value);
            }

            NSAssert([value isKindOfClass:[NSString class]],
                     @"value of %@ at keyPath '%@' is not an NSString",
                     NSStringFromClass([entity class]), meta.keyPath);
            
            text = value;
        }
    }

    textField.stringValue = text;
}

@end
