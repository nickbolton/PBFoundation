//
//  NSAppleScript+PBFoundation.m
//  PBFoundation
//
//  Created by Nick Bolton on 1/16/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "NSAppleScript+PBFoundation.h"

@implementation NSAppleScript (PBFoundation)

+ (void)runScript:(NSString*)scriptText {
    NSDictionary *error = nil;
    NSAppleEventDescriptor *appleEventDescriptor;
    NSAppleScript *appleScript;
    appleScript = [[NSAppleScript alloc] initWithSource:scriptText];
    appleEventDescriptor = [appleScript executeAndReturnError:&error];
    if (error != nil) {
        NSLog(@"error: %@", error);
    }
}

+ (void)runScriptWithName:(NSString *)scriptFile {

    NSString *extension = [scriptFile pathExtension];
    NSString *scriptName = [scriptFile stringByDeletingPathExtension];

    NSString *scriptPath =
    [[NSBundle mainBundle]
     pathForResource:scriptName ofType:extension];

    if (scriptPath == nil) {
        NSLog(@"No script exists with name: %@", scriptFile);
        return;
    }
    
    NSError *error = nil;

    NSString *scriptText =
    [NSString
     stringWithContentsOfFile:scriptPath
     encoding:NSUTF8StringEncoding
     error:&error];

    if (error != nil) {
        NSLog(@"Failed loading script file: %@ - %@", scriptFile, scriptPath);
        return;
    }

    [self runScript:scriptText];
}

@end
