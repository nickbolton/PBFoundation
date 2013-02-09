//
//  PBShadowTextFieldCell.h
//  PBFoundation
//
//  Created by Nick Bolton on 2/9/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBMiddleAlignedTextFieldCell.h"

@interface PBShadowTextFieldCell : PBMiddleAlignedTextFieldCell

@property (nonatomic, strong) NSColor *textShadowColor;
@property (nonatomic) NSSize textShadowOffset;

@end
