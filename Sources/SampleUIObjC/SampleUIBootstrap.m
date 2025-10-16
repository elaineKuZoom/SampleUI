#import "SampleUIBootstrap.h"
#import "BaseNavigationController.h"
#import "PreSessionUI/IntroViewController.h"
#import "UISceneOrientationHelper.h"
#import "PreSessionUI/MainViewController.h"
@import ZoomVideoSDK; // or import via a public header that wraps it

@implementation SampleUIBootstrap

static NSString *_defaultAppToken = nil;

+ (void)setDefaultAppToken:(NSString *)token {
    _defaultAppToken = token;
}

+ (NSString *)defaultAppToken {
    return _defaultAppToken;
}

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
    // 1. Intro screen (pre-session)
    IntroViewController *intro = [IntroViewController new];

    // 2. Navigation container
    BaseNavigationController *nav =
        [[BaseNavigationController alloc] initWithRootViewController:intro];

    // 3. MainViewController = LGSideMenuController subclass
    MainViewController *mainViewController = [MainViewController new];
    mainViewController.rootViewController = nav;
    [mainViewController setupWithType];

    // ✅ Return full container (the same hierarchy as SceneDelegate)
    return mainViewController;
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
