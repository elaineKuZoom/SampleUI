//
//  SimulateStorage.m
//  ZoomVideoSample
//
//  Created by Zoom on 2022/1/4.
//  Copyright © 2022 Zoom. All rights reserved.
//

#import "SimulateStorage.h"
#import "InSessionUI/More/MoreMenuViewController.h"

#define kEnableLowerThird   @"kEnableLowerThird"
#define kLowerThirdName     @"kLowerThirdName"
#define kLowerThirddesc     @"kLowerThirddesc"
#define kLowerThirdColorIndex    @"kLowerThirdColorIndex"

#define kHasPopComfirmView @"kHasPopComfirmView"

#define ZOOM_UD [NSUserDefaults standardUserDefaults]
#define COLORARR @[@"#444B53", @"#1E71D6", @"#FD3D4A", @"#66CC84", @"#FF8422", @"#493AB7", @"#A477FF", @"#FFBF39"]

@interface SimulateStorage ()
@property (nonatomic, strong) NSMutableArray *lowerThirdArr;

+ (UIColor *)colorWithHexString:(NSString *)hexString;
@end

@implementation LowerThirdCmd
- (UIColor *)getUsersColor;
{
    return [SimulateStorage colorWithHexString:_colorStr];
}
@end

@implementation SimulateStorage

+ (SimulateStorage*)shareInstance;
{
    static SimulateStorage *instance = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [SimulateStorage new];
    });

    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _lowerThirdArr = [[NSMutableArray alloc] init];
    }
    return self;
}

- (CmdTpye)getCmdTypeFromCmd:(NSString *)cmdString
{
    NSArray *parseArray = [cmdString componentsSeparatedByString:@"|"];
    if (!parseArray || parseArray.count < 2) {
        return CmdTpye_None;
    }

    int type = [parseArray[0] intValue];
    CmdTpye cmd_type = CmdTpye_None;
    switch (type) {
        case 1:
            cmd_type = CmdTpye_Reaction;
            break;
        default:
            break;
    }

    return cmd_type;
}

// ****reaction*******
- (BOOL)sendReactionCmd:(kTagReactionTpye)type {
    NSString * cmdString = [self generateReactionCmdString:type];
    if (!cmdString) return NO;

    ZoomVideoSDKError error = [[[ZoomVideoSDK shareInstance] getCmdChannel] sendCommand:cmdString receiveUser:nil];
    NSLog(@"Reaction::sendCommand===>%@",error == Errors_Success ? @"YES" : @"NO");
    return error == Errors_Success ? YES : NO;
}

- (NSString *)generateReactionCmdString:(kTagReactionTpye)type {
    NSString *cmdString;
    switch (type) {
        case kTagReactionTpye_Clap:
            cmdString = @"1|clap";
            break;
        case kTagReactionTpye_Thumbsup:
            cmdString = @"1|thumbsup";
            break;
        case kTagReactionTpye_Heart:
            cmdString = @"1|heart";
            break;
        case kTagReactionTpye_Joy:
            cmdString = @"1|joy";
            break;
        case kTagReactionTpye_Hushed:
            cmdString = @"1|hushed";
            break;
        case kTagReactionTpye_Tada:
            cmdString = @"1|tada";
            break;
        case kTagReactionTpye_Raisehand:
            cmdString = @"1|raisehand";
            break;
        case kTagReactionTpye_Lowerhand:
            cmdString = @"1|lowerhand";
            break;
        default:
            break;
    }
    return cmdString;
}

- (kTagReactionTpye)getReactionTypeFromCmd:(NSString *)cmdString
{
    NSArray *parseArray = [cmdString componentsSeparatedByString:@"|"];
    if (!parseArray || parseArray.count < 2) {
        return kTagReactionTpye_None;
    }

    kTagReactionTpye type = kTagReactionTpye_None;
    NSString * reactionString = parseArray[1];
    if (!reactionString) return kTagReactionTpye_None;

    if ([@"clap" isEqualToString:reactionString]) {
        type = kTagReactionTpye_Clap;
    } else if ([@"thumbsup" isEqualToString:reactionString]) {
        type = kTagReactionTpye_Thumbsup;
    } else if ([@"heart" isEqualToString:reactionString]) {
        type = kTagReactionTpye_Heart;
    } else if ([@"joy" isEqualToString:reactionString]) {
        type = kTagReactionTpye_Joy;
    } else if ([@"hushed" isEqualToString:reactionString]) {
        type = kTagReactionTpye_Hushed;
    } else if ([@"tada" isEqualToString:reactionString]) {
        type = kTagReactionTpye_Tada;
    } else if ([@"raisehand" isEqualToString:reactionString]) {
        type = kTagReactionTpye_Raisehand;
    } else if ([@"lowerhand" isEqualToString:reactionString]) {
        type = kTagReactionTpye_Lowerhand;
    }

    return type;
}

- (UIImage *)getReactionImageFromType:(kTagReactionTpye)type
{
    UIImage *image = nil;
    switch (type) {
        case kTagReactionTpye_Clap:
            image = [UIImage imageNamed:@"reaction_clap"];
            break;
        case kTagReactionTpye_Thumbsup:
            image = [UIImage imageNamed:@"reaction_thumbsup"];
            break;
        case kTagReactionTpye_Heart:
            image = [UIImage imageNamed:@"reaction_heart"];
            break;
        case kTagReactionTpye_Joy:
            image = [UIImage imageNamed:@"reaction_joy"];
            break;
        case kTagReactionTpye_Hushed:
            image = [UIImage imageNamed:@"reaction_hushed"];
            break;
        case kTagReactionTpye_Tada:
            image = [UIImage imageNamed:@"reaction_tada"];
            break;
        case kTagReactionTpye_Raisehand:
            image = [UIImage imageNamed:@"reaction_raisehand"];
            break;
        default:
            break;
    }

    return image;
}

// ****feedback*******
+ (BOOL)hasPopConfirmView
{
    return [ZOOM_UD boolForKey:kHasPopComfirmView];
}

+ (void)hasPopConfirmView:(BOOL)enable
{
    [ZOOM_UD setBool:enable forKey:kHasPopComfirmView];
    [ZOOM_UD synchronize];
}
@end
