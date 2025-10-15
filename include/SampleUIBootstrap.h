
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface SampleUIBootstrap : NSObject

/// Call at app launch (was initZoomSDK in your AppDelegate).
+ (void)configureWithDomain:(NSString *)domain
                 appGroupId:(nullable NSString *)appGroupId
                  enableLog:(BOOL)enableLog;

/// Create the root UI your sample shows (Intro inside BaseNavigationController).
+ (UIViewController *)makeRootViewController;

/// Forward app termination/cleanup.
+ (void)cleanup;

/// (Optional) Your topVC helper moved into the package.
+ (UIViewController *)topViewControllerAllowingRotation:(BOOL)allow;

@end
NS_ASSUME_NONNULL_END
