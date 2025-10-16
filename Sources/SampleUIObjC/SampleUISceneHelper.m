#import "SampleUISceneHelper.h"
#import "BaseNavigationController.h"
#import "PreSessionUI/IntroViewController.h"
#import "UISceneOrientationHelper.h"
#import "PreSessionUI/MainViewController.h"

@implementation SampleUISceneHelper

+ (UIInterfaceOrientationMask)supportedOrientationsAllowingRotation:(BOOL)canRotate {
    return canRotate
        ? (UIInterfaceOrientationMaskPortrait |
           UIInterfaceOrientationMaskLandscapeLeft |
           UIInterfaceOrientationMaskLandscapeRight)
        : UIInterfaceOrientationMaskPortrait;
}

#pragma mark - Window / VC discovery

+ (UIWindow *)currentWindow {
    UIWindow *keyWindow = nil;
    if (@available(iOS 13.0, *)) {
        for (UIWindowScene *scene in UIApplication.sharedApplication.connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive) {
                for (UIWindow *w in scene.windows) {
                    if (w.isKeyWindow) { keyWindow = w; break; }
                }
                if (!keyWindow) keyWindow = scene.windows.firstObject;
                if (keyWindow) break;
            }
        }
    } else {
        keyWindow = UIApplication.sharedApplication.keyWindow;
    }
    return keyWindow;
}

+ (UIViewController *)topViewController {
    UIWindow *window = [self currentWindow];
    UIViewController *root = window.rootViewController;
    return [self topFrom:root];
}

+ (UIViewController *)topFrom:(UIViewController *)vc {
    if (!vc) return nil;
    if ([vc isKindOfClass:UINavigationController.class]) {
        return [self topFrom:((UINavigationController *)vc).topViewController];
    } else if ([vc isKindOfClass:UITabBarController.class]) {
        return [self topFrom:((UITabBarController *)vc).selectedViewController];
    } else if (vc.presentedViewController) {
        return [self topFrom:vc.presentedViewController];
    }
    return vc;
}

+ (UIViewController *)mainContainerController {
    // If you ever embed a side menu container, detect it here.
    Class mainClass = NSClassFromString(@"MainViewController");
    UIViewController *vc = [self topViewController];
    for (UIViewController *p = vc; p; p = p.parentViewController) {
        if (mainClass && [p isKindOfClass:mainClass]) return p;
    }
    // Fall back to the window root (works for SwiftUI host that embeds a nav controller)
    return [self currentWindow].rootViewController;
}

#pragma mark - Window sizing (visionOS)

+ (void)optimizeWindowSizeIfNeeded:(UIWindow *)windowOrNil {
#if TARGET_OS_VISION
    UIWindow *window = windowOrNil ?: [self currentWindow];
    if (!window) return;

    CGSize screenSize = UIScreen.mainScreen.bounds.size;
    CGFloat w = MIN(screenSize.width * 0.8, 1536);
    CGFloat h = MIN(screenSize.height * 0.8, 960);
    w = MAX(w, 800); h = MAX(h, 600);

    CGRect newFrame = CGRectMake(0, 0, w, h);
    if (!CGRectEqualToRect(window.frame, newFrame)) {
        window.frame = newFrame;
        [self notifyRootIfMainViewController:window newSize:newFrame.size];
    }
#else
    (void)windowOrNil; // no-op on iOS
#endif
}

+ (void)setWindow:(UIWindow *)window toSize:(CGSize)size {
#if TARGET_OS_VISION
    window.frame = (CGRect){ .origin = CGPointZero, .size = size };
    [self notifyRootIfMainViewController:window newSize:size];
#else
    (void)window; (void)size;
#endif
}

+ (void)notifyRootIfMainViewController:(UIWindow *)window newSize:(CGSize)size {
    if (!window) return;
    // Walk down to find a MainViewController even if it is not the root
    UIViewController *candidate = window.rootViewController;
    Class mainClass = NSClassFromString(@"MainViewController");

    // BFS down the tree to locate MainViewController
    NSMutableArray<UIViewController *> *queue = [NSMutableArray array];
    if (candidate) [queue addObject:candidate];
    while (queue.count) {
        UIViewController *vc = queue.firstObject;
        [queue removeObjectAtIndex:0];

        if (mainClass && [vc isKindOfClass:mainClass]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            if ([vc respondsToSelector:@selector(windowSizeDidChange:)]) {
                [vc performSelector:@selector(windowSizeDidChange:)
                         withObject:[NSValue valueWithCGSize:size]];
            }
#pragma clang diagnostic pop
            return;
        }
        // enqueue children
        for (UIViewController *child in vc.childViewControllers) {
            [queue addObject:child];
        }
        if (vc.presentedViewController) [queue addObject:vc.presentedViewController];
        if ([vc isKindOfClass:UINavigationController.class]) {
            UIViewController *top = ((UINavigationController *)vc).topViewController;
            if (top) [queue addObject:top];
        }
        if ([vc isKindOfClass:UITabBarController.class]) {
            UIViewController *sel = ((UITabBarController *)vc).selectedViewController;
            if (sel) [queue addObject:sel];
        }
    }
}

@end
