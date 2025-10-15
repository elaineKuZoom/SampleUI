//
//  UISceneOrientationHelper.h
//  ZoomVideoSample
//
//  Created for Vision Pro compatibility
//  Copyright © 2024 Zoom Video Communications, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UISceneOrientationHelper : NSObject

// Get current interface orientation
+ (UIInterfaceOrientation)currentInterfaceOrientation;

// Get current device orientation
+ (UIDeviceOrientation)currentDeviceOrientation;

// Get current key window (Vision Pro compatible)
+ (UIWindow *)currentKeyWindow;

// Get current window scene
+ (UIWindowScene *)currentWindowScene;

// Check if device supports orientation changes
+ (BOOL)supportsOrientationChanges;

// Get supported interface orientations for current device
+ (UIInterfaceOrientationMask)supportedInterfaceOrientations;

// Orientation change observer methods
+ (void)addOrientationChangeObserver:(id)observer selector:(SEL)selector;
+ (void)removeOrientationChangeObserver:(id)observer;

@end

NS_ASSUME_NONNULL_END
