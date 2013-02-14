//
//  PBListViewCommand.h
//  PBListView
//
//  Created by Nick Bolton on 2/11/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^PBCommandActionHandler)(NSArray *entities);

@interface PBListViewCommand : NSObject

@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSUInteger keyCode;
@property (nonatomic, readonly) NSString *keyEquivalent;
@property (nonatomic, readonly) NSUInteger modifierMask;
@property (nonatomic, readonly) PBCommandActionHandler actionHandler;
@property (nonatomic) BOOL hasMultipleTargets;

+ (PBListViewCommand *)commandWithTitle:(NSString *)title
                                keyCode:(NSUInteger)keyCode
                           modifierMask:(NSUInteger)modifierMask
                          actionHandler:(PBCommandActionHandler)PBCommandActionHandler;

@end
