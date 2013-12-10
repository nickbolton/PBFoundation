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
                              itemType:(PBItemType)itemType
                         hasDisclosure:(BOOL)hasDisclosure
                          selectAction:(void(^)(PBListViewController *viewController))selectActionBlock
                          deleteAction:(void(^)(PBListViewController *viewController))deleteActionBlock {

    PBListViewItem *selectionItem =
    [[PBListViewItem alloc] init];

    selectionItem.title = title;
    selectionItem.value = value;
    selectionItem.rowHeight = -1.0f;
    selectionItem.itemType = itemType;
    selectionItem.hasDisclosure = hasDisclosure;
    selectionItem.selectActionBlock = selectActionBlock;
    selectionItem.deleteActionBlock = deleteActionBlock;
    selectionItem.selectionStyle = UITableViewCellSelectionStyleGray;
    selectionItem.titleAlignment = NSTextAlignmentLeft;

    return selectionItem;
}

+ (instancetype)customNibItemWithUserContext:(id)userContext
                                      cellID:(NSString *)cellID
                                     cellNib:(UINib *)cellNib
                                   configure:(void(^)(PBListViewController *viewController, PBListViewItem *item, id cell))configureBlock
                                     binding:(void(^)(PBListViewController *viewController, NSIndexPath *indexPath, PBListViewItem *item, id cell))bindingBlock
                                selectAction:(void(^)(PBListViewController *viewController))selectActionBlock
                                deleteAction:(void(^)(PBListViewController *viewController))deleteActionBlock {

    PBListViewItem *selectionItem =
    [[PBListViewItem alloc] init];

    selectionItem.rowHeight = -1.0f;
    selectionItem.itemType = PBItemTypeCustom;
    selectionItem.userContext = userContext;
    selectionItem.cellID = cellID;
    selectionItem.cellNib = cellNib;
    selectionItem.configureBlock = configureBlock;
    selectionItem.bindingBlock = bindingBlock;
    selectionItem.selectActionBlock = selectActionBlock;
    selectionItem.deleteActionBlock = deleteActionBlock;
    selectionItem.selectionStyle = UITableViewCellSelectionStyleNone;

    return selectionItem;
}

+ (instancetype)customClassItemWithUserContext:(id)userContext
                                        cellID:(NSString *)cellID
                                     cellClass:(Class)cellClass
                                     configure:(void(^)(PBListViewController *viewController, PBListViewItem *item, id cell))configureBlock
                                       binding:(void(^)(PBListViewController *viewController, NSIndexPath *indexPath, PBListViewItem *item, id cell))bindingBlock
                                  selectAction:(void(^)(PBListViewController *viewController))selectActionBlock
                                  deleteAction:(void(^)(PBListViewController *viewController))deleteActionBlock {

    PBListViewItem *selectionItem =
    [[PBListViewItem alloc] init];

    selectionItem.rowHeight = -1.0f;
    selectionItem.itemType = PBItemTypeCustom;
    selectionItem.userContext = userContext;
    selectionItem.cellID = cellID;
    selectionItem.cellClass = cellClass;
    selectionItem.configureBlock = configureBlock;
    selectionItem.bindingBlock = bindingBlock;
    selectionItem.selectActionBlock = selectActionBlock;
    selectionItem.deleteActionBlock = deleteActionBlock;
    selectionItem.selectionStyle = UITableViewCellSelectionStyleNone;

    return selectionItem;
}

- (BOOL)isDeletable {
    return self.deleteActionBlock != nil;
}

- (CGFloat)rowHeight {

    if (_rowHeight > 0) {
        return _rowHeight;
    }

    CGFloat rowHeight = kPBListRowHeight;

    switch (self.itemType) {
        case PBItemTypeAction:

            rowHeight = kPBListActionRowHeight;
            break;

            case PBItemTypeSpacer:
            rowHeight = kPBListSpacerRowHeight;

        default:
            rowHeight = kPBListRowHeight;
            break;
    }

    return rowHeight;
}

@end
