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

static NSImage *PBSpacerViewUpImage = nil;
static NSImage *PBSpacerViewDownImage = nil;
static NSImage *PBSpacerViewLeftImage = nil;
static NSImage *PBSpacerViewRightImage = nil;

@interface PBSpacerView() {

    BOOL _vertical;
}

@property (nonatomic, readwrite) PBResizeableView *view1;
@property (nonatomic, readwrite) PBResizeableView *view2;
@property (nonatomic, strong) PBGuideView *guideView1;
@property (nonatomic, strong) PBGuideView *guideView2;
@property (nonatomic, strong) NSTextField *valueTextField;
@property (nonatomic, strong) NSImageView *arrowImageView1;
@property (nonatomic, strong) NSImageView *arrowImageView2;
@property (nonatomic, strong) NSLayoutConstraint *guideView1Size;
@property (nonatomic, strong) NSLayoutConstraint *guideView2Size;
@property (nonatomic, strong) NSLayoutConstraint *valueTextFieldWidth;
@property (nonatomic, strong) NSMutableArray *constraints;

@property (nonatomic) CGFloat value;

@end

@implementation PBSpacerView

+ (void)setUpSpacerImage:(NSImage *)image {
    PBSpacerViewUpImage = image;
}

+ (void)setDownSpacerImage:(NSImage *)image {
    PBSpacerViewDownImage = image;
}

+ (void)setLeftSpacerImage:(NSImage *)image {
    PBSpacerViewLeftImage = image;
}

+ (void)setRightSpacerImage:(NSImage *)image {
    PBSpacerViewRightImage = image;
}

+ (NSImage *)upSpacerImage {
    if (PBSpacerViewUpImage == nil) {
        PBSpacerViewUpImage = [NSImage imageNamed:@"arrowUp"];
    }
    return PBSpacerViewUpImage;
}

+ (NSImage *)downSpacerImage {
    if (PBSpacerViewDownImage == nil) {
        PBSpacerViewDownImage = [NSImage imageNamed:@"arrowDown"];
    }
    return PBSpacerViewDownImage;
}

+ (NSImage *)leftSpacerImage {
    if (PBSpacerViewLeftImage == nil) {
        PBSpacerViewLeftImage = [NSImage imageNamed:@"arrowLeft"];
    }
    return PBSpacerViewLeftImage;
}

+ (NSImage *)rightSpacerImage {
    if (PBSpacerViewRightImage == nil) {
        PBSpacerViewRightImage = [NSImage imageNamed:@"arrowRight"];
    }
    return PBSpacerViewRightImage;
}

- (PBGuideView *)buildGuideView:(NSRect)frame {
    PBGuideView *view = [[PBGuideView alloc] initWithFrame:frame];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    view.vertical = _vertical;
    return view;
}

- (void)addSpacerConstraints {

    if (_vertical) {
        [self addVerticalSpacerConstraints];
    } else {
        [self addHorizontalSpacerConstraints];
    }
}

- (void)removeAllConstraints {

    [self removeConstraints:_constraints];
    [self.superview removeConstraints:_constraints];
    [_guideView1 removeConstraint:_guideView1Size];
    [_guideView2 removeConstraint:_guideView2Size];
    [_valueTextField removeConstraint:_valueTextFieldWidth];
    [_valueTextField removeConstraints:_constraints];
    [_constraints removeAllObjects];
}

- (void)tearDownSubviews {
    [self removeAllConstraints];
    [_guideView1 removeFromSuperview];
    [_guideView2 removeFromSuperview];
    [_arrowImageView1 removeFromSuperview];
    [_arrowImageView2 removeFromSuperview];
    [_valueTextField removeFromSuperview];
    self.guideView1 = nil;
    self.guideView2 = nil;
    self.guideView1Size = nil;
    self.guideView2Size = nil;
    self.valueTextFieldWidth = nil;
    self.arrowImageView1 = nil;
    self.arrowImageView2 = nil;
}

- (void)buildValueTextField {

    if (_valueTextField == nil) {

        NSRect frame = NSZeroRect;

        self.valueTextField = [[NSTextField alloc] initWithFrame:frame];
        _valueTextField.bezeled = NO;
        _valueTextField.drawsBackground = YES;
        _valueTextField.backgroundColor = [NSColor blackColor];
        _valueTextField.editable = NO;
        _valueTextField.selectable = NO;
        _valueTextField.translatesAutoresizingMaskIntoConstraints = NO;
        _valueTextField.textColor = [NSColor whiteColor];
        _valueTextField.font = [NSFont fontWithName:@"HelveticaNeue" size:13.0f];
    }
    [self addSubview:_valueTextField];
}

- (void)updateValueTextField {

    NSString *text = [NSString stringWithFormat:@"%.0f", _value];

    NSSize size =
    [text sizeWithAttributes:
     @{
       NSFontAttributeName : _valueTextField.font,
     }];

    _valueTextField.stringValue = text;
    [_valueTextField sizeToFit];

//    if (_valueTextFieldWidth == nil) {
//
//        self.valueTextFieldWidth =
//        [NSLayoutConstraint
//         addWidthConstraint:size.width
//         toView:_valueTextField];
//
//    } else {
//
//        self.valueTextFieldWidth.constant = size.width;
//    }
//
//    [self setNeedsLayout:YES];
}

#pragma mark - Horizontal

- (void)addHorizontalSpacerConstraints {

    if (_view1 != nil) {

        NSArray *constraints =
        [NSLayoutConstraint
         constraintsWithVisualFormat:@"H:[_view1]-(0)-[self]"
         options:0
         metrics:nil
         views:NSDictionaryOfVariableBindings(_view1, self)];
        [self.superview addConstraints:constraints];
        [_constraints addObjectsFromArray:constraints];
    }

    if (_view2 != nil) {

        NSArray *constraints =
        [NSLayoutConstraint
         constraintsWithVisualFormat:@"H:[self]-(0)-[_view2]"
         options:0
         metrics:nil
         views:NSDictionaryOfVariableBindings(_view2, self)];
        [self.superview addConstraints:constraints];
        [_constraints addObjectsFromArray:constraints];
    }
}

- (id)initWithLeftView:(PBGuideView *)leftView
             rightView:(PBGuideView *)rightView
                 value:(CGFloat)value {

    CGFloat height =
    MAX([PBSpacerView leftSpacerImage].size.height,
        [PBSpacerView rightSpacerImage].size.height);

    NSRect frame = NSMakeRect(0.0f, 0.0f, value, height);

    self = [super initWithFrame:frame];

    if (self != nil) {
        self.view1 = leftView;
        self.view2 = rightView;
        self.value = value;
        self.constraints = [NSMutableArray array];
        self.translatesAutoresizingMaskIntoConstraints = NO;
        [self buildValueTextField];
        [self tearDownSubviews];
    }

    return self;
}

- (CGFloat)guideWidth {

    NSImage *leftArrowImage = [PBSpacerView leftSpacerImage];
    NSImage *rightArrowImage = [PBSpacerView rightSpacerImage];

    return
    (NSWidth(self.frame) - leftArrowImage.size.width - rightArrowImage.size.width) / 2.0f;
}

- (void)updateWidth {

    [self updateValueTextField];

    CGFloat width = [self guideWidth];

    if (width <= 0.0f) {
        [self tearDownSubviews];
        return;
    }

    if (_guideView1 == nil) {
        if (_vertical) {
            [self initializeVertical];
        } else {
            [self initializeHorizontal];
        }
        [self addSpacerConstraints];
    }

//    self.alphaValue = 1.0f;

    _guideView1Size.constant = width;
    [_guideView1 setNeedsLayout:YES];

    _guideView2Size.constant = width;
    [_guideView2 setNeedsLayout:YES];

}

- (void)initializeHorizontal {

    _vertical = NO;

    self.guideView1 = [self buildLeftGuideView];
    self.guideView2 = [self buildRightGuideView];

    [self buildLeftArrowImageView];
    [self buildRightArrowImageView];
    [self addSubview:_valueTextField];

    NSArray *constraints =
    [NSLayoutConstraint
     constraintsWithVisualFormat:@"H:|[_arrowImageView1(leftArrowWidth)][_guideView1(>=0)][_guideView2(>=0)][_arrowImageView2(rightArrowWidth)]|"
     options:0
     metrics:
     @{
       @"leftArrowWidth" : @([PBSpacerView leftSpacerImage].size.width),
       @"rightArrowWidth" : @([PBSpacerView rightSpacerImage].size.width),
       }
     views:NSDictionaryOfVariableBindings(_arrowImageView1, _guideView1, _guideView2, _arrowImageView2)];
    [self addConstraints:constraints];
    [_constraints addObjectsFromArray:constraints];

    NSLayoutConstraint *centeredX =
    [NSLayoutConstraint
     constraintWithItem:_valueTextField
     attribute:NSLayoutAttributeCenterX
     relatedBy:NSLayoutRelationEqual
     toItem:self
     attribute:NSLayoutAttributeCenterX
     multiplier:1.0f
     constant:0.0f];
    [self addConstraint:centeredX];
    [_constraints addObject:centeredX];

    self.guideView1Size =
    [NSLayoutConstraint
     addWidthConstraint:NSWidth(_guideView1.frame)
     toView:_guideView1];

    self.guideView2Size =
    [NSLayoutConstraint
     addWidthConstraint:NSWidth(_guideView2.frame)
     toView:_guideView2];
}

- (NSImageView *)buildArrowImageView:(NSImage *)arrowImage {

    NSRect frame = NSZeroRect;
    frame.size = arrowImage.size;

    NSImageView *imageView = [[NSImageView alloc] initWithFrame:frame];
    imageView.imageScaling = NSScaleNone;
    imageView.image = arrowImage;
    imageView.translatesAutoresizingMaskIntoConstraints = NO;

    [self addSubview:imageView];

    [NSLayoutConstraint addWidthConstraint:NSWidth(frame) toView:imageView];
    [NSLayoutConstraint addHeightConstraint:NSHeight(frame) toView:imageView];

    return imageView;
}

- (void)buildLeftArrowImageView {
    self.arrowImageView1 =
    [self buildArrowImageView:[PBSpacerView leftSpacerImage]];
}

- (void)buildRightArrowImageView {
    self.arrowImageView2 =
    [self buildArrowImageView:[PBSpacerView rightSpacerImage]];
}

- (PBGuideView *)buildLeftGuideView {

    NSImage *leftArrowImage = [PBSpacerView leftSpacerImage];
    
    CGFloat width = [self guideWidth];

    NSRect frame =
    NSMakeRect(leftArrowImage.size.width,
               (NSHeight(self.frame) - 1.0f) / 2.0f,
               width,
               1.0f);

    PBGuideView *guideView = [self buildGuideView:frame];
    guideView.autoresizingMask = NSViewWidthSizable;
    
    [self addSubview:guideView];

    return guideView;
}

- (PBGuideView *)buildRightGuideView {

    NSImage *leftArrowImage = [PBSpacerView leftSpacerImage];

    CGFloat width = [self guideWidth];

    NSRect frame =
    NSMakeRect(width + leftArrowImage.size.width,
               (NSHeight(self.frame) - 1.0f) / 2.0f,
               width,
               1.0f);

    PBGuideView *guideView = [self buildGuideView:frame];
    guideView.autoresizingMask = NSViewWidthSizable;

    guideView.frame = frame;
    [self addSubview:guideView];

    return guideView;
}

#pragma mark - Vertical

- (id)initWithTopView:(PBGuideView *)topView
           bottomView:(PBGuideView *)bottomView
                value:(CGFloat)value {

    CGFloat height =
    MAX([PBSpacerView leftSpacerImage].size.height,
        [PBSpacerView rightSpacerImage].size.height);

    NSRect frame = NSMakeRect(0.0f, 0.0f, value, height);

    self = [super initWithFrame:frame];

    if (self != nil) {
        self.view1 = topView;
        self.view2 = bottomView;
        self.value = value;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        [self initializeVertical];
        [self buildValueTextField];
        [self tearDownSubviews];
    }

    return self;

}

- (void)addVerticalSpacerConstraints {
}

- (CGFloat)guideHeight {
    return 0.0f;
}

- (void)updateHeight {
}

- (void)buildUpArrowImageView {
    self.arrowImageView1 =
    [self buildArrowImageView:[PBSpacerView upSpacerImage]];
}

- (void)buildDownArrowImageView {
    self.arrowImageView2 =
    [self buildArrowImageView:[PBSpacerView downSpacerImage]];
}

- (void)initializeVertical {

    _vertical = YES;

    NSRect frame =
    NSMakeRect((NSWidth(self.frame) - 1.0f) / 2.0f,
               0.0f,
               1.0f,
               _value);

    PBGuideView *guideView = [self buildGuideView:frame];
    guideView.frame = frame;
    guideView.translatesAutoresizingMaskIntoConstraints = NO;

    [self addSubview:guideView];

    [NSLayoutConstraint addHeightConstraint:1.0f toView:guideView];
    [NSLayoutConstraint expandHeightToSuperview:guideView];
    [NSLayoutConstraint horizontallyCenterView:guideView];

    NSImage *upArrowImage = [PBSpacerView upSpacerImage];
    NSImage *downArrowImage = [PBSpacerView downSpacerImage];

    CGFloat width =
    MAX(upArrowImage.size.width, downArrowImage.size.width);

    [NSLayoutConstraint addWidthConstraint:width toView:self];
    
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

//- (void)drawRect:(NSRect)dirtyRect {
//
//    [[NSColor redColor] setFill];
//    NSRectFillUsingOperation(dirtyRect, NSCompositeSourceOver);
//
//    [super drawRect:dirtyRect];
//}

@end

