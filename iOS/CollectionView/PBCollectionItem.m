//
//  PBCollectionItem.m
//  PBFoundation
//
//  Created by Nick Bolton on 11/12/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBCollectionItem.h"
#import "PBCollectionViewController.h"

@implementation PBCollectionItem

+ (instancetype)
customNibItemWithUserContext:(id)userContext
reuseIdentifier:(NSString *)reuseIdentifier
cellNib:(UINib *)cellNib
configure:(void(^)(PBCollectionViewController *viewController, PBCollectionItem *item, id cell))configureBlock
binding:(void(^)(PBCollectionViewController *viewController, NSIndexPath *indexPath, PBCollectionItem *item, id cell))bindingBlock
selectAction:(void(^)(PBCollectionViewController *viewController))selectActionBlock
deleteAction:(void(^)(PBCollectionViewController *viewController))deleteActionBlock {

    PBCollectionItem *item =
    [[PBCollectionItem alloc] init];

    item.userContext = userContext;
    item.reuseIdentifier = reuseIdentifier;
    item.cellNib = cellNib;
    item.kind = kPBCollectionViewCellKind;
    item.deselectable = YES;
    item.configureBlock = configureBlock;
    item.bindingBlock = bindingBlock;
    item.selectActionBlock = selectActionBlock;
    item.deleteActionBlock = deleteActionBlock;
    item.useBackgroundImageSize = YES;

    item.point = CGPointZero;
    item.center = CGPointZero;
    item.size = CGSizeZero;
    item.transform3D = CATransform3DIdentity;
    item.transform = CGAffineTransformIdentity;
    item.alpha = 1.0f;
    item.zIndex = 0;
    item.hidden = NO;

    return item;
}

- (BOOL)isDeletable {
    return self.deleteActionBlock != nil;
}

- (void)setSelectAllItem:(BOOL)selectAllItem {
    _selectAllItem = selectAllItem;
    self.deselectable = NO;
}

@end
