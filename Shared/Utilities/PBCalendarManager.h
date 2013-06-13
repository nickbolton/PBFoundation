//
//  PBCalendarManager.h
//  PBFoundation
//
//  Created by Nick Bolton on 3/14/12.
//  Copyright 2012 Pixelbleed LLC. All rights reserved.
//

@interface PBCalendarManager : NSObject

+ (PBCalendarManager *) sharedInstance;

- (NSCalendar *)calendarForCurrentThread;

@end
