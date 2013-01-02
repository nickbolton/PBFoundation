//
//  NSTask+PBFoundation.m
//  PBFoundation
//
//  Created by Nick Bolton on 12/19/12.
//  Copyright (c) 2012 Pixelbleed. All rights reserved.
//

#import "NSTask+PBFoundation.h"

@implementation NSTask (PBFoundation)

+ (NSString *)runTask:(NSString *)taskName withArguments:(NSArray *)arguments {

    NSTask *task;
    task = [[NSTask alloc] init];
    [task setLaunchPath:taskName];

    [task setArguments:arguments];

    NSPipe *pipe;
    pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];

    NSFileHandle *file;
    file = [pipe fileHandleForReading];

    [task launch];

    NSData *data;
    data = [file readDataToEndOfFile];

    NSString *string;
    string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    NSLog (@"task %@ returned: %@", task, string);

    return string;
}

@end
