/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "SearchContentMessageCell.h"

#import <Twinme/TLTwinmeAttributes.h>
#import <TwinmeCommon/Design.h>
#import <Utils/NSString+Utils.h>

#import "DecoratedLabel.h"
#import "UIContact.h"
#import "UIConversation.h"

#import "UIColor+Hex.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static const CGFloat DESIGN_LARGE_ROUND_CORNER_RADIUS = 38;
static const CGFloat DESIGN_SMALL_ROUND_CORNER_RADIUS = 8;

//
// Interface: SearchContentMessageCell ()
//

@interface SearchContentMessageCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelBottomConstraint;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentLabelBottomConstraint;
@property (weak, nonatomic) IBOutlet DecoratedLabel *contentLabel;

@end

//
// Implementation: SearchContentMessageCell
//

#undef LOG_TAG
#define LOG_TAG @"SearchContentMessageCell"

@implementation SearchContentMessageCell

- (void)awakeFromNib {
    DDLogVerbose(@"%@ awakeFromNib", LOG_TAG);
    
    [super awakeFromNib];
    
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.avatarViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.avatarViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.avatarView.layer.cornerRadius = self.avatarViewHeightConstraint.constant * 0.5;
    self.avatarView.layer.masksToBounds = YES;
    
    self.nameLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.nameLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.nameLabelBottomConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.nameLabel.font = Design.FONT_MEDIUM28;
    self.nameLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.dateLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.dateLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
        
    self.dateLabel.font = Design.FONT_REGULAR28;
    self.dateLabel.textColor = Design.FONT_COLOR_GREY;
    
    if ([[UIApplication sharedApplication] userInterfaceLayoutDirection] == UIUserInterfaceLayoutDirectionRightToLeft) {
        self.dateLabel.textAlignment = NSTextAlignmentLeft;
        self.nameLabel.textAlignment = NSTextAlignmentLeft;
    }
    
    self.contentLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.contentLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.contentLabelBottomConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.contentLabel.font = Design.FONT_REGULAR32;
    
    CGFloat largeRadius = DESIGN_LARGE_ROUND_CORNER_RADIUS * Design.HEIGHT_RATIO;
    CGFloat smallRadius = DESIGN_SMALL_ROUND_CORNER_RADIUS * Design.HEIGHT_RATIO;
    
    self.contentLabel.numberOfLines = 0;
    self.contentLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.contentLabel.preferredMaxLayoutWidth = Design.PEER_MESSAGE_CELL_MAX_WIDTH;
    self.contentLabel.textColor = [UIColor whiteColor];
    [self.contentLabel setCornerRadiusWithTopLeft:smallRadius topRight:largeRadius bottomRight:largeRadius bottomLeft:largeRadius];
    
    CGFloat heightPadding = Design.TEXT_HEIGHT_PADDING;
    CGFloat widthPadding = Design.TEXT_WIDTH_PADDING;
    [self.contentLabel setPaddingWithTop:heightPadding left:widthPadding bottom:heightPadding right:widthPadding];
    [self.contentLabel setDecorShadowColor:[UIColor clearColor]];
    [self.contentLabel setDecorColor:Design.MAIN_COLOR];
    [self.contentLabel setBorderColor:[UIColor clearColor]];
    [self.contentLabel setBorderWidth:0];
}

- (void)bindWithConversation:(UIConversation *)uiConversation search:(NSString *)search {
    DDLogVerbose(@"%@ bindWithConversation: %@", LOG_TAG, uiConversation);
    
    self.nameLabel.text = uiConversation.uiContact.name;
    self.dateLabel.text = [uiConversation getLastMessageDate];
    
    if ([uiConversation isLocalDescriptor]) {
        [self.contentLabel setDecorColor:Design.MAIN_COLOR];
        [self.contentLabel setBorderColor:[UIColor clearColor]];
        [self.contentLabel setTextColor:[UIColor whiteColor]];
    } else {
        [self.contentLabel setDecorColor:Design.GREY_ITEM];
        [self.contentLabel setBorderColor:[UIColor clearColor]];
        [self.contentLabel setTextColor:Design.FONT_COLOR_DEFAULT];
    }
        
    NSString *message = [[uiConversation getMessage] stringByReplacingOccurrencesOfString:search withString:[NSString stringWithFormat:@"~%@~", search] options:NSCaseInsensitiveSearch range:NSMakeRange(0, [uiConversation getMessage].length)];
    
    @try {
        NSAttributedString *attributedString = [NSString formatText:message fontSize:Design.FONT_REGULAR32.pointSize fontColor:self.contentLabel.textColor fontSearch:Design.FONT_BOLD34];
        self.contentLabel.text = attributedString;
    } @catch (NSException *exception) {
        self.contentLabel.text = [uiConversation getLastMessage];
    }
        
    if ([uiConversation.uiContact.avatar isEqual:[TLTwinmeAttributes DEFAULT_GROUP_AVATAR]]) {
        self.avatarView.backgroundColor = [UIColor colorWithHexString:Design.DEFAULT_COLOR alpha:1.0];
        self.avatarView.tintColor = [UIColor whiteColor];
    } else {
        self.avatarView.backgroundColor = [UIColor clearColor];
        self.avatarView.tintColor = [UIColor clearColor];
    }
    
    self.avatarView.image = uiConversation.uiContact.avatar;
    
    [self updateFont];
    [self updateColor];
    [self setNeedsDisplay];
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.nameLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.dateLabel.textColor = Design.FONT_COLOR_GREY;
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    self.contentLabel.font = Design.FONT_REGULAR32;
    self.nameLabel.font = Design.FONT_MEDIUM28;
    self.dateLabel.font = Design.FONT_REGULAR28;
}

@end
