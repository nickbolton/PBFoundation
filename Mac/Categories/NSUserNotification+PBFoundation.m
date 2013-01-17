//
//  NSUserNotification+PBFoundation.m
//  PBFoundation
//
//  Created by Nick Bolton on 1/14/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "NSUserNotification+PBFoundation.h"

@implementation NSUserNotification (PBFoundation)

+ (void)postNotification:(NSString *)title
         informativeText:(NSString *)informativeText
                userInfo:(NSDictionary *)userInfo {
    NSUserNotification *notification = [[NSUserNotification alloc] init];

    notification.title = title;
    notification.informativeText = informativeText;
    notification.deliveryDate = [NSDate date];
    notification.soundName = NSUserNotificationDefaultSoundName;
    notification.userInfo = userInfo;

    [[NSUserNotificationCenter defaultUserNotificationCenter]
     deliverNotification:notification];
}

+ (void)postNotification:(NSString *)title
         informativeText:(NSString *)informativeText {
    [self postNotification:title informativeText:informativeText userInfo:nil];
}

@end
