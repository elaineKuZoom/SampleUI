//
//  ControlBar.m
//  ZoomVideoSample
//
//  Created by Zoom Communications on 2019/5/27.
//  Copyright © 2019 Zoom. All rights reserved.
//

#import "ControlBar.h"
#import "TopBarView.h"
#import <AudioToolbox/AudioToolbox.h>
#import "MoreMenuViewController.h"
#import "KGModal.h"

#define COMPARE(FIRST,SECOND) (CFStringCompare(FIRST, SECOND, kCFCompareCaseInsensitive) == kCFCompareEqualTo)

@interface ControlBar ()
@property (strong, nonatomic) UIButton          *videoBtn;
@property (strong, nonatomic) UIButton          *moreBtn;

@property (nonatomic, assign) NSInteger         indexOfExternalVideoSource;
@end

@implementation ControlBar

- (id)init
{
    self = [super init];
    if (self) {
        _broadcastChannelIDs = [NSMutableArray array];
        [self initSubView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    UIInterfaceOrientation orientation = GET_STATUS_BAR_ORIENTATION();
    BOOL landscape = UIInterfaceOrientationIsLandscape(orientation);
    
    float button_width;
    if (landscape) {
        if (IS_IPAD) {
            button_width = 65.0;
        } else {
            if (SCREEN_HEIGHT <= 375.0) {
                button_width = 50;
            } else {
                button_width = 55;
            }
        }
    } else {
        button_width = 65;
    }
    
    ZoomVideoSDKUser *myUser = [[[ZoomVideoSDK shareInstance] getSession] getMySelf];
    _audioBtn.frame = CGRectMake(0, 0, button_width, button_width * ([UIImage imageNamed:@"icon_no_audio"].size.height/[UIImage imageNamed:@"icon_no_audio"].size.width));
    if (myUser.audioStatus.audioType == ZoomVideoSDKAudioType_None) {
        _audioBtn.frame = CGRectMake(0, 0, button_width, button_width * ([UIImage imageNamed:@"icon_no_audio"].size.height/[UIImage imageNamed:@"icon_no_audio"].size.width));
    } else {
        if (!myUser.audioStatus.isMuted) {
            [_audioBtn setImage:[UIImage imageNamed:@"icon_mute"] forState:UIControlStateNormal];
        } else {
            [_audioBtn setImage:[UIImage imageNamed:@"icon_unmute"] forState:UIControlStateNormal];
        }
    }
    
    _shareBtn.frame = CGRectMake(0, CGRectGetMaxY(_audioBtn.frame), button_width, button_width * ([UIImage imageNamed:@"icon_video_share"].size.height/[UIImage imageNamed:@"icon_video_share"].size.width));
    _videoBtn.frame = CGRectMake(0, CGRectGetMaxY(_shareBtn.frame), button_width, button_width * ([UIImage imageNamed:@"icon_video_on"].size.height/[UIImage imageNamed:@"icon_video_on"].size.width));
    _moreBtn.frame = CGRectMake(0, CGRectGetMaxY(_videoBtn.frame), button_width, button_width * ([UIImage imageNamed:@"icon_video_more"].size.height/[UIImage imageNamed:@"icon_video_more"].size.width));
    
    float controlBar_height = Height(_moreBtn)+Height(_videoBtn)+Height(_shareBtn)+Height(_audioBtn);
    
    float controlBar_x = SCREEN_WIDTH-button_width - 5;
    float controlBar_y;
    if (landscape) {
        if (orientation == UIInterfaceOrientationLandscapeLeft && IPHONE_X) {
            controlBar_x = SCREEN_WIDTH-button_width-SAFE_ZOOM_INSETS;
        } else {
            controlBar_x = SCREEN_WIDTH-button_width - 12;
        }
    }
    
    if (landscape && !IS_IPAD && SCREEN_HEIGHT <= 375.0) {
        controlBar_y = Top_Height + 20;
    } else {
        controlBar_y = (SCREEN_HEIGHT - controlBar_height)/2;
    }
    self.frame = CGRectMake(controlBar_x, controlBar_y, button_width, controlBar_height);
}

- (void)initSubView {
    _videoBtn = [[UIButton alloc] init];
    _videoBtn.tag = kTagButtonVideo;
    [_videoBtn setImage:[UIImage imageNamed:@"icon_video_off"] forState:UIControlStateNormal];
    [_videoBtn setImage:[UIImage imageNamed:@"icon_video_on"] forState:UIControlStateSelected];
    [_videoBtn addTarget: self action: @selector(onBarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_videoBtn];
    
    _shareBtn = [[UIButton alloc] init];
    _shareBtn.tag = kTagButtonShare;
    [_shareBtn setImage:[UIImage imageNamed:@"icon_video_share"] forState:UIControlStateNormal];
    [_shareBtn addTarget: self action: @selector(onBarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_shareBtn];
    
    _audioBtn = [[UIButton alloc] init];
    _audioBtn.tag = kTagButtonAudio;
    [_audioBtn setImage:[UIImage imageNamed:@"icon_no_audio"] forState:UIControlStateNormal];
    [_audioBtn addTarget: self action: @selector(onBarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_audioBtn];
        
    _moreBtn = [[UIButton alloc] init];
    _moreBtn.tag = kTagButtonMore;
    [_moreBtn setImage:[UIImage imageNamed:@"icon_video_more"] forState:UIControlStateNormal];
    [_moreBtn addTarget: self action: @selector(onBarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_moreBtn];
    
    
}

- (void)showAudioTestMenu:(id)sender
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Audio"
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    
    if (!IS_IPAD) {
        NSString *speakDispaly;
        if ([self isCurrentOutputDeviceSpeaker]) {
            speakDispaly = @"ON -> Turn off Speaker";
        } else {
            speakDispaly = @"OFF -> Turn on Speaker";
        }
        [alertController addAction:[UIAlertAction actionWithTitle:speakDispaly
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
                                                              [self switchSpeaker];
                                                          }]];
    }
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"out: showAirPlayPicker"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        [[[ZoomVideoSDK shareInstance] getAudioHelper] showAudioOutputDeviceAirPlayPicker:self.superview];
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"out: getAvailableAudioOutputRoute"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        [self showChangeAudioOutputTestMenu:sender];
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"in: getAvailableAudioInputsDevice"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        [self showChangeAudioInputTestMenu:sender];
                                                      }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"startAudio"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
                                                          [[[ZoomVideoSDK shareInstance] getAudioHelper] startAudio];
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"stopAudio"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
                                                          [[[ZoomVideoSDK shareInstance] getAudioHelper] stopAudio];
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"muteAudio:"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        ZoomVideoSDKUser *myself = [[[ZoomVideoSDK shareInstance] getSession] getMySelf];
        [[[ZoomVideoSDK shareInstance] getAudioHelper] muteAudio:myself];
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"unMuteAudio:"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        ZoomVideoSDKUser *myself = [[[ZoomVideoSDK shareInstance] getSession] getMySelf];
        [[[ZoomVideoSDK shareInstance] getAudioHelper] unmuteAudio:myself];
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"MuteAll:"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        [[[ZoomVideoSDK shareInstance] getAudioHelper] muteAllAudio:NO];
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"UnmuteAll"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        [[[ZoomVideoSDK shareInstance] getAudioHelper] unmuteAllAudio];
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"allowAudioUnmutedBySelf YES"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        [[[ZoomVideoSDK shareInstance] getAudioHelper] allowAudioUnmutedBySelf:YES];
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"allowAudioUnmutedBySelf NO"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        [[[ZoomVideoSDK shareInstance] getAudioHelper] allowAudioUnmutedBySelf:NO];
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"subscribe"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        [[[ZoomVideoSDK shareInstance] getAudioHelper] subscribe];
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"unSubscribe"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        [[[ZoomVideoSDK shareInstance] getAudioHelper] unSubscribe];
                                                      }]];
    
    ZoomVideoSDKAudioSettingHelper *audioSettingHelper = [[ZoomVideoSDK shareInstance] getAudioSettingHelper];
    BOOL isOrigin = [audioSettingHelper isMicOriginalInputEnable];
    [alertController addAction:[UIAlertAction actionWithTitle:isOrigin?@"origin: set to non-origin":@"non-origin: set to origin"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        [audioSettingHelper enableMicOriginalInput:!isOrigin];
                                                      }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
    
    UIPopoverPresentationController *popover = alertController.popoverPresentationController;
    if (popover)
    {
        UIButton *btn = (UIButton*)sender;
        popover.sourceView = btn;
        popover.sourceRect = btn.bounds;
        popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    [[appDelegate topViewController] presentViewController:alertController animated:YES completion:nil];
}

- (void)showChangeAudioOutputTestMenu:(id)sender
{
    NSArray * outputList = [[[ZoomVideoSDK shareInstance] getAudioHelper] getAvailableAudioOutputRoute];
    ZoomVideoSDKAudioDevice *output = [[[ZoomVideoSDK shareInstance] getAudioHelper] getCurrentAudioOutputRoute];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Current Audio Output"
                                                                             message:output.getAudioName
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];

    for (ZoomVideoSDKAudioDevice *output in outputList) {
        [alertController addAction:[UIAlertAction actionWithTitle:output.getAudioName
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
            [[[ZoomVideoSDK shareInstance] getAudioHelper] setAudioOutputRoute:output];
                                                          }]];
    }

    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
    
    UIPopoverPresentationController *popover = alertController.popoverPresentationController;
    if (popover)
    {
        UIButton *btn = (UIButton*)sender;
        popover.sourceView = btn;
        popover.sourceRect = btn.bounds;
        popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    [[appDelegate topViewController] presentViewController:alertController animated:YES completion:nil];
}

- (void)showChangeAudioInputTestMenu:(id)sender
{
    ZoomVideoSDKAudioDevice *input = [[[ZoomVideoSDK shareInstance] getAudioHelper] getCurrentAudioInputDevice];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Current Audio Input"
                                                                             message:input.getAudioName
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];

    NSArray *arr = [[[ZoomVideoSDK shareInstance] getAudioHelper] getAvailableAudioInputsDevice];
    for (ZoomVideoSDKAudioDevice *input in arr) {
        [alertController addAction:[UIAlertAction actionWithTitle:input.getAudioName
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
            [[[ZoomVideoSDK shareInstance] getAudioHelper] setAudioInputDevice:input];
                                                          }]];
    }

    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
    
    UIPopoverPresentationController *popover = alertController.popoverPresentationController;
    if (popover)
    {
        UIButton *btn = (UIButton*)sender;
        popover.sourceView = btn;
        popover.sourceRect = btn.bounds;
        popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    [[appDelegate topViewController] presentViewController:alertController animated:YES completion:nil];
}

- (void)showSpotLightTestMenu:(id)sender
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"SpotLight"
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];

    [alertController addAction:[UIAlertAction actionWithTitle:@"getSpotlightedVideoUserList"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
                                                          NSArray *arr = [[[ZoomVideoSDK shareInstance] getVideoHelper] getSpotlightedVideoUserList];
        NSLog(@"getSpotlightedVideoUserList %@", arr);
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"unSpotlightAllVideos"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
                                                          [[[ZoomVideoSDK shareInstance] getVideoHelper] unSpotlightAllVideos];
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
    
    UIPopoverPresentationController *popover = alertController.popoverPresentationController;
    if (popover)
    {
        UIButton *btn = (UIButton*)sender;
        popover.sourceView = btn;
        popover.sourceRect = btn.bounds;
        popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    [[appDelegate topViewController] presentViewController:alertController animated:YES completion:nil];
}


- (void)showCameraRotateMenu:(id)sender
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"rotate Camera"
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];

    [alertController addAction:[UIAlertAction actionWithTitle:@"Portrait"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        [[[ZoomVideoSDK shareInstance] getVideoHelper] rotateMyVideo:UIDeviceOrientationPortrait];
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"PortraitUpsideDown"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        [[[ZoomVideoSDK shareInstance] getVideoHelper] rotateMyVideo:UIDeviceOrientationPortraitUpsideDown];
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"LandscapeLeft"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        [[[ZoomVideoSDK shareInstance] getVideoHelper] rotateMyVideo:UIDeviceOrientationLandscapeLeft];
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"LandscapeRight"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        [[[ZoomVideoSDK shareInstance] getVideoHelper] rotateMyVideo:UIDeviceOrientationLandscapeRight];
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
    
    UIPopoverPresentationController *popover = alertController.popoverPresentationController;
    if (popover)
    {
        UIButton *btn = (UIButton*)sender;
        popover.sourceView = btn;
        popover.sourceRect = btn.bounds;
        popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    [[appDelegate topViewController] presentViewController:alertController animated:YES completion:nil];
}

- (void)showCameraSelect:(id)sender
{
#if !TARGET_OS_VISION
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Select Camera"
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];

    NSArray *cameraList = [[[ZoomVideoSDK shareInstance] getVideoHelper] getCameraDeviceList];
    for (ZoomVideoSDKCameraDevice *device in cameraList) {
        NSString *deviceId = device.deviceId;
        [alertController addAction:[UIAlertAction actionWithTitle:[NSString stringWithFormat:@"%@", device]
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
                                                              [[[ZoomVideoSDK shareInstance] getVideoHelper] switchCamera:deviceId];
                                                          }]];
    }
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
    
    UIPopoverPresentationController *popover = alertController.popoverPresentationController;
    if (popover)
    {
        UIButton *btn = (UIButton*)sender;
        popover.sourceView = btn;
        popover.sourceRect = btn.bounds;
        popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    [[appDelegate topViewController] presentViewController:alertController animated:YES completion:nil];
#endif
}

- (void)showMultiStreamTestMenu:(id)sender
{
#if !TARGET_OS_VISION
    BOOL support = [[[ZoomVideoSDK shareInstance] getVideoHelper] isMultiStreamSupported];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"Multi Stream, support:%@", @(support)]
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];

    NSArray *cameraList = [[[ZoomVideoSDK shareInstance] getVideoHelper] getCameraDeviceList];
    for (ZoomVideoSDKCameraDevice *device in cameraList) {
        [alertController addAction:[UIAlertAction actionWithTitle:[NSString stringWithFormat:@"%@%@, isRun:%@, isSel:%@", device.deviceName, device.isSelectDevice ? @"(Selected)" : @"", @(device.isRunningAsMultiCamera), @(device.isSelectedAsMultiCamera)]
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
            [self showDeviceMultiStreamTestMenu:sender with:device];
                                                          }]];
    }
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
    
    UIPopoverPresentationController *popover = alertController.popoverPresentationController;
    if (popover)
    {
        UIButton *btn = (UIButton*)sender;
        popover.sourceView = btn;
        popover.sourceRect = btn.bounds;
        popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    [[appDelegate topViewController] presentViewController:alertController animated:YES completion:nil];
#endif
}

- (void)showDeviceMultiStreamTestMenu:(id)sender with:(ZoomVideoSDKCameraDevice *)device
{
#if !TARGET_OS_VISION
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:device.deviceName
                                                                             message:device.deviceId
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];

    [alertController addAction:[UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Enable:%@", device]
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        [[[ZoomVideoSDK shareInstance] getVideoHelper] enableMultiStreamVideo:device.deviceId customDeviceName:nil];
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Disable:%@", device]
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        [[[ZoomVideoSDK shareInstance] getVideoHelper] disableMultiStreamVideo:device.deviceId];
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Mute:%@", device]
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        [[[ZoomVideoSDK shareInstance] getVideoHelper] muteMultiStreamVideo:device.deviceId];
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Unmute:%@", device]
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        [[[ZoomVideoSDK shareInstance] getVideoHelper] unmuteMultiStreamVideo:device.deviceId];
                                                      }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
    
    UIPopoverPresentationController *popover = alertController.popoverPresentationController;
    if (popover)
    {
        UIButton *btn = (UIButton*)sender;
        popover.sourceView = btn;
        popover.sourceRect = btn.bounds;
        popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    [[appDelegate topViewController] presentViewController:alertController animated:YES completion:nil];
#endif
}

- (void)showVideoTestMenu:(id)sender
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Video"
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];

    [alertController addAction:[UIAlertAction actionWithTitle:@"startVideo"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
                                                          [[[ZoomVideoSDK shareInstance] getVideoHelper] startVideo];
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"stopVideo"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
                                                          [[[ZoomVideoSDK shareInstance] getVideoHelper] stopVideo];
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"rotateMyVideo:"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        [self showCameraRotateMenu:sender];
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"switchCamera:"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        [self showCameraSelect:sender];
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"getSelectCamera:"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        [[[ZoomVideoSDK shareInstance] getVideoHelper] getSelectedCamera];
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"switchCamera"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
#if !TARGET_OS_VISION
        [[[ZoomVideoSDK shareInstance] getVideoHelper] switchCamera];
#endif
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"mirrorVideo"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        BOOL ret = [[[ZoomVideoSDK shareInstance] getVideoHelper] isMyVideoMirrored];
        [[[ZoomVideoSDK shareInstance] getVideoHelper] mirrorMyVideo:!ret];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"isMirrorMyVideoEnabled %@", @(ret));
        });
                                                      }]];
    
    NSString *alphaMode = [NSString stringWithFormat:@"Alpha Mode,can:%@,isEnable:%@,isDevce:%@", @([[[ZoomVideoSDK shareInstance] getVideoHelper] canEnableAlphaChannelMode]), @([[[ZoomVideoSDK shareInstance] getVideoHelper] isAlphaChannelModeEnabled]), @([[[ZoomVideoSDK shareInstance] getVideoHelper] isDeviceSupportAlphaChannelMode])];
    [alertController addAction:[UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Enalbe %@", alphaMode]
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        [[[ZoomVideoSDK shareInstance] getVideoHelper] enableAlphaChannelMode:YES];
                                                      }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Disable %@", alphaMode]
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        [[[ZoomVideoSDK shareInstance] getVideoHelper] enableAlphaChannelMode:NO];
                                                      }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"videoPreference:"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        ZoomVideoSDKVideoPreferenceSetting *setting = [ZoomVideoSDKVideoPreferenceSetting new];
        setting.mode = ZoomVideoSDKVideoPreferenceMode_Sharpness;
        [[[ZoomVideoSDK shareInstance] getVideoHelper] setVideoQualityPreference:setting];
                                                      }]];
    
    ZoomVideoSDKUser *myUser = [[[ZoomVideoSDK shareInstance] getSession] getMySelf];
    BOOL isVideoOn = myUser.getVideoCanvas.videoStatus.on;
    NSString *isVideoOnStr = [NSString stringWithFormat:@"video status:%@", @(isVideoOn)];
    [alertController addAction:[UIAlertAction actionWithTitle:isVideoOnStr
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
                                                      }]];
    
    
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
    
    UIPopoverPresentationController *popover = alertController.popoverPresentationController;
    if (popover)
    {
        UIButton *btn = (UIButton*)sender;
        popover.sourceView = btn;
        popover.sourceRect = btn.bounds;
        popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    [[appDelegate topViewController] presentViewController:alertController animated:YES completion:nil];
}

- (ZoomVideoSDKShareAction *)getActiveShareAction
{
    NSMutableArray *allUser = [[[[ZoomVideoSDK shareInstance] getSession] getRemoteUsers] mutableCopy];
    [allUser addObject:[[[ZoomVideoSDK shareInstance] getSession] getMySelf]];
    for (ZoomVideoSDKUser *user in allUser) {
        NSArray <ZoomVideoSDKShareAction *>* shareActionList = [user getShareActionList];
        if (shareActionList == nil || shareActionList.count == 0) continue;
        return shareActionList.firstObject;
    }
    return nil;
}

- (void)showSubSessionTestMenu:(id)sender
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    int i = 5;
    NSMutableArray *arr = [NSMutableArray array];
    while (i>0) {
        [arr addObject:[NSString stringWithFormat:@"subsession%d",arc4random()%100]];
        i--;
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"SubSession"
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];

    [alertController addAction:[UIAlertAction actionWithTitle:@"addSubSessionToPreList"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        NSLog(@"addSubSessionToPreList:%@",arr.description);
        
        [[[ZoomVideoSDK shareInstance] getsubSessionHelper] addSubSessionToPreList:arr];
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"removeSubSessionFromPreList"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        NSArray *arr1 = [[[ZoomVideoSDK shareInstance] getsubSessionHelper] getSubSessionPreList];
        if (arr1.count < 2) {
            return;
        }
        NSArray *arr2 = @[arr1[0],arr1[1]];
        [[[ZoomVideoSDK shareInstance] getsubSessionHelper] removeSubSessionFromPreList:arr2];
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"clearSubSessionPreList"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        
        [[[ZoomVideoSDK shareInstance] getsubSessionHelper] clearSubSessionPreList];
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"getSubSessionPreList"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        NSLog(@"getSubSessionPreList:%@",[[[ZoomVideoSDK shareInstance] getsubSessionHelper] getSubSessionPreList].description);
        
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"commitSubSessionList"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        
        [[[ZoomVideoSDK shareInstance] getsubSessionHelper] commitSubSessionList];
                                                      }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"getCommittedSubSessionList"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        NSLog(@"getSubSessionPreList:%@",[[[ZoomVideoSDK shareInstance] getsubSessionHelper] getCommittedSubSessionList].description);
                                                      }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"DemoTestSubsessionView"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        NSLog(@"getSubSessionPreList:%@",[[[ZoomVideoSDK shareInstance] getsubSessionHelper] getCommittedSubSessionList].description);
                                                      }]];
        
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
    
    UIPopoverPresentationController *popover = alertController.popoverPresentationController;
    if (popover)
    {
        UIButton *btn = (UIButton*)sender;
        popover.sourceView = btn;
        popover.sourceRect = btn.bounds;
        popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    [[appDelegate topViewController] presentViewController:alertController animated:YES completion:nil];
}


- (void)showLiveStreamTestMenu:(id)sender
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"LiveStream"
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];

    ZoomVideoSDKLiveStreamSetting *setting = [[ZoomVideoSDKLiveStreamSetting alloc ] init];
    ZoomVideoSDKLiveStreamParams *params = [[ZoomVideoSDKLiveStreamParams alloc]init];
    [alertController addAction:[UIAlertAction actionWithTitle:@"StartLiveStream"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        setting.layout = ZoomVideoSDKLiveStreamLayout_SpeakerView;
        setting.closeCaption =  ZoomVideoSDKLiveStreamCloseCaption_BurntIn;
        params.streamUrl= @"";
        params.key = @"";
        params.broadcastUrl = @"";
        params.setting = setting;

        ZoomVideoSDKError ret  = [[[ZoomVideoSDK shareInstance] getLiveStreamHelper] startLiveStreamWithParams:params];
        NSLog(@"startLiveStreamWithParams:%@",@(ret));
                                                      }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"StartLiveStream_GalleryView_BurntIn"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        setting.layout = ZoomVideoSDKLiveStreamLayout_GalleryView;
        setting.closeCaption =  ZoomVideoSDKLiveStreamCloseCaption_BurntIn;
        params.streamUrl= @"";
        params.key = @"";
        params.broadcastUrl = @"";
        params.setting = setting;
        ZoomVideoSDKError ret  = [[[ZoomVideoSDK shareInstance] getLiveStreamHelper] startLiveStreamWithParams:params];
        NSLog(@"startLiveStreamWithParams:%@",@(ret));
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"StartLiveStreamSpeakerView_Embedded"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        setting.layout = ZoomVideoSDKLiveStreamLayout_SpeakerView;
        setting.closeCaption =  ZoomVideoSDKLiveStreamCloseCaption_Embedded;
        params.streamUrl= @"";
        params.key = @"";
        params.broadcastUrl = @"";
        params.setting = setting;
        ZoomVideoSDKError ret  = [[[ZoomVideoSDK shareInstance] getLiveStreamHelper] startLiveStreamWithParams:params];
        NSLog(@"startLiveStreamWithParams:%@",@(ret));
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"stopLiveStream"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        [[[ZoomVideoSDK shareInstance] getLiveStreamHelper] stopLiveStream];
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"updateLiveStreamSetting"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        NSLog(@"canGetOrUpdateLiveStreamSetting:%@",@([[[ZoomVideoSDK shareInstance] getLiveStreamHelper] canGetOrUpdateLiveStreamSetting]));
        ZoomVideoSDKLiveStreamSetting *setting = [[[ZoomVideoSDK shareInstance] getLiveStreamHelper] getCurrentLiveStreamSetting];
        NSLog(@"getCurrentLiveStreamSetting :%@",setting.description);
        setting.layout = setting.layout == ZoomVideoSDKLiveStreamLayout_SpeakerView?ZoomVideoSDKLiveStreamLayout_SpeakerView:ZoomVideoSDKLiveStreamLayout_GalleryView;
        setting.closeCaption = (setting.closeCaption+1) %3;
        ZoomVideoSDKError ret = [[[ZoomVideoSDK shareInstance] getLiveStreamHelper]
         updateLiveStreamSetting:setting];
        NSLog(@"getCurrentLiveStreamSetting :%@",setting.description);
        NSLog(@"updateLiveStreamSetting:%@",@(ret));
        
        
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:[NSString stringWithFormat:@"canStartLiveStream:%@",@([[ZoomVideoSDK shareInstance] getLiveStreamHelper].canStartLiveStream)]
                                                        style:UIAlertActionStyleDefault
                                                      handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
    
    UIPopoverPresentationController *popover = alertController.popoverPresentationController;
    if (popover)
    {
        UIButton *btn = (UIButton*)sender;
        popover.sourceView = btn;
        popover.sourceRect = btn.bounds;
        popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    [[appDelegate topViewController] presentViewController:alertController animated:YES completion:nil];
}

- (void)showWhiteboard:(id)sender
{
#if !TARGET_OS_VISION
    ZoomVideoSDKWhiteboardHelper *wbHelper = [[ZoomVideoSDK shareInstance] getWhiteboardHelper];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"canStart:%d canStop:%d OtherSharingWb:%d",[wbHelper canStartShareWhiteboard],[wbHelper canStopShareWhiteboard],[wbHelper isOtherSharingWhiteboard]]
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"setPresentViewController"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        ZoomVideoSDKError ret = [wbHelper subscribeWhiteboard:[appDelegate topViewController]];
        NSLog(@"subscribeWhitebaord   - %lu",(unsigned long)ret);
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"dismissWhiteboard"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        ZoomVideoSDKError ret = [wbHelper unSubscribeWhiteboard];
        NSLog(@"subscribeWhitebaord   - %lu",(unsigned long)ret);
                                                      }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"startShareWhiteboard"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        ZoomVideoSDKError ret = [wbHelper startShareWhiteboard];
        NSLog(@"startShareWhiteboard   - %lu",(unsigned long)ret);
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"stopShareWhiteboard"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        ZoomVideoSDKError ret = [wbHelper stopShareWhiteboard];
        NSLog(@"stopShareWhiteboard   - %lu",(unsigned long)ret);
                                                      }]];

    [alertController addAction:[UIAlertAction actionWithTitle:@"ZoomVideoSDKWhiteboardExport_FormatPDF"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        NSLog(@"isWhiteboardShareLocked:%d",[wbHelper exportWhiteboard:ZoomVideoSDKWhiteboardExport_Format_PDF]);
    }]];
        

    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
    
    UIPopoverPresentationController *popover = alertController.popoverPresentationController;
    if (popover)
    {
        UIButton *btn = (UIButton*)sender;
        popover.sourceView = btn;
        popover.sourceRect = btn.bounds;
        popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    [[appDelegate topViewController] presentViewController:alertController animated:YES completion:nil];
#endif
}

- (void)showRecordTestMenu:(id)sender
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Record"
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];

    NSString *canStartRecording = [NSString stringWithFormat:@"canStartRecording:%@",@([[ZoomVideoSDK shareInstance] getRecordingHelper].canStartRecording)];
    [alertController addAction:[UIAlertAction actionWithTitle:canStartRecording
                                                        style:UIAlertActionStyleDefault
                                                      handler:nil]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"startCloudRecording"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        [[[ZoomVideoSDK shareInstance] getRecordingHelper] startCloudRecording];
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"stopCloudRecording"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        [[[ZoomVideoSDK shareInstance] getRecordingHelper] stopCloudRecording];
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"pauseCloudRecording"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        [[[ZoomVideoSDK shareInstance] getRecordingHelper] pauseCloudRecording];
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"resumeCloudRecording"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        [[[ZoomVideoSDK shareInstance] getRecordingHelper] resumeCloudRecording];
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:[NSString stringWithFormat:@"getCloudRecordingStatus:%@",@([[ZoomVideoSDK shareInstance] getRecordingHelper].getCloudRecordingStatus)]
                                                        style:UIAlertActionStyleDefault
                                                      handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
    
    UIPopoverPresentationController *popover = alertController.popoverPresentationController;
    if (popover)
    {
        UIButton *btn = (UIButton*)sender;
        popover.sourceView = btn;
        popover.sourceRect = btn.bounds;
        popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    [[appDelegate topViewController] presentViewController:alertController animated:YES completion:nil];
}

- (void)showPhoneTestMenu:(id)sender
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Phone"
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    
    NSString *isSupportPhoneFeature = [NSString stringWithFormat:@"isSupportPhoneFeature:%@",@([[ZoomVideoSDK shareInstance] getPhoneHelper].isSupportPhoneFeature)];
    [alertController addAction:[UIAlertAction actionWithTitle:isSupportPhoneFeature
                                                        style:UIAlertActionStyleDefault
                                                      handler:nil]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"getSupportCountryInfo"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        NSArray *infoArr = [[[ZoomVideoSDK shareInstance] getPhoneHelper] getSupportCountryInfo];
        NSLog(@"getSupportCountryInfo:%@", infoArr);
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"invitePhoneUser:"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        
        ZoomVideoSDKInvitePhoneUserInfo *info = [[ZoomVideoSDKInvitePhoneUserInfo alloc] init];
        info.name = @"";
        info.countryCode = @"";
        info.phoneNumber = @"";
        info.bGreeting = YES;
        info.bPressOne = YES;
        [[[ZoomVideoSDK shareInstance] getPhoneHelper] invitePhoneUser:info];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"cancelInviteByPhone"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        [[[ZoomVideoSDK shareInstance] getPhoneHelper] cancelInviteByPhone];
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:[NSString stringWithFormat:@"getInviteByPhoneStatus:%@",@([[ZoomVideoSDK shareInstance] getPhoneHelper].getInviteByPhoneStatus)]
                                                        style:UIAlertActionStyleDefault
                                                      handler:nil]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Get dial in number list"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        NSArray *dialInList = [[[ZoomVideoSDK shareInstance] getPhoneHelper] getSessionDialInNumbers];
        NSLog(@"dial in list:\n %@", dialInList);
                                                      }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
    
    UIPopoverPresentationController *popover = alertController.popoverPresentationController;
    if (popover)
    {
        UIButton *btn = (UIButton*)sender;
        popover.sourceView = btn;
        popover.sourceRect = btn.bounds;
        popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    [[appDelegate topViewController] presentViewController:alertController animated:YES completion:nil];
}
- (void)showUserTestMenu:(id)sender
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"User list"
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];

    NSMutableArray *allUser = [[[[ZoomVideoSDK shareInstance] getSession] getRemoteUsers] mutableCopy];
    [allUser addObject:[[[ZoomVideoSDK shareInstance] getSession] getMySelf]];
    
    ZoomVideoSDKUser *my = [[[ZoomVideoSDK shareInstance] getSession] getMySelf];
    NSArray <ZoomVideoSDKRawDataPipe *> *pipeList = my.getMultiCameraStreamList;
    for (ZoomVideoSDKRawDataPipe *pipe in pipeList) {
        NSString *deviceId = [[[ZoomVideoSDK shareInstance] getVideoHelper] getDeviceIDByMyPipe:pipe];
        NSLog(@"User getDeviceIDByMyPipe:%@", deviceId);
    }
    
    NSArray <ZoomVideoSDKVideoCanvas *> *canvasList = my.getMultiCameraCanvasList;
    for (ZoomVideoSDKVideoCanvas *canvas in canvasList) {
        NSString *deviceId = [[[ZoomVideoSDK shareInstance] getVideoHelper] getDeviceIDByMyCanvas:canvas];
        NSLog(@"User getDeviceIDByMyCanvas:%@", deviceId);
    }
    
    NSString *userProperty = @"";
    for (ZoomVideoSDKUser *user in allUser) {
        
        [alertController addAction:[UIAlertAction actionWithTitle:[NSString stringWithFormat:@"%@  host:%@, manager:%@, spot:%@", user.getUserName, /*user.getUserReference,*/ @(user.isHost), @(user.isManager), @(user.isVideoSpotLighted)]
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
            [self showUserActionMenu:sender andUser:user];
        }]];
       
        userProperty = [userProperty stringByAppendingFormat:@"\n%@ : %@",user.getUserName, user.debugDescription];
    }
    NSLog(@"User property:%@", userProperty);
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
    
    UIPopoverPresentationController *popover = alertController.popoverPresentationController;
    if (popover)
    {
        UIButton *btn = (UIButton*)sender;
        popover.sourceView = btn;
        popover.sourceRect = btn.bounds;
        popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    [[appDelegate topViewController] presentViewController:alertController animated:YES completion:nil];
}

- (void)showBroadcastStreamTestMenu:(id)sender
{
    
    ZoomVideoSDKBroadcastStreamingHelper *helper = [[ZoomVideoSDK shareInstance] getBroadcastStreamingHelper];
    ZoomVideoSDKBroadcastStreamingViewerHelper *viewerHelper = [[ZoomVideoSDK shareInstance] getBroadcastStreamingViewerHelper];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"CanBS(%@)StreamStatus(%@)",@([helper canStartBroadcast]),@([viewerHelper getStreamingJoinStatus])]
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];

    
    [alertController addAction:[UIAlertAction actionWithTitle:@"startBroadcast" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"startBroadcast:%@",@([helper startBroadcast]));
    }]];
    
    for (NSString *channelID in _broadcastChannelIDs) {
        [alertController addAction:[UIAlertAction actionWithTitle:[NSString stringWithFormat:@"stop:%@",channelID] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"stopBroadcast:%@",@([helper stopBroadcast:channelID]));
        }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:[NSString stringWithFormat:@"getStatus:%@",channelID] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"getBroadcastStatus:%@",@([helper getBroadcastStatus:channelID]));
        }]];
    }
   
    
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
    
    UIPopoverPresentationController *popover = alertController.popoverPresentationController;
    if (popover)
    {
        UIButton *btn = (UIButton*)sender;
        popover.sourceView = btn;
        popover.sourceRect = btn.bounds;
        popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    [[appDelegate topViewController] presentViewController:alertController animated:YES completion:nil];
}
- (void)showUserActionMenu:(id)sender andUser:(ZoomVideoSDKUser *)user
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:user.getUserName
                                                                             message:[NSString stringWithFormat:@"%@ isHost:%@, isManager:%@", user.getUserName, @(user.isHost), @(user.isManager)]
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:[NSString stringWithFormat:@"change %@'s name", user.getUserName]
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull action) {
        [[[ZoomVideoSDK shareInstance] getUserHelper] changeName:@"Test User" withUser:user];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Make %@'s Host", user.getUserName]
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull action) {
        [[[ZoomVideoSDK shareInstance] getUserHelper] makeHost:user];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Remove %@", user.getUserName]
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull action) {
        [[[ZoomVideoSDK shareInstance] getUserHelper] removeUser:user];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Make %@ as Manager", user.getUserName]
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull action) {
        [[[ZoomVideoSDK shareInstance] getUserHelper] makeManager:user];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Revoke %@'s Manager", user.getUserName]
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull action) {
        [[[ZoomVideoSDK shareInstance] getUserHelper] revokeManager:user];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Mute Audio %@", user.getUserName]
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull action) {
        [[[ZoomVideoSDK shareInstance] getAudioHelper] muteAudio:user];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Unmute Audio %@", user.getUserName]
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull action) {
        [[[ZoomVideoSDK shareInstance] getAudioHelper] unmuteAudio:user];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Spot %@", user.getUserName]
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull action) {
        [[[ZoomVideoSDK shareInstance] getVideoHelper] spotLightVideo:user];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:[NSString stringWithFormat:@"un-Spot %@", user.getUserName]
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull action) {
        [[[ZoomVideoSDK shareInstance] getVideoHelper] unSpotLightVideo:user];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
    
    UIPopoverPresentationController *popover = alertController.popoverPresentationController;
    if (popover)
    {
        UIButton *btn = (UIButton*)sender;
        popover.sourceView = btn;
        popover.sourceRect = btn.bounds;
        popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    [[appDelegate topViewController] presentViewController:alertController animated:YES completion:nil];
}

- (void)showChatTest:(id)sender {
    ZoomVideoSDKChatHelper *chatHelper =  [[ZoomVideoSDK shareInstance] getChatHelper];
    bool isCanChat = ![chatHelper IsChatDisabled];
    bool isCanPrivateChat = ![chatHelper IsPrivateChatDisabled];
    ZoomVideoSDKChatPrivilegeType Privilege = [chatHelper getChatPrivilege];
    NSString *PrivilegeStr = @"_Uknow";
    switch (Privilege) {
        case ZoomVideoSDKChatPrivilege_Everyone_Publicly_And_Privately:
            PrivilegeStr = @"_Everyone_Publicly_And_Privately";
            break;
        case ZoomVideoSDKChatPrivilege_Everyone_Publicly:
            PrivilegeStr = @"_Everyone_Publicly";
            break;
        case ZoomVideoSDKChatPrivilege_No_One:
            PrivilegeStr = @"_No_One";
            break;
            
        default:
            break;
    }
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"Chat:%@ PrivateChat:%@ Privilege:%@",@(isCanChat),@(isCanPrivateChat),PrivilegeStr]
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"changeAttendeeChatPrivilege"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {

        NSArray *arr = @[@"ZoomVideoSDKChatPrivilege_Unknown",@"ZoomVideoSDKChatPrivilege_Everyone_Publicly_And_Privately",@"ZoomVideoSDKChatPrivilege_No_One",@"ZoomVideoSDKChatPrivilege_Everyone_Publicly"];
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"Chat:%@ PrivateChat:%@",@(isCanChat),@(isCanPrivateChat)]
                                                                                             message:nil
                                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
        for (NSString *tmp in arr) {
            [alertController addAction:[UIAlertAction actionWithTitle:tmp
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action) {
                NSLog(@"changeAttendeeChatPrivilege:%lu", (unsigned long)[chatHelper changeChatPrivilege:[arr indexOfObject:tmp]]);
                                                              }]];
        }


        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];

        UIPopoverPresentationController *popover = alertController.popoverPresentationController;
        if (popover)
        {
            UIButton *btn = (UIButton*)sender;
            popover.sourceView = btn;
            popover.sourceRect = btn.bounds;
            popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
        }
        [[appDelegate topViewController] presentViewController:alertController animated:YES completion:nil];
    }]];

    [alertController addAction:[UIAlertAction actionWithTitle:@"SendChatToAll"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        NSLog(@"call --[ZoomVideoSDKChatHelper SendChatToAll:] ret:%d",[chatHelper SendChatToAll:[NSString stringWithFormat:@"send all %d",arc4random()%100+100]]);
                                                      }]];
    

    
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"SendChatToUser"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        NSArray <ZoomVideoSDKUser *>* users = [[[ZoomVideoSDK shareInstance] getSession] getRemoteUsers];
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"send user " message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        for (ZoomVideoSDKUser *user in users) {
            [alertController addAction:[UIAlertAction actionWithTitle:[NSString stringWithFormat:@"%@ %@",user.getUserName,@(user.getUserID)] style:UIAlertActionStyleDefault  handler:^(UIAlertAction *action) {
                NSLog(@"changeAttendeeChatPrivilege:%lu", (unsigned long)[chatHelper SendChatToUser:user Content:[NSString stringWithFormat:@"send %@ %d",user.getUserName,arc4random()%100+100]]);
            }]];
        }


        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];

        UIPopoverPresentationController *popover = alertController.popoverPresentationController;
        if (popover)
        {
            UIButton *btn = (UIButton*)sender;
            popover.sourceView = btn;
            popover.sourceRect = btn.bounds;
            popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
        }
        [[appDelegate topViewController] presentViewController:alertController animated:YES completion:nil];
        
      }]];
    
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
    
    UIPopoverPresentationController *popover = alertController.popoverPresentationController;
    if (popover)
    {
        UIButton *btn = (UIButton*)sender;
        popover.sourceView = btn;
        popover.sourceRect = btn.bounds;
        popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    [[appDelegate topViewController] presentViewController:alertController animated:YES completion:nil];
}

- (void)showTestCRC:(id)sender
{
    BOOL enable = [[[ZoomVideoSDK shareInstance] getCRCHelper] isCRCEnabled];
    ZoomVideoSDKCRCHelper *crcHelper =  [[ZoomVideoSDK shareInstance] getCRCHelper];
    ZoomVideoSDKSession *session = [[ZoomVideoSDK shareInstance] getSession];
    NSLog(@"call -[session getSessionNumber] ret:%llu",[session getSessionNumber]);
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"CRC"
                                                                             message:[enable?@"CRC Enabled":@"CRC Disabled" stringByAppendingFormat:@" Session Num:%@, %@", @([session getSessionNumber]), [crcHelper getSessionSIPAddress]]
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"CRC callCRCDevice"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        ZoomVideoSDKCRCHelper *crcHelper =  [[ZoomVideoSDK shareInstance] getCRCHelper];
        ZoomVideoSDKError ret =  [crcHelper callCRCDevice:@"" protocol:ZoomVideoSDKCRCProtocol_SIP];
               NSLog(@"call -[ZoomVideoSDKCRCHelper callCRCDevice:callType:] ret:%d",ret);
        NSLog(@"call -[ZoomVideoSDKCRCHelper callCRCDevice:callType:] ret:%lu",(unsigned long)ret);
                                                      }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"CRC cancelCallCRCDevice"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        ZoomVideoSDKCRCHelper *crcHelper =  [[ZoomVideoSDK shareInstance] getCRCHelper];
        ZoomVideoSDKError ret =  [crcHelper cancelCallCRCDevice];
        NSLog(@"call -[ZoomVideoSDKCRCHelper cancelCallCRCDevice:] ret:%@",@(ret));
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
    
    UIPopoverPresentationController *popover = alertController.popoverPresentationController;
    if (popover)
    {
        UIButton *btn = (UIButton*)sender;
        popover.sourceView = btn;
        popover.sourceRect = btn.bounds;
        popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [[appDelegate topViewController] presentViewController:alertController animated:YES completion:nil];
}

- (void)showTestltt:(id)sender {
    ZoomVideoSDKLiveTranscriptionHelper *lttHelper =  [[ZoomVideoSDK shareInstance] getLiveTranscriptionHelper];
    BOOL ret = [lttHelper canStartLiveTranscription];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"CanStartLTT:%@",@(ret)]
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"getLiveTranscriptionStatus"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        ZoomVideoSDKCRCHelper *crcHelper =  [[ZoomVideoSDK shareInstance] getCRCHelper];
        NSLog(@"call -[ZoomVideoSDKLiveTranscriptionHelper getLiveTranscriptionStatus:] ret:%@",@([lttHelper getLiveTranscriptionStatus]));
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"startLiveTranscription"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        NSLog(@"call -[ZoomVideoSDKLiveTranscriptionHelper startLiveTranscription] ret:%@",@([lttHelper startLiveTranscription]));
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"stopLiveTranscription"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        NSLog(@"call -[ZoomVideoSDKLiveTranscriptionHelper stopLiveTranscription] ret:%@",@([lttHelper stopLiveTranscription]));
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"getSpokenLanguage"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        
        NSLog(@"call -[ZoomVideoSDKLiveTranscriptionHelper getSpokenLanguage] ret:%@",[lttHelper getSpokenLanguage].description );
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"getAvailableSpokenLanguages"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        
        NSLog(@"call -[ZoomVideoSDKLiveTranscriptionHelper getAvailableSpokenLanguages] ret:%@",[lttHelper getAvailableSpokenLanguages].description );
                                                      }]];
    
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"setSpokenLanguage"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"setSpokenLanguage"]
                                                                                     message:nil
                                                                              preferredStyle:UIAlertControllerStyleActionSheet];
            NSArray *arr = [lttHelper getAvailableSpokenLanguages];
            for(ZoomVideoSDKLiveTranscriptionLanguage *tmp in arr) {
                [alertController addAction:[UIAlertAction actionWithTitle:tmp.description
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction *action) {
                    NSLog(@"setSpokenLanguage: %d",[lttHelper setSpokenLanguage:tmp.languageID]);
                                                                  }]];
            }
            
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
            
            UIPopoverPresentationController *popover = alertController.popoverPresentationController;
            if (popover)
            {
                UIButton *btn = (UIButton*)sender;
                popover.sourceView = btn;
                popover.sourceRect = btn.bounds;
                popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
            }
            [[appDelegate topViewController] presentViewController:alertController animated:YES completion:nil];
        
      }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"enableReceiveSpokenLanguageContent"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        
        NSLog(@"call -[ZoomVideoSDKLiveTranscriptionHelper enableReceiveSpokenLanguageContent] YES ret:%d",[lttHelper enableReceiveSpokenLanguageContent:YES] );
                                                      }]];
    
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"isAllowViewFullTranscriptEnable"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        
        NSLog(@"call -[ZoomVideoSDKLiveTranscriptionHelper isAllowViewFullTranscriptEnable] ret:%d",[lttHelper isAllowViewFullTranscriptEnable] );
                                                      }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"getHistoryTranslationMessageList"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        
        NSLog(@"call -[ZoomVideoSDKLiveTranscriptionHelper getHistoryTranslationMessageList] ret:%@",[lttHelper getHistoryTranslationMessageList].description );
                                                      }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"getTranslationLanguage"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        
        NSLog(@"call -[ZoomVideoSDKLiveTranscriptionHelper getSpokenLanguage] ret:%@",[lttHelper getTranslationLanguage].description );
                                                      }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"setTranslationLanguage"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"setSpokenLanguage"]
                                                                                     message:nil
                                                                              preferredStyle:UIAlertControllerStyleActionSheet];
            NSArray *arr = [lttHelper getAvailableTranslationLanguages];
            for(ZoomVideoSDKLiveTranscriptionLanguage *tmp in arr) {
                [alertController addAction:[UIAlertAction actionWithTitle:tmp.description
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction *action) {
                    NSLog(@"setSpokenLanguage: %d",[lttHelper setTranslationLanguage:tmp.languageID]);
                                                                  }]];
            }
            
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
            
            UIPopoverPresentationController *popover = alertController.popoverPresentationController;
            if (popover)
            {
                UIButton *btn = (UIButton*)sender;
                popover.sourceView = btn;
                popover.sourceRect = btn.bounds;
                popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
            }
            [[appDelegate topViewController] presentViewController:alertController animated:YES completion:nil];
        
      }]];
    
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
    
    UIPopoverPresentationController *popover = alertController.popoverPresentationController;
    if (popover)
    {
        UIButton *btn = (UIButton*)sender;
        popover.sourceView = btn;
        popover.sourceRect = btn.bounds;
        popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    [[appDelegate topViewController] presentViewController:alertController animated:YES completion:nil];
}

- (void)showFileTransferMenu:(id)sender
{
    ZoomVideoSDKSession * session = [[ZoomVideoSDK shareInstance] getSession];
    BOOL enable = [session isFileTransferEnable];
    NSString *wl = [session getTransferFileTypeWhiteList];
    unsigned long long maxSize =[session getMaxTransferFileSize];
    
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"FileTransfer"
                                                                             message:[NSString stringWithFormat:@"%@\n%@\n%@", enable?@"Enabled":@"Disabled", wl, @(maxSize)]
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Session Send to ALL"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        [session transferFile:[self findFirstLogFilesInTmpDirectory]];
                                                      }]];
    
    NSArray <ZoomVideoSDKUser *>* users = [[[ZoomVideoSDK shareInstance] getSession] getRemoteUsers];
    for (ZoomVideoSDKUser *user in users) {
        [alertController addAction:[UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Send:%@ %@",user.getUserName,@(user.getUserID)] style:UIAlertActionStyleDefault  handler:^(UIAlertAction *action) {
            [user transferFile:[self findFirstLogFilesInTmpDirectory]];
        }]];
    }
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
    
    UIPopoverPresentationController *popover = alertController.popoverPresentationController;
    if (popover)
    {
        UIButton *btn = (UIButton*)sender;
        popover.sourceView = btn;
        popover.sourceRect = btn.bounds;
        popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    [[appDelegate topViewController] presentViewController:alertController animated:YES completion:nil];
}

- (NSString *)findFirstLogFilesInTmpDirectory {
    NSError *error = nil;
    NSString *tmpDirectory = NSTemporaryDirectory();
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *directoryContents = [fileManager contentsOfDirectoryAtPath:tmpDirectory error:&error];
    if (error) {
        NSLog(@"Error reading tmp directory: %@", error);
        return nil;
    }
    
    for (NSString *file in directoryContents) {
        if ([file.pathExtension isEqualToString:@"log"]) {
            NSString *filePath = [tmpDirectory stringByAppendingPathComponent:file];
            return filePath;
        }
    }
    
    return nil;
}

//#define  VSDK_SIMPLE_MACRO
- (void)onBarButtonClicked:(UIButton *)sender
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    switch (sender.tag) {
        case kTagButtonMore:
        {

#ifndef VSDK_SIMPLE_MACRO
            MoreMenuViewController *pollingVC = [[MoreMenuViewController alloc] init];
            pollingVC.modalPresentationStyle = UIModalPresentationPageSheet;
            [[appDelegate topViewController] presentViewController:pollingVC animated:YES completion:nil];
            return;
#else
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                                     message:nil
                                                                              preferredStyle:UIAlertControllerStyleActionSheet];

            [alertController addAction:[UIAlertAction actionWithTitle:@"Audio"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action) {
                [self showAudioTestMenu:sender];
                                                              }]];
            [alertController addAction:[UIAlertAction actionWithTitle:@"Video"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action) {
                [self showVideoTestMenu:sender];
                                                              }]];
            [alertController addAction:[UIAlertAction actionWithTitle:@"Multi Stream"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action) {
                [self showMultiStreamTestMenu:sender];
                                                              }]];
            [alertController addAction:[UIAlertAction actionWithTitle:@"Share"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action) {
                [self showShareTestMenu:sender];
                                                              }]];
//            [alertController addAction:[UIAlertAction actionWithTitle:@"subSession"
//                                                                style:UIAlertActionStyleDefault
//                                                              handler:^(UIAlertAction *action) {
//                [self showSubSessionTestMenu:sender];
//                                                              }]];
            [alertController addAction:[UIAlertAction actionWithTitle:@"subSessionControl"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action) {
                if (self.controlBarClickBlock) {
                    self.controlBarClickBlock(kTagButtonSubsession);
                }
                                                              }]];
            [alertController addAction:[UIAlertAction actionWithTitle:@"BroadcastStreaming"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action) {
                [self showBroadcastStreamTestMenu:sender];
                                                              }]];
            [alertController addAction:[UIAlertAction actionWithTitle:@"User"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action) {
                [self showUserTestMenu:sender];
                                                              }]];
            [alertController addAction:[UIAlertAction actionWithTitle:@"whiteboard"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action) {
                [self showWhiteboard:sender];
                                                              }]];
            [alertController addAction:[UIAlertAction actionWithTitle:@"LiveStream"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action) {
                [self showLiveStreamTestMenu:sender];
                                                              }]];
            [alertController addAction:[UIAlertAction actionWithTitle:@"Recording"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action) {
                [self showRecordTestMenu:sender];
                                                              }]];
            [alertController addAction:[UIAlertAction actionWithTitle:@"Phone"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action) {
                [self showPhoneTestMenu:sender];
                                                              }]];
            [alertController addAction:[UIAlertAction actionWithTitle:@"ChatTest"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action) {
                [self showChatTest:sender];
                                                              }]];
            [alertController addAction:[UIAlertAction actionWithTitle:@"Spotlight"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action) {
                [self showSpotLightTestMenu:sender];
                                                              }]];
            [alertController addAction:[UIAlertAction actionWithTitle:@"LiveTranscription"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action) {
                [self showTestltt:sender];
                                                              }]];
            [alertController addAction:[UIAlertAction actionWithTitle:@"CRC"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action) {
                [self showTestCRC:sender];
                                                              }]];
            if ([[[ZoomVideoSDK shareInstance] getVirtualBackgroundHelper] isSupportVirtualBackground]) {
                [alertController addAction:[UIAlertAction actionWithTitle:@"VB"
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction *action) {
                    [self showVBTestMenu:sender];
                                                                  }]];
            }
            if ([[[ZoomVideoSDK shareInstance] getVirtualBackgroundHelper] isSupportVirtualBackground]) {
                [alertController addAction:[UIAlertAction actionWithTitle:@"FileTranser"
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction *action) {
                    [self showFileTransferMenu:sender];
                                                                  }]];
            }
            [alertController addAction:[UIAlertAction actionWithTitle:@"Mask"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action) {
                CGFloat w = [[[ZoomVideoSDK shareInstance] getSession] getMySelf].getVideoStatisticInfo.width;
                CGFloat h = [[[ZoomVideoSDK shareInstance] getSession] getMySelf].getVideoStatisticInfo.height;
                NSMutableArray *arr = [NSMutableArray array];
                ZoomVideoSDKMaskInfo *info = [[ZoomVideoSDKMaskInfo alloc] init];
                info.shape = ZoomVideoSDKMaskShape_Circle;
                info.cx = 0;
                info.cy = 0;
                info.radius = 350;
                [arr addObject:info];
                ZoomVideoSDKMaskInfo *info2 = [[ZoomVideoSDKMaskInfo alloc] init];
                info2.shape = ZoomVideoSDKMaskShape_Rectangle;
                info2.top = 200;
                info2.left = 150;
                info2.right = 150;
                info2.bottom = 500;
                [arr addObject:info2];
                ZoomVideoSDKMaskInfo *info3 = [[ZoomVideoSDKMaskInfo alloc] init];
                info3.shape = ZoomVideoSDKMaskShape_Circle;
                info3.cx = w;
                info3.cy = 0;
                info3.radius = 350;
                [arr addObject:info3];
                ZoomVideoSDKMaskInfo *info4 = [[ZoomVideoSDKMaskInfo alloc] init];
                info4.shape = ZoomVideoSDKMaskShape_Circle;
                info4.cx = w;
                info4.cy = h;
                info4.radius = 350;
                [arr addObject:info4];
                ZoomVideoSDKMaskInfo *info5 = [[ZoomVideoSDKMaskInfo alloc] init];
                info5.shape = ZoomVideoSDKMaskShape_Circle;
                info5.cx = 0;
                info5.cy = h;
                info5.radius = 350;
                [arr addObject:info5];
                ZoomVideoSDKMaskHelper *helper = [[ZoomVideoSDK shareInstance] getMaskHelper];
                UIImage * maskImage = [helper generateMask:arr width:w height:h];
                
                BOOL isMirror = [[ZoomVideoSDK shareInstance] getVideoHelper].isMyVideoMirrored;
                [helper setVideoMask:maskImage background:[UIImage imageNamed:@"intro_bg_2"] mirror:isMirror];
            }]];
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
            UIPopoverPresentationController *popover = alertController.popoverPresentationController;
            if (popover)
            {
                UIButton *btn = (UIButton*)sender;
                popover.sourceView = btn;
                popover.sourceRect = btn.bounds;
                popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
            }
            [[appDelegate topViewController] presentViewController:alertController animated:YES completion:nil];
#endif
            break;
        }

        case kTagButtonVideo:
        {
            ZoomVideoSDKUser *myUser = [[[ZoomVideoSDK shareInstance] getSession] getMySelf];
            if (myUser.getVideoPipe.videoStatus.on) {
                [[[ZoomVideoSDK shareInstance] getVideoHelper] stopVideo];
                [_videoBtn setSelected:YES];
            } else {
                [[[ZoomVideoSDK shareInstance] getVideoHelper] startVideo];
                [_videoBtn setSelected:NO];
            }
            break;
        }
        case kTagButtonShare:
        {
            if (self.controlBarClickBlock) {
                self.controlBarClickBlock(kTagButtonShare);
            }
            break;
        }
        case kTagButtonAudio:
        {
            ZoomVideoSDKUser *myUser = [[[ZoomVideoSDK shareInstance] getSession] getMySelf];
            if (myUser.audioStatus.audioType == ZoomVideoSDKAudioType_None) {
                [[[ZoomVideoSDK shareInstance] getAudioHelper] startAudio];
            } else {
                if (!myUser.audioStatus.isMuted) {
                    [[[ZoomVideoSDK shareInstance] getAudioHelper] muteAudio:myUser];
                } else {
                    [[[ZoomVideoSDK shareInstance] getAudioHelper] unmuteAudio:myUser];
                }
            }
        }
        default:
            break;
    }
}

- (void)switchSpeaker
{
    CFDictionaryRef route;
    UInt32 size = sizeof (route);
    OSStatus status = AudioSessionGetProperty(kAudioSessionProperty_AudioRouteDescription, &size, &route);
    if (status != noErr) {
        return;
    }
    
    CFArrayRef outputs = (CFArrayRef)CFDictionaryGetValue(route, kAudioSession_AudioRouteKey_Outputs);
    if (!outputs || CFArrayGetCount(outputs) == 0) {
        if(route) CFRelease(route);
        return;
    }
    
    CFDictionaryRef item = (CFDictionaryRef)CFArrayGetValueAtIndex(outputs, 0);
    CFStringRef device = (CFStringRef)CFDictionaryGetValue(item, kAudioSession_AudioRouteKey_Type);
    if (device && COMPARE(device, kAudioSessionOutputRoute_BuiltInReceiver))
    {
        UInt32 isSpeaker = kAudioSessionOverrideAudioRoute_Speaker;
        AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(isSpeaker), &isSpeaker);
    }
    else if (device && COMPARE(device, kAudioSessionOutputRoute_BuiltInSpeaker))
    {
        UInt32 isSpeaker = kAudioSessionOverrideAudioRoute_None;
        AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(isSpeaker), &isSpeaker);
    }
    
    if(route) CFRelease(route);
}

- (BOOL)isCurrentOutputDeviceSpeaker
{
    CFDictionaryRef route;
    UInt32 size = sizeof (route);
    OSStatus status = AudioSessionGetProperty(kAudioSessionProperty_AudioRouteDescription, &size, &route);
    if (status != noErr) {
        return NO;
    }
    
    CFArrayRef outputs = (CFArrayRef)CFDictionaryGetValue(route, kAudioSession_AudioRouteKey_Outputs);
    if (!outputs || CFArrayGetCount(outputs) == 0) {
        if(route) CFRelease(route);
        return NO;
    }
    
    CFDictionaryRef item = (CFDictionaryRef)CFArrayGetValueAtIndex(outputs, 0);
    CFStringRef device = (CFStringRef)CFDictionaryGetValue(item, kAudioSession_AudioRouteKey_Type);
    if (device && COMPARE(device, kAudioSessionOutputRoute_BuiltInReceiver))
    {
        return NO;
    }
    else if (device && COMPARE(device, kAudioSessionOutputRoute_BuiltInSpeaker))
    {
        return YES;
    }
    
    if(route) CFRelease(route);
    return NO;
}

@end


