//
//  IntroViewController.m
//  ZoomVideoSample
//
//  Created by Zoom Communications on 2019/10/23.
//  Copyright © 2019 Zoom. All rights reserved.
//

#import "SampleUI.h"
#import "IntroViewController.h"
#import "Vender/LGSideMenuController/UIViewController+LGSideMenuController.h"
#import "PreSessionUI/CreateViewController.h"
#import "PreSessionUI/MainViewController.h"

#define kTagImgView         11001
#if TARGET_OS_VISION
#define Button_Hight        60
#else
#define Button_Hight        44
#endif
#define kPageHeight         20
#define Top_Space_Hight     50

@interface IntroViewController ()<UIScrollViewDelegate>

@property (retain, nonatomic)  UIImageView *bgImageView;
@property (retain, nonatomic)  UIImageView *coverImageView;

@property (retain, nonatomic)  UIScrollView *scrollView;
@property (retain, nonatomic)  UIPageControl *pageControl;

@property (retain, nonatomic)  UIView *firstView;
@property (retain, nonatomic)  UIView *secondView;
@property (retain, nonatomic)  UIView *thirdView;
@property (retain, nonatomic)  UIView *forthView;
@property (retain, nonatomic)  UIView *fifthView;
@property (retain, nonatomic)  UIView *sixthView;
//@property (retain, nonatomic)  UIView *seventhView;

@property (retain, nonatomic)  UIButton *sideButton;

@property (retain, nonatomic)  UIView   *buttonView;
@property (retain, nonatomic)  UIButton *createButton;
@property (retain, nonatomic)  UIButton *joinButtin;

@property (assign, nonatomic)  float bg_height;
@end

@implementation IntroViewController

- (CGFloat)imageViewYOffset {
#if TARGET_OS_VISION
    return MaxY(self.pageControl) + 50;
#else
    return MaxY(self.pageControl) + 20;
#endif
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.view.backgroundColor = [UIColor whiteColor];

    [self.view addSubview:self.bgImageView];

    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.firstView];
    [self.scrollView addSubview:self.secondView];
    [self.scrollView addSubview:self.thirdView];
    [self.scrollView addSubview:self.forthView];
    [self.scrollView addSubview:self.fifthView];
    [self.scrollView addSubview:self.sixthView];
//    [self.scrollView addSubview:self.seventhView];


    [self.view addSubview:self.coverImageView];

    [self.view addSubview:self.pageControl];

    if (@available(iOS 11.0, *))
    {
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }

    [self.view addSubview:self.sideButton];

    [self.view addSubview:self.buttonView];
    [self.view addSubview:self.createButton];
    [self.view addSubview:self.joinButtin];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}


- (BOOL)shouldAutorotate{
    return NO;
}

#if TARGET_OS_VISION
- (void)windowSizeDidChange:(NSValue *)sizeValue {
    CGSize newSize = [sizeValue CGSizeValue];
    NSLog(@"IntroViewController window size changed to: %@", NSStringFromCGSize(newSize));

            // Recalculate layout parameters
    [self recalculateLayoutForSize:newSize];

            // Notify child view controllers
    for (UIViewController *childViewController in self.childViewControllers) {
        if ([childViewController respondsToSelector:@selector(windowSizeDidChange:)]) {
            [childViewController performSelector:@selector(windowSizeDidChange:) withObject:sizeValue];
        }
    }
}

- (void)recalculateLayoutForSize:(CGSize)size {
    // Vision Pro optimization: recalculate layout parameters based on new window size
    CGFloat screenRatio = size.width / size.height;

    // Dynamically adjust background height
    if (screenRatio > 1.5) {
        // Wide screen mode
        _bg_height = size.height * 0.55; // Reduce background height to leave more space for buttons
    } else if (screenRatio < 1.0) {
        // Portrait mode
        _bg_height = size.height * 0.65;
    } else {
        // Standard mode
        _bg_height = size.height * 0.6;
    }

    // Dynamically adjust button width and position
    CGFloat buttonWidth = MIN(size.width * 0.35, 400); // Max width 400
    CGFloat buttonMargin = (size.width - buttonWidth) / 2;

    // Update layout
    [self updateLayoutForNewSize:size buttonWidth:buttonWidth buttonMargin:buttonMargin];
}

- (void)updateLayoutForNewSize:(CGSize)size buttonWidth:(CGFloat)buttonWidth buttonMargin:(CGFloat)buttonMargin {
    // Vision Pro optimization: update button layout
    if (self.createButton && self.joinButtin) {
        // Ensure buttons have sufficient vertical space
        CGFloat availableHeight = size.height - _bg_height;
        CGFloat buttonSpacing = 20; // Button spacing
        CGFloat totalButtonHeight = Button_Hight * 2 + buttonSpacing;
        CGFloat button_y = _bg_height + (availableHeight - totalButtonHeight) / 2;

        self.createButton.frame = CGRectMake(buttonMargin, button_y, buttonWidth, Button_Hight);
        self.joinButtin.frame = CGRectMake(buttonMargin, MaxY(self.createButton) + buttonSpacing, buttonWidth, Button_Hight);
    }

    // Update background image layout
    if (self.bgImageView) {
        self.bgImageView.frame = CGRectMake(0, 0, size.width, _bg_height);
    }

    // Update scroll view layout
    if (self.scrollView) {
        self.scrollView.frame = CGRectMake(0, 0, size.width, Height(self.bgImageView));
        self.scrollView.contentSize = CGSizeMake(size.width * self.pageControl.numberOfPages, Width(self.scrollView));
    }

    // Update page control position
    if (self.pageControl) {
        CGFloat pageControlY = size.height * 0.06; // 6% of screen height
        self.pageControl.frame = CGRectMake(0, pageControlY, size.width, kPageHeight);
    }

    // Update side button position
    if (self.sideButton) {
        CGFloat sideButtonX = size.width * 0.04; // 4% of screen width
        CGFloat sideButtonY = size.height * 0.06; // Align with page control
        self.sideButton.frame = CGRectMake(sideButtonX, sideButtonY, 30, 30);
    }

    // Re-layout all subviews
    [self viewDidLayoutSubviews];
}
#endif

- (void)viewDidLayoutSubviews
{
#if TARGET_OS_VISION
    // Dynamic layout on Vision Pro
    [self layoutForVisionPro];
#else
    // Fixed layout on iOS
    [self layoutForIOS];
#endif
}

#if TARGET_OS_VISION
- (void)layoutForVisionPro {
    // Vision Pro optimization: dynamically calculate layout parameters
    CGSize screenSize = self.view.bounds.size;
    CGFloat screenRatio = screenSize.width / screenSize.height;

    // Dynamically adjust background height
    if (screenRatio > 1.5) {
        // Wide screen mode
        _bg_height = screenSize.height * 0.55; // Reduce background height to leave more space for buttons
    } else if (screenRatio < 1.0) {
        // Portrait mode
        _bg_height = screenSize.height * 0.65;
    } else {
        // Standard mode
        _bg_height = screenSize.height * 0.6;
    }

    // Dynamically adjust page control position
    CGFloat pageControlY = screenSize.height * 0.06; // 6% of screen height
    self.pageControl.frame = CGRectMake(0, pageControlY, screenSize.width, kPageHeight);

    // Dynamically adjust side button position
    CGFloat sideButtonX = screenSize.width * 0.04; // 4% of screen width
    CGFloat sideButtonY = pageControlY;
    self.sideButton.frame = CGRectMake(sideButtonX, sideButtonY, 30, 30);

    // Dynamically adjust button width
    CGFloat buttonWidth = MIN(screenSize.width * 0.35, 400); // Max width 400
    CGFloat buttonMargin = (screenSize.width - buttonWidth) / 2;

    // Apply layout
    [self applyVisionProLayout:screenSize buttonWidth:buttonWidth buttonMargin:buttonMargin];
}

- (void)applyVisionProLayout:(CGSize)screenSize buttonWidth:(CGFloat)buttonWidth buttonMargin:(CGFloat)buttonMargin {
    self.bgImageView.frame = CGRectMake(0, 0, screenSize.width, _bg_height);

    self.scrollView.frame = CGRectMake(0, 0, screenSize.width, Height(self.bgImageView));
    self.scrollView.contentSize = CGSizeMake(screenSize.width * self.pageControl.numberOfPages, Width(self.scrollView));

    [self updateFirstViewFrame];
    [self updateSecondViewFrame];
    [self updateThirdViewFrame];
    [self updateForthViewFrame];
    [self updateFifthViewFrame];
    [self updateSixthViewFrame];

    UIImage *coverImage = [UIImage imageNamed:@"cover_bg"];
    self.coverImageView.frame = CGRectMake(0, Height(self.bgImageView) - screenSize.width * coverImage.size.height/coverImage.size.width, screenSize.width, screenSize.width * coverImage.size.height/coverImage.size.width);

    self.buttonView.frame = CGRectMake(0, _bg_height, screenSize.width, screenSize.height - _bg_height);

    // Vision Pro optimization: ensure buttons have sufficient vertical space
    CGFloat availableHeight = screenSize.height - _bg_height;
            CGFloat buttonSpacing = 20; // Button spacing
    CGFloat totalButtonHeight = Button_Hight * 2 + buttonSpacing;
    CGFloat button_y = _bg_height + (availableHeight - totalButtonHeight) / 2;

    self.createButton.frame = CGRectMake(buttonMargin, button_y, buttonWidth, Button_Hight);
    self.joinButtin.frame = CGRectMake(buttonMargin, MaxY(self.createButton) + buttonSpacing, buttonWidth, Button_Hight);
}
#endif

- (void)layoutForIOS {
    self.pageControl.frame = CGRectMake(0, Top_Space_Hight, self.view.bounds.size.width, kPageHeight);

    _bg_height = 465 * self.view.bounds.size.height/590; // size from design

    self.bgImageView.frame = CGRectMake(0, 0, self.view.bounds.size.width, _bg_height);

    self.scrollView.frame = CGRectMake(0, 0, self.view.bounds.size.width, Height(self.bgImageView));
    self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width*self.pageControl.numberOfPages, Width(self.scrollView));

    [self updateFirstViewFrame];
    [self updateSecondViewFrame];
    [self updateThirdViewFrame];
    [self updateForthViewFrame];
    [self updateFifthViewFrame];
    [self updateSixthViewFrame];

    UIImage *coverImage = [UIImage imageNamed:@"cover_bg"];
    self.coverImageView.frame = CGRectMake(0, Height(self.bgImageView)-self.view.bounds.size.width * coverImage.size.height/coverImage.size.width, self.view.bounds.size.width, self.view.bounds.size.width * coverImage.size.height/coverImage.size.width);

    self.sideButton.frame = CGRectMake(15, Top_Space_Hight, 30, 30);

    self.buttonView.frame = CGRectMake(0, _bg_height, self.view.bounds.size.width, self.view.bounds.size.height-_bg_height);
    float button_y = Height(self.firstView) + (self.view.bounds.size.height - _bg_height - Button_Hight*2 -15)/2;
    self.createButton.frame = CGRectMake(40, button_y, self.view.bounds.size.width-80, Button_Hight);
    self.joinButtin.frame = CGRectMake(40, MaxY(self.createButton)+15, self.view.bounds.size.width-80, Button_Hight);
}

- (void)updateFirstViewFrame
{
    UIImageView *imgView = [self.firstView viewWithTag:kTagImgView];
#if TARGET_OS_VISION
    // Vision Pro optimization: better view positioning
            CGFloat topOffset = 60; // Leave space for page control and side button
    self.firstView.frame = CGRectMake(0, topOffset, self.view.bounds.size.width, _bg_height - topOffset);
#else
    if (IPHONE_X) {
        self.firstView.frame = CGRectMake(0, 30, self.view.bounds.size.width, _bg_height);
    } else {
        self.firstView.frame = CGRectMake(0, 0, self.view.bounds.size.width, _bg_height);
    }
#endif

    imgView.frame = CGRectMake(0, [self imageViewYOffset], self.view.bounds.size.width, _bg_height);
}

- (void)updateSecondViewFrame
{
    CGRect viewFrame = CGRectOffset(self.firstView.frame, self.firstView.frame.size.width, 0);
    self.secondView.frame = viewFrame;

    UIImageView *imgView = [self.secondView viewWithTag:kTagImgView];
    imgView.frame = CGRectMake(0, [self imageViewYOffset], self.view.bounds.size.width, _bg_height);
}

- (void)updateThirdViewFrame
{
    CGRect viewFrame = CGRectOffset(self.secondView.frame, self.secondView.frame.size.width, 0);
    self.thirdView.frame = viewFrame;

    UIImageView *imgView = [self.thirdView viewWithTag:kTagImgView];
    imgView.frame = CGRectMake(0, [self imageViewYOffset], self.view.bounds.size.width, _bg_height);
}

- (void)updateForthViewFrame
{
    CGRect viewFrame = CGRectOffset(self.thirdView.frame, self.thirdView.frame.size.width, 0);
    self.forthView.frame = viewFrame;

    UIImageView *imgView = [self.forthView viewWithTag:kTagImgView];
    imgView.frame = CGRectMake(0, [self imageViewYOffset], self.view.bounds.size.width, _bg_height);
}

- (void)updateFifthViewFrame
{
    CGRect viewFrame = CGRectOffset(self.forthView.frame, self.forthView.frame.size.width, 0);
    self.fifthView.frame = viewFrame;

    UIImageView *imgView = [self.fifthView viewWithTag:kTagImgView];
    imgView.frame = CGRectMake(0, [self imageViewYOffset], self.view.bounds.size.width, _bg_height);
}

- (void)updateSixthViewFrame
{
    CGRect viewFrame = CGRectOffset(self.fifthView.frame, self.fifthView.frame.size.width, 0);
    self.sixthView.frame = viewFrame;

    UIImageView *imgView = [self.sixthView viewWithTag:kTagImgView];
    imgView.frame = CGRectMake(0, [self imageViewYOffset], self.view.bounds.size.width, _bg_height);
}

//- (void)updateSeventhViewFrame
//{
//    CGRect viewFrame = CGRectOffset(self.sixthView.frame, self.sixthView.frame.size.width, 0);
//    self.seventhView.frame = viewFrame;
//
//    UIImageView *imgView = [self.seventhView viewWithTag:kTagImgView];
//    imgView.frame = CGRectMake(0, MaxY(self.pageControl)+20, self.view.bounds.size.width, _bg_height);
//}

- (UIView*)buttonView
{
    if (!_buttonView)
    {
        _buttonView = [[UIView alloc] initWithFrame:CGRectZero];
        _buttonView.backgroundColor = [UIColor whiteColor];
    }
    return _buttonView;
}


- (UIButton*)createButton
{
    if (!_createButton)
    {
        _createButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [_createButton setBackgroundColor:RGBCOLOR(0x0E, 0x71, 0xEB)];
        [_createButton setTitle:@"Create" forState:UIControlStateNormal];
#if TARGET_OS_VISION
        _createButton.titleLabel.font = [UIFont boldSystemFontOfSize:24];
#else
        _createButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
#endif
        [_createButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_createButton addTarget:self action:@selector(onCreateClicked:) forControlEvents:UIControlEventTouchUpInside];
        _createButton.layer.cornerRadius = 10;
        _createButton.clipsToBounds = YES;
    }

    return _createButton;
}

- (UIImageView *)bgImageView
{
    if (!_bgImageView)
    {
        _bgImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _bgImageView.image = [UIImage imageNamed:@"intro_bg"];
        _bgImageView.contentMode = UIViewContentModeScaleAspectFill;
    }

    return _bgImageView;
}

- (UIImageView *)coverImageView
{
    if (!_coverImageView)
    {
        _coverImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _coverImageView.image = [UIImage imageNamed:@"cover_bg"];
    }

    return _coverImageView;
}

- (UIButton*)joinButtin
{
    if (!_joinButtin)
    {
        _joinButtin = [[UIButton alloc] initWithFrame:CGRectZero];
        [_joinButtin setTitle:@"Join" forState:UIControlStateNormal];
#if TARGET_OS_VISION
        _joinButtin.titleLabel.font = [UIFont boldSystemFontOfSize:24];
#else
        _joinButtin.titleLabel.font = [UIFont boldSystemFontOfSize:16];
#endif
        [_joinButtin setTitleColor:RGBCOLOR(0x0E, 0x72, 0xED) forState:UIControlStateNormal];
        [_joinButtin addTarget:self action:@selector(onJoinClicked:) forControlEvents:UIControlEventTouchUpInside];
        _joinButtin.layer.cornerRadius = 10;
        _joinButtin.clipsToBounds = YES;
    }

    return _joinButtin;
}

- (UIButton*)sideButton
{
    if (!_sideButton)
    {
        _sideButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [_sideButton setBackgroundImage:[UIImage imageNamed:@"side_btn_bg"] forState:UIControlStateNormal];
        [_sideButton addTarget:self action:@selector(onSideClicked:) forControlEvents:UIControlEventTouchUpInside];
    }

    return _sideButton;
}

- (UIScrollView*)scrollView
{
    if (!_scrollView)
    {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
        _scrollView.delegate = self;
        _scrollView.pagingEnabled = YES;
        _scrollView.showsVerticalScrollIndicator = NO;

        //This is the starting point of the ScrollView
        CGPoint scrollPoint = CGPointMake(0, 0);
        [_scrollView setContentOffset:scrollPoint animated:YES];
    }

    return _scrollView;
}

- (UIPageControl*)pageControl
{
    if (!_pageControl)
    {
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectZero];
        _pageControl.userInteractionEnabled = NO;
        _pageControl.currentPageIndicatorTintColor = [UIColor colorWithWhite:1 alpha:1];
        _pageControl.pageIndicatorTintColor = [UIColor colorWithWhite:1 alpha:0.5];
        _pageControl.numberOfPages = 6;
    }

    return _pageControl;
}

- (UIView*)firstView
{
    if (!_firstView)
    {
        _firstView = [[UIView alloc] initWithFrame:CGRectZero];

        UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectZero];
        imageview.tag = kTagImgView;
        imageview.clipsToBounds = YES;
        imageview.contentMode = UIViewContentModeTop;
        imageview.image = [UIImage imageNamed:@"intro_bg_1"];
        [_firstView addSubview:imageview];
    }

    return _firstView;
}

- (UIView*)secondView
{
    if (!_secondView)
    {
        _secondView = [[UIView alloc] initWithFrame:CGRectZero];

        UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectZero];
        imageview.tag = kTagImgView;
        imageview.clipsToBounds = YES;
        imageview.contentMode = UIViewContentModeTop;
        imageview.image = [UIImage imageNamed:@"intro_bg_2"];
        [_secondView addSubview:imageview];
     }

    return _secondView;
}

- (UIView*)thirdView
{
    if (!_thirdView)
    {
        _thirdView = [[UIView alloc] initWithFrame:CGRectZero];

        UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectZero];
        imageview.tag = kTagImgView;
        imageview.clipsToBounds = YES;
        imageview.contentMode = UIViewContentModeTop;
        imageview.image = [UIImage imageNamed:@"intro_bg_3"];
        [_thirdView addSubview:imageview];
    }

    return _thirdView;
}

- (UIView*)forthView
{
    if (!_forthView)
    {
        _forthView = [[UIView alloc] initWithFrame:CGRectZero];

        UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectZero];
        imageview.tag = kTagImgView;
        imageview.clipsToBounds = YES;
        imageview.contentMode = UIViewContentModeTop;
        imageview.image = [UIImage imageNamed:@"intro_bg_4"];
        [_forthView addSubview:imageview];
    }

    return _forthView;
}


- (UIView*)fifthView
{
    if (!_fifthView)
    {
        _fifthView = [[UIView alloc] initWithFrame:CGRectZero];

        UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectZero];
        imageview.tag = kTagImgView;
        imageview.clipsToBounds = YES;
        imageview.contentMode = UIViewContentModeTop;
        imageview.image = [UIImage imageNamed:@"intro_bg_5"];
        [_fifthView addSubview:imageview];
    }

    return _fifthView;
}

- (UIView*)sixthView
{
    if (!_sixthView)
    {
        _sixthView = [[UIView alloc] initWithFrame:CGRectZero];

        UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectZero];
        imageview.tag = kTagImgView;
        imageview.clipsToBounds = YES;
        imageview.contentMode = UIViewContentModeTop;
        imageview.image = [UIImage imageNamed:@"intro_bg_6"];
        [_sixthView addSubview:imageview];
    }

    return _sixthView;
}

//- (UIView*)seventhView
//{
//    if (!_seventhView)
//    {
//        _seventhView = [[UIView alloc] initWithFrame:CGRectZero];
//
//        UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectZero];
//        imageview.tag = kTagImgView;
//        imageview.clipsToBounds = YES;
//        imageview.contentMode = UIViewContentModeTop;
//        imageview.image = [UIImage imageNamed:@"intro_bg_7"];
//        [_seventhView addSubview:imageview];
//    }
//
//    return _seventhView;
//}


- (void)onCreateClicked:(UIButton *)sender {
    CreateViewController *vc = [[CreateViewController alloc] init];
    vc.type = ZoomVideoCreateJoinType_Create;

    MainViewController *mainViewController = (MainViewController *)self.sideMenuController;
    UINavigationController *navigationController = (UINavigationController *)mainViewController.rootViewController;
    [navigationController pushViewController:vc animated:YES];
}

- (void)onJoinClicked:(UIButton *)sender {
    CreateViewController *vc = [[CreateViewController alloc] init];
    vc.type = ZoomVideoCreateJoinType_Join;

    MainViewController *mainViewController = (MainViewController *)self.sideMenuController;
    UINavigationController *navigationController = (UINavigationController *)mainViewController.rootViewController;
    [navigationController pushViewController:vc animated:YES];
}

- (void)onSideClicked:(UIButton *)sender
{
    [self.sideMenuController showLeftViewAnimated:YES completionHandler:nil];
}

#pragma mark - ScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = CGRectGetWidth(self.view.bounds);
    CGFloat pageFraction = self.scrollView.contentOffset.x / pageWidth;
    self.pageControl.currentPage = roundf(pageFraction);
}

@end
