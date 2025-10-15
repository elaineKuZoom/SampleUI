#import "SampleUIBootstrap.h"
#import "BaseNavigationController.h"
#import "IntroViewController.h"
#import "UISceneOrientationHelper.h"
@import ZoomVideoSDK; // or import via a public header that wraps it

@implementation SampleUIBootstrap

+ (void)configureWithDomain:(NSString *)domain
                 appGroupId:(NSString *)appGroupId
                  enableLog:(BOOL)enableLog
{
    ZoomVideoSDKInitParams *ctx = [ZoomVideoSDKInitParams new];
    ctx.domain = domain;
    ctx.appGroupId = appGroupId ?: @"";   // empty if you don’t need screen share
    ctx.enableLog = enableLog;
    ZoomVideoSDKError ret = [[ZoomVideoSDK shareInstance] initialize:ctx];
    NSLog(@"[ZoomVideoSDK] initialize => %@", ret == Errors_Success ? @"Success" : @(ret));

    NSString *ver = [[ZoomVideoSDK shareInstance] getSDKVersion];
    NSLog(@"[ZoomVideoSDK] version: %@", ver);
}

+ (UIViewController *)makeRootViewController
{
    UIViewController *intro = [IntroViewController new];
    BaseNavigationController *nav =
      [[BaseNavigationController alloc] initWithRootViewController:intro];
    return nav;
}

+ (void)cleanup
{
    ZoomVideoSDKError ret = [[ZoomVideoSDK shareInstance] cleanup];
    NSLog(@"[ZoomVideoSDK] cleanup => %@", ret == Errors_Success ? @"Success" : @(ret));
}

+ (UIViewController *)topViewControllerAllowingRotation:(BOOL)allow
{
    UIWindow *keyWindow = [UISceneOrientationHelper currentKeyWindow];
    UIViewController *vc = keyWindow.rootViewController;
    while (vc.presentedViewController) {
        vc = vc.presentedViewController;
        if ([vc isKindOfClass:UINavigationController.class]) {
            vc = ((UINavigationController *)vc).topViewController;
        } else if ([vc isKindOfClass:UITabBarController.class]) {
            vc = ((UITabBarController *)vc).selectedViewController;
        }
    }
    // if you still want to use allow to choose orientation, do it in host’s delegate
    return vc ?: keyWindow.rootViewController;
}

@end
