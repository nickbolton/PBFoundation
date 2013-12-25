//
//  PBCollectionSupplimentaryImageItem.m
//  PBFoundation
//
//  Created by Nick Bolton on 11/12/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBCollectionSupplimentaryImageItem.h"
#import "PBCollectionViewController.h"

@interface PBCollectionSupplimentaryImageItem()

@end

@implementation PBCollectionSupplimentaryImageItem

+ (instancetype)supplimentaryImageItemWithImage:(UIImage *)image {

    PBCollectionSupplimentaryImageItem *item =
    [[PBCollectionSupplimentaryImageItem alloc] init];

    item.userContext = nil;
    item.reuseIdentifier = NSStringFromClass([self class]);
    item.kind = kPBCollectionViewSupplimentaryKind;
    item.point = CGPointZero;
    item.center = CGPointZero;
    item.size = CGSizeZero;
    item.transform3D = CATransform3DIdentity;
    item.transform = CGAffineTransformIdentity;
    item.alpha = 1.0f;
    item.zIndex = 0;
    item.hidden = NO;
    item.backgroundImage = image;

    return item;
}

@end
