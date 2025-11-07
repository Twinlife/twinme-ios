/*
 *  Copyright (c) 2022 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "SubscribeCell.h"

#import <TwinmeCommon/Design.h>

#import <Utils/NSString+Utils.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static UIColor *DESIGN_SUBSCRIBE_BACKGROUND_COLOR;
static UIColor *DESIGN_SUBSCRIBE_COLOR;

static int checkCharCode = 0x2713;

//
// Interface: SubscribeCell
//

@interface SubscribeCell()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *subscribeViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *subscribeViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *subscribeViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *subscribeView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *subscribeEnableLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *subscribeEnableLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *subscribeEnableLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *accessoryImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *accessoryImageViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *accessoryImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@end

//
// Implementation: SubscribeCell
//

#undef LOG_TAG
#define LOG_TAG @"SubscribeCell"

@implementation SubscribeCell

- (void)awakeFromNib {
    DDLogVerbose(@"%@ awakeFromNib", LOG_TAG);
    
    [super awakeFromNib];
    
    DESIGN_SUBSCRIBE_BACKGROUND_COLOR = [UIColor colorWithRed:186./255. green:241./255. blue:215./255. alpha:1.0];
    DESIGN_SUBSCRIBE_COLOR = [UIColor colorWithRed:10./255. green:169./255. blue:141./255. alpha:1.0];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    self.titleWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.titleLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.titleTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.title.font = Design.FONT_REGULAR34;
    self.title.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.subscribeViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.subscribeViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.subscribeViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.subscribeView.clipsToBounds = YES;
    self.subscribeView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.subscribeView.backgroundColor = DESIGN_SUBSCRIBE_BACKGROUND_COLOR;
    self.subscribeView.hidden = YES;
    
    self.subscribeEnableLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.subscribeEnableLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.subscribeEnableLabel.font = Design.FONT_MEDIUM32;
    self.subscribeEnableLabel.textColor = DESIGN_SUBSCRIBE_COLOR;
    
    NSString *checkString = [[NSString alloc] initWithBytes:&checkCharCode length:4 encoding:NSUTF32LittleEndianStringEncoding];
    self.subscribeEnableLabel.text = [checkString stringByAppendingString: TwinmeLocalizedString(@"side_menu_view_controller_subscribe_enable", nil)];
    self.accessoryImageViewHeightConstraint.constant = Design.ACCESSORY_HEIGHT;
    self.accessoryImageViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.accessoryImageView.tintColor = Design.ACCESSORY_COLOR;
    self.accessoryImageView.image = [self.accessoryImageView.image imageFlippedForRightToLeftLayoutDirection];
    
    self.separatorViewHeightConstraint.constant = Design.SEPARATOR_HEIGHT;
    self.separatorView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
}

- (void)bind:(BOOL)subscribeEnable {
    DDLogVerbose(@"%@ bind: %@", LOG_TAG, subscribeEnable ? @"YES":@"NO");
    
    if (subscribeEnable) {
        self.subscribeView.hidden = NO;
        self.title.text = TwinmeLocalizedString(@"in_app_subscription_view_controller_title", nil);
    } else {
        self.subscribeView.hidden = YES;
        self.title.text = TwinmeLocalizedString(@"side_menu_view_controller_subscribe", nil);
    }
    
    [self updateFont];
    [self updateColor];
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.title.font = Design.FONT_REGULAR34;
    self.subscribeEnableLabel.font = Design.FONT_MEDIUM32;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    self.separatorView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
    self.title.textColor = Design.FONT_COLOR_DEFAULT;
}

@end
