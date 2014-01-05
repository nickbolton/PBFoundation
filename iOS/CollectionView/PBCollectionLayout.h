//
//  PBCollectionLayout.h
//  PBFoundation
//
//  Created by Nick Bolton on 11/12/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PBCollectionViewController;

@interface PBCollectionLayout : UICollectionViewFlowLayout

@property (nonatomic, weak) PBCollectionViewController *viewController;

@property (nonatomic) CGSize minContentSize;

@end
