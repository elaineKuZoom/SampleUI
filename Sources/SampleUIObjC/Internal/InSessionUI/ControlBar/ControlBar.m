//
//  ControlBar.m
//  ZoomVideoSample
//
//  Created by Zoom Communications on 2019/5/27.
//  Copyright © 2019 Zoom. All rights reserved.
//

#import "SampleUI.h"
#import "ControlBar.h"
#import "InSessionUI/TopBar/TopBarView.h"
#import <AudioToolbox/AudioToolbox.h>
#import "InSessionUI/More/MoreMenuViewController.h"
#import "Vender/KGModal/KGModal.h"

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

//#define  VSDK_SIMPLE_MACRO
- (void)onBarButtonClicked:(UIButton *)sender
{
    switch (sender.tag) {
        case kTagButtonMore:
        {
			MoreMenuViewController *pollingVC = [[MoreMenuViewController alloc] init];
			pollingVC.modalPresentationStyle = UIModalPresentationPageSheet;

			// Find the parent view controller from responder chain
			UIResponder *responder = self;
			while (responder) {
				if ([responder isKindOfClass:[UIViewController class]]) {
					[(UIViewController *)responder presentViewController:pollingVC animated:YES completion:nil];
					break;
				}
				responder = [responder nextResponder];
			}
			return;
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


