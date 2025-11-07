/*
 *  Copyright (c) 2022 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Utils/NSString+Utils.h>

#import "DisplayModeCell.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static CGFloat DESIGN_DEVICE_RADIUS = 10;
static CGFloat DESIGN_ITEM_RADIUS = 3;

static UIColor *DESIGN_DARK_PEER_ITEM_COLOR;
static UIColor *DESIGN_PEER_ITEM_COLOR;

//
// Interface: DisplayModeCell
//

@interface DisplayModeCell()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lightViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lightViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *lightView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lightDeviceViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lightDeviceViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *lightDeviceView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lightTimeLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lightTimeLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lightTimeLabelHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *lightTimeLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lightItemViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lightItemViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lightItemViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lightItemViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *lightItemView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lightPeerItemViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lightPeerItemViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lightPeerItemViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *lightPeerItemView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lightCheckMarkViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lightCheckMarkViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *lightCheckMarkView;
@property (weak, nonatomic) IBOutlet UIImageView *lightCheckMarkImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lightLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *lightLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *darkViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *darkViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *darkView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *darkDeviceViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *darkDeviceViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *darkDeviceView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *darkTimeLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *darkTimeLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *darkTimeLabelHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *darkTimeLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *darkItemViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *darkItemViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *darkItemViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *darkItemViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *darkItemView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *darkPeerItemViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *darkPeerItemViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *darkPeerItemViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *darkPeerItemView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *darkCheckMarkViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *darkCheckMarkViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *darkCheckMarkView;
@property (weak, nonatomic) IBOutlet UIImageView *darkCheckMarkImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *darkLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *darkLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@property DisplayMode displayMode;

@end

//
// Implementation: DisplayModeCell
//

#undef LOG_TAG
#define LOG_TAG @"DisplayModeCell"

@implementation DisplayModeCell

+ (void)initialize {
    DDLogVerbose(@"%@ initialize", LOG_TAG);
    
    DESIGN_DARK_PEER_ITEM_COLOR = [UIColor colorWithRed:38./255. green:38./255. blue:41./255. alpha:1];
    DESIGN_PEER_ITEM_COLOR = [UIColor colorWithRed:243./255. green:243./255. blue:243./255. alpha:1];
}

- (void)awakeFromNib {
    DDLogVerbose(@"%@ awakeFromNib", LOG_TAG);
    
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = [UIColor clearColor];
    
    self.lightViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.lightViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.lightView.userInteractionEnabled = YES;
    self.lightView.isAccessibilityElement = YES;
    self.lightView.accessibilityLabel = TwinmeLocalizedString(@"personalization_view_controller_mode_light", nil);
    
    UITapGestureRecognizer *lightViewTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleLightTapGesture:)];
    [self.lightView addGestureRecognizer:lightViewTapGesture];
    
    self.lightDeviceViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.lightDeviceViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.lightDeviceView.clipsToBounds = YES;
    self.lightDeviceView.backgroundColor = [UIColor whiteColor];
    self.lightDeviceView.layer.borderColor = Design.CHECKMARK_BORDER_COLOR.CGColor;
    self.lightDeviceView.layer.borderWidth = Design.ITEM_BORDER_WIDTH;
    self.lightDeviceView.layer.cornerRadius = DESIGN_DEVICE_RADIUS;
    
    self.lightTimeLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.lightTimeLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.lightTimeLabelHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.lightTimeLabel.textColor = [UIColor blackColor];
    self.lightTimeLabel.font = Design.FONT_MEDIUM30;
    
    self.lightItemViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.lightItemViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.lightItemViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.lightItemViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.lightItemView.backgroundColor = Design.MAIN_COLOR;
    self.lightItemView.layer.cornerRadius = DESIGN_ITEM_RADIUS;
    
    self.lightPeerItemViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.lightPeerItemViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.lightPeerItemViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.lightPeerItemView.backgroundColor = DESIGN_PEER_ITEM_COLOR;
    self.lightPeerItemView.layer.cornerRadius = DESIGN_ITEM_RADIUS;
    
    self.lightCheckMarkViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.lightCheckMarkViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.lightCheckMarkView.clipsToBounds = YES;
    
    CALayer *checkMarkViewLayer = self.lightCheckMarkView.layer;
    checkMarkViewLayer.cornerRadius = self.lightCheckMarkViewHeightConstraint.constant * 0.5;
    checkMarkViewLayer.borderWidth = Design.CHECKMARK_BORDER_WIDTH;
    checkMarkViewLayer.borderColor = Design.CHECKMARK_BORDER_COLOR.CGColor;
    
    self.lightCheckMarkView.tintColor = Design.MAIN_COLOR;
    
    self.lightLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.lightLabel.font = Design.FONT_REGULAR34;
    self.lightLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.lightLabel.text = TwinmeLocalizedString(@"personalization_view_controller_mode_light", nil);
    
    self.darkViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.darkViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.darkView.userInteractionEnabled = YES;
    self.darkView.isAccessibilityElement = YES;
    self.darkView.accessibilityLabel = TwinmeLocalizedString(@"personalization_view_controller_mode_dark", nil);
    
    UITapGestureRecognizer *darkViewTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleDarkTapGesture:)];
    [self.darkView addGestureRecognizer:darkViewTapGesture];
    
    self.darkDeviceViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.darkDeviceViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.darkDeviceView.clipsToBounds = YES;
    self.darkDeviceView.backgroundColor = [UIColor blackColor];
    self.darkDeviceView.layer.borderColor = Design.CHECKMARK_BORDER_COLOR.CGColor;
    self.darkDeviceView.layer.borderWidth = Design.ITEM_BORDER_WIDTH;
    self.darkDeviceView.layer.cornerRadius = DESIGN_DEVICE_RADIUS;
    
    self.darkTimeLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.darkTimeLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.darkTimeLabelHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.darkTimeLabel.textColor = [UIColor whiteColor];
    self.darkTimeLabel.font = Design.FONT_MEDIUM30;
    
    self.darkItemViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.darkItemViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.darkItemViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.darkItemViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.darkItemView.backgroundColor = Design.MAIN_COLOR;
    self.darkItemView.layer.cornerRadius = DESIGN_ITEM_RADIUS;
    
    self.darkPeerItemViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.darkPeerItemViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.darkPeerItemViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.darkPeerItemView.backgroundColor = DESIGN_DARK_PEER_ITEM_COLOR;
    self.darkPeerItemView.layer.cornerRadius = DESIGN_ITEM_RADIUS;
    
    self.darkCheckMarkViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.darkCheckMarkViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.darkCheckMarkView.clipsToBounds = YES;
    
    CALayer *darkCheckMarkViewLayer = self.darkCheckMarkView.layer;
    darkCheckMarkViewLayer.cornerRadius = self.darkCheckMarkViewHeightConstraint.constant * 0.5;
    darkCheckMarkViewLayer.borderWidth = Design.CHECKMARK_BORDER_WIDTH;
    darkCheckMarkViewLayer.borderColor = Design.CHECKMARK_BORDER_COLOR.CGColor;
    
    self.darkCheckMarkView.tintColor = Design.MAIN_COLOR;
    
    self.darkLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.darkLabel.font = Design.FONT_REGULAR34;
    self.darkLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.darkLabel.text = TwinmeLocalizedString(@"personalization_view_controller_mode_dark", nil);
    
    self.separatorViewHeightConstraint.constant = Design.SEPARATOR_HEIGHT;
    self.separatorView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
}

- (void)prepareForReuse {
   [super prepareForReuse];
}

- (void)bind:(DisplayMode)displayMode {
   DDLogVerbose(@"%@ bind", LOG_TAG);
   
    self.displayMode = displayMode;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    
    NSDate *date = [[NSDate alloc]init];
    self.lightTimeLabel.text = [dateFormatter stringFromDate:date];
    self.darkTimeLabel.text = [dateFormatter stringFromDate:date];
        
    if (self.displayMode == DisplayModeSystem) {
        self.lightView.alpha = 0.5;
        self.darkView.alpha = 0.5;
        
        if (@available(iOS 13.0, *)) {
            if ([UIScreen mainScreen].traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark){
                self.lightCheckMarkImageView.hidden = YES;
                self.darkCheckMarkImageView.hidden = NO;
            } else {
                self.lightCheckMarkImageView.hidden = NO;
                self.darkCheckMarkImageView.hidden = YES;
            }
        } else {
            self.lightCheckMarkImageView.hidden = NO;
            self.darkCheckMarkImageView.hidden = YES;
        }
    } else {
        self.lightView.alpha = 1.0;
        self.darkView.alpha = 1.0;
        
        if (self.displayMode == DisplayModeLight) {
            self.lightCheckMarkImageView.hidden = NO;
            self.darkCheckMarkImageView.hidden = YES;
        } else {
            self.lightCheckMarkImageView.hidden = YES;
            self.darkCheckMarkImageView.hidden = NO;
        }
    }
    
    [self updateFont];
    [self updateColor];
}

- (void)handleLightTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleLightTapGesture: %@", LOG_TAG, sender);
    
    if (self.displayMode != DisplayModeSystem && sender.state == UIGestureRecognizerStateEnded) {
        self.lightCheckMarkImageView.hidden = NO;
        self.darkCheckMarkImageView.hidden = YES;
        
        if ([self.delegate respondsToSelector:@selector(didSelectMode:)]) {
            [self.delegate didSelectMode:DisplayModeLight];
        }
    }
}

- (void)handleDarkTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleLightTapGesture: %@", LOG_TAG, sender);
    
    if (self.displayMode != DisplayModeSystem && sender.state == UIGestureRecognizerStateEnded) {
        self.lightCheckMarkImageView.hidden = YES;
        self.darkCheckMarkImageView.hidden = NO;
        
        if ([self.delegate respondsToSelector:@selector(didSelectMode:)]) {
            [self.delegate didSelectMode:DisplayModeDark];
        }
    }
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.lightTimeLabel.font = Design.FONT_MEDIUM30;
    self.darkTimeLabel.font = Design.FONT_MEDIUM30;
    self.lightLabel.font = Design.FONT_REGULAR34;
    self.darkLabel.font = Design.FONT_REGULAR34;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    self.lightLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.darkLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.lightItemView.backgroundColor = Design.MAIN_COLOR;
    self.darkItemView.backgroundColor = Design.MAIN_COLOR;
    self.lightCheckMarkImageView.tintColor = Design.MAIN_COLOR;
    self.darkCheckMarkImageView.tintColor = Design.MAIN_COLOR;
    self.separatorView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
}

@end
