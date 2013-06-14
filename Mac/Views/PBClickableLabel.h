//
//  PBClickableLabel.h
//  PBFoundation
//
//  Created by Nick Bolton on 1/11/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PBClickableLabel;

@protocol PBClickableLabelDelegate <NSTextFieldDelegate>

@optional
- (void)labelClicked:(PBClickableLabel *)label;
- (void)labelMouseUp:(PBClickableLabel *)label;
- (void)labelDoubleClicked:(PBClickableLabel *)label;

@end

@interface PBClickableLabel : NSTextField

@end
