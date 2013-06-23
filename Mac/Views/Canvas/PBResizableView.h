//
//  PBResizableView.h
//  Prototype
//
//  Created by Nick Bolton on 6/22/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBAcceptsFirstView.h"

@class PBResizableView;

@interface PBResizableView : PBAcceptsFirstView

@property (nonatomic, strong) NSColor *backgroundColor;
@property (nonatomic, strong) NSColor *borderColor;
@property (nonatomic, strong) NSArray *borderDashPattern;
@property (nonatomic) NSInteger borderDashPhase;
@property (nonatomic) NSInteger borderWidth;
@property (nonatomic) NSInteger tag;

@end
