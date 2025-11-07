/*
 *  Copyright (c) 2020-2022 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Utils/NSString+Utils.h>

#import "PeerMessageItemCell.h"

#import "PreviewAppearanceCell.h"

#import <TwinmeCommon/Design.h>
#import "DecoratedLabel.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static const CGFloat DESIGN_TEXT_HEIGHT_PADDING = 16;
static const CGFloat DESIGN_TEXT_WIDTH_PADDING = 32;
static const CGFloat DESIGN_MESSAGE_CELL_MAX_WIDTH = 502;
static const CGFloat DESIGN_PEER_MESSAGE_CELL_MAX_WIDTH = 408;
static const CGFloat DESIGN_LARGE_ROUND_CORNER_RADIUS = 38;
static const CGFloat DESIGN_SMALL_ROUND_CORNER_RADIUS = 8;

static UIColor *DESIGN_SHADOW_COLOR;

//
// Interface: PreviewAppearanceCell ()
//

@interface PreviewAppearanceCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backgroundImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeLabelHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeLabelTopConstraint;
@property (weak, nonatomic) IBOutlet DecoratedLabel *timeLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *peerContentLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet DecoratedLabel *peerContentLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentLabelTopConstraint;
@property (weak, nonatomic) IBOutlet DecoratedLabel *contentLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stateImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stateImageViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stateImageViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *stateImageView;

@end

//
// Implementation: PreviewAppearanceCell
//

#undef LOG_TAG
#define LOG_TAG @"PreviewAppearanceCell"

@implementation PreviewAppearanceCell

+ (void)initialize {
    DDLogVerbose(@"%@ initialize", LOG_TAG);
    
    DESIGN_SHADOW_COLOR = [UIColor colorWithRed:210./255. green:210./255. blue:210./255. alpha:1];
}

- (void)awakeFromNib {
    DDLogVerbose(@"%@ awakeFromNib", LOG_TAG);
    
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    
    self.backgroundImageView.hidden = YES;
    
    self.timeLabelHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.timeLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.timeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.timeLabel.userInteractionEnabled = NO;
    self.timeLabel.numberOfLines = 0;
    self.timeLabel.font = Design.FONT_MEDIUM26;
    [self.timeLabel setPaddingWithTop:0 left:0 bottom:0 right:0];
    [self.timeLabel setTextColor:Design.TIME_COLOR];
    [self.timeLabel setDecorColor:[UIColor clearColor]];
    [self.timeLabel setBorderColor:[UIColor clearColor]];
    [self.timeLabel setBorderWidth:0];
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
    
    self.avatarViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.avatarViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.avatarViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.avatarView.layer.cornerRadius = self.avatarViewHeightConstraint.constant * 0.5;
    self.avatarView.layer.masksToBounds = YES;
    self.avatarView.image = [UIImage imageNamed:@"PreviewAvatar"];
    
    CGFloat largeRadius = DESIGN_LARGE_ROUND_CORNER_RADIUS * Design.HEIGHT_RATIO;
    CGFloat smallRadius = DESIGN_SMALL_ROUND_CORNER_RADIUS * Design.HEIGHT_RATIO;
    
    self.contentLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.contentLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.contentLabel.font = Design.FONT_REGULAR32;
    self.contentLabel.numberOfLines = 0;
    self.contentLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.contentLabel.preferredMaxLayoutWidth = DESIGN_MESSAGE_CELL_MAX_WIDTH * Design.WIDTH_RATIO;
    self.contentLabel.textColor = [UIColor whiteColor];
    CGFloat heightPadding = DESIGN_TEXT_HEIGHT_PADDING * Design.HEIGHT_RATIO;
    CGFloat widthPadding = DESIGN_TEXT_WIDTH_PADDING * Design.WIDTH_RATIO;
    [self.contentLabel setPaddingWithTop:heightPadding left:widthPadding bottom:heightPadding right:widthPadding];
    [self.contentLabel setDecorShadowColor:[UIColor clearColor]];
    [self.contentLabel setDecorColor:Design.MAIN_COLOR];
    [self.contentLabel setBorderColor:[UIColor clearColor]];
    [self.contentLabel setCornerRadiusWithTopLeft:largeRadius topRight:largeRadius bottomRight:smallRadius bottomLeft:largeRadius];
    self.contentLabel.text = TwinmeLocalizedString(@"space_appearance_view_controller_preview_message", nil);
    
    self.peerContentLabelLeadingConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.peerContentLabel.font = Design.FONT_REGULAR32;
    self.peerContentLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.peerContentLabel.numberOfLines = 0;
    self.peerContentLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.peerContentLabel.preferredMaxLayoutWidth = DESIGN_PEER_MESSAGE_CELL_MAX_WIDTH * Design.WIDTH_RATIO;
    [self.peerContentLabel setPaddingWithTop:heightPadding left:widthPadding bottom:heightPadding right:widthPadding];
    [self.peerContentLabel setDecorShadowColor:DESIGN_SHADOW_COLOR];
    [self.peerContentLabel setDecorColor:Design.GREY_ITEM];
    [self.peerContentLabel setBorderColor:[UIColor clearColor]];
    [self.peerContentLabel setCornerRadiusWithTopLeft:largeRadius topRight:largeRadius bottomRight:largeRadius bottomLeft:largeRadius];
    self.peerContentLabel.text = TwinmeLocalizedString(@"space_appearance_view_controller_preview_peer_message", nil);
    
    self.stateImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.stateImageViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.stateImageViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.stateImageView.layer.cornerRadius = self.stateImageViewHeightConstraint.constant * 0.5;
    self.stateImageView.clipsToBounds = YES;
    self.stateImageView.image = [UIImage imageNamed:@"ItemStateReceived"];
}

- (void)bind {
    DDLogVerbose(@"%@ bind", LOG_TAG);
    
    self.contentView.backgroundColor = Design.CONVERSATION_BACKGROUND_COLOR;
    
    [self.timeLabel setTextColor:Design.TIME_COLOR];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    self.timeLabel.enabledTextCheckingTypes = 0;
    self.timeLabel.text = [dateFormatter stringFromDate:[NSDate date]];
    
    self.contentLabel.textColor = [UIColor whiteColor];
    [self.contentLabel setDecorColor:Design.MAIN_COLOR];
    self.contentLabel.text = TwinmeLocalizedString(@"space_appearance_view_controller_preview_message", nil);
    
    self.peerContentLabel.textColor = Design.FONT_COLOR_DEFAULT;
    [self.peerContentLabel setDecorColor:Design.GREY_ITEM];
    self.peerContentLabel.text = TwinmeLocalizedString(@"space_appearance_view_controller_preview_peer_message", nil);
    
    [self.peerContentLabel setNeedsDisplay];
    [self.contentLabel setNeedsDisplay];
    
    self.backgroundImageViewHeightConstraint.constant = self.contentView.frame.size.height;
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.contentLabel.font = Design.FONT_REGULAR32;
    self.peerContentLabel.font = Design.FONT_REGULAR32;
}

@end

