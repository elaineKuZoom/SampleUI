//
//  UISceneOrientationHelper.m
//  ZoomVideoSample
//
//  Created for Vision Pro compatibility
//  Copyright © 2024 Zoom Video Communications, Inc. All rights reserved.
//

#import "UISceneOrientationHelper.h"

@implementation UISceneOrientationHelper

+ (UIInterfaceOrientation)currentInterfaceOrientation {
#if TARGET_OS_VISION
    // Vision Pro: statusBarOrientation not available, use default orientation
    return UIInterfaceOrientationPortrait;
#else
    if (@available(iOS 13.0, *)) {
        return [UIApplication sharedApplication].statusBarOrientation;
    } else {
        return UIInterfaceOrientationPortrait;
    }
#endif
}

+ (UIDeviceOrientation)currentDeviceOrientation {
#if TARGET_OS_VISION
    // Vision Pro: UIDevice orientation not available, use default orientation
    return UIDeviceOrientationPortrait;
#else
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    
    // Check if orientation is valid
    if (orientation == UIDeviceOrientationUnknown ||
        orientation == UIDeviceOrientationFaceUp ||
        (orientation == UIDeviceOrientationFaceDown)) {
        if (@available(iOS 13.0, *)) {
            return (UIDeviceOrientation)[UIApplication sharedApplication].statusBarOrientation;
        } else {
            return UIDeviceOrientationPortrait;
        }
    }
    
    return orientation;
#endif
}

+ (UIWindow *)currentKeyWindow {
#if TARGET_OS_VISION
    // Vision Pro: keyWindow not available, use first window from active scene
    UIWindowScene *windowScene = [self currentWindowScene];
    if (windowScene && windowScene.activationState == UISceneActivationStateForegroundActive) {
        for (UIWindow *window in windowScene.windows) {
            // Vision Pro: keyWindow not available, use first window
            if (window == windowScene.windows.firstObject) {
                return window;
            }
        }
    }
    return nil;
#else
    if (@available(iOS 13.0, *)) {
        UIWindowScene *windowScene = [self currentWindowScene];
        if (windowScene) {
            return windowScene.keyWindow;
        }
    }
    return [UIApplication sharedApplication].keyWindow;
#endif
}

+ (UIWindowScene *)currentWindowScene {
    if (@available(iOS 13.0, *)) {
        for (UIWindowScene *windowScene in [UIApplication sharedApplication].connectedScenes) {
            if (windowScene.activationState == UISceneActivationStateForegroundActive) {
                for (UIWindow* window in windowScene.windows) {
                    // Vision Pro: keyWindow not available, use first window
                    if (window == windowScene.windows.firstObject) {
                        return windowScene;
                    }
                }
            }
        }
    }
    return nil;
}

+ (BOOL)supportsOrientationChanges {
#if TARGET_OS_VISION
    // Vision Pro has limited orientation support
    return NO;
#else
    return YES;
#endif
}

+ (UIInterfaceOrientationMask)supportedInterfaceOrientations {
#if TARGET_OS_VISION
    // Vision Pro primarily supports portrait mode
    return UIInterfaceOrientationMaskPortrait;
#else
    // iOS devices support multiple orientations
    return (UIInterfaceOrientationMaskPortrait | 
            UIInterfaceOrientationMaskLandscapeLeft | 
            UIInterfaceOrientationMaskLandscapeRight);
#endif
}

#pragma mark - Orientation Change Observer Methods

+ (void)addOrientationChangeObserver:(id)observer selector:(SEL)selector {
#if TARGET_OS_VISION
    // Vision Pro: UIDeviceOrientationDidChangeNotification not available, use UIScene notification
    [[NSNotificationCenter defaultCenter] addObserver:observer 
                                             selector:selector 
                                                 name:UISceneDidActivateNotification 
                                               object:nil];
#else
    [[NSNotificationCenter defaultCenter] addObserver:observer 
                                             selector:selector 
                                                 name:UIDeviceOrientationDidChangeNotification 
                                               object:nil];
#endif
}

+ (void)removeOrientationChangeObserver:(id)observer {
#if TARGET_OS_VISION
    // Vision Pro: UIDeviceOrientationDidChangeNotification not available, use UIScene notification
    [[NSNotificationCenter defaultCenter] removeObserver:observer 
                                                    name:UISceneDidActivateNotification 
                                                  object:nil];
#else
    [[NSNotificationCenter defaultCenter] removeObserver:observer 
                                                    name:UIDeviceOrientationDidChangeNotification 
                                                  object:nil];
#endif
}

@end
