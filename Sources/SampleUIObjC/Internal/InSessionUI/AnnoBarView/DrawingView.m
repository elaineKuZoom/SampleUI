

#import "DrawingView.h"

@implementation DrawingViewDataHelper

+ (NSString *)stringForDrawingShapeEvent:(DrawingShapeEventType)eventType content:(NSString * _Nullable)content {
    switch (eventType) {
        case DrawingShapeEventTypeBegin:
            return @"DrawShape|Begin";
        case DrawingShapeEventTypeContent:
            if (content.length > 0) {
                return [NSString stringWithFormat:@"DrawShape|%@", content];
            } else {
                return @"DrawShape|Content"; // Default content
            }
        case DrawingShapeEventTypeEnd:
            return @"DrawShape|End";
        case DrawingShapeEventTypeClear:
            return @"DrawShape|Clear";
    }
}

+ (NSDictionary *)parseDrawingShapeString:(NSString *)input {
    if (input.length == 0) return nil;

    NSArray *parts = [input componentsSeparatedByString:@"|"];
    if (parts.count < 2) return nil;

    NSString *command = parts[1];
    if ([command isEqualToString:@"Begin"]) {
        return @{@"eventType": @(DrawingShapeEventTypeBegin)};
    }
    if ([command isEqualToString:@"End"]) {
        return @{@"eventType": @(DrawingShapeEventTypeEnd)};
    }
    if ([command isEqualToString:@"Clear"]) {
        return @{@"eventType": @(DrawingShapeEventTypeClear)};
    }

    NSString *content = [input substringFromIndex:@"DrawShape|".length];
    return @{
        @"eventType": @(DrawingShapeEventTypeContent),
        @"content": content
    };
}

@end

@interface MessageAssembler ()
@property (nonatomic) NSUInteger expectedParts;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSString *> *receivedParts;

@end

@implementation MessageAssembler

- (instancetype)init {
    if (self = [super init]) {
        _receivedParts = [NSMutableDictionary dictionary];
        _expectedParts = 0;
    }
    return self;
}

- (BOOL)addPart:(NSString *)part {
    NSArray<NSString *> *components = [part componentsSeparatedByString:@"|"];
    if (components.count < 4 || ![components[0] isEqualToString:@"Part"]) {
        NSLog(@"famat error");
        return NO;
    }

    NSUInteger index = [components[1] integerValue];
    NSUInteger total = [components[2] integerValue];
    NSString *content = [[components subarrayWithRange:NSMakeRange(3, components.count - 3)] componentsJoinedByString:@"|"];

    if (self.expectedParts == 0) {
        self.expectedParts = total;
    } else if (self.expectedParts != total) {
        NSLog(@"expect not equal to total");
        return NO;
    }

    self.receivedParts[@(index)] = content;
    return YES;
}

- (BOOL)isComplete {
    return self.expectedParts > 0 && self.receivedParts.count == self.expectedParts;
}

- (NSString *)assembledMessage {
    if (![self isComplete]) return nil;
    
    NSMutableString *result = [NSMutableString string];
    for (NSUInteger i = 0; i < self.expectedParts; i++) {
        NSString *piece = self.receivedParts[@(i)];
        if (piece) {
            [result appendString:piece];
        } else {
            NSLog(@"Loss index=%lu", (unsigned long)i);
        }
    }
    [self.receivedParts removeAllObjects];
    self.expectedParts = 0;
    return result;
}

@end


typedef NS_ENUM(NSInteger, ShapeType) {
    ShapeTypeLine,
    ShapeTypeStrokeRect,
    ShapeTypeFillRect
};

@interface ShapeModel : NSObject
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, assign) ShapeType shapeType;
@property (nonatomic, assign) CGPoint startPoint;
@property (nonatomic, assign) CGPoint endPoint;

@property (nonatomic, strong) UIBezierPath *path;
@property (nonatomic, strong) NSMutableArray<NSValue *> *pathPoints;

- (NSString *)toJSONString;
+ (instancetype)fromJSONString:(NSString *)jsonStrin;
@end

@implementation ShapeModel

- (NSString *)toJSONString {
    NSDictionary *dict = [self toDictionary];
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    if (error) {
        NSLog(@"JSON fail: %@", error);
        return nil;
    }
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

+ (instancetype)fromJSONString:(NSString *)jsonString {
    NSError *error = nil;
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error || ![dict isKindOfClass:[NSDictionary class]]) {
        NSLog(@"Anti-JSON fail: %@", error);
        return nil;
    }
    return [self modelFromDictionary:dict];
}

- (NSDictionary *)toDictionary {
    CGFloat r = 0, g = 0, b = 0, a = 1;
    [self.color getRed:&r green:&g blue:&b alpha:&a];

    NSMutableDictionary *dict = [@{
        @"color": @{@"r": @(r), @"g": @(g), @"b": @(b), @"a": @(a)},
        @"lineWidth": @(self.lineWidth),
        @"shapeType": @(self.shapeType),
        @"startPoint": @{@"x": @(self.startPoint.x), @"y": @(self.startPoint.y)},
        @"endPoint": @{@"x": @(self.endPoint.x), @"y": @(self.endPoint.y)}
    } mutableCopy];

    if (self.shapeType == ShapeTypeLine && self.pathPoints.count > 0) {
        NSMutableArray *pointsArr = [NSMutableArray array];
        for (NSValue *val in self.pathPoints) {
            CGPoint pt = val.CGPointValue;
            [pointsArr addObject:@{@"x": @(pt.x), @"y": @(pt.y)}];
        }
        dict[@"pathPoints"] = pointsArr;
    }

    return dict;
}

+ (instancetype)modelFromDictionary:(NSDictionary *)dict {
    ShapeModel *model = [[ShapeModel alloc] init];

    NSDictionary *colorDict = dict[@"color"];
    model.color = [UIColor colorWithRed:[colorDict[@"r"] floatValue]
                                  green:[colorDict[@"g"] floatValue]
                                   blue:[colorDict[@"b"] floatValue]
                                  alpha:[colorDict[@"a"] floatValue]];
    model.lineWidth = [dict[@"lineWidth"] floatValue];
    model.shapeType = [dict[@"shapeType"] integerValue];

    NSDictionary *startDict = dict[@"startPoint"];
    NSDictionary *endDict = dict[@"endPoint"];
    model.startPoint = CGPointMake([startDict[@"x"] floatValue], [startDict[@"y"] floatValue]);
    model.endPoint = CGPointMake([endDict[@"x"] floatValue], [endDict[@"y"] floatValue]);

    if (model.shapeType == ShapeTypeLine && dict[@"pathPoints"]) {
        NSArray *pointsArr = dict[@"pathPoints"];
        model.pathPoints = [NSMutableArray array];
        model.path = [UIBezierPath bezierPath];
        model.path.lineWidth = model.lineWidth;

        if (pointsArr.count > 0) {
            NSDictionary *first = pointsArr[0];
            CGPoint start = CGPointMake([first[@"x"] floatValue], [first[@"y"] floatValue]);
            [model.path moveToPoint:start];
            [model.pathPoints addObject:[NSValue valueWithCGPoint:start]];

            for (int i = 1; i < pointsArr.count; i++) {
                NSDictionary *ptDict = pointsArr[i];
                CGPoint pt = CGPointMake([ptDict[@"x"] floatValue], [ptDict[@"y"] floatValue]);
                [model.path addLineToPoint:pt];
                [model.pathPoints addObject:[NSValue valueWithCGPoint:pt]];
            }
        }
    }

    return model;
}
@end

@interface DrawingView ()

@property (nonatomic, strong) NSMutableArray<ShapeModel *> *shapes;
@property (nonatomic, strong) ShapeModel *currentShape;

@property (nonatomic, strong) UIColor *currentColor;
@property (nonatomic, assign) CGFloat currentLineWidth;
@property (nonatomic, assign) ShapeType currentShapeType;

@end

@implementation DrawingView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = UIColor.whiteColor;
        self.shapes = [NSMutableArray array];

        self.currentColor = UIColor.blackColor;
        self.currentLineWidth = 2.0;
        self.currentShapeType = ShapeTypeLine;
        
        [self setupControls];
    }
    return self;
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    if (self.superview) {
        if ([self.delegate respondsToSelector:@selector(drawingShapeBegin)]) {
            [self.delegate drawingShapeBegin];
        }
    }
}

#pragma mark - UI
- (void)setupControls
{
    CGFloat startY = 70;
    NSArray *colors = @[UIColor.blackColor, UIColor.redColor, UIColor.blueColor];
    for (int i = 0; i < colors.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame = CGRectMake(20 + i * 60, startY, 50, 30);
        btn.backgroundColor = colors[i];
        btn.tag = i;
        [btn addTarget:self action:@selector(colorSelected:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
    }

    UIButton *thinBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    thinBtn.frame = CGRectMake(20, startY+30+20, 80, 45);
    [thinBtn setTitle:@"Thin Line" forState:UIControlStateNormal];
    [thinBtn addTarget:self action:@selector(thinSelected) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:thinBtn];

    UIButton *thickBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    thickBtn.frame = CGRectMake(110, startY+30+20, 80, 45);
    [thickBtn setTitle:@"Thick Line" forState:UIControlStateNormal];
    [thickBtn addTarget:self action:@selector(thickSelected) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:thickBtn];

    UISegmentedControl *seg = [[UISegmentedControl alloc] initWithItems:@[@"Line", @"HSquare", @"SSquare"]];
    seg.frame = CGRectMake(20, CGRectGetMaxY(thickBtn.frame) + 20, 200, 30);
    [seg addTarget:self action:@selector(shapeTypeChanged:) forControlEvents:UIControlEventValueChanged];
    seg.selectedSegmentIndex = 0;
    [self addSubview:seg];
    
    CGFloat buttonWidth = 60;
    CGFloat buttonHeight = 30;
    CGFloat padding = 10;

    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [closeButton setTitle:@"Close" forState:UIControlStateNormal];
    closeButton.frame = CGRectMake(self.bounds.size.width - buttonWidth - padding, startY, buttonWidth, buttonHeight);
    closeButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    [closeButton addTarget:self action:@selector(closeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:closeButton];

    UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [clearButton setTitle:@"Clear" forState:UIControlStateNormal];
    clearButton.frame = CGRectMake(self.bounds.size.width - 2*buttonWidth - 2*padding, startY, buttonWidth, buttonHeight);
    clearButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    [clearButton addTarget:self action:@selector(clearButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:clearButton];
}

#pragma mark - Control Actions
- (void)colorSelected:(UIButton *)sender {
    NSArray *colors = @[UIColor.blackColor, UIColor.redColor, UIColor.blueColor];
    self.currentColor = colors[sender.tag];
}

- (void)thinSelected {
    self.currentLineWidth = 2.0;
}

- (void)thickSelected {
    self.currentLineWidth = 6.0;
}

- (void)shapeTypeChanged:(UISegmentedControl *)seg {
    self.currentShapeType = seg.selectedSegmentIndex;
}

- (void)closeButtonTapped {
    NSLog(@"Close button tapped!");
    
    if ([self.delegate respondsToSelector:@selector(drawingShapeEnd)]) {
        [self.delegate drawingShapeEnd];
    }
    
    [self removeFromSuperview];
}

- (void)clearButtonTapped {
    NSLog(@"Clear button tapped!");
    if ([self.delegate respondsToSelector:@selector(drawingShapeClear)]) {
        [self.delegate drawingShapeClear];
    }
    
    [self claerView];
}

- (void)claerView
{
    [self.shapes removeAllObjects];
    [self setNeedsDisplay];
}

#pragma mark - Touch
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint p = [[touches anyObject] locationInView:self];
    ShapeModel *shape = [ShapeModel new];
    shape.color = self.currentColor;
    shape.lineWidth = self.currentLineWidth;
    shape.shapeType = self.currentShapeType;
    shape.startPoint = p;
    shape.endPoint = p;
    if (shape.shapeType == ShapeTypeLine) {
        shape.path = [UIBezierPath bezierPath];
        shape.path.lineWidth = shape.lineWidth;
        [shape.path moveToPoint:p];

        shape.pathPoints = [NSMutableArray array];
        [shape.pathPoints addObject:[NSValue valueWithCGPoint:p]];
    }
    self.currentShape = shape;
    [self.shapes addObject:shape];
    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint p = [[touches anyObject] locationInView:self];
    self.currentShape.endPoint = p;

    if (self.currentShape.shapeType == ShapeTypeLine) {
        [self.currentShape.path addLineToPoint:p];
        [self.currentShape.pathPoints addObject:[NSValue valueWithCGPoint:p]];
    }
    [self setNeedsDisplay];
    
    if (self.currentShape && self.currentShape.shapeType != ShapeTypeLine) {
        NSString *jsonString = [self.currentShape toJSONString];
        if (jsonString && [self.delegate respondsToSelector:@selector(drawingShapeWithJSONString:)]) {
            [self.delegate drawingShapeWithJSONString:jsonString];
        }
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.currentShape.shapeType == ShapeTypeLine)
    {
        NSString *jsonString = [self.currentShape toJSONString];
        if (jsonString && [self.delegate respondsToSelector:@selector(drawingShapeWithJSONString:)]) {
            [self.delegate drawingShapeWithJSONString:jsonString];
        }
    }
    self.currentShape = nil;
}

#pragma mark - Draw
- (void)drawRect:(CGRect)rect {
    if (!self.shapes.lastObject) return;
    NSArray *arr = @[self.shapes.lastObject];
    for (ShapeModel *shape in arr) {
        [shape.color setStroke];
        [shape.color setFill];

        switch (shape.shapeType) {
            case ShapeTypeLine:
                [shape.path setLineWidth:shape.lineWidth];
                [shape.path stroke];
                break;
            case ShapeTypeStrokeRect: {
                CGRect box = [self rectFromPoints:shape.startPoint to:shape.endPoint];
                UIBezierPath *path = [UIBezierPath bezierPathWithRect:box];
                path.lineWidth = shape.lineWidth;
                CGFloat dashPattern[] = {6, 3};
                [path setLineDash:dashPattern count:2 phase:0];
                [path stroke];
                break;
            }
            case ShapeTypeFillRect: {
                CGRect box = [self rectFromPoints:shape.startPoint to:shape.endPoint];
                UIBezierPath *path = [UIBezierPath bezierPathWithRect:box];
                [path fill];
                break;
            }
        }
    }
}

- (CGRect)rectFromPoints:(CGPoint)p1 to:(CGPoint)p2 {
    CGFloat x = MIN(p1.x, p2.x);
    CGFloat y = MIN(p1.y, p2.y);
    CGFloat w = fabs(p2.x - p1.x);
    CGFloat h = fabs(p2.y - p1.y);
    return CGRectMake(x, y, w, h);
}


- (void)addShapeFromJSONString:(NSString *)jsonString {
    if (jsonString.length == 0) {
        NSLog(@"JSON string is empty");
        return;
    }

    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error || ![dict isKindOfClass:[NSDictionary class]]) {
        NSLog(@"JSON parsing fail: %@", error);
        return;
    }

    ShapeModel *model = [ShapeModel modelFromDictionary:dict];
    if (!model) {
        NSLog(@"to model with dict fail");
        return;
    }
    NSLog(@"addShapeFromJSONString");
    [self.shapes removeAllObjects];
    [self.shapes addObject:model];
    [self setNeedsDisplay];
}
@end
