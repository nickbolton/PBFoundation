//
//  NSAppleScript+PBFoundation.m
//  PBFoundation
//
//  Created by Nick Bolton on 1/16/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "NSAppleScript+PBFoundation.h"

DescType const PBAppleScriptTextDescriptorType = 1970567284;
DescType const PBAppleScriptLongDescriptorType = 1819242087;

@implementation NSAppleScript (PBFoundation)

+ (NSAppleEventDescriptor *)runScript:(NSString*)scriptText {
    NSDictionary *error = nil;
    NSAppleEventDescriptor *appleEventDescriptor =
    [self runScript:scriptText error:&error];
    if (error != nil) {
        NSLog(@"error: %@", error);
    }
    return appleEventDescriptor;
}

+ (NSAppleEventDescriptor *)runScript:(NSString*)scriptText error:(NSDictionary **)error {
    NSAppleScript *appleScript = [[NSAppleScript alloc] initWithSource:scriptText];
    NSAppleEventDescriptor *appleEventDescriptor =
    [appleScript executeAndReturnError:error];
    return appleEventDescriptor;
}

+ (NSAppleEventDescriptor *)runScriptWithFile:(NSString *)scriptFile {

    NSString *extension = [scriptFile pathExtension];
    NSString *scriptName = [scriptFile stringByDeletingPathExtension];

    NSString *scriptPath =
    [[NSBundle mainBundle]
     pathForResource:scriptName ofType:extension];

    if (scriptPath == nil) {
        NSLog(@"No script exists with name: %@", scriptFile);
        return nil;
    }

    NSError *error = nil;

    NSString *scriptText =
    [NSString
     stringWithContentsOfFile:scriptPath
     encoding:NSUTF8StringEncoding
     error:&error];

    if (error != nil) {
        NSLog(@"Failed loading script file: %@ - %@", scriptFile, scriptPath);
        return nil;
    }

    return [self runScript:scriptText];
}

+ (NSAppleEventDescriptor *)runScriptWithFile:(NSString *)scriptFile
                            tokenReplacements:(NSDictionary *)tokenReplacements {

    NSString *extension = [scriptFile pathExtension];
    NSString *scriptName = [scriptFile stringByDeletingPathExtension];

    NSString *scriptPath =
    [[NSBundle mainBundle]
     pathForResource:scriptName ofType:extension];

    if (scriptPath == nil) {
        NSLog(@"No script exists with name: %@", scriptFile);
        return nil;
    }

    NSError *error = nil;

    NSString *scriptText =
    [NSString
     stringWithContentsOfFile:scriptPath
     encoding:NSUTF8StringEncoding
     error:&error];

    if (error != nil) {
        NSLog(@"Failed loading script file: %@ - %@", scriptFile, scriptPath);
        return nil;
    }

    for (NSString *token in tokenReplacements) {
        scriptText =
        [scriptText
         stringByReplacingOccurrencesOfString:token
         withString:[tokenReplacements objectForKey:token]];
    }

    return [self runScript:scriptText];

}

+ (NSString *)runScriptWithStringResult:(NSString *)scriptFile {
    NSAppleEventDescriptor *eventDescriptor =
    [self runScriptWithFile:scriptFile];

    NSString *message =
    [NSString stringWithFormat:
     @"Return descriptor type (%@) != PBAppleScriptTextDescriptorType",
     NSFileTypeForHFSTypeCode([eventDescriptor descriptorType])];

    NSAssert([eventDescriptor descriptorType] == PBAppleScriptTextDescriptorType,
             message);

    return eventDescriptor.stringValue;
}

+ (NSNumber *)runScriptWithNumberResult:(NSString *)scriptFile {
    NSAppleEventDescriptor *eventDescriptor =
    [self runScriptWithFile:scriptFile];

    NSString *message =
    [NSString stringWithFormat:
     @"Return descriptor type (%@) != PBAppleScriptLongDescriptorType",
     NSFileTypeForHFSTypeCode([eventDescriptor descriptorType])];

    NSAssert([eventDescriptor descriptorType] == PBAppleScriptLongDescriptorType,
             message);
    
    return @(eventDescriptor.int32Value);
}

@end
