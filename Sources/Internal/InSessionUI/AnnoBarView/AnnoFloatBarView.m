//
//  AnnoFloatBarView.m
//  MobileRTCSample
//
//  Created by Zoom Communications on 2018/6/12.
//  Copyright © Zoom Communications, Inc. All rights reserved.
//

#import "AnnoFloatBarView.h"

@interface AnnoFloatBarView ()

@property (strong, nonatomic) UIButton *switchBtn;
@property (assign, nonatomic) CGPoint  oldPoint;
@property (assign, nonatomic) BOOL isAnnotate;
@property (strong, nonatomic) NSMutableArray *itemArray;

@property (strong, nonatomic) UIButton *colorButton;
@property (nonatomic, strong) ZoomVideoSDKAnnotationHelper *annoHelper;

@end

@implementation AnnoFloatBarView

- (instancetype)initWithAnnoHelper:(ZoomVideoSDKAnnotationHelper *)helper;
{
    self = [super init];
    if (self) {
        self.annoHelper = helper;
        [self initSubView];
        _isAnnotate = NO;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self initSubView];
        _isAnnotate = NO;
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)coder
{
    if (self = [super initWithCoder:coder])
    {
        [self initSubView];
        _isAnnotate = NO;
    }
    return self;
}

- (void)dealloc
{
    _switchBtn= nil;
    _colorButton = nil;
    [_itemArray removeAllObjects];
    _itemArray = nil;
}

- (void)updateAnnoHelper:(ZoomVideoSDKAnnotationHelper *)annoHelper
{
    self.annoHelper = annoHelper;
}

- (void)initSubView
{
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    UIImage *image = [UIImage imageNamed:@"icon_mainicon_normal"];
    self.switchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.switchBtn.frame = CGRectMake(5.0, 0.0, image.size.width, image.size.height);
    [self.switchBtn setBackgroundImage:[UIImage imageNamed:@"icon_mainicon_normal"] forState:UIControlStateNormal];
    [self.switchBtn setBackgroundImage:[UIImage imageNamed:@"icon_mainicon_pressed"] forState:UIControlStateSelected];
    [self.switchBtn addTarget:self action:@selector(onActionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.switchBtn setAccessibilityLabel:NSLocalizedString(@"Annotation Bar", @"")];
    [self addSubview:self.switchBtn];

    //add pan gesture
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    panGesture.maximumNumberOfTouches = 1;
    panGesture.minimumNumberOfTouches = 1;
    [self addGestureRecognizer:panGesture];
}

- (void)hideActionView {
    self.backgroundColor = [UIColor clearColor];
    [self.switchBtn setSelected:NO];
    
    for (UIButton *itemBtn in self.itemArray) {
        [itemBtn removeFromSuperview];
    }
    
    [self.itemArray removeAllObjects];
}

- (void)showActionView {
    
    self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.4];
    
    self.itemArray = [NSMutableArray array];
    [self.switchBtn setSelected:YES];
    
    CGSize iconSize = IS_IPAD?CGSizeMake(51, 49):CGSizeMake(51, 45);
    
    UIImage *image = [UIImage imageNamed:@"icon_mainicon_normal"];
    UIButton *penButton = [UIButton buttonWithType:UIButtonTypeCustom];
    penButton.frame = CGRectMake(image.size.width + 5, 5, iconSize.width, iconSize.height);
    [penButton setImage:[UIImage imageNamed:@"anno_icon_pen"] forState:UIControlStateNormal];
    [penButton setImage:[UIImage imageNamed:@"anno_icon_pen_selected"] forState:UIControlStateSelected];
    [penButton addTarget:self action:@selector(onPenButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [penButton setTitle:@"Pen" forState:UIControlStateNormal];
    penButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:10];
    [self layoutSubViewsInCenter:0.0 byParentView:penButton];
    [self addSubview:penButton];
    [self.itemArray addObject:penButton];
    
    UIButton *highlightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    highlightButton.frame = penButton.frame;
    highlightButton.frame = CGRectOffset(penButton.frame, iconSize.width, 0);
    [highlightButton setImage:[UIImage imageNamed:@"anno_icon_highlight"] forState:UIControlStateNormal];
    [highlightButton setImage:[UIImage imageNamed:@"anno_icon_highlight_selected"] forState:UIControlStateSelected];
    [highlightButton addTarget:self action:@selector(onHighlightButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [highlightButton setTitle:@"HighLight" forState:UIControlStateNormal];
    highlightButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:10];
    [self layoutSubViewsInCenter:0.0 byParentView:highlightButton];
    [self addSubview:highlightButton];
    [self.itemArray addObject:highlightButton];
    
    UIButton *sportlightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sportlightButton setImage:[UIImage imageNamed:@"anno_icon_spotlight"] forState:UIControlStateNormal];
    [sportlightButton setImage:[UIImage imageNamed:@"anno_icon_spotlight_selected"] forState:UIControlStateSelected];
    sportlightButton.frame = highlightButton.frame;
    sportlightButton.frame = CGRectOffset(highlightButton.frame, iconSize.width, 0);
    [sportlightButton addTarget:self action:@selector(onSpotlightButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [sportlightButton setTitle:@"SportLight" forState:UIControlStateNormal];
    sportlightButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:10];
    [self layoutSubViewsInCenter:0.0 byParentView:sportlightButton];
    [self addSubview:sportlightButton];
    [self.itemArray addObject:sportlightButton];
    
    UIColor *toolColor = [self.annoHelper getToolColor];
    UIImage *back = [self imageWithColor:[UIColor clearColor] size:CGSizeMake(20, 20) andRoundSize:0];
    UIImage *top = [self imageWithColor:toolColor size:CGSizeMake(20, 20) andRoundSize:10];
    UIImage *colorBtnImage = [self mergeTwoImages:top bottomImage:back];
    
    UIButton *colorButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [colorButton setImage:colorBtnImage forState:UIControlStateNormal];
    [colorButton setImage:colorBtnImage forState:UIControlStateSelected];
    colorButton.frame = sportlightButton.frame;
    colorButton.frame = CGRectOffset(sportlightButton.frame, iconSize.width, 0);
    [colorButton addTarget:self action:@selector(onColorButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [colorButton setTitle:@"Color" forState:UIControlStateNormal];
    colorButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:10];
    [self layoutSubViewsInCenter:0.0 byParentView:colorButton];
    [self addSubview:colorButton];
    [self.itemArray addObject:colorButton];
    self.colorButton = colorButton;
    
    UIButton *changeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [changeButton setImage:[UIImage imageNamed:@"anno_icon_arrow"] forState:UIControlStateNormal];
    [changeButton setImage:[UIImage imageNamed:@"anno_icon_arrow_selected"] forState:UIControlStateSelected];
    changeButton.frame = sportlightButton.frame;
    changeButton.frame = CGRectOffset(colorButton.frame, iconSize.width, 0);
    [changeButton addTarget:self action:@selector(onChangeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [changeButton setTitle:@"Change" forState:UIControlStateNormal];
    changeButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:10];
    [self layoutSubViewsInCenter:0.0 byParentView:changeButton];
    [self addSubview:changeButton];
    [self.itemArray addObject:changeButton];
    
    UIButton *widthButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [widthButton setImage:[UIImage imageNamed:@"anno_icon_spotlight"] forState:UIControlStateNormal];
    [widthButton setImage:[UIImage imageNamed:@"anno_icon_spotlight_selected"] forState:UIControlStateSelected];
    widthButton.frame = penButton.frame;
    widthButton.frame = CGRectOffset(penButton.frame, 0, iconSize.height);
    [widthButton addTarget:self action:@selector(onWidthButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [widthButton setTitle:@"Width" forState:UIControlStateNormal];
    widthButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:10];
    [self layoutSubViewsInCenter:0.0 byParentView:widthButton];
    [self addSubview:widthButton];
    [self.itemArray addObject:widthButton];
    
    UIButton *destroyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [destroyButton setImage:[UIImage imageNamed:@"anno_font_italic_normal"] forState:UIControlStateNormal];
    [destroyButton setImage:[UIImage imageNamed:@"anno_font_italic_normal"] forState:UIControlStateSelected];
    destroyButton.frame = widthButton.frame;
    destroyButton.frame = CGRectOffset(widthButton.frame, -(iconSize.width), 0);
    [destroyButton addTarget:self action:@selector(onDestroyButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [destroyButton setTitle:@"Destroy" forState:UIControlStateNormal];
    destroyButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:10];
    [self layoutSubViewsInCenter:0.0 byParentView:destroyButton];
    [self addSubview:destroyButton];
    [self.itemArray addObject:destroyButton];
    
    UIButton *undoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [undoButton setImage:[UIImage imageNamed:@"anno_icon_undo"] forState:UIControlStateNormal];
    [undoButton setImage:[UIImage imageNamed:@"anno_icon_undo_selected"] forState:UIControlStateSelected];
    undoButton.frame = widthButton.frame;
    undoButton.frame = CGRectOffset(widthButton.frame, iconSize.width, 0);
    [undoButton addTarget:self action:@selector(onUndoButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [undoButton setTitle:@"Undo" forState:UIControlStateNormal];
    undoButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:10];
    [self layoutSubViewsInCenter:0.0 byParentView:undoButton];
    [self addSubview:undoButton];
    [self.itemArray addObject:undoButton];
    
    UIButton *redoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [redoButton setImage:[UIImage imageNamed:@"anno_icon_redo"] forState:UIControlStateNormal];
    [redoButton setImage:[UIImage imageNamed:@"anno_icon_redo_selected"] forState:UIControlStateSelected];
    redoButton.frame = undoButton.frame;
    redoButton.frame = CGRectOffset(undoButton.frame, iconSize.width, 0);
    [redoButton addTarget:self action:@selector(onRedoButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [redoButton setTitle:@"Redo" forState:UIControlStateNormal];
    redoButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:10];
    [self layoutSubViewsInCenter:0.0 byParentView:redoButton];
    [self addSubview:redoButton];
    [self.itemArray addObject:redoButton];
    
    UIButton *cleanButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cleanButton setImage:[UIImage imageNamed:@"anno_icon_clear"] forState:UIControlStateNormal];
    [cleanButton setImage:[UIImage imageNamed:@"anno_icon_clear_selected"] forState:UIControlStateSelected];
    cleanButton.frame = redoButton.frame;
    cleanButton.frame = CGRectOffset(redoButton.frame, iconSize.width, 0);
    [cleanButton addTarget:self action:@selector(onCleanButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cleanButton setTitle:@"Clean" forState:UIControlStateNormal];
    cleanButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:10];
    [self layoutSubViewsInCenter:0.0 byParentView:cleanButton];
    [self addSubview:cleanButton];
    [self.itemArray addObject:cleanButton];
    
    UIButton *eraseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [eraseButton setImage:[UIImage imageNamed:@"anno_icon_erase"] forState:UIControlStateNormal];
    [eraseButton setImage:[UIImage imageNamed:@"anno_icon_erase_selected"] forState:UIControlStateSelected];
    eraseButton.frame = cleanButton.frame;
    eraseButton.frame = CGRectOffset(cleanButton.frame, iconSize.width, 0);
    [eraseButton addTarget:self action:@selector(onEraseButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [eraseButton setTitle:@"Erase" forState:UIControlStateNormal];
    eraseButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:10];
    [self layoutSubViewsInCenter:0.0 byParentView:eraseButton];
    [self addSubview:eraseButton];
    [self.itemArray addObject:eraseButton];
}

- (void)handlePanGesture:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        _oldPoint = [gestureRecognizer locationInView: gestureRecognizer.view];
        return;
    }
    
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        return;
    }
    
    [self locateUI:[gestureRecognizer locationInView: gestureRecognizer.view]];
}

- (void)locateUI:(CGPoint)newPoint
{
    CGFloat dx = newPoint.x - _oldPoint.x;
    CGFloat dy = newPoint.y - _oldPoint.y;
    
    CGPoint newCenter = CGPointMake(self.center.x+dx, self.center.y+dy);
    
    self.center = newCenter;
    [self setNeedsLayout];
}

- (void)onActionButtonClicked:(id)sender
{
    if (!self.isAnnotate)
    {
        [self.annoHelper startAnnotation];
        [self showActionView];
        self.isAnnotate = !self.isAnnotate;
    }
    else
    {
        [self.annoHelper stopAnnotation];
        [self hideActionView];
        self.isAnnotate = !self.isAnnotate;
    }
}

- (void)onPenButtonClicked:(id)sender
{
    [self.annoHelper setToolType:ZoomVideoSDKAnnotationToolType_Pen];
}

- (void)onHighlightButtonClicked:(id)sender
{
    [self.annoHelper setToolType:ZoomVideoSDKAnnotationToolType_HighLighter];
}

- (void)onSpotlightButtonClicked:(id)sender {
    [self.annoHelper setToolType:ZoomVideoSDKAnnotationToolType_SpotLight];
}

- (void)onDestroyButtonClicked:(id)sender {
    if (self.annoHelper) {
        ZoomVideoSDKShareHelper *shareHelper = [[ZoomVideoSDK shareInstance] getShareHelper];
        [shareHelper destroyAnnotationHelper:self.annoHelper];
    }
}

#define random(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)/255.0]
#define randomColor random(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256), 1.0)
#define ZMRed(cmmColor) (uint8_t)(cmmColor & 0xff)
#define ZMGreen(cmmColor) (uint8_t)((cmmColor >> 8) & 0xff)
#define ZMBlue(cmmColor) (uint8_t)((cmmColor >> 16) & 0xff)


- (void)onColorButtonClicked:(id)sendor {
    NSArray *colorAccessArray = @[@"Black", @"Red", @"Yellow", @"Green", @"Blue"];
    NSArray *colorArr = @[@(0x333333), @(0x1919FF), @(0x32DEFF), @(0x86C782), @(0xFF8C2E)];
    
    int i = arc4random_uniform(5);
    UIColor *color = [UIColor colorWithRed:ZMRed([colorArr[i] integerValue])/256.0 green:ZMGreen([colorArr[i] integerValue])/256.0 blue:ZMBlue([colorArr[i] integerValue])/256.0 alpha:1.0];
    [self.annoHelper setToolColor:color];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIImage *back = [self imageWithColor:[UIColor clearColor] size:CGSizeMake(20, 20) andRoundSize:0];
        UIImage *top = [self imageWithColor:color size:CGSizeMake(20, 20) andRoundSize:10];
        UIImage *colorBtnImage = [self mergeTwoImages:top bottomImage:back];
        [self.colorButton setImage:colorBtnImage forState:UIControlStateNormal];
        [self.colorButton setImage:colorBtnImage forState:UIControlStateSelected];
    });
}

- (void)onChangeButtonClicked:(id)sender
{
    if (!self.annoHelper) return;
    ZoomVideoSDKAnnotationToolType type = [self.annoHelper getToolType];
    if (ZoomVideoSDKAnnotationToolType_VanishingRectangle == type) type = ZoomVideoSDKAnnotationToolType_None;
    ZoomVideoSDKError ret = [self.annoHelper setToolType:type+1];
    NSLog(@"onChangeButtonClicked ret :%@", @(ret));
    if (ret != Errors_Success) {
        ret = [self.annoHelper setToolType:type+2];
        NSLog(@"onChangeButtonClicked ret :%@", @(ret));
    }
}

- (void)onWidthButtonClicked:(id)sender {
    if (!self.annoHelper) return;
    NSUInteger width = [self.annoHelper getToolWidth];
    width += 8;
    if (width > 45) width = 1;
    [self.annoHelper setToolWidth:width];
}

- (void)onEraseButtonClicked:(id)sender
{
    [self.annoHelper setToolType:ZoomVideoSDKAnnotationToolType_ERASER];
}

- (void)onCleanButtonClicked:(id)sender {
    if (!self.annoHelper) return;
    [self showCleanTestMenu:sender];
}

- (void)onUndoButtonClicked:(id)sender {
    if (!self.annoHelper) return;
    [self.annoHelper undo];
}

- (void)onRedoButtonClicked:(id)sender {
    if (!self.annoHelper) return;
    [self.annoHelper redo];
}

- (void)showCleanTestMenu:(id)sender
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Clear"
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];

    BOOL disalbed = [self.annoHelper canDoAnnotation];
    [alertController addAction:[UIAlertAction actionWithTitle:[NSString stringWithFormat:@"canDoAnnotation:%@", @(disalbed)]
                                                        style:UIAlertActionStyleDefault
                                                      handler:nil]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Clear my"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        [self.annoHelper clear:ZoomVideoSDKAnnotationClearType_My];
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Clear all"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        [self.annoHelper clear:ZoomVideoSDKAnnotationClearType_All];
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Clear others"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action){
        [self.annoHelper clear:ZoomVideoSDKAnnotationClearType_Others];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
    
    UIPopoverPresentationController *popover = alertController.popoverPresentationController;
    if (popover)
    {
        UIButton *btn = (UIButton*)sender;
        popover.sourceView = btn;
        popover.sourceRect = btn.bounds;
        popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    [[appDelegate topViewController] presentViewController:alertController animated:YES completion:nil];
}

- (void)layoutSubViewsInCenter:(CGFloat)space byParentView:(UIButton *)button
{
    // get the size of the elements here for readability
    CGSize imageSize = button.imageView.frame.size;
    CGSize titleSize = button.titleLabel.intrinsicContentSize;
    
    // lower the text and push it left to center it
    button.titleEdgeInsets = UIEdgeInsetsMake(0.0, -imageSize.width, -(imageSize.height + space), 0.0);
    
    // raise the image and push it right to center it
    button.imageEdgeInsets = UIEdgeInsetsMake(-(titleSize.height + space), 0.0, 0.0, -titleSize.width);
    
    // center image
    CGPoint center = button.imageView.center;
    center.x = button.frame.size.width / 2;
    button.imageView.center = center;
}

- (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size andRoundSize:(CGFloat)roundSize {
    if (!color)
        return nil;
    
    size = CGSizeMake(floor(size.width), floor(size.height));
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
#if TARGET_OS_VISION
    UIGraphicsBeginImageContextWithOptions(size, NO, 2.0);
#else
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
#endif
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (roundSize > 0) {
        UIBezierPath* roundedRectanglePath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius: roundSize];
        [color setFill];
        [roundedRectanglePath fill];
    } else {
        CGContextSetFillColorWithColor(context, [color CGColor]);
        CGContextFillRect(context, rect);
        
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage*)mergeTwoImages:(UIImage*)topImage bottomImage:(UIImage*)bottomImage
{
    int bwidth = bottomImage.size.width;
    int bheight = bottomImage.size.height;
    int twidth = topImage.size.width;
    int theight = topImage.size.height;
    int xoffset = (bwidth - twidth) / 2;
    int yoffset = (bheight - theight) / 2;
    
    CGSize size = CGSizeMake(bwidth, bheight);
#if TARGET_OS_VISION
    UIGraphicsBeginImageContextWithOptions(size, NO, 2.0);
#else
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
#endif
    [bottomImage drawInRect:CGRectMake(0,0,bwidth,bheight)];
    [topImage drawInRect:CGRectMake(xoffset,yoffset,twidth,theight) blendMode:kCGBlendModeMultiply alpha:1.0];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}
@end
