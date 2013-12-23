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

+ (instancetype)spacerItemWithHeight:(CGFloat)height {

    PBListViewItem *item =
    [self
     selectionItemWithTitle:nil
     value:nil
     itemType:PBItemTypeSpacer
     hasDisclosure:NO
     selectAction:nil
     deleteAction:nil];

    item.backgroundColor = [UIColor clearColor];
    item.rowHeight = height;
    item.selectionStyle = UITableViewCellSelectionStyleNone;

    return item;
}

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
    selectionItem.deselectable = YES;
    selectionItem.titleMargin = 20.0f;
    selectionItem.valueMargin = 20.0f;
    selectionItem.hasDisclosure = hasDisclosure;
    selectionItem.selectActionBlock = selectActionBlock;
    selectionItem.deleteActionBlock = deleteActionBlock;
    selectionItem.selectionStyle = itemType == PBItemTypeChecked ? UITableViewCellSelectionStyleNone : UITableViewCellSelectionStyleGray;
    selectionItem.titleAlignment = NSTextAlignmentLeft;

    return selectionItem;
}

+ (instancetype)selectAllItemWithTitle:(NSString *)title
                          selectAction:(void(^)(PBListViewController *viewController))selectActionBlock
                          deleteAction:(void(^)(PBListViewController *viewController))deleteActionBlock {

    PBListViewItem *selectionItem =
    [[PBListViewItem alloc] init];

    selectionItem.title = title;
    selectionItem.value = nil;
    selectionItem.rowHeight = -1.0f;
    selectionItem.itemType = PBItemTypeSelectAll;
    selectionItem.deselectable = NO;
    selectionItem.titleMargin = 20.0f;
    selectionItem.valueMargin = 20.0f;
    selectionItem.hasDisclosure = NO;
    selectionItem.selectActionBlock = selectActionBlock;
    selectionItem.deleteActionBlock = deleteActionBlock;
    selectionItem.selectionStyle = UITableViewCellSelectionStyleNone;
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
    selectionItem.deselectable = YES;
    selectionItem.titleMargin = 20.0f;
    selectionItem.valueMargin = 20.0f;
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
    selectionItem.deselectable = YES;
    selectionItem.titleMargin = 20.0f;
    selectionItem.valueMargin = 20.0f;
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
