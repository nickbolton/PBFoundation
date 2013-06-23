//
//  PBCrosshairView.m
//  PBFoundation
//
//  Created by Nick Bolton on 6/7/12.
//  Copyright (c) 2012 Pixelbleed LLC. All rights reserved.
//

#import "PBCrosshairView.h"

@implementation PBCrosshairView

- (void)drawRect:(NSRect)dirtyRect {
    
    NSGraphicsContext *currentContext = [NSGraphicsContext currentContext];
    [currentContext saveGraphicsState];
    
    [[NSColor colorWithDeviceRed:(16.0f / 255.0f) 
                           green:(16.0f / 255.0f) 
                            blue:(16.0f / 255.0f) 
                           alpha:1] set];

    NSInteger width = dirtyRect.size.width;
    NSInteger height = dirtyRect.size.height;

    NSBezierPath * verticalLinePath = [NSBezierPath bezierPath];
    [verticalLinePath setLineWidth:1];
    
    NSPoint startPoint = NSMakePoint(width / 2.0f, 0.0f);
    NSPoint endPoint = NSMakePoint(width / 2.0f, height);

    [verticalLinePath moveToPoint:startPoint];
    [verticalLinePath lineToPoint:endPoint];
    [verticalLinePath stroke];
    
    NSBezierPath * horizontalLinePath = [NSBezierPath bezierPath];
    [horizontalLinePath setLineWidth:1];
    
    startPoint = NSMakePoint(0.0f, height / 2.0f);
    endPoint = NSMakePoint(width, height / 2.0f);
    
    [horizontalLinePath moveToPoint:startPoint];
    [horizontalLinePath lineToPoint:endPoint];
    [horizontalLinePath stroke];
    
    [currentContext restoreGraphicsState];
}

@end
