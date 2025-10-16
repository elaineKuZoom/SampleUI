//
//  Header.h
//  SampleUI
//
//  Created by Elaine Ku on 10/15/25.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface SampleUISceneHelper : NSObject
+ (UIInterfaceOrientationMask)supportedOrientationsAllowingRotation:(BOOL)canRotate;

// Vision Pro window helpers (no-ops on iPhone/iPad)
+ (void)optimizeWindowSizeIfNeeded:(UIWindow *)window;
+ (void)setWindow:(UIWindow *)window toSize:(CGSize)size;
+ (void)notifyRootIfMainViewController:(UIWindow *)window newSize:(CGSize)size;
@end

NS_ASSUME_NONNULL_END
