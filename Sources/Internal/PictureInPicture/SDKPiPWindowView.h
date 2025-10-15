//
//  SDKPiPWindowView.h
//  MobileRTCSample
//
//  Created by Zoom on 2023/7/11.
//  Copyright © Zoom Communications, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ZoomVideoSDK/ZoomVideoSDK.h>
#import "CanvasViewController.h"

@interface SDKPiPWindowView : UIView

@property (nonatomic, strong) UIView *activeVideo;

- (void)startShowActive:(ZoomVideoSDKUser *)user videoType:(ZoomVideoSDKVideoType)type;
- (void)stopShowActive;

@end
