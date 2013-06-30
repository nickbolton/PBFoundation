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

@interface PBSpacerView() {

    BOOL _vertical;
}

@property (nonatomic, readwrite) PBResizeableView *view1;
@property (nonatomic, readwrite) PBResizeableView *view2;
@property (nonatomic, strong) NSMutableArray *constraints;

@property (nonatomic) CGFloat value;

@end

@implementation PBSpacerView

- (void)commonInit:(CGFloat)value {
    self.value = value;
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.constraints = [NSMutableArray array];
    self.spacerColor = [NSColor redColor];
}

- (PBGuideView *)buildGuideView:(NSRect)frame {
    PBGuideView *view = [[PBGuideView alloc] initWithFrame:frame];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    view.vertical = _vertical;
    return view;
}

- (void)removeAllConstraints {

    [self removeConstraints:_constraints];
    [self.superview removeConstraints:_constraints];
    [_constraints removeAllObjects];
}

- (void)updateSize {
    if (_vertical) {
        [self updateHeight];
    } else {
        [self updateWidth];
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

- (void)updateWidth {

    CGFloat width = NSWidth(self.frame);

    if (width <= 0.0f) {
        [self removeAllConstraints];
        return;
    }
}

- (void)initializeHorizontal {

    _vertical = NO;

    if (_view1 != nil) {

        NSArray *constraints =
        [NSLayoutConstraint
         constraintsWithVisualFormat:@"H:[_view1][self]"
         options:0
         metrics:nil
         views:NSDictionaryOfVariableBindings(_view1, self)];
        [self.superview addConstraints:constraints];
        [_constraints addObjectsFromArray:constraints];
    }

    if (_view2 != nil) {

        NSArray *constraints =
        [NSLayoutConstraint
         constraintsWithVisualFormat:@"H:[self][_view2]"
         options:0
         metrics:nil
         views:NSDictionaryOfVariableBindings(_view2, self)];
        [self.superview addConstraints:constraints];
        [_constraints addObjectsFromArray:constraints];
    }
}

#pragma mark - Vertical

- (id)initWithTopView:(PBGuideView *)topView
           bottomView:(PBGuideView *)bottomView
                value:(CGFloat)value {

    NSRect frame = NSMakeRect(0.0f, 0.0f, 5.0f, value);

    self = [super initWithFrame:frame];

    if (self != nil) {
        self.view1 = topView;
        self.view2 = bottomView;
        [self commonInit:value];
        [self initializeVertical];
    }

    return self;
}

- (void)updateHeight {

    CGFloat height = NSHeight(self.frame);

    if (height <= 0.0f) {
        [self removeAllConstraints];
        return;
    }
}

- (void)initializeVertical {

    _vertical = YES;

    if (_view1 != nil) {

        NSArray *constraints =
        [NSLayoutConstraint
         constraintsWithVisualFormat:@"V:[_view1][self]"
         options:0
         metrics:nil
         views:NSDictionaryOfVariableBindings(_view1, self)];
        [self.superview addConstraints:constraints];
        [_constraints addObjectsFromArray:constraints];
    }

    if (_view2 != nil) {

        NSArray *constraints =
        [NSLayoutConstraint
         constraintsWithVisualFormat:@"V:[self][_view2]"
         options:0
         metrics:nil
         views:NSDictionaryOfVariableBindings(_view2, self)];
        [self.superview addConstraints:constraints];
        [_constraints addObjectsFromArray:constraints];
    }
}

#pragma mark - 

- (void)setFrame:(NSRect)frameRect {

//    NSLog(@"%s frame: %@", __PRETTY_FUNCTION__, NSStringFromRect(frameRect));
//    NSLog(@"%s constraints: %@", __PRETTY_FUNCTION__, self.constraints);
//    NSLog(@"%s super.constraints: %@", __PRETTY_FUNCTION__, self.superview.constraints);

    if (NSWidth(frameRect) > 0.0f && NSHeight(frameRect) > 0.0f) {
        [super setFrame:frameRect];
    }
}

- (void)drawRect:(NSRect)dirtyRect {

    NSRect frame;
    NSPoint point1, point2;

    [_spacerColor setStroke];

    if (_vertical) {

        // draw bottom line

        frame = NSMakeRect(0.0f, 0.0f, NSWidth(self.bounds), 1.0f);
        frame = NSIntersectionRect(frame, dirtyRect);
        point1 = NSMakePoint(roundf(NSMinX(frame)), roundf(NSMinY(frame)));
        point2 = NSMakePoint(roundf(NSMaxX(frame)), roundf(NSMinY(frame)));

        [NSBezierPath strokeLineFromPoint:point1 toPoint:point2];

        // draw vertical line

        frame = NSMakeRect(NSMidX(self.bounds), 0.0f, 1.0f, NSHeight(self.bounds));
        frame = NSIntersectionRect(frame, dirtyRect);
        point1 = NSMakePoint(roundf(NSMidX(frame) - 1.0f), roundf(NSMinY(frame)));
        point2 = NSMakePoint(roundf(NSMidX(frame) - 1.0f), roundf(NSMaxY(frame)));

        [NSBezierPath strokeLineFromPoint:point1 toPoint:point2];

        // draw top line

        frame = NSMakeRect(0.0f, NSHeight(self.bounds)-1.0f, NSWidth(self.bounds), 1.0f);
        frame = NSIntersectionRect(frame, dirtyRect);
        point1 = NSMakePoint(roundf(NSMinX(frame)), roundf(NSMinY(frame)));
        point2 = NSMakePoint(roundf(NSMaxX(frame)), roundf(NSMaxY(frame)));

        [NSBezierPath strokeLineFromPoint:point1 toPoint:point2];

    } else {

        // draw left line

        frame = NSMakeRect(0.0f, 0.0f, 1.0f, NSHeight(self.bounds));
        frame = NSIntersectionRect(frame, dirtyRect);
        point1 = NSMakePoint(roundf(NSMinX(frame)), roundf(NSMinY(frame)));
        point2 = NSMakePoint(roundf(NSMinX(frame)), roundf(NSMaxY(frame)));

        [NSBezierPath strokeLineFromPoint:point1 toPoint:point2];

        // draw horizontal line

        frame = NSMakeRect(0.0f, NSMidY(self.bounds), NSWidth(self.bounds), 1.0f);
        frame = NSIntersectionRect(frame, dirtyRect);
        point1 = NSMakePoint(roundf(NSMinX(frame)), roundf(NSMidY(frame) - 1.0f));
        point2 = NSMakePoint(roundf(NSMaxX(frame)), roundf(NSMidY(frame) - 1.0f));

        [NSBezierPath strokeLineFromPoint:point1 toPoint:point2];

        // draw right line

        frame = NSMakeRect(NSWidth(self.bounds)-1.0f, 0.0f, 1.0f, NSHeight(self.bounds));
        frame = NSIntersectionRect(frame, dirtyRect);
        point1 = NSMakePoint(roundf(NSMinX(frame)), roundf(NSMinY(frame)));
        point2 = NSMakePoint(roundf(NSMaxX(frame)), roundf(NSMaxY(frame)));

        [NSBezierPath strokeLineFromPoint:point1 toPoint:point2];
    }
}

@end

