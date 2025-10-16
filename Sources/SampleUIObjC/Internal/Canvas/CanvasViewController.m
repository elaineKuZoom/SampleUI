//
//  CanvasViewController.m
//  ZoomVideoSample
//
//  Created by Zoom Communications on 2019/5/27.
//  Copyright © 2019 Zoom. All rights reserved.
//

#import "SampleUI.h"
#import <ReplayKit/ReplayKit.h>
#import "CanvasViewController.h"
#import "UISceneOrientationHelper.h"
#import "InSessionUI/TopBar/TopBarView.h"
#import "InSessionUI/ControlBar/ControlBar.h"
#import "InSessionUI/Chat/ChatInputView.h"
#import "InSessionUI/BottomBar/BottomBarView.h"
#import "InSessionUI/Chat/ChatView.h"
#import "Vender/KGModal/KGModal.h"
#import "InSessionUI/SwitchBtn/SwitchBtn.h"
#import "InSessionUI/More/MoreMenuViewController.h"
#import "InSessionUI/Storage/SimulateStorage.h"
#import "PictureInPicture/SDKCallKitManager.h"
#import "PictureInPicture/SDKPiPHelper.h"
#import "Canvas/DemoTestSubsessionView.h"
#import "Vender/MBProgressHUD/MBProgressHUD.h"
//#import "SharePreprocessHelper.h"

#import <Photos/Photos.h>
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h> // iOS 14+


#define kBroadcastPickerTag 10001
#define kEmojiTag           10002
#define kBackgroudTag       10003

@implementation ZoomView

@end

@interface CanvasViewController () <ZoomVideoSDKDelegate, BottomBarViewDelegate, ChatInputViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIScrollViewDelegate>
@property (strong, nonatomic) TopBarView              *topBarView;
@property (strong, nonatomic) ControlBar              *controlBarView;
@property (strong, nonatomic) ChatInputView           *chatInputView;
@property (strong, nonatomic) BottomBarView           *bottomView;
@property (strong, nonatomic) ChatView                *chatView;
@property (strong, nonatomic) SwitchBtn               *switchShareBtn;

@property (strong, nonatomic) DemoTestSubsessionView * subSessionView;
@property (nonatomic, strong) ZoomView  *fullScreenCanvas;

@property (nonatomic, strong) ZoomView *multipUserView;

@property (nonatomic, strong) UIView *shareView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *selectImgView;
@property (nonatomic, strong) UIButton *stopShareBtn;

@property (nonatomic, strong) NSMutableArray *avatarArr;
@property (nonatomic, strong) NSTimer *speakerTimer;

@property (nonatomic, strong) NSTimer *updateTimer;
@property (nonatomic, strong) UILabel *statisticLabel;


@property (nonatomic, strong)ZoomVideoSDKSubSessionParticipant* currentParticipant;
@end

@implementation CanvasViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [ZoomVideoSDK shareInstance].delegate = self;
    self.avatarArr = [NSMutableArray array];

    [self initSubView];

    [UIApplication sharedApplication].idleTimerDisabled = YES;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mySelfReactionAction:) name:Notification_mySelfReactionAction object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(audioRouteChanged:)
                                                     name:AVAudioSessionRouteChangeNotification
                                                   object:nil];

}



- (void)audioRouteChanged:(NSNotification *)notification {
//    NSDictionary *info = notification.userInfo;
//    AVAudioSessionRouteChangeReason reason = [info[AVAudioSessionRouteChangeReasonKey] unsignedIntegerValue];
//
//    switch (reason) {
//        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
//            NSLog(@" audioRouteChanged New device available");
//            break;
//        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
//            NSLog(@" audioRouteChanged Old device unavailable");
//            [[[ZoomVideoSDK shareInstance]getAudioHelper] setSDKAudioSessionEnv];
//            break;
//        default:
//            break;
//    }
//
//    AVAudioSessionRouteDescription *previousRoute = info[AVAudioSessionRouteChangePreviousRouteKey];
//    NSLog(@"audioRouteChangedAudio Previous route: %@", previousRoute);
}



- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self updateFrame];
}

- (void)updateFrame {
    self.fullScreenCanvas.frame = self.view.bounds;

    [self.topBarView setNeedsLayout];

    UIInterfaceOrientation orientation = GET_STATUS_BAR_ORIENTATION();
    BOOL landscape = UIInterfaceOrientationIsLandscape(orientation);
    if (landscape) {
        if (orientation == UIInterfaceOrientationLandscapeRight && IPHONE_X) {
            self.switchShareBtn.frame = CGRectMake(SAFE_ZOOM_INSETS+10, Top_Height + 5, 180, 35);
        } else {
            self.switchShareBtn.frame = CGRectMake(8, Top_Height + 5, 180, 35);
        }
        self.statisticLabel.frame = CGRectMake(SCREEN_WIDTH - CGRectGetWidth(_topBarView.leaveBtn.frame) - 90 - 30, 23.5, 90, 25);
    } else {
        self.switchShareBtn.frame = CGRectMake(8, (IPHONE_X ? Top_Height + SAFE_ZOOM_INSETS : Top_Height) + 5, 180, 35);
        self.statisticLabel.frame = CGRectMake(SCREEN_WIDTH - 90 - 16, (IPHONE_X ? Top_Height + SAFE_ZOOM_INSETS : Top_Height), 90, 25);
    }

    [self.chatView setNeedsLayout];

    [self.controlBarView setNeedsLayout];
    if (_bottomView) {
        [self.bottomView setNeedsLayout];
    }

    CGRect fullRect = self.fullScreenCanvas.bounds;
    for (UIView *subView in self.fullScreenCanvas.subviews) {
        if (subView.tag == kBackgroudTag) {
            subView.frame = fullRect;
        }

        if (subView.tag == kEmojiTag) {
            subView.frame = CGRectMake(fullRect.size.width * 0.25, fullRect.size.height * 0.25, fullRect.size.width * 0.5, fullRect.size.height * 0.5);
        }
    }

//    self.shareView.frame = self.view.bounds;
//    self.scrollView.frame = self.view.bounds;
//    self.selectImgView.frame = self.view.bounds;
    self.shareView.frame = CGRectMake(0, SCREEN_HEIGHT*0.3, SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.5);
    self.scrollView.frame = CGRectMake(0, 0, SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.5);
    self.selectImgView.frame = CGRectMake(0, 0, SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.5);
    CGFloat bottom = IPHONE_X ? (landscape ? 21.f : 34.f) : 0.0;
    CGFloat right = IPHONE_X ? 44.0 : 0.0;
    CGFloat width = 104.0;
    CGFloat height = 28.0;
    self.stopShareBtn.frame = CGRectMake(SCREEN_WIDTH - width - 16 - right, SCREEN_HEIGHT - 16 - height - bottom, width, height);
}

- (BOOL)shouldAutorotate{
    return YES;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    [UISceneOrientationHelper addOrientationChangeObserver:self selector:@selector(onDeviceOrientationChangeNotification:)];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [UISceneOrientationHelper removeOrientationChangeObserver:self];

#if !TARGET_OS_VISION
    [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationPortrait) forKey:@"orientation"];
    [UIViewController attemptRotationToDeviceOrientation];
#endif
}

- (void)dealloc {
    [self cleanUp];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [[KGModal sharedInstance] hideAnimated:NO];
}

- (void)cleanUp {
    if ([ZoomVideoSDK shareInstance].delegate == self) {
        [ZoomVideoSDK shareInstance].delegate = nil;
    }
    [self stopUpdateTimer];
}

- (void)keyBoardWillShow:(NSNotification *)notification {
    [self.chatInputView keyBoardWillShow:notification];
    self.chatView.hidden = NO;
    self.controlBarView.hidden = NO;
}

- (void)keyBoardDidShow:(NSNotification *)notification {
    [self.chatView updateFrame:NO notification:notification];
}

- (void)keyBoardWillHide:(NSNotification *)notification {
    [self.chatInputView keyBoardWillHide:notification];
}

- (void)keyBoardDidHide:(NSNotification *)notification {
    [self.chatView updateFrame:YES notification:notification];
}


- (void)initSubView {

    [self initfullScreenCanvas];

    _topBarView = [[TopBarView alloc] init];

    [self updateTitleIsJoined:NO];

    __weak CanvasViewController *weakSelf = self;
    _topBarView.endOnClickBlock = ^(void) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Are you sure that you want to leave the session?"
                                                                                 message:nil
                                                                          preferredStyle:UIAlertControllerStyleActionSheet];

        if ([[[[ZoomVideoSDK shareInstance] getSession] getMySelf] isInSubSession] && weakSelf.currentParticipant) {
            [alertController addAction:[UIAlertAction actionWithTitle:@"LeaveSubSesssion"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action) {
                ZoomVideoSDKError ret= [weakSelf.currentParticipant returnToMainSession];
                NSLog(@"returnToMainSession ;%lu",(unsigned long)ret);
                                                              }]];
        }

        [alertController addAction:[UIAlertAction actionWithTitle:@"Leave"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
                                                              [[ZoomVideoSDK shareInstance] leaveSession:NO];
                                                              [weakSelf dismissViewControllerAnimated:YES completion:nil];
                                                          }]];

        if ([[[[ZoomVideoSDK shareInstance] getSession] getMySelf] isHost]) {
            [alertController addAction:[UIAlertAction actionWithTitle:@"End Session"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action) {
                                                                  [[ZoomVideoSDK shareInstance] leaveSession:YES];
                                                              }]];
        }
        if (self.fullScreenCanvas.isBroadcastStreamingViewer) {
            [alertController addAction:[UIAlertAction actionWithTitle:@"leaveStreaming"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action) {
                self.fullScreenCanvas.isBroadcastStreamingViewer = NO;
                [[[ZoomVideoSDK shareInstance] getBroadcastStreamingViewerHelper] leaveStreaming];
                [weakSelf dismissViewControllerAnimated:YES completion:nil];
            }]];

        }

        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        }]];

        UIPopoverPresentationController *popover = alertController.popoverPresentationController;
        if (popover)
        {
            UIButton *btn = weakSelf.topBarView.leaveBtn;
            popover.sourceView = btn;
            popover.sourceRect = btn.bounds;
            popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
        }
        [weakSelf presentViewController:alertController animated:YES completion:nil];
    };
    _topBarView.sessionInfoOnClickBlock = ^(void) {
        [weakSelf showSessionInfo];
    };

    [self.view addSubview:_topBarView];
    [self.view addSubview:self.switchShareBtn];
    [self.view addSubview:self.statisticLabel];
}

- (BottomBarView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[BottomBarView alloc] initWithDelegate:self];
        _bottomView.frame = CGRectMake(0, SCREEN_HEIGHT - kTableHeight, SCREEN_WIDTH, kTableHeight);
        [self.view addSubview:_bottomView];
    }

    return _bottomView;
}

- (SwitchBtn *)switchShareBtn {
    if (!_switchShareBtn) {
        _switchShareBtn = [[SwitchBtn alloc] initWithFrame:CGRectZero];
        [_switchShareBtn setTitle:@"Switch to Share" forState:UIControlStateNormal];
        _switchShareBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        [_switchShareBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _switchShareBtn.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
        _switchShareBtn.clipsToBounds = YES;
        _switchShareBtn.layer.cornerRadius = 6;
        [_switchShareBtn addTarget:self action:@selector(switchToShare:) forControlEvents:UIControlEventTouchUpInside];
        _switchShareBtn.hidden = YES;
    }

    return _switchShareBtn;
}

- (ControlBar *)controlBarView {
    if (!_controlBarView) {
        _controlBarView = [[ControlBar alloc] init];
        __weak CanvasViewController *weakSelf = self;
        _controlBarView.chatOnClickBlock = ^(void) {
            [weakSelf.chatInputView showKeyBoard];
        };
        _controlBarView.controlBarClickBlock = ^(NSInteger type) {
            if (type == kTagButtonShare) {
                [weakSelf showShareOptionView];
            }
            else if (type == kTagButtonSubsession) {
                if ([weakSelf.view.subviews containsObject:weakSelf.subSessionView] ) {
                    [weakSelf.subSessionView removeFromSuperview];
                }
                else {
                    [weakSelf.view addSubview:weakSelf.subSessionView];
                }
            }
        };
    }
    return _controlBarView;
}

- (DemoTestSubsessionView *)subSessionView {
    if (!_subSessionView) {
        _subSessionView = [[DemoTestSubsessionView alloc] initWithFrame:CGRectMake(50, self.view.frame.size.height - 300, self.view.frame.size.width - 100, 300)];
    }
    return _subSessionView;
}

- (UILabel *)statisticLabel {
    if (!_statisticLabel) {
        _statisticLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _statisticLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
        _statisticLabel.font = [UIFont systemFontOfSize:9.0];
        _statisticLabel.textColor = [UIColor whiteColor];
        _statisticLabel.numberOfLines = 1;
        _statisticLabel.textAlignment = 1;
        _statisticLabel.clipsToBounds = YES;
        _statisticLabel.layer.cornerRadius = 6.0;
        _statisticLabel.hidden = YES;
    }
    return _statisticLabel;
}

- (void)initfullScreenCanvas {
    self.fullScreenCanvas = [[ZoomView alloc] initWithFrame:self.view.bounds];
    self.fullScreenCanvas.backgroundColor = [UIColor blackColor];

    // subscribe my video;
    ZoomVideoSDKUser *mySelfUser = [[[ZoomVideoSDK shareInstance] getSession] getMySelf];
    self.fullScreenCanvas.user = [[[ZoomVideoSDK shareInstance] getSession] getMySelf];
    self.fullScreenCanvas.dataType = ZoomVideoSDKVideoType_VideoData;
    [[mySelfUser getVideoCanvas] subscribeWithView:self.fullScreenCanvas aspectMode:ZoomVideoSDKVideoAspect_LetterBox andResolution:ZoomVideoSDKVideoResolution_Auto];
    [[SDKPiPHelper shared] updatePiPVideoUser:mySelfUser videoType:ZoomVideoSDKVideoType_VideoData];

    [self startUpdateTimer];
    [self.view addSubview:self.fullScreenCanvas];

    self.fullScreenCanvas.userInteractionEnabled = YES;
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSingleTap)];
    [self.fullScreenCanvas addGestureRecognizer:tapGesture];
}

- (void)onSingleTap {
    if ([self.chatInputView.chatTextField isEditing]) {
        [self.chatInputView hideKeyBoard];
        return;
    }

    if (self.chatView.hidden == NO) {
        [UIView animateWithDuration:0.3 animations:^{
            self.chatView.hidden = YES;
            self.controlBarView.hidden = YES;
            self.statisticLabel.alpha = 0.0;
        }];
    } else {
        [UIView animateWithDuration:0.3 animations:^{
            self.chatView.hidden = NO;
            self.controlBarView.hidden = NO;
            self.statisticLabel.alpha = 1.0;
        }];
    }
}

- (ZoomVideoSDKShareAction *)getStartedShareAction:(ZoomVideoSDKUser*)user {
    for (ZoomVideoSDKShareAction * shareAction in [user getShareActionList]) {
        if ([shareAction getShareStatus] == ZoomVideoSDKReceiveSharingStatus_Start) {
            return shareAction;
        }
    }
    return nil;
}

- (void)leave
{
    ZoomVideoSDKUser *user = self.fullScreenCanvas.user;
    if ([self getStartedShareAction:user]) {
        [[self getStartedShareAction:user].getShareCanvas unSubscribeWithView:self.fullScreenCanvas];
    }
    else {
        [[user getVideoCanvas] unSubscribeWithView:self.fullScreenCanvas];
    }
    [self.fullScreenCanvas removeFromSuperview];
    [self stopThumbViewVideo];
    [self.bottomView removeAllThumberViewItem];
    [self.avatarArr removeAllObjects];

    [self stopUpdateTimer];

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)noVideofailBack {
    ZoomVideoSDKUser *user = [[[ZoomVideoSDK shareInstance] getSession] getMySelf];
    self.fullScreenCanvas.user = user;
    if ([self getStartedShareAction:user]) {
        self.fullScreenCanvas.dataType = ZoomVideoSDKVideoType_ShareData;
        [[[self getStartedShareAction:user] getShareCanvas] subscribeWithView:self.fullScreenCanvas aspectMode:ZoomVideoSDKVideoAspect_Original andResolution:ZoomVideoSDKVideoResolution_Auto];
        [[SDKPiPHelper shared] updatePiPVideoUser:user videoType:ZoomVideoSDKVideoType_ShareData];
    } else {
        self.fullScreenCanvas.dataType = ZoomVideoSDKVideoType_VideoData;
        [[user getVideoCanvas] subscribeWithView:self.fullScreenCanvas aspectMode:ZoomVideoSDKVideoAspect_LetterBox andResolution:ZoomVideoSDKVideoResolution_Auto];
        [[SDKPiPHelper shared] updatePiPVideoUser:user videoType:ZoomVideoSDKVideoType_VideoData];
    }
}

- (void)showSessionInfo {
    NSLog(@"showSessionInfo");
    NSLog(@"SessionID = %@", [[[ZoomVideoSDK shareInstance] getSession] getSessionID]);
    [[KGModal sharedInstance] setModalBackgroundColor:[UIColor whiteColor]];
    [[KGModal sharedInstance] setCloseButtonType:KGModalCloseButtonTypeNone];
    [[KGModal sharedInstance] setTapOutsideToDismiss:YES];
    [[KGModal sharedInstance] showWithContentView:[self alertViewOfSessionInfo] andAnimated:YES];
}

- (UIView*)alertViewOfSessionInfo {
    UIView *dialogView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 237)];
    dialogView.layer.masksToBounds = YES;

    NSArray *userArr = [[[ZoomVideoSDK shareInstance] getSession] getRemoteUsers];
    ZoomVideoSDKSession *session = [[ZoomVideoSDK shareInstance] getSession];

    //Title Label
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, 21, 256, 24)];
    titleLabel.text = NSLocalizedString(@"Session Information", @"");
    titleLabel.textColor = RGBCOLOR(0x23, 0x23, 0x23);
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [dialogView addSubview:titleLabel];

    UILabel *sessionNameTitle = [[UILabel alloc] initWithFrame:CGRectMake(24, CGRectGetMaxY(titleLabel.frame) + 25, 256, 20)];
    sessionNameTitle.text = NSLocalizedString(@"Session name", @"");
    sessionNameTitle.textColor = RGBCOLOR(0x74, 0x74, 0x87);
    sessionNameTitle.textAlignment = NSTextAlignmentLeft;
    sessionNameTitle.font = [UIFont systemFontOfSize:12.0];
    [dialogView addSubview:sessionNameTitle];

    UILabel *sessionNameValue = [[UILabel alloc] initWithFrame:CGRectMake(24, CGRectGetMaxY(sessionNameTitle.frame), 256, 16)];
    sessionNameValue.text = session.getSessionName;
    sessionNameValue.textColor = RGBCOLOR(0x23, 0x23, 0x23);
    sessionNameValue.textAlignment = NSTextAlignmentLeft;
    sessionNameValue.font = [UIFont boldSystemFontOfSize:16.0];
    [dialogView addSubview:sessionNameValue];

    UILabel *pswTitle = [[UILabel alloc] initWithFrame:CGRectMake(24, CGRectGetMaxY(sessionNameValue.frame) + 20, 256, 20)];
    pswTitle.text = NSLocalizedString(@"Password", @"");
    pswTitle.textColor = RGBCOLOR(0x74, 0x74, 0x87);
    pswTitle.textAlignment = NSTextAlignmentLeft;
    pswTitle.font = [UIFont systemFontOfSize:12.0];
    [dialogView addSubview:pswTitle];

    BOOL hasPassword = (session.getSessionPassword && ![session.getSessionPassword isEqualToString:@""]);
    UILabel *pswValue = [[UILabel alloc] initWithFrame:CGRectMake(24, CGRectGetMaxY(pswTitle.frame), 256, 16)];
    pswValue.text = hasPassword ? session.getSessionPassword : @"Not Set";
    pswValue.textColor = hasPassword ? RGBCOLOR(0x23, 0x23, 0x23) : RGBCOLOR(0x74, 0x74, 0x87);
    pswValue.textAlignment = NSTextAlignmentLeft;
    pswValue.font = [UIFont boldSystemFontOfSize:16.0];
    [dialogView addSubview:pswValue];

    UILabel *participantsTitle = [[UILabel alloc] initWithFrame:CGRectMake(24, CGRectGetMaxY(pswValue.frame) + 20, 256, 20)];
    participantsTitle.text = NSLocalizedString(@"Participants", @"");
    participantsTitle.textColor = RGBCOLOR(0x74, 0x74, 0x87);
    participantsTitle.textAlignment = NSTextAlignmentLeft;
    participantsTitle.font = [UIFont systemFontOfSize:12.0];
    [dialogView addSubview:participantsTitle];

    NSUInteger count = userArr.count + 1;
    UILabel *pValue = [[UILabel alloc] initWithFrame:CGRectMake(24, CGRectGetMaxY(participantsTitle.frame), 256, 16)];
    pValue.text = [NSString stringWithFormat:@"%@", @(count)];
    pValue.textColor = RGBCOLOR(0x23, 0x23, 0x23);
    pValue.textAlignment = NSTextAlignmentLeft;
    pValue.font = [UIFont boldSystemFontOfSize:16.0];
    [dialogView addSubview:pValue];

    return dialogView;
}

- (void)showShareOptionView {
    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:@"Share" message:nil preferredStyle: UIAlertControllerStyleActionSheet];
    if (@available(iOS 11.0, *)) {
        [sheet addAction:[UIAlertAction actionWithTitle:@"Share Device Screen"
                                                  style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                                                    if ([[[ZoomVideoSDK shareInstance] getShareHelper] isShareLocked]) {
                                                        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                                                        hud.mode = MBProgressHUDModeText;
                                                        hud.label.text = @"Share is locked by admin";
                                                        hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
                                                        [hud hideAnimated:YES afterDelay:2.f];
                                                        return;
                                                    }
                                                    if ([[[ZoomVideoSDK shareInstance] getShareHelper] isOtherSharing]) {
                                                        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                                                        hud.mode = MBProgressHUDModeText;
                                                        hud.label.text = @"Some one is alerady sharing";
                                                        hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
                                                        [hud hideAnimated:YES afterDelay:2.f];
                                                        return;
                                                    }

                                                    if (@available(iOS 12.0, *)) {
                                                        RPSystemBroadcastPickerView *broadcastView = [[RPSystemBroadcastPickerView alloc] init];
                                                        broadcastView.preferredExtension = @"group.test.sdk";
                                                        broadcastView.tag = kBroadcastPickerTag;
                                                        [self.view addSubview:broadcastView];
                                                        [self sendTouchDownEventToBroadcastButton];
                                                    } else {
                                                        // Guide page
                                                    }
                                                  }]];
    }
    [sheet addAction:[UIAlertAction actionWithTitle:@"Share a Picture"
                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                                                  [UIView animateWithDuration: 0. delay: 0 options: UIViewAnimationOptionLayoutSubviews  animations:^{

                                                  } completion:^(BOOL finished){
                                                      BOOL isOtherSharing = [[[ZoomVideoSDK shareInstance] getShareHelper] isOtherSharing];
                                                      if (isOtherSharing) {
                                                          MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                                                          hud.mode = MBProgressHUDModeText;
                                                          hud.label.text = @"Others are sharing";
                                                          hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
                                                          [hud hideAnimated:YES afterDelay:2.f];
                                                          return;
                                                      }

                                                      UIImagePickerController *controller = [[UIImagePickerController alloc] init];
                                                      controller.delegate = self;
                                                      controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                                      [self presentViewController:controller animated:YES completion:^{

                                                      }];
                                                  } ];
                                              }]];
#if !TARGET_OS_VISION
    [sheet addAction:[UIAlertAction actionWithTitle:@"Share current camera"
                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                                                  [UIView animateWithDuration: 0. delay: 0 options: UIViewAnimationOptionLayoutSubviews  animations:^{

                                                  } completion:^(BOOL finished){
                                                      BOOL isOtherSharing = [[[ZoomVideoSDK shareInstance] getShareHelper] isOtherSharing];
                                                      if (isOtherSharing) {
                                                          MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                                                          hud.mode = MBProgressHUDModeText;
                                                          hud.label.text = @"Others are sharing";
                                                          hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
                                                          [hud hideAnimated:YES afterDelay:2.f];
                                                          return;
                                                      }
                                                      self.shareView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT*0.3, SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.5)];
                                                      [self.view addSubview:self.shareView];
                                                      ZoomVideoSDKError ret = [[[ZoomVideoSDK shareInstance] getShareHelper] startShareCamera:self.shareView];
                                                      if (ret != Errors_Success) {
                                                          MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                                                          hud.mode = MBProgressHUDModeText;
                                                          hud.label.text = @"Share error";
                                                          hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
                                                          [hud hideAnimated:YES afterDelay:2.f];
                                                          return;
                                                      }

                                                      UIInterfaceOrientation orientation = GET_STATUS_BAR_ORIENTATION();
                                                      BOOL landscape = UIInterfaceOrientationIsLandscape(orientation);
                                                      CGFloat bottom = IPHONE_X ? (landscape ? 21.f : 34.f) : 0.0;
                                                      CGFloat right = IPHONE_X ? 44.0 : 0.0;
                                                      CGFloat width = 104.0;
                                                      CGFloat height = 28.0;
                                                      self.stopShareBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - width - 16 - right, SCREEN_HEIGHT - 16 - height - bottom, width, height)];
                                                      [self.stopShareBtn setTitle:@"STOP SHARE" forState:UIControlStateNormal];
                                                      self.stopShareBtn.clipsToBounds = YES;
                                                      self.stopShareBtn.layer.cornerRadius = height * 0.5;
                                                      self.stopShareBtn.titleLabel.font = [UIFont systemFontOfSize:12.0];
                                                      self.stopShareBtn.backgroundColor = [UIColor redColor];
                                                      [self.stopShareBtn addTarget:self action:@selector(stopShareBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
                                                      [self.view addSubview:self.stopShareBtn];
                                                  }];
                                              }]];
#endif
    [sheet addAction:[UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil]];

    UIPopoverPresentationController *popover = sheet.popoverPresentationController;
    if (popover)
    {
        UIButton *btn = (UIButton*)self.controlBarView.shareBtn;
        popover.sourceView = btn;
        popover.sourceRect = btn.bounds;
        popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }

    [self presentViewController:sheet animated:YES completion:nil];
}

- (void)sendTouchDownEventToBroadcastButton
{
    if (@available(iOS 12.0, *)) {
        RPSystemBroadcastPickerView *broadcastView = [self.view viewWithTag:kBroadcastPickerTag];
        if (!broadcastView) return;


        for (UIView *subView in broadcastView.subviews) {
            if ([subView isKindOfClass:[UIButton class]])
            {
                UIButton *broadcastBtn = (UIButton *)subView;
                [broadcastBtn sendActionsForControlEvents:UIControlEventAllTouchEvents];
                break;
            }
        }
    }
}

- (void)showReconnectingUI
{
    [self stopThumbViewVideo];
    [self.bottomView removeAllThumberViewItem];
    [self.avatarArr removeAllObjects];

    [UIView animateWithDuration:0.3 animations:^{
        [self.chatView removeFromSuperview];
        [self.chatInputView removeFromSuperview];
        [self.controlBarView removeFromSuperview];
        self.statisticLabel.alpha = 0.0;
    }];

    [self updateTitleIsJoined:NO];
    ZoomVideoSDKUser *my = [[[ZoomVideoSDK shareInstance] getSession] getMySelf];
    self.fullScreenCanvas.user = my;
    self.fullScreenCanvas.dataType = ZoomVideoSDKVideoType_VideoData;
    [my.getVideoCanvas subscribeWithView:self.fullScreenCanvas aspectMode:ZoomVideoSDKVideoAspect_LetterBox andResolution:ZoomVideoSDKVideoResolution_Auto];
    [[SDKPiPHelper shared] updatePiPVideoUser:my videoType:ZoomVideoSDKVideoType_VideoData];
}

- (void)showZoomPasswordAlert:(BOOL)wrongPwd
{
    NSString *message = wrongPwd ? NSLocalizedString(@"Incorrect password, please try again", @"") : NSLocalizedString(@"Please enter your password", @"");

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Password";
        textField.secureTextEntry = YES;
    }];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if (self.joinSessionOrIgnorePasswordBlock) {
            ZoomVideoSDKError error = self.joinSessionOrIgnorePasswordBlock(nil, YES);
            NSLog(@"Cancel error code : %@", @(error));
        }
    }];

    UIAlertAction *joinAction = [UIAlertAction actionWithTitle:@"Join" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (self.joinSessionOrIgnorePasswordBlock) {
            NSString *password = alert.textFields.firstObject.text;
            ZoomVideoSDKError error = self.joinSessionOrIgnorePasswordBlock(password, NO);
            if (error != Errors_Success) {
                [self showZoomPasswordAlert:YES];
            }
            NSLog(@"Input password error code : %@", @(error));
        }
    }];

    [alert addAction:cancelAction];
    [alert addAction:joinAction];

    [self presentViewController:alert animated:YES completion:nil];
}


#pragma mark - uiimagepicker delegate -
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

    self.shareView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT*0.3, SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.5)];//CGRectMake(0, SCREEN_HEIGHT*0.3, SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.5)
    UIImage *selectPic = info[UIImagePickerControllerOriginalImage];
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.5)];//CGRectMake(0, 0, SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.5)
    self.scrollView.backgroundColor = [UIColor blackColor];
    self.scrollView.delegate = self;
    self.scrollView.bounces = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.minimumZoomScale = 1.0;
    self.scrollView.maximumZoomScale = 3.0;
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleShareTap:)];
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.numberOfTouchesRequired = 1;
    [self.scrollView addGestureRecognizer:doubleTap];

    self.selectImgView = [[UIImageView alloc] initWithImage:selectPic];
    self.selectImgView.contentMode = UIViewContentModeScaleAspectFit;
    self.selectImgView.frame = CGRectMake(0, 0, SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.5);//CGRectMake(0, 0, SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.5)

    [self.scrollView addSubview:self.selectImgView];
    [self.shareView addSubview:self.scrollView];
    [self.view addSubview:self.shareView];
    [picker dismissViewControllerAnimated:YES completion:nil];

    UIInterfaceOrientation orientation = GET_STATUS_BAR_ORIENTATION();
    BOOL landscape = UIInterfaceOrientationIsLandscape(orientation);
    CGFloat bottom = IPHONE_X ? (landscape ? 21.f : 34.f) : 0.0;
    CGFloat right = IPHONE_X ? 44.0 : 0.0;
    CGFloat width = 104.0;
    CGFloat height = 28.0;

    self.stopShareBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - width - 16 - right, SCREEN_HEIGHT - 16 - height - bottom, width, height)];
    [self.stopShareBtn setTitle:@"STOP SHARE" forState:UIControlStateNormal];
    self.stopShareBtn.clipsToBounds = YES;
    self.stopShareBtn.layer.cornerRadius = height * 0.5;
    self.stopShareBtn.titleLabel.font = [UIFont systemFontOfSize:12.0];
    self.stopShareBtn.backgroundColor = [UIColor redColor];
    [self.stopShareBtn addTarget:self action:@selector(stopShareBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.stopShareBtn];

//    1. normal share with view
    [[[ZoomVideoSDK shareInstance] getShareHelper] startShareWithView:self.shareView];

//    2. share with startShareWithPreprocessing:sharePreprocessor:
//    ZoomVideoSDKSharePreprocessParam *param = [ZoomVideoSDKSharePreprocessParam new];
//    param.type = ZoomVideoSDKSharePreprocessType_view;
//    param.view = self.shareView;
//    [[[ZoomVideoSDK shareInstance] getShareHelper] startShareWithPreprocessing:param sharePreprocessor:[SharePreprocessHelper shareInstance]];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.selectImgView;
}

- (void)handleDoubleShareTap:(UIGestureRecognizer *)gestureRecognizer
{
    CGFloat zs = self.scrollView.zoomScale;
    zs = (zs == self.scrollView.minimumZoomScale) ? self.scrollView.maximumZoomScale : self.scrollView.minimumZoomScale;
    CGRect zoomRect = [self zoomRectForScale: zs withCenter: [gestureRecognizer locationInView: gestureRecognizer.view]];
    [self.scrollView zoomToRect: zoomRect animated: YES];
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center
{
    CGRect zoomRect;

    CGFloat w = [self.scrollView frame].size.width;
    CGFloat h = [self.scrollView frame].size.height;
    zoomRect.size.height = h / scale;
    zoomRect.size.width  = w / scale;

    CGFloat x = center.x - (zoomRect.size.width  / 2.0);
    CGFloat y = center.y - (zoomRect.size.height / 2.0);

    CGSize shareSource = self.view.bounds.size;
    CGFloat offsetX = fabs(shareSource.width / scale - w) / 2;
    CGFloat offsetY = fabs(shareSource.height / scale - h) / 2;
    if (x < offsetX) x = 0;
    if (y < offsetY) y = 0;
    if (x > offsetX && (x + zoomRect.size.width) * scale > shareSource.width) x = (shareSource.width - w) / scale;
    if (y > offsetY && (y + zoomRect.size.height) * scale > shareSource.height) y = (shareSource.height - h) / scale;
    zoomRect.origin.x = x;
    zoomRect.origin.y = y;

    return zoomRect;
}

- (void)stopShareBtnClicked:(id)sender {
    NSLog(@"stop share");
    [self.shareView removeFromSuperview];
    [self.stopShareBtn removeFromSuperview];

    [[[ZoomVideoSDK shareInstance] getShareHelper] stopShare];

    [self pinMyself];
}


#pragma mark - ZoomVideoSDK delegate -
- (void)onError:(ZoomVideoSDKError)ErrorType detail:(NSInteger)details
{

    NSLog(@"ErrorDetails========%@",@(details));

    switch (ErrorType) {
        case Errors_Session_Join_Failed:
        {
            [self leave];
        }
            break;
        case Errors_Session_Disconnecting:
        {
        }
            break;
        case Errors_Session_Reconnecting:
        {
            [self showReconnectingUI];
        }
            break;
        default:
            break;
    }


}

- (void)onSessionJoin {
    NSLog(@"onSessionJoin====>");

    [[SDKCallKitManager sharedManager] startCallWithHandle:@"testemail@zoom.us" complete:^{
        NSLog(@" ----CallKitManager startCall Complete ------");
        [[SDKPiPHelper shared] presetPiPWithSrcView:self.view];
    }];

    _chatView = [[ChatView alloc] init];
    [self.view addSubview:_chatView];
    _chatView.userInteractionEnabled = YES;
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSingleTap)];
    [_chatView addGestureRecognizer:tapGesture];

    self.chatInputView = [[ChatInputView alloc] initWithView:self.view];
    self.chatInputView.delegate = self;
    [self.view addSubview:self.chatInputView];
    self.chatInputView.hidden = NO;

    [self.view addSubview:self.controlBarView];

    [self updateTitleIsJoined:YES];

    ZoomVideoSDKUser *mySelf = [[[ZoomVideoSDK shareInstance] getSession] getMySelf];
    if (mySelf) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self onUserJoin:nil users:@[mySelf]];
        });
    }
    if ([[[[ZoomVideoSDK shareInstance] getSession] getMySelf] isInSubSession]) {
        [self.subSessionView reloadData];
    }
}

- (void)onSessionLeave:(ZoomVideoSDKSessionLeaveReason)reason {
    NSLog(@"onSessionLeave====>");
    [self cleanUp];
    [self leave];

    [[SDKPiPHelper shared] cleanUpPictureInPicture];
    [[SDKCallKitManager sharedManager] endCallWithComplete:^{
        NSLog(@"----CallKitManager endCall Complete ------");
    }];
}

- (void)onUserJoin:(ZoomVideoSDKUserHelper *)helper users:(NSArray<ZoomVideoSDKUser *> *)userArray {
    NSLog(@"onUserJoin====>");
    self.fullScreenCanvas.user = [[[ZoomVideoSDK shareInstance] getSession] getMySelf];
    NSMutableArray *allUser = [[[[ZoomVideoSDK shareInstance] getSession] getRemoteUsers] mutableCopy];
    [allUser addObject:[[[ZoomVideoSDK shareInstance] getSession] getMySelf]];

    for (int i = 0; i < allUser.count; i++) {
        ZoomVideoSDKUser *user = allUser[i];
        if ([self.avatarArr containsObject:user]) {
            continue;
        }

        [self.avatarArr addObject:user];

        ZoomView *view = [[ZoomView alloc] initWithFrame:CGRectMake(15, 10, kTableHeight - 15 * 2, kCellHeight - 10)];
        view.user = user;
        view.backgroundColor = [UIColor blackColor];
        view.dataType = ZoomVideoSDKVideoType_VideoData;

        [[user getVideoCanvas] subscribeWithView:view aspectMode:ZoomVideoSDKVideoAspect_PanAndScan andResolution:ZoomVideoSDKVideoResolution_Auto];

        ViewItem *item = [[ViewItem alloc] init];
        item.user = user;
        item.view = view;
        item.isActive = NO;
        item.itemName = user.getUserName;

        [self.bottomView addThumberViewItem:item];

        if (!helper) {
            [self viewItemSelected:item];
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self updateAvatar:view user:user];
        });
    }
    [self.view insertSubview:self.controlBarView aboveSubview:self.bottomView];
    if (![[[ZoomVideoSDK shareInstance] getShareHelper] isSharingOut]) {
        [self.view bringSubviewToFront:self.chatInputView];
    }

    [self updateTitleIsJoined:YES];
}

- (void)onUserLeave:(ZoomVideoSDKUserHelper *)helper users:(NSArray<ZoomVideoSDKUser *> *)userArray {
    for (int i = 0; i < userArray.count; i++) {
        ZoomVideoSDKUser *user = userArray[i];

        NSArray *items = [self.bottomView getThumberViewItems:user];
        for (ViewItem *item in items) {
            ZoomView *view = (ZoomView *)item.view;
            ZoomVideoSDKUser *user = item.user;
            if ([self getStartedShareAction:user]) {
                [[[self getStartedShareAction:user] getShareCanvas] unSubscribeWithView:view];
            } else {
                [[user getVideoCanvas] unSubscribeWithView:view];
            }
        }
        [self.bottomView removeThumberViewItemWithUser:user];
        [self.avatarArr removeObject:user];

        if (self.fullScreenCanvas.user == user) {
            [self pinMyself];
        }
    }

    [self updateTitleIsJoined:YES];
}

- (void)onCloudRecordingStatus:(ZoomVideoSDKRecordingStatus)status recordAgreementHandler:(ZoomVideoSDKRecordAgreementHandler *)handler;
{
    if (status == ZoomVideoSDKRecordingStatus_Start) {
//        [handler accept];
//        [handler decline];
    }
}

- (void)updateAvatar:(ZoomView *)canvas user:(ZoomVideoSDKUser *)user{
    if (!canvas) {
        return;
    }

    NSMutableArray *needRemove = [NSMutableArray new];
    for (UIView *view in [canvas subviews]) {
        if (view.tag == kEmojiTag) {
            [needRemove addObject:view];
        }
        if (view.tag == kBackgroudTag) {
            [needRemove addObject:view];
        }
    }
    [needRemove makeObjectsPerformSelector:@selector(removeFromSuperview)];

    BOOL isVideoOn = user.getVideoCanvas.videoStatus.on ;
    NSLog(@"user:%@   .isVideoOn=======%@",[user getUserName],@(isVideoOn));
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"user:%@   .videoStatus.on==-------=====%@",[user getUserName],@(isVideoOn));
        if (!isVideoOn && (canvas.dataType == ZoomVideoSDKVideoType_VideoData)) {
            UIView *bgView = [[UIView alloc] initWithFrame:canvas.bounds];
            bgView.backgroundColor = RGBCOLOR(0x23, 0x23, 0x23);
            bgView.tag = kBackgroudTag;
            [canvas addSubview:bgView];
            [canvas insertSubview:bgView atIndex:1];

            ZoomVideoSDKUser *litter_user = user;
            NSInteger index = [self.avatarArr indexOfObject:litter_user];
            if (index == NSNotFound) index = 0;
            NSString *imageName = [NSString stringWithFormat:@"default_avatar"];
            UIImage *image = [UIImage imageNamed:imageName
                                        inBundle:SampleUIResourcesBundle()
                   compatibleWithTraitCollection:nil];
            UIImageView *view = [[UIImageView alloc] initWithImage:image];
            view.frame = CGRectMake(canvas.bounds.size.width * 0.25, canvas.bounds.size.height * 0.25, canvas.bounds.size.width * 0.5, canvas.bounds.size.height * 0.5);
            view.contentMode = UIViewContentModeScaleAspectFit;
            view.tag = kEmojiTag;
            [canvas addSubview:view];
        }
        else {
            NSMutableArray *needRemove = [NSMutableArray new];
            for (UIView *view in [canvas subviews]) {
                if (view.tag == kEmojiTag) {
                    [needRemove addObject:view];
                }
                if (view.tag == kBackgroudTag) {
                    [needRemove addObject:view];
                }
            }
            [needRemove makeObjectsPerformSelector:@selector(removeFromSuperview)];
        }
    });
}

- (void)onUserVideoStatusChanged:(ZoomVideoSDKVideoHelper *)helper user:(NSArray <ZoomVideoSDKUser *>*)userArray {
    NSLog(@"onUserVideoStatusChanged====>: %@", userArray);

    for (int i = 0; i < userArray.count; i++) {
        ZoomVideoSDKUser *user = userArray[i];
        NSLog(@"onUserVideoStatusChanged====> name:%@ videoStatus: %@",[user getUserName], @([user getVideoCanvas].videoStatus.on));
        // update full cavas avatar
        if (user == self.fullScreenCanvas.user) {
            [self updateAvatar:self.fullScreenCanvas user:user];
        }

        // update bottom cavas avatar
        ZoomView *canvas = [self getBottomCanvsViewByUser:user];
        [self updateAvatar:canvas user:user];
    }
}

- (void)onUserShareStatusChanged:(ZoomVideoSDKShareHelper * _Nullable)helper user:(ZoomVideoSDKUser * _Nullable)user shareAction:(ZoomVideoSDKShareAction*_Nullable)shareAction
{
    NSLog(@"-- %s",__func__);
    ZoomVideoSDKReceiveSharingStatus status = [shareAction getShareStatus];
    NSLog(@"onUserShareStatusChanged====>%@, %@",user, @(status));
    ZoomVideoSDKUser *myUser = [[[ZoomVideoSDK shareInstance] getSession] getMySelf];
    if ([user isEqual:myUser]) {
        return;
    }

    if (status == ZoomVideoSDKReceiveSharingStatus_Start) {
        self.fullScreenCanvas.dataType = ZoomVideoSDKVideoType_ShareData;
        self.fullScreenCanvas.shareAction = shareAction;
        [[shareAction getShareCanvas] subscribeWithView:self.fullScreenCanvas aspectMode:ZoomVideoSDKVideoAspect_Original andResolution:ZoomVideoSDKVideoResolution_Auto];
        [[SDKPiPHelper shared] updatePiPVideoUser:user videoType:ZoomVideoSDKVideoType_ShareData];
    } else if (status == ZoomVideoSDKReceiveSharingStatus_Stop) {
        self.fullScreenCanvas.dataType = ZoomVideoSDKVideoType_VideoData;
        self.fullScreenCanvas.shareAction = nil;
        [[user getVideoCanvas] subscribeWithView:self.fullScreenCanvas aspectMode:ZoomVideoSDKVideoAspect_LetterBox andResolution:ZoomVideoSDKVideoResolution_Auto];
        [[SDKPiPHelper shared] updatePiPVideoUser:user videoType:ZoomVideoSDKVideoType_VideoData];
    }

    self.fullScreenCanvas.user = user;
    [self updateAvatar:self.fullScreenCanvas user:user];

    if (status == ZoomVideoSDKReceiveSharingStatus_Start) {
        self.switchShareBtn.sharedUser = user;
        NSArray *viewItems = [self.bottomView getThumberViewItems:user];
        ViewItem *item = [viewItems firstObject];
        [self viewItemSelected:item];
        ZoomView *view = (ZoomView *)item.view;
        view.dataType = ZoomVideoSDKVideoType_VideoData;
        [[user getVideoCanvas] subscribeWithView:view aspectMode:ZoomVideoSDKVideoAspect_LetterBox andResolution:ZoomVideoSDKVideoResolution_Auto];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self stopThumbViewVideo];
            [self.bottomView scrollToVisibleArea:item];
        });
    } else {
        self.switchShareBtn.sharedUser = nil;
    }

    for (ViewItem *item in self.bottomView.viewArray) {
        if ([user isEqual:item.user]) {
            [self viewItemSelected:item];
        }
    }
    self.switchShareBtn.hidden = YES;
}

- (void)onShareCanvasSubscribeFailWithUser:(ZoomVideoSDKUser *_Nullable)user view:(UIView *_Nullable)view shareAction:(ZoomVideoSDKShareAction*_Nullable)shareAction {
    NSLog(@"-- %s   %d",__func__, [shareAction getSubscribeFailReason]);
}

- (void)onUserActiveAudioChanged:(ZoomVideoSDKUserHelper *)helper users:(NSArray<ZoomVideoSDKUser *> *)userArray {
    for (ZoomVideoSDKUser *user in userArray) {
        [self.bottomView activeThumberViewItem:user];
    }

    [self startSpeakerTimer];
}

- (void)onUserAudioStatusChanged:(ZoomVideoSDKAudioHelper *)helper user:(NSArray <ZoomVideoSDKUser *>*)userArray; {
// can update audio UI here
    ZoomVideoSDKUser *myUser = [[[ZoomVideoSDK shareInstance] getSession] getMySelf];
    for (ZoomVideoSDKUser *user in userArray) {
        if ([user isEqual:myUser]) {
            if (user.audioStatus.audioType == ZoomVideoSDKAudioType_None) {
                [self.controlBarView.audioBtn setImage:[UIImage imageNamed:@"icon_no_audio"
                                                                  inBundle:SampleUIResourcesBundle()
                                             compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
            } else {
                if (!user.audioStatus.isMuted) {
                    [self.controlBarView.audioBtn setImage:[UIImage imageNamed:@"icon_mute"
                                                                      inBundle:SampleUIResourcesBundle()
                                                 compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
                } else {
                    [self.controlBarView.audioBtn setImage:[UIImage imageNamed:@"icon_unmute"
                                                                      inBundle:SampleUIResourcesBundle()
                                                 compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
                }
            }
        }
    }
}

- (void)onChatNewMessageNotify:(ZoomVideoSDKChatHelper *)helper message:(ZoomVideoSDKChatMessage *)chatMessage {
    [self.chatView.chatMsgArray addObject:chatMessage];
    [self.chatView.tableView reloadData];
    [self.chatView scrollToBottom];
}

- (void)onChatMsgDeleteNotification:(ZoomVideoSDKChatHelper * _Nullable)helper messageID:(NSString * __nonnull)msgID deleteBy:(ZoomVideoSDKChatMsgDeleteBy) type {
    ZoomVideoSDKChatMessage *deleteMsg ;
    for (ZoomVideoSDKChatMessage *msg in self.chatView.chatMsgArray) {
        if ([msg.messageID isEqualToString:msgID]) {
            deleteMsg = msg;
            break;
        }
    }
    [self.chatView.chatMsgArray removeObject:deleteMsg];
    [self.chatView.tableView reloadData];
}

- (void)onChatPrivilegeChanged:(ZoomVideoSDKChatHelper * _Nullable)helper privilege:(ZoomVideoSDKChatPrivilegeType)currentPrivilege {
    NSLog(@"--- %s currentPrivilege:%d",__FUNCTION__,currentPrivilege);
}

- (void)onInviteByPhoneStatus:(ZoomVideoSDKPhoneStatus)status failReason:(ZoomVideoSDKPhoneFailedReason)failReason  {
    NSLog(@"--- %s status: %@  failReason:%@",__FUNCTION__,@(status),@(failReason));
}


- (void)onLiveTranscriptionStatus:(ZoomVideoSDKLiveTranscriptionStatus)status {
    NSLog(@"%s:%@",__FUNCTION__,status == ZoomVideoSDKLiveTranscriptionStatus_Stop ? @"ZoomVideoSDKLiveTranscriptionStatus_Stop":@"ZoomVideoSDKLiveTranscriptionStatus_Start");
}

- (void)onLiveTranscriptionMsgReceived:(ZoomVideoSDKLiveTranscriptionMessageInfo *)messageInfo {
    NSLog(@"%s:%@",__FUNCTION__,messageInfo.description);
}
- (void)onOriginalLanguageMsgReceived:(ZoomVideoSDKLiveTranscriptionMessageInfo*)messageInfo {
    NSLog(@"%s:%@",__FUNCTION__,messageInfo.description);
}
- (void)onLiveTranscriptionMsgError:(ZoomVideoSDKLiveTranscriptionLanguage *)spokenLanguage transLanguage:(ZoomVideoSDKLiveTranscriptionLanguage *)transcriptLanguage {
    NSLog(@"%s:spokenLanguage:%@ transcriptLanguage:%@",__FUNCTION__,spokenLanguage.description,transcriptLanguage.description);
}

- (void)onSessionNeedPassword:(ZoomVideoSDKError (^)(NSString *password, BOOL leaveSessionIgnorePassword))completion
{
    if (completion) {
        self.joinSessionOrIgnorePasswordBlock = completion;

        [self showZoomPasswordAlert:NO];
    }
}

- (void)onSessionPasswordWrong:(ZoomVideoSDKError (^)(NSString *password, BOOL leaveSessionIgnorePassword))completion
{
    if (completion) {
        self.joinSessionOrIgnorePasswordBlock = completion;

        [self showZoomPasswordAlert:YES];
    }
}

- (void)onUserHostChanged:(ZoomVideoSDKUserHelper * _Nullable)helper users:(ZoomVideoSDKUser * _Nullable)user
{
}

- (void)onMultiCameraStreamStatusChanged:(ZoomVideoSDKMultiCameraStreamStatus)status parentUser:(ZoomVideoSDKUser *)user videoCanvas:(ZoomVideoSDKVideoCanvas *)videoCanvas
{


    NSLog(@"---%s   --%@",__FUNCTION__,@(status));
}

- (void)onCallCRCDeviceStatusChanged:(ZoomVideoSDKCRCCallStatus)state {
    NSLog(@"---%s   --%@",__FUNCTION__,@(state));
}

- (void)onSystemPermissionRequired:(ZoomVideoSDKSystemPermissionType)permissionType
{

    NSString *alertTitle = @"system permission needed";
    switch (permissionType) {
        case ZoomVideoSDKSystemPermissionType_Camera:
            alertTitle = @"Can't Access Camera";
            break;
        case ZoomVideoSDKSystemPermissionType_Microphone:
            alertTitle = @"Can't Access Microphone";
            break;
        default:
            break;
    }
    NSString *alertMsg = @"please turn on the toggle in system settings to grant permission";

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle
                                                                             message:alertMsg
                                                                      preferredStyle:UIAlertControllerStyleAlert];

    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)onCloudRecordingStatus:(ZoomVideoSDKRecordingStatus)status
{
    NSLog(@"Cloud Recording::onCloudRecordingStatus:%@", @(status));
}

- (void)onHostAskUnmute
{
    NSLog(@"onHostAskUnmute=>");
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = @"The host would like you to unmute";
    hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
    [hud hideAnimated:YES afterDelay:2.f];
}

- (void)onProxySettingNotification:(ZoomVideoSDKProxySettingHandler *_Nonnull)handler{
    NSLog(@"Fun：%s --- line %d  ",__FUNCTION__,__LINE__);
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"Proxy Settings"message:@"Please input Prpxy name and password" preferredStyle:UIAlertControllerStyleAlert];
    [alertVC addTextFieldWithConfigurationHandler:^(UITextField*textField) {
        textField.placeholder=@"Username";
    }];
    [alertVC addTextFieldWithConfigurationHandler:^(UITextField*textField) {
        textField.placeholder=@"Password";
        textField.secureTextEntry=YES;
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [handler cancel];
    }];
    __weak UIAlertController *w_alertVC = alertVC;
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *name  = w_alertVC.textFields[0].text;
        NSString *psw= w_alertVC.textFields[1].text;
        [handler inputUsername:name password:psw];
    }];

    [alertVC addAction: ok];
    [alertVC addAction: cancel];
    [self presentViewController:alertVC animated:NO completion:nil];
}

- (void)onSSLCertVerifiedFailNotification:(ZoomVideoSDKSSLCertificateInfo *)handler {
    NSLog(@"Fun：%s --- line %d",__FUNCTION__,__LINE__);
}

- (void)onUserVideoNetworkStatusChanged:(ZoomVideoSDKNetworkStatus)status user:(ZoomVideoSDKUser *)user
{
    NSLog(@"Fun：%s --- line %d",__FUNCTION__,__LINE__);
}

- (void)onAnnotationHelperCleanUp:(ZoomVideoSDKAnnotationHelper *)helper
{
    NSLog(@"Fun：%s --- line %d",__FUNCTION__,__LINE__);
    [[[ZoomVideoSDK shareInstance] getShareHelper] destroyAnnotationHelper:helper];
}

- (void)onAnnotationPrivilegeChangeWithUser:(ZoomVideoSDKUser *_Nullable)user shareAction:(ZoomVideoSDKShareAction*_Nullable)shareAction;
{
    NSLog(@"Fun：%s --- line %d, enable:%d, user:%@",__FUNCTION__,__LINE__, [shareAction isAnnotationPrivilegeEnabled], user.getUserName);
}

- (void)onSendFileStatus:(ZoomVideoSDKSendFile * _Nullable)file status:(ZoomVideoSDKFileTransferStatus)status
{
    NSLog(@"Fun：%s --- line %d, file:%@, status:%@",__FUNCTION__,__LINE__, file, @(status));
}

- (void)onReceiveFileStatus:(ZoomVideoSDKReceiveFile * _Nullable)file status:(ZoomVideoSDKFileTransferStatus)status
{
    NSLog(@"Fun：%s --- line %d, file:%@, status:%@",__FUNCTION__,__LINE__, file, @(status));
    if (status == FileTransferState_ReadyToTransfer) {
        NSString *tmpDirectory = NSTemporaryDirectory();
        ZoomVideoSDKError err = [file startReceive:[NSString stringWithFormat:@"%@/%@", tmpDirectory, file.getFileName]];
        NSLog(@"Fun：%s --- line %d, status:%@",__FUNCTION__,__LINE__, @(err));
    }
}

- (void)onUVCCameraStatusChange:(ZoomVideoSDKUVCCameraStatus)status
{
    NSLog(@"Fun：%s --- line %d, status:%@",__FUNCTION__,__LINE__, @(status));
}

- (void)onShareContentSizeChanged:(ZoomVideoSDKShareHelper *)helper user:(ZoomVideoSDKUser *)user shareAction:(ZoomVideoSDKShareAction*)shareAction
{
    NSLog(@"Fun：%s --- line %d, status:%@",__FUNCTION__,__LINE__, @(shareAction.getShareSourceContentSize));
}

- (void)onShareContentChanged:(ZoomVideoSDKShareHelper *)shareHelper user:(ZoomVideoSDKUser *)user shareAction:(ZoomVideoSDKShareAction *)shareAction
{
    if (shareAction.getShareType == ZoomVideoSDKShareType_Normal && [[ZoomVideoSDK shareInstance] getShareHelper].isSharingOut) {

    }
    NSLog(@"Fun：%s --- line %d, userId:%@, shareType:%@",__FUNCTION__,__LINE__, @(user.getUserID), @(shareAction.getShareType));
}

#pragma mark Whiteboard -

#if !TARGET_OS_VISION
- (void)onWhiteboardExported:(ZoomVideoSDKWhiteboardExportFormatType)format data:(NSData*)data {
    NSLog(@"%s format:%@ %@ ",__FUNCTION__,@(format),data);
    switch (format) {
        case ZoomVideoSDKWhiteboardExport_Format_PDF:
        {
            NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
            NSString *tmpath = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"whiteboard_%d.pdf",arc4random()%100000]];
            if([data writeToFile:tmpath atomically:YES]) {
                [self exportPDFToFilesApp:tmpath];
            }
        }
            break;
        default:
            break;
    }
}
#endif


#if !TARGET_OS_VISION
-(void)onUserWhiteboardShareStatusChanged:(ZoomVideoSDKUser *)user whiteboardheler:(ZoomVideoSDKWhiteboardHelper*)whiteboardHelper {
    NSLog(@"%s user:%@ %@ ",__FUNCTION__,@(user.getWhiteboardStatus),whiteboardHelper);
    if (user.getWhiteboardStatus == ZoomVideoSDKWhiteboardStatus_Started) {
        self.controlBarView.backgroundColor = [UIColor blackColor];
        [[[ZoomVideoSDK shareInstance] getWhiteboardHelper] subscribeWhiteboard:self];
    }
    else {
        [[[ZoomVideoSDK shareInstance] getWhiteboardHelper] unSubscribeWhiteboard];
    }
    [self.view bringSubviewToFront:self.controlBarView];
}
#endif

#pragma mark -sub session -
- (void)onSubSessionStatusChanged:(ZoomVideoSDKSubSessionStatus)status subSession:(NSArray <ZoomVideoSDKSubSessionKit*>* _Nonnull)pSubSessionKitList {
    NSLog(@"%s  %@  %@ ",__FUNCTION__,@(status) ,pSubSessionKitList.description);
    self.subSessionView.pSubSessionKitList = pSubSessionKitList;
    [self.subSessionView reloadData];
}
- (void)onSubSessionListUpdate:(NSArray <ZoomVideoSDKSubSessionKit*>* _Nonnull) pSubSessionKitList {
    self.subSessionView.pSubSessionKitList = pSubSessionKitList;
    [self.subSessionView reloadData];
    NSLog(@"%s  %@ ",__FUNCTION__,pSubSessionKitList);
}
- (void)onSubSessionManagerHandle:(ZoomVideoSDKSubSessionManager* _Nullable)pManager {
   self.subSessionView.sessionManager = pManager;
   [self.subSessionView reloadData];
   NSLog(@"%s  %@ ",__FUNCTION__,pManager);
}
- (void)onSubSessionParticipantHandle:(ZoomVideoSDKSubSessionParticipant* _Nullable)pParticipant {
    self.subSessionView.pParticipant = pParticipant;
    self.currentParticipant = pParticipant;
    [self.subSessionView reloadData];
    NSLog(@"%s  %@ ",__FUNCTION__,pParticipant);
}
- (void)onSubSessionUsersUpdate:(ZoomVideoSDKSubSessionKit* _Nonnull)pSubSessionKit {
    NSLog(@"%s  %@ ",__FUNCTION__,pSubSessionKit);
    [self.subSessionView reloadData];
}

- (void)onBroadcastMessageFromMainSession:(NSString* _Nonnull) sMessage userName:(NSString* _Nonnull)sUserName {
    NSLog(@"%s  %@  %@ ",__FUNCTION__,sMessage,sUserName );
    [self.subSessionView reloadData];
}


- (void)onSubSessionUserHelpRequestHandler:(ZoomVideoSDKSubSessionUserHelpRequestHandler*_Nonnull) pHandler {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"Help:%@ %@",[pHandler getRequestUserName],[pHandler getRequestSubSessionName]]
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];

    [alertController addAction:[UIAlertAction actionWithTitle:@"joinSubSessionByUserRequest"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        ZoomVideoSDKError ret = [pHandler joinSubSessionByUserRequest];
        NSLog(@"pHandler  joinSubSessionByUserRequest ret %lu",(unsigned long)ret);
                                                      }]];

    [alertController addAction:[UIAlertAction actionWithTitle:@"ignore" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        ZoomVideoSDKError ret = [pHandler ignore];
        NSLog(@"pHandler  ignore ret %lu",(unsigned long)ret);
                                                      }]];

    [self presentViewController:alertController animated:YES completion:nil];


}
- (void)onSubSessionUserHelpRequestResult:(ZoomVideoSDKUserHelpRequestResult)result {
    NSLog(@"%s    %@  ",__FUNCTION__,@(result));
    [self.subSessionView reloadData];
}



#pragma mark - audio rawdata delegate -
- (void)onMixedAudioRawDataReceived:(ZoomVideoSDKAudioRawData *)rawData
{
    NSLog(@"onMixedAudioRawDataReceived %@", rawData);
}

- (void)onOneWayAudioRawDataReceived:(ZoomVideoSDKAudioRawData *)rawData user:(ZoomVideoSDKUser *)user
{
    NSLog(@"onOneWayAudioRawDataReceived %@", rawData);
}

- (void)onSharedAudioRawDataReceived:(ZoomVideoSDKAudioRawData *)rawData
{
    NSLog(@"onSharedAudioRawDataReceived %@", rawData);
}


#pragma mark - Broadcast

- (void)onStartBroadcastResponse:(BOOL)bSuccess channelID:(NSString* _Nonnull)channelID  {
    NSLog(@"--- %s  %@  %@ ",__func__,@(bSuccess),channelID);
    if (bSuccess) {
        [_controlBarView.broadcastChannelIDs addObject:channelID];
    }
}


- (void)onStopBroadcastResponse:(BOOL)bSuccess  {
    NSLog(@"--- %s  %@  ",__func__,@(bSuccess));
    if (_controlBarView.broadcastChannelIDs.count > 0) {
        [_controlBarView.broadcastChannelIDs removeLastObject];
    }
}
- (void)onGetBroadcastControlStatus:(BOOL)bSuccess status:(ZoomVideoSDKBroadcastControlStatus)status  {
    NSLog(@"--- %s  %@  %@ ",__func__,@(bSuccess),@(status));
}
- (void)onStreamingJoinStatusChanged:(ZoomVideoSDKStreamingJoinStatus)status  {
    NSLog(@"--- %s  %@  ",__func__,@(status));
    switch (status) {
        case ZoomVideoSDKStreamingJoinStatus_Joined:
        {
            self.fullScreenCanvas.isBroadcastStreamingViewer = YES;
        }
            break;

        case ZoomVideoSDKStreamingJoinStatus_Left:

            break;
        default:
            break;
    }
}


#pragma mark - ChatInputViewDelegate -
- (void)sendAction:(NSString *)chatString
{
    NSLog(@"chatString===>%@",chatString);

    if (chatString.length == 0) {
        return;
    }

    [[[ZoomVideoSDK shareInstance] getChatHelper] SendChatToAll:chatString];
}

#pragma mark - BottomBarViewDelegate -
- (void)stopThumbViewVideo {
    for (ViewItem *item in self.bottomView.viewArray) {
        ZoomView *view = (ZoomView *)item.view;
        ZoomVideoSDKUser *user = view.user;
        if ([self getStartedShareAction:user]) {
            [[[self getStartedShareAction:user] getShareCanvas] unSubscribeWithView:view];
        } else {
            [[user getVideoCanvas] unSubscribeWithView:view];
        }
    }
}

- (void)startThumbViewVideo {
    NSArray <UITableViewCell *> *cellArray = self.bottomView.thumbTableView.visibleCells;

    for (int i = 0; i < cellArray.count; i++) {
        UITableViewCell *cell = [cellArray objectAtIndex:i];
        NSIndexPath *indexPath = [self.bottomView.thumbTableView indexPathForCell:cell];

        ViewItem *item = [self.bottomView.viewArray objectAtIndex:indexPath.row];
        ZoomView *view = (ZoomView *)item.view;
        view.dataType = ZoomVideoSDKVideoType_VideoData;
        ZoomVideoSDKUser *user = view.user;
        [[user getVideoCanvas] subscribeWithView:view aspectMode:ZoomVideoSDKVideoAspect_PanAndScan andResolution:ZoomVideoSDKVideoResolution_Auto];
    }
}

- (void)pinThumberViewItem:(ViewItem *)item {

    if (!item) {
        return;
    }

    NSLog(@"Pin thumbernail view %@", item);
    ZoomVideoSDKUser *itemUser = item.user;

    ZoomVideoSDKUser *olduser = self.fullScreenCanvas.user;

    self.fullScreenCanvas.user = itemUser;
    self.fullScreenCanvas.dataType = ZoomVideoSDKVideoType_VideoData;
    [[itemUser getVideoCanvas] subscribeWithView:self.fullScreenCanvas aspectMode:ZoomVideoSDKVideoAspect_PanAndScan andResolution:ZoomVideoSDKVideoResolution_Auto];
    [[SDKPiPHelper shared] updatePiPVideoUser:itemUser videoType:ZoomVideoSDKVideoType_VideoData];

    if (olduser.getVideoCanvas.videoStatus.on != itemUser.getVideoCanvas.videoStatus.on && self.fullScreenCanvas.dataType != ZoomVideoSDKVideoType_ShareData) {
         [self updateAvatar:self.fullScreenCanvas user:itemUser];;
    }

    [self viewItemSelected:item];
    for (ViewItem *item in self.bottomView.viewArray) {
        item.isPin = NO;
    }
    item.isPin = YES;

    [self updateTitleIsJoined:YES];

    if (self.switchShareBtn.sharedUser) {
        self.switchShareBtn.hidden = NO;
    }
}

- (void)scrollToThumberViewItem:(ViewItem *)item {
    if (!item) {
        return;
    }

    UIView *view = item.view;
    ZoomVideoSDKUser *itemUser = item.user;
    [[itemUser getVideoCanvas] subscribeWithView:view aspectMode:ZoomVideoSDKVideoAspect_PanAndScan andResolution:ZoomVideoSDKVideoResolution_Auto];
}

- (void)pinMyself {
    ZoomVideoSDKUser *myUser = [[[ZoomVideoSDK shareInstance] getSession] getMySelf];
    for (ViewItem *item in self.bottomView.viewArray) {
        if ([myUser isEqual:item.user]) {
            [self pinThumberViewItem:item];
            [self.bottomView scrollToVisibleArea:item];
        }
    }
}

- (void)viewItemSelected:(ViewItem *)item {
    for (ViewItem *item in self.bottomView.viewArray) {
        item.view.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.5].CGColor;
    }

    item.view.layer.borderColor = [UIColor greenColor].CGColor;
}

- (void)switchToShare:(SwitchBtn *)switchShareBtn {
    switchShareBtn.hidden = YES;

    if (!switchShareBtn.sharedUser) {
        return;
    }

    self.fullScreenCanvas.dataType = ZoomVideoSDKVideoType_ShareData;
    self.fullScreenCanvas.user = switchShareBtn.sharedUser;
    [[self.fullScreenCanvas.shareAction getShareCanvas] subscribeWithView:self.fullScreenCanvas aspectMode:ZoomVideoSDKVideoAspect_Original andResolution:ZoomVideoSDKVideoResolution_Auto];
    [[SDKPiPHelper shared] updatePiPVideoUser:switchShareBtn.sharedUser videoType:ZoomVideoSDKVideoType_ShareData];

    for (ViewItem *item in self.bottomView.viewArray) {
        if ([switchShareBtn.sharedUser isEqual:item.user]) {
            [self viewItemSelected:item];
        }
    }
}

- (void)startSpeakerTimer {
    if ([self.speakerTimer isValid]) {
        [self stopSpeakerTimer];
    }
    if (@available(iOS 10.0, *)) {
        self.speakerTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 repeats:NO
                                                              block:^(NSTimer * _Nonnull timer) {
                                                                  [self speakerOffAll];
                                                              }];
    } else {
        // Fallback on earlier versions
    }
}

- (void)stopSpeakerTimer {
    [self.speakerTimer invalidate];
    self.speakerTimer = nil;
}

- (void)speakerOffAll {
    [self.bottomView deactiveAllThumberView];
}

- (void)updateTitleIsJoined:(BOOL)isJoined
{
    BOOL beforeSession = NO;
    ZoomVideoSDKSession *session = [[ZoomVideoSDK shareInstance] getSession];
    if (!session) {
        beforeSession = YES;
    }

    if (beforeSession) {
        [self.topBarView updateTopBarWithSessionName:session.getSessionName totalNum:1 password:session.getSessionPassword isJoined:isJoined];
    } else {
        NSArray *allUsers = [session getRemoteUsers];// all remote user(Except me).
        NSString *title = session.getSessionName;
        if ([[[[ZoomVideoSDK shareInstance] getSession] getMySelf] isInSubSession]) {
            title = [NSString stringWithFormat:@"%@(%@)",session.getSessionName,[self.subSessionView.joinedSubSessionkit getSubSessionName]];
        }
        [self.topBarView updateTopBarWithSessionName:title totalNum:allUsers.count+1 password:session.getSessionPassword isJoined:isJoined];
    }
}

- (void)startUpdateTimer {
    if ([self.updateTimer isValid]) {
        [self stopUpdateTimer];
    }

    if (@available(iOS 10.0, *)) {
        __weak typeof(self) wself = self;
        wself.updateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES
                                                             block:^(NSTimer * _Nonnull timer) {
                                                                __strong typeof(wself) sSelf = wself;
                                                                [sSelf updateStatisticInfo];
                                                             }];
    } else {
        // Fallback on earlier versions
    }
}

- (void)stopUpdateTimer {
    if (self.updateTimer) {
        [self.updateTimer invalidate];
        self.updateTimer = nil;
    }
}

- (void)updateStatisticInfo {
    ZoomVideoSDKUser *user = self.fullScreenCanvas.user;
    NSString *statisticStr = @"";
    if (self.fullScreenCanvas.dataType == ZoomVideoSDKVideoType_VideoData) {
        ZoomVideoSDKVideoStatisticInfo *info = [user getVideoStatisticInfo];
        statisticStr = [NSString stringWithFormat:@"%@x%@ %@FPS", @(info.width), @(info.height), @(info.fps)];
    } else {
        ZoomVideoSDKShareStatisticInfo *info = [user getShareStatisticInfo];
        statisticStr = [NSString stringWithFormat:@"%@x%@ %@FPS", @(info.width), @(info.height), @(info.fps)];
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        if (![statisticStr isEqualToString:@"0x0 0FPS"]) {
            self.statisticLabel.hidden = NO;
            self.statisticLabel.text = statisticStr;
        } else {
            self.statisticLabel.hidden = YES;
            self.statisticLabel.text = statisticStr;
        }
    });
}

- (void)onDeviceOrientationChangeNotification:(NSNotification *)aNotification {
#if TARGET_OS_VISION
    // Vision Pro: statusBarOrientation not available, use default orientation
    [[[ZoomVideoSDK shareInstance] getVideoHelper] rotateMyVideo:UIDeviceOrientationPortrait];
#else
    UIDeviceOrientation orientation = [UISceneOrientationHelper currentDeviceOrientation];
    [[[ZoomVideoSDK shareInstance] getVideoHelper] rotateMyVideo:orientation];
#endif
}

- (void)onCommandReceived:(NSString * _Nullable)commandContent sendUser:(ZoomVideoSDKUser * _Nullable)sendUser
{
    NSLog(@"commandContent:%@, sendUser:%@", commandContent, sendUser);

    if ([commandContent hasPrefix:@"Part|"])
    {
        [self.assembler addPart:commandContent];
        if ([self.assembler isComplete]) {
            NSString *comStr = [self.assembler assembledMessage];
            [self handleWithDrawingData:comStr sendUser:sendUser];
        }
        return;
    }

    if ([self handleWithDrawingData:commandContent sendUser:sendUser])
        return;

    NSData *jsonData = [commandContent dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    if (!error && [dict isKindOfClass:[NSMutableDictionary class]]) {
        NSLog(@"dict %@", dict);
        if (dict[@"action"]) {
            NSString *kitID = dict[@"kit"];
            if ([dict[@"action"] isEqualToString:@"join"]) {
                for (ZoomVideoSDKSubSessionKit* kit in self.subSessionView.pSubSessionKitList ) {
                    if ([[kit getSubSessionID] isEqualToString:kitID]) {
                        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"Join session:%@ %@",[kit getSubSessionName],[kit getSubSessionID]]
                                                                                                 message:nil
                                                                                          preferredStyle:UIAlertControllerStyleActionSheet];

                        [alertController addAction:[UIAlertAction actionWithTitle:@"Join"
                                                                            style:UIAlertActionStyleDefault
                                                                          handler:^(UIAlertAction *action) {
                            ZoomVideoSDKError ret = [kit joinSubSession];
                            NSLog(@"joinSubSession ret %lu",(unsigned long)ret);
                                                                          }]];

                        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                        }]];

//                        UIPopoverPresentationController *popover = alertController.popoverPresentationController;
//                        if (popover)
//                        {
//                            UIButton *btn = weakSelf.topBarView.leaveBtn;
//                            popover.sourceView = btn;
//                            popover.sourceRect = btn.bounds;
//                            popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
//                        }
                        [self presentViewController:alertController animated:YES completion:nil];
                    }
                }
            }
            else if ([dict[@"action"] isEqualToString:@"leave"])  {

            }
            return;
        }
    } else {
        NSLog(@"dict failed: %@", error.localizedDescription);
    }


    CmdTpye cmd_type = [[SimulateStorage shareInstance] getCmdTypeFromCmd:commandContent];
    if (cmd_type == CmdTpye_Reaction) {
        for (ViewItem *item in self.bottomView.viewArray) {
            if ([item.user isEqual:sendUser]) {
                kTagReactionTpye reaction_type = [[SimulateStorage shareInstance] getReactionTypeFromCmd:commandContent];
                item.reactionImg.image = [[SimulateStorage shareInstance] getReactionImageFromType:reaction_type];
                item.reactionImg.hidden = NO;

                NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                [dict setObject:item.reactionImg forKey:@"reaction_imageview"];
                [dict setObject:commandContent forKey:@"command_content"];
                if ([SimulateStorage shareInstance].reactionType == kTagReactionTpye_Raisehand
                    && reaction_type != kTagReactionTpye_Raisehand
                    && reaction_type != kTagReactionTpye_Lowerhand) {
                    NSTimer *timer = [NSTimer timerWithTimeInterval:5 target:self selector:@selector(handleRaisehandAndThenEmojiTimer:) userInfo:dict repeats:NO];
                    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
                } else if (reaction_type != kTagReactionTpye_Raisehand && reaction_type != kTagReactionTpye_Lowerhand) {
                    NSTimer *timer = [NSTimer timerWithTimeInterval:5 target:self selector:@selector(handleHideTimer:) userInfo:dict repeats:NO];
                    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
                } else if ([SimulateStorage shareInstance].reactionType == kTagReactionTpye_Raisehand && reaction_type == kTagReactionTpye_Lowerhand) {
                    item.reactionImg.hidden = YES;
                }
                [SimulateStorage shareInstance].reactionType = reaction_type;
            }
        }
    }
}

- (BOOL)handleWithDrawingData:(NSString *)commandContent sendUser:(ZoomVideoSDKUser * _Nullable)sendUser
{
    ZoomVideoSDKUser *my = [[[ZoomVideoSDK shareInstance] getSession] getMySelf];
    if ([commandContent hasPrefix:@"DrawShape"] && (my.getUserID != sendUser.getUserID))
    {
        NSDictionary *dict = [DrawingViewDataHelper parseDrawingShapeString:commandContent];
        DrawingShapeEventType type = (DrawingShapeEventType)([dict[@"eventType"] integerValue]);
        switch (type) {
            case DrawingShapeEventTypeBegin: {
                [self.view addSubview:self.drawingView];
                break;
            }
            case DrawingShapeEventTypeContent: {
                NSString *jsonStr = dict[@"content"];
                if (jsonStr)
                    [self.drawingView addShapeFromJSONString:jsonStr];
                break;
            }
            case DrawingShapeEventTypeEnd: {
                [self.drawingView removeFromSuperview];
                _drawingView = nil;
                break;
            }
            case DrawingShapeEventTypeClear: {
                [self.drawingView claerView];
                break;
            }
            default:
                break;
        }
        return YES;
    }
    return NO;
}

- (void)onCmdChannelConnectResult:(BOOL)success
{
    NSLog(@"[onCmdChannelConnectResult] result:%@",@(success));
}

- (void)handleHideTimer:(NSTimer *)timer {
    UIImageView *reactionImageView = [[timer userInfo] objectForKey:@"reaction_imageview"];
    reactionImageView.hidden = YES;
}

- (void)handleRaisehandAndThenEmojiTimer:(NSTimer *)timer {
    UIImageView *reactionImageView = [[timer userInfo] objectForKey:@"reaction_imageview"];
    reactionImageView.hidden = NO;
    reactionImageView.image = [UIImage imageNamed:@"reaction_raisehand"
                                         inBundle:SampleUIResourcesBundle()
                    compatibleWithTraitCollection:nil];
}

// Simulate yourself receiving your own CMD for local reaction
- (void)mySelfReactionAction:(NSNotification *)notification {
    kTagReactionTpye reaction_type = [notification.object intValue];
    NSString *cmd = [[SimulateStorage shareInstance] generateReactionCmdString:reaction_type];
    if (!cmd) return;
    [self onCommandReceived:cmd sendUser:[[[ZoomVideoSDK shareInstance] getSession] getMySelf]];
}

- (ZoomView *)getBottomCanvsViewByUser:(ZoomVideoSDKUser *)user {
    NSArray *viewItems = [self.bottomView getThumberViewItems:user];
    ViewItem *item = [viewItems firstObject];
    ZoomView *view = (ZoomView *)item.view;
    return view;
}

#pragma mark -anno float bar-


- (void)exportPDFToFilesApp:(NSString *)pdfPath {
    NSURL *fileURL = [NSURL fileURLWithPath:pdfPath];
    UIDocumentPickerViewController *picker = [[UIDocumentPickerViewController alloc] initWithURL:fileURL inMode:UIDocumentPickerModeExportToService];
    picker.delegate = self;
    picker.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller
      didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    NSLog(@"The user has exported the file to: %@", urls);
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
    NSLog(@"The user has cancelled the export");
}

- (void)saveImageToAlbum:(UIImage *)image albumName:(NSString *)albumName {
    __block NSString *localIdentifier = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetChangeRequest *createAssetRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
        localIdentifier = createAssetRequest.placeholderForCreatedAsset.localIdentifier;
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (!success || error) {
            NSLog(@"Failed to save to camera roll: %@", error);
            return;
        }
    }];
}



@end
