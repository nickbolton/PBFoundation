//
//  PBCollectionDefaultCell.h
//  PBFoundation
//
//  Created by Nick Bolton on 11/12/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PBCollectionItem;
@class PBCollectionViewController;

@interface PBCollectionDefaultCell : UICollectionViewCell

@property (nonatomic, readonly) IBOutlet UIImageView *backgroundImageView;

@property (nonatomic, strong) PBCollectionItem *item;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, weak) PBCollectionViewController *viewController;
@property (nonatomic) BOOL cellConfigured;

- (void)updateForSelectedState;

@end
