//
//  PBListViewCellView.m
//  PBListView
//
//  Created by Nick Bolton on 2/9/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBListViewCellView.h"

@implementation PBListViewCellView

- (void)viewDidMoveToSuperview {
    [NSLayoutConstraint expandWidthToSuperview:self];
}

@end
