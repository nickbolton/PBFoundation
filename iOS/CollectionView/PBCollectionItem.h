//
//  PBCollectionItem.h
//  PBFoundation
//
//  Created by Nick Bolton on 11/12/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PBCollectionViewController;

@interface PBCollectionItem : NSObject

@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, strong) UIImage *backgroundImage;
@property (nonatomic, strong) UIImage *selectedBackgroundImage;
@property (nonatomic, strong) UIImage *hightlightedBackgroundImage;
@property (nonatomic, strong) UIImage *highlightedSelectedBackgroundImage;
@property (nonatomic) NSString *reuseIdentifier;
@property (nonatomic) UINib *cellNib;
@property (nonatomic,  strong) NSString *kind;
@property (nonatomic) id userContext;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic) UICollectionViewScrollPosition scrollPosition;
@property (nonatomic, getter = isSelected) BOOL selected;
@property (nonatomic) BOOL selectionDisabled;
@property (nonatomic) BOOL itemConfigured;
@property (nonatomic) BOOL selectAllItem;
@property (nonatomic) BOOL useCenter;
@property (nonatomic) BOOL useBackgroundImageSize;
@property (nonatomic) CGSize contentSizeOffset;
@property (nonatomic, strong) PBCollectionItem *supplimentaryItem;
@property (nonatomic, strong) PBCollectionItem *decorationItem;
@property (nonatomic, getter = isDeselectable) BOOL deselectable;
@property (nonatomic, copy) void(^selectActionBlock)(id sender);
@property (nonatomic, copy) void(^deleteActionBlock)(id sender);
@property (nonatomic, copy) void(^configureBlock)(id sender, PBCollectionItem *item, id cell);
@property (nonatomic, copy) void(^bindingBlock)(id sender, NSIndexPath *indexPath, PBCollectionItem *item, id cell);

// properties passed directly to UICollectionViewLayoutAttributes

@property (nonatomic) CGPoint point;
@property (nonatomic) CGPoint center;
@property (nonatomic) CGSize size;
@property (nonatomic) CATransform3D transform3D;
@property (nonatomic) CGAffineTransform transform;
@property (nonatomic) CGFloat alpha;
@property (nonatomic) NSInteger zIndex;
@property (nonatomic, getter=isHidden) BOOL hidden;

+ (instancetype)
customNibItemWithUserContext:(id)userContext
reuseIdentifier:(NSString *)reuseIdentifier
cellNib:(UINib *)cellNib
configure:(void(^)(PBCollectionViewController *viewController, PBCollectionItem *item, id cell))configureBlock
binding:(void(^)(PBCollectionViewController *viewController, NSIndexPath *indexPath, PBCollectionItem *item, id cell))bindingBlock
selectAction:(void(^)(PBCollectionViewController *viewController))selectActionBlock
deleteAction:(void(^)(PBCollectionViewController *viewController))deleteActionBlock;

@end
