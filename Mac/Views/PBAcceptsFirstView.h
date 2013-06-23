//
//  PBAcceptsFirstView.h
//
//  Created by Nick Bolton on 12/22/11.
//  Copyright (c) 2011 Pixelbleed LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol PBAcceptsFirstViewDelegate <NSObject>

- (void)handleKeyEvent:(NSEvent *)event;

@end

@interface PBAcceptsFirstView : NSView

@property (nonatomic, weak) IBOutlet id <PBAcceptsFirstViewDelegate> delegate;

@end
