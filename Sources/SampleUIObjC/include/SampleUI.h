
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@import ZoomVideoSDK;

// Common macros
#define RGBCOLOR(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]

// Screen dimensions
#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height

// Device type detection
#define IPHONE_X ({\
    BOOL isPhoneX = NO;\
    if (@available(iOS 11.0, *)) {\
        UIWindow *window = [[UIApplication sharedApplication].windows firstObject];\
        if (window.safeAreaInsets.bottom > 0.0) {\
            isPhoneX = YES;\
        }\
    }\
    isPhoneX;\
})

// Safe area insets
#define SAFE_ZOOM_INSETS ({\
    CGFloat inset = 0.0;\
    if (@available(iOS 11.0, *)) {\
        UIWindow *window = [[UIApplication sharedApplication].windows firstObject];\
        inset = window.safeAreaInsets.left;\
    }\
    inset;\
})

// Status bar orientation helper
#define GET_STATUS_BAR_ORIENTATION() [UISceneOrientationHelper currentInterfaceOrientation]

FOUNDATION_EXPORT double SampleUIVersionNumber;
FOUNDATION_EXPORT const unsigned char SampleUIVersionString[];

#import "SampleUIBootstrap.h"
