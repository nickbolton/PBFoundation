//
//  PBListViewRowView.m
//  PBListView
//
//  Created by Nick Bolton on 2/9/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBListViewRowView.h"

@implementation PBListViewRowView

- (void)viewDidMoveToSuperview {
    [NSLayoutConstraint expandWidthToSuperview:self];
}

- (void)setFrame:(NSRect)frameRect {
    NSLog(@"%s - %@", __PRETTY_FUNCTION__, NSStringFromRect(frameRect));
    [super setFrame:frameRect];
}

@end
