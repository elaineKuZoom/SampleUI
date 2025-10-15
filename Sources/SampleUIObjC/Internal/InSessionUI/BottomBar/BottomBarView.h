//
//  BottomBarView.h
//  ZoomVideoSample
//
//  Created by Zoom Communications on 2019/5/29.
//  Copyright © 2019 Zoom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HorizontalTableView.h"
#import "InSessionUI/Storage/SimulateStorage.h"

#define CALC_WIDTH ((SCREEN_WIDTH) / 3.0)
#define kCellHeight (CALC_WIDTH > 135.0 ? 135.0 : CALC_WIDTH)

#define kTableHeight  (kCellHeight + 20.0)

@class RawdataDelegate;
@interface ViewItem : NSObject
@property (nonatomic, copy) NSString            *itemName;
@property (nonatomic, strong) UIView            *view;
@property (nonatomic, strong) ZoomVideoSDKUser    *user;
@property (nonatomic, assign) BOOL              isActive;
@property (nonatomic, strong) UIImageView       *reactionImg;
@property (nonatomic, strong) UIButton          *moreClickBtn;
@property (nonatomic, assign) BOOL              isPin;
@end

@interface LeftLabel : UILabel

@end

@protocol BottomBarViewDelegate <NSObject>

- (void)pinThumberViewItem:(ViewItem *)item;
- (void)stopThumbViewVideo;
- (void)startThumbViewVideo;
- (void)scrollToThumberViewItem:(ViewItem *)item;
- (void)removeCameraControlView;
@end

@interface BottomBarView : UIView
@property (strong, nonatomic) HorizontalTableView       *thumbTableView;

@property (nonatomic, strong, readonly) NSMutableArray *viewArray;

- (instancetype)initWithDelegate:(id<BottomBarViewDelegate>)delegate;

- (void)addThumberViewItem:(ViewItem *)item;

- (void)updateItem:(ViewItem *)item withViewItem:(ViewItem *)newItem;

- (void)removeThumberViewItem:(ViewItem *)item;

- (void)removeAllThumberViewItem;

- (void)removeThumberViewItemWithUser:(ZoomVideoSDKUser *)user;

- (void)activeThumberViewItem:(ZoomVideoSDKUser *)user;

- (void)deactiveAllThumberView;

- (NSArray *)getThumberViewItems:(ZoomVideoSDKUser *)user;

- (void)scrollToVisibleArea:(ViewItem *)item;

@property (assign, nonatomic) BOOL isCameraControl;
@end

