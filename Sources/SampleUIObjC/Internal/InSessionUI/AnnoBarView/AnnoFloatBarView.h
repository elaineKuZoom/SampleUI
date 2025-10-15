//
//  AnnoFloatBarView.h
//  MobileRTCSample
//
//  Created by Zoom Communications on 2018/6/12.
//  Copyright © Zoom Communications, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@import ZoomVideoSDK;
#import "SampleUI.h"

@interface AnnoFloatBarView : UIView
- (instancetype)initWithAnnoHelper:(ZoomVideoSDKAnnotationHelper *)helper;
- (void)updateAnnoHelper:(ZoomVideoSDKAnnotationHelper *)annoHelper;
@end
