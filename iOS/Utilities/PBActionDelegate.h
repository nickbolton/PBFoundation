//
//  TCCalendarActionDelegate.h
//  Timecop-iOS
//
//  Created by Nick Bolton on 11/26/12.
//  Copyright (c) 2012 Pixelbleed LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCCalendarActionDelegate : NSObject <UIActionSheetDelegate>

- (void)addTarget:(id)target action:(SEL)action toButton:(NSInteger)buttonIndex;

@end
