//
//  DemoTestView.h
//  ZoomVideoSample
//
//  Created by ZOOM  on 2025/5/19.
//  Copyright © 2025 Zoom. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DemoTestSubsessionView : UITableView 

@property (nonatomic, strong) NSArray <ZoomVideoSDKSubSessionKit*>*  pSubSessionKitList;
@property (nonatomic, strong) ZoomVideoSDKSubSessionManager*  sessionManager;
@property (nonatomic, strong) ZoomVideoSDKSubSessionParticipant*  pParticipant;
@property (nonatomic, strong) ZoomVideoSDKSubSessionKit *joinedSubSessionkit;

@end

NS_ASSUME_NONNULL_END
