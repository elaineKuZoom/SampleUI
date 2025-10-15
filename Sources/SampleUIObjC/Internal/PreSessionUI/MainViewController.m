//
//  MainViewController.m
//  ZoomVideoSample
//
//  Created by Zoom Communications on 2019/10/24.
//  Copyright © 2019 Zoom. All rights reserved.
//

#import "SampleUI.h"
#import "MainViewController.h"
#import "PreSessionUI/IntroViewController.h"
#import "PreSessionUI/LeftViewController.h"

@interface MainViewController ()

@property (assign, nonatomic) NSUInteger type;

@end

@implementation MainViewController

- (void)setupWithType {

    self.leftViewController = [LeftViewController new];

    self.leftViewWidth = self.view.bounds.size.width-100;
    self.leftViewBackgroundColor = [UIColor whiteColor];


    UIColor *greenCoverColor = [UIColor colorWithRed:0.0 green:0.1 blue:0.0 alpha:0.3];
    UIBlurEffectStyle regularStyle;

    if (UIDevice.currentDevice.systemVersion.floatValue >= 10.0) {
        regularStyle = UIBlurEffectStyleRegular;
    }
    else {
        regularStyle = UIBlurEffectStyleLight;
    }

    self.leftViewPresentationStyle = LGSideMenuPresentationStyleSlideAbove;
    self.rootViewCoverColorForLeftView = greenCoverColor;
}

- (void)leftViewWillLayoutSubviewsWithSize:(CGSize)size {
    [super leftViewWillLayoutSubviewsWithSize:size];

    if (!self.isLeftViewStatusBarHidden) {
        self.leftView.frame = CGRectMake(0.0, 20.0, size.width, size.height-20.0);
    }
}

- (void)rightViewWillLayoutSubviewsWithSize:(CGSize)size {
    [super rightViewWillLayoutSubviewsWithSize:size];

#if TARGET_OS_VISION
    // Vision Pro: UI_USER_INTERFACE_IDIOM not available, use default behavior
    if (!self.isRightViewStatusBarHidden) {
        self.rightView.frame = CGRectMake(0.0, 20.0, size.width, size.height-20.0);
    }
#else
    if (!self.isRightViewStatusBarHidden ||
        (self.rightViewAlwaysVisibleOptions & LGSideMenuAlwaysVisibleOnPadLandscape &&
         UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad &&
         UIInterfaceOrientationIsLandscape([UISceneOrientationHelper currentInterfaceOrientation]))) {
            self.rightView.frame = CGRectMake(0.0, 20.0, size.width, size.height-20.0);
        }
#endif
}

- (BOOL)isLeftViewStatusBarHidden {
    return super.isLeftViewStatusBarHidden;
}

- (BOOL)isRightViewStatusBarHidden {
    return super.isRightViewStatusBarHidden;
}

- (void)dealloc {
    NSLog(@"MainViewController deallocated");
}
@end
