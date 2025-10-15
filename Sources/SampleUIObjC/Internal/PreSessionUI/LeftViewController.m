//
//  LeftViewController.m
//  ZoomVideoSample
//
//  Created by Zoom Communications on 2019/10/24.
//  Copyright © 2019 Zoom. All rights reserved.
//

#import "LeftViewController.h"
#import "PreSessionUI/LeftViewCell.h"
#import "Vender/LGSideMenuController/UIViewController+LGSideMenuController.h"
#import "PreSessionUI/MainViewController.h"
#import "InSessionUI/LowerThird/LowerThirdSettingViewController.h"

@interface LeftViewController ()

@property (strong, nonatomic) NSArray *titlesArray;

@end

@implementation LeftViewController

- (id)init {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.titlesArray = @[@"Video SDK Playground",
                             @"",
                             @"Lower Third",
                             @"Zoom Video SDK",
                             @"Version",
                             @"",
                             @"",
                             @"Init SDK",
                             @"CleanUp SDK",];

        self.view.backgroundColor = [UIColor clearColor];

        [self.tableView registerClass:[LeftViewCell class] forCellReuseIdentifier:@"cell"];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
#if TARGET_OS_VISION
        self.tableView.contentInset = UIEdgeInsetsMake(80.0, 0.0, 80.0, 0.0);
#else
        self.tableView.contentInset = UIEdgeInsetsMake(44.0, 0.0, 44.0, 0.0);
#endif
        self.tableView.showsVerticalScrollIndicator = NO;
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationFade;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titlesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LeftViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];

    cell.textLabel.text = self.titlesArray[indexPath.row];
    cell.separatorView.hidden = indexPath.row <= 1;
    cell.userInteractionEnabled = (indexPath.row != 0 && indexPath.row != 1);

#if TARGET_OS_VISION
    if (indexPath.row == 0) {
        cell.textLabel.font = [UIFont boldSystemFontOfSize:24.0];
    } else {
        cell.textLabel.font = [UIFont systemFontOfSize:20.0];
    }
#else
    if (indexPath.row == 0) {
        cell.textLabel.font = [UIFont boldSystemFontOfSize:17.0];
    } else {
        cell.textLabel.font = [UIFont systemFontOfSize:15.0];
    }
#endif

    if (indexPath.row == 2) {
        cell.imageView.image = [UIImage imageNamed:@"settings_icon"];
    } else if (indexPath.row == 3) {
        cell.imageView.image = [UIImage imageNamed:@"zoom_doc_icon"];
    } else if (indexPath.row == 4) {
        cell.textLabel.text = [NSString stringWithFormat:@"Version:%@",[[ZoomVideoSDK shareInstance] getSDKVersion]];
    } else {
        cell.imageView.image = nil;
    }

    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
#if TARGET_OS_VISION
    return (indexPath.row == 1) ? 30.0 : 60.0;
#else
    return (indexPath.row == 1) ? 22.0 : 44.0;
#endif
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.row == 2) {
        MainViewController *mainViewController = (MainViewController *)self.sideMenuController;
        [mainViewController hideLeftViewAnimated:YES completionHandler:nil];
        UINavigationController *navigationController = (UINavigationController *)mainViewController.rootViewController;

        LowerThirdSettingViewController *vc = [[LowerThirdSettingViewController alloc] init];
        vc.isPushed = YES;
        [navigationController pushViewController:vc animated:YES];
    }
    else if (indexPath.row == 3) {
        MainViewController *mainViewController = (MainViewController *)self.sideMenuController;
        [mainViewController hideLeftViewAnimated:YES completionHandler:nil];

        NSString *urlString = @"https://marketplace.zoom.us";
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:urlString]]) {
            NSDictionary *options = @{UIApplicationOpenURLOptionUniversalLinksOnly: @NO};
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]
                                              options:options
                                    completionHandler:^(BOOL success) {
                if (!success) {
                    NSLog(@"fail to open url");
                }
            }];
        }
    }
    else if (indexPath.row == 7) {
        [self showInitAlert:cell];
    }
    else if (indexPath.row == 8) {
        [self unInitialize];
    }
}

- (void)showInitAlert:(id)sender
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Init SDK"
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];

    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"please input domain";
    }];

    [alertController addAction:[UIAlertAction actionWithTitle:[NSString stringWithFormat:@"OK"]
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull action) {
        NSString *domain = @"";
        NSString *tfText = alertController.textFields.firstObject.text;
        if (tfText.length <= 0 || !([tfText hasPrefix:@"http://"] || [tfText hasPrefix:@"https://"])) {
            domain = kAppDomain;
        } else {
            domain = tfText;
        }

        [self initZoomSDK:domain];
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


- (void)unInitialize
{
    ZoomVideoSDKError ret = [[ZoomVideoSDK shareInstance] cleanup];
    NSLog(@"[ZoomVideoSDK] cleanup =====>%@", ret == Errors_Success ? @"Success" : @(ret));
}

- (void)initZoomSDK:(NSString *)domain
{
    ZoomVideoSDKInitParams *context = [[ZoomVideoSDKInitParams alloc] init];
    context.domain = domain;
    /**
     * if you need use screen share feature, Here are a few things to note:
     * <1> Create your own app groupId on the Apple Developer Web site, and fill the group ID in this file and in the file SampleHandler.mm
     * <2> Create an "App Groups" Capability in the main project target and the screenshare target, and select the groupId correctly.
     * <3> If you can't select groupId correctly in "App Groups" Capability, Please check files of ZoomVideoSample.entitlements and ZoomVideoSDKScreenShare.entitlements, need to configure the correct group id. etc:
     *   <key>com.apple.security.application-groups</key>
         <array>
             <string> your group id </string>
         </array
     *
     * For details, please refer: https://marketplace.zoom.us/docs/sdk/video/ios/advanced/screen-share
     *
     * if you don't need screen share feature, appGroupId can fill an empty string, or delete the bottom line. And delete ZoomVideoSDKScreenShare target.
     */
    context.appGroupId = kScreenShareBundleId; // please input group id from the Apple Developer Web site.
    context.enableLog = YES;
//    context.logFilePrefix = @"";
//    context.videoRawdataMemoryMode = ZoomVideoSDKRawDataMemoryModeHeap;
//    context.shareRawdataMemoryMode = ZoomVideoSDKRawDataMemoryModeHeap;
//    context.audioRawdataMemoryMode = ZoomVideoSDKRawDataMemoryModeHeap;

//    NSString *speakerFilePath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"mp3"];
//    if (speakerFilePath.length != 0) {
//        context.extendParam.speakerTestFilePath = speakerFilePath;
//    }

    ZoomVideoSDKError ret = [[ZoomVideoSDK shareInstance] initialize:context];
    NSLog(@"[ZoomVideoSDK] initialize =====>%@", ret == Errors_Success ? @"Success" : @(ret));
}
@end
