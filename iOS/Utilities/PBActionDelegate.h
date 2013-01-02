//
//  PBActionDelegate.h
//  PBFoundation
//
//  Created by Nick Bolton on 11/26/12.
//  Copyright (c) 2012 Pixelbleed LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PBActionDelegate : NSObject <UIActionSheetDelegate>

- (void)addTarget:(id)target
           action:(SEL)action
      userContext:(id)userContext
         toButton:(NSInteger)buttonIndex;

@end
