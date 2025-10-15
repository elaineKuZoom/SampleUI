//
//  CameraControlView.h
//  ZoomVideoSample
//
//  Created by Zoom on 2023/11/1.
//  Copyright © 2023 Zoom. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CameraControlViewDelegate <NSObject>
- (void)closeCameraControlView;
@end

@interface CameraControlView : UIView
@property (nonatomic,assign) id<CameraControlViewDelegate> delegate;
@property (nonatomic, strong) ZoomVideoSDKRemoteCameraControlHelper *cameraControlHelper;
@end

