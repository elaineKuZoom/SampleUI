//
//  SampleUISceneHelper.m
//  SampleUI
//
//  Created by Elaine Ku on 10/15/25.
//

#import "SampleUISceneHelper.h"
#import "BaseNavigationController.h"
#import "PreSessionUI/IntroViewController.h"
#import "UISceneOrientationHelper.h"
#import "PreSessionUI/MainViewController.h" // if you keep it internal

@implementation SampleUISceneHelper

+ (UIInterfaceOrientationMask)supportedOrientationsAllowingRotation:(BOOL)canRotate {
    return canRotate
      ? (UIInterfaceOrientationMaskPortrait |
         UIInterfaceOrientationMaskLandscapeLeft |
         UIInterfaceOrientationMaskLandscapeRight)
      : UIInterfaceOrientationMaskPortrait;
}

+ (void)optimizeWindowSizeIfNeeded:(UIWindow *)window {
#if TARGET_OS_VISION
    CGSize screenSize = UIScreen.mainScreen.bounds.size;
    CGFloat w = MIN(screenSize.width * 0.8, 1536);
    CGFloat h = MIN(screenSize.height * 0.8, 960);
    w = MAX(w, 800); h = MAX(h, 600);
    CGRect newFrame = CGRectMake(0, 0, w, h);
    if (!CGRectEqualToRect(window.frame, newFrame)) {
        window.frame = newFrame;
        [self notifyRootIfMainViewController:window newSize:newFrame.size];
    }
#endif
}

+ (void)setWindow:(UIWindow *)window toSize:(CGSize)size {
#if TARGET_OS_VISION
    window.frame = (CGRect){.origin = CGPointZero, .size = size};
    [self notifyRootIfMainViewController:window newSize:size];
#endif
}

+ (void)notifyRootIfMainViewController:(UIWindow *)window newSize:(CGSize)size {
    UIViewController *root = window.rootViewController;
    if ([root isKindOfClass:NSClassFromString(@"MainViewController")]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        if ([root respondsToSelector:@selector(windowSizeDidChange:)]) {
            [root performSelector:@selector(windowSizeDidChange:)
                       withObject:[NSValue valueWithCGSize:size]];
        }
#pragma clang diagnostic pop
    }
}
@end
