//
//  SceneDelegate.h
//  ZoomVideoSample
//
//  Created for Vision Pro compatibility
//  Copyright © 2024 Zoom Video Communications, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SceneDelegate : UIResponder <UIWindowSceneDelegate>

@property (strong, nonatomic) UIWindow * window;
@property (assign, nonatomic) BOOL canRotation;

// Vision Pro specific methods
#if TARGET_OS_VISION
- (void)optimizeVisionProWindowSize;
- (CGSize)calculateOptimalWindowSize;
- (void)setVisionProWindowSize:(CGSize)size;
#endif

// Helper methods
- (UIViewController *)topViewController;
- (UIViewController *)_topViewController:(UIViewController *)vc;

@end

NS_ASSUME_NONNULL_END
