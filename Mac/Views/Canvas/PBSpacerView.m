//
//  PBSpacerView.m
//  Pods
//
//  Created by Nick Bolton on 6/26/13.
//
//

#import "PBSpacerView.h"
#import "PBGuideView.h"
#import "PBDrawingCanvas.h"
#import "PBResizableView.h"

@interface PBSpacerView() {

    BOOL _vertical;
    BOOL _hidden;
}

@end

@implementation PBSpacerView

- (NSDictionary *)dataSource {

    NSMutableDictionary *dataSource = [NSMutableDictionary dictionary];
    dataSource[@"vertical"] = @(_vertical);
    dataSource[@"hidden"] = @(_hidden);
    dataSource[@"alpha"] = @(self.alphaValue);
    dataSource[@"value"] = @(roundf(_value / _scale));
    dataSource[@"constraining"] = @(_constraining);

    return dataSource;
}

- (void)updateFromDataSource:(NSDictionary *)dataSource {

    _vertical = [dataSource[@"vertical"] boolValue];
    _hidden = [dataSource[@"hidden"] boolValue];
    self.alphaValue = [dataSource[@"alpha"] floatValue];
    _value = [dataSource[@"value"] floatValue];
    _constraining = [dataSource[@"constraining"] boolValue];
}

- (void)commonInit:(CGFloat)value {
    self.value = value;
    self.constrainingSpacerColor = [NSColor redColor];
    self.spacerColor = [NSColor greenColor];
}

- (PBGuideView *)buildGuideView:(NSRect)frame {
    PBGuideView *view = [[PBGuideView alloc] initWithFrame:frame];
    view.vertical = _vertical;
    return view;
}

- (void)setValue:(CGFloat)value {
    _value = value;

    if (value == -246.0f) {
        NSLog(@"ZZZ");
    }
}

- (PBSpacerView *)overlappingSpacerView {

    if (_vertical) {

        if (_view1.topSpacerView == self) {
            return _view2.bottomSpacerView;
        } else if (_view2.bottomSpacerView == self) {
            return _view1.topSpacerView;
        }

    } else {

        if (_view1.rightSpacerView == self) {
            return _view2.leftSpacerView;
        } else if (_view2.leftSpacerView == self) {
            return _view1.rightSpacerView;
        }
    }

    return nil;
}

- (void)updateValue:(CGFloat)value
            forView:(PBResizableView *)view
       andViewFrame:(NSRect)viewFrame
            animate:(BOOL)animate {

    self.value = roundf(value);

    if (_vertical) {
        [self
         updateHeightForView:view
         andViewFrame:viewFrame
         animate:animate];
    } else {
        [self
         updateWidthForView:view
         andViewFrame:viewFrame
         animate:animate];
    }
}

#pragma mark - Horizontal

- (id)initWithLeftView:(PBGuideView *)leftView
             rightView:(PBGuideView *)rightView
                 value:(CGFloat)value {

    NSRect frame = NSMakeRect(0.0f, 0.0f, value, 5.0f);

    self = [super initWithFrame:frame];

    if (self != nil) {
        self.view1 = leftView;
        self.view2 = rightView;
        [self commonInit:value];
        [self initializeHorizontal];
    }

    return self;
}

- (void)updateWidthForView:(PBResizableView *)view
              andViewFrame:(NSRect)viewFrame
                   animate:(BOOL)animate {

    NSRect frame = self.frame;

    CGFloat xPos;
    CGFloat yPos;

    if (_view1 != nil && _view2 != nil) {

        NSRect rect1 = _view1 == view ? viewFrame : _view1.frame;
        NSRect rect2 = _view2 == view ? viewFrame : _view2.frame;

        rect1.origin.x = 0.0f;
        rect1.size.width = NSWidth(self.window.screen.frame);
        rect2.origin.x = 0.0f;
        rect2.size.width = NSWidth(self.window.screen.frame);

        NSRect intersectingRect = NSIntersectionRect(rect1, rect2);

        yPos = NSMidY(intersectingRect);

    } else {
        yPos = NSMidY(viewFrame) - (NSHeight(frame) / 2.0f);
    }

    if (_view1 != nil) {
        xPos = _view1 == view ? NSMaxX(viewFrame) : NSMaxX(_view1.frame);
    } else {
        xPos = 0.0f;
    }

    frame.origin.x = roundf(xPos);
    frame.origin.y = roundf(yPos);
    frame.size.width = _value;

    if (animate) {
        self.animator.frame = frame;
    } else {
        self.frame = frame;
    }
}

- (void)initializeHorizontal {
    _vertical = NO;
}

#pragma mark - Vertical

- (id)initWithTopView:(PBGuideView *)topView
           bottomView:(PBGuideView *)bottomView
                value:(CGFloat)value {

    NSRect frame = NSMakeRect(0.0f, 0.0f, 5.0f, value);

    self = [super initWithFrame:frame];

    if (self != nil) {
        self.view1 = bottomView;
        self.view2 = topView;
        [self commonInit:value];
        [self initializeVertical];
    }

    return self;
}

- (void)updateHeightForView:(PBResizableView *)view
               andViewFrame:(NSRect)viewFrame
                    animate:(BOOL)animate {

    NSRect frame = self.frame;

    CGFloat xPos;
    CGFloat yPos;

    if (_view1 != nil && _view2 != nil) {

        NSRect rect1 = _view1 == view ? viewFrame : _view1.frame;
        NSRect rect2 = _view2 == view ? viewFrame : _view2.frame;

        rect1.origin.y = 0.0f;
        rect1.size.height = NSHeight(self.window.screen.frame);
        rect2.origin.y = 0.0f;
        rect2.size.height = NSHeight(self.window.screen.frame);

        NSRect intersectingRect = NSIntersectionRect(rect1, rect2);

        xPos = NSMidX(intersectingRect);

    } else {
        xPos = NSMidX(viewFrame) - (NSWidth(frame) / 2.0f);
    }

    if (_view1 != nil) {
        yPos = _view1 == view ? NSMaxY(viewFrame) : NSMaxY(_view1.frame);
    } else {
        yPos = 0.0f;
    }

    frame.origin.x = roundf(xPos);
    frame.origin.y = roundf(yPos);
    frame.size.height = _value;

    if (animate) {
        self.animator.frame = frame;
    } else {
        self.frame = frame;
    }
}

- (void)initializeVertical {
    _vertical = YES;
}

#pragma mark - Mouse Events

- (void)mouseDown:(NSEvent *)event {
    if ([self.delegate respondsToSelector:@selector(spacerViewClicked:)]) {
        [(id<PBSpacerProtocol>)self.delegate spacerViewClicked:self];
    }
}

#pragma mark -

- (void)setFrame:(NSRect)frameRect {
    if ((NSMinX(frameRect) != 0.0f || _vertical == NO) &&
        (NSMinY(frameRect) != 0.0f || _vertical)) {
        [super setFrame:frameRect];
    }
}

- (void)drawRect:(NSRect)dirtyRect {

    if (_hidden) return;
    
    NSRect frame;
    NSPoint point1, point2;

    if (_constraining) {
        [_constrainingSpacerColor setStroke];
    } else {
        [_spacerColor setStroke];
    }
    
    CGFloat minDimension = 1.0f / self.window.backingScaleFactor;

    if (_vertical) {

        // draw bottom line

        frame = NSMakeRect(0.0f, 0.0f, NSWidth(self.bounds), minDimension);
        frame = NSIntersectionRect(frame, dirtyRect);
        point1 = NSMakePoint(roundf(NSMinX(frame)), roundf(NSMinY(frame)));
        point2 = NSMakePoint(roundf(NSMaxX(frame)), roundf(NSMinY(frame)));

        [NSBezierPath strokeLineFromPoint:point1 toPoint:point2];

        // draw vertical line

        frame = NSMakeRect(NSMidX(self.bounds), 0.0f, minDimension, NSHeight(self.bounds));
        frame = NSIntersectionRect(frame, dirtyRect);
        point1 = NSMakePoint(roundf(NSMidX(frame) - minDimension), roundf(NSMinY(frame)));
        point2 = NSMakePoint(roundf(NSMidX(frame) - minDimension), roundf(NSMaxY(frame)));

        [NSBezierPath strokeLineFromPoint:point1 toPoint:point2];

        // draw top line

        frame = NSMakeRect(0.0f, NSHeight(self.bounds)-minDimension, NSWidth(self.bounds), minDimension);
        frame = NSIntersectionRect(frame, dirtyRect);
        point1 = NSMakePoint(roundf(NSMinX(frame)), roundf(NSMinY(frame)));
        point2 = NSMakePoint(roundf(NSMaxX(frame)), roundf(NSMaxY(frame)));

        [NSBezierPath strokeLineFromPoint:point1 toPoint:point2];

    } else {

        // draw left line

        frame = NSMakeRect(0.0f, 0.0f, minDimension, NSHeight(self.bounds));
        frame = NSIntersectionRect(frame, dirtyRect);
        point1 = NSMakePoint(roundf(NSMinX(frame)), roundf(NSMinY(frame)));
        point2 = NSMakePoint(roundf(NSMinX(frame)), roundf(NSMaxY(frame)));

        [NSBezierPath strokeLineFromPoint:point1 toPoint:point2];

        // draw horizontal line

        frame = NSMakeRect(0.0f, NSMidY(self.bounds), NSWidth(self.bounds), minDimension);
        frame = NSIntersectionRect(frame, dirtyRect);
        point1 = NSMakePoint(roundf(NSMinX(frame)), roundf(NSMidY(frame) - minDimension));
        point2 = NSMakePoint(roundf(NSMaxX(frame)), roundf(NSMidY(frame) - minDimension));

        [NSBezierPath strokeLineFromPoint:point1 toPoint:point2];

        // draw right line

        frame = NSMakeRect(NSWidth(self.bounds)-minDimension, 0.0f, minDimension, NSHeight(self.bounds));
//        frame = NSIntersectionRect(frame, dirtyRect);
        point1 = NSMakePoint(roundf(NSMinX(frame)), roundf(NSMinY(frame)));
        point2 = NSMakePoint(roundf(NSMaxX(frame)), roundf(NSMaxY(frame)));

        [NSBezierPath strokeLineFromPoint:point1 toPoint:point2];
    }
}

@end

