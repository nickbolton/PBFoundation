//
//  PBListViewItem.m
//  Sometime
//
//  Created by Nick Bolton on 12/2/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBListViewItem.h"

CGFloat const kPBListRowHeight = 44.0f;
CGFloat const kPBListSpacerRowHeight = 32.0f;
CGFloat const kPBListActionRowHeight = 44.0f;

@implementation PBListViewItem

+ (instancetype)selectionItemWithTitle:(NSString *)title
                                 value:(NSString *)value
                              listType:(PBListType)listType
                         hasDisclosure:(BOOL)hasDisclosure
                          selectAction:(UIViewController *(^)(PBListViewController *viewController))selectActionBlock
                          deleteAction:(UIViewController *(^)(PBListViewController *viewController))deleteActionBlock {

    PBListViewItem *selectionItem =
    [[PBListViewItem alloc] init];

    selectionItem.title = title;
    selectionItem.value = value;
    selectionItem.rowHeight = -1.0f;
    selectionItem.listType = listType;
    selectionItem.hasDisclosure = hasDisclosure;
    selectionItem.selectActionBlock = selectActionBlock;
    selectionItem.deleteActionBlock = deleteActionBlock;
    selectionItem.selectionStyle = UITableViewCellSelectionStyleGray;
    selectionItem.titleAlignment = NSTextAlignmentLeft;

    return selectionItem;
}

- (BOOL)isDeletable {
    return self.deleteActionBlock != nil;
}

- (CGFloat)rowHeight {

    if (self.rowHeight > 0) {
        return self.rowHeight;
    }

    CGFloat rowHeight = kPBListRowHeight;

    switch (self.listType) {
        case PBListTypeAction:

            rowHeight = kPBListActionRowHeight;
            break;

            case PBListTypeSpacer:
            rowHeight = kPBListSpacerRowHeight;

        default:
            rowHeight = kPBListRowHeight;
            break;
    }

    return rowHeight;
}

@end
