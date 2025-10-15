//
//  CameraControlView.m
//  ZoomVideoSample
//
//  Created by Zoom on 2023/11/1.
//  Copyright © 2023 Zoom. All rights reserved.
//

#import "CameraControlView.h"

#define kUpTag        1001
#define kDownTag      1002
#define kLeftTag      1003
#define kRightTag     1004

#define kZoomOutTag   1005
#define kZoomInTag    1006
#define kCloseTag     1007

@interface CameraControlView ()

@property (assign, nonatomic) BOOL isCameraControl;
@end

@implementation CameraControlView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubView];
    }
    return self;
}

- (void)initSubView
{
    self.backgroundColor = RGBCOLOR(0x1A, 0x1A, 0x1A);
    self.layer.cornerRadius = 10;
    
    float right_button_width = 80.f;
    
    UIImageView *rightBGView = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width-10-right_button_width, 10, right_button_width, right_button_width)];
    rightBGView.userInteractionEnabled = YES;
    rightBGView.image = [UIImage imageNamed:@"camera_control_right_bg"];
    [self addSubview:rightBGView];
    
    UIImageView *rightButtonBGView = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width-10-right_button_width, 10, right_button_width, right_button_width)];
    rightButtonBGView.userInteractionEnabled = YES;
    rightButtonBGView.image = [UIImage imageNamed:@"camera_control_right_button_bg"];
    
    [self addSubview:rightButtonBGView];
    
    UIButton *upBtn = [[UIButton alloc] initWithFrame:CGRectMake(right_button_width/3, 0, right_button_width/3, right_button_width/3)];
    [upBtn setBackgroundImage:[UIImage imageNamed:@"camera_control_up_button"] forState:UIControlStateNormal];
    [upBtn addTarget:self action:@selector(onCameraButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    upBtn.tag = kUpTag;
    [rightButtonBGView addSubview:upBtn];
    
    UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(right_button_width - right_button_width/3, right_button_width/3, right_button_width/3, right_button_width/3)];
    [rightBtn setBackgroundImage:[UIImage imageNamed:@"camera_control_right_button"] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(onCameraButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    rightBtn.tag = kRightTag;
    [rightButtonBGView addSubview:rightBtn];
    
    UIButton *downBtn = [[UIButton alloc] initWithFrame:CGRectMake(right_button_width/3, right_button_width*2/3, right_button_width/3, right_button_width/3)];
    [downBtn setBackgroundImage:[UIImage imageNamed:@"camera_control_down_button"] forState:UIControlStateNormal];
    [downBtn addTarget:self action:@selector(onCameraButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    downBtn.tag = kDownTag;
    [rightButtonBGView addSubview:downBtn];
    
    UIButton *leftBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, right_button_width/3, right_button_width/3, right_button_width/3)];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"camera_control_left_button"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(onCameraButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    leftBtn.tag = kLeftTag;
    [rightButtonBGView addSubview:leftBtn];
    
    
    UIButton *closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 160-30-right_button_width, right_button_width/3)];
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"camera_control_close_button"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(onCameraButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    closeBtn.tag = kCloseTag;
    [self addSubview:closeBtn];
    
    UIButton *zoomOutBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(closeBtn.frame)+right_button_width/3, closeBtn.frame.size.width/2, right_button_width/3)];
    [zoomOutBtn setBackgroundImage:[UIImage imageNamed:@"camera_control_zoomout_button"] forState:UIControlStateNormal];
    [zoomOutBtn addTarget:self action:@selector(onCameraButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    zoomOutBtn.tag = kZoomOutTag;
    [self addSubview:zoomOutBtn];
    
    UIButton *zoomInBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(zoomOutBtn.frame), zoomOutBtn.frame.origin.y, closeBtn.frame.size.width/2, right_button_width/3)];
    [zoomInBtn setBackgroundImage:[UIImage imageNamed:@"camera_control_zoomin_button"] forState:UIControlStateNormal];
    [zoomInBtn addTarget:self action:@selector(onCameraButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    zoomInBtn.tag = kZoomInTag;
    [self addSubview:zoomInBtn];
}

- (void)onCameraButtonClicked:(UIButton *)sender
{
    switch (sender.tag) {
        case kUpTag:
        {
            ZoomVideoSDKError ret = [self.cameraControlHelper turnUp:100];
            NSLog(@"turnUp  ===> %@",@(ret));
            break;
        }
        case kDownTag:
        {
            ZoomVideoSDKError ret = [self.cameraControlHelper turnDown:100];
            NSLog(@"turnDown  ===> %@",@(ret));
            break;
        }
        case kLeftTag:
        {
            ZoomVideoSDKError ret = [self.cameraControlHelper turnLeft:100];
            NSLog(@"turnLeft  ===> %@",@(ret));
            break;
        }
        case kRightTag:
        {
            ZoomVideoSDKError ret = [self.cameraControlHelper turnRight:100];
            NSLog(@"turnRight  ===> %@",@(ret));
            break;
        }
        case kZoomOutTag:
        {
            ZoomVideoSDKError ret = [self.cameraControlHelper zoomOut:50];
            NSLog(@"zoomOut  ===> %@",@(ret));
            break;
        }
        case kZoomInTag:
        {
            ZoomVideoSDKError ret = [self.cameraControlHelper zoomIn:50];
            NSLog(@"zoomIn  ===> %@",@(ret));
            break;
        }
        case kCloseTag:
        {
            if ([self.delegate respondsToSelector:@selector(closeCameraControlView)]) {
                [self.delegate closeCameraControlView];
            }
            break;
        }
        default:
            break;
    }
}

@end
