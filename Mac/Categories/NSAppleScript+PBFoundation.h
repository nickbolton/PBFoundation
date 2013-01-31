//
//  NSAppleScript+PBFoundation.h
//  PBFoundation
//
//  Created by Nick Bolton on 1/16/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSAppleScript (PBFoundation)

+ (void)runScript:(NSString *)scriptText;
+ (void)runScriptWithName:(NSString *)scriptName;

@end
