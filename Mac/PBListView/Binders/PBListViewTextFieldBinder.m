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

NSString * const kEntityKey = @"entity";
NSString * const kKeyPathKey = @"key-path";

@interface PBListViewTextFieldBinder() <NSTextFieldDelegate>
@end

@implementation PBListViewTextFieldBinder

- (id)buildUIElement:(PBListView *)listView {
    NSTextField *textField = [[NSTextField alloc] initWithFrame:NSZeroRect];
    PBShadowTextFieldCell *cell = [[PBShadowTextFieldCell alloc] init];
    cell.yoffset = -2.0f;
    textField.cell = cell;

    textField.delegate = self;
    textField.alignment = NSLeftTextAlignment;
    textField.bezeled = self.isEditable;
    textField.editable = self.isEditable;
    textField.selectable = self.isEditable;
    textField.drawsBackground = NO;
//    [textField DEBUG_colorizeSelfAndSubviews];
    ((NSTextFieldCell *)textField.cell).lineBreakMode = NSLineBreakByTruncatingTail;

    return textField;
}

- (void)runtimeConfiguration:(PBListView *)listView
                        meta:(PBListViewUIElementMeta *)meta
                        view:(NSTextField *)textField
                         row:(NSInteger)row {

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

    textField.delegate = nil;
    PBShadowTextFieldCell *cell = textField.cell;
    cell.representedObject = nil;

    if (meta.staticText != nil) {
        textField.stringValue = meta.staticText;
    } else {

        NSString *text = @"";
        if (meta.keyPath != nil) {

            cell.representedObject =
            @{
              kEntityKey : entity,
              kKeyPathKey : meta.keyPath,
              };

            if (self.isEditable) {
                textField.delegate = self;
            }

            id value = [entity valueForKeyPath:meta.keyPath];
            if (value != nil) {

                if (meta.valueTransformer != nil) {
                    value = meta.valueTransformer(value, meta);
                }

                NSAssert([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSAttributedString class]],
                         @"value of %@ at keyPath '%@' is not an NSString",
                         NSStringFromClass([entity class]), meta.keyPath);

                text = value;
            }
        }

        if ([text isKindOfClass:[NSAttributedString class]]) {
            textField.attributedStringValue = (id)text;
        } else {
            textField.stringValue = text;
        }
    }
}

- (void)controlTextDidChange:(NSNotification *)notification {
    NSLog(@"%s - %@", __PRETTY_FUNCTION__, notification);

    NSTextField *textField = notification.object;
    PBShadowTextFieldCell *cell = textField.cell;
    NSDictionary *representedObject = cell.representedObject;
    id entity =
    [representedObject objectForKey:kEntityKey];
    NSString *keyPath = [representedObject objectForKey:kKeyPathKey];

    [entity setValue:textField.stringValue forKeyPath:keyPath];

}

@end
