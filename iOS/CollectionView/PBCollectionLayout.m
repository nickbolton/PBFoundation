//
//  PBCollectionLayout.m
//  PBFoundation
//
//  Created by Nick Bolton on 11/12/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBCollectionLayout.h"
#import "PBCollectionItem.h"
#import "PBCollectionViewController.h"

@interface PBCollectionLayout()

@property (nonatomic, strong) NSDictionary *layoutInfo;

@end

@implementation PBCollectionLayout

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {

    CGRect screenBounds = [[UIScreen mainScreen] bounds];

    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];

    if (UIDeviceOrientationIsLandscape(orientation)) {
        self.minContentSize = CGSizeMake(CGRectGetHeight(screenBounds), CGRectGetWidth(screenBounds));
    } else {
        self.minContentSize = CGSizeMake(CGRectGetWidth(screenBounds), CGRectGetHeight(screenBounds));
    }
}

#pragma mark - Getters and Setters

#pragma mark -

- (void)configureAttributes:(UICollectionViewLayoutAttributes *)itemAttributes
                   withItem:(PBCollectionItem *)item
                atIndexPath:(NSIndexPath *)indexPath {

    if (item.useCenter) {

        itemAttributes.size = item.size;
        itemAttributes.center = item.center;

    } else {
        itemAttributes.frame = [self frameForItem:item];
    }

    itemAttributes.transform3D = item.transform3D;
    itemAttributes.transform = item.transform;
    itemAttributes.alpha = item.alpha;
    itemAttributes.zIndex = item.zIndex;
    itemAttributes.hidden = item.isHidden;
}

- (void)prepareLayout {

    NSMutableDictionary *newLayoutInfo = [NSMutableDictionary dictionary];
    NSMutableDictionary *cellLayoutInfo = [NSMutableDictionary dictionary];
    NSMutableDictionary *supplimentaryLayoutInfo = [NSMutableDictionary dictionary];
    NSMutableDictionary *decorationLayoutInfo = [NSMutableDictionary dictionary];

    NSInteger sectionCount = [self.collectionView numberOfSections];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];

    for (NSInteger section = 0; section < sectionCount; section++) {
        NSInteger itemCount = [self.collectionView numberOfItemsInSection:section];

        for (NSInteger item = 0; item < itemCount; item++) {
            indexPath = [NSIndexPath indexPathForItem:item inSection:section];

            UICollectionViewLayoutAttributes *itemAttributes =
            [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];

            PBCollectionItem *item = [self.viewController itemAtIndexPath:indexPath];

            [self
             configureAttributes:itemAttributes
             withItem:item
             atIndexPath:indexPath];

            cellLayoutInfo[indexPath] = itemAttributes;

            if (item.supplimentaryItem != nil) {

                UICollectionViewLayoutAttributes *itemAttributes =
                [UICollectionViewLayoutAttributes
                 layoutAttributesForSupplementaryViewOfKind:item.supplimentaryItem.kind
                 withIndexPath:indexPath];

                [self
                 configureAttributes:itemAttributes
                 withItem:item.supplimentaryItem
                 atIndexPath:indexPath];

                 supplimentaryLayoutInfo[indexPath] = itemAttributes;
            }

            if (item.decorationItem != nil) {

                UICollectionViewLayoutAttributes *itemAttributes =
                [UICollectionViewLayoutAttributes
                 layoutAttributesForDecorationViewOfKind:item.decorationItem.kind
                 withIndexPath:indexPath];

                [self
                 configureAttributes:itemAttributes
                 withItem:item.decorationItem
                 atIndexPath:indexPath];

                decorationLayoutInfo[indexPath] = itemAttributes;
            }
        }
    }

    newLayoutInfo[kPBCollectionViewCellKind] = cellLayoutInfo;
    newLayoutInfo[kPBCollectionViewSupplimentaryKind] = supplimentaryLayoutInfo;
    newLayoutInfo[kPBCollectionViewDecorationKind] = decorationLayoutInfo;

    PBLog(@"layoutInfo: %@", newLayoutInfo);

    self.layoutInfo = newLayoutInfo;
}

- (CGRect)frameForItemAtIndexPath:(NSIndexPath *)indexPath {

    PBCollectionItem *item =
    [self.viewController itemAtIndexPath:indexPath];

    return [self frameForItem:item];
}

- (CGRect)frameForItem:(PBCollectionItem *)item {

    CGRect frame;
    frame.origin = item.point;
    frame.size = item.size;

    return frame;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {

    NSMutableArray *allAttributes = [NSMutableArray arrayWithCapacity:self.layoutInfo.count];

    [self.layoutInfo enumerateKeysAndObjectsUsingBlock:^(NSString *elementIdentifier,
                                                         NSDictionary *elementsInfo,
                                                         BOOL *stop) {
        [elementsInfo enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *indexPath,
                                                          UICollectionViewLayoutAttributes *attributes,
                                                          BOOL *innerStop) {
            if (CGRectIntersectsRect(rect, attributes.frame)) {
                [allAttributes addObject:attributes];
            }
        }];
    }];

    PBLog(@"atributes for rect %@: %@", NSStringFromCGRect(rect), allAttributes);

    return allAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.layoutInfo[kPBCollectionViewDecorationKind][indexPath];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind
                                                                     atIndexPath:(NSIndexPath *)indexPath {
    return self.layoutInfo[kind][indexPath];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)decorationViewKind
                                                                  atIndexPath:(NSIndexPath *)indexPath {
    return self.layoutInfo[decorationViewKind][indexPath];
}

- (CGPoint)maxPointOfItem:(PBCollectionItem *)item {

    CGFloat x;
    CGFloat y;

    if (item.useCenter) {

        x = item.center.x + (item.size.width / 2.0f);
        y = item.center.y + (item.size.height / 2.0f);

    } else {

        x = item.point.x + item.size.width;
        y = item.point.y + item.size.height;
    }

    x += item.contentSizeOffset.width;
    y += item.contentSizeOffset.height;

    if (item.supplimentaryItem != nil) {

        // resursion

        CGPoint p = [self maxPointOfItem:item.supplimentaryItem];

        x = MAX(x, p.x);
        y = MAX(y, p.y);
    }

    if (item.decorationItem != nil) {

        // resursion

        CGPoint p = [self maxPointOfItem:item.decorationItem];

        x = MAX(x, p.x);
        y = MAX(y, p.y);
    }

    return CGPointMake(x, y);
}

- (CGSize)collectionViewContentSize {

    NSArray *dataSource = self.viewController.dataSource;

    CGFloat bottomMostPosition = 0.0f;
    CGFloat rightMostPosition = 0.0f;

    BOOL sizeSet = NO;

    if (self.viewController.isSectioned) {

        for (NSArray *section in dataSource) {

            for (PBCollectionItem *item in section) {

                sizeSet = YES;

                CGPoint p = [self maxPointOfItem:item];

                rightMostPosition = MAX(rightMostPosition, p.x);
                bottomMostPosition = MAX(bottomMostPosition, p.y);
            }
        }

    } else {

        for (PBCollectionItem *item in dataSource) {

            sizeSet = YES;

            CGPoint p = [self maxPointOfItem:item];

            rightMostPosition = MAX(rightMostPosition, p.x);
            bottomMostPosition = MAX(bottomMostPosition, p.y);
        }
    }

    CGFloat width = self.minContentSize.width;
    CGFloat height = self.minContentSize.height;

    if (sizeSet) {
        width = MAX(width, rightMostPosition);
        height = MAX(height, bottomMostPosition);
    } else {
        PBLog(@"No items in datasource!");
    }

    NSLog(@"content size: %@", NSStringFromCGSize(CGSizeMake(width, height)));

    return CGSizeMake(width, height);
}

@end
