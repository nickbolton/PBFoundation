//
//  NSString+PBFoundation.m
//  PBFoundation
//
//  Created by Nick Bolton on 1/1/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "NSString+PBFoundation.h"
#import <sys/types.h>
#import <stdio.h>
#import <string.h>
#import <sys/socket.h>
#import <net/if_dl.h>
#import <ifaddrs.h>
#import <CommonCrypto/CommonDigest.h>

#if !defined(IFT_ETHER)
#define IFT_ETHER 0x6
#endif

NSString * const kPBFRemoteApplicationInstanceIdKey = @"!pbr-app-instance-id";

@implementation NSString (PBFoundation)

+ (NSString *)uuidString {
    // Returns a UUID

    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuidString = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
    CFRelease(uuid);

    return uuidString;
}

+ (NSString *)machineName {
#if TARGET_OS_IPHONE
    return [[UIDevice currentDevice] name];
#else
    return (__bridge NSString *)CSCopyMachineName();
#endif
}

+ (NSString *)safeString:(NSString *)value {
    if (value != nil) {
        return value;
    }
    return @"";
}

- (NSString *)trimmedValue {
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];

    return [self stringByTrimmingCharactersInSet:whitespace];
}

- (NSString *) md5Digest {
    const char *cStr = [self UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, strlen(cStr), result );
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

+ (NSString *)macAddress {

    char macAddress[18] = { 0 };
    struct ifaddrs* addrs;
    if (!getifaddrs(&addrs)) {
        for (struct ifaddrs* cursor = addrs; cursor; cursor = cursor->ifa_next) {
            if (cursor->ifa_addr->sa_family != AF_LINK) continue;
            if (strcmp("en0", cursor->ifa_name)) continue;
            const struct sockaddr_dl* dlAddr = (const struct sockaddr_dl*)cursor->ifa_addr;
            if (dlAddr->sdl_type != IFT_ETHER) continue;
            const unsigned char* base = (const unsigned char*)&dlAddr->sdl_data[dlAddr->sdl_nlen];
            for (int i = 0; i < dlAddr->sdl_alen; ++i) {
                if (i) {
                    strcat(macAddress, ":");
                }
                char partialAddr[3];
                sprintf(partialAddr, "%02X", base[i]);
                strcat(macAddress, partialAddr);

            }
        }
        freeifaddrs(addrs);
    }

    return [NSString stringWithUTF8String:macAddress];
}

+ (NSString *)timestampedGuid {

    NSString *macAddressWithTimestamp =
    [NSString stringWithFormat:@"%@-%f",
     [NSString macAddress],
     [NSDate timeIntervalSinceReferenceDate]];

    NSString *guid = [macAddressWithTimestamp md5Digest];

    return guid;
}

+ (NSString *)deviceIdentifier {
    return [[NSString macAddress] md5Digest];
}

+ (NSString *)applicationInstanceId {

    NSString *instanceId =
    [[NSUserDefaults standardUserDefaults]
     stringForKey:kPBFRemoteApplicationInstanceIdKey];

    if (instanceId == nil) {
        instanceId = [NSString timestampedGuid];
        [[NSUserDefaults standardUserDefaults]
         setObject:instanceId forKey:kPBFRemoteApplicationInstanceIdKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    return instanceId;
}

@end
