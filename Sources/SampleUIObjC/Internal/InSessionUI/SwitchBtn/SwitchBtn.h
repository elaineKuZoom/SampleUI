//
//  SiwtchBtn.h
//  ZoomVideoSample
//
//  Created by Zoom Communications on 2020/7/16.
//  Copyright © 2020 Zoom. All rights reserved.
//

#import <UIKit/UIKit.h>
@import ZoomVideoSDK;

@interface SwitchBtn : UIButton
@property (nonatomic, strong, nullable) ZoomVideoSDKUser *sharedUser;

@end

