//
//  SceneDelegate.m
//  ZoomVideoSample
//
//  Created for Vision Pro compatibility
//  Copyright © 2024 Zoom Video Communications, Inc. All rights reserved.
//

#import "SceneDelegate.h"
#import "MainViewController.h"
#import "UISceneOrientationHelper.h"
#import "IntroViewController.h"
#import "BaseNavigationController.h"

@implementation SceneDelegate

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    
    if ([scene isKindOfClass:[UIWindowScene class]]) {
        UIWindowScene *windowScene = (UIWindowScene *)scene;
        self.window = [[UIWindow alloc] initWithWindowScene:windowScene];
        
        IntroViewController *viewController = [IntroViewController new];
        BaseNavigationController *navigationController = [[BaseNavigationController alloc] initWithRootViewController:viewController];
        MainViewController *mainViewController = [MainViewController new];
        mainViewController.rootViewController = navigationController;
        [mainViewController setupWithType];
        
        self.window.rootViewController = mainViewController;
        [self.window makeKeyAndVisible];
        
#if TARGET_OS_VISION
        // Vision Pro optimization: monitor window size changes
        // Monitor window size changes
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(windowSceneDidChangeSize:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
        
        // Monitor window scene size changes
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(windowSceneSizeDidChange:)
                                                     name:UIWindowDidBecomeKeyNotification
                                                   object:windowScene];
#endif
    }
}

- (void)sceneDidDisconnect:(UIScene *)scene {
    // Called as the scene is being released by the system.
    // This occurs shortly after the scene enters the background, or when its session is discarded.
    // Release any resources associated with this scene that can be re-created the next time the scene connects.
    // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
}

- (void)sceneDidBecomeActive:(UIScene *)scene {
    // Called when the scene has moved from an inactive state to an active state.
    // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    
#if TARGET_OS_VISION
    // Vision Pro optimization: trigger window size optimization when scene becomes active
    [self optimizeVisionProWindowSize];
#endif
}

- (void)sceneWillResignActive:(UIScene *)scene {
    // Called when the scene will move from an active state to an inactive state.
    // This may occur due to temporary interruptions (ex. an incoming phone call).
    
#if TARGET_OS_VISION
    if ([scene isKindOfClass:[UIWindowScene class]]) {
        UIWindowScene *windowScene = (UIWindowScene *)scene;
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIApplicationDidBecomeActiveNotification
                                                      object:nil];
#if TARGET_OS_VISION
        // Vision Pro uses different notification names
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIWindowDidBecomeKeyNotification
                                                      object:windowScene];
#else
        // Use application state changes for iOS
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIApplicationDidBecomeActiveNotification
                                                      object:nil];
#endif
    }
#endif
}

- (void)sceneWillEnterForeground:(UIScene *)scene {
    // Called as the scene transitions from the background to the foreground.
    // Use this method to undo the changes made on entering the background.
}

- (void)sceneDidEnterBackground:(UIScene *)scene {
    // Called as the scene transitions from the foreground to the background.
    // Use this method to save data, release shared resources, and store enough scene-specific state information
    // to restore the scene back to its current state.
}

#pragma mark - Orientation Support

- (UIInterfaceOrientationMask)windowScene:(UIWindowScene *)windowScene supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    if (self.canRotation) {
        return (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight);
    }
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - Vision Pro Window Size Handling

#if TARGET_OS_VISION
- (void)optimizeVisionProWindowSize {
    // Vision Pro optimization: set more appropriate window size
    CGSize optimalSize = [self calculateOptimalWindowSize];
    CGRect newFrame = CGRectMake(0, 0, optimalSize.width, optimalSize.height);
    
    if (!CGRectEqualToRect(self.window.frame, newFrame)) {
        self.window.frame = newFrame;
        NSLog(@"Vision Pro window size optimized to: %@", NSStringFromCGRect(newFrame));
        
        // Notify MainViewController of window size change
        if ([self.window.rootViewController isKindOfClass:[MainViewController class]]) {
            MainViewController *mainVC = (MainViewController *)self.window.rootViewController;
            if ([mainVC respondsToSelector:@selector(windowSizeDidChange:)]) {
                [mainVC performSelector:@selector(windowSizeDidChange:) withObject:[NSValue valueWithCGSize:optimalSize]];
            }
        }
    }
}

- (CGSize)calculateOptimalWindowSize {
    // Vision Pro optimization: calculate optimal window size based on device characteristics
#if TARGET_OS_VISION
    CGSize screenSize = GET_SCREEN_BOUNDS().size;
#else
    CGSize screenSize = UIScreen.mainScreen.bounds.size;
#endif
    
    // Vision Pro recommended window size
    CGFloat width = MIN(screenSize.width * 0.8, 1536);  // Max width 1536
    CGFloat height = MIN(screenSize.height * 0.8, 960); // Max height 960
    
    // Ensure minimum size
    width = MAX(width, 800);
    height = MAX(height, 600);
    
    return CGSizeMake(width, height);
}

// Convenient method: set different window sizes
- (void)setVisionProWindowSize:(CGSize)size {
#if TARGET_OS_VISION
    CGRect newFrame = CGRectMake(0, 0, size.width, size.height);
    self.window.frame = newFrame;
    NSLog(@"Vision Pro window size set to: %@", NSStringFromCGSize(size));
    
    // Notify MainViewController
    if ([self.window.rootViewController isKindOfClass:[MainViewController class]]) {
        MainViewController *mainVC = (MainViewController *)self.window.rootViewController;
        if ([mainVC respondsToSelector:@selector(windowSizeDidChange:)]) {
            [mainVC performSelector:@selector(windowSizeDidChange:) withObject:[NSValue valueWithCGSize:size]];
        }
    }
#endif
}

- (void)windowSceneDidChangeSize:(NSNotification *)notification {
    // Vision Pro optimization: window size change handling
    dispatch_async(dispatch_get_main_queue(), ^{
        CGSize newSize = self.window.bounds.size;
        NSLog(@"Vision Pro window size changed to: %@", NSStringFromCGSize(newSize));
        
        // Notify MainViewController
        if ([self.window.rootViewController isKindOfClass:[MainViewController class]]) {
            MainViewController *mainVC = (MainViewController *)self.window.rootViewController;
            if ([mainVC respondsToSelector:@selector(windowSizeDidChange:)]) {
                [mainVC performSelector:@selector(windowSizeDidChange:) withObject:[NSValue valueWithCGSize:newSize]];
            }
        }
    });
}

- (void)windowSceneSizeDidChange:(NSNotification *)notification {
    // Vision Pro optimization: window scene size change handling
#if TARGET_OS_VISION
    // Vision Pro uses different handling approach
    UIWindow *window = notification.object;
    if (window && [window isKindOfClass:[UIWindow class]]) {
        CGSize newSize = window.bounds.size;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Vision Pro window size changed to: %@", NSStringFromCGSize(newSize));
            
            // Adjust window size
            [self setVisionProWindowSize:newSize];
        });
    }
#else
    // For iOS, use application state changes
    if (notification.object) {
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        if (keyWindow) {
            CGSize newSize = keyWindow.bounds.size;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"iOS window size changed to: %@", NSStringFromCGSize(newSize));
                
                // Adjust window size
                [self setVisionProWindowSize:newSize];
            });
        }
    }
#endif
}

#endif
- (void)applicationDidBecomeActive:(NSNotification *)notification {
    // Handle application becoming active
    CGSize newSize = self.window.bounds.size;
    NSLog(@"Application became active, window size: %@", NSStringFromCGSize(newSize));
    
    // Notify MainViewController
    if ([self.window.rootViewController isKindOfClass:[MainViewController class]]) {
        MainViewController *mainVC = (MainViewController *)self.window.rootViewController;
        if ([mainVC respondsToSelector:@selector(windowSizeDidChange:)]) {
            [mainVC performSelector:@selector(windowSizeDidChange:) withObject:[NSValue valueWithCGSize:newSize]];
        }
    }
}

#pragma mark - Helper Methods

- (UIViewController *)topViewController {
    UIViewController *resultVC;
    
    UIWindow *keyWindow = [UISceneOrientationHelper currentKeyWindow];
    resultVC = [self _topViewController:keyWindow.rootViewController];
    
    while (resultVC.presentedViewController) {
        resultVC = [self _topViewController:resultVC.presentedViewController];
    }
    return resultVC;
}

- (UIViewController *)_topViewController:(UIViewController *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self _topViewController:[(UINavigationController *)vc topViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self _topViewController:[(UITabBarController *)vc selectedViewController]];
    } else {
        return vc;
    }
}

@end
