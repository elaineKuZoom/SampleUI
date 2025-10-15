//
//  LeftViewCell.m
//  ZoomVideoSample
//
//  Created by Zoom Communications on 2019/10/24.
//  Copyright © 2019 Zoom. All rights reserved.
//

#import "LeftViewCell.h"

@implementation LeftViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.backgroundColor = [UIColor clearColor];
        
#if TARGET_OS_VISION
        self.textLabel.font = [UIFont systemFontOfSize:20];
#else
        self.textLabel.font = [UIFont systemFontOfSize:15];
#endif
        self.textLabel.textColor = RGBCOLOR(0x23, 0x23, 0x33);

        
        self.separatorView = [UIView new];
        self.separatorView.backgroundColor = RGBCOLOR(0xDE, 0xDE, 0xF4);;
        [self addSubview:self.separatorView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
#if TARGET_OS_VISION
    CGRect imageViewFrame = self.imageView.frame;
    imageViewFrame.size = CGSizeMake(30, 30);
    imageViewFrame.origin.x = 20;
    imageViewFrame.origin.y = (CGRectGetHeight(self.frame) - imageViewFrame.size.height) / 2;
    self.imageView.frame = imageViewFrame;
    
    CGRect textLabelFrame = self.textLabel.frame;
    textLabelFrame.origin.x = MaxX(self.imageView)+25;
    textLabelFrame.size.width = CGRectGetWidth(self.frame) - 32.0;
    self.textLabel.frame = textLabelFrame;
#else
    CGRect textLabelFrame = self.textLabel.frame;
    textLabelFrame.origin.x = MaxX(self.imageView)+15;;
    textLabelFrame.size.width = CGRectGetWidth(self.frame) - 16.0;
    self.textLabel.frame = textLabelFrame;
#endif
    
#if TARGET_OS_VISION
    CGFloat height = 0.5; 
#else
    CGFloat height = UIScreen.mainScreen.scale == 1.0 ? 1.0 : 0.5;
#endif
    
#if TARGET_OS_VISION
    self.separatorView.frame = CGRectMake(20.0,
                                          CGRectGetHeight(self.frame)-height,
                                          CGRectGetWidth(self.frame)*0.85,
                                          height);
#else
    self.separatorView.frame = CGRectMake(0.0,
                                          CGRectGetHeight(self.frame)-height,
                                          CGRectGetWidth(self.frame)*0.9,
                                          height);
#endif
}


@end

