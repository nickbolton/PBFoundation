//
//  PBApplication.h
//  PBListView
//
//  Created by Nick Bolton on 2/10/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PBApplication : NSApplication

@property (nonatomic, getter = isUserInteractionEnabled) BOOL userInteractionEnabled;

@end
