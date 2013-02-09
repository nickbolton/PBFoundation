//
//  NSAppleScript+PBFoundation.h
//  PBFoundation
//
//  Created by Nick Bolton on 1/16/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSAppleScript (PBFoundation)

+ (NSAppleEventDescriptor *)runScript:(NSString*)scriptText;
+ (NSAppleEventDescriptor *)runScript:(NSString*)scriptText error:(NSDictionary **)error;
+ (NSAppleEventDescriptor *)runScriptWithFile:(NSString *)scriptFile;
+ (NSAppleEventDescriptor *)runScriptWithFile:(NSString *)scriptFile
                            tokenReplacements:(NSDictionary *)tokenReplacements;
+ (NSString *)runScriptWithStringResult:(NSString *)scriptFile;
+ (NSNumber *)runScriptWithNumberResult:(NSString *)scriptFile;

@end
