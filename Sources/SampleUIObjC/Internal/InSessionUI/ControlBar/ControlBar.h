//
//  ControlBar.h
//  ZoomVideoSample
//
//  Created by Zoom Communications on 2019/5/27.
//  Copyright © 2019 Zoom. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kTagButtonVideo         2000
#define kTagButtonShare         (kTagButtonVideo+1)
#define kTagButtonAudio         (kTagButtonVideo+2)
#define kTagButtonMore          (kTagButtonVideo+3)
#define kTagButtonSubsession    (kTagButtonVideo+4)
#define kTagShowAnnotation      (kTagButtonVideo+5)

NS_ASSUME_NONNULL_BEGIN

@interface ControlBar : UIView
@property (strong, nonatomic) UIButton          *shareBtn;
@property (strong, nonatomic) UIButton          *audioBtn;
@property (strong, nonatomic) NSMutableArray    *broadcastChannelIDs;

@property (nonatomic,copy) void(^chatOnClickBlock)(void);
@property (nonatomic,copy) void(^controlBarClickBlock)(NSInteger type);
@end

NS_ASSUME_NONNULL_END
