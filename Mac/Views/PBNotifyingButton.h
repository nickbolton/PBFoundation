//
//  PBNotifyingButton.h
//  PBFoundation
//
//  Created by Nick Bolton on 1/6/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PBNotifyingButton : NSButton

@property (nonatomic, assign) SEL mouseDownAction;
@property (nonatomic, assign) SEL mouseUpAction;
@property (nonatomic, assign) SEL mouseMovedAction;
@property (nonatomic, assign) SEL mouseEnteredAction;
@property (nonatomic, assign) SEL mouseExitedAction;

@end
