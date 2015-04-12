//
//  PBResizableView.m
//  Prototype
//
//  Created by Nick Bolton on 6/22/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBResizableView.h"
#import "PBSpacerView.h"

@interface PBResizableView() {

    BOOL _rotating;
    BOOL _highlighted;
    BOOL _dropTarget;
}

@property (nonatomic, readwrite) NSTextField *infoLabel;
@property (nonatomic, readwrite) NSImageView *backgroundImageView;
@property (nonatomic, strong) NSColor *previousForegroundColor;
@property (nonatomic, strong) NSColor *previousBackgroundColor;
@property (nonatomic, readwrite) NSInteger tag;

//@property (nonatomic, strong) NSTrackingArea *trackingArea;

@end

@implementation PBResizableView

@synthesize tag = _tag;

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)setupInfoLabel {

    self.infoLabel = [[NSTextField alloc] initWithFrame:NSZeroRect];
    _infoLabel.bezeled = NO;
    _infoLabel.drawsBackground = NO;
//    _infoLabel.backgroundColor = [NSColor redColor];
    _infoLabel.editable = NO;
    _infoLabel.selectable = NO;
    _infoLabel.alphaValue = 0.0f;
    _infoLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _infoLabel.font = [NSFont fontWithName:@"HelveticaNeue" size:17.0f];

    [self addSubview:_infoLabel];

    [NSLayoutConstraint horizontallyCenterView:_infoLabel];
    [NSLayoutConstraint verticallyCenterView:_infoLabel padding:-3.0f];
}

- (void)commonInit {
    self.highlightColor = [NSColor colorWithRGBHex:0.0f alpha:.05f];
    self.dropTargetColor = [NSColor colorWithRGBHex:0.0f alpha:.4f];
    [self setupInfoLabel];
    [self registerForDraggedTypes:@[NSFilenamesPboardType, NSTIFFPboardType]];
}

#pragma mark - Getters and Setters

- (NSDictionary *)dataSource {

    NSMutableDictionary *dataSource = [NSMutableDictionary dictionary];

    NSRect frame = self.frame;
    frame.origin.x /= _drawingCanvas.scaleFactor;
    frame.origin.y /= _drawingCanvas.scaleFactor;
    frame.size.width /= _drawingCanvas.scaleFactor;
    frame.size.height /= _drawingCanvas.scaleFactor;

    frame = [_drawingCanvas roundedRect:frame];

    dataSource[@"frame"] = NSStringFromRect(frame);

    if (_topSpacerView != nil) {
        dataSource[@"topSpacer"] = _topSpacerView.dataSource;
    }

    if (_bottomSpacerView != nil) {
        dataSource[@"bottomSpacer"] = _bottomSpacerView.dataSource;
    }

    if (_leftSpacerView != nil) {
        dataSource[@"leftSpacer"] = _leftSpacerView.dataSource;
    }

    if (_rightSpacerView != nil) {
        dataSource[@"rightSpacer"] = _rightSpacerView.dataSource;
    }

    if (_backgroundColor != nil) {

        CGFloat red;
        CGFloat green;
        CGFloat blue;
        CGFloat alpha;

        [_backgroundColor getRGBComponents:&red green:&green blue:&blue alpha:&alpha];

        dataSource[@"bgColor"] =
        @{
          @"r" : @(red),
          @"g" : @(green),
          @"b" : @(blue),
          @"a" : @(alpha),
        };
    }

    if (_backgroundImage) {
        dataSource[@"backgroundImage"] = _backgroundImage;
    }

    return dataSource;
}

- (BOOL)isSelected {
    return [_drawingCanvas.selectedViews containsObject:self];
}

- (void)setBackgroundImage:(NSImage *)backgroundImage {
    _backgroundImage = backgroundImage;

    [_backgroundImageView removeFromSuperview];
    self.backgroundImageView = nil;

    if (backgroundImage != nil) {

        NSPoint center = NSMakePoint(NSMidX(self.frame), NSMidY(self.frame));

        NSRect frame = self.frame;

        frame.size = backgroundImage.size;
        frame.origin.x = center.x - (NSWidth(frame) / 2.0f);
        frame.origin.y = center.y - (NSHeight(frame) / 2.0f);

        self.previousBackgroundColor = _backgroundColor;
        self.backgroundColor = nil;

        self.backgroundImageView =
        [[NSImageView alloc] initWithFrame:self.bounds];

        _backgroundImageView.image = backgroundImage;
        _backgroundImageView.imageScaling = NSImageScaleAxesIndependently;
        _backgroundImageView.autoresizingMask =
        NSViewWidthSizable | NSViewHeightSizable;

        [self
         addSubview:_backgroundImageView
         positioned:NSWindowBelow
         relativeTo:nil];

        [self
         setViewFrame:frame
         withContainerFrame:self.superview.frame
         animate:NO];

        [_drawingCanvas updateMouseDownSelectedViewOrigin:self];

    } else {
        if (_previousBackgroundColor != nil) {
            self.backgroundColor = _previousBackgroundColor;
            self.previousBackgroundColor = nil;
            [self setNeedsDisplay:YES];
        }
    }

    [self updateInfo];
}

#pragma mark -


- (void)validateConstraints:(PBSpacerView *)spacerView {

    [spacerView setNeedsDisplay:YES];

    if (spacerView == _topSpacerView) {

    } else if (spacerView == _bottomSpacerView) {

    } else if (spacerView == _leftSpacerView) {

    } else if (spacerView == _rightSpacerView) {

    }
}

- (void)updateTopSpaceConstraint:(CGFloat)value {

    CGFloat distance = value - _topSpacerView.value;

    if (_bottomSpacerView.isConstraining) {

        if (distance > 0.0f) {
            if (NSHeight(self.frame) - distance < 0.0f) {
                distance += NSHeight(self.frame) - distance;
            }
        }

        NSRect frame = self.frame;
        frame.size.height -= distance;

        [_drawingCanvas
         resizeView:self
         toFrame:frame
         animate:NO];
        [_drawingCanvas updateGuidesForView:self];

    } else {

        _topSpacerView.value = value;

        [_drawingCanvas moveView:self offset:NSMakePoint(0.0f, -distance)];
    }

    [self updateInfo];
}

- (void)updateBottomSpaceConstraint:(CGFloat)value {

    CGFloat distance = value - _bottomSpacerView.value;

    if (_topSpacerView.isConstraining) {

        if (distance > 0.0f) {
            if (NSHeight(self.frame) - distance < 0.0f) {
                distance += NSHeight(self.frame) - distance;
            }
        }

        NSRect frame = self.frame;
        frame.size.height -= distance;
        frame.origin.y += distance;

        [_drawingCanvas
         resizeView:self
         toFrame:frame
         animate:NO];
        [_drawingCanvas updateGuidesForView:self];

    } else {

        _bottomSpacerView.value = value;
        [_drawingCanvas moveView:self offset:NSMakePoint(0.0f, distance)];
    }

    [self updateInfo];
}

- (void)updateLeftSpaceConstraint:(CGFloat)value {

    CGFloat distance = value - _leftSpacerView.value;

    if (_rightSpacerView.isConstraining) {

        if (distance > 0.0f) {
            if (NSWidth(self.frame) - distance < 0.0f) {
                distance += NSWidth(self.frame) - distance;
            }
        }

        NSRect frame = self.frame;
        frame.size.width -= distance;
        frame.origin.x += distance;

        [_drawingCanvas
         resizeView:self
         toFrame:frame
         animate:NO];
        [_drawingCanvas updateGuidesForView:self];

    } else {

        _leftSpacerView.value = value;
        [_drawingCanvas moveView:self offset:NSMakePoint(distance, 0.0f)];
    }

    [self updateInfo];
}

- (void)updateRightSpaceConstraint:(CGFloat)value {

    CGFloat distance = value - _rightSpacerView.value;

    if (_leftSpacerView.isConstraining) {

        if (distance > 0.0f) {
            if (NSWidth(self.frame) - distance < 0.0f) {
                distance += NSWidth(self.frame) - distance;
            }
        }

        NSRect frame = self.frame;
        frame.size.width -= distance;

        [_drawingCanvas
         resizeView:self
         toFrame:frame
         animate:NO];
        [_drawingCanvas updateGuidesForView:self];

    } else {

        _rightSpacerView.value = value;
        [_drawingCanvas moveView:self offset:NSMakePoint(-distance, 0.0f)];
    }

    [self updateInfo];
}

- (void)updateWidthConstraint:(CGFloat)value {

    NSRect frame = self.frame;

    if (_rightSpacerView.isConstraining) {

        frame.origin.x = NSMaxX(self.frame) - value;
        frame.size.width = value;

    } else {

        frame.size.width = value;
    }

    [_drawingCanvas
     resizeView:self
     toFrame:frame
     animate:NO];
    [_drawingCanvas updateGuidesForView:self];

    [self updateInfo];
}

- (void)updateHeightConstraint:(CGFloat)value {

    NSRect frame = self.frame;

    if (_topSpacerView.isConstraining) {

        frame.origin.y = NSMaxY(self.frame) - value;
        frame.size.height = value;

    } else {

        frame.size.height = value;
    }

    [_drawingCanvas
     resizeView:self
     toFrame:frame
     animate:NO];
    [_drawingCanvas updateGuidesForView:self];
    
    [self updateInfo];
}

- (void)willRotateWindow:(NSRect)newframe {

    _rotating = YES;
    
    NSRect oldFrame = self.frame;
    NSRect frame = self.frame;
    CGFloat containerHeight = NSHeight(newframe);

    if (_topSpacerView.isConstraining) {

        if (_bottomSpacerView.isConstraining) {

            CGFloat height =
            containerHeight - _topSpacerView.value - _bottomSpacerView.value;

            frame.origin.y =
            containerHeight - _topSpacerView.value - height;

            frame.size.height = height;

            if (NSMinY(frame) < 0.0f) {
                frame.origin.y = 0.0f;
                frame.size.height += NSMinY(frame);
                _bottomSpacerView.value += NSMinY(frame);
            }

            if (NSMaxY(frame) > containerHeight) {
                frame.size.height -= NSMaxY(frame) - containerHeight;
                _topSpacerView.value -= NSMaxY(frame) - containerHeight;
            }
            
        } else {
            
            frame.origin.y =
            containerHeight - _topSpacerView.value - NSHeight(frame);
        }

    } else if (_bottomSpacerView.isConstraining) {
        frame.origin.y = _bottomSpacerView.value;
    } else {
        
        // keep it at the top
        frame.origin.y =
        containerHeight - _topSpacerView.value - NSHeight(frame);
    }

    if (_rightSpacerView.isConstraining) {

        if (_leftSpacerView.isConstraining) {

            CGFloat width =
            NSWidth(newframe) - _leftSpacerView.value - _rightSpacerView.value;

            frame.origin.x = _leftSpacerView.value;

            frame.size.width = width;

            if (NSMinX(frame) < 0.0f) {
                frame.origin.x = 0.0f;
                frame.size.width += NSMinX(frame);
                _leftSpacerView.value += NSMinX(frame);
            }

            if (NSMaxX(frame) > NSWidth(newframe)) {
                frame.size.width -= NSMaxX(frame) - NSWidth(newframe);
                _rightSpacerView.value -= NSMaxX(frame) - NSWidth(newframe);
            }
            
        } else {

            frame.origin.x = 
            NSWidth(newframe) - _rightSpacerView.value - NSWidth(frame);
        }

    } else if (_leftSpacerView.isConstraining) {
        frame.origin.x = _leftSpacerView.value;
    } else {

        // keep it on the left
        frame.origin.x = _leftSpacerView.value;
    }

    [self
     setViewFrame:frame
     withContainerFrame:newframe
     animate:NO];

    _rotating = NO;
}

- (void)setupConstraints {

}

//- (void)startMouseTracking {
//    if (_trackingArea == nil) {
//
//        int opts = (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways | NSTrackingMouseMoved);
//        self.trackingArea =
//        [[NSTrackingArea alloc]
//         initWithRect:self.bounds
//         options:opts
//         owner:self
//         userInfo:nil];
//        [self addTrackingArea:_trackingArea];
//    }
//}

//- (void)setAlphaValue:(CGFloat)viewAlpha {
//
//    if (viewAlpha > 0.0f) {
//        [self startMouseTracking];
//    } else {
//        [self stopMouseTracking];
//    }
//}

//- (void)stopMouseTracking {
//    [self removeTrackingArea:_trackingArea];
//    self.trackingArea = nil;
//}
//
//- (void)mouseEntered:(NSEvent *)event {
//    self.showingInfo = YES;
//}
//
//- (void)mouseExited:(NSEvent *)event {
//    if (_updating == NO) {
//        self.showingInfo = NO;
//    }
//}
//
//- (void)mouseMoved:(NSEvent *)event {
//    if (_updating == NO && _showingInfo == NO) {
//        self.showingInfo = YES;
//    }
//}

- (void)setBackgroundColor:(NSColor *)backgroundColor {
    _backgroundColor = backgroundColor;
    [self updateInfo];
}

- (void)setShowingInfo:(BOOL)showingInfo {

    BOOL changed = _showingInfo != showingInfo;
    
    _showingInfo = showingInfo;

    if (changed) {
        [self updateInfo];
    }
}

- (void)updateInfo {

    if (_backgroundImage != nil) {
        _infoLabel.hidden = YES;
        _drawingCanvas.infoLabel.hidden = YES;
        return;
    }

    _infoLabel.hidden = NO;
    _drawingCanvas.infoLabel.hidden = NO;

    _infoLabel.textColor = [_backgroundColor contrastingColor];
    
    CGFloat windowScale = self.window != nil ? self.window.backingScaleFactor : 1.0f;

    _infoLabel.stringValue =
    [NSString stringWithFormat:@"(%.0f, %.0f)",
     NSWidth(self.frame) / _drawingCanvas.scaleFactor * windowScale,
     NSHeight(self.frame) / _drawingCanvas.scaleFactor * windowScale];

    [_infoLabel sizeToFit];
    [_drawingCanvas setInfoValue:_infoLabel.stringValue];

    _showingInfoLabel =
    NSWidth(self.frame) > NSWidth(_infoLabel.frame) &&
    NSHeight(self.frame) > NSHeight(_infoLabel.frame);

    CGFloat alpha = _showingInfo ? 1.0f : 0.0f;
    CGFloat infoAlpha = _showingInfo && _showingInfoLabel ? 1.0f : 0.0f;

    _infoLabel.alphaValue = infoAlpha;

    [_drawingCanvas updateInfoLabel:self];
}

- (void)updateSpacers {

    CGFloat alpha = _showingInfo ? 1.0f : 0.0f;

    [PBAnimator
     animateWithDuration:.3f
     timingFunction:PB_EASE_OUT
     animation:^{

         _topSpacerView.animator.alphaValue = alpha;

         if (_closestBottomView == nil) {
             _bottomSpacerView.animator.alphaValue = alpha;
         } else {
             _bottomSpacerView.animator.alphaValue = 0.0f;
         }

         _leftSpacerView.animator.alphaValue = alpha;

         if (_closestRightView == nil) {
             _rightSpacerView.animator.alphaValue = alpha;
         } else {
             _rightSpacerView.animator.alphaValue = 0.0f;
         }
     }];
}

- (CGFloat)roundedValue:(CGFloat)value {
    
    CGFloat scale = self.window != nil ? self.window.backingScaleFactor : 1.0f;
    return roundf(value * scale) / scale;
}

- (NSSize)roundedSize:(NSSize)size {
    return
    NSMakeSize([self roundedValue:size.width],
               [self roundedValue:size.height]);
}

- (NSPoint)roundedPoint:(NSPoint)point {
    return
    NSMakePoint([self roundedValue:point.x],
                [self roundedValue:point.y]);
}

- (NSRect)roundedRect:(NSRect)rect {
    NSRect roundedRect = NSZeroRect;
    roundedRect.origin = [self roundedPoint:rect.origin];
    roundedRect.size = [self roundedSize:rect.size];
    return roundedRect;
}

- (void)setFrame:(NSRect)frameRect {

//    NSLog(@"%s frame: %@", __PRETTY_FUNCTION__, NSStringFromRect(frameRect));
//    NSLog(@"%s constraints: %@", __PRETTY_FUNCTION__, self.constraints);
//    NSLog(@"%s super.constraints: %@", __PRETTY_FUNCTION__, self.superview.constraints);

    frameRect.origin = [self roundedPoint:frameRect.origin];
    frameRect.size = [self roundedSize:frameRect.size];

    BOOL changed = NSEqualRects(frameRect, self.frame);

    [super setFrame:frameRect];

    if (_rotating == NO && [self.delegate respondsToSelector:@selector(viewDidMove:)]) {
        [(id<PBResizableViewDelegate>)self.delegate viewDidMove:self];
    }

    [self updateInfo];
//    [self stopMouseTracking];
//    [self startMouseTracking];
}

//- (void)setFrameOrigin:(NSPoint)newOrigin {
//
//    newOrigin = [self roundedPoint:newOrigin];
//
//    BOOL changed = NSEqualPoints(newOrigin, self.frame.origin);
//
//    [super setFrameOrigin:newOrigin];
//
//    if ([self.delegate respondsToSelector:@selector(viewDidMove:)]) {
//        [(id<PBResizableViewDelegate>)self.delegate viewDidMove:self];
//    }
//
//    [self updateInfo];
//}
//
//- (void)setFrameSize:(NSSize)newSize {
//
//    newSize = [self roundedSize:newSize];
//
//    BOOL changed = NSEqualSizes(newSize, self.frame.size);
//
//    [super setFrameSize:newSize];
//
//    if ([self.delegate respondsToSelector:@selector(viewDidMove:)]) {
//        [(id<PBResizableViewDelegate>)self.delegate viewDidMove:self];
//    }
//
//    [self updateInfo];
//}

- (void)setViewFrame:(NSRect)frame
  withContainerFrame:(NSRect)containerFrame
             animate:(BOOL)animate {

//    NSLog(@"%s frame: %@", __PRETTY_FUNCTION__, NSStringFromRect(frame));
//    NSLog(@"%s containerFrame: %@", __PRETTY_FUNCTION__, NSStringFromRect(containerFrame));

    CGFloat topSpacer = 0.0f;
    CGFloat bottomSpacer = 0.0f;
    CGFloat leftSpacer = 0.0f;
    CGFloat rightSpacer = 0.0f;

    if (_rotating && _topSpacerView.isConstraining) {
        topSpacer = _topSpacerView.value;
    } else {

        if (_closestTopView != nil) {
            topSpacer = NSMinY(_closestTopView.frame) - NSMaxY(frame);
        } else {
            topSpacer = NSHeight(containerFrame) - NSMaxY(frame);
        }
    }

    if (_rotating && _bottomSpacerView.isConstraining) {
        bottomSpacer = _bottomSpacerView.value;
    } else {

        if (_closestBottomView != nil) {
            bottomSpacer = NSMinY(frame) - NSMaxY(_closestBottomView.frame);
        } else {
            bottomSpacer = NSMinY(frame);
        }
    }

    if (_rotating && _leftSpacerView.isConstraining) {
        leftSpacer = _leftSpacerView.value;
    } else {
        
        if (_closestLeftView != nil) {
            leftSpacer = NSMinX(frame) - NSMaxX(_closestLeftView.frame);
        } else {
            leftSpacer = NSMinX(frame);
        }
    }

    if (_rotating && _rightSpacerView.isConstraining) {
        rightSpacer = _rightSpacerView.value;
    } else {

        if (_closestRightView != nil) {
            rightSpacer = NSMinX(_closestRightView.frame) - NSMaxX(frame);
        } else {
            rightSpacer = NSWidth(containerFrame) - NSMaxX(frame);
        }
    }

    if (animate) {

        [NSAnimationContext beginGrouping];
        NSAnimationContext.currentContext.duration = .3f;
        NSAnimationContext.currentContext.completionHandler = ^{
        };

        [_topSpacerView
         updateValue:topSpacer
         forView:self
         andViewFrame:frame
         animate:YES];
        [_bottomSpacerView
         updateValue:bottomSpacer
         forView:self
         andViewFrame:frame
         animate:YES];
        [_leftSpacerView
         updateValue:leftSpacer
         forView:self
         andViewFrame:frame
         animate:YES];
        [_rightSpacerView
         updateValue:rightSpacer
         forView:self
         andViewFrame:frame
         animate:YES];

        self.animator.frame = frame;
        [NSAnimationContext endGrouping];

    } else {
        [_topSpacerView
         updateValue:topSpacer
         forView:self
         andViewFrame:frame
         animate:NO];
        [_bottomSpacerView
         updateValue:bottomSpacer
         forView:self
         andViewFrame:frame
         animate:NO];
        [_leftSpacerView
         updateValue:leftSpacer
         forView:self
         andViewFrame:frame
         animate:NO];
        [_rightSpacerView
         updateValue:rightSpacer
         forView:self
         andViewFrame:frame
         animate:NO];
        self.frame = frame;
    }
}

- (void)highlight {

    if (_highlighted == NO) {

        if (_dropTarget) {
            [self clearDropTarget];
        }

        _highlighted = YES;
        self.previousForegroundColor = _foregroundColor;
        self.foregroundColor = _highlightColor;
        [self setNeedsDisplay:YES];
    }
}

- (void)unhighlight {

    if (_highlighted) {
        _highlighted = NO;
        self.foregroundColor = self.previousForegroundColor;
        self.previousForegroundColor = nil;
        [self setNeedsDisplay:YES];
    }
}

- (void)setDropTarget {

    if (_dropTarget == NO) {

        if (_highlighted) {
            [self unhighlight];
        }

        _dropTarget = YES;
        self.previousForegroundColor = _foregroundColor;
        self.foregroundColor = _dropTargetColor;
        [self setNeedsDisplay:YES];
    }
}

- (void)clearDropTarget {

    if (_dropTarget) {
        _dropTarget = NO;
        self.foregroundColor = self.previousForegroundColor;
        self.previousForegroundColor = nil;
        [self setNeedsDisplay:YES];
    }
}

#pragma mark - First Responder

- (void)paste:(id)sender {

    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    NSArray *items = pasteboard.pasteboardItems;
    NSPasteboardItem *lastItem = items.lastObject;

    NSArray *imageTypesAry = @[@"public.tiff"];

    if ([[lastItem availableTypeFromArray:imageTypesAry] isEqualToString:@"public.tiff"]) {

        NSData *imageData = [lastItem dataForType:@"public.tiff"];
        self.backgroundImage = [[NSImage alloc] initWithData:imageData];
    }
}

#pragma mark - Drag n Drop

- (NSArray *)imageFilenamesForPasteboard:(id)sender {
    if ([sender respondsToSelector:@selector(draggingPasteboard)] == NO) return nil;

    NSPasteboard *pasteboard = [sender draggingPasteboard];
    NSArray *imageTypesAry = @[NSFilenamesPboardType];

    NSString *desiredType =
    [pasteboard availableTypeFromArray:imageTypesAry];

    if ([desiredType isEqualToString:NSFilenamesPboardType]) {

        NSArray *filenames =
        [pasteboard propertyListForType:@"NSFilenamesPboardType"];

        NSMutableArray *imageFilenames = [NSMutableArray array];

        for (NSString *filename in filenames) {

            NSString *ext = [[filename pathExtension] lowercaseString];

            if ([ext isEqualToString:@"png"]  ||
                [ext isEqualToString:@"tiff"] ||
                [ext isEqualToString:@"jpg"]) {
                [imageFilenames addObject:filename];
            }
        }
        
        return imageFilenames;
    }
    
    return nil;
}

- (NSDragOperation)draggingEntered:(id )sender {

    if ([sender respondsToSelector:@selector(draggingPasteboard)] == NO) {
        return NSDragOperationNone;
    }

    if ([self imageFilenamesForPasteboard:sender].count == 1) {

        if ((NSDragOperationGeneric & [sender draggingSourceOperationMask]) == NSDragOperationGeneric) {

            [self setDropTarget];
            return NSDragOperationCopy;
        }
        
    } else {

        NSPasteboard *pasteboard = [sender draggingPasteboard];
        NSArray *imageTypesAry = @[NSPasteboardTypeTIFF];

        NSString *desiredType =
        [pasteboard availableTypeFromArray:imageTypesAry];

        if ([desiredType isEqualToString:NSPasteboardTypeTIFF]) {

            [self setDropTarget];
            return NSDragOperationCopy;
        }
    }
    return NSDragOperationNone;
}

- (NSDragOperation)draggingUpdated:(id < NSDraggingInfo >)sender {
    return NSDragOperationGeneric;
}

- (void)draggingEnded:(id < NSDraggingInfo >)sender {
    [self clearDropTarget];
}

- (void)draggingExited:(id < NSDraggingInfo >)sender {
    [self clearDropTarget];
}

- (BOOL)prepareForDragOperation:(id )sender {
    return YES;
}

- (BOOL)performDragOperation:(id )sender {
    NSArray *filenames = [self imageFilenamesForPasteboard:sender];

    if (filenames.count == 1) {
        NSImage *image =
        [[NSImage alloc] initWithContentsOfFile:filenames[0]];

        self.backgroundImage = image;
        return YES;
    } else {

        NSPasteboard *pasteboard = [sender draggingPasteboard];

        NSArray *imageTypesAry = @[NSPasteboardTypeTIFF];

        NSString *desiredType =
        [pasteboard availableTypeFromArray:imageTypesAry];

        if ([desiredType isEqualToString:NSPasteboardTypeTIFF]) {

            NSData *imageData = [pasteboard dataForType:desiredType];
            self.backgroundImage = [[NSImage alloc] initWithData:imageData];
        }
    }
    return NO;
}

- (void)concludeDragOperation:(id )sender {
    [self clearDropTarget];
}

#pragma mark - Drawing

- (void)drawRect:(NSRect)dirtyRect {

    if (_backgroundColor != nil) {
        [_backgroundColor setFill];
        NSRectFillUsingOperation(dirtyRect, NSCompositeSourceOver);
    }

    if (_borderColor != nil && _borderWidth > 0) {

        NSBezierPath *borderPath =
        [NSBezierPath bezierPathWithRect:self.bounds];

        if (_borderDashPattern.count > 0) {
            CGFloat dashPattern[_borderDashPattern.count];

            NSInteger idx = 0;

            for (NSNumber *value in _borderDashPattern) {
                dashPattern[idx++] = value.floatValue;
            }

            [borderPath
             setLineDash:dashPattern
             count:_borderDashPattern.count
             phase:_borderDashPhase];
        }

        [_borderColor setStroke];

        [borderPath stroke];
    }

    [super drawRect:dirtyRect];

    if (_foregroundColor != nil) {
        [_foregroundColor setFill];
        NSRectFillUsingOperation(dirtyRect, NSCompositeSourceOver);
    }
}

@end
