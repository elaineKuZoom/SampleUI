#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SampleUISceneHelper : NSObject

+ (UIInterfaceOrientationMask)supportedOrientationsAllowingRotation:(BOOL)canRotate;

// Window discovery (useful in SwiftUI hosts)
+ (nullable UIWindow *)currentWindow;
+ (nullable UIViewController *)topViewController;
+ (nullable UIViewController *)mainContainerController;

// Window sizing (visionOS-safe)
+ (void)optimizeWindowSizeIfNeeded:(nullable UIWindow *)window;
+ (void)setWindow:(UIWindow *)window toSize:(CGSize)size;

// Notify packaged root about size changes (safe walk)
+ (void)notifyRootIfMainViewController:(UIWindow *)window newSize:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
